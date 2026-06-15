import Foundation
import Combine
import AppKit

/// 游戏主引擎 — 管理游戏循环、状态更新和事件分发
class GameEngine: ObservableObject {
    @Published var hero: Hero
    @Published var party: HeroParty
    @Published var runeTree: RuneTree
    @Published var cubeProgress: CubeProgress
    @Published var activeSkillLoadouts: ActiveSkillLoadouts
    @Published var currentBattle: Battle?
    @Published var battleLockReason: String?
    @Published var inventory: Inventory
    @Published var progress: ProgressTracker
    @Published var statistics: GameStatistics
    @Published var autoEquipBestItems: Bool
    @Published var soundEffectsEnabled: Bool {
        didSet {
            audio.isEnabled = soundEffectsEnabled
        }
    }

    private var tickTimer: Timer?
    private let tickInterval: TimeInterval = 1.0
    private let saveManager: SaveManager
    private let audio: GameAudioPlaying
    private var terminationObserver: NSObjectProtocol?
    private var unyieldingWillConsumedStageKey: String?

    /// 每 30 个 tick（约 30 秒）自动保存一次
    private let autosaveTicks = 30
    private var ticksSinceLastSave = 0

    init(saveManager: SaveManager = SaveManager(), audio: GameAudioPlaying = GameAudio.shared) {
        self.hero = Hero()
        self.party = HeroParty()
        self.runeTree = RuneTree()
        self.cubeProgress = CubeProgress()
        self.activeSkillLoadouts = ActiveSkillLoadouts()
        self.battleLockReason = nil
        self.inventory = Inventory()
        self.progress = ProgressTracker()
        self.statistics = GameStatistics()
        self.autoEquipBestItems = false
        self.soundEffectsEnabled = true
        self.saveManager = saveManager
        self.audio = audio
        self.audio.isEnabled = soundEffectsEnabled
    }

    deinit {
        tickTimer?.invalidate()
        if let terminationObserver {
            NotificationCenter.default.removeObserver(terminationObserver)
        }
    }

    // MARK: - Lifecycle

    func start() {
        loadSave()
        calculateOfflineProgress()
        startNextBattle()
        observeTermination()
        startTickTimer()
    }

    func stop() {
        tickTimer?.invalidate()
        tickTimer = nil
        save()
    }

    private func startTickTimer() {
        tickTimer?.invalidate()
        let timer = Timer(timeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        // .common 模式：菜单栏弹窗打开（eventTracking）期间游戏循环不暂停
        RunLoop.main.add(timer, forMode: .common)
        tickTimer = timer
    }

    /// 进程退出（含 Cmd+Q、系统注销）时兜底保存
    private func observeTermination() {
        guard terminationObserver == nil else { return }
        terminationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.save()
        }
    }

    // MARK: - Game Loop

    private func tick() {
        ticksSinceLastSave += 1
        if ticksSinceLastSave >= autosaveTicks {
            ticksSinceLastSave = 0
            save()
        }

        guard hero.isAlive else { return }

        currentBattle?.update(deltaTime: tickInterval)
        statistics.totalPlayTime += tickInterval

        if let battle = currentBattle, battle.isOver {
            handleBattleResult(battle.result)
            startNextBattle()
        }
    }

    // MARK: - Battle

    private func startNextBattle() {
        if let lockReason = progress.stageLockReason {
            battleLockReason = lockReason
            currentBattle = nil
            return
        }

        battleLockReason = nil
        let encounter = progress.currentEncounterState
        let waveEncounters = progress.currentEncounterPlan
            .encounters(inWave: encounter.wave)
            .filter { $0.encounterIndex >= encounter.encounterIndex }
        let plannedEncounters = waveEncounters.isEmpty ? [encounter] : waveEncounters
        let monsters = plannedEncounters.map {
            progress.currentStage.spawnMonster(
                difficulty: progress.currentDifficulty,
                encounterIndex: $0.encounterIndex
            )
        }
        let stageRevivalKey = currentStageRevivalKey
        let battle = Battle(
            hero: hero,
            monsters: monsters,
            party: party,
            activeSkillSlotCount: runeTree.activeSkillSlotCount,
            activeSkillLoadouts: activeSkillLoadouts,
            unyieldingWillAvailable: unyieldingWillConsumedStageKey != stageRevivalKey
        )
        battle.onUnyieldingWillUsed = { [weak self] in
            self?.unyieldingWillConsumedStageKey = stageRevivalKey
        }
        battle.onEvent = { [weak self] event in
            self?.handleBattleEvent(event)
        }
        currentBattle = battle
    }

