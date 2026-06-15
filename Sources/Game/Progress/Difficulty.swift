import Foundation

/// 难度等级
enum Difficulty: Int, CaseIterable, Codable {
    case normal = 1
    case nightmare = 2
    case hell = 3
    case torment = 4

    var name: String {
        switch self {
        case .normal: return "普通"
        case .nightmare: return "噩梦"
        case .hell: return "地狱"
        case .torment: return "苦痛"
        }
    }

    var statMultiplier: Double {
        switch self {
        case .normal: return 1.0
        case .nightmare: return 1.8
        case .hell: return 3.0
        case .torment: return 5.0
        }
    }

    var xpMultiplier: Double {
        switch self {
        case .normal: return 1.0
        case .nightmare: return 1.5
        case .hell: return 2.5
        case .torment: return 4.0
        }
    }

    var goldMultiplier: Double {
        switch self {
        case .normal: return 1.0
        case .nightmare: return 1.5
        case .hell: return 2.5
        case .torment: return 4.0
        }
    }
}
