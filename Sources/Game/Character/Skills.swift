import Foundation

enum SkillActivation: String, Codable, CaseIterable {
    case cooldown = "COOLDOWN"
    case baseAttack = "BASEATTACK"
    case baseAttackCount = "BASEATTACK_COUNT"
    case continuous = "CONTINUOUS"
}

enum SkillDamageElement: String, Codable, CaseIterable {
    case none
    case physical
    case fire
    case cold
    case lightning
    case chaos

    var isElemental: Bool {
        switch self {
        case .fire, .cold, .lightning:
            return true
        case .none, .physical, .chaos:
            return false
        }
    }

    var battleLogLabel: String? {
        switch self {
        case .none:
            return nil
        case .physical:
            return "物理"
        case .fire:
            return "火"
        case .cold:
            return "冰"
        case .lightning:
            return "电"
        case .chaos:
            return "混沌"
        }
    }
}

enum SkillDelivery: String, Codable, CaseIterable {
    case none
    case melee
    case meleeAOE
    case projectile
    case projectileAOE
    case range
    case rangeAOE
    case summonProjectile
    case trap
    case buff
    case heal
    case resurrection
}

/// 技能定义（MVP 简化版）
struct Skill: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let cooldown: TimeInterval
    let damageMultiplier: Double
    let unlockLevel: Int
    let activation: SkillActivation
    let triggerEvery: Int
    let levelValues: [Int]
    let damageElement: SkillDamageElement
    let delivery: SkillDelivery

    var levelOneValue: Int {
        value(at: 1)
    }

    var sourceSkill: SourceSkill? {
        SourceSkillCatalog.skill(id: id)
    }

    var sourceRange: Int? {
        sourceSkill?.range
    }

    init(
        id: String,
        name: String,
        description: String,
        cooldown: TimeInterval,
        damageMultiplier: Double,
        unlockLevel: Int,
        activation: SkillActivation = .cooldown,
        triggerEvery: Int = 0,
        levelValues: [Int] = [],
        damageElement: SkillDamageElement = .none,
        delivery: SkillDelivery = .none
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.cooldown = cooldown
        self.damageMultiplier = damageMultiplier
        self.unlockLevel = unlockLevel
        self.activation = activation
        self.triggerEvery = triggerEvery > 0 ? triggerEvery : (activation == .baseAttackCount ? 3 : 0)
        self.levelValues = levelValues
        self.damageElement = damageElement
        self.delivery = delivery
    }

    func value(at skillLevel: Int) -> Int {
        guard !levelValues.isEmpty else { return 0 }
        let index = min(max(skillLevel, 1), levelValues.count) - 1
        return levelValues[index]
    }
}

struct ActiveSkillLoadouts: Codable, Equatable {
    private var skillIDsByClass: [String: [String]]

    init(skillIDsByClass: [String: [String]] = [:]) {
        self.skillIDsByClass = skillIDsByClass
    }

    func selectedSkillIDs(for heroClass: HeroClass) -> [String] {
        sanitizedSkillIDs(skillIDsByClass[storageKey(for: heroClass)] ?? [], for: heroClass)
    }

    mutating func setSkill(_ skillID: String, for heroClass: HeroClass, slotIndex: Int) {
        guard slotIndex >= 0 else { return }

        let availableIDs = HeroSkills.named(for: heroClass).map(\.id)
        guard availableIDs.contains(skillID) else { return }

        var selectedIDs = selectedSkillIDs(for: heroClass)
        while selectedIDs.count <= slotIndex {
            guard let fallback = availableIDs.first(where: { !selectedIDs.contains($0) }) else { break }
            selectedIDs.append(fallback)
        }
        guard selectedIDs.indices.contains(slotIndex) else { return }

        if let duplicateIndex = selectedIDs.firstIndex(of: skillID), duplicateIndex != slotIndex {
            selectedIDs[duplicateIndex] = selectedIDs[slotIndex]
        }
        selectedIDs[slotIndex] = skillID
        skillIDsByClass[storageKey(for: heroClass)] = sanitizedSkillIDs(selectedIDs, for: heroClass)
    }

    mutating func setSkills(_ skillIDs: [String], for heroClass: HeroClass) {
        skillIDsByClass[storageKey(for: heroClass)] = sanitizedSkillIDs(skillIDs, for: heroClass)
    }

    func activeSkills(for heroClass: HeroClass, heroLevel: Int, slotCount: Int) -> [Skill] {
        HeroSkills.activeLoadout(
            for: heroClass,
            heroLevel: heroLevel,
            slotCount: slotCount,
            preferredSkillIDs: selectedSkillIDs(for: heroClass)
        )
    }

    private func storageKey(for heroClass: HeroClass) -> String {
        heroClass.rawValue
    }

    private func sanitizedSkillIDs(_ skillIDs: [String], for heroClass: HeroClass) -> [String] {
        let availableIDs = HeroSkills.named(for: heroClass).map(\.id)
        var uniqueIDs: [String] = []
        for skillID in skillIDs where availableIDs.contains(skillID) && !uniqueIDs.contains(skillID) {
            uniqueIDs.append(skillID)
        }
        return uniqueIDs
    }
}

/// Source-checked active/base/monster skill catalog. This is data-only until
/// individual runtime semantics are verified and implemented skill by skill.
struct SourceSkill: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let activation: SkillActivation
    let damageType: String
    let delivery: String
    let range: Int
    let sourceValue: Int?

    init(
        id: String,
        name: String,
        activation: SkillActivation,
        damageType: String,
        delivery: String,
        range: Int,
        sourceValue: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.activation = activation
        self.damageType = damageType
        self.delivery = delivery
        self.range = range
        self.sourceValue = sourceValue
    }

    var isRuntimeModeled: Bool {
        SourceSkillCatalog.runtimeModeledSkillIDs.contains(id)
    }

    var sourceValueText: String {
        sourceValue.map(String.init) ?? "未核对"
    }

    var runtimeDamageElement: SkillDamageElement {
        switch damageType.lowercased() {
        case "physical":
            return .physical
        case "fire":
            return .fire
        case "cold":
            return .cold
        case "lightning":
            return .lightning
        case "chaos":
            return .chaos
        default:
            return .none
        }
    }

    var runtimeDelivery: SkillDelivery {
        let parts = delivery
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        let containsProjectile = parts.contains("projectile")
        let containsMelee = parts.contains("melee")
        let containsAOE = parts.contains("aoe")
        let containsSummon = parts.contains("summon")

        if parts.contains("trap") {
            return .trap
        }
        if containsProjectile && containsSummon {
            return .summonProjectile
        }
        if containsProjectile && containsAOE {
            return .projectileAOE
        }
        if containsProjectile {
            return .projectile
        }
        if containsMelee && containsAOE {
            return .meleeAOE
        }
        if containsMelee {
            return .melee
        }
        if containsAOE {
            return .rangeAOE
        }
        return .none
    }
}