    private var currentStageRevivalKey: String {
        "\(progress.currentDifficulty.rawValue):\(progress.currentStage.displayCode)"
    }

    private func handleBattleResult(_ result: BattleResult?) {
        guard let result = result else { return }
        switch result {
        case .victory(let rewards):
            let clearedStage = progress.currentStage
            let clearedDifficulty = progress.currentDifficulty
            let oldLevel = hero.level
            hero.gainXP(rewards.xp)
            handleLevelGain(from: oldLevel)
            hero.gainGold(rewards.gold)
            // 背包满时战利品丢失；自动装备成功也视作已保留战利品。
            let lootStoredCount = retainLoot(rewards.lootItems)
            if lootStoredCount > 0 {
                audio.play(.lootFound)
            }
            _ = progress.advance(by: rewards.encountersCleared)
            statistics.recordVictory(
                rewards: rewards,
                lootStoredCount: lootStoredCount,
                chapter: clearedStage.act,
                difficulty: clearedDifficulty,
                stage: clearedStage
            )

        case .defeat:
            statistics.recordDefeat()
            hero.respawn()
        }
    }

    static func audioEvent(for event: BattleEvent) -> GameAudioEvent {
        switch event {
        case .heroAttack(let isCrit):
            return isCrit ? .heroCriticalHit : .heroAttack
        case .heroSkill(_, let isCrit):
            return isCrit ? .heroCriticalHit : .skillCast
        case .supportAttack(let isCrit):
            return isCrit ? .heroCriticalHit : .heroAttack
        case .supportSkill(_, _, let isCrit):
            return isCrit ? .heroCriticalHit : .skillCast
        case .heroDamaged:
            return .heroDamaged
        case .battleWon(_):
            return .battleWon
        case .battleLost:
            return .battleLost
        }
    }

    private func handleBattleEvent(_ event: BattleEvent) {
        audio.play(Self.audioEvent(for: event))
    }

    // MARK: - Inventory

    /// 从背包装备物品；被替换下的旧装备放回背包，不会丢失
    func equipItem(_ item: Item) {
        guard item.slot != nil else { return }
        guard inventory.items.contains(item) else { return }
        inventory.remove(item)
        if let old = hero.equipment.equip(item) {
            inventory.add(old)
        }
        audio.play(.itemEquipped)
    }

    func setAutoEquipBestItems(_ enabled: Bool) {
        autoEquipBestItems = enabled
        if enabled {
            equipBestItemsFromInventory()
        }
        save()
    }

    func setSoundEffectsEnabled(_ enabled: Bool) {
        soundEffectsEnabled = enabled
        save()
    }

    @discardableResult
    func infuseItemIntoCube(_ item: Item) -> Int? {
        guard !item.isLocked else { return nil }
        guard inventory.items.contains(item) else { return nil }

        inventory.remove(item)
        let gainedExperience = cubeProgress.infuse(item)
        save()
        return gainedExperience
    }

    @discardableResult
    func alchemizeItem(_ item: Item) -> Int? {
        guard !item.isLocked else { return nil }
        guard inventory.items.contains(item) else { return nil }

        inventory.remove(item)
        let gainedGold = item.rarity.alchemyGoldValue
        hero.gainGold(gainedGold)
        save()
        return gainedGold
    }

    @discardableResult
    func synthesizeItems(rarity: Rarity) -> Item? {
        guard let outputRarity = rarity.synthesisOutputRarity else { return nil }
        let consumed = SynthesisPreview.selectedInputs(for: rarity, in: inventory.items)
        guard consumed.count == Rarity.synthesisInputCount else { return nil }

        let outputType = consumed.compactMap(\.equipmentType).first ?? .sword
        let outputLevel = consumed.map(\.itemLevel).max() ?? 1

        for item in consumed {
            inventory.remove(item)
        }

        let output = LootTable.makeItem(
            type: outputType,
            rarity: outputRarity,
            itemLevel: outputLevel
        )
        guard inventory.add(output) else {
            for item in consumed {
                inventory.add(item)
            }
            return nil
        }

        audio.play(.lootFound)
        save()
        return output
    }

