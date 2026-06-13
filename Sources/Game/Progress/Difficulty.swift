import Foundation

/// 难度等级
enum Difficulty: Int, CaseIterable, Codable {
    case normal = 1
    case hard = 2
    case nightmare = 3
    case hell = 4

    var name: String {
        switch self {
        case .normal: return "普通"
        case .hard: return "困难"
        case .nightmare: return "噩梦"
        case .hell: return "地狱"
        }
    }

    var statMultiplier: Double {
        switch self {
        case .normal: return 1.0
        case .hard: return 1.8
        case .nightmare: return 3.0
        case .hell: return 5.0
        }
    }

    var xpMultiplier: Double {
        switch self {
        case .normal: return 1.0
        case .hard: return 1.5
        case .nightmare: return 2.5
        case .hell: return 4.0
        }
    }

    var goldMultiplier: Double {
        switch self {
        case .normal: return 1.0
        case .hard: return 1.5
        case .nightmare: return 2.5
        case .hell: return 4.0
        }
    }
}
