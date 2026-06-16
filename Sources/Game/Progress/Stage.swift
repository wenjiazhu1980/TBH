import Foundation

enum SoulStoneKind: String, CaseIterable, Codable, Identifiable {
    case normal
    case nightmare
    case hell
    case torment

    var id: String { rawValue }

    init(difficulty: Difficulty) {
        switch difficulty {
        case .normal: self = .normal
        case .nightmare: self = .nightmare
        case .hell: self = .hell
        case .torment: self = .torment
        }
    }

    var displayName: String {
        switch self {
        case .normal: return "灵魂石 - 普通"
        case .nightmare: return "灵魂石 - 噩梦"
        case .hell: return "灵魂石 - 地狱"
        case .torment: return "灵魂石 - 折磨"
        }
    }

    var materialID: Int {
        switch self {
        case .normal: return 190_001
        case .nightmare: return 190_002
        case .hell: return 190_003
        case .torment: return 190_004
        }
    }

    var rarity: Rarity {
        switch self {
        case .normal: return .immortal
        case .nightmare: return .arcana
        case .hell: return .beyond
        case .torment: return .celestial
        }
    }
}

struct SoulStoneInventory: Codable, Equatable {
    private var countsByKind: [String: Int] = [:]

    func count(for kind: SoulStoneKind) -> Int {
        countsByKind[kind.rawValue, default: 0]
    }

    mutating func grant(_ kind: SoulStoneKind, count: Int = 1) {
        guard count > 0 else { return }
        countsByKind[kind.rawValue, default: 0] += count
    }

    mutating func consume(_ kind: SoulStoneKind, count: Int = 1) -> Bool {
        guard count > 0 else { return true }
        let current = self.count(for: kind)
        guard current >= count else { return false }
        countsByKind[kind.rawValue] = current - count
        return true
    }
}

enum ChestKind: String, CaseIterable, Codable, Identifiable {
    case normal
    case nightmare
    case hell
    case torment

    var id: String { rawValue }

    init(difficulty: Difficulty) {
        switch difficulty {
        case .normal: self = .normal
        case .nightmare: self = .nightmare
        case .hell: self = .hell
        case .torment: self = .torment
        }
    }

    var sourceDifficulty: Difficulty {
        switch self {
        case .normal: return .normal
        case .nightmare: return .nightmare
        case .hell: return .hell
        case .torment: return .torment
        }
    }

    var displayName: String {
        switch self {
        case .normal: return "普通箱子"
        case .nightmare: return "噩梦箱子"
        case .hell: return "地狱箱子"
        case .torment: return "苦痛箱子"
        }
    }

    var fallbackSoulStone: SoulStoneKind {
        switch self {
        case .normal: return .normal
        case .nightmare: return .nightmare
        case .hell: return .hell
        case .torment: return .torment
        }
    }
}

enum ChestFamily: String, CaseIterable, Codable, Identifiable {
    case normalMonster
    case stageBoss
    case actBoss

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .normalMonster: return "Normal Monster Box"
        case .stageBoss: return "Stage Boss Box"
        case .actBoss: return "Act Boss Box"
        }
    }

    var rarity: Rarity {
        switch self {
        case .normalMonster: return .common
        case .stageBoss: return .rare
        case .actBoss: return .legendary
        }
    }
}

struct ChestCatalogEntry: Equatable {
    let family: ChestFamily
    let stageLevelFloor: Int?
    let catalogLevel: Int
    let databaseID: Int
    let displayName: String

    init(
        family: ChestFamily,
        stageLevelFloor: Int? = nil,
        catalogLevel: Int,
        databaseID: Int,
        displayName: String
    ) {
        self.family = family
        self.stageLevelFloor = stageLevelFloor
        self.catalogLevel = catalogLevel
        self.databaseID = databaseID
        self.displayName = displayName
    }

    var isMappedToStageRewards: Bool {
        stageLevelFloor != nil
    }
}

