import Foundation
import Combine
import AppKit

/// 游戏主引擎 — 管理游戏循环、状态更新和事件分发
class GameEngine: ObservableObject {
    @Published var hero: Hero
    @Published var party: HeroParty
    @Published var runeTree: RuneTree
    @Published var cubeProgress: CubeProgress
    @Published var purchasedInventoryExpansionCount: Int
    @Published var activeSkillLoadouts: ActiveSkillLoadouts
    @Published var currentBattle: Battle?
    @Published var battleLockReason: String?
    @Published var inventory: Inventory
    @Published var progress: ProgressTracker
    @Published var statistics: GameStatistics
    @Published private(set) var autoOpenChestCooldowns: AutoOpenChestCooldowns
    @Published private(set) var recentBattleLog: [BattleLogEntry]
    @Published var autoEquipBestItems: Bool
    @Published var worseEquipmentHandling: WorseEquipmentHandling
    @Published var soundEffectsEnabled: Bool {
        didSet {
            audio.isEnabled = soundEffectsEnabled
        }
    }

    private var tickTimer: Timer?
    private let tickInterval: TimeInterval = GamePacing.runtimeTickInterval
    private let saveManager: SaveManager
    private let audio: GameAudioPlaying
    private var terminationObserver: NSObjectProtocol?
    private var unyieldingWillConsumedStageKey: String?
    private var needsSaveAfterStartupNormalization = false

    /// 每 30 个 tick（当前约 30 秒）自动保存一次
    private let autosaveTicks = 30
    private var ticksSinceLastSave = 0
    private let retainedBattleLogLimit = 300

    init(saveManager: SaveManager = SaveManager(), audio: GameAudioPlaying = GameAudio.shared) {
        self.hero = Hero()
        self.party = HeroParty()
        self.runeTree = RuneTree()
        self.cubeProgress = CubeProgress()
        self.purchasedInventoryExpansionCount = 0
        self.activeSkillLoadouts = ActiveSkillLoadouts()
        self.battleLockReason = nil
        self.inventory = Inventory()
        self.progress = ProgressTracker()
        self.statistics = GameStatistics()
        self.autoOpenChestCooldowns = AutoOpenChestCooldowns()
        self.recentBattleLog = []
        self.autoEquipBestItems = false
        self.worseEquipmentHandling = .keep
        self.soundEffectsEnabled = true
        self.saveManager = saveManager
        self.audio = audio
        self.audio.isEnabled = soundEffectsEnabled
        self.audio.isMutedByInterface = true
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
        saveAfterStartupNormalizationIfNeeded()
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

        let battleLogCountBeforeUpdate = currentBattle?.log.count ?? 0
        updateCurrentBattle(deltaTime: GamePacing.simulatedCombatDelta(for: tickInterval))
        appendRecentBattleLog(from: currentBattle, startingAt: battleLogCountBeforeUpdate)
        statistics.totalPlayTime += tickInterval
        tickAutoOpenChests(deltaTime: tickInterval)

        if let battle = currentBattle, battle.isOver {
            handleBattleResult(battle.result)
            if progress.isAwaitingNewGamePlus {
                currentBattle = nil
                battleLockReason = nil
            } else {
                startNextBattle()
            }
        }
    }

    private func updateCurrentBattle(deltaTime: TimeInterval) {
        var remainingBattleTime = max(0, deltaTime)
        let simulationStep = max(0.01, GamePacing.combatSimulationStep)

        while remainingBattleTime > 0,
              let battle = currentBattle,
              !battle.isOver {
            let step = min(simulationStep, remainingBattleTime)
            battle.update(deltaTime: step)
            remainingBattleTime -= step
        }
    }

    // MARK: - Battle

