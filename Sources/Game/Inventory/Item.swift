import Foundation

/// 物品稀有度
enum Rarity: String, Codable, CaseIterable, Comparable {
    case common = "普通"
    case uncommon = "优秀"
    case rare = "稀有"
    case legendary = "传说"
    case immortal = "不朽"
    case arcana = "奥秘"
    case beyond = "超越"
    case celestial = "天界"
    case divine = "神圣"
    case cosmic = "宇宙"

    var color: String {
        switch self {
        case .common: return "#E4E4E4"
        case .uncommon: return "#54FC0C"
        case .rare: return "#2F8BFC"
        case .legendary: return "#FC9C0C"
        case .immortal: return "#FC2424"
        case .arcana: return "#B40CFC"
        case .beyond: return "#FC246C"
        case .celestial: return "#6CCCE4"
        case .divine: return "#FCE454"
        case .cosmic: return "#FCFCFC"
        }
    }

    /// 按 allCases 声明顺序比较，保持原版从 Common 到 Cosmic 的稀有度阶梯。
    static func < (lhs: Rarity, rhs: Rarity) -> Bool {
        guard let l = allCases.firstIndex(of: lhs),
              let r = allCases.firstIndex(of: rhs) else { return false }
        return l < r
    }
}

/// 装备槽位。`accessory` 仅用于兼容旧存档，新的饰品会拆分到四个具体槽位。
enum EquipSlot: String, Codable, Hashable {
    case weapon = "武器"
    case offhand = "副手"
    case armor = "护甲"
    case helmet = "头盔"
    case gloves = "手套"
    case boots = "靴子"
    case amulet = "护符"
    case earring = "耳环"
    case ring = "戒指"
    case bracer = "护腕"
    case accessory = "饰品"

    static let allCases: [EquipSlot] = [
        .weapon, .offhand,
        .helmet, .armor, .gloves, .boots,
        .amulet, .earring, .ring, .bracer
    ]
}

enum EquipmentCategory: String, Codable, CaseIterable, Hashable {
    case weapon = "武器"
    case offhand = "副手"
    case armor = "护甲"
    case accessory = "饰品"
}

/// 原版资料页列出的 20 种装备类型，映射到 macOS 版当前可承载的 10 个实际槽位。
enum EquipmentType: String, Codable, CaseIterable, Hashable {
    case sword = "Sword"
    case bow = "Bow"
    case staff = "Staff"
    case scepter = "Scepter"
    case crossbow = "Crossbow"
    case axe = "Axe"

    case shield = "Shield"
    case arrow = "Arrow"
    case orb = "Orb"
    case tome = "Tome"
    case bolt = "Bolt"
    case hatchet = "Hatchet"

    case helmet = "Helmet"
    case armor = "Armor"
    case gloves = "Gloves"
    case boots = "Boots"

    case amulet = "Amulet"
    case earring = "Earring"
    case ring = "Ring"
    case bracer = "Bracer"

    var category: EquipmentCategory {
        switch self {
        case .sword, .bow, .staff, .scepter, .crossbow, .axe:
            return .weapon
        case .shield, .arrow, .orb, .tome, .bolt, .hatchet:
            return .offhand
        case .helmet, .armor, .gloves, .boots:
            return .armor
        case .amulet, .earring, .ring, .bracer:
            return .accessory
        }
    }

    var equipSlot: EquipSlot {
        switch self {
        case .sword, .bow, .staff, .scepter, .crossbow, .axe:
            return .weapon
        case .shield, .arrow, .orb, .tome, .bolt, .hatchet:
            return .offhand
        case .helmet:
            return .helmet
        case .armor:
            return .armor
        case .gloves:
            return .gloves
        case .boots:
            return .boots
        case .amulet:
            return .amulet
        case .earring:
            return .earring
        case .ring:
            return .ring
        case .bracer:
            return .bracer
        }
    }

    var localizedName: String {
        switch self {
        case .sword: return "剑"
        case .bow: return "弓"
        case .staff: return "法杖"
        case .scepter: return "权杖"
        case .crossbow: return "弩"
        case .axe: return "斧"
        case .shield: return "盾"
        case .arrow: return "箭袋"
        case .orb: return "宝珠"
        case .tome: return "魔典"
        case .bolt: return "弩矢"
        case .hatchet: return "手斧"
        case .helmet: return "头盔"
        case .armor: return "护甲"
        case .gloves: return "手套"
        case .boots: return "靴子"
        case .amulet: return "护符"
        case .earring: return "耳环"
        case .ring: return "戒指"
        case .bracer: return "护腕"
        }
    }

    var typeLine: String {
        "\(category.rawValue) / \(rawValue)"
    }

    static func defaultType(for slot: EquipSlot?) -> EquipmentType? {
        switch slot {
        case .weapon: return .sword
        case .offhand: return .shield
        case .helmet: return .helmet
        case .armor: return .armor
        case .gloves: return .gloves
        case .boots: return .boots
        case .amulet: return .amulet
        case .earring: return .earring
        case .ring, .accessory: return .ring
        case .bracer: return .bracer
        case nil: return nil
        }
    }
}

struct SourceGearLevelProgression: Equatable, Identifiable {
    let id: String
    let itemLevel: Int
    let name: String
}

enum SourceMaterialCategory: String, CaseIterable, Hashable {
    case decoration = "Decoration"
    case engraving = "Engraving"
    case inscription = "Inscription"
    case crafting = "Crafting"
    case offering = "Offering"
    case soulStone = "Soul Stone"
}

struct SourceMaterialEntry: Equatable, Identifiable {
    let id: String
    let name: String
    let rarity: Rarity
    let category: SourceMaterialCategory

    var iconName: String {
        "source_material_\(id)"
    }
}

struct SourceStageChestEntry: Equatable, Identifiable {
    let id: String
    let name: String
    let rarity: Rarity