enum ChestCatalog {
    private static let entries: [ChestCatalogEntry] = [
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 1, catalogLevel: 1, databaseID: 910_011, displayName: "Normal Monster Box 1"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 5, catalogLevel: 5, databaseID: 910_051, displayName: "Normal Monster Box 2"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 10, catalogLevel: 10, databaseID: 910_101, displayName: "Normal Monster Box 3"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 15, catalogLevel: 15, databaseID: 910_151, displayName: "Normal Monster Box Lv15"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 20, catalogLevel: 20, databaseID: 910_201, displayName: "Normal Monster Box Lv20"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 25, catalogLevel: 25, databaseID: 910_251, displayName: "Normal Monster Box Lv25"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 30, catalogLevel: 30, databaseID: 910_301, displayName: "Normal Monster Box Lv30"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 35, catalogLevel: 35, databaseID: 910_351, displayName: "Normal Monster Box Lv35"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 40, catalogLevel: 40, databaseID: 910_401, displayName: "Normal Monster Box Lv40"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 45, catalogLevel: 45, databaseID: 910_451, displayName: "Normal Monster Box Lv45"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 50, catalogLevel: 50, databaseID: 910_501, displayName: "Normal Monster Box Lv50"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 55, catalogLevel: 55, databaseID: 910_551, displayName: "Normal Monster Box Lv55"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 60, catalogLevel: 60, databaseID: 910_601, displayName: "Normal Monster Box Lv60"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 65, catalogLevel: 65, databaseID: 910_651, displayName: "Normal Monster Box Lv65"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 70, catalogLevel: 70, databaseID: 910_701, displayName: "Normal Monster Box Lv70"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 75, catalogLevel: 75, databaseID: 910_751, displayName: "Normal Monster Box Lv75"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 80, catalogLevel: 80, databaseID: 910_801, displayName: "Normal Monster Box Lv80"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 85, catalogLevel: 85, databaseID: 910_851, displayName: "Normal Monster Box Lv85"),
        ChestCatalogEntry(family: .normalMonster, stageLevelFloor: 90, catalogLevel: 90, databaseID: 910_901, displayName: "Normal Monster Box Lv90"),

        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 1, catalogLevel: 1, databaseID: 920_001, displayName: "Stage Boss Box 1"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 3, catalogLevel: 2, databaseID: 920_002, displayName: "Stage Boss Box 2"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 5, catalogLevel: 3, databaseID: 920_003, displayName: "Stage Boss Box 3"),
        ChestCatalogEntry(family: .stageBoss, catalogLevel: 3, databaseID: 920_004, displayName: "Stage Boss Box 3"),
        ChestCatalogEntry(family: .stageBoss, catalogLevel: 3, databaseID: 920_005, displayName: "Stage Boss Box 3"),
        ChestCatalogEntry(family: .stageBoss, catalogLevel: 3, databaseID: 920_006, displayName: "Stage Boss Box 3"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 7, catalogLevel: 4, databaseID: 920_011, displayName: "Stage Boss Box 4"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 10, catalogLevel: 6, databaseID: 920_022, displayName: "Stage Boss Box 6"),
        ChestCatalogEntry(family: .stageBoss, catalogLevel: 6, databaseID: 920_032, displayName: "Stage Boss Box 6"),
        ChestCatalogEntry(family: .stageBoss, catalogLevel: 6, databaseID: 920_042, displayName: "Stage Boss Box 6"),
        ChestCatalogEntry(family: .stageBoss, catalogLevel: 5, databaseID: 920_051, displayName: "Stage Boss Box 5"),
        ChestCatalogEntry(family: .stageBoss, catalogLevel: 6, databaseID: 920_052, displayName: "Stage Boss Box 6"),
        ChestCatalogEntry(family: .stageBoss, catalogLevel: 7, databaseID: 920_101, displayName: "Stage Boss Box 7"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 15, catalogLevel: 15, databaseID: 920_151, displayName: "Stage Boss Box Lv15"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 20, catalogLevel: 20, databaseID: 920_201, displayName: "Stage Boss Box Lv20"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 25, catalogLevel: 25, databaseID: 920_251, displayName: "Stage Boss Box Lv25"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 30, catalogLevel: 30, databaseID: 920_301, displayName: "Stage Boss Box Lv30"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 35, catalogLevel: 35, databaseID: 920_351, displayName: "Stage Boss Box Lv35"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 40, catalogLevel: 40, databaseID: 920_401, displayName: "Stage Boss Box Lv40"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 45, catalogLevel: 45, databaseID: 920_451, displayName: "Stage Boss Box Lv45"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 50, catalogLevel: 50, databaseID: 920_501, displayName: "Stage Boss Box Lv50"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 55, catalogLevel: 55, databaseID: 920_551, displayName: "Stage Boss Box Lv55"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 60, catalogLevel: 60, databaseID: 920_601, displayName: "Stage Boss Box Lv60"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 65, catalogLevel: 65, databaseID: 920_651, displayName: "Stage Boss Box Lv65"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 70, catalogLevel: 70, databaseID: 920_701, displayName: "Stage Boss Box Lv70"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 75, catalogLevel: 75, databaseID: 920_751, displayName: "Stage Boss Box Lv75"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 80, catalogLevel: 80, databaseID: 920_801, displayName: "Stage Boss Box Lv80"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 85, catalogLevel: 85, databaseID: 920_851, displayName: "Stage Boss Box Lv85"),
        ChestCatalogEntry(family: .stageBoss, stageLevelFloor: 90, catalogLevel: 90, databaseID: 920_901, displayName: "Stage Boss Box Lv90"),

        ChestCatalogEntry(family: .actBoss, stageLevelFloor: 1, catalogLevel: 1, databaseID: 930_101, displayName: "Act Boss Box 1"),
        ChestCatalogEntry(family: .actBoss, stageLevelFloor: 20, catalogLevel: 20, databaseID: 930_201, displayName: "Act Boss Box Lv20"),
        ChestCatalogEntry(family: .actBoss, stageLevelFloor: 30, catalogLevel: 30, databaseID: 930_301, displayName: "Act Boss Box Lv30"),
        ChestCatalogEntry(family: .actBoss, stageLevelFloor: 40, catalogLevel: 40, databaseID: 930_401, displayName: "Act Boss Box Lv40"),
        ChestCatalogEntry(family: .actBoss, stageLevelFloor: 45, catalogLevel: 45, databaseID: 930_451, displayName: "Act Boss Box Lv45"),
        ChestCatalogEntry(family: .actBoss, stageLevelFloor: 50, catalogLevel: 50, databaseID: 930_501, displayName: "Act Boss Box Lv50"),
        ChestCatalogEntry(family: .actBoss, stageLevelFloor: 60, catalogLevel: 60, databaseID: 930_601, displayName: "Act Boss Box Lv60"),
        ChestCatalogEntry(family: .actBoss, stageLevelFloor: 65, catalogLevel: 65, databaseID: 930_651, displayName: "Act Boss Box Lv65"),
        ChestCatalogEntry(family: .actBoss, stageLevelFloor: 70, catalogLevel: 70, databaseID: 930_701, displayName: "Act Boss Box Lv70"),
        ChestCatalogEntry(family: .actBoss, stageLevelFloor: 85, catalogLevel: 85, databaseID: 930_851, displayName: "Act Boss Box Lv85"),
        ChestCatalogEntry(family: .actBoss, stageLevelFloor: 90, catalogLevel: 90, databaseID: 930_901, displayName: "Act Boss Box Lv90")
    ]

    static var entryCount: Int {
        entries.count
    }

    static func contains(databaseID: Int) -> Bool {
        entries.contains { $0.databaseID == databaseID }
    }

    static func catalogLevel(for stageLevel: Int, family: ChestFamily) -> Int {
        entry(forStageLevel: stageLevel, family: family).catalogLevel
    }

    static func databaseID(family: ChestFamily, catalogLevel: Int) -> Int {
        entry(forCatalogLevel: catalogLevel, family: family).databaseID
    }

    static func displayName(family: ChestFamily, catalogLevel: Int) -> String {
        entry(forCatalogLevel: catalogLevel, family: family).displayName
    }

    static func entry(forStageLevel stageLevel: Int, family: ChestFamily) -> ChestCatalogEntry {
        let familyEntries = entries
            .filter { $0.family == family && $0.isMappedToStageRewards }
            .sorted { ($0.stageLevelFloor ?? 0) < ($1.stageLevelFloor ?? 0) }

        return familyEntries.last { ($0.stageLevelFloor ?? Int.min) <= stageLevel } ?? familyEntries[0]
    }

    private static func entry(forCatalogLevel catalogLevel: Int, family: ChestFamily) -> ChestCatalogEntry {
        let familyEntries = entries
            .filter { $0.family == family }

        if let exactMapped = familyEntries.first(where: { $0.catalogLevel == catalogLevel && $0.isMappedToStageRewards }) {
            return exactMapped
        }

        if let exact = familyEntries.first(where: { $0.catalogLevel == catalogLevel }) {
            return exact
        }

        let stageMappedEntries = familyEntries
            .filter(\.isMappedToStageRewards)
            .sorted { ($0.stageLevelFloor ?? 0) < ($1.stageLevelFloor ?? 0) }

        return stageMappedEntries.last { ($0.stageLevelFloor ?? Int.min) <= catalogLevel } ?? stageMappedEntries[0]
    }
}

struct LootChest: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let kind: ChestKind
    let family: ChestFamily
    let itemLevel: Int
    let catalogLevel: Int
    let sourceStageCode: String
    let sourceDifficulty: Difficulty

    init(
        id: String = UUID().uuidString,
        kind: ChestKind,
        itemLevel: Int,
        sourceStageCode: String,
        sourceDifficulty: Difficulty,
        family: ChestFamily = .normalMonster,
        catalogLevel: Int? = nil
    ) {
        self.id = id
        self.kind = kind
        self.family = family
        self.itemLevel = itemLevel
        self.catalogLevel = catalogLevel ?? ChestCatalog.catalogLevel(for: itemLevel, family: family)
        self.sourceStageCode = sourceStageCode
        self.sourceDifficulty = sourceDifficulty
    }

    var displayName: String {
        ChestCatalog.displayName(family: family, catalogLevel: catalogLevel)
    }

    var databaseID: Int {
        ChestCatalog.databaseID(family: family, catalogLevel: catalogLevel)
    }

    var rarity: Rarity {
        family.rarity
    }

    /// 当前公开资料只证明 Boss 需要 Soul Stone、资料库存在四种灵魂石与关卡宝箱。
    /// 掉率和完整内容表仍缺失，因此先按箱子难度桶给对应灵魂石，避免物品等级跨难度提升石头类型。
    var soulStoneDrop: SoulStoneKind {
        return kind.fallbackSoulStone
    }
}

extension LootChest {
    private enum CodingKeys: String, CodingKey {
        case id
        case kind
        case family
        case itemLevel
        case catalogLevel
        case sourceStageCode
        case sourceDifficulty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(ChestKind.self, forKey: .kind)
        let family = try container.decodeIfPresent(ChestFamily.self, forKey: .family) ?? .normalMonster
        let itemLevel = try container.decode(Int.self, forKey: .itemLevel)
        self.init(
            id: try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString,
            kind: kind,
            itemLevel: itemLevel,
            sourceStageCode: try container.decode(String.self, forKey: .sourceStageCode),
            sourceDifficulty: try container.decodeIfPresent(Difficulty.self, forKey: .sourceDifficulty) ?? kind.sourceDifficulty,
            family: family,
            catalogLevel: try container.decodeIfPresent(Int.self, forKey: .catalogLevel)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(kind, forKey: .kind)
        try container.encode(family, forKey: .family)
        try container.encode(itemLevel, forKey: .itemLevel)
        try container.encode(catalogLevel, forKey: .catalogLevel)
        try container.encode(sourceStageCode, forKey: .sourceStageCode)
        try container.encode(sourceDifficulty, forKey: .sourceDifficulty)
    }
}

struct ChestStorageLimits: Equatable {
    static let base = ChestStorageLimits(normalMonster: 1, stageBoss: 1, actBoss: 1)
    static let unlimited = ChestStorageLimits(normalMonster: Int.max, stageBoss: Int.max, actBoss: Int.max)

    let normalMonster: Int
    let stageBoss: Int
    let actBoss: Int

    func limit(for family: ChestFamily) -> Int {
        switch family {
        case .normalMonster:
            return normalMonster
        case .stageBoss:
            return stageBoss
        case .actBoss:
            return actBoss
        }
    }
}

struct ChestInventory: Codable, Equatable {
    private(set) var chests: [LootChest] = []

    var totalCount: Int { chests.count }

    func count(for kind: ChestKind) -> Int {
        chests.filter { $0.kind == kind }.count
    }

    func first(kind: ChestKind) -> LootChest? {
        chests.first { $0.kind == kind }
    }

    func first(family: ChestFamily) -> LootChest? {
        chests.first { $0.family == family }
    }

