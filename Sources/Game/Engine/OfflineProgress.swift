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
    static let maxOfflineSeconds: TimeInterval = 8 * 60 * 60

    static func calculate(
        hero: Hero,
        chapter: Chapter,
        difficulty: Difficulty,
        offlineSeconds: TimeInterval,
        offlineGoldMultiplier: Double = 1.0,
        offlineXPMultiplier: Double = 1.0
    ) -> Rewards {
        calculate(
            hero: hero,
            stage: StageDefinition.stage(act: chapter, number: 1),
            difficulty: difficulty,
            offlineSeconds: offlineSeconds,
            offlineGoldMultiplier: offlineGoldMultiplier,
            offlineXPMultiplier: offlineXPMultiplier
        )
    }

    static func calculate(
        hero: Hero,
        stage: StageDefinition,
        difficulty: Difficulty,
        offlineSeconds: TimeInterval,
        offlineGoldMultiplier: Double = 1.0,
        offlineXPMultiplier: Double = 1.0
    ) -> Rewards {
        let baseGoldPerSecond = Double(stage.baseGoldPerClear(for: difficulty)) / stage.avgClearTime(for: difficulty)
        let baseXPPerSecond = Double(stage.baseXPPerClear(for: difficulty)) / stage.avgClearTime(for: difficulty)

        // 原版离线收益上限为 8 小时，且只给金币与经验。
        let cappedSeconds = min(offlineSeconds, maxOfflineSeconds)

        let xp = Int(baseXPPerSecond * cappedSeconds * xpMultiplier * offlineXPMultiplier)
        let gold = Int(baseGoldPerSecond * cappedSeconds * goldMultiplier * offlineGoldMultiplier)

        return Rewards(xp: xp, gold: gold)
    }
}