    var sourceIconID: String {
        if id.hasPrefix("91") {
            return "910011"
        }
        if id.hasPrefix("92") {
            return "920011"
        }
        if id.hasPrefix("93") {
            return "930011"
        }
        return id
    }

    var iconName: String {
        "source_stage_chest_\(sourceIconID)"
    }
}

struct SourceGearTypeEntry: Equatable, Identifiable {
    var id: String { equipmentType.rawValue }

    let equipmentType: EquipmentType
    let sourceSlug: String
    let sourceTitle: String
    let gearEntryCount: Int
    let levelStepCount: Int
    let rarityCounts: [Rarity: Int]
    let progressions: [SourceGearLevelProgression]

    func rarityCount(for rarity: Rarity) -> Int {
        rarityCounts[rarity] ?? 0
    }
}

enum SourceItemCatalog {
    static let expectedGearTypeCount = 20
    static let expectedGearEntryCount = 5_760
    static let expectedGearLevelProgressionCount = 396
    static let expectedMaterialCount = 115
    static let expectedMaterialCategoryCount = 6
    static let expectedStageChestCount = 59

    static let allGearTypes: [SourceGearTypeEntry] = parseSourceGearTypeTSV()
    static let allMaterials: [SourceMaterialEntry] = parseSourceMaterialTSV()
    static let allStageChests: [SourceStageChestEntry] = parseSourceStageChestTSV()

    static let byType: [EquipmentType: SourceGearTypeEntry] = Dictionary(
        uniqueKeysWithValues: allGearTypes.map { ($0.equipmentType, $0) }
    )

    static let materialByID: [String: SourceMaterialEntry] = Dictionary(
        uniqueKeysWithValues: allMaterials.map { ($0.id, $0) }
    )

    static let stageChestByID: [String: SourceStageChestEntry] = Dictionary(
        uniqueKeysWithValues: allStageChests.map { ($0.id, $0) }
    )

    static var totalGearEntryCount: Int {
        allGearTypes.reduce(0) { $0 + $1.gearEntryCount }
    }

    static var totalGearLevelProgressionCount: Int {
        allGearTypes.reduce(0) { $0 + $1.progressions.count }
    }

    static var totalRarityDistributionCount: Int {
        allGearTypes.reduce(0) { total, entry in
            total + entry.rarityCounts.values.reduce(0, +)
        }
    }

    static var aggregateRarityCounts: [Rarity: Int] {
        var counts: [Rarity: Int] = [:]
        for entry in allGearTypes {
            for (rarity, count) in entry.rarityCounts {
                counts[rarity, default: 0] += count
            }
        }
        return counts
    }

    static var materialCountsByCategory: [SourceMaterialCategory: Int] {
        Dictionary(grouping: allMaterials, by: \.category).mapValues(\.count)
    }

    static var materialCountsByRarity: [Rarity: Int] {
        Dictionary(grouping: allMaterials, by: \.rarity).mapValues(\.count)
    }

    static var stageChestCountsByRarity: [Rarity: Int] {
        Dictionary(grouping: allStageChests, by: \.rarity).mapValues(\.count)
    }

    static var duplicateProgressionIDs: [String] {
        let ids = allGearTypes.flatMap { $0.progressions.map(\.id) }
        let duplicates = Set(ids.filter { id in ids.filter { $0 == id }.count > 1 })
        return duplicates.sorted()
    }

    static var duplicateMaterialIDs: [String] {
        let ids = allMaterials.map(\.id)
        let duplicates = Set(ids.filter { id in ids.filter { $0 == id }.count > 1 })
        return duplicates.sorted()
    }

    static var duplicateStageChestIDs: [String] {
        let ids = allStageChests.map(\.id)
        let duplicates = Set(ids.filter { id in ids.filter { $0 == id }.count > 1 })
        return duplicates.sorted()
    }

    static var missingEquipmentTypes: [EquipmentType] {
        let covered = Set(allGearTypes.map(\.equipmentType))
        return EquipmentType.allCases.filter { !covered.contains($0) }
    }

    private static func parseSourceGearTypeTSV() -> [SourceGearTypeEntry] {
        sourceGearTypeTSV
            .split(whereSeparator: \.isNewline)
            .compactMap { line -> SourceGearTypeEntry? in
                let columns = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
                guard columns.count == 6,
                      let equipmentType = equipmentType(sourceTitle: columns[1]),
                      let gearEntryCount = Int(columns[2]),
                      let levelStepCount = Int(columns[3]) else {
                    return nil
                }

                return SourceGearTypeEntry(
                    equipmentType: equipmentType,
                    sourceSlug: columns[0],
                    sourceTitle: columns[1],
                    gearEntryCount: gearEntryCount,
                    levelStepCount: levelStepCount,
                    rarityCounts: parseRarityCounts(columns[4]),
                    progressions: parseProgressions(columns[5])
                )
            }
    }

    private static func parseSourceMaterialTSV() -> [SourceMaterialEntry] {
        sourceMaterialTSV
            .split(whereSeparator: \.isNewline)
            .compactMap { line -> SourceMaterialEntry? in
                let columns = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
                guard columns.count == 4,
                      let rarity = rarity(sourceName: columns[1]),
                      let category = materialCategory(sourceName: columns[2]) else {
                    return nil
                }

                return SourceMaterialEntry(
                    id: columns[3],
                    name: columns[0],
                    rarity: rarity,
                    category: category
                )
            }
    }

    private static func parseSourceStageChestTSV() -> [SourceStageChestEntry] {
        sourceStageChestTSV
            .split(whereSeparator: \.isNewline)
            .compactMap { line -> SourceStageChestEntry? in
                let columns = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
                guard columns.count == 3,
                      let rarity = rarity(sourceName: columns[1]) else {
                    return nil
                }

                return SourceStageChestEntry(
                    id: columns[2],
                    name: columns[0],
                    rarity: rarity
                )
            }
    }

    private static func equipmentType(sourceTitle: String) -> EquipmentType? {
        if sourceTitle == "Earing" {
            return .earring
        }
        return EquipmentType(rawValue: sourceTitle)
    }