    private func startNextBattle() {
        if progress.isAwaitingNewGamePlus {
            battleLockReason = nil
            currentBattle = nil
            return
        }

        if let lockReason = progress.stageLockReason {
            battleLockReason = lockReason
            currentBattle = nil
            return
        }

        battleLockReason = nil
        let clearTargetReduction = runeTree.stageClearTargetReduction
        let encounter = progress.currentEncounterState(clearTargetReduction: clearTargetReduction)
        let waveEncounters = progress.currentEncounterPlan(clearTargetReduction: clearTargetReduction)
            .encounters(inWave: encounter.wave)
            .filter { $0.encounterIndex >= encounter.encounterIndex }
        let plannedEncounters = waveEncounters.isEmpty ? [encounter] : waveEncounters
        let monsters = plannedEncounters.map {
            progress.currentStage.spawnMonster(
                difficulty: progress.currentDifficulty,
                encounterIndex: $0.encounterIndex,
                playthrough: progress.playthrough
            )
        }
        let stageRevivalKey = currentStageRevivalKey
        let battle = Battle(
            hero: hero,
            monsters: monsters,
            party: party,
            activeSkillSlotCount: runeTree.activeSkillSlotCount,
            activeSkillLoadouts: activeSkillLoadouts,
            allHeroAttackDamageBonus: runeTree.allHeroAttackDamage,
            allHeroAttackDamageMultiplier: runeTree.allHeroAttackDamageMultiplier,
            allHeroArmorBonus: runeTree.allHeroArmor,
            allHeroArmorMultiplier: runeTree.allHeroArmorMultiplier,
            allHeroAttackSpeedMultiplier: runeTree.allHeroAttackSpeedMultiplier,
            allHeroMoveSpeedBonus: runeTree.allHeroMoveSpeed,
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

    private func appendRecentBattleLog(from battle: Battle?, startingAt startIndex: Int) {
        guard let battle, battle.log.count > startIndex else { return }
        recentBattleLog.append(contentsOf: battle.log[startIndex...])
        let overflow = recentBattleLog.count - retainedBattleLogLimit
        if overflow > 0 {
            recentBattleLog.removeFirst(overflow)
        }
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
            let rewardEncounterKind = combatRewardEncounterKind(
                stage: clearedStage,
                difficulty: clearedDifficulty,
                startingEncounterIndex: progress.killsInChapter,
                encountersCleared: rewards.encountersCleared
            )
            let earnedRewards = adjustedVictoryRewards(rewards, encounterKind: rewardEncounterKind)
            let oldLevel = hero.level
            grantHeroXP(earnedRewards.xp)
            handleLevelGain(from: oldLevel)
            hero.gainGold(earnedRewards.gold)
            // 背包满时战利品丢失；自动装备成功也视作已保留战利品。
            let lootStoredCount = retainLoot(rewards.lootItems)
            if lootStoredCount > 0 {
                audio.play(.lootFound)
            }
            _ = progress.advance(
                by: rewards.encountersCleared,
                chestStorageLimits: runeTree.chestStorageLimits,
                clearTargetReduction: runeTree.stageClearTargetReduction,
                chestDropBonuses: runeTree.chestDropBonuses
            )
            statistics.recordVictory(
                rewards: earnedRewards,
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

    private func adjustedVictoryRewards(
        _ rewards: BattleResult.Rewards,
        encounterKind: CombatRewardEncounterKind
    ) -> BattleResult.Rewards {
        BattleResult.Rewards(
            xp: Int(Double(rewards.xp) * runeTree.combatXPMultiplier(for: encounterKind)),
            gold: Int(Double(rewards.gold) * runeTree.combatGoldMultiplier(for: encounterKind)),
            lootItems: rewards.lootItems,
            encountersCleared: rewards.encountersCleared
        )
    }

    func previewVictoryRewards(_ rewards: BattleResult.Rewards) -> BattleResult.Rewards {
        let rewardEncounterKind = combatRewardEncounterKind(
            stage: progress.currentStage,
            difficulty: progress.currentDifficulty,
            startingEncounterIndex: progress.killsInChapter,
            encountersCleared: rewards.encountersCleared
        )
        let adjustedRewards = adjustedVictoryRewards(rewards, encounterKind: rewardEncounterKind)
        let appliedXP = HeroLevelPacing.previewGrantedXP(
            adjustedRewards.xp,
            for: hero,
            maxLevel: HeroLevelPacing.maxHeroLevel(for: progress)
        )
        return BattleResult.Rewards(
            xp: appliedXP,
            gold: adjustedRewards.gold,
            lootItems: adjustedRewards.lootItems,
            encountersCleared: adjustedRewards.encountersCleared
        )
    }

    private func combatRewardEncounterKind(
        stage: StageDefinition,
        difficulty: Difficulty,
        startingEncounterIndex: Int,
        encountersCleared: Int
    ) -> CombatRewardEncounterKind {
        if stage.isBoss {
            return .actBoss
        }

        let clearTargetReduction = runeTree.stageClearTargetReduction
        let clearedRange = 0..<max(1, encountersCleared)
        let clearedAnyStageLeader = clearedRange.contains { offset in
            stage.encounterState(
                for: difficulty,
                encounterIndex: startingEncounterIndex + offset,
                clearTargetReduction: clearTargetReduction
            ).monsterSpawn.isStageLeader
        }
        return clearedAnyStageLeader ? .stageBoss : .normalMonster
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

    func setWorseEquipmentHandling(_ handling: WorseEquipmentHandling) {
        worseEquipmentHandling = handling
        save()
    }

    func setSoundEffectsEnabled(_ enabled: Bool) {
        soundEffectsEnabled = enabled
        save()
    }

    func setInterfaceAudioActive(_ active: Bool) {
        audio.isMutedByInterface = !active
    }

    @discardableResult
    func infuseItemIntoCube(_ item: Item) -> Int? {
        guard !item.isLocked else { return nil }
        guard inventory.items.contains(item) else { return nil }

        inventory.remove(item)
        let gainedExperience = cubeProgress.infuse(item, multiplier: runeTree.cubeExperienceMultiplier)
        audio.play(.itemConsumed)
        save()
        return gainedExperience
    }

    @discardableResult
    func alchemizeItem(_ item: Item) -> Int? {
        guard !item.isLocked else { return nil }
        guard inventory.items.contains(item) else { return nil }

        inventory.remove(item)
        let gainedGold = alchemyGold(for: item)
        hero.gainGold(gainedGold)
        audio.play(.itemConsumed)
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

    var nextInventoryExpansionGoldCost: Int {
        InventoryExpansion.nextGoldCost(after: purchasedInventoryExpansionCount)
    }

    func canPurchaseInventoryExpansion() -> Bool {
        hero.gold >= nextInventoryExpansionGoldCost
    }

    @discardableResult
    func purchaseInventoryExpansion() -> Bool {
        let cost = nextInventoryExpansionGoldCost
        guard hero.gold >= cost else { return false }

        hero.gold -= cost
        purchasedInventoryExpansionCount += 1
        applyRuneTreeUnlocks()
        audio.play(.itemConsumed)
        save()
        return true
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
    func startNextPlaythrough() -> Bool {
        guard progress.startNextPlaythrough() else { return false }
        unyieldingWillConsumedStageKey = nil
        startNextBattle()
        save()
        return true
    }

    @discardableResult
    func unlockRuneTreeNode(_ node: RuneTreeNode) -> Bool {
        guard runeTree.unlock(node, heroLevel: hero.level, availableGold: hero.gold) else { return false }
        hero.gold -= node.goldCost
        applyRuneTreeUnlocks()
        refreshAutoOpenCooldowns(afterUnlocking: node)
        startNextBattle()
        save()
        return true
    }

    func canUnlockRuneTreeNode(_ node: RuneTreeNode) -> Bool {
        runeTree.canUnlock(node, heroLevel: hero.level, availableGold: hero.gold)
    }

    var unlockableRuneTreeNodeCount: Int {
        runeTreeUnlockPreview.unlockedNodes.count
    }

    var unlockableRuneTreeGoldCost: Int {
        hero.gold - runeTreeUnlockPreview.remainingGold
    }

    @discardableResult
    func unlockAllAvailableRuneTreeNodes() -> Int {
        var remainingGold = hero.gold
        let unlockedNodes = Self.unlockAvailableRuneTreeNodes(
            in: &runeTree,
            heroLevel: hero.level,
            availableGold: &remainingGold
        )
        guard !unlockedNodes.isEmpty else { return 0 }

        hero.gold = remainingGold
        applyRuneTreeUnlocks()
        for node in unlockedNodes {
            refreshAutoOpenCooldowns(afterUnlocking: node)
        }
        startNextBattle()
        save()
        return unlockedNodes.count
    }

    private var runeTreeUnlockPreview: (unlockedNodes: [RuneTreeNode], remainingGold: Int) {
        var previewRuneTree = runeTree
        var previewGold = hero.gold
        let unlockedNodes = Self.unlockAvailableRuneTreeNodes(
            in: &previewRuneTree,
            heroLevel: hero.level,
            availableGold: &previewGold
        )
        return (unlockedNodes, previewGold)
    }

    private static func unlockAvailableRuneTreeNodes(
        in runeTree: inout RuneTree,
        heroLevel: Int,
        availableGold: inout Int
    ) -> [RuneTreeNode] {
        var unlockedNodes: [RuneTreeNode] = []
        var madeProgress = true

        while madeProgress {
            madeProgress = false
            for node in RuneTreeNode.allCases {
                guard !runeTree.isUnlocked(node),
                      runeTree.unlock(node, heroLevel: heroLevel, availableGold: availableGold)
                else { continue }

                availableGold -= node.goldCost
                unlockedNodes.append(node)
                madeProgress = true
            }
        }

        return unlockedNodes
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
        autoOpenChestCooldowns = AutoOpenChestCooldowns()
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
    private func openChest(family: ChestFamily) -> Bool {
        guard let chest = progress.openChest(family: family) else { return false }
        retainOpenedChest(chest)
        return true
    }

    @discardableResult
    func openChests(kind: ChestKind) -> Int {
        guard runeTree.canOpenOneChestTypeAtOnce else { return 0 }
        let chestIDs = progress.chests.chests
            .filter { $0.kind == kind }
            .map(\.id)
        var openedCount = 0

        for chestID in chestIDs where openChest(id: chestID) {
            openedCount += 1
        }

        return openedCount
    }

    @discardableResult
    func openAllChests() -> Int {
        guard runeTree.canOpenAllChestTypesAtOnce else { return 0 }
        let chestIDs = progress.chests.chests.map(\.id)
        var openedCount = 0

        for chestID in chestIDs where openChest(id: chestID) {
            openedCount += 1
        }

        return openedCount
    }

    @discardableResult
    private func tickAutoOpenChests(deltaTime: TimeInterval) -> Int {
        var openedCount = 0

        for family in ChestFamily.allCases {
            guard isAutoOpenEnabled(for: family) else {
                autoOpenChestCooldowns.setRemaining(0, for: family)
                continue
            }

            let remaining = max(0, autoOpenChestCooldowns.remaining(for: family) - max(0, deltaTime))
            guard remaining <= 0 else {
                autoOpenChestCooldowns.setRemaining(remaining, for: family)
                continue
            }

            autoOpenChestCooldowns.setRemaining(runeTree.autoOpenCooldown(for: family), for: family)
            if openChest(family: family) {
                openedCount += 1
            } else {
                autoOpenChestCooldowns.setRemaining(0, for: family)
            }
        }

        return openedCount
    }

    private func isAutoOpenEnabled(for family: ChestFamily) -> Bool {
        switch family {
        case .normalMonster:
            return runeTree.canAutoOpenNormalChests
        case .stageBoss:
            return runeTree.canAutoOpenStageBossChests
        case .actBoss:
            return runeTree.canAutoOpenActBossChests
        }
    }

    private func refreshAutoOpenCooldowns(afterUnlocking node: RuneTreeNode) {
        switch node {
        case .autoOpenNormalChests:
            primeAutoOpenCooldown(for: .normalMonster)
        case .autoOpenStageBossChests:
            primeAutoOpenCooldown(for: .stageBoss)
        case .autoOpenActBossChests:
            primeAutoOpenCooldown(for: .actBoss)
        case _ where RuneTree.normalChestAutoOpenSpeedNodes.contains(node):
            clampAutoOpenCooldown(for: .normalMonster)
        case _ where RuneTree.stageBossChestAutoOpenSpeedNodes.contains(node):
            clampAutoOpenCooldown(for: .stageBoss)
        case _ where RuneTree.actBossChestAutoOpenSpeedNodes.contains(node):
            clampAutoOpenCooldown(for: .actBoss)
        default:
            break
        }
    }

    private func primeAutoOpenCooldown(for family: ChestFamily) {
        guard isAutoOpenEnabled(for: family) else { return }
        let cooldown = runeTree.autoOpenCooldown(for: family)
        let currentRemaining = autoOpenChestCooldowns.remaining(for: family)
        autoOpenChestCooldowns.setRemaining(currentRemaining > 0 ? min(currentRemaining, cooldown) : cooldown, for: family)
    }

    private func clampAutoOpenCooldown(for family: ChestFamily) {
        guard isAutoOpenEnabled(for: family) else { return }
        let cooldown = runeTree.autoOpenCooldown(for: family)
        let currentRemaining = autoOpenChestCooldowns.remaining(for: family)
        guard currentRemaining > cooldown else { return }
        autoOpenChestCooldowns.setRemaining(cooldown, for: family)
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

        if handleWorseEquipmentLoot(item) {
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

    private func handleWorseEquipmentLoot(_ item: Item) -> Bool {
        guard worseEquipmentHandling != .keep else { return false }
        guard let slot = item.slot else { return false }
        guard !item.isBetterEquipment(than: hero.equipment.item(in: slot)) else { return false }

        switch worseEquipmentHandling {
        case .keep:
            return false
        case .alchemize:
            hero.gainGold(alchemyGold(for: item))
            audio.play(.itemConsumed)
            return true
        case .discard:
            return true
        }
    }

    private func alchemyGold(for item: Item) -> Int {
        Int(Double(item.rarity.alchemyGoldValue) * runeTree.alchemyGoldMultiplier)
    }

    // MARK: - Offline Progress

    private func calculateOfflineProgress() {
        guard !progress.isAwaitingNewGamePlus else { return }
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
        let appliedXP = grantHeroXP(rewards.xp)
        handleLevelGain(from: oldLevel)
        hero.gainGold(rewards.gold)
        statistics.offlineXP += appliedXP
        statistics.offlineGold += rewards.gold
    }

    // MARK: - Save/Load

    func save() {
        let data = SaveData(
            hero: hero,
            party: party,
            runeTree: runeTree,
            cubeProgress: cubeProgress,
            purchasedInventoryExpansionCount: purchasedInventoryExpansionCount,
            activeSkillLoadouts: activeSkillLoadouts,
            inventory: inventory,
            progress: progress,
            statistics: statistics,
            autoOpenChestCooldowns: autoOpenChestCooldowns,
            autoEquipBestItems: autoEquipBestItems,
            worseEquipmentHandling: worseEquipmentHandling,
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
        purchasedInventoryExpansionCount = InventoryExpansion.normalizedCount(data.purchasedInventoryExpansionCount)
        activeSkillLoadouts = data.activeSkillLoadouts
        party.setPrimaryClass(hero.heroClass)
        inventory = data.inventory
        applyRuneTreeUnlocks()
        progress = data.progress
        statistics = data.statistics
        autoOpenChestCooldowns = data.autoOpenChestCooldowns
        autoEquipBestItems = data.autoEquipBestItems
        worseEquipmentHandling = data.worseEquipmentHandling
        soundEffectsEnabled = data.soundEffectsEnabled
        unyieldingWillConsumedStageKey = data.unyieldingWillConsumedStageKey
        needsSaveAfterStartupNormalization = enforceHeroLevelPacing() || needsSaveAfterStartupNormalization
        if autoEquipBestItems {
            equipBestItemsFromInventory()
        }
    }

    /// 删除存档并将内存中的游戏状态完整重置
    @discardableResult
    func resetGame() -> Bool {
        let didDeleteSave = saveManager.deleteSave()
        hero = Hero()
        runeTree = RuneTree()
        cubeProgress = CubeProgress()
        purchasedInventoryExpansionCount = 0
        activeSkillLoadouts = ActiveSkillLoadouts()
        party = HeroParty(primaryClass: hero.heroClass, unlockedSlotCount: runeTree.unlockedPartySlotCount)
        inventory = Inventory()
        progress = ProgressTracker()
        statistics = GameStatistics()
        autoOpenChestCooldowns = AutoOpenChestCooldowns()
        recentBattleLog.removeAll()
        autoEquipBestItems = false
        worseEquipmentHandling = .keep
        soundEffectsEnabled = true
        unyieldingWillConsumedStageKey = nil
        battleLockReason = nil
        ticksSinceLastSave = 0
        applyRuneTreeUnlocks()
        startNextBattle()
        save()
        return didDeleteSave
    }

    private func handleLevelGain(from oldLevel: Int) {
        let gainedLevels = hero.level - oldLevel
        guard gainedLevels > 0 else { return }
        applyRuneTreeUnlocks()
        audio.play(.levelUp)
    }

    @discardableResult
    private func grantHeroXP(_ amount: Int) -> Int {
        HeroLevelPacing.grantXP(amount, to: hero, maxLevel: HeroLevelPacing.maxHeroLevel(for: progress))
    }

    private func enforceHeroLevelPacing() -> Bool {
        hero.clampLevel(to: HeroLevelPacing.maxHeroLevel(for: progress))
    }

    private func saveAfterStartupNormalizationIfNeeded() {
        guard needsSaveAfterStartupNormalization else { return }
        needsSaveAfterStartupNormalization = false
        save()
    }

    private func applyRuneTreeUnlocks() {
        hero.runeAttackDamageBonus = runeTree.allHeroAttackDamage
        hero.runeAttackDamageMultiplier = runeTree.allHeroAttackDamageMultiplier
        hero.runeArmorBonus = runeTree.allHeroArmor
        hero.runeArmorMultiplier = runeTree.allHeroArmorMultiplier
        hero.runeMoveSpeedBonus = runeTree.allHeroMoveSpeed
        party.setUnlockedSlotCount(runeTree.unlockedPartySlotCount)
        inventory.setMaxCapacity(InventoryExpansion.maxCapacity(
            runeTree: runeTree,
            purchasedExpansionCount: purchasedInventoryExpansionCount
        ))
    }
}

#if DEBUG
extension GameEngine {
    func runSelfTestTick() {
        tick()
    }

    @discardableResult
    func runSelfTestAutoOpenCooldown(seconds: TimeInterval) -> Int {
        tickAutoOpenChests(deltaTime: seconds)
    }

    @discardableResult
    func retainLootForTesting(_ item: Item) -> Bool {
        retainLoot(item)
    }
}
#endif