    func first(id: String) -> LootChest? {
        chests.first { $0.id == id }
    }

    mutating func add(_ chest: LootChest) {
        chests.append(chest)
    }

    mutating func add(_ chest: LootChest, limits: ChestStorageLimits) {
        let limit = limits.limit(for: chest.family)
        guard limit > 0 else { return }

        chests.append(chest)
        while chests.filter({ $0.family == chest.family }).count > limit {
            guard let index = chests.firstIndex(where: { $0.family == chest.family }) else { break }
            chests.remove(at: index)
        }
    }

    mutating func removeFirst(kind: ChestKind) -> LootChest? {
        guard let index = chests.firstIndex(where: { $0.kind == kind }) else { return nil }
        return chests.remove(at: index)
    }

    mutating func removeFirst(family: ChestFamily) -> LootChest? {
        guard let index = chests.firstIndex(where: { $0.family == family }) else { return nil }
        return chests.remove(at: index)
    }

    mutating func remove(id: String) -> LootChest? {
        guard let index = chests.firstIndex(where: { $0.id == id }) else { return nil }
        return chests.remove(at: index)
    }
}

struct StageRuntimeData: Equatable {
    let code: String
    let difficulty: Difficulty
    let level: Int
    let waves: Int
    let killsRequired: Int
    let goldReward: Int
    let xpReward: Int
    let hp: Int
    let monsterName: String
    let monsterComposition: [StageMonsterSpawn]

    var isBoss: Bool { killsRequired == 0 }
}

struct StageMonsterSpawn: Equatable {
    let name: String
    let count: Int
    let isStageLeader: Bool
}

struct StageEncounterState: Equatable {
    let encounterIndex: Int
    let encounterNumber: Int
    let clearTarget: Int
    let wave: Int
    let waveCount: Int
    let waveEncounterNumber: Int
    let waveEncounterTarget: Int
    let compositionIndex: Int
    let compositionTotal: Int
    let monsterSpawn: StageMonsterSpawn
}

struct StageEncounterPlan: Equatable {
    let difficulty: Difficulty
    let clearTarget: Int
    let waveCount: Int
    let encounters: [StageEncounterState]

    func encounters(inWave wave: Int) -> [StageEncounterState] {
        encounters.filter { $0.wave == wave }
    }
}

/// 原版关卡骨架：3 个 Act，每个 Act 10 关。详细掉落/金币/经验表后续再数据化。
struct StageDefinition: Identifiable, Codable, Equatable {
    static let stagesPerAct = 10
    static let defaultClearsPerStage = 10

    let act: Chapter
    let number: Int
    let name: String
    let recommendedLevel: Int
    let bossName: String?

    var id: String { "\(act.rawValue)-\(number)" }
    var displayCode: String { "\(act.rawValue)-\(number)" }
    var displayName: String { "\(displayCode) \(name)" }
    var isBoss: Bool { bossName != nil }
    var clearTarget: Int { clearTarget(for: .normal) }

    func clearTarget(for difficulty: Difficulty) -> Int {
        let killsRequired = runtimeData(for: difficulty).killsRequired
        return isBoss ? 1 : max(1, killsRequired)
    }

    func runtimeData(for difficulty: Difficulty) -> StageRuntimeData {
        Self.runtimeDataByCode[Self.stageCode(difficulty: difficulty, act: act, number: number)]
            ?? StageRuntimeData(
                code: Self.stageCode(difficulty: difficulty, act: act, number: number),
                difficulty: difficulty,
                level: recommendedLevel,
                waves: isBoss ? 0 : Self.defaultClearsPerStage,
                killsRequired: isBoss ? 0 : Self.defaultClearsPerStage,
                goldReward: 120 + recommendedLevel * 20 + (isBoss ? 140 : 0),
                xpReward: 140 + recommendedLevel * 24 + (isBoss ? 180 : 0),
                hp: bossHP(for: difficulty) ?? max(1, recommendedLevel * 120),
                monsterName: bossName ?? "绿色史莱姆",
                monsterComposition: [
                    StageMonsterSpawn(
                        name: bossName ?? "绿色史莱姆",
                        count: isBoss ? 1 : Self.defaultClearsPerStage,
                        isStageLeader: isBoss
                    )
                ]
            )
    }

    func requiredSoulStone(for difficulty: Difficulty) -> SoulStoneKind? {
        isBoss ? SoulStoneKind(difficulty: difficulty) : nil
    }

    func chestSources(for difficulty: Difficulty) -> [LootChest] {
        let runtime = runtimeData(for: difficulty)
        let families: [ChestFamily] = isBoss ? [.normalMonster, .actBoss] : [.normalMonster, .stageBoss]

        return families.map { family in
            LootChest(
                kind: ChestKind(difficulty: difficulty),
                itemLevel: itemLevelCap(for: difficulty),
                sourceStageCode: displayCode,
                sourceDifficulty: difficulty,
                family: family,
                catalogLevel: ChestCatalog.catalogLevel(for: runtime.level, family: family)
            )
        }
    }

    func chestRewards(for difficulty: Difficulty) -> [LootChest] {
        chestSources(for: difficulty)
    }

    func chestReward(for difficulty: Difficulty) -> LootChest? {
        chestRewards(for: difficulty).first
    }

    func itemLevelCap(for difficulty: Difficulty) -> Int {
        let current = Self.progressionSortValue(difficulty: difficulty, act: act, stageNumber: number)
        return Self.itemLevelThresholds
            .filter { $0.sortValue <= current }
            .max(by: { $0.sortValue < $1.sortValue })?
            .itemLevel ?? recommendedLevel
    }

    func baseGoldPerClear(for difficulty: Difficulty) -> Int {
        runtimeData(for: difficulty).goldReward
    }

    var baseGoldPerClear: Int {
        baseGoldPerClear(for: .normal)
    }

    func baseXPPerClear(for difficulty: Difficulty) -> Int {
        runtimeData(for: difficulty).xpReward
    }

    var baseXPPerClear: Int {
        baseXPPerClear(for: .normal)
    }

    /// 平均清一次战斗的时间，用于离线收益估算。
    func avgClearTime(for difficulty: Difficulty) -> TimeInterval {
        let data = runtimeData(for: difficulty)
        if isBoss { return 16.0 }
        return 5.0 + Double(max(data.waves, 1)) * 0.45
    }

    var avgClearTime: TimeInterval {
        avgClearTime(for: .normal)
    }

    func monsterSpawn(for difficulty: Difficulty, encounterIndex: Int) -> StageMonsterSpawn {
        encounterState(for: difficulty, encounterIndex: encounterIndex).monsterSpawn
    }

    func encounterPlan(for difficulty: Difficulty) -> StageEncounterPlan {
        let target = clearTarget(for: difficulty)
        let encounters = (0..<target).map {
            encounterState(for: difficulty, encounterIndex: $0)
        }
        return StageEncounterPlan(
            difficulty: difficulty,
            clearTarget: max(target, 1),
            waveCount: isBoss ? 1 : max(runtimeData(for: difficulty).waves, 1),
            encounters: encounters
        )
    }

    func encounterState(for difficulty: Difficulty, encounterIndex: Int) -> StageEncounterState {
        let data = runtimeData(for: difficulty)
        let target = clearTarget(for: difficulty)
        let clampedTarget = max(target, 1)
        let clampedIndex = min(max(0, encounterIndex), clampedTarget - 1)
        let waveCount = isBoss ? 1 : max(data.waves, 1)
        let wave = min(waveCount, (clampedIndex * waveCount / clampedTarget) + 1)
        let waveStartIndex = (wave - 1) * clampedTarget / waveCount
        let waveEndIndex = max(waveStartIndex + 1, wave * clampedTarget / waveCount)
        let waveEncounterTarget = waveEndIndex - waveStartIndex
        let composition = runtimeData(for: difficulty).monsterComposition
        let compositionTotal = composition.reduce(0) { $0 + max(1, $1.count) }
        let compositionIndex = compositionTotal > 0
            ? min(compositionTotal - 1, clampedIndex * compositionTotal / clampedTarget)
            : 0

        return StageEncounterState(
            encounterIndex: clampedIndex,
            encounterNumber: clampedIndex + 1,
            clearTarget: clampedTarget,
            wave: wave,
            waveCount: waveCount,
            waveEncounterNumber: clampedIndex - waveStartIndex + 1,
            waveEncounterTarget: waveEncounterTarget,
            compositionIndex: compositionIndex,
            compositionTotal: compositionTotal,
            monsterSpawn: monsterSpawn(from: composition, compositionIndex: compositionIndex)
        )
    }