    private static func parseRarityCounts(_ value: String) -> [Rarity: Int] {
        Dictionary(
            uniqueKeysWithValues: value.split(separator: ",").compactMap { pair in
                let parts = pair.split(separator: ":", omittingEmptySubsequences: false)
                guard parts.count == 2,
                      let rarity = rarity(sourceName: String(parts[0])),
                      let count = Int(parts[1]) else {
                    return nil
                }
                return (rarity, count)
            }
        )
    }

    private static func parseProgressions(_ value: String) -> [SourceGearLevelProgression] {
        value.split(separator: "|").compactMap { entry in
            let parts = entry.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
            guard parts.count == 3,
                  let itemLevel = Int(parts[0]) else {
                return nil
            }
            return SourceGearLevelProgression(
                id: String(parts[1]),
                itemLevel: itemLevel,
                name: String(parts[2])
            )
        }
    }

    private static func materialCategory(sourceName: String) -> SourceMaterialCategory? {
        switch sourceName.lowercased() {
        case "decoration": return .decoration
        case "engraving": return .engraving
        case "inscription": return .inscription
        case "crafting": return .crafting
        case "offering": return .offering
        case "soul stone": return .soulStone
        default: return nil
        }
    }

    private static func rarity(sourceName: String) -> Rarity? {
        switch sourceName.lowercased() {
        case "common": return .common
        case "uncommon": return .uncommon
        case "rare": return .rare
        case "legendary": return .legendary
        case "immortal": return .immortal
        case "arcana": return .arcana
        case "beyond": return .beyond
        case "celestial": return .celestial
        case "divine": return .divine
        case "cosmic": return .cosmic
        default: return nil
        }
    }

    private static let sourceMaterialTSV = """
Minor Ruby	Common	Decoration	110001
Minor Sapphire	Common	Decoration	110002
Minor Topaz	Common	Decoration	110003
Minor Emerald	Common	Decoration	110004
Minor Amethyst	Common	Decoration	110005
Obsidian Shard	Uncommon	Decoration	111001
Coral Piece	Uncommon	Decoration	111002
Jade Stone	Uncommon	Decoration	111003
Amber Gem	Uncommon	Decoration	111004
Ruby	Rare	Decoration	112001
Sapphire	Rare	Decoration	112002
Topaz	Rare	Decoration	112003
Emerald	Rare	Decoration	112004
Amethyst	Rare	Decoration	112005
Crystal Quartz	Legendary	Decoration	113001
Pearl	Legendary	Decoration	113002
Turquoise	Legendary	Decoration	113003
Garnet	Legendary	Decoration	113004
Diamond	Immortal	Decoration	114001
Opal	Immortal	Decoration	114002
Lapis Lazuli	Immortal	Decoration	114003
Black Pearl	Immortal	Decoration	114004
Arcane Crystal	Arcana	Decoration	115001
Mystic Topaz	Arcana	Decoration	115002
Enchanted Ruby	Arcana	Decoration	115003
Starlight Sapphire	Arcana	Decoration	115004
Void Opal	Beyond	Decoration	116001
Astral Diamond	Beyond	Decoration	116002
Phantom Emerald	Beyond	Decoration	116003
Twilight Amethyst	Beyond	Decoration	116004
Celestial Pearl	Celestial	Decoration	117001
Dragonite Crystal	Celestial	Decoration	117002
Void Crystal	Divine	Decoration	118001
Abyssal Pearl	Divine	Decoration	118002
Ethereal Gem	Cosmic	Decoration	119001
Chaos Diamond	Cosmic	Decoration	119002
Goblin Hide	Common	Engraving	120001
Skeleton Bone	Common	Engraving	120002
Slime Jelly	Common	Engraving	120003
Wolf Fang	Uncommon	Engraving	121001
Spider Silk	Uncommon	Engraving	121002
Poisonous Herb	Uncommon	Engraving	121003
Healing Herb	Uncommon	Engraving	121004
Bat Wing Membrane	Rare	Engraving	122001
Ogre Blood	Rare	Engraving	122002
Mushroom Spore	Rare	Engraving	122003
Ancient Tree Sap	Rare	Engraving	122004
Skull	Legendary	Engraving	123001
Harpy Feather	Legendary	Engraving	123002
Mandrake Root	Legendary	Engraving	123003
Nightshade Extract	Legendary	Engraving	123004
Basilisk Scale	Immortal	Engraving	124001
Wyvern Claw	Immortal	Engraving	124002
Dice	Immortal	Engraving	124003
Demon Blood	Immortal	Engraving	124004
Minotaur Horn	Arcana	Engraving	125001
Griffin Beak	Arcana	Engraving	125002
Phoenix Ash	Arcana	Engraving	125003
Dragon Bile	Arcana	Engraving	125004
Wraith Essence	Beyond	Engraving	126001
Kraken Ink	Beyond	Engraving	126002
Titan Marrow	Beyond	Engraving	126003
Void Ichor	Beyond	Engraving	126004
Abyssal Mucus	Celestial	Engraving	127001
Chaos Spore	Celestial	Engraving	127002
Primordial Sap	Divine	Engraving	128001
Eldritch Venom	Divine	Engraving	128002
Chaso Dice	Cosmic	Engraving	129001
Void Tendril	Cosmic	Engraving	129002
Scroll of Common Inscription	Common	Inscription	130001
Scroll of Uncommon Inscription	Uncommon	Inscription	131001
Scroll of Rare Inscription	Rare	Inscription	132001
Scroll of Legendary Inscription	Legendary	Inscription	133001
Scroll of Immortal Inscription	Immortal	Inscription	134001
Scroll of Arcana Inscription	Arcana	Inscription	135001
Scroll of Beyond Inscription	Beyond	Inscription	136001
Scroll of Celestial Inscription	Celestial	Inscription	137001
Scroll of Divine Inscription	Divine	Inscription	138001
Scroll of Cosmic Inscription	Cosmic	Inscription	139001
Wood	Common	Crafting	140001
Stone	Common	Crafting	140002
Leather	Common	Crafting	140003
Copper Nugget	Common	Crafting	140004
Bronze Ingot	Uncommon	Crafting	141001
Iron Ingot	Uncommon	Crafting	141002
Silver Ingot	Rare	Crafting	142001
Gold Ingot	Rare	Crafting	142002
Stardust Ingot	Legendary	Crafting	143001
Void Iron	Legendary	Crafting	143002
Bloodstone	Immortal	Crafting	144001
Thunderstone	Immortal	Crafting	144002
Chaos Shard	Arcana	Crafting	145001
Arcane Ore	Arcana	Crafting	145002
Darksteel Ingot	Beyond	Crafting	146001
Orichalcum Ore	Beyond	Crafting	146002
Moonstone	Celestial	Crafting	147001
Sunstone	Celestial	Crafting	147002
Mithril Ore	Divine	Crafting	148001
Ethereal Ingot	Divine	Crafting	148002
Adamantium Ore	Cosmic	Crafting	149001
Aeon Ingot	Cosmic	Crafting	149002
Kingdom 1st Anniversary Coin	Common	Offering	160001
Empire 1st Anniversary Coin	Uncommon	Offering	160002
Kingdom 10th Anniversary Coin	Rare	Offering	160003
Empire 10th Anniversary Coin	Legendary	Offering	160004
Kingdom 50th Anniversary Coin	Immortal	Offering	160005
Empire 50th Anniversary Coin	Arcana	Offering	160006
Kingdom 100th Anniversary Coin	Beyond	Offering	160007
Empire 100th Anniversary Coin	Celestial	Offering	160008
Sacred Kingdom 1000th Anniversary Coin	Divine	Offering	160009
Eternal Empire 1000th Anniversary Coin	Cosmic	Offering	160010
Soulstone - Normal	Immortal	Soul Stone	190001
Soulstone - Nightmare	Arcana	Soul Stone	190002
Soulstone - Hell	Beyond	Soul Stone	190003
Soulstone - Torment	Celestial	Soul Stone	190004
"""

