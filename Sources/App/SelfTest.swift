import Foundation

#if DEBUG
/// 本地自检 — 在缺少 XCTest/swift-testing 的 CLT 环境下提供最小测试反馈。
/// 完整测试套件位于 Tests/GameTests（swift-testing，在带完整 Xcode 的环境/CI 上运行）。
/// 用法：swift run TBH --self-test
enum SelfTest {
    private static var failures: [String] = []

    private static func expect(
        _ condition: Bool,
        _ message: String,
        file: String = #fileID,
        line: UInt = #line
    ) {
        if condition {
            print("  ✓ \(message)")
        } else {
            failures.append("\(file):\(line) \(message)")
            print("  ✗ \(message)")
        }
    }

    static func runAll() -> Never {
        print("=== TBH Self Test ===")

        damageCalculator()
        progressTracker()
        gameStatistics()
        itemContract()
        inventoryCapacity()
        gameEngineEquip()
        saveRoundTrip()

        if failures.isEmpty {
            print("=== ALL PASSED ===")
            exit(0)
        } else {
            print("=== \(failures.count) FAILURE(S) ===")
            failures.forEach { print("  FAIL: \($0)") }
            exit(1)
        }
    }

    // MARK: - Suites

    private static func damageCalculator() {
        print("[DamageCalculator]")
        let crit = DamageCalculator.calculateResult(attackerATK: 100, defenderDEF: 0, critRate: 1.0, critDamage: 2.0)
        expect(crit.isCrit, "critRate=1 always crits")
        expect(crit.amount >= 180 && crit.amount <= 220, "crit damage in ±10% range, got \(crit.amount)")

        let normal = DamageCalculator.calculateResult(attackerATK: 100, defenderDEF: 0, critRate: 0, critDamage: 2.0)
        expect(!normal.isCrit, "critRate=0 never crits")
        expect(normal.amount >= 90 && normal.amount <= 110, "normal damage in ±10% range, got \(normal.amount)")

        let floor = DamageCalculator.calculate(attackerATK: 1, defenderDEF: 9999, critRate: 0, critDamage: 1.5)
        expect(floor >= 1, "minimum damage is 1")
    }

    private static func progressTracker() {
        print("[ProgressTracker]")
        var tracker = ProgressTracker()
        tracker.advance()
        expect(tracker.killsInChapter == 1 && tracker.currentChapter == .forest, "single kill does not advance chapter")

        tracker = ProgressTracker()
        for _ in 0..<ProgressTracker.killsToAdvance { tracker.advance() }
        expect(tracker.currentChapter == .dungeon, "chapter advances after \(ProgressTracker.killsToAdvance) kills")
        expect(tracker.killsInChapter == 0, "kill counter resets on advance")
        expect(tracker.chaptersCleared.contains(Chapter.forest.rawValue), "cleared chapter recorded")

        tracker = ProgressTracker()
        for _ in 0..<(ProgressTracker.killsToAdvance * Chapter.allCases.count) { tracker.advance() }
        expect(tracker.currentDifficulty == .hard && tracker.currentChapter == .forest, "difficulty advances after all chapters")

        tracker = ProgressTracker()
        let totalKills = ProgressTracker.killsToAdvance * Chapter.allCases.count * Difficulty.allCases.count * 2
        for _ in 0..<totalKills { tracker.advance() }
        expect(tracker.currentDifficulty == .hell && tracker.currentChapter == .volcano, "progress caps at hell/volcano")

        let legacyJSON = #"{"currentChapterIndex":1,"currentDifficultyIndex":0,"chaptersCleared":[1]}"#
        let decoded = try? JSONDecoder().decode(ProgressTracker.self, from: Data(legacyJSON.utf8))
        expect(decoded?.currentChapter == .dungeon && decoded?.killsInChapter == 0, "legacy save without killsInChapter decodes")
    }

