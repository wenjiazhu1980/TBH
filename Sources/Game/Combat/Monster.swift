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