    private static let sourceStageChestTSV = """
Normal Monster Box 1	Common	910011
Normal Monster Box 2	Common	910051
Normal Monster Box 3	Common	910101
Normal Monster Box Lv15	Common	910151
Normal Monster Box Lv20	Common	910201
Normal Monster Box Lv25	Common	910251
Normal Monster Box Lv30	Common	910301
Normal Monster Box Lv35	Common	910351
Normal Monster Box Lv40	Common	910401
Normal Monster Box Lv45	Common	910451
Normal Monster Box Lv50	Common	910501
Normal Monster Box Lv55	Common	910551
Normal Monster Box Lv60	Common	910601
Normal Monster Box Lv65	Common	910651
Normal Monster Box Lv70	Common	910701
Normal Monster Box Lv75	Common	910751
Normal Monster Box Lv80	Common	910801
Normal Monster Box Lv85	Common	910851
Normal Monster Box Lv90	Common	910901
Stage Boss Box 1	Rare	920001
Stage Boss Box 2	Rare	920002
Stage Boss Box 3	Rare	920003
Stage Boss Box 3	Rare	920004
Stage Boss Box 3	Rare	920005
Stage Boss Box 3	Rare	920006
Stage Boss Box 4	Rare	920011
Stage Boss Box 6	Rare	920022
Stage Boss Box 6	Rare	920032
Stage Boss Box 6	Rare	920042
Stage Boss Box 5	Rare	920051
Stage Boss Box 6	Rare	920052
Stage Boss Box 7	Rare	920101
Stage Boss Box Lv15	Rare	920151
Stage Boss Box Lv20	Rare	920201
Stage Boss Box Lv25	Rare	920251
Stage Boss Box Lv30	Rare	920301
Stage Boss Box Lv35	Rare	920351
Stage Boss Box Lv40	Rare	920401
Stage Boss Box Lv45	Rare	920451
Stage Boss Box Lv50	Rare	920501
Stage Boss Box Lv55	Rare	920551
Stage Boss Box Lv60	Rare	920601
Stage Boss Box Lv65	Rare	920651
Stage Boss Box Lv70	Rare	920701
Stage Boss Box Lv75	Rare	920751
Stage Boss Box Lv80	Rare	920801
Stage Boss Box Lv85	Rare	920851
Stage Boss Box Lv90	Rare	920901
Act Boss Box 1	Legendary	930101
Act Boss Box Lv20	Legendary	930201
Act Boss Box Lv30	Legendary	930301
Act Boss Box Lv40	Legendary	930401
Act Boss Box Lv45	Legendary	930451
Act Boss Box Lv50	Legendary	930501
Act Boss Box Lv60	Legendary	930601
Act Boss Box Lv65	Legendary	930651
Act Boss Box Lv70	Legendary	930701
Act Boss Box Lv85	Legendary	930851
Act Boss Box Lv90	Legendary	930901
"""

