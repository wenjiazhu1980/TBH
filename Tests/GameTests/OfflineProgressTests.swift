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

    @Test func offlineCap() {
        let hero = Hero()
        let rewards24h = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: 86400  // 24 小时
        )
        let rewards48h = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: 172800  // 48 小时
        )
        // 封顶 24 小时，收益应相等
        #expect(rewards24h.xp == rewards48h.xp)
        #expect(rewards24h.gold == rewards48h.gold)
    }
}
