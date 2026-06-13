import Testing
@testable import TBH

@Suite struct DamageCalculatorTests {
    @Test func basicDamage() {
        let damage = DamageCalculator.calculate(
            attackerATK: 100,
            defenderDEF: 0,
            critRate: 0,
            critDamage: 1.5
        )
        // DEF=0 时，100 * (100/100) = 100，±10% 波动
        #expect(damage >= 90 && damage <= 110, "Damage \(damage) out of expected range")
    }

    @Test func defenseReduction() {
        let damage = DamageCalculator.calculate(
            attackerATK: 100,
            defenderDEF: 100,
            critRate: 0,
            critDamage: 1.5
        )
        // DEF=100 时，100 * (100/200) = 50，±10%
        #expect(damage >= 45 && damage <= 55, "Damage \(damage) out of expected range")
    }

    @Test func minimumDamage() {
        let damage = DamageCalculator.calculate(
            attackerATK: 1,
            defenderDEF: 9999,
            critRate: 0,
            critDamage: 1.5
        )
        #expect(damage >= 1, "Minimum damage should be 1")
    }
}