    private static let sourceGearTypeTSV = """
amulet	Amulet	272	19	Common:0,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:601011:Copper Amulet|5:601021:Bronze Amulet|10:601031:Silver Amulet|15:601041:Gold Amulet|20:601051:Platinum Amulet|25:601061:Crystal Amulet|30:601071:Moonstone Pendant|35:601081:Amber Pendant|40:601091:Ruby Pendant|45:601101:Amethyst Pendant|50:601111:Emerald Amulet|55:601121:Diamond Amulet|60:601131:Stardust Amulet|65:601141:Eclipse Amulet|70:601151:Celestial Amulet|75:601161:Astral Amulet|80:601171:Ethereal Amulet|85:601181:Void Amulet|90:601191:Abyss Amulet
armor	Armor	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:510001:Wooden Armor|5:510002:Empire Armor|10:510003:Iron Plate|15:510004:Chain Mail|20:510005:Knight's Armor|25:510006:Fate Armor|30:510007:War Armor|35:510008:Heavy Armor|40:510009:Rune Plate|45:510010:Dragon Scale Armor|50:510011:Mystic Armor|55:510012:Great Armor|60:510013:Ancient Armor|65:510014:Shine Armor|70:510015:Void Armor|75:510016:Dragon Armor|80:510017:Dimensional Armor|85:510018:Shadow Armor|90:510019:Eternal Armor|100:510020:Radiant Armor
arrow	Arrow	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:410001:Wooden Arrow|5:410002:Iron Arrow|10:410003:Hunter's Arrow|15:410004:Barbed Arrow|20:410005:Azure Arrow|25:410006:Brutal Arrow|30:410007:Gale Arrow|35:410008:Serpent Arrow|40:410009:Rune Arrow|45:410010:Tribal Arrow|50:410011:Fate Arrow|55:410012:Storm Arrow|60:410013:Obsidian Arrow|65:410014:Haste Arrow|70:410015:Void Arrow|75:410016:Poison Arrow|80:410017:Dimensional Arrow|85:410018:Shadow Arrow|90:410019:Ancient Arrow|100:410020:Exalted Arrow
axe	Axe	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:350001:Wooden Axe|5:350002:Iron Axe|10:350003:Battle Axe|15:350004:Steel Axe|20:350005:War Axe|25:350006:Knight's Axe|30:350007:Great Axe|35:350008:Heavy Axe|40:350009:Rune Axe|45:350010:Legend Axe|50:350011:Fate Axe|55:350012:Hero Axe|60:350013:Storm Axe|65:350014:Limitless Axe|70:350015:Chaos Axe|75:350016:Power Axe|80:350017:Dimensional Axe|85:350018:Shadow Axe|90:350019:Eternal Axe|100:350020:Radiant Axe
bolt	Bolt	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:440001:Short Bolt|5:440002:Fear Bolt|10:440003:Hunter's Bolt|15:440004:Barbed Bolt|20:440005:Beast Bolt|25:440006:Swift Bolt|30:440007:Iron Bolt|35:440008:Heavy Bolt|40:440009:Rune Bolt|45:440010:Hero Bolt|50:440011:Fate Bolt|55:440012:Storm Bolt|60:440013:Thunder Bolt|65:440014:Haste Bolt|70:440015:Void Bolt|75:440016:Poison Bolt|80:440017:Dimensional Bolt|85:440018:Shadow Bolt|90:440019:Ancient Bolt|100:440020:Sanctified Bolt
boots	Boots	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:530001:Wooden Boots|5:530002:Empire Boots|10:530003:Iron Boots|15:530004:Knight Boots|20:530005:Chain Boots|25:530006:Fate Boots|30:530007:War Boots|35:530008:Heavy Boots|40:530009:Rune Boots|45:530010:Plate Boots|50:530011:Mystic Boots|55:530012:Great Boots|60:530013:Ancient Boots|65:530014:Shine Boots|70:530015:Void Boots|75:530016:Crystal Boots|80:530017:Dimensional Boots|85:530018:Shadow Boots|90:530019:Eternal Boots|100:530020:Radiant Boots
bow	Bow	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:310001:Short Bow|5:310002:Hunting Bow|10:310003:Long Bow|15:310004:Composite Bow|20:310005:War Bow|25:310006:Scarlet Bow|30:310007:Dusk Bow|35:310008:Jade Bow|40:310009:Elite Bow|45:310010:Rune Bow|50:310011:Mystic Bow|55:310012:Swift Bow|60:310013:Ancient Bow|65:310014:Limitless Bow|70:310015:Chaos Bow|75:310016:Storm Bow|80:310017:Shadow Bow|85:310018:Tempest Bow|90:310019:Eternal Bow|100:310020:Radiant Bow
bracer	Bracer	272	19	Common:0,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:631011:Copper Bracer|5:631021:Bronze Bracer|10:631031:Silver Bracer|15:631041:Gold Bracer|20:631051:Platinum Bracer|25:631061:Crystal Bracer|30:631071:Obsidian Bracer|35:631081:Shadow Bracer|40:631091:Crimson Bracer|45:631101:Bloodstone Bracer|50:631111:Emerald Bracer|55:631121:Diamond Bracer|60:631131:Stardust Bracer|65:631141:Eclipse Bracer|70:631151:Celestial Bracer|75:631161:Astral Bracer|80:631171:Ethereal Bracer|85:631181:Void Bracer|90:631191:Abyss Bracer
crossbow	Crossbow	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:340001:Short Crossbow|5:340002:Leather Crossbow|10:340003:Long Crossbow|15:340004:Complete Crossbow|20:340005:Exceptional Crossbow|25:340006:Reinforced Crossbow|30:340007:Iron Crossbow|35:340008:Wing Crossbow|40:340009:Elite Crossbow|45:340010:Large Crossbow|50:340011:Mystic Crossbow|55:340012:Fast Crossbow|60:340013:Ancient Crossbow|65:340014:Limitless Crossbow|70:340015:Chaos Crossbow|75:340016:Power Crossbow|80:340017:Dimensional Crossbow|85:340018:Shadow Crossbow|90:340019:Eternal Crossbow|100:340020:Radiant Crossbow
earing	Earing	272	19	Common:0,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:611011:Copper Earring|5:611021:Bronze Earring|10:611031:Silver Earring|15:611041:Gold Earring|20:611051:Platinum Earring|25:611061:Crystal Earring|30:611071:Emerald Earring|35:611081:Jade Earring|40:611091:Tiger Eye Earring|45:611101:Garnet Earring|50:611111:Sapphire Earring|55:611121:Diamond Earring|60:611131:Moonstone Earring|65:611141:Celestial Earring|70:611151:Eclipse Earring|75:611161:Astral Earring|80:611171:Ethereal Earring|85:611181:Void Earring|90:611191:Abyss Earring
gloves	Gloves	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:520001:Leather Gloves|5:520002:Empire Gloves|10:520003:Iron Gloves|15:520004:Knight Gloves|20:520005:Chain Gloves|25:520006:Fate Gloves|30:520007:War Gloves|35:520008:Heavy Gloves|40:520009:Rune Gloves|45:520010:Plate Gloves|50:520011:Mystic Gloves|55:520012:Great Gloves|60:520013:Ancient Gloves|65:520014:Shine Gloves|70:520015:Void Gloves|75:520016:Dragon Gloves|80:520017:Dimensional Gloves|85:520018:Shadow Gloves|90:520019:Eternal Gloves|100:520020:Radiant Gloves
hatchet	Hatchet	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:450001:Short Hatchet|5:450002:Leather Hatchet|10:450003:Long Hatchet|15:450004:Steel Hatchet|20:450005:War Hatchet|25:450006:Composite Hatchet|30:450007:Battle Hatchet|35:450008:Wing Hatchet|40:450009:Elite Hatchet|45:450010:Large Hatchet|50:450011:Mystic Hatchet|55:450012:Swift Hatchet|60:450013:Ancient Hatchet|65:450014:Limitless Hatchet|70:450015:Chaos Hatchet|75:450016:Power Hatchet|80:450017:Dimensional Hatchet|85:450018:Shadow Hatchet|90:450019:Eternal Hatchet|100:450020:Exalted Hatchet
helmet	Helmet	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:500001:Wooden Helmet|5:500002:Empire Helmet|10:500003:Iron Helmet|15:500004:Knight Helmet|20:500005:Chain Helmet|25:500006:Medium Helmet|30:500007:War Helmet|35:500008:Emperor Helmet|40:500009:Rune Helmet|45:500010:Red Helmet|50:500011:Fate Helmet|55:500012:Great Helmet|60:500013:Storm Helmet|65:500014:Fighter's Helmet|70:500015:Void Helmet|75:500016:Crystal Helmet|80:500017:Dimensional Helmet|85:500018:Shadow Helmet|90:500019:Eternal Helmet|100:500020:Radiant Helmet
orb	Orb	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:420001:Magic Orb|5:420002:Elder Orb|10:420003:Brilliant Orb|15:420004:Frozen Orb|20:420005:Prophecy Orb|25:420006:Dark Orb|30:420007:Rune Orb|35:420008:Shining Orb|40:420009:Arcane Orb|45:420010:Fate Orb|50:420011:Mystic Orb|55:420012:Sky Orb|60:420013:Spirit Orb|65:420014:Ancient Orb|70:420015:Abyssal Orb|75:420016:Void Orb|80:420017:Dimensional Orb|85:420018:Shadow Orb|90:420019:Eternal Orb|100:420020:Aureate Orb
ring	Ring	272	19	Common:0,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:621011:Copper Ring|5:621021:Bronze Ring|10:621031:Silver Ring|15:621041:Gold Ring|20:621051:Platinum Ring|25:621061:Crystal Ring|30:621071:Amber Ring|35:621081:Topaz Ring|40:621091:Amethyst Ring|45:621101:Garnet Ring|50:621111:Emerald Ring|55:621121:Diamond Ring|60:621131:Moonstone Ring|65:621141:Eclipse Ring|70:621151:Celestial Ring|75:621161:Astral Ring|80:621171:Ethereal Ring|85:621181:Void Ring|90:621191:Abyss Ring
scepter	Scepter	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:330001:Novice Scepter|5:330002:Iron Scepter|10:330003:Blessed Scepter|15:330004:Steel Scepter|20:330005:Sacred Scepter|25:330006:Bishop's Scepter|30:330007:Devout Scepter|35:330008:Heavy Scepter|40:330009:Rune Scepter|45:330010:Legend Scepter|50:330011:Fate Scepter|55:330012:Hero Scepter|60:330013:Storm Scepter|65:330014:Limitless Scepter|70:330015:Chaos Scepter|75:330016:Power Scepter|80:330017:Dimensional Scepter|85:330018:Shadow Scepter|90:330019:Eternal Scepter|100:330020:Radiant Scepter
shield	Shield	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:400001:Buckler|5:400002:Wooden Shield|10:400003:Iron Shield|15:400004:Heater Shield|20:400005:Heavy Shield|25:400006:Forest Shield|30:400007:War Shield|35:400008:Barrier Shield|40:400009:Elite Shield|45:400010:Crimson Shield|50:400011:Mystic Shield|55:400012:Grand Shield|60:400013:Ancient Shield|65:400014:Radiant Shield|70:400015:Void Shield|75:400016:Divine Shield|80:400017:Dimensional Shield|85:400018:Shadow Shield|90:400019:Eternal Shield|100:400020:Dragon Shield
staff	Staff	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:320001:Wooden Staff|5:320002:Herald Staff|10:320003:Long Staff|15:320004:Witch Staff|20:320005:Azure Staff|25:320006:Elder Staff|30:320007:Sage Staff|35:320008:Mystic Staff|40:320009:Comet Staff|45:320010:Crystal Staff|50:320011:Void Staff|55:320012:Conqueror Staff|60:320013:Ancient Staff|65:320014:Sacred Staff|70:320015:Abyssal Staff|75:320016:Chaos Staff|80:320017:Tempest Staff|85:320018:Nova Staff|90:320019:Eternal Staff|100:320020:Radiant Staff
sword	Sword	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:300001:Long Sword|5:300002:Cutlas|10:300003:Rapier|15:300004:Bastard Sword|20:300005:Great Sword|25:300006:Heavy Blade|30:300007:Knight Sword|35:300008:Commander's Sword|40:300009:Rune Sword|45:300010:Legend Sword|50:300011:Fate Sword|55:300012:Hero Sword|60:300013:Storm Sword|65:300014:Vengeance Sword|70:300015:Void Blade|75:300016:Crystal Blade|80:300017:Dimensional Sword|85:300018:Shadow Blade|90:300019:Eternal Sword|100:300020:Radiant Sword
tome	Tome	292	20	Common:20,Uncommon:38,Rare:38,Legendary:38,Immortal:38,Arcana:32,Beyond:28,Celestial:24,Divine:20,Cosmic:16	1:430001:Prayer Tome|5:430002:Empire Tome|10:430003:Iron Tome|15:430004:Knight's Tome|20:430005:Blessed Tome|25:430006:Commander's Tome|30:430007:War Tome|35:430008:Emperor's Tome|40:430009:Rune Tome|45:430010:Crimson Tome|50:430011:Fate Tome|55:430012:Grand Tome|60:430013:Storm Tome|65:430014:Warrior's Tome|70:430015:Void Tome|75:430016:Crystal Tome|80:430017:Dimensional Tome|85:430018:Shadow Tome|90:430019:Eternal Tome|100:430020:Empyrean Tome
"""
}

