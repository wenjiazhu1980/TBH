import Foundation

/// 单次伤害结算结果
struct DamageResult {
    let amount: Int
    let isCrit: Bool
}

/// 伤害计算公式
struct DamageCalculator {
    /// 基础伤害 = ATK * (100 / (100 + DEF))，带暴击与 ±10% 随机波动
    static func calculateResult(
        attackerATK: Int,
        defenderDEF: Int,
        critRate: Double,
        critDamage: Double
    ) -> DamageResult {
        let baseDamage = Double(attackerATK) * (100.0 / (100.0 + Double(defenderDEF)))
        let isCrit = Double.random(in: 0..<1) < critRate
        let finalDamage = isCrit ? baseDamage * critDamage : baseDamage

        let variance = Double.random(in: 0.9...1.1)
        return DamageResult(amount: max(1, Int(finalDamage * variance)), isCrit: isCrit)
    }

    /// 便捷入口 — 只关心伤害数值时使用
    static func calculate(
        attackerATK: Int,
        defenderDEF: Int,
        critRate: Double,
        critDamage: Double
    ) -> Int {
        calculateResult(
            attackerATK: attackerATK,
            defenderDEF: defenderDEF,
            critRate: critRate,
            critDamage: critDamage
        ).amount
    }
}
