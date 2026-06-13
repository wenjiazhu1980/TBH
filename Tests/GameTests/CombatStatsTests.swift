import Testing
@testable import TBH

@Suite struct DamageResultTests {
    @Test func guaranteedCritIsFlagged() {
        let result = DamageCalculator.calculateResult(
            attackerATK: 100,
            defenderDEF: 0,
            critRate: 1.0,
            critDamage: 2.0
        )
        #expect(result.isCrit, "critRate=1 must always crit")
        // 100 * 2.0 = 200，±10% 波动
        #expect(result.amount >= 180 && result.amount <= 220, "Crit damage \(result.amount) out of range")
    }

    @Test func zeroCritRateNeverCrits() {
        let result = DamageCalculator.calculateResult(
            attackerATK: 100,
            defenderDEF: 0,
            critRate: 0,
            critDamage: 2.0
        )
        #expect(!result.isCrit, "critRate=0 must never crit")
        #expect(result.amount >= 90 && result.amount <= 110)
    }
}

@Suite struct GameStatisticsTests {
    @Test func recordVictoryAccumulates() {
        var stats = GameStatistics()
        let rewards = BattleResult.Rewards(xp: 10, gold: 25, lootItem: nil)
        stats.recordVictory(rewards: rewards, lootStored: false, chapter: .dungeon, difficulty: .hard)
        #expect(stats.monstersKilled == 1)
        #expect(stats.totalGoldEarned == 25)
        #expect(stats.highestChapter == Chapter.dungeon.rawValue)
        #expect(stats.highestDifficulty == Difficulty.hard.rawValue)
        #expect(stats.itemsFound == 0, "No loot means no item count")
    }

    @Test func recordVictoryCountsOnlyStoredLoot() {
        var stats = GameStatistics()
        let item = Item(id: "i1", name: "测试", rarity: .common, slot: .weapon, stats: ItemStats(), description: "")
        let rewards = BattleResult.Rewards(xp: 1, gold: 1, lootItem: item)
        stats.recordVictory(rewards: rewards, lootStored: true, chapter: .forest, difficulty: .normal)
        #expect(stats.itemsFound == 1)
        // 背包满导致物品未入包 → 不计数
        stats.recordVictory(rewards: rewards, lootStored: false, chapter: .forest, difficulty: .normal)
        #expect(stats.itemsFound == 1, "Loot lost to a full inventory must not count")
    }

    @Test func highWaterMarksNeverDecrease() {
        var stats = GameStatistics()
        let rewards = BattleResult.Rewards(xp: 1, gold: 1, lootItem: nil)
        stats.recordVictory(rewards: rewards, lootStored: false, chapter: .volcano, difficulty: .hell)
        stats.recordVictory(rewards: rewards, lootStored: false, chapter: .forest, difficulty: .normal)
        #expect(stats.highestChapter == Chapter.volcano.rawValue)
        #expect(stats.highestDifficulty == Difficulty.hell.rawValue)
    }

    @Test func recordDefeatCountsDeath() {
        var stats = GameStatistics()
        stats.recordDefeat()
        #expect(stats.deaths == 1)
    }
}