/// 物品 — 身份由 id 决定，== 与 hash 保持同一契约
struct Item: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let rarity: Rarity
    let slot: EquipSlot?
    let equipmentType: EquipmentType?
    let itemLevel: Int
    let stats: ItemStats
    let description: String
    let isLocked: Bool

    init(
        id: String,
        name: String,
        rarity: Rarity,
        slot: EquipSlot?,
        stats: ItemStats,
        description: String,
        itemLevel: Int = 1,
        isLocked: Bool = false,
        equipmentType: EquipmentType? = nil
    ) {
        self.id = id
        self.name = name
        self.rarity = rarity
        let resolvedType = equipmentType ?? EquipmentType.defaultType(for: slot)
        self.slot = resolvedType?.equipSlot ?? (slot == .accessory ? .ring : slot)
        self.equipmentType = resolvedType
        self.itemLevel = max(1, itemLevel)
        self.stats = stats
        self.description = description
        self.isLocked = isLocked
    }

    static func == (lhs: Item, rhs: Item) -> Bool { lhs.id == rhs.id }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func locked(_ isLocked: Bool) -> Item {
        Item(
            id: id,
            name: name,
            rarity: rarity,
            slot: slot,
            stats: stats,
            description: description,
            itemLevel: itemLevel,
            isLocked: isLocked,
            equipmentType: equipmentType
        )
    }

    enum CodingKeys: String, CodingKey {
        case id, name, rarity, slot, equipmentType, itemLevel, stats, description, isLocked
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        rarity = try c.decode(Rarity.self, forKey: .rarity)
        let decodedSlot = try c.decodeIfPresent(EquipSlot.self, forKey: .slot)
        let decodedType = try c.decodeIfPresent(EquipmentType.self, forKey: .equipmentType)
        let resolvedType = decodedType ?? EquipmentType.defaultType(for: decodedSlot)
        equipmentType = resolvedType
        slot = resolvedType?.equipSlot ?? (decodedSlot == .accessory ? .ring : decodedSlot)
        stats = try c.decode(ItemStats.self, forKey: .stats)
        let decodedDescription = try c.decode(String.self, forKey: .description)
        description = decodedDescription
        itemLevel = max(
            1,
            try c.decodeIfPresent(Int.self, forKey: .itemLevel) ?? Self.inferItemLevel(from: decodedDescription)
        )
        isLocked = try c.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
    }

    private static func inferItemLevel(from description: String) -> Int {
        guard description.hasPrefix("Lv.") else { return 1 }
        let digits = description.dropFirst(3).prefix { $0.isNumber }
        return Int(digits) ?? 1
    }
}