enum SourceSkillCatalog {
    static let expectedSourceCount = 106
    static let all: [SourceSkill] = parseSourceRows()

    static var runtimeNamedHeroSkillIDs: Set<String> {
        HeroSkills.namedSourceSkillIDs
    }

    static var runtimeHeroBaseAttackSkillIDs: Set<String> {
        HeroSkills.baseAttackSourceSkillIDs
    }

    static var runtimeHeroSkillIDs: Set<String> {
        runtimeNamedHeroSkillIDs.union(runtimeHeroBaseAttackSkillIDs)
    }

    static var runtimeMonsterAttackSkillIDs: Set<String> {
        Set(monsterSourceSkillIDsByName.values)
    }

    static var runtimeMonsterAttackMappings: [(monsterName: String, sourceSkillID: String)] {
        monsterSourceSkillIDsByName
            .map { (monsterName: $0.key, sourceSkillID: $0.value) }
            .sorted { $0.sourceSkillID < $1.sourceSkillID }
    }

    static var runtimeModeledSkillIDs: Set<String> {
        runtimeHeroSkillIDs.union(runtimeMonsterAttackSkillIDs)
    }

    static var runtimeModeledSkills: [SourceSkill] {
        all.filter(\.isRuntimeModeled)
    }

    static func skill(id: String) -> SourceSkill? {
        all.first { $0.id == id }
    }

    static func sourceSkillID(forMonsterNamed name: String) -> String? {
        monsterSourceSkillIDsByName[name]
    }

    static func skills(activation: SkillActivation) -> [SourceSkill] {
        all.filter { $0.activation == activation }
    }

    static var damageTypes: Set<String> {
        Set(all.map(\.damageType))
    }

    static var deliveries: Set<String> {
        Set(all.map(\.delivery))
    }

    private static func parseSourceRows() -> [SourceSkill] {
        sourceSkillTSV.split(separator: "\n").compactMap { row in
            let columns = row.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard (columns.count == 6 || columns.count == 7),
                  let activation = SkillActivation(rawValue: columns[2]),
                  let range = Int(columns[5]) else {
                return nil
            }
            return SourceSkill(
                id: columns[0],
                name: columns[1],
                activation: activation,
                damageType: columns[3],
                delivery: columns[4],
                range: range,
                sourceValue: columns.count == 7 ? Int(columns[6]) : nil
            )
        }
    }

    private static let monsterSourceSkillIDsByName: [String: String] = [
        "燃烧的地狱祭司": "301015",
        "冰冻的地狱祭司": "301025",
        "电流的地狱祭司": "301035",
        "混沌的地狱祭司": "301045"
    ]

