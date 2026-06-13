import Foundation

/// 英雄职业
enum HeroClass: String, Codable, CaseIterable {
    case warrior = "战士"

    var baseStats: BaseStats {
        switch self {
        case .warrior:
            return BaseStats(hp: 100, atk: 15, def: 10, spd: 8, critRate: 0.05, critDamage: 1.5)
        }
    }
}

struct BaseStats: Codable {
    let hp: Int
    let atk: Int
    let def: Int
    let spd: Int
    let critRate: Double
    let critDamage: Double
}

/// 英雄
class Hero: ObservableObject, Codable {
    @Published var name: String = "无名英雄"
    @Published var heroClass: HeroClass = .warrior
    @Published var level: Int = 1
    @Published var currentXP: Int = 0
    @Published var gold: Int = 0
    @Published var currentHP: Int = 100
    @Published var equipment: EquipmentLoadout = EquipmentLoadout()

    var isAlive: Bool { currentHP > 0 }

    var baseStats: BaseStats { heroClass.baseStats }

    var maxHP: Int {
        baseStats.hp + level * 10 + equipment.bonusHP
    }

    var attack: Int {
        baseStats.atk + level * 2 + equipment.bonusATK
    }

    var defense: Int {
        baseStats.def + level * 1 + equipment.bonusDEF
    }

    var speed: Int {
        baseStats.spd + equipment.bonusSPD
    }

    var critRate: Double {
        min(baseStats.critRate + equipment.bonusCritRate, 1.0)
    }

    var critDamage: Double {
        baseStats.critDamage + equipment.bonusCritDamage
    }

    func xpForNextLevel() -> Int {
        return Int(pow(Double(level), 1.5) * 100)
    }

    func gainXP(_ amount: Int) {
        currentXP += amount
        while currentXP >= xpForNextLevel() {
            currentXP -= xpForNextLevel()
            level += 1
            currentHP = maxHP
        }
    }

    func gainGold(_ amount: Int) {
        gold += amount
    }

    func takeDamage(_ amount: Int) {
        currentHP = max(0, currentHP - amount)
    }

    func respawn() {
        currentHP = maxHP / 2
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case name, heroClass, level, currentXP, gold, currentHP, equipment
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        _name = Published(initialValue: try c.decode(String.self, forKey: .name))
        _heroClass = Published(initialValue: try c.decode(HeroClass.self, forKey: .heroClass))
        _level = Published(initialValue: try c.decode(Int.self, forKey: .level))
        _currentXP = Published(initialValue: try c.decode(Int.self, forKey: .currentXP))
        _gold = Published(initialValue: try c.decode(Int.self, forKey: .gold))
        _currentHP = Published(initialValue: try c.decode(Int.self, forKey: .currentHP))
        _equipment = Published(initialValue: try c.decode(EquipmentLoadout.self, forKey: .equipment))
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(heroClass, forKey: .heroClass)
        try c.encode(level, forKey: .level)
        try c.encode(currentXP, forKey: .currentXP)
        try c.encode(gold, forKey: .gold)
        try c.encode(currentHP, forKey: .currentHP)
        try c.encode(equipment, forKey: .equipment)
    }

    init() {
        _currentHP = Published(initialValue: heroClass.baseStats.hp)
    }
}
