import Foundation
import Combine
import AppKit

/// 游戏主引擎 — 管理游戏循环、状态更新和事件分发
class GameEngine: ObservableObject {
    @Published var hero: Hero
    @Published var currentBattle: Battle?
    @Published var inventory: Inventory
    @Published var progress: ProgressTracker
    @Published var statistics: GameStatistics

    private var tickTimer: Timer?
    private let tickInterval: TimeInterval = 1.0
    private let saveManager: SaveManager
    private var terminationObserver: NSObjectProtocol?

    /// 每 30 个 tick（约 30 秒）自动保存一次
    private let autosaveTicks = 30
    private var ticksSinceLastSave = 0

    init(saveManager: SaveManager = SaveManager()) {
        self.hero = Hero()
        self.inventory = Inventory()
        self.progress = ProgressTracker()
        self.statistics = GameStatistics()
        self.saveManager = saveManager
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
        let monster = progress.currentChapter.spawnMonster(difficulty: progress.currentDifficulty)
        currentBattle = Battle(hero: hero, monster: monster)
    }

    private func handleBattleResult(_ result: BattleResult?) {
        guard let result = result else { return }
        switch result {
        case .victory(let rewards):
            hero.gainXP(rewards.xp)
            hero.gainGold(rewards.gold)
            // 背包满时战利品丢失，统计只记实际入包的物品
            let lootStored = rewards.lootItem.map { inventory.add($0) } ?? false
            progress.advance()
            statistics.recordVictory(
                rewards: rewards,
                lootStored: lootStored,
                chapter: progress.currentChapter,
                difficulty: progress.currentDifficulty
            )

        case .defeat:
            statistics.recordDefeat()
            hero.respawn()
        }
    }

    // MARK: - Inventory

    /// 从背包装备物品；被替换下的旧装备放回背包，不会丢失
    func equipItem(_ item: Item) {
        guard item.slot != nil else { return }
        inventory.remove(item)
        if let old = hero.equipment.equip(item) {
            inventory.add(old)
        }
    }

    // MARK: - Offline Progress

    private func calculateOfflineProgress() {
        guard let lastSave = saveManager.lastSaveTimestamp else { return }
        let offlineSeconds = Date().timeIntervalSince(lastSave)
        guard offlineSeconds > 60 else { return }

        let rewards = OfflineProgress.calculate(
            hero: hero,
            chapter: progress.currentChapter,
            difficulty: progress.currentDifficulty,
            offlineSeconds: offlineSeconds
        )

        hero.gainXP(rewards.xp)
        hero.gainGold(rewards.gold)
        statistics.offlineXP += rewards.xp
        statistics.offlineGold += rewards.gold
    }

    // MARK: - Save/Load

    func save() {
        let data = SaveData(
            hero: hero,
            inventory: inventory,
            progress: progress,
            statistics: statistics,
            timestamp: Date()
        )
        saveManager.save(data)
    }

    private func loadSave() {
        guard let data = saveManager.load() else { return }
        hero = data.hero
        inventory = data.inventory
        progress = data.progress
        statistics = data.statistics
    }

    /// 删除存档并将内存中的游戏状态完整重置
    func resetGame() {
        saveManager.deleteSave()
        hero = Hero()
        inventory = Inventory()
        progress = ProgressTracker()
        statistics = GameStatistics()
        ticksSinceLastSave = 0
        startNextBattle()
    }
}