    private static let sourceSkillTSV = """
10001	Skill 10001	BASEATTACK	Physical	Melee	140
10101	Piercing Thrust	BASEATTACK_COUNT	Physical	Melee, AOE	200
10201	Shield Charge	COOLDOWN	Physical	Melee	900
10301	Retribution Strike	BASEATTACK_COUNT	Physical	Melee	150
10401	Aegis Field	COOLDOWN	Physical	AOE	150
10501	Sacred Blade	COOLDOWN	Physical		150
10601	Unyielding Will	COOLDOWN	Physical		150
20001	Skill 20001	BASEATTACK	Physical	Projectile	1100
20101	Rapid Fire	BASEATTACK_COUNT	Physical	Projectile	1150
20201	Scatter Shot	COOLDOWN	Physical	Projectile	1650
20301	Arrow Rain	COOLDOWN	Physical	AOE	1300
20401	Swift Surge	COOLDOWN	Physical		1200
20501	Piercing Arrow	BASEATTACK_COUNT	Physical	Projectile	1200
20601	Skewer Shot	BASEATTACK_COUNT	Physical	Projectile	1200
30001	Skill 30001	BASEATTACK	Fire	Projectile	900
30101	Fireball	COOLDOWN	Fire	Projectile, AOE	950
30201	Ice Orb	COOLDOWN	Cold	Projectile, AOE	950
30301	Lightning	COOLDOWN	Lightning	AOE	1050
30401	Flame Hydra	COOLDOWN	Fire	Projectile, Summon	1100
30501	Snowstorm	COOLDOWN	Cold	AOE	1100
30601	Meteor Strike	COOLDOWN	Fire	AOE	1100
40001	Skill 40001	BASEATTACK	Physical	Melee	170
40101	Heal	COOLDOWN	Physical		950
40201	Blessing Of Might	CONTINUOUS	Physical	AOE	950
40301	Wrath of Heaven	COOLDOWN	Lightning	AOE	1050
40401	Sanctuary	COOLDOWN	Physical	AOE	1100
40501	Blessing of Warding	CONTINUOUS	Physical	AOE	1100
40601	Resurrection	COOLDOWN	Physical		1100
50001	Skill 50001	BASEATTACK	Physical	Projectile	1000
50101	Explosive Bolt	BASEATTACK_COUNT	Fire	Projectile	1100
50201	Frost Bolt	COOLDOWN	Cold	Projectile	1100
50301	Quick Loader	COOLDOWN	Physical		1050
50401	Charge Trap	COOLDOWN	Physical	Trap	1150
50501	Crossbow Turret	COOLDOWN	Physical	Projectile, Summon	1100
50601	Shock Bolt	BASEATTACK_COUNT	Lightning	Projectile	1100
60001	Skill 60001	BASEATTACK	Physical	Melee	120
60101	Slam Jump	COOLDOWN	Physical	Melee, AOE	850
60201	Crushing Blow	BASEATTACK_COUNT	Physical	Melee	200
60301	Commander’s Cry	COOLDOWN	Physical	AOE	150
60401	Ground Slam	BASEATTACK_COUNT	Physical	Melee, AOE	300
60501	Axe Spin	COOLDOWN	Physical	Melee, AOE	150
60601	Bloodlust	COOLDOWN	Physical		900
100111	Skill 100111	BASEATTACK	Physical		200
100211	Skill 100211	BASEATTACK	Physical		130
100221	Skill 100221	BASEATTACK	Physical		170
100231	Skill 100231	BASEATTACK	Fire		800
100311	Skill 100311	BASEATTACK	Physical		200
100411	Skill 100411	BASEATTACK	Physical		150
100421	Skill 100421	BASEATTACK	Physical		170
100431	Skill 100431	BASEATTACK	Physical		250
100511	Skill 100511	BASEATTACK	Physical		150
100521	Skill 100521	BASEATTACK	Physical		900
100531	Skill 100531	BASEATTACK	Physical		300
109011	Skill 109011	BASEATTACK	Physical		300
109021	Skill 109021	BASEATTACK_COUNT	Physical		450	1500
109031	Skill 109031	COOLDOWN	Physical		700	1500
109041	Skill 109041	COOLDOWN	Physical		300	1500
109051	Skill 109051	COOLDOWN	Physical		700	1500
200111	Skill 200111	BASEATTACK	Physical		150
200211	Skill 200211	BASEATTACK	Physical		130
200221	Skill 200221	BASEATTACK	Physical		900
200231	Skill 200231	BASEATTACK	Physical		150
200241	Skill 200241	BASEATTACK	Physical		170
200311	Skill 200311	BASEATTACK	Physical		200
200411	Skill 200411	BASEATTACK	Chaos		150
200421	Skill 200421	BASEATTACK	Chaos		800	1000
200511	Skill 200511	BASEATTACK	Physical		200
200611	Skill 200611	BASEATTACK	Physical		170
200621	Skill 200621	BASEATTACK	Physical		900
200711	Skill 200711	BASEATTACK	Physical		150
200811	Skill 200811	BASEATTACK	Physical		150
200911	Skill 200911	BASEATTACK	Fire		800
201111	Skill 201111	BASEATTACK	Physical		170
201211	Skill 201211	BASEATTACK	Physical		130	1000
209011	Skill 209011	BASEATTACK	Physical		230
209021	Skill 209021	COOLDOWN	Physical		250	1800
209031	Skill 209031	BASEATTACK_COUNT	Physical		600	1350
209041	Skill 209041	COOLDOWN	Physical		270	2300
209051	Skill 209051	COOLDOWN	Physical		600	2000
300111	Skill 300111	BASEATTACK	Physical		130
300121	Skill 300121	BASEATTACK	Physical		150
300131	Skill 300131	BASEATTACK	Physical		170
300211	Skill 300211	BASEATTACK	Physical		250
300311	Skill 300311	BASEATTACK	Fire		800
300411	Skill 300411	BASEATTACK	Physical		170
300421	Skill 300421	BASEATTACK	Physical		900
300431	Skill 300431	BASEATTACK	Physical		200
300441	Skill 300441	BASEATTACK	Cold		800	1000
300511	Skill 300511	BASEATTACK	Physical		200
300611	Skill 300611	BASEATTACK	Fire		170
300711	Skill 300711	BASEATTACK	Chaos		800
300811	Skill 300811	BASEATTACK	Physical		150
300821	Skill 300821	BASEATTACK	Fire		800
300831	Skill 300831	BASEATTACK	Physical		250
300841	Skill 300841	BASEATTACK	Physical		130
300911	Skill 300911	BASEATTACK	Fire		300
301015	Skill 301015	BASEATTACK	Fire		800
301025	Skill 301025	BASEATTACK	Cold		800
301035	Skill 301035	BASEATTACK	Lightning		800
301045	Skill 301045	BASEATTACK	Chaos		800
301111	Skill 301111	BASEATTACK	Physical		150
309011	Skill 309011	BASEATTACK	Chaos		700
309021	Skill 309021	COOLDOWN	Chaos		700	800
309031	Skill 309031	COOLDOWN	Physical		800	1500
309041	Skill 309041	COOLDOWN	Chaos		700	1700
309051	Skill 309051	COOLDOWN	Chaos		600	2300
"""
}

enum PassiveSkillValueType: String, Codable, CaseIterable {
    case flat = "FLAT"
    case additive = "ADDITIVE"
}

/// Source-checked passive skill node catalog. Unlock paths are still incomplete,
/// but explicitly unlocked IDs can now feed the conservative runtime hooks below.
struct PassiveSkill: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let stat: String
    let valueType: PassiveSkillValueType
    let value: Int

    var heroClass: HeroClass? {
        PassiveSkills.heroClass(for: id)
    }
}

enum PassiveSkills {
    static let all: [PassiveSkill] = parseSourceRows()

    static func skill(id: String) -> PassiveSkill? {
        all.first { $0.id == id }
    }

    static func skills(for heroClass: HeroClass) -> [PassiveSkill] {
        all.filter { $0.heroClass == heroClass }
    }

    static func heroClass(for passiveSkillID: String) -> HeroClass? {
        switch passiveSkillID.first {
        case "1":
            return .knight
        case "2":
            return .ranger
        case "3":
            return .sorcerer
        case "4":
            return .priest
        case "5":
            return .hunter
        case "6":
            return .slayer
        default:
            return nil
        }
    }

    private static func parseSourceRows() -> [PassiveSkill] {
        passiveSkillTSV.split(separator: "\n").compactMap { row in
            let columns = row.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard columns.count == 5,
                  let valueType = PassiveSkillValueType(rawValue: columns[3]),
                  let value = Int(columns[4]) else {
                return nil
            }
            return PassiveSkill(
                id: columns[0],
                name: columns[1],
                stat: columns[2],
                valueType: valueType,
                value: value
            )
        }
    }

