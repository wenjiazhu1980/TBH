import Foundation

/// 物品稀有度
enum Rarity: String, Codable, CaseIterable, Comparable {
    case common = "普通"
    case uncommon = "优秀"
    case rare = "稀有"
    case legendary = "传说"

    var color: String {
        switch self {
        case .common: return "#FFFFFF"
        case .uncommon: return "#1EFF00"
        case .rare: return "#0070FF"
        case .legendary: return "#FF8000"
        }
    }

    /// 按 allCases 声明顺序比较（common < uncommon < rare < legendary）
    static func < (lhs: Rarity, rhs: Rarity) -> Bool {
        guard let l = allCases.firstIndex(of: lhs),
              let r = allCases.firstIndex(of: rhs) else { return false }
        return l < r
    }
}

/// 装备槽位
enum EquipSlot: String, Codable, CaseIterable {
    case weapon = "武器"
    case armor = "护甲"
    case helmet = "头盔"
    case boots = "靴子"
    case accessory = "饰品"
}

/// 物品 — 身份由 id 决定，== 与 hash 保持同一契约
struct Item: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let rarity: Rarity
    let slot: EquipSlot?
    let stats: ItemStats
    let description: String

    static func == (lhs: Item, rhs: Item) -> Bool { lhs.id == rhs.id }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ItemStats: Codable, Equatable, Hashable {
    var bonusHP: Int = 0
    var bonusATK: Int = 0
    var bonusDEF: Int = 0
    var bonusSPD: Int = 0
    var bonusCritRate: Double = 0
    var bonusCritDamage: Double = 0
}

/// 装备栏
struct EquipmentLoadout: Codable {
    var weapon: Item? = nil
    var armor: Item? = nil
    var helmet: Item? = nil
    var boots: Item? = nil
    var accessory: Item? = nil

    var bonusHP: Int { sum(\.bonusHP) }
    var bonusATK: Int { sum(\.bonusATK) }
    var bonusDEF: Int { sum(\.bonusDEF) }
    var bonusSPD: Int { sum(\.bonusSPD) }
    var bonusCritRate: Double { sum(\.bonusCritRate) }
    var bonusCritDamage: Double { sum(\.bonusCritDamage) }

    private var equippedItems: [Item] {
        [weapon, armor, helmet, boots, accessory].compactMap { $0 }
    }

    private func sum<T: AdditiveArithmetic>(_ keyPath: KeyPath<ItemStats, T>) -> T {
        equippedItems.reduce(.zero) { $0 + $1.stats[keyPath: keyPath] }
    }

    mutating func equip(_ item: Item) -> Item? {
        guard let slot = item.slot else { return nil }
        let old: Item?
        switch slot {
        case .weapon: old = weapon; weapon = item
        case .armor: old = armor; armor = item
        case .helmet: old = helmet; helmet = item
        case .boots: old = boots; boots = item
        case .accessory: old = accessory; accessory = item
        }
        return old
    }
}