struct ItemStats: Codable, Equatable, Hashable {
    var bonusHP: Int = 0
    var bonusATK: Int = 0
    var bonusDEF: Int = 0
    var bonusSPD: Int = 0
    var bonusCritRate: Double = 0
    var bonusCritDamage: Double = 0

    var equipmentScore: Double {
        Double(bonusHP)
        + Double(bonusATK) * 5
        + Double(bonusDEF) * 3
        + Double(bonusSPD) * 2
        + bonusCritRate * 100
        + bonusCritDamage * 50
    }
}

struct SynthesisPreview: Equatable {
    let inputRarity: Rarity
    let outputRarity: Rarity?
    let unlockedInputCount: Int
    let lockedInputCount: Int
    let selectedInputCount: Int
    let outputItemLevel: Int?

    var isReady: Bool {
        outputRarity != nil && selectedInputCount == Rarity.synthesisInputCount
    }

    var sourceVariantBoundary: String? {
        guard outputRarity != nil else { return nil }
        return "跳阶/降级概率未核实"
    }

    static func make(for rarity: Rarity, in items: [Item]) -> SynthesisPreview {
        let unlockedInputs = eligibleUnlockedInputs(for: rarity, in: items)
        let selectedInputs = Array(unlockedInputs.prefix(Rarity.synthesisInputCount))
        let lockedInputCount = items.filter { $0.rarity == rarity && $0.isLocked }.count
        let outputLevel = selectedInputs.count == Rarity.synthesisInputCount
            ? selectedInputs.map(\.itemLevel).max()
            : nil

        return SynthesisPreview(
            inputRarity: rarity,
            outputRarity: rarity.synthesisOutputRarity,
            unlockedInputCount: unlockedInputs.count,
            lockedInputCount: lockedInputCount,
            selectedInputCount: selectedInputs.count,
            outputItemLevel: outputLevel
        )
    }

    static func selectedInputs(for rarity: Rarity, in items: [Item]) -> [Item] {
        Array(eligibleUnlockedInputs(for: rarity, in: items).prefix(Rarity.synthesisInputCount))
    }

    private static func eligibleUnlockedInputs(for rarity: Rarity, in items: [Item]) -> [Item] {
        items.filter { $0.rarity == rarity && !$0.isLocked }
    }
}

extension Item {
    var equipmentScore: Double {
        stats.equipmentScore + Double(rarity.rank) * 0.01
    }