    private static func gameStatistics() {
        print("[GameStatistics]")
        var stats = GameStatistics()
        stats.recordVictory(rewards: BattleResult.Rewards(xp: 10, gold: 25, lootItem: nil), lootStored: false, chapter: .dungeon, difficulty: .hard)
        expect(stats.monstersKilled == 1 && stats.totalGoldEarned == 25, "victory accumulates kills and gold")
        expect(stats.highestChapter == Chapter.dungeon.rawValue && stats.highestDifficulty == Difficulty.hard.rawValue, "high-water marks recorded")

        stats.recordVictory(rewards: BattleResult.Rewards(xp: 1, gold: 1, lootItem: nil), lootStored: false, chapter: .forest, difficulty: .normal)
        expect(stats.highestChapter == Chapter.dungeon.rawValue, "high-water marks never decrease")

        let item = Item(id: "i1", name: "测试", rarity: .common, slot: .weapon, stats: ItemStats(), description: "")
        let lootRewards = BattleResult.Rewards(xp: 1, gold: 1, lootItem: item)
        stats.recordVictory(rewards: lootRewards, lootStored: true, chapter: .forest, difficulty: .normal)
        stats.recordVictory(rewards: lootRewards, lootStored: false, chapter: .forest, difficulty: .normal)
        expect(stats.itemsFound == 1, "only loot actually stored counts")

        stats.recordDefeat()
        expect(stats.deaths == 1, "defeat counts a death")
    }

    private static func itemContract() {
        print("[Item Hashable contract]")
        let a = Item(id: "same", name: "甲", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 1), description: "x")
        let b = Item(id: "same", name: "乙", rarity: .rare, slot: .armor, stats: ItemStats(bonusDEF: 9), description: "y")
        expect(a == b && a.hashValue == b.hashValue, "equal items have equal hashes")
        var set: Set<Item> = [a]
        set.insert(b)
        expect(set.count == 1 && set.contains(b), "Set treats equal-id items as one member")
    }

    private static func inventoryCapacity() {
        print("[Inventory]")
        let inventory = Inventory()
        var allAdded = true
        for i in 0..<inventory.maxCapacity {
            if !inventory.add(Item(id: "i\(i)", name: "x", rarity: .common, slot: nil, stats: ItemStats(), description: "")) {
                allAdded = false
            }
        }
        expect(allAdded, "adding within capacity succeeds")
        let overflow = inventory.add(Item(id: "of", name: "x", rarity: .common, slot: nil, stats: ItemStats(), description: ""))
        expect(!overflow && inventory.items.count == inventory.maxCapacity, "adding to full inventory fails")
    }

    private static func gameEngineEquip() {
        print("[GameEngine equip/reset]")
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHSelfTest-\(UUID().uuidString)", isDirectory: true)
        let engine = GameEngine(saveManager: SaveManager(directory: tempDir))

        let sword1 = Item(id: "s1", name: "铁剑", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 5), description: "")
        let sword2 = Item(id: "s2", name: "钢剑", rarity: .rare, slot: .weapon, stats: ItemStats(bonusATK: 10), description: "")
        engine.inventory.add(sword1)
        engine.inventory.add(sword2)

        engine.equipItem(sword1)
        expect(engine.hero.equipment.weapon?.id == "s1" && engine.inventory.items.count == 1, "equip removes item from inventory")

        engine.equipItem(sword2)
        expect(engine.hero.equipment.weapon?.id == "s2", "new weapon equipped")
        expect(engine.inventory.items.map(\.id) == ["s1"], "old weapon returns to inventory")

        let junk = Item(id: "j1", name: "杂物", rarity: .common, slot: nil, stats: ItemStats(), description: "")
        engine.inventory.add(junk)
        engine.equipItem(junk)
        expect(engine.inventory.items.count == 2, "non-equippable equip is a no-op")

        engine.hero.gainGold(999)
        engine.resetGame()
        expect(engine.hero.gold == 0 && engine.hero.level == 1 && engine.inventory.items.isEmpty, "resetGame clears state")
    }

    private static func saveRoundTrip() {
        print("[SaveManager]")
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHSelfTest-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)
        let hero = Hero()
        hero.gainGold(123)
        manager.save(SaveData(hero: hero, inventory: Inventory(), progress: ProgressTracker(), statistics: GameStatistics(), timestamp: Date()))
        let loaded = manager.load()
        expect(loaded?.hero.gold == 123, "save/load round trip preserves data")
    }
}
#endif