    private static let passiveSkillTSV = """
101001	Attack Damage Enhancement	AttackDamage	FLAT	1
101002	Health Enhancement	MaxHp	FLAT	15
101011	Armor Enhancement	Armor	FLAT	10
101012	HP Regen Enhancement	HpRegenPerSec	FLAT	100
101021	HP Per Kill Enhancement	AddHpPerKill	FLAT	3
101022	Block Chance Enhancement	BlockChance	FLAT	30
101031	Physical Damage Enhancement	PhysicalDamagePercent	FLAT	150
101032	Health Enhancement	MaxHp	ADDITIVE	50
101041	Cooldown Reduction	CooldownReduction	FLAT	20
101042	HP Regen Enhancement	HpRegenPerSec	FLAT	100
101051	HP Per Kill Enhancement	AddHpPerKill	FLAT	5
101052	Block Chance Enhancement	BlockChance	FLAT	30
101061	Attack Speed Enhancement	AttackSpeed	ADDITIVE	40
101062	All Elemental Resistance Enhancement	AllElementalResistance	FLAT	30
101071	Damage Reduction Enhancement	DamageReduction	FLAT	20
101072	Attack Damage Enhancement	AttackDamage	FLAT	1
101081	Skill Range Enhancement	SkillRangeExpansion	ADDITIVE	30
101082	Area of Effect Enhancement	AreaOfEffect	ADDITIVE	50
201001	Attack Damage Enhancement	AttackDamage	FLAT	1
201002	Attack Speed Enhancement	AttackSpeed	ADDITIVE	40
201011	Critical Chance Enhancement	CriticalChance	ADDITIVE	200
201012	Critical Damage Enhancement	CriticalDamage	FLAT	130
201021	Dodge Chance Enhancement	DodgeChance	FLAT	30
201022	Projectile Damage Enhancement	IncreaseProjectileDamage	ADDITIVE	150
201031	Dodge Chance Enhancement	DodgeChance	FLAT	30
201032	Attack Speed Enhancement	AttackSpeed	ADDITIVE	50
201041	Dodge Chance Enhancement	ElementalDodgeChance	FLAT	30
201042	Movement Speed Enhancement	MovementSpeed	FLAT	20
201051	Dodge Chance Enhancement	DodgeChance	FLAT	30
201052	Life Leech Enhancement	HpLeech	FLAT	5
201061	Area of Effect Damage Enhancement	IncreaseAreaOfEffectDamage	ADDITIVE	150
201062	Projectile Damage Enhancement	IncreaseProjectileDamage	ADDITIVE	150
201071	Dodge Chance Enhancement	DodgeChance	FLAT	30
201072	Attack Speed Enhancement	AttackSpeed	ADDITIVE	60
201081	Max Dodge Chance Enhancement	MaxDodgeChance	FLAT	10
201082	Movement Speed Enhancement	MovementSpeed	FLAT	20
301001	Attack Damage Enhancement	AttackDamage	FLAT	2
301002	Cooldown Reduction	CooldownReduction	FLAT	10
301011	Area of Effect Enhancement	AreaOfEffect	ADDITIVE	30
301012	Critical Chance Enhancement	CriticalChance	ADDITIVE	200
301021	Fire Damage Enhancement	FireDamagePercent	FLAT	100
301022	Cold Damage Enhancement	ColdDamagePercent	FLAT	100
301031	Lightning Damage Enhancement	LightningDamagePercent	FLAT	100
301032	Health Enhancement	MaxHp	FLAT	10
301041	Cooldown Reduction	CooldownReduction	FLAT	20
301042	Attack Damage Enhancement	AttackDamage	FLAT	2
301051	Cast Speed Enhancement	CastSpeed	ADDITIVE	70
301052	Critical Damage Enhancement	CriticalDamage	FLAT	200
301061	All Elemental Resistance Enhancement	AllElementalResistance	FLAT	20
301062	Area of Effect Enhancement	AreaOfEffect	ADDITIVE	30
301071	Critical Chance Enhancement	CriticalChance	FLAT	3
301072	Cooldown Reduction	CooldownReduction	FLAT	20
301081	Attack Damage Enhancement	AttackDamage	FLAT	3
301082	Cast Speed Enhancement	CastSpeed	ADDITIVE	70
401001	Attack Damage Enhancement	AttackDamage	FLAT	1
401002	Health Enhancement	MaxHp	FLAT	15
401011	Armor Enhancement	Armor	FLAT	10
401012	Damage Absorption Enhancement	DamageAbsorption	FLAT	5
401021	Cooldown Reduction	CooldownReduction	FLAT	20
401022	Skill Heal Enhancement	SkillHealIncrease	ADDITIVE	70
401031	Health Enhancement	MaxHp	FLAT	15
401032	Damage Absorption Enhancement	DamageAbsorption	FLAT	5
401041	Cast Speed Enhancement	CastSpeed	ADDITIVE	70
401042	Block Chance Enhancement	BlockChance	FLAT	30
401051	Physical Damage Enhancement	PhysicalDamagePercent	FLAT	150
401052	All Elemental Resistance Enhancement	AllElementalResistance	FLAT	20
401061	Cooldown Reduction	CooldownReduction	FLAT	20
401062	Armor Enhancement	Armor	FLAT	50
401071	Area of Effect Enhancement	AreaOfEffect	ADDITIVE	30
401072	Cast Speed Enhancement	CastSpeed	ADDITIVE	70
401081	Health Enhancement	MaxHp	FLAT	20
401082	Skill Heal Enhancement	SkillHealIncrease	ADDITIVE	70
501001	Attack Damage Enhancement	AttackDamage	FLAT	2
501002	Critical Chance Enhancement	CriticalChance	ADDITIVE	200
501011	Critical Damage Enhancement	CriticalDamage	FLAT	100
501012	Dodge Chance Enhancement	DodgeChance	FLAT	30
501021	Fire Damage Enhancement	FireDamagePercent	FLAT	150
501022	Cold Damage Enhancement	ColdDamagePercent	FLAT	150
501031	Cooldown Reduction	CooldownReduction	FLAT	10
501032	Health Enhancement	MaxHp	FLAT	15
501041	Physical Damage Enhancement	PhysicalDamagePercent	FLAT	150
501042	Critical Chance Enhancement	CriticalChance	FLAT	3
501051	Attack Damage Enhancement	AttackDamage	FLAT	3
501052	Area of Effect Enhancement	AreaOfEffect	ADDITIVE	30
501061	Lightning Damage Enhancement	LightningDamagePercent	FLAT	150
501062	Critical Damage Enhancement	CriticalDamage	FLAT	150
501071	Attack Speed Enhancement	AttackSpeed	ADDITIVE	40
501072	HP Per Hit Enhancement	AddHpPerHit	FLAT	3
501081	Critical Chance Enhancement	CriticalChance	FLAT	5
501082	Critical Damage Enhancement	CriticalDamage	FLAT	150
601001	Attack Damage Enhancement	AttackDamage	FLAT	2
601002	Health Enhancement	MaxHp	FLAT	15
601011	Area of Effect Enhancement	AreaOfEffect	ADDITIVE	30
601012	HP Per Kill Enhancement	AddHpPerKill	FLAT	5
601021	Physical Damage Enhancement	PhysicalDamagePercent	FLAT	150
601022	Life Leech Enhancement	HpLeech	FLAT	5
601031	Attack Damage Enhancement	AttackDamage	FLAT	2
601032	Health Enhancement	MaxHp	FLAT	15
601041	Critical Damage Enhancement	CriticalDamage	FLAT	100
601042	Physical Damage Enhancement	PhysicalDamagePercent	FLAT	150
601051	Area of Effect Damage Enhancement	IncreaseAreaOfEffectDamage	ADDITIVE	150
601052	Area of Effect Enhancement	AreaOfEffect	ADDITIVE	30
601061	Health Enhancement	MaxHp	FLAT	20
601062	Movement Speed Enhancement	MovementSpeed	ADDITIVE	20
601071	Area of Effect Damage Enhancement	IncreaseAreaOfEffectDamage	ADDITIVE	150
601072	Duration Enhancement	SkillDurationIncrease	ADDITIVE	80
601081	Physical Damage Enhancement	PhysicalDamagePercent	FLAT	150
601082	Area of Effect Enhancement	AreaOfEffect	ADDITIVE	30
"""
}

