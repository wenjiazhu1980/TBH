import Foundation

/// Act 定义。保留 `Chapter` 命名是为了兼容旧存档和现有调用点。
enum Chapter: Int, CaseIterable, Codable {
    case forest = 1
    case dungeon = 2
    case volcano = 3

    var name: String {
        switch self {
        case .forest: return "Act 1 — 绿野与诅咒之地"
        case .dungeon: return "Act 2 — 沙漠与古墓"
        case .volcano: return "Act 3 — 冰封荒原与地狱"
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
        StageDefinition.stage(act: self, number: 1).spawnMonster(difficulty: difficulty)
    }
}
