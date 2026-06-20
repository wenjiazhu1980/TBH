import Foundation

/// 英雄职业
enum HeroClass: String, CaseIterable, Codable {
    case knight = "骑士"
    case ranger = "游侠"
    case sorcerer = "法师"
    case priest = "牧师"
    case hunter = "猎人"
    case slayer = "杀手"

    var baseStats: BaseStats {
        switch self {
        case .knight:
            return BaseStats(hp: 130, atk: 18, def: 45, spd: 9, critRate: 0.025, critDamage: 1.4)
        case .ranger:
            return BaseStats(hp: 60, atk: 10, def: 8, spd: 10, critRate: 0.04, critDamage: 1.5)
        case .sorcerer:
            return BaseStats(hp: 50, atk: 11, def: 5, spd: 6, critRate: 0.05, critDamage: 1.65)
        case .priest:
            return BaseStats(hp: 95, atk: 9, def: 30, spd: 9, critRate: 0.02, critDamage: 1.4)
        case .hunter:
            return BaseStats(hp: 70, atk: 14, def: 15, spd: 7, critRate: 0.045, critDamage: 1.55)
        case .slayer:
            return BaseStats(hp: 115, atk: 14, def: 40, spd: 7, critRate: 0.025, critDamage: 1.8)
        }
    }

    var role: String {
        switch self {
        case .knight: return "坦克 / 前排"
        case .ranger: return "远程物理 DPS"
        case .sorcerer: return "范围元素 DPS"
        case .priest: return "治疗 / 增益"
        case .hunter: return "陷阱 / 远程 DPS"
        case .slayer: return "近战爆发 / 吸血"
        }
    }