    private func monsterSpawn(from composition: [StageMonsterSpawn], compositionIndex: Int) -> StageMonsterSpawn {
        guard let first = composition.first else {
            return StageMonsterSpawn(name: bossName ?? "绿色史莱姆", count: 1, isStageLeader: isBoss)
        }

        let index = max(0, compositionIndex)
        var lowerBound = 0
        for spawn in composition {
            let upperBound = lowerBound + max(1, spawn.count)
            if index < upperBound {
                return spawn
            }
            lowerBound = upperBound
        }

        return composition.last ?? first
    }

    static let all: [StageDefinition] = [
        StageDefinition(act: .forest, number: 1, name: "牧场", recommendedLevel: 1, bossName: nil),
        StageDefinition(act: .forest, number: 2, name: "阴影草原", recommendedLevel: 2, bossName: nil),
        StageDefinition(act: .forest, number: 3, name: "荒野", recommendedLevel: 3, bossName: nil),
        StageDefinition(act: .forest, number: 4, name: "阴森峡谷", recommendedLevel: 5, bossName: nil),
        StageDefinition(act: .forest, number: 5, name: "燃烧村庄入口", recommendedLevel: 6, bossName: nil),
        StageDefinition(act: .forest, number: 6, name: "朗姆街广场", recommendedLevel: 7, bossName: nil),
        StageDefinition(act: .forest, number: 7, name: "城市外围", recommendedLevel: 8, bossName: nil),
        StageDefinition(act: .forest, number: 8, name: "公墓", recommendedLevel: 10, bossName: nil),
        StageDefinition(act: .forest, number: 9, name: "诅咒之地", recommendedLevel: 11, bossName: nil),
        StageDefinition(act: .forest, number: 10, name: "黑暗王座", recommendedLevel: 12, bossName: "骷髅王"),

        StageDefinition(act: .dungeon, number: 1, name: "绿洲路", recommendedLevel: 13, bossName: nil),
        StageDefinition(act: .dungeon, number: 2, name: "沙风暴谷", recommendedLevel: 14, bossName: nil),
        StageDefinition(act: .dungeon, number: 3, name: "沙漠地下洞窟", recommendedLevel: 15, bossName: nil),
        StageDefinition(act: .dungeon, number: 4, name: "虫巢", recommendedLevel: 16, bossName: nil),
        StageDefinition(act: .dungeon, number: 5, name: "炽热沙丘", recommendedLevel: 17, bossName: nil),
        StageDefinition(act: .dungeon, number: 6, name: "夕阳废墟", recommendedLevel: 18, bossName: nil),
        StageDefinition(act: .dungeon, number: 7, name: "午夜沙漠", recommendedLevel: 19, bossName: nil),
        StageDefinition(act: .dungeon, number: 8, name: "神圣墓穴", recommendedLevel: 20, bossName: nil),
        StageDefinition(act: .dungeon, number: 9, name: "法老陵墓", recommendedLevel: 21, bossName: nil),
        StageDefinition(act: .dungeon, number: 10, name: "法老地下水道", recommendedLevel: 22, bossName: "沙漠的支配者"),

        StageDefinition(act: .volcano, number: 1, name: "雪原前哨", recommendedLevel: 23, bossName: nil),
        StageDefinition(act: .volcano, number: 2, name: "冰封战场", recommendedLevel: 24, bossName: nil),
        StageDefinition(act: .volcano, number: 3, name: "冰川洞窟入口", recommendedLevel: 25, bossName: nil),
        StageDefinition(act: .volcano, number: 4, name: "冰川洞窟深处", recommendedLevel: 26, bossName: nil),
        StageDefinition(act: .volcano, number: 5, name: "地狱之门", recommendedLevel: 27, bossName: nil),
        StageDefinition(act: .volcano, number: 6, name: "燃烧峡谷", recommendedLevel: 28, bossName: nil),
        StageDefinition(act: .volcano, number: 7, name: "痛苦平原", recommendedLevel: 29, bossName: nil),
        StageDefinition(act: .volcano, number: 8, name: "毁灭要塞", recommendedLevel: 30, bossName: nil),
        StageDefinition(act: .volcano, number: 9, name: "深渊之核", recommendedLevel: 31, bossName: nil),
        StageDefinition(act: .volcano, number: 10, name: "地狱指挥室", recommendedLevel: 32, bossName: "执政官莫尔卡")
    ]

    private struct ItemLevelThreshold {
        let difficulty: Difficulty
        let act: Chapter
        let stageNumber: Int
        let itemLevel: Int

        var sortValue: Int {
            StageDefinition.progressionSortValue(difficulty: difficulty, act: act, stageNumber: stageNumber)
        }
    }

    private static let itemLevelThresholds: [ItemLevelThreshold] = [
        ItemLevelThreshold(difficulty: .normal, act: .forest, stageNumber: 1, itemLevel: 1),
        ItemLevelThreshold(difficulty: .normal, act: .forest, stageNumber: 4, itemLevel: 5),
        ItemLevelThreshold(difficulty: .normal, act: .forest, stageNumber: 8, itemLevel: 10),
        ItemLevelThreshold(difficulty: .normal, act: .dungeon, stageNumber: 3, itemLevel: 15),
        ItemLevelThreshold(difficulty: .normal, act: .dungeon, stageNumber: 8, itemLevel: 20),
        ItemLevelThreshold(difficulty: .normal, act: .volcano, stageNumber: 2, itemLevel: 25),
        ItemLevelThreshold(difficulty: .normal, act: .volcano, stageNumber: 8, itemLevel: 30),
        ItemLevelThreshold(difficulty: .nightmare, act: .forest, stageNumber: 3, itemLevel: 35),
        ItemLevelThreshold(difficulty: .nightmare, act: .volcano, stageNumber: 9, itemLevel: 50)
    ]

    private static func progressionSortValue(difficulty: Difficulty, act: Chapter, stageNumber: Int) -> Int {
        difficulty.rawValue * 1_000 + act.rawValue * 100 + stageNumber
    }

    static func stage(act: Chapter, number: Int) -> StageDefinition {
        all.first { $0.act == act && $0.number == number } ?? all[0]
    }

    static var runtimeDataCount: Int { runtimeDataByCode.count }

    private static let runtimeDataByCode: [String: StageRuntimeData] = {
        var result: [String: StageRuntimeData] = [:]
        for rawLine in minedStageTSV.split(separator: "\n") {
            let columns = rawLine
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: "\t", omittingEmptySubsequences: false)
            guard columns.count >= 8,
                  let difficulty = difficulty(from: String(columns[1])),
                  let level = Int(columns[2]),
                  let waves = Int(columns[3]),
                  let killsRequired = Int(columns[4]),
                  let goldReward = Int(columns[5]),
                  let xpReward = Int(columns[6]) else {
                continue
            }

            let code = String(columns[0])
            let hp: Int
            let monsterColumn: Int
            if columns.count >= 9, let minedHP = Int(columns[7]) {
                hp = minedHP
                monsterColumn = 8
            } else {
                hp = 1
                monsterColumn = 7
            }

            result[code] = StageRuntimeData(
                code: code,
                difficulty: difficulty,
                level: level,
                waves: waves,
                killsRequired: killsRequired,
                goldReward: goldReward,
                xpReward: xpReward,
                hp: hp,
                monsterName: String(columns[monsterColumn]),
                monsterComposition: monsterCompositionByCode[code] ?? []
            )
        }
        return result
    }()

