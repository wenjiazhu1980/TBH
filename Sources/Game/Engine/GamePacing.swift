import Foundation

enum GamePacing {
    static let runtimeTickInterval: TimeInterval = 1.0
    static let combatSimulationStep: TimeInterval = 1.0
    static let combatDeltaMultiplier = 1.0
    static let appliedXPMultiplier = 0.35
    static let stageLevelBuffer = 2
    static let playthroughLevelBonus = 15
    static let minimumAttackInterval: TimeInterval = 1.0
    static let minimumHastedAttackInterval: TimeInterval = 1.0

    static func pacedXP(from amount: Int) -> Int {
        guard amount > 0 else { return 0 }
        return max(1, Int(Double(amount) * appliedXPMultiplier))
    }

    static func simulatedCombatDelta(for wallClockDelta: TimeInterval) -> TimeInterval {
        max(0, wallClockDelta) * combatDeltaMultiplier
    }

    static func attackInterval(baseInterval: TimeInterval, attackSpeedMultiplier: Double) -> TimeInterval {
        let normalizedMultiplier = max(0.1, attackSpeedMultiplier)
        let adjustedInterval = baseInterval / normalizedMultiplier
        let localMinimum = normalizedMultiplier > 1.0 ? minimumHastedAttackInterval : minimumAttackInterval
        return max(localMinimum, adjustedInterval)
    }
}