    var grade: String {
        switch self {
        case .knight, .priest, .hunter: return "S"
        case .sorcerer, .slayer: return "A"
        case .ranger: return "B"
        }
    }

    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        switch rawValue {
        case Self.knight.rawValue, "战士", "warrior", "Warrior", "knight", "Knight":
            self = .knight
        case Self.ranger.rawValue, "ranger", "Ranger":
            self = .ranger
        case Self.sorcerer.rawValue, "sorcerer", "Sorcerer", "法师":
            self = .sorcerer
        case Self.priest.rawValue, "priest", "Priest":
            self = .priest
        case Self.hunter.rawValue, "hunter", "Hunter":
            self = .hunter
        case Self.slayer.rawValue, "slayer", "Slayer", "屠戮者":
            self = .slayer
        default:
            self = .knight
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
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
    @Published var heroClass: HeroClass = .knight
    @Published var level: Int = 1
    @Published var currentXP: Int = 0
    @Published var gold: Int = 0
    @Published var currentHP: Int = 100
    @Published var equipment: EquipmentLoadout = EquipmentLoadout()
    @Published var unlockedPassiveSkillIDs: Set<String> = []
    @Published var runeAttackDamageBonus: Int = 0
    @Published var runeAttackDamageMultiplier: Double = 1.0
    @Published var runeArmorBonus: Int = 0
    @Published var runeArmorMultiplier: Double = 1.0
    @Published var runeMoveSpeedBonus: Int = 0

    var isAlive: Bool { currentHP > 0 }

    var baseStats: BaseStats { heroClass.baseStats }

    var passiveRuntimeEffects: PassiveSkillRuntimeEffects {
        PassiveSkillRuntimeEffects.make(unlockedSkillIDs: unlockedPassiveSkillIDs, heroClass: heroClass)
    }

    var maxHP: Int {
        let baseValue = baseStats.hp + max(level - 1, 0) * 10 + equipment.bonusHP + passiveRuntimeEffects.passiveMaxHp
        return max(1, Int(ceil(Double(baseValue) * passiveRuntimeEffects.passiveMaxHpMultiplier)))
    }

    var attack: Int {
        let baseValue = baseStats.atk + max(level - 1, 0) * 2 + equipment.bonusATK + passiveRuntimeEffects.passiveAttackDamage + runeAttackDamageBonus
        return max(1, Int(ceil(Double(baseValue) * passiveRuntimeEffects.passiveAttackDamageMultiplier * runeAttackDamageMultiplier)))
    }

    var defense: Int {
        let baseValue = baseStats.def + max(level - 1, 0) + equipment.bonusDEF + passiveRuntimeEffects.passiveArmor + runeArmorBonus
        return max(0, Int(ceil(Double(baseValue) * runeArmorMultiplier)))
    }

    var speed: Int {
        let effects = passiveRuntimeEffects
        let baseValue = baseStats.spd + equipment.bonusSPD + effects.passiveMovementSpeed + runeMoveSpeedBonus
        return max(1, Int(ceil(Double(baseValue) * effects.passiveAttackSpeedMultiplier * effects.passiveMovementSpeedMultiplier)))
    }

    var critRate: Double {
        min(max(baseStats.critRate + equipment.bonusCritRate + passiveRuntimeEffects.passiveCriticalChance, 0), 1.0)
    }

    var critDamage: Double {
        max(1.0, baseStats.critDamage + equipment.bonusCritDamage + passiveRuntimeEffects.passiveCriticalDamage)
    }

    static func xpForNextLevel(at level: Int) -> Int {
        Int(pow(Double(max(level, 1)), 1.5) * 100)
    }

    func xpForNextLevel() -> Int {
        Self.xpForNextLevel(at: level)
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

    @discardableResult
    func heal(_ amount: Int) -> Int {
        guard currentHP < maxHP else { return 0 }
        let oldHP = currentHP
        currentHP = min(maxHP, currentHP + max(0, amount))
        return currentHP - oldHP
    }

    @discardableResult
    func revive(withHP amount: Int) -> Int {
        let oldHP = currentHP
        currentHP = max(1, amount)
        return currentHP - oldHP
    }

    func respawn() {
        currentHP = maxHP / 2
    }

    func changeClass(to newClass: HeroClass) {
        guard newClass != heroClass else { return }
        let wasAtFullHealth = currentHP >= maxHP
        heroClass = newClass
        currentHP = wasAtFullHealth ? maxHP : min(currentHP, maxHP)
    }

    @discardableResult
    func clampLevel(to maxLevel: Int) -> Bool {
        let oldLevel = level
        let oldXP = currentXP
        let oldHP = currentHP
        let cappedLevel = max(1, maxLevel)
        level = min(max(level, 1), cappedLevel)
        currentXP = min(max(currentXP, 0), max(0, xpForNextLevel() - 1))
        if currentHP > 0 {
            currentHP = min(currentHP, maxHP)
        }
        return oldLevel != level || oldXP != currentXP || oldHP != currentHP
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case name, heroClass, level, currentXP, gold, currentHP, equipment, unlockedPassiveSkillIDs
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
        _unlockedPassiveSkillIDs = Published(initialValue: try c.decodeIfPresent(Set<String>.self, forKey: .unlockedPassiveSkillIDs) ?? [])
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
        try c.encode(unlockedPassiveSkillIDs, forKey: .unlockedPassiveSkillIDs)
    }

    init() {
        _currentHP = Published(initialValue: heroClass.baseStats.hp)
    }
}

struct HeroLevelCapBreakdown: Equatable {
    let stageLevel: Int
    let stageLevelBuffer: Int
    let completedPlaythroughCycles: Int
    let playthroughBonusPerCycle: Int

    var playthroughBonus: Int {
        completedPlaythroughCycles * playthroughBonusPerCycle
    }

    var maxLevel: Int {
        max(1, stageLevel + stageLevelBuffer + playthroughBonus)
    }

    var formulaText: String {
        "Lv.\(stageLevel) + \(stageLevelBuffer) + \(playthroughBonus) = Lv.\(maxLevel)"
    }
}

struct HeroLevelCapStatus: Equatable {
    let heroLevel: Int
    let currentXP: Int
    let breakdown: HeroLevelCapBreakdown

    var maxLevel: Int {
        breakdown.maxLevel
    }

    var maxCurrentXP: Int {
        max(0, Hero.xpForNextLevel(at: maxLevel) - 1)
    }

    var needsNormalization: Bool {
        heroLevel < 1 || heroLevel > maxLevel || currentXP < 0 || currentXP > maxCurrentXP
    }

    var isAtLevelCap: Bool {
        !needsNormalization && heroLevel >= maxLevel
    }

    var canLevelUp: Bool {
        !needsNormalization && heroLevel < maxLevel
    }

    var nextLevelXPRemaining: Int {
        guard canLevelUp else { return 0 }
        return max(0, Hero.xpForNextLevel(at: heroLevel) - currentXP)
    }

    var levelText: String {
        "Lv.\(heroLevel)/\(maxLevel)"
    }

    var statusText: String {
        if needsNormalization {
            return "需修正"
        }
        return isAtLevelCap ? "已达上限" : "可升级"
    }

    var xpSpaceText: String {
        if needsNormalization {
            return "修正后重算"
        }
        return isAtLevelCap ? "升级停止" : "下级 \(nextLevelXPRemaining) XP"
    }
}

enum HeroLevelPacing {
    static let stageLevelBuffer = GamePacing.stageLevelBuffer
    static let playthroughLevelBonus = GamePacing.playthroughLevelBonus

    static func levelCapBreakdown(for progress: ProgressTracker) -> HeroLevelCapBreakdown {
        let stageLevel = progress.currentStage
            .runtimeData(for: progress.currentDifficulty)
            .level
        let completedPlaythroughCycles = NewGamePlusTuning.completedCycles(before: progress.playthrough)
        return HeroLevelCapBreakdown(
            stageLevel: stageLevel,
            stageLevelBuffer: stageLevelBuffer,
            completedPlaythroughCycles: completedPlaythroughCycles,
            playthroughBonusPerCycle: playthroughLevelBonus
        )
    }

    static func maxHeroLevel(for progress: ProgressTracker) -> Int {
        levelCapBreakdown(for: progress).maxLevel
    }

    static func levelCapStatus(for hero: Hero, progress: ProgressTracker) -> HeroLevelCapStatus {
        HeroLevelCapStatus(
            heroLevel: hero.level,
            currentXP: hero.currentXP,
            breakdown: levelCapBreakdown(for: progress)
        )
    }

    @discardableResult
    static func grantXP(_ amount: Int, to hero: Hero, maxLevel: Int) -> Int {
        let grantableXP = previewGrantedXP(amount, for: hero, maxLevel: maxLevel)
        guard grantableXP > 0 else {
            hero.clampLevel(to: maxLevel)
            return 0
        }

        hero.gainXP(grantableXP)
        hero.clampLevel(to: maxLevel)
        return grantableXP
    }

    static func previewGrantedXP(_ amount: Int, for hero: Hero, maxLevel: Int) -> Int {
        let requestedXP = GamePacing.pacedXP(from: amount)
        return min(requestedXP, maxGrantableXP(for: hero, maxLevel: maxLevel))
    }

    private static func maxGrantableXP(for hero: Hero, maxLevel: Int) -> Int {
        let cappedLevel = max(1, maxLevel)
        guard hero.level <= cappedLevel else { return 0 }

        if hero.level == cappedLevel {
            return max(0, hero.xpForNextLevel() - 1 - hero.currentXP)
        }

        var grantableXP = 0
        var simulatedLevel = hero.level
        var simulatedXP = hero.currentXP
        while simulatedLevel < cappedLevel {
            grantableXP += max(0, Hero.xpForNextLevel(at: simulatedLevel) - simulatedXP)
            simulatedLevel += 1
            simulatedXP = 0
        }
        grantableXP += max(0, Hero.xpForNextLevel(at: cappedLevel) - 1)

        return max(0, grantableXP)
    }
}