struct PassiveSkillRuntimeEffects: Codable, Equatable {
    var passiveMaxHp = 0
    var passiveMaxHpMultiplier = 1.0
    var passiveAttackDamage = 0
    var passiveAttackDamageMultiplier = 1.0
    var passiveArmor = 0
    var passiveAttackSpeedMultiplier = 1.0
    var passiveCriticalChance = 0.0
    var passiveCriticalDamage = 0.0
    var passiveHpRegenPerSec = 0.0
    var passiveAddHpPerHit = 0
    var passiveAddHpPerKill = 0
    var passiveHpLeech = 0.0
    var passiveDamageReduction = 0.0
    var passiveDamageAbsorption = 0
    var passiveAllElementalResistance = 0.0
    var passiveBlockChance = 0.0
    var passiveDodgeChance = 0.0
    var passiveElementalDodgeChance = 0.0
    var passiveMaxDodgeChance = 0.0
    var passivePhysicalDamagePercent = 0.0
    var passiveFireDamagePercent = 0.0
    var passiveColdDamagePercent = 0.0
    var passiveLightningDamagePercent = 0.0
    var passiveIncreaseProjectileDamage = 0.0
    var passiveIncreaseAreaOfEffectDamage = 0.0
    var passiveSkillHealIncrease = 0.0
    var passiveSkillDurationIncrease = 0.0
    var passiveCooldownReduction = 0.0
    var passiveCastSpeed = 0.0
    var passiveSkillRangeExpansion = 0.0
    var passiveAreaOfEffect = 0.0
    var passiveMovementSpeed = 0
    var passiveMovementSpeedMultiplier = 1.0

    static let none = PassiveSkillRuntimeEffects()

    static func make(unlockedSkillIDs: Set<String>, heroClass: HeroClass) -> PassiveSkillRuntimeEffects {
        guard !unlockedSkillIDs.isEmpty else { return .none }

        var effects = PassiveSkillRuntimeEffects()
        for passiveSkill in PassiveSkills.skills(for: heroClass) where unlockedSkillIDs.contains(passiveSkill.id) {
            effects.apply(passiveSkill)
        }
        return effects
    }

