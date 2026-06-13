import Foundation

/// 战斗结果
enum BattleResult {
    case victory(Rewards)
    case defeat

    struct Rewards {
        let xp: Int
        let gold: Int
        let lootItem: Item?
    }
}

/// 战斗系统 — 回合制自动战斗
class Battle: ObservableObject {
    @Published var heroHP: Int
    @Published var monsterHP: Int
    @Published var log: [BattleLogEntry] = []
    @Published var isOver: Bool = false
    @Published var result: BattleResult?

    let hero: Hero
    let monster: Monster

    private var heroCooldown: TimeInterval = 0
    private var monsterCooldown: TimeInterval = 0

    init(hero: Hero, monster: Monster) {
        self.hero = hero
        self.monster = monster
        self.heroHP = hero.currentHP
        self.monsterHP = monster.hp
    }

    /// 每 tick 调用
    func update(deltaTime: TimeInterval) {
        guard !isOver else { return }

        heroCooldown -= deltaTime
        monsterCooldown -= deltaTime

        // 英雄攻击
        if heroCooldown <= 0 {
            let hit = DamageCalculator.calculateResult(
                attackerATK: hero.attack,
                defenderDEF: monster.def,
                critRate: hero.critRate,
                critDamage: hero.critDamage
            )
            monsterHP = max(0, monsterHP - hit.amount)
            log.append(BattleLogEntry(attacker: .hero, damage: hit.amount, isCrit: hit.isCrit))
            heroCooldown = 1.0 / Double(hero.speed) * 10

            if monsterHP <= 0 {
                endBattle(victory: true)
                return
            }
        }

        // 怪物攻击
        if monsterCooldown <= 0 {
            let hit = DamageCalculator.calculateResult(
                attackerATK: monster.atk,
                defenderDEF: hero.defense,
                critRate: monster.critRate,
                critDamage: 1.5
            )
            hero.takeDamage(hit.amount)
            heroHP = hero.currentHP  // 单一事实来源：以英雄实际 HP 为准
            log.append(BattleLogEntry(attacker: .monster, damage: hit.amount, isCrit: hit.isCrit))
            monsterCooldown = 1.0 / Double(monster.spd) * 10

            if heroHP <= 0 {
                endBattle(victory: false)
                return
            }
        }
    }

    private func endBattle(victory: Bool) {
        isOver = true
        if victory {
            let loot = LootTable.roll(for: monster)
            result = .victory(BattleResult.Rewards(
                xp: monster.xpReward,
                gold: monster.goldReward,
                lootItem: loot
            ))
        } else {
            result = .defeat
        }
    }
}

struct BattleLogEntry: Identifiable {
    let id = UUID()
    let attacker: Battler
    let damage: Int
    let isCrit: Bool

    enum Battler {
        case hero, monster
    }
}