    private static let monsterCompositionByCode: [String: [StageMonsterSpawn]] = {
        var result: [String: [StageMonsterSpawn]] = [:]
        for rawLine in minedStageCompositionTSV.split(separator: "\n") {
            let columns = rawLine
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: "\t", omittingEmptySubsequences: false)
            guard columns.count == 2 else { continue }

            let entries = columns[1]
                .split(separator: "|", omittingEmptySubsequences: false)
                .compactMap { entry -> StageMonsterSpawn? in
                    let parts = entry.split(separator: ":", omittingEmptySubsequences: false)
                    guard parts.count == 3, let count = Int(parts[1]) else { return nil }
                    return StageMonsterSpawn(
                        name: String(parts[0]),
                        count: count,
                        isStageLeader: parts[2] == "1"
                    )
                }

            result[String(columns[0])] = entries
        }
        return result
    }()

    private static func stageCode(difficulty: Difficulty, act: Chapter, number: Int) -> String {
        String(format: "%d%d%02d", difficulty.rawValue, act.rawValue, number)
    }

    private static func difficulty(from code: String) -> Difficulty? {
        switch code {
        case "NORMAL": return .normal
        case "NIGHTMARE": return .nightmare
        case "HELL": return .hell
        case "TORMENT": return .torment
        default: return nil
        }
    }

    private static let minedStageCompositionTSV = """
    1101	哥布林盗贼:1:1|史莱姆:5:0|哥布林:5:0
    1102	哥布林萨满:1:1|史莱姆:7:0|哥布林:7:0|哥布林盗贼:7:0
    1103	兽人:1:1|哥布林:9:0|哥布林盗贼:9:0|蝙蝠:9:0
    1104	兽人战士:1:1|史莱姆:9:0|哥布林:9:0|兽人:9:0
    1105	精英兽人:1:1|哥布林:10:0|哥布林盗贼:10:0|哥布林萨满:10:0
    1106	骷髅:1:1|史莱姆:17:0|兽人:17:0|兽人战士:17:0
    1107	骷髅战士:1:1|蝙蝠:27:0|骷髅:27:0|骷髅弓箭手:19:0
    1108	蝙蝠:24:0|骷髅:24:0|骷髅弓箭手:17:0|骷髅战士:12:0
    1109	蝙蝠:19:0|兽人战士:19:0|骷髅:19:0|骷髅弓箭手:13:0
    1110	骷髅王:1:1
    1201	鼠族狂战士:1:1|蝎子:33:0|鼠族战士:33:0|鼠族弓手:33:0
    1202	蝎子:24:0|鼠族战士:24:0|鼠族弓手:24:0|鼠族狂战士:24:0
    1203	蝎子:29:0|瘟疫鼠:29:0|眼镜蛇:29:0|蝙蝠:9:0
    1204	蝎子:25:0|瘟疫鼠:25:0|眼镜蛇:25:0|巨蝇:25:0
    1205	人造人:1:1|巨蝇:42:0|蝎子:21:0|鼠族战士:21:0
    1206	食尸鬼:1:1|鼠族狂战士:30:0|眼镜蛇:30:0|狗头人卫兵:30:0
    1207	人造人:39:0|瘟疫鼠:28:0|骷髅弓箭手:22:0|蝎子:20:0
    1208	狗头人卫兵:30:0|狗头人投石手:30:0|人造人:30:0|火元素:6:0
    1209	狗头人卫兵:26:0|狗头人投石手:26:0|木乃伊:26:0|食尸鬼:13:0
    1210	沙漠的支配者:1:1
    1301	鼠族狂战士:1:1|小鬼:58:0|地精灵:41:0|堕落天使的头盔:29:0
    1302	鼠族战士:1:1|小鬼:38:0|雪山战士:38:0|地精灵:26:0
    1303	眼镜蛇:1:1|堕落天使的头盔:53:0|雪山战士:53:0|雪山弓手:37:0
    1304	毒虫:1:1|雪山战士:37:0|雪山卫兵:37:0|幽灵:37:0
    1305	人造人:1:1|小鬼:38:0|地精灵:38:0|雪山卫兵:38:0
    1306	食尸鬼:1:1|恶魔士兵:51:0|地狱魔像:51:0|熔岩人:26:0
    1307	瘟疫鼠:1:1|恶魔士兵:64:0|燃烧小猪:38:0|恶魔突击兵:32:0
    1308	狗头人卫兵:1:1|恶魔突击兵:71:0|死亡之指:49:0|幽灵:35:0
    1309	木乃伊:1:1|恶魔士兵:47:0|恶魔突击兵:47:0|死亡之指:47:0
    1310	执政官莫尔卡:1:1
    2101	鼠族狂战士:1:1|史莱姆:67:0|哥布林:67:0|哥布林盗贼:67:0
    2102	鼠族战士:1:1|史莱姆:50:0|哥布林:50:0|哥布林盗贼:50:0
    2103	眼镜蛇:1:1|哥布林:55:0|哥布林盗贼:55:0|哥布林萨满:55:0
    2104	毒虫:1:1|史莱姆:58:0|哥布林:58:0|哥布林萨满:58:0
    2105	人造人:1:1|哥布林:50:0|哥布林盗贼:50:0|哥布林萨满:50:0
    2106	食尸鬼:1:1|史莱姆:70:0|兽人:70:0|兽人战士:70:0
    2107	瘟疫鼠:1:1|蝙蝠:101:0|骷髅:101:0|骷髅弓箭手:71:0
    2108	狗头人卫兵:1:1|蝙蝠:85:0|骷髅:85:0|骷髅弓箭手:60:0
    2109	木乃伊:1:1|蝙蝠:60:0|兽人战士:60:0|骷髅:60:0
    2110	骷髅王:1:1
    2201	鼠族狂战士:1:1|蝎子:95:0|鼠族战士:95:0|鼠族弓手:95:0
    2202	蝎子:72:0|鼠族战士:72:0|鼠族弓手:72:0|鼠族狂战士:72:0
    2203	蝎子:79:0|瘟疫鼠:79:0|眼镜蛇:79:0|蝙蝠:24:0
    2204	蝎子:65:0|瘟疫鼠:65:0|眼镜蛇:65:0|巨蝇:65:0
    2205	人造人:1:1|巨蝇:114:0|蝎子:57:0|鼠族战士:57:0
    2206	食尸鬼:1:1|鼠族狂战士:72:0|眼镜蛇:72:0|狗头人卫兵:72:0
    2207	蝎子:87:0|人造人:87:0|瘟疫鼠:61:0|骷髅弓箭手:48:0
    2208	狗头人卫兵:64:0|狗头人投石手:64:0|人造人:64:0|火元素:51:0
    2209	狗头人卫兵:61:0|狗头人投石手:61:0|木乃伊:61:0|火元素:49:0
    2210	沙漠的支配者:1:1
    2301	鼠族狂战士:1:1|小鬼:129:0|地精灵:129:0|堕落天使的头盔:64:0
    2302	鼠族战士:1:1|小鬼:72:0|地精灵:72:0|雪人:72:0
    2303	眼镜蛇:1:1|堕落天使的头盔:101:0|雪山战士:101:0|雪山弓手:70:0
    2304	毒虫:1:1|雪山战士:73:0|雪山卫兵:73:0|幽灵:73:0
    2305	人造人:1:1|小鬼:69:0|地精灵:69:0|雪山卫兵:69:0
    2306	食尸鬼:1:1|熔岩人:85:0|恶魔士兵:85:0|地狱魔像:85:0
    2307	瘟疫鼠:1:1|恶魔士兵:99:0|幼龙:69:0|恶魔军团长:69:0
    2308	狗头人卫兵:1:1|恶魔突击兵:96:0|死亡之指:96:0|燃烧的地狱祭司:67:0
    2309	木乃伊:1:1|燃烧小猪:91:0|死亡之指:91:0|幽灵:64:0
    2310	执政官莫尔卡:1:1
    3101	鼠族狂战士:1:1|史莱姆:120:0|哥布林:120:0|哥布林盗贼:120:0
    3102	鼠族战士:1:1|史莱姆:90:0|哥布林:90:0|哥布林盗贼:90:0
    3103	眼镜蛇:1:1|哥布林:94:0|哥布林盗贼:94:0|哥布林萨满:94:0
    3104	毒虫:1:1|史莱姆:94:0|哥布林:94:0|哥布林萨满:94:0
    3105	人造人:1:1|哥布林:75:0|哥布林盗贼:75:0|哥布林萨满:75:0
    3106	食尸鬼:1:1|史莱姆:104:0|兽人:104:0|兽人战士:104:0
    3107	瘟疫鼠:1:1|蝙蝠:148:0|骷髅:148:0|骷髅弓箭手:104:0
    3108	狗头人卫兵:1:1|蝙蝠:125:0|骷髅:125:0|骷髅弓箭手:88:0
    3109	木乃伊:1:1|蝙蝠:83:0|兽人战士:83:0|骷髅:83:0
    3110	骷髅王:1:1
    3201	鼠族狂战士:1:1|蝎子:139:0|鼠族战士:139:0|鼠族弓手:139:0
    3202	蝎子:104:0|鼠族战士:104:0|鼠族弓手:104:0|鼠族狂战士:104:0
    3203	蝎子:104:0|瘟疫鼠:104:0|眼镜蛇:104:0|毒虫:73:0
    3204	蝎子:78:0|瘟疫鼠:78:0|眼镜蛇:78:0|巨蝇:78:0
    3205	人造人:1:1|巨蝇:160:0|蝎子:80:0|鼠族战士:80:0
    3206	食尸鬼:1:1|鼠族狂战士:97:0|眼镜蛇:97:0|狗头人卫兵:97:0
    3207	蝎子:109:0|人造人:109:0|瘟疫鼠:76:0|骷髅弓箭手:60:0
    3208	狗头人卫兵:79:0|狗头人投石手:79:0|人造人:79:0|火元素:79:0
    3209	狗头人卫兵:80:0|狗头人投石手:80:0|火元素:80:0|木乃伊:80:0
    3210	沙漠的支配者:1:1
    3301	鼠族狂战士:1:1|小鬼:209:0|地精灵:146:0|堕落天使的头盔:104:0
    3302	鼠族战士:1:1|小鬼:109:0|雪人:109:0|雪山战士:109:0
    3303	眼镜蛇:1:1|堕落天使的头盔:135:0|雪山战士:135:0|雪山弓手:94:0
    3304	毒虫:1:1|雪山战士:100:0|雪山卫兵:100:0|幽灵:100:0
    3305	人造人:1:1|小鬼:94:0|地精灵:94:0|雪山卫兵:94:0
    3306	食尸鬼:1:1|熔岩人:131:0|地狱魔像:131:0|恶魔士兵:92:0
    3307	瘟疫鼠:1:1|血之祭司:108:0|恶魔士兵:108:0|幼龙:76:0
    3308	狗头人卫兵:1:1|恶魔突击兵:113:0|燃烧的地狱祭司:79:0|冰冻的地狱祭司:79:0
    3309	木乃伊:1:1|死亡之指:113:0|幽灵:79:0|燃烧的地狱祭司:79:0
    3310	执政官莫尔卡:1:1
    4101	鼠族狂战士:1:1|史莱姆:174:0|哥布林:174:0|哥布林盗贼:174:0
    4102	鼠族战士:1:1|史莱姆:130:0|哥布林:130:0|哥布林盗贼:130:0
    4103	眼镜蛇:1:1|哥布林:130:0|哥布林盗贼:130:0|哥布林萨满:130:0
    4104	毒虫:1:1|史莱姆:130:0|哥布林:130:0|哥布林萨满:130:0
    4105	人造人:1:1|哥布林:104:0|哥布林盗贼:104:0|哥布林萨满:104:0
    4106	食尸鬼:1:1|史莱姆:145:0|兽人:145:0|兽人战士:145:0
    4107	瘟疫鼠:1:1|蝙蝠:204:0|骷髅:204:0|骷髅弓箭手:143:0
    4108	狗头人卫兵:1:1|蝙蝠:172:0|骷髅:172:0|骷髅弓箭手:121:0
    4109	木乃伊:1:1|蝙蝠:115:0|兽人战士:115:0|骷髅:115:0
    4110	骷髅王:1:1
    4201	鼠族狂战士:1:1|蝎子:190:0|鼠族战士:190:0|鼠族弓手:190:0
    4202	蝎子:142:0|鼠族战士:142:0|鼠族弓手:142:0|鼠族狂战士:142:0
    4203	蝎子:133:0|瘟疫鼠:133:0|眼镜蛇:133:0|毒虫:133:0
    4204	蝎子:104:0|瘟疫鼠:104:0|眼镜蛇:104:0|毒虫:104:0
    4205	人造人:1:1|巨蝇:228:0|蝎子:114:0|鼠族战士:114:0
    4206	食尸鬼:1:1|鼠族狂战士:142:0|眼镜蛇:142:0|狗头人卫兵:142:0
    4207	蝎子:148:0|人造人:148:0|瘟疫鼠:104:0|骷髅弓箭手:81:0
    4208	狗头人卫兵:120:0|狗头人投石手:120:0|人造人:120:0|火元素:120:0
    4209	狗头人卫兵:109:0|狗头人投石手:109:0|火元素:109:0|木乃伊:109:0
    4210	沙漠的支配者:1:1
    4301	鼠族狂战士:1:1|小鬼:282:0|地精灵:197:0|堕落天使的头盔:141:0
    4302	鼠族战士:1:1|小鬼:148:0|雪人:148:0|雪山战士:148:0
    4303	眼镜蛇:1:1|堕落天使的头盔:141:0|雪山战士:141:0|冰冻的地狱祭司:141:0
    4304	毒虫:1:1|雪山战士:135:0|雪山卫兵:135:0|幽灵:135:0
    4305	人造人:1:1|小鬼:119:0|幼龙:119:0|雪山卫兵:119:0
    4306	食尸鬼:1:1|熔岩人:138:0|地狱魔像:138:0|电流的地狱祭司:138:0
    4307	瘟疫鼠:1:1|血之祭司:136:0|恶魔士兵:136:0|混沌的地狱祭司:136:0
    4308	狗头人卫兵:1:1|恶魔突击兵:125:0|燃烧的地狱祭司:125:0|冰冻的地狱祭司:125:0
    4309	木乃伊:1:1|冰冻的地狱祭司:125:0|电流的地狱祭司:125:0|混沌的地狱祭司:125:0
    4310	执政官莫尔卡:1:1
    """

    private static let minedStageTSV = """
    1101	NORMAL	1	10	10	140	155	470	哥布林盗贼
    1102	NORMAL	2	11	22	493	463	940	哥布林萨满
    1103	NORMAL	3	11	33	989	788	1100	兽人
    1104	NORMAL	5	12	36	1963	2985	1685	兽人战士
    1105	NORMAL	6	12	48	3394	7406	2885	精英兽人
    1106	NORMAL	7	12	60	4652	11697	5470	骷髅
    1107	NORMAL	8	12	72	3561	15111	2510	骷髅战士
    1108	NORMAL	10	13	78	5789	26944	3235	骷髅弓箭手
    1109	NORMAL	11	13	91	10062	59774	6340	精英兽人
    1110	NORMAL	12	0	0	3250	1332	1050	骷髅王
    1201	NORMAL	13	14	98	9084	74376	4365	鼠族狂战士
    1202	NORMAL	14	14	98	12140	100241	4920	鼠族战士
    1203	NORMAL	15	14	98	12646	117332	6505	眼镜蛇
    1204	NORMAL	16	15	105	14411	151304	6725	毒虫
    1205	NORMAL	17	15	105	13449	153438	4735	人造人
    1206	NORMAL	18	15	120	25926	352425	10275	食尸鬼
    1207	NORMAL	19	15	120	26425	355572	12035	瘟疫鼠
    1208	NORMAL	20	16	128	21598	305664	9000	狗头人卫兵
    1209	NORMAL	21	16	128	38947	585839	14855	木乃伊
    1210	NORMAL	22	0	0	8500	2808	1850	沙漠的支配者
    1301	NORMAL	23	16	128	29411	500529	7345	鼠族狂战士
    1302	NORMAL	24	16	128	31231	448253	10735	鼠族战士
    1303	NORMAL	25	17	153	43001	563205	13055	眼镜蛇
    1304	NORMAL	26	17	153	45915	594284	18135	毒虫
    1305	NORMAL	27	17	153	46264	698314	14245	人造人
    1306	NORMAL	28	17	153	91197	1763440	17280	食尸鬼
    1307	NORMAL	29	17	170	96030	1712640	15695	瘟疫鼠
    1308	NORMAL	30	18	180	160450	2798687	14315	狗头人卫兵
    1309	NORMAL	31	18	198	160704	2969200	15260	木乃伊
    1310	NORMAL	32	0	0	18750	644	2550	执政官莫尔卡
    2101	NIGHTMARE	33	20	200	101840	1819483	8785	鼠族狂战士
    2102	NIGHTMARE	34	20	200	123542	2191500	8035	鼠族战士
    2103	NIGHTMARE	35	20	220	144997	2377700	6930	眼镜蛇
    2104	NIGHTMARE	35	21	231	152144	2725690	10485	毒虫
    2105	NIGHTMARE	36	21	252	202381	3638131	13615	人造人
    2106	NIGHTMARE	37	21	252	245109	4523405	22695	食尸鬼
    2107	NIGHTMARE	38	21	273	152185	2618176	9160	瘟疫鼠
    2108	NIGHTMARE	39	21	273	209817	3695671	11585	狗头人卫兵
    2109	NIGHTMARE	40	22	286	307355	5588890	20690	木乃伊
    2110	NIGHTMARE	40	0	0	30550	13392	2350	骷髅王
    2201	NIGHTMARE	41	22	286	232169	4349786	12425	鼠族狂战士
    2202	NIGHTMARE	41	22	286	288250	5333920	14760	鼠族战士
    2203	NIGHTMARE	42	22	286	286709	5194845	18425	眼镜蛇
    2204	NIGHTMARE	42	22	286	276829	5161492	18070	毒虫
    2205	NIGHTMARE	43	22	286	244463	4578413	12655	人造人
    2206	NIGHTMARE	43	22	286	368024	6994650	24345	食尸鬼
    2207	NIGHTMARE	44	22	308	370977	7181899	28595	瘟疫鼠
    2208	NIGHTMARE	44	22	308	305171	5745382	22065	狗头人卫兵
    2209	NIGHTMARE	45	23	322	496956	9406111	36655	木乃伊
    2210	NIGHTMARE	45	0	0	39550	20664	1950	沙漠的支配者
    2301	NIGHTMARE	46	23	322	321592	6137678	18115	鼠族狂战士
    2302	NIGHTMARE	47	23	322	373169	6483513	39635	鼠族战士
    2303	NIGHTMARE	48	23	322	361045	5152273	26135	眼镜蛇
    2304	NIGHTMARE	49	23	322	373640	5163948	36735	毒虫
    2305	NIGHTMARE	50	23	322	362459	5643708	31765	人造人
    2306	NIGHTMARE	50	23	322	637872	12733401	32915	食尸鬼
    2307	NIGHTMARE	51	23	345	590366	11246411	33120	瘟疫鼠
    2308	NIGHTMARE	51	23	345	1006894	19212300	28065	狗头人卫兵
    2309	NIGHTMARE	52	23	345	1029458	19768579	29750	木乃伊
    2310	NIGHTMARE	52	0	0	54250	2064	2750	执政官莫尔卡
    3101	HELL	53	24	360	510062	9886467	15675	鼠族狂战士
    3102	HELL	54	24	360	608592	11704500	14435	鼠族战士
    3103	HELL	55	25	375	660642	11647890	11805	眼镜蛇
    3104	HELL	56	25	375	687017	13280085	16965	毒虫
    3105	HELL	57	25	375	820116	15844032	20365	人造人
    3106	HELL	58	25	375	965694	18927169	33535	食尸鬼
    3107	HELL	59	25	400	579197	10545700	13370	瘟疫鼠
    3108	HELL	59	25	400	756127	14051400	16875	狗头人卫兵
    3109	HELL	60	25	400	1036725	19798934	28600	木乃伊
    3110	HELL	60	0	0	74050	51408	2350	骷髅王
    3201	HELL	61	26	416	798215	15636689	18145	鼠族狂战士
    3202	HELL	62	26	416	1030956	20042480	21320	鼠族战士
    3203	HELL	63	26	416	1008833	19173348	26110	眼镜蛇
    3204	HELL	64	26	416	1150912	22452619	26040	毒虫
    3205	HELL	65	26	416	879308	17189804	18435	人造人
    3206	HELL	66	26	416	1338930	26475880	34025	食尸鬼
    3207	HELL	67	26	442	1518309	30388301	39995	瘟疫鼠
    3208	HELL	68	26	442	1360066	26651748	31965	狗头人卫兵
    3209	HELL	69	26	442	1734058	34114415	49400	木乃伊
    3210	HELL	69	0	0	100150	120900	2050	沙漠的支配者
    3301	HELL	70	27	459	1131703	22355931	26165	鼠族狂战士
    3302	HELL	71	27	459	1308849	23406216	58355	鼠族战士
    3303	HELL	72	27	459	1224860	17738652	36565	眼镜蛇
    3304	HELL	73	27	459	1249877	17565656	51495	毒虫
    3305	HELL	74	27	459	1197666	18896159	44390	人造人
    3306	HELL	75	27	459	2265967	46302371	47985	食尸鬼
    3307	HELL	76	27	486	2462338	48265278	49900	瘟疫鼠
    3308	HELL	76	27	486	3401712	66816935	41615	狗头人卫兵
    3309	HELL	77	27	486	3421275	67442443	39530	木乃伊
    3310	HELL	77	0	0	126750	4964	3050	执政官莫尔卡
    4101	TORMENT	78	29	522	1695575	33605456	22695	鼠族狂战士
    4102	TORMENT	79	29	522	2001724	39430125	20835	鼠族战士
    4103	TORMENT	80	29	522	2058618	37102896	16305	眼镜蛇
    4104	TORMENT	81	29	522	2114156	41738004	23445	毒虫
    4105	TORMENT	82	29	522	2493942	49189327	28195	人造人
    4106	TORMENT	83	29	522	2891574	57590758	46770	食尸鬼
    4107	TORMENT	84	29	551	1698839	31422822	18375	瘟疫鼠
    4108	TORMENT	84	29	551	2220938	41999814	23245	狗头人卫兵
    4109	TORMENT	85	29	551	3008395	58367689	39355	木乃伊
    4110	TORMENT	85	0	0	156550	92340	2350	骷髅王
    4201	TORMENT	86	30	570	2278448	45290133	24775	鼠族狂战士
    4202	TORMENT	86	30	570	2847591	56238798	29110	鼠族战士
    4203	TORMENT	87	30	570	2767745	53462939	35180	眼镜蛇
    4204	TORMENT	87	30	570	3035351	60020389	35620	毒虫
    4205	TORMENT	88	30	570	2280378	45151344	25195	人造人
    4206	TORMENT	88	30	570	3408082	67985820	47795	食尸鬼
    4207	TORMENT	89	30	600	3778164	76475520	54145	瘟疫鼠
    4208	TORMENT	89	30	600	2793810	55365600	43200	狗头人卫兵
    4209	TORMENT	90	30	600	4144078	82267067	67420	木乃伊
    4210	TORMENT	90	0	0	176800	215946	2350	沙漠的支配者
    4301	TORMENT	91	31	620	2669033	53134175	35305	鼠族狂战士
    4302	TORMENT	91	31	620	3000104	54116955	79185	鼠族战士
    4303	TORMENT	92	31	620	3718521	62312615	51520	眼镜蛇
    4304	TORMENT	92	31	620	2760627	39013586	69440	毒虫
    4305	TORMENT	93	31	620	3424026	56691256	67715	人造人
    4306	TORMENT	93	31	620	5325522	108297186	63550	食尸鬼
    4307	TORMENT	94	31	651	6064583	123310166	56135	瘟疫鼠
    4308	TORMENT	94	31	651	7222400	142863980	54280	狗头人卫兵
    4309	TORMENT	95	31	651	7250719	143780798	53215	木乃伊
    4310	TORMENT	95	0	0	198300	7826	3550	执政官莫尔卡
    """

    func spawnMonster(difficulty: Difficulty, encounterIndex: Int = 0, playthrough: Int = 1) -> Monster {
        let data = runtimeData(for: difficulty)
        let spawn = monsterSpawn(for: difficulty, encounterIndex: encounterIndex)
        let monsterName = spawn.name
        let base = monsterProfile(named: monsterName)
        let levelScale = 1.0 + Double(max(data.level - 1, 0)) * 0.08
        let enemyMultiplier = NewGamePlusTuning.enemyStatMultiplier(for: playthrough)
        let rewardMultiplier = NewGamePlusTuning.rewardMultiplier(for: playthrough)

        return Monster(
            id: isBoss ? "boss_\(id)" : base.id,
            name: monsterName,
            hp: max(1, Int(Double(data.hp) * enemyMultiplier)),
            atk: max(1, Int(Double(base.atk) * difficulty.statMultiplier * levelScale * (isBoss ? 1.45 : 1.0) * enemyMultiplier)),
            def: max(0, Int(Double(base.def) * difficulty.statMultiplier * levelScale * (isBoss ? 1.35 : 1.0) * enemyMultiplier)),
            spd: base.spd,
            critRate: base.critRate,
            xpReward: max(1, Int(Double(data.xpReward) * rewardMultiplier)),
            goldReward: max(1, Int(Double(data.goldReward) * rewardMultiplier)),
            lootTableID: base.lootTableID,
            itemLevelCap: itemLevelCap(for: difficulty),
            sourceSkillID: sourceSkillID(forMonsterNamed: monsterName) ?? base.sourceSkillID
        )
    }

    private func bossHP(for difficulty: Difficulty) -> Int? {
        guard isBoss else { return nil }
        switch (act, difficulty) {
        case (.forest, .normal): return 1050
        case (.forest, .nightmare), (.forest, .hell), (.forest, .torment): return 2350
        case (.dungeon, .normal): return 1850
        case (.dungeon, .nightmare): return 1950
        case (.dungeon, .hell): return 2050
        case (.dungeon, .torment): return 2350
        case (.volcano, .normal): return 2550
        case (.volcano, .nightmare): return 2750
        case (.volcano, .hell): return 3050
        case (.volcano, .torment): return 3550
        }
    }

    private func monsterProfile(named name: String) -> Monster {
        switch name {
        case "史莱姆":
            return Monster(id: "slime_green", name: name, hp: 50, atk: 8, def: 3, spd: 5, critRate: 0.02, xpReward: 15, goldReward: 10, lootTableID: "slime_drops")
        case "哥布林":
            return Monster(id: "goblin", name: name, hp: 70, atk: 14, def: 6, spd: 10, critRate: 0.08, xpReward: 30, goldReward: 25, lootTableID: "goblin_drops")
        case "哥布林盗贼":
            return Monster(id: "assassin_goblin", name: name, hp: 70, atk: 14, def: 6, spd: 11, critRate: 0.08, xpReward: 30, goldReward: 25, lootTableID: "goblin_drops")
        case "哥布林萨满":
            return Monster(id: "shaman_goblin", name: name, hp: 76, atk: 15, def: 6, spd: 9, critRate: 0.07, xpReward: 30, goldReward: 25, lootTableID: "goblin_drops")
        case "兽人":
            return Monster(id: "basic_orc", name: name, hp: 88, atk: 16, def: 8, spd: 9, critRate: 0.06, xpReward: 32, goldReward: 25, lootTableID: "goblin_drops")
        case "兽人战士":
            return Monster(id: "armored_orc", name: name, hp: 104, atk: 18, def: 12, spd: 8, critRate: 0.06, xpReward: 34, goldReward: 27, lootTableID: "goblin_drops")
        case "精英兽人":
            return Monster(id: "elite_orc", name: name, hp: 125, atk: 20, def: 14, spd: 8, critRate: 0.07, xpReward: 38, goldReward: 30, lootTableID: "goblin_drops")
        case "骷髅":
            return Monster(id: "stage_skeleton", name: name, hp: 120, atk: 18, def: 12, spd: 7, critRate: 0.05, xpReward: 40, goldReward: 30, lootTableID: "undead_drops")
        case "骷髅战士":
            return Monster(id: "armored_skeleton", name: name, hp: 140, atk: 20, def: 15, spd: 7, critRate: 0.05, xpReward: 42, goldReward: 32, lootTableID: "undead_drops")
        case "骷髅弓箭手":
            return Monster(id: "skeleton_archer", name: name, hp: 110, atk: 22, def: 10, spd: 8, critRate: 0.07, xpReward: 42, goldReward: 32, lootTableID: "undead_drops")
        case "蝙蝠":
            return Monster(id: "bat", name: name, hp: 40, atk: 10, def: 2, spd: 15, critRate: 0.05, xpReward: 12, goldReward: 8, lootTableID: "beast_drops")
        case "鼠族狂战士":
            return Monster(id: "berserker_rat", name: name, hp: 78, atk: 20, def: 7, spd: 13, critRate: 0.09, xpReward: 24, goldReward: 18, lootTableID: "beast_drops")
        case "鼠族战士":
            return Monster(id: "warrior_rat", name: name, hp: 86, atk: 18, def: 9, spd: 12, critRate: 0.08, xpReward: 24, goldReward: 18, lootTableID: "beast_drops")
        case "鼠族弓手":
            return Monster(id: "warrior_rat", name: name, hp: 78, atk: 20, def: 6, spd: 13, critRate: 0.09, xpReward: 24, goldReward: 18, lootTableID: "beast_drops")
        case "眼镜蛇":
            return Monster(id: "cobra", name: name, hp: 72, atk: 19, def: 5, spd: 13, critRate: 0.08, xpReward: 22, goldReward: 15, lootTableID: "beast_drops")
        case "毒虫", "蝎子", "巨蝇":
            return Monster(id: "poison_insect", name: name, hp: 72, atk: 17, def: 5, spd: 12, critRate: 0.07, xpReward: 22, goldReward: 15, lootTableID: "beast_drops")
        case "人造人":
            return Monster(id: "homunculus", name: name, hp: 185, atk: 23, def: 26, spd: 5, critRate: 0.02, xpReward: 60, goldReward: 45, lootTableID: "golem_drops")
        case "食尸鬼":
            return Monster(id: "stage_ghoul", name: name, hp: 210, atk: 17, def: 20, spd: 4, critRate: 0.01, xpReward: 50, goldReward: 35, lootTableID: "undead_drops")
        case "幽灵":
            return Monster(id: "stage_ghoul", name: name, hp: 160, atk: 22, def: 12, spd: 8, critRate: 0.05, xpReward: 50, goldReward: 35, lootTableID: "undead_drops")
        case "瘟疫鼠":
            return Monster(id: "zombie_rat", name: name, hp: 92, atk: 19, def: 9, spd: 11, critRate: 0.06, xpReward: 26, goldReward: 18, lootTableID: "beast_drops")
        case "狗头人卫兵", "狗头人投石手":
            return Monster(id: "spear_kobolt", name: name, hp: 106, atk: 19, def: 12, spd: 10, critRate: 0.06, xpReward: 34, goldReward: 27, lootTableID: "goblin_drops")
        case "木乃伊":
            return Monster(id: "small_mummy", name: name, hp: 220, atk: 17, def: 22, spd: 3, critRate: 0.01, xpReward: 52, goldReward: 36, lootTableID: "undead_drops")
        case "火元素", "地精灵", "熔岩人", "地狱魔像", "雪人":
            return Monster(id: "golem", name: name, hp: 300, atk: 25, def: 35, spd: 2, critRate: 0.0, xpReward: 80, goldReward: 60, lootTableID: "golem_drops")
        case "雪山战士", "雪山卫兵":
            return Monster(id: "armored_orc", name: name, hp: 130, atk: 20, def: 16, spd: 7, critRate: 0.05, xpReward: 38, goldReward: 30, lootTableID: "goblin_drops")
        case "雪山弓手":
            return Monster(id: "skeleton_archer", name: name, hp: 110, atk: 22, def: 10, spd: 8, critRate: 0.07, xpReward: 42, goldReward: 32, lootTableID: "undead_drops")
        case "小鬼", "燃烧小猪", "幼龙":
            return Monster(id: "dragon_whelp", name: name, hp: 250, atk: 30, def: 25, spd: 8, critRate: 0.12, xpReward: 100, goldReward: 80, lootTableID: "dragon_drops")
        case "堕落天使的头盔", "恶魔士兵", "恶魔突击兵", "恶魔军团长", "死亡之指", "燃烧的地狱祭司", "冰冻的地狱祭司", "电流的地狱祭司", "血之祭司", "混沌的地狱祭司":
            return Monster(id: "voidcaller", name: name, hp: 250, atk: 30, def: 25, spd: 8, critRate: 0.12, xpReward: 100, goldReward: 80, lootTableID: "dragon_drops")
        case "骷髅王":
            return Monster(id: "skeleton_king", name: name, hp: 260, atk: 24, def: 24, spd: 5, critRate: 0.04, xpReward: 80, goldReward: 60, lootTableID: "undead_drops")
        case "沙漠的支配者":
            return Monster(id: "sibuna", name: name, hp: 300, atk: 25, def: 35, spd: 4, critRate: 0.03, xpReward: 80, goldReward: 60, lootTableID: "golem_drops")
        case "执政官莫尔卡":
            return Monster(id: "voidcaller", name: name, hp: 250, atk: 30, def: 25, spd: 8, critRate: 0.12, xpReward: 100, goldReward: 80, lootTableID: "dragon_drops")
        default:
            break
        }
        return Monster.allMonsters.first { $0.id == "slime_green" } ?? Monster.allMonsters[0]
    }

    private func sourceSkillID(forMonsterNamed name: String) -> String? {
        switch name {
        case "燃烧的地狱祭司":
            return "301015"
        case "冰冻的地狱祭司":
            return "301025"
        case "电流的地狱祭司":
            return "301035"
        case "混沌的地狱祭司":
            return "301045"
        default:
            return nil
        }
    }
}