    func isBetterEquipment(than current: Item?) -> Bool {
        guard slot != nil else { return false }
        guard let current else { return true }
        guard current.slot == slot else { return true }
        return equipmentScore > current.equipmentScore
    }
}

extension Rarity {
    static let synthesisInputCount = 9

    var rank: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }

    var synthesisOutputRarity: Rarity? {
        guard let index = Self.allCases.firstIndex(of: self) else { return nil }
        let nextIndex = Self.allCases.index(after: index)
        guard Self.allCases.indices.contains(nextIndex) else { return nil }
        return Self.allCases[nextIndex]
    }

    var alchemyGoldValue: Int {
        switch self {
        case .common: return 10
        case .uncommon: return 30
        case .rare: return 90
        case .legendary: return 270
        case .immortal: return 810
        case .arcana: return 2_592
        case .beyond: return 8_294
        case .celestial: return 29_029
        case .divine: return 101_602
        case .cosmic: return 355_607
        }
    }

    var cubeExperience: Int {
        switch self {
        case .common: return 2
        case .uncommon: return 6
        case .rare: return 18
        case .legendary: return 54
        case .immortal: return 162
        case .arcana: return 518
        case .beyond: return 1_658
        case .celestial: return 5_803
        case .divine: return 20_311
        case .cosmic: return 71_089
        }
    }

    var decorationSlots: Int {
        switch self {
        case .common: return 0
        case .uncommon, .rare: return 1
        case .legendary, .immortal: return 2
        case .arcana, .beyond, .celestial, .divine, .cosmic: return 3
        }
    }

    var engravingSlots: Int {
        switch self {
        case .common, .uncommon: return 0
        case .rare: return 1
        case .legendary, .immortal, .arcana, .beyond, .celestial, .divine, .cosmic: return 2
        }
    }

    var inscriptionSlots: Int {
        switch self {
        case .common, .uncommon, .rare, .legendary: return 0
        case .immortal, .arcana: return 1
        case .beyond, .celestial, .divine, .cosmic: return 2
        }
    }

    var slotSummary: String {
        "\(decorationSlots)/\(engravingSlots)/\(inscriptionSlots)"
    }
}

/// 装备栏
struct EquipmentLoadout: Codable {
    var weapon: Item? = nil
    var offhand: Item? = nil
    var armor: Item? = nil
    var helmet: Item? = nil
    var gloves: Item? = nil
    var boots: Item? = nil
    var amulet: Item? = nil
    var earring: Item? = nil
    var ring: Item? = nil
    var bracer: Item? = nil

    init() {}

    var bonusHP: Int { sum(\.bonusHP) }
    var bonusATK: Int { sum(\.bonusATK) }
    var bonusDEF: Int { sum(\.bonusDEF) }
    var bonusSPD: Int { sum(\.bonusSPD) }
    var bonusCritRate: Double { sum(\.bonusCritRate) }
    var bonusCritDamage: Double { sum(\.bonusCritDamage) }

    private var equippedItems: [Item] {
        [weapon, offhand, armor, helmet, gloves, boots, amulet, earring, ring, bracer].compactMap { $0 }
    }

    func item(in slot: EquipSlot) -> Item? {
        switch slot {
        case .weapon: return weapon
        case .offhand: return offhand
        case .armor: return armor
        case .helmet: return helmet
        case .gloves: return gloves
        case .boots: return boots
        case .amulet: return amulet
        case .earring: return earring
        case .ring: return ring
        case .bracer: return bracer
        case .accessory: return ring ?? amulet ?? earring ?? bracer
        }
    }

    private func sum<T: AdditiveArithmetic>(_ keyPath: KeyPath<ItemStats, T>) -> T {
        equippedItems.reduce(.zero) { $0 + $1.stats[keyPath: keyPath] }
    }

    mutating func equip(_ item: Item) -> Item? {
        guard let slot = item.slot else { return nil }
        let old: Item?
        switch slot {
        case .weapon: old = weapon; weapon = item
        case .offhand: old = offhand; offhand = item
        case .armor: old = armor; armor = item
        case .helmet: old = helmet; helmet = item
        case .gloves: old = gloves; gloves = item
        case .boots: old = boots; boots = item
        case .amulet: old = amulet; amulet = item
        case .earring: old = earring; earring = item
        case .ring, .accessory: old = ring; ring = item
        case .bracer: old = bracer; bracer = item
        }
        return old
    }

    enum CodingKeys: String, CodingKey {
        case weapon, offhand, armor, helmet, gloves, boots, amulet, earring, ring, bracer, accessory
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        weapon = try c.decodeIfPresent(Item.self, forKey: .weapon)
        offhand = try c.decodeIfPresent(Item.self, forKey: .offhand)
        armor = try c.decodeIfPresent(Item.self, forKey: .armor)
        helmet = try c.decodeIfPresent(Item.self, forKey: .helmet)
        gloves = try c.decodeIfPresent(Item.self, forKey: .gloves)
        boots = try c.decodeIfPresent(Item.self, forKey: .boots)
        amulet = try c.decodeIfPresent(Item.self, forKey: .amulet)
        earring = try c.decodeIfPresent(Item.self, forKey: .earring)
        ring = try c.decodeIfPresent(Item.self, forKey: .ring)
        bracer = try c.decodeIfPresent(Item.self, forKey: .bracer)

        if ring == nil {
            ring = try c.decodeIfPresent(Item.self, forKey: .accessory)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(weapon, forKey: .weapon)
        try c.encodeIfPresent(offhand, forKey: .offhand)
        try c.encodeIfPresent(armor, forKey: .armor)
        try c.encodeIfPresent(helmet, forKey: .helmet)
        try c.encodeIfPresent(gloves, forKey: .gloves)
        try c.encodeIfPresent(boots, forKey: .boots)
        try c.encodeIfPresent(amulet, forKey: .amulet)
        try c.encodeIfPresent(earring, forKey: .earring)
        try c.encodeIfPresent(ring, forKey: .ring)
        try c.encodeIfPresent(bracer, forKey: .bracer)
    }
}
