import Foundation

/// 怪物定义
struct Monster: Identifiable, Codable {
    let id: String
    let name: String
    let hp: Int
    let atk: Int
    let def: Int
    let spd: Int
    let critRate: Double
    let xpReward: Int
    let goldReward: Int
    let lootTableID: String
    let itemLevelCap: Int
    let sourceSkillID: String?

    init(
        id: String,
        name: String,
        hp: Int,
        atk: Int,
        def: Int,
        spd: Int,
        critRate: Double,
        xpReward: Int,
        goldReward: Int,
        lootTableID: String,
        itemLevelCap: Int = 1,
        sourceSkillID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.hp = hp
        self.atk = atk
        self.def = def
        self.spd = spd
        self.critRate = critRate
        self.xpReward = xpReward
        self.goldReward = goldReward
        self.lootTableID = lootTableID
        self.itemLevelCap = max(1, itemLevelCap)
        self.sourceSkillID = sourceSkillID
    }

    var sourceSkill: SourceSkill? {
        sourceSkillID.flatMap(SourceSkillCatalog.skill(id:))
    }

    var sourceDamageElement: SkillDamageElement {
        sourceSkill?.runtimeDamageElement ?? .none
    }

    var sourceDelivery: SkillDelivery {
        sourceSkill?.runtimeDelivery ?? .none
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case hp
        case atk
        case def
        case spd
        case critRate
        case xpReward
        case goldReward
        case lootTableID
        case itemLevelCap
        case sourceSkillID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(String.self, forKey: .id),
            name: try container.decode(String.self, forKey: .name),
            hp: try container.decode(Int.self, forKey: .hp),
            atk: try container.decode(Int.self, forKey: .atk),
            def: try container.decode(Int.self, forKey: .def),
            spd: try container.decode(Int.self, forKey: .spd),
            critRate: try container.decode(Double.self, forKey: .critRate),
            xpReward: try container.decode(Int.self, forKey: .xpReward),
            goldReward: try container.decode(Int.self, forKey: .goldReward),
            lootTableID: try container.decode(String.self, forKey: .lootTableID),
            itemLevelCap: try container.decodeIfPresent(Int.self, forKey: .itemLevelCap) ?? 1,
            sourceSkillID: try container.decodeIfPresent(String.self, forKey: .sourceSkillID)
        )
    }

    static let allMonsters: [Monster] = [
        Monster(id: "slime_green", name: "绿色史莱姆", hp: 50, atk: 8, def: 3, spd: 5, critRate: 0.02, xpReward: 15, goldReward: 10, lootTableID: "slime_drops"),
        Monster(id: "slime_blue", name: "蓝色史莱姆", hp: 80, atk: 12, def: 5, spd: 6, critRate: 0.03, xpReward: 25, goldReward: 18, lootTableID: "slime_drops"),
        Monster(id: "skeleton", name: "骷髅兵", hp: 120, atk: 18, def: 12, spd: 7, critRate: 0.05, xpReward: 40, goldReward: 30, lootTableID: "undead_drops"),
        Monster(id: "goblin", name: "哥布林", hp: 70, atk: 14, def: 6, spd: 10, critRate: 0.08, xpReward: 30, goldReward: 25, lootTableID: "goblin_drops"),
        Monster(id: "wolf", name: "灰狼", hp: 90, atk: 20, def: 8, spd: 12, critRate: 0.1, xpReward: 35, goldReward: 20, lootTableID: "beast_drops"),
        Monster(id: "bat", name: "蝙蝠", hp: 40, atk: 10, def: 2, spd: 15, critRate: 0.05, xpReward: 12, goldReward: 8, lootTableID: "beast_drops"),
        Monster(id: "zombie", name: "僵尸", hp: 200, atk: 15, def: 20, spd: 3, critRate: 0.01, xpReward: 50, goldReward: 35, lootTableID: "undead_drops"),
        Monster(id: "spider", name: "毒蜘蛛", hp: 60, atk: 16, def: 4, spd: 11, critRate: 0.07, xpReward: 22, goldReward: 15, lootTableID: "beast_drops"),
        Monster(id: "golem", name: "石头傀儡", hp: 300, atk: 25, def: 35, spd: 2, critRate: 0.0, xpReward: 80, goldReward: 60, lootTableID: "golem_drops"),
        Monster(id: "dragon_whelp", name: "幼龙", hp: 250, atk: 30, def: 25, spd: 8, critRate: 0.12, xpReward: 100, goldReward: 80, lootTableID: "dragon_drops")
    ]
}