    private mutating func apply(_ passiveSkill: PassiveSkill) {
        switch passiveSkill.stat {
        case "MaxHp":
            if passiveSkill.valueType == .additive {
                passiveMaxHpMultiplier += percentMultiplierDelta(passiveSkill)
            } else {
                passiveMaxHp += max(0, passiveSkill.value)
            }
        case "AttackDamage":
            if passiveSkill.valueType == .additive {
                passiveAttackDamageMultiplier += percentMultiplierDelta(passiveSkill)
            } else {
                passiveAttackDamage += max(0, passiveSkill.value)
            }
        case "Armor":
            passiveArmor += max(0, passiveSkill.value)
        case "AttackSpeed":
            passiveAttackSpeedMultiplier += percentMultiplierDelta(passiveSkill)
        case "CriticalChance":
            passiveCriticalChance += basisPointChance(passiveSkill)
        case "CriticalDamage":
            passiveCriticalDamage += percentMultiplierDelta(passiveSkill)
        case "HpRegenPerSec":
            passiveHpRegenPerSec += Double(max(0, passiveSkill.value))
        case "AddHpPerHit":
            passiveAddHpPerHit += max(0, passiveSkill.value)
        case "AddHpPerKill":
            passiveAddHpPerKill += max(0, passiveSkill.value)
        case "HpLeech":
            passiveHpLeech += percentMultiplierDelta(passiveSkill)
        case "DamageReduction":
            passiveDamageReduction += percentMultiplierDelta(passiveSkill)
        case "DamageAbsorption":
            passiveDamageAbsorption += max(0, passiveSkill.value)
        case "AllElementalResistance":
            passiveAllElementalResistance += percentMultiplierDelta(passiveSkill)
        case "BlockChance":
            passiveBlockChance += basisPointChance(passiveSkill)
        case "DodgeChance":
            passiveDodgeChance += basisPointChance(passiveSkill)
        case "ElementalDodgeChance":
            passiveElementalDodgeChance += basisPointChance(passiveSkill)
        case "MaxDodgeChance":
            passiveMaxDodgeChance += basisPointChance(passiveSkill)
        case "PhysicalDamagePercent":
            passivePhysicalDamagePercent += percentMultiplierDelta(passiveSkill)
        case "FireDamagePercent":
            passiveFireDamagePercent += percentMultiplierDelta(passiveSkill)
        case "ColdDamagePercent":
            passiveColdDamagePercent += percentMultiplierDelta(passiveSkill)
        case "LightningDamagePercent":
            passiveLightningDamagePercent += percentMultiplierDelta(passiveSkill)
        case "IncreaseProjectileDamage":
            passiveIncreaseProjectileDamage += percentMultiplierDelta(passiveSkill)
        case "IncreaseAreaOfEffectDamage":
            passiveIncreaseAreaOfEffectDamage += percentMultiplierDelta(passiveSkill)
        case "SkillHealIncrease":
            passiveSkillHealIncrease += percentMultiplierDelta(passiveSkill)
        case "SkillDurationIncrease":
            passiveSkillDurationIncrease += percentMultiplierDelta(passiveSkill)
        case "CooldownReduction":
            passiveCooldownReduction += percentMultiplierDelta(passiveSkill)
        case "CastSpeed":
            passiveCastSpeed += percentMultiplierDelta(passiveSkill)
        case "SkillRangeExpansion":
            passiveSkillRangeExpansion += percentMultiplierDelta(passiveSkill)
        case "AreaOfEffect":
            passiveAreaOfEffect += percentMultiplierDelta(passiveSkill)
        case "MovementSpeed":
            if passiveSkill.valueType == .additive {
                passiveMovementSpeedMultiplier += percentMultiplierDelta(passiveSkill)
            } else {
                passiveMovementSpeed += max(0, passiveSkill.value)
            }
        default:
            break
        }
    }

    private func percentMultiplierDelta(_ passiveSkill: PassiveSkill) -> Double {
        Double(max(0, passiveSkill.value)) / 100.0
    }

    private func basisPointChance(_ passiveSkill: PassiveSkill) -> Double {
        Double(max(0, passiveSkill.value)) / 10_000.0
    }
}

/// 原版命名主动技能的轻量数据基线。
enum HeroSkills {
    static let defaultActiveSkillSlotCount = 1
    static let maximumModeledActiveSkillSlots = 6

    static var namedSourceSkillIDs: Set<String> {
        Set(HeroClass.allCases.flatMap { named(for: $0).map(\.id) })
    }

    static var baseAttackSourceSkillIDs: Set<String> {
        Set(HeroClass.allCases.map(baseAttackSourceSkillID(for:)))
    }

    static func baseAttackSourceSkill(for heroClass: HeroClass) -> SourceSkill? {
        SourceSkillCatalog.skill(id: baseAttackSourceSkillID(for: heroClass))
    }

    static func baseAttackDamageElement(for heroClass: HeroClass) -> SkillDamageElement {
        baseAttackSourceSkill(for: heroClass)?.runtimeDamageElement ?? .physical
    }

    static func baseAttackDelivery(for heroClass: HeroClass) -> SkillDelivery {
        baseAttackSourceSkill(for: heroClass)?.runtimeDelivery ?? .melee
    }

    static func activeLoadout(
        for heroClass: HeroClass,
        heroLevel: Int,
        slotCount: Int,
        preferredSkillIDs: [String] = []
    ) -> [Skill] {
        let availableSkills = named(for: heroClass)
            .filter { heroLevel >= $0.unlockLevel }
        let clampedSlotCount = min(max(slotCount, defaultActiveSkillSlotCount), availableSkills.count)
        guard clampedSlotCount > 0 else { return [] }

        var selectedSkills: [Skill] = []
        for skillID in preferredSkillIDs {
            guard selectedSkills.count < clampedSlotCount else { break }
            guard let skill = availableSkills.first(where: { $0.id == skillID }) else { continue }
            guard !selectedSkills.contains(where: { $0.id == skill.id }) else { continue }
            selectedSkills.append(skill)
        }

        for skill in availableSkills {
            guard selectedSkills.count < clampedSlotCount else { break }
            guard !selectedSkills.contains(where: { $0.id == skill.id }) else { continue }
            selectedSkills.append(skill)
        }

        return selectedSkills
    }

    static func skill(forLogSkillName skillName: String) -> Skill? {
        let allSkills = HeroClass.allCases.flatMap { named(for: $0) }
        if let exact = allSkills.first(where: { $0.name == skillName }) {
            return exact
        }
        return allSkills.first { skillName.hasPrefix($0.name) }
    }

    private static func baseAttackSourceSkillID(for heroClass: HeroClass) -> String {
        switch heroClass {
        case .knight:
            return "10001"
        case .ranger:
            return "20001"
        case .sorcerer:
            return "30001"
        case .priest:
            return "40001"
        case .hunter:
            return "50001"
        case .slayer:
            return "60001"
        }
    }

