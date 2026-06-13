import Foundation

/// 离线收益计算
struct OfflineProgress {
    struct Rewards {
        let xp: Int
        let gold: Int
    }

    /// 离线效率系数 — 防止挂机过于轻松
    private static let xpMultiplier: Double = 0.3
    private static let goldMultiplier: Double = 0.5

    static func calculate(
        hero: Hero,
        chapter: Chapter,
        difficulty: Difficulty,
        offlineSeconds: TimeInterval
    ) -> Rewards {
        let baseGoldPerSecond = Double(chapter.baseGoldPerKill) * difficulty.goldMultiplier / chapter.avgKillTime
        let baseXPPerSecond = Double(chapter.baseXPPerKill) * difficulty.xpMultiplier / chapter.avgKillTime

        // 封顶 24 小时，防止极端情况
        let cappedSeconds = min(offlineSeconds, 86400)

        let xp = Int(baseXPPerSecond * cappedSeconds * xpMultiplier)
        let gold = Int(baseGoldPerSecond * cappedSeconds * goldMultiplier)

        return Rewards(xp: xp, gold: gold)
    }
}
