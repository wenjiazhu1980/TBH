import Testing
@testable import TBH

@Suite struct OfflineProgressTests {
    @Test func offlineRewards() {
        let hero = Hero()
        let rewards = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: 3600  // 1 小时
        )
        #expect(rewards.xp > 0, "Should earn XP offline")
        #expect(rewards.gold > 0, "Should earn gold offline")
    }

    @Test func offlineBoostMultipliersApplyIndependently() {
        let hero = Hero()
        let base = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: 3600
        )
        let goldBoosted = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: 3600,
            offlineGoldMultiplier: 1.10
        )
        let xpBoosted = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: 3600,
            offlineXPMultiplier: 1.10
        )

        #expect(goldBoosted.gold > base.gold)
        #expect(goldBoosted.xp == base.xp)
        #expect(xpBoosted.xp > base.xp)
        #expect(xpBoosted.gold == base.gold)
    }

    @Test func offlineCapIsEightHours() {
        let hero = Hero()
        let rewards8h = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: OfflineProgress.maxOfflineSeconds
        )
        let rewards24h = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: 86_400  // 24 小时
        )
        // 原版封顶 8 小时，超过后收益应相等
        #expect(rewards8h.xp == rewards24h.xp)
        #expect(rewards8h.gold == rewards24h.gold)
    }
}