    func previewSoundEffect() {
        audio.play(.preview)
    }

    func setHeroClass(_ heroClass: HeroClass) {
        hero.changeClass(to: heroClass)
        party.setPrimaryClass(heroClass)
        applyRuneTreeUnlocks()
        startNextBattle()
        save()
    }

    func setPartyMember(slotIndex: Int, heroClass: HeroClass) {
        guard party.member(at: slotIndex)?.isUnlocked == true else { return }
        party.setHeroClass(heroClass, atSlot: slotIndex)
        if slotIndex == 0 {
            hero.changeClass(to: party.member(at: 0)?.heroClass ?? heroClass)
        }
        startNextBattle()
        save()
    }

    func setActiveSkill(_ skillID: String, for heroClass: HeroClass, slotIndex: Int) {
        activeSkillLoadouts.setSkill(skillID, for: heroClass, slotIndex: slotIndex)
        startNextBattle()
        save()
    }

    @discardableResult
    func selectStage(_ selection: StageSelectionOption) -> Bool {
        guard progress.selectStage(selection) else { return false }
        startNextBattle()
        save()
        return true
    }

    func restartCurrentStage() {
        progress.restartCurrentStage()
        startNextBattle()
        save()
    }

    @discardableResult
    func unlockRuneTreeNode(_ node: RuneTreeNode) -> Bool {
        guard runeTree.unlock(node, heroLevel: hero.level, availableGold: hero.gold) else { return false }
        hero.gold -= node.goldCost
        applyRuneTreeUnlocks()
        startNextBattle()
        save()
        return true
    }

    func canUnlockRuneTreeNode(_ node: RuneTreeNode) -> Bool {
        runeTree.canUnlock(node, heroLevel: hero.level, availableGold: hero.gold)
    }

    func directPartySlotUnlockCost(slotIndex: Int) -> Int? {
        runeTree.directPartySlotUnlockCost(for: slotIndex)
    }

    func canDirectlyUnlockPartySlot(slotIndex: Int) -> Bool {
        runeTree.canDirectlyUnlockPartySlot(slotIndex, availableGold: hero.gold)
    }

    @discardableResult
    func directlyUnlockPartySlot(slotIndex: Int) -> Bool {
        guard let spentGold = runeTree.directlyUnlockPartySlot(slotIndex, availableGold: hero.gold) else {
            return false
        }

        hero.gold -= spentGold
        applyRuneTreeUnlocks()
        startNextBattle()
        save()
        return true
    }

    func resetRuneTree() {
        let refundGold = runeTree.resetUnlockedNodes()
        if refundGold > 0 {
            hero.gainGold(refundGold)
        }
        applyRuneTreeUnlocks()
        startNextBattle()
        save()
    }

    func equipBestItemsFromInventory() {
        for slot in EquipSlot.allCases {
            guard let best = inventory.items
                .filter({ $0.slot == slot })
                .max(by: { $0.equipmentScore < $1.equipmentScore }) else {
                continue
            }

            if best.isBetterEquipment(than: hero.equipment.item(in: slot)) {
                equipItem(best)
            }
        }
    }

    @discardableResult
    func openChest(kind: ChestKind) -> Bool {
        guard let chest = progress.openChest(kind: kind) else { return false }
        retainOpenedChest(chest)
        return true
    }

    @discardableResult
    func openChest(id: String) -> Bool {
        guard let chest = progress.openChest(id: id) else { return false }
        retainOpenedChest(chest)
        return true
    }

    @discardableResult
    func openAllChests() -> Int {
        let chestIDs = progress.chests.chests.map(\.id)
        var openedCount = 0

        for chestID in chestIDs where openChest(id: chestID) {
            openedCount += 1
        }

        return openedCount
    }

    private func retainOpenedChest(_ chest: LootChest) {
        let item = LootTable.roll(for: chest)
        let lootStored = retainLoot(item)
        if lootStored {
            statistics.itemsFound += 1
        }
        audio.play(.lootFound)
        if currentBattle == nil {
            startNextBattle()
        }
        save()
    }

    private func retainLoot(_ item: Item?) -> Bool {
        guard let item else { return false }

        if autoEquipBestItems, autoEquipLootItemIfBetter(item) {
            return true
        }

        return inventory.add(item)
    }

