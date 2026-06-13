import Testing
@testable import TBH

@Suite struct HeroTests {
    @Test func levelUp() {
        let hero = Hero()
        let xpNeeded = hero.xpForNextLevel()
        hero.gainXP(xpNeeded)
        #expect(hero.level == 2, "Hero should level up")
    }

    @Test func takeDamage() {
        let hero = Hero()
        let initialHP = hero.currentHP
        hero.takeDamage(10)
        #expect(hero.currentHP == initialHP - 10)
    }

    @Test func deathCheck() {
        let hero = Hero()
        hero.takeDamage(hero.currentHP + 100)
        #expect(!hero.isAlive)
        #expect(hero.currentHP == 0)
    }

    @Test func respawn() {
        let hero = Hero()
        hero.takeDamage(hero.currentHP + 100)
        hero.respawn()
        #expect(hero.isAlive)
        #expect(hero.currentHP > 0)
    }
}
