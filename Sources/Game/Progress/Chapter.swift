import Foundation

/// 章节定义
enum Chapter: Int, CaseIterable, Codable {
    case forest = 1
    case dungeon = 2
    case volcano = 3

    var name: String {
        switch self {
        case .forest: return "迷雾森林"
        case .dungeon: return "暗影地牢"
        case .volcano: return "烈焰火山"
        }
    }

    var monsterPool: [String] {
        switch self {
        case .forest: return ["slime_green", "slime_blue", "bat", "spider", "wolf"]
        case .dungeon: return ["skeleton", "goblin", "zombie", "spider"]
        case .volcano: return ["golem", "dragon_whelp", "skeleton", "zombie"]
        }
    }

    var baseGoldPerKill: Int {
        switch self {
        case .forest: return 15
        case .dungeon: return 35
        case .volcano: return 70
        }
    }

    var baseXPPerKill: Int {
        switch self {
        case .forest: return 20
        case .dungeon: return 50
        case .volcano: return 100
        }
    }

    /// 平均击杀时间（秒），用于离线收益估算
    var avgKillTime: TimeInterval {
        switch self {
        case .forest: return 5.0
        case .dungeon: return 8.0
        case .volcano: return 12.0
        }
    }

    func spawnMonster(difficulty: Difficulty) -> Monster {
        let eligible = monsterPool.compactMap { id in
            Monster.allMonsters.first { $0.id == id }
        }
        let monster = eligible.randomElement() ?? Monster.allMonsters[0]

        // 难度缩放
        let scale = difficulty.statMultiplier
        return Monster(
            id: monster.id,
            name: monster.name,
            hp: Int(Double(monster.hp) * scale),
            atk: Int(Double(monster.atk) * scale),
            def: Int(Double(monster.def) * scale),
            spd: monster.spd,
            critRate: monster.critRate,
            xpReward: Int(Double(monster.xpReward) * scale),
            goldReward: Int(Double(monster.goldReward) * scale),
            lootTableID: monster.lootTableID
        )
    }
}