    static func named(for heroClass: HeroClass) -> [Skill] {
        switch heroClass {
        case .knight:
            return [
                Skill(id: "10101", name: "穿透突刺", description: "向前突刺，对范围敌人造成物理伤害。", cooldown: 5, damageMultiplier: 25.0, unlockLevel: 1, activation: .baseAttackCount, levelValues: [2_500, 2_700, 2_900, 3_100, 3_300, 3_500, 3_700, 3_900, 4_100, 4_300], damageElement: .physical, delivery: .meleeAOE),
                Skill(id: "10201", name: "盾牌冲锋", description: "举盾冲锋，对撞到的敌人造成物理伤害。", cooldown: 8, damageMultiplier: 30.0, unlockLevel: 1, levelValues: [3_000, 3_300, 3_600, 3_900, 4_200, 4_500, 4_800, 5_100, 5_400, 5_700], damageElement: .physical, delivery: .melee),
                Skill(id: "10301", name: "报应打击", description: "生命越低，打击次数越多。", cooldown: 10, damageMultiplier: 15.0, unlockLevel: 1, activation: .baseAttackCount, levelValues: [1_500, 1_700, 1_900, 2_100, 2_300, 2_500, 2_700, 2_900, 3_100, 3_300], damageElement: .physical, delivery: .melee),
                Skill(id: "10401", name: "神盾领域", description: "展开领域，为友军阻挡伤害。", cooldown: 14, damageMultiplier: 0, unlockLevel: 1, levelValues: [500, 650, 800, 950, 1_100, 1_250, 1_400, 1_550, 1_700, 1_850], damageElement: .physical, delivery: .buff),
                Skill(id: "10501", name: "神圣之刃", description: "强化攻击并在攻击时回复生命。", cooldown: 16, damageMultiplier: 0, unlockLevel: 1, levelValues: [20, 40, 60, 80, 100, 120, 140, 160, 180, 200], damageElement: .physical, delivery: .buff),
                Skill(id: "10601", name: "不屈意志", description: "每关一次濒死后重新站起。", cooldown: 30, damageMultiplier: 0, unlockLevel: 1, levelValues: [300, 400, 500, 600, 700, 800, 900, 1_000, 1_100, 1_200], delivery: .buff)
            ]
        case .ranger:
            return [
                Skill(id: "20101", name: "快速射击", description: "连续射出多支箭矢。", cooldown: 5, damageMultiplier: 13.2, unlockLevel: 1, activation: .baseAttackCount, levelValues: [1_320, 1_440, 1_560, 1_680, 1_800, 1_920, 2_040, 2_160, 2_280, 2_400], damageElement: .physical, delivery: .projectile),
                Skill(id: "20201", name: "散弹射击", description: "发射多支追踪敌人的箭矢。", cooldown: 8, damageMultiplier: 16.2, unlockLevel: 1, levelValues: [1_620, 1_780, 1_940, 2_100, 2_260, 2_420, 2_580, 2_740, 2_900, 3_060], damageElement: .physical, delivery: .projectile),
                Skill(id: "20301", name: "箭雨", description: "对广范围敌人造成物理伤害。", cooldown: 12, damageMultiplier: 21.5, unlockLevel: 1, levelValues: [2_150, 2_410, 2_670, 2_930, 3_190, 3_450, 3_710, 3_970, 4_230, 4_490], damageElement: .physical, delivery: .rangeAOE),
                Skill(id: "20401", name: "迅捷觉醒", description: "短时间提升攻击速度。", cooldown: 14, damageMultiplier: 0, unlockLevel: 1, levelValues: [500, 600, 700, 800, 900, 1_000, 1_100, 1_200, 1_300, 1_400], delivery: .buff),
                Skill(id: "20501", name: "穿透之箭", description: "射出贯穿敌人的箭矢。", cooldown: 9, damageMultiplier: 24.4, unlockLevel: 1, activation: .baseAttackCount, levelValues: [2_440, 2_600, 2_760, 2_920, 3_080, 3_240, 3_400, 3_560, 3_720, 3_880], damageElement: .physical, delivery: .projectile),
                Skill(id: "20601", name: "穿刺射击", description: "箭矢扎入敌人并可触发出血。", cooldown: 11, damageMultiplier: 10.0, unlockLevel: 1, activation: .baseAttackCount, levelValues: [1_000, 1_300, 1_600, 1_900, 2_200, 2_500, 2_800, 3_100, 3_400, 3_700], damageElement: .physical, delivery: .projectile)
            ]
        case .sorcerer:
            return [
                Skill(id: "30101", name: "火球术", description: "接触敌人时爆炸，造成火焰范围伤害。", cooldown: 6, damageMultiplier: 27.0, unlockLevel: 1, levelValues: [2_700, 2_950, 3_200, 3_450, 3_700, 3_950, 4_200, 4_450, 4_700, 4_950], damageElement: .fire, delivery: .rangeAOE),
                Skill(id: "30201", name: "冰球术", description: "造成多段冰冷伤害并减速敌人。", cooldown: 8, damageMultiplier: 15.0, unlockLevel: 1, levelValues: [1_500, 1_620, 1_740, 1_860, 1_980, 2_100, 2_220, 2_340, 2_460, 2_580], damageElement: .cold, delivery: .rangeAOE),
                Skill(id: "30301", name: "闪电术", description: "向前射出电流造成闪电伤害。", cooldown: 7, damageMultiplier: 25.5, unlockLevel: 1, levelValues: [2_550, 2_820, 3_090, 3_360, 3_630, 3_900, 4_170, 4_440, 4_710, 4_980], damageElement: .lightning, delivery: .rangeAOE),
                Skill(id: "30401", name: "烈焰九头蛇", description: "召唤海德拉发射火球。", cooldown: 16, damageMultiplier: 23.0, unlockLevel: 1, levelValues: [2_300, 2_450, 2_600, 2_750, 2_900, 3_050, 3_200, 3_350, 3_500, 3_650], damageElement: .fire, delivery: .summonProjectile),
                Skill(id: "30501", name: "暴风雪", description: "召唤冰块，持续造成冰冷伤害。", cooldown: 18, damageMultiplier: 5.0, unlockLevel: 1, levelValues: [500, 660, 820, 980, 1_140, 1_300, 1_460, 1_620, 1_780, 1_940], damageElement: .cold, delivery: .rangeAOE),
                Skill(id: "30601", name: "陨石打击", description: "召唤陨石造成大范围火焰伤害。", cooldown: 20, damageMultiplier: 55.0, unlockLevel: 1, levelValues: [5_500, 5_950, 6_400, 6_850, 7_300, 7_750, 8_200, 8_650, 9_100, 9_550], damageElement: .fire, delivery: .rangeAOE)
            ]
        case .priest:
            return [
                Skill(id: "40101", name: "治愈", description: "为一名友军恢复最大生命。", cooldown: 8, damageMultiplier: 0, unlockLevel: 1, levelValues: [100, 120, 140, 160, 180, 200, 220, 240, 260, 280], delivery: .heal),
                Skill(id: "40201", name: "力量祝福", description: "提升自身和附近队友攻击力。", cooldown: 12, damageMultiplier: 0, unlockLevel: 1, activation: .continuous, levelValues: [500, 600, 700, 800, 900, 1_000, 1_100, 1_200, 1_300, 1_400], delivery: .buff),
                Skill(id: "40301", name: "天堂之怒", description: "攻击附带闪电范围伤害。", cooldown: 14, damageMultiplier: 43.0, unlockLevel: 1, levelValues: [4_300, 4_700, 5_100, 5_500, 5_900, 6_300, 6_700, 7_100, 7_500, 7_900], damageElement: .lightning, delivery: .rangeAOE),
                Skill(id: "40401", name: "圣域", description: "展开神圣领域，为友军持续恢复生命。", cooldown: 18, damageMultiplier: 0, unlockLevel: 1, levelValues: [300, 400, 520, 660, 820, 1_000, 1_200, 1_420, 1_660, 1_920], delivery: .heal),
                Skill(id: "40501", name: "守护祝福", description: "提升自身和附近队友元素抗性。", cooldown: 16, damageMultiplier: 0, unlockLevel: 1, activation: .continuous, levelValues: [10, 15, 20, 25, 30, 35, 40, 45, 50, 55], delivery: .buff),
                Skill(id: "40601", name: "复活", description: "复活一名倒下的队友。", cooldown: 30, damageMultiplier: 0, unlockLevel: 1, levelValues: [300, 350, 400, 450, 500, 550, 600, 650, 700, 750], delivery: .resurrection)
            ]
        case .hunter:
            return [
                Skill(id: "50101", name: "爆炸弩箭", description: "弩箭命中后爆炸，造成火焰范围伤害。", cooldown: 7, damageMultiplier: 48.4, unlockLevel: 1, activation: .baseAttackCount, levelValues: [4_840, 5_350, 5_860, 6_370, 6_880, 7_390, 7_900, 8_410, 8_920, 9_430], damageElement: .fire, delivery: .projectileAOE),
                Skill(id: "50201", name: "寒霜弩箭", description: "造成冰冷范围伤害并冰冻敌人。", cooldown: 8, damageMultiplier: 21.0, unlockLevel: 1, levelValues: [2_100, 2_250, 2_400, 2_550, 2_700, 2_850, 3_000, 3_150, 3_300, 3_450], damageElement: .cold, delivery: .projectileAOE),
                Skill(id: "50301", name: "快速装填", description: "数次攻击期间提升攻击速度。", cooldown: 12, damageMultiplier: 0, unlockLevel: 1, levelValues: [3, 4, 5, 6, 7, 8, 9, 10, 11, 12], delivery: .buff),
                Skill(id: "50401", name: "充能陷阱", description: "发射受元素伤害时爆炸的陷阱。", cooldown: 13, damageMultiplier: 0, unlockLevel: 1, levelValues: [1_000, 1_500, 2_000, 2_500, 3_000, 3_500, 4_000, 4_500, 5_000, 5_500], damageElement: .physical, delivery: .trap),
                Skill(id: "50501", name: "弩炮塔", description: "设置自动弩发射弩箭。", cooldown: 16, damageMultiplier: 17.5, unlockLevel: 1, levelValues: [1_750, 1_910, 2_070, 2_230, 2_390, 2_550, 2_710, 2_870, 3_030, 3_190], damageElement: .physical, delivery: .summonProjectile),
                Skill(id: "50601", name: "电击弩箭", description: "扎入敌人并向周围释放闪电。", cooldown: 14, damageMultiplier: 27.0, unlockLevel: 1, activation: .baseAttackCount, levelValues: [2_700, 2_900, 3_100, 3_300, 3_500, 3_700, 3_900, 4_100, 4_300, 4_500], damageElement: .lightning, delivery: .projectile)
            ]
        case .slayer:
            return [
                Skill(id: "60101", name: "猛击跳跃", description: "跃向敌人，落地造成范围物理伤害。", cooldown: 7, damageMultiplier: 31.0, unlockLevel: 1, levelValues: [3_100, 3_350, 3_600, 3_850, 4_100, 4_350, 4_600, 4_850, 5_100, 5_350], damageElement: .physical, delivery: .meleeAOE),
                Skill(id: "60201", name: "粉碎强击", description: "重击敌人，击杀时产生冲击波。", cooldown: 9, damageMultiplier: 62.0, unlockLevel: 1, activation: .baseAttackCount, levelValues: [6_200, 6_600, 7_000, 7_400, 7_800, 8_200, 8_600, 9_000, 9_400, 9_800], damageElement: .physical, delivery: .melee),
                Skill(id: "60301", name: "将军怒吼", description: "眩晕周围敌人并提升队伍暴击几率系数。", cooldown: 16, damageMultiplier: 0, unlockLevel: 1, levelValues: [500, 550, 600, 650, 700, 750, 800, 850, 900, 950], damageElement: .physical, delivery: .buff),
                Skill(id: "60401", name: "大地强击", description: "猛击地面引发地震和岩石爆炸。", cooldown: 14, damageMultiplier: 37.0, unlockLevel: 1, activation: .baseAttackCount, levelValues: [3_700, 3_950, 4_200, 4_450, 4_700, 4_950, 5_200, 5_450, 5_700, 5_950], damageElement: .physical, delivery: .meleeAOE),
                Skill(id: "60501", name: "旋转斧", description: "旋转攻击周围敌人并可能造成流血。", cooldown: 13, damageMultiplier: 10.0, unlockLevel: 1, levelValues: [1_000, 1_080, 1_160, 1_240, 1_320, 1_400, 1_480, 1_560, 1_640, 1_720], damageElement: .physical, delivery: .meleeAOE),
                Skill(id: "60601", name: "嗜血", description: "消耗当前生命，短时间提升攻击伤害。", cooldown: 18, damageMultiplier: 0, unlockLevel: 1, levelValues: [4_000, 4_300, 4_600, 4_900, 5_200, 5_500, 5_800, 6_100, 6_400, 6_700], delivery: .buff)
            ]
        }
    }
}

enum WarriorSkills {
    static let all: [Skill] = HeroSkills.named(for: .knight)
}