    private func retainLoot(_ items: [Item]) -> Int {
        items.reduce(0) { storedCount, item in
            storedCount + (retainLoot(item) ? 1 : 0)
        }
    }

    private func autoEquipLootItemIfBetter(_ item: Item) -> Bool {
        guard let slot = item.slot else { return false }
        guard item.isBetterEquipment(than: hero.equipment.item(in: slot)) else { return false }

        let old = hero.equipment.item(in: slot)
        guard old == nil || !inventory.isFull else { return false }

        if let old = hero.equipment.equip(item) {
            inventory.add(old)
        }
        audio.play(.itemEquipped)
        return true
    }

    // MARK: - Offline Progress

    private func calculateOfflineProgress() {
        guard let lastSave = saveManager.lastSaveTimestamp else { return }
        let offlineSeconds = Date().timeIntervalSince(lastSave)
        guard offlineSeconds > 60 else { return }
        guard runeTree.offlineRewardsUnlocked else { return }

        let rewards = OfflineProgress.calculate(
            hero: hero,
            stage: progress.currentStage,
            difficulty: progress.currentDifficulty,
            offlineSeconds: offlineSeconds,
            offlineGoldMultiplier: runeTree.offlineGoldMultiplier,
            offlineXPMultiplier: runeTree.offlineXPMultiplier
        )

        let oldLevel = hero.level
        hero.gainXP(rewards.xp)
        handleLevelGain(from: oldLevel)
        hero.gainGold(rewards.gold)
        statistics.offlineXP += rewards.xp
        statistics.offlineGold += rewards.gold
    }

    // MARK: - Save/Load

    func save() {
        let data = SaveData(
            hero: hero,
            party: party,
            runeTree: runeTree,
            cubeProgress: cubeProgress,
            activeSkillLoadouts: activeSkillLoadouts,
            inventory: inventory,
            progress: progress,
            statistics: statistics,
            autoEquipBestItems: autoEquipBestItems,
            soundEffectsEnabled: soundEffectsEnabled,
            unyieldingWillConsumedStageKey: unyieldingWillConsumedStageKey,
            timestamp: Date()
        )
        saveManager.save(data)
    }

    private func loadSave() {
        guard let data = saveManager.load() else { return }
        hero = data.hero
        party = data.party
        runeTree = data.runeTree
        cubeProgress = data.cubeProgress
        activeSkillLoadouts = data.activeSkillLoadouts
        party.setPrimaryClass(hero.heroClass)
        inventory = data.inventory
        applyRuneTreeUnlocks()
        progress = data.progress
        statistics = data.statistics
        autoEquipBestItems = data.autoEquipBestItems
        soundEffectsEnabled = data.soundEffectsEnabled
        unyieldingWillConsumedStageKey = data.unyieldingWillConsumedStageKey
        if autoEquipBestItems {
            equipBestItemsFromInventory()
        }
    }

    /// 删除存档并将内存中的游戏状态完整重置
    func resetGame() {
        saveManager.deleteSave()
        hero = Hero()
        runeTree = RuneTree()
        cubeProgress = CubeProgress()
        activeSkillLoadouts = ActiveSkillLoadouts()
        party = HeroParty(primaryClass: hero.heroClass, unlockedSlotCount: runeTree.unlockedPartySlotCount)
        inventory = Inventory()
        progress = ProgressTracker()
        statistics = GameStatistics()
        autoEquipBestItems = false
        soundEffectsEnabled = true
        unyieldingWillConsumedStageKey = nil
        battleLockReason = nil
        ticksSinceLastSave = 0
        applyRuneTreeUnlocks()
        startNextBattle()
    }

    private func handleLevelGain(from oldLevel: Int) {
        let gainedLevels = hero.level - oldLevel
        guard gainedLevels > 0 else { return }
        applyRuneTreeUnlocks()
        audio.play(.levelUp)
    }

    private func applyRuneTreeUnlocks() {
        party.setUnlockedSlotCount(runeTree.unlockedPartySlotCount)
        inventory.setMaxCapacity(runeTree.inventoryCapacity)
    }
}

#if DEBUG
extension GameEngine {
    func runSelfTestTick() {
        tick()
    }
}
#endif
