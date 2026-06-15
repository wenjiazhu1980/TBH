import Foundation

/// 掉落表
struct LootTable {
    static func roll(for monster: Monster) -> Item? {
        // 40% 掉落概率
        guard Double.random(in: 0..<1) < 0.4 else { return nil }

        let itemLevel = itemLevel(for: monster)
        let rarity = rollRarity(itemLevel: itemLevel)
        return generateRandomItem(rarity: rarity, itemLevel: itemLevel)
    }

    static func itemLevel(for monster: Monster) -> Int {
        max(1, monster.itemLevelCap)
    }

    static func roll(for chest: LootChest) -> Item {
        let rarity = rollRarity(itemLevel: chest.itemLevel)
        return generateRandomItem(rarity: rarity, itemLevel: chest.itemLevel)
    }

    private static func rollRarity(itemLevel: Int) -> Rarity {
        let roll = Double.random(in: 0..<1)
        if itemLevel >= 90 {
            if roll < 0.02 { return .cosmic }
            if roll < 0.05 { return .divine }
            if roll < 0.10 { return .celestial }
            if roll < 0.18 { return .beyond }
            if roll < 0.30 { return .arcana }
            if roll < 0.45 { return .immortal }
            if roll < 0.60 { return .legendary }
            if roll < 0.78 { return .rare }
            if roll < 0.90 { return .uncommon }
            return .common
        }
        if itemLevel >= 70 {
            if roll < 0.02 { return .celestial }
            if roll < 0.06 { return .beyond }
            if roll < 0.14 { return .arcana }
            if roll < 0.28 { return .immortal }
            if roll < 0.45 { return .legendary }
            if roll < 0.65 { return .rare }
            if roll < 0.85 { return .uncommon }
            return .common
        }
        if itemLevel >= 50 {
            if roll < 0.02 { return .arcana }
            if roll < 0.08 { return .immortal }
            if roll < 0.20 { return .legendary }
            if roll < 0.45 { return .rare }
            if roll < 0.75 { return .uncommon }
            return .common
        }
        if itemLevel >= 30 {
            if roll < 0.02 { return .immortal }
            if roll < 0.12 { return .legendary }
            if roll < 0.35 { return .rare }
            if roll < 0.65 { return .uncommon }
            return .common
        }
        if itemLevel >= 10 {
            if roll < 0.02 { return .legendary }
            if roll < 0.16 { return .rare }
            if roll < 0.45 { return .uncommon }
            return .common
        }
        if roll < 0.25 { return .uncommon }
        return .common
    }

    static func makeItem(type: EquipmentType, rarity: Rarity, itemLevel: Int = 1) -> Item {
        let slot = type.equipSlot
        let multiplier: Double
        switch rarity {
        case .common: multiplier = 1.0
        case .uncommon: multiplier = 1.5
        case .rare: multiplier = 2.5
        case .legendary: multiplier = 4.0
        case .immortal: multiplier = 5.5
        case .arcana: multiplier = 7.5
        case .beyond: multiplier = 10.0
        case .celestial: multiplier = 13.0
        case .divine: multiplier = 17.0
        case .cosmic: multiplier = 22.0
        }
        let levelMultiplier = 1.0 + Double(max(itemLevel - 1, 0)) * 0.08

        let baseATK = Int(Double(Int.random(in: 3...15)) * multiplier * levelMultiplier)
        let baseDEF = Int(Double(Int.random(in: 2...10)) * multiplier * levelMultiplier)
        let baseHP = Int(Double(Int.random(in: 10...50)) * multiplier * levelMultiplier)

        let namePrefix: String
        switch rarity {
        case .common: namePrefix = ["旧", "普通的", "简陋的"].randomElement()!
        case .uncommon: namePrefix = ["精良的", "坚固的", "锋利的"].randomElement()!
        case .rare: namePrefix = ["魔法", "附魔", "秘银"].randomElement()!
        case .legendary: namePrefix = ["远古", "龙裔", "神圣"].randomElement()!
        case .immortal: namePrefix = ["不朽", "赤红", "永恒"].randomElement()!
        case .arcana: namePrefix = ["奥秘", "秘法", "星界"].randomElement()!
        case .beyond: namePrefix = ["超越", "虚空", "深渊"].randomElement()!
        case .celestial: namePrefix = ["天界", "辉耀", "星辰"].randomElement()!
        case .divine: namePrefix = ["神圣", "审判", "光辉"].randomElement()!
        case .cosmic: namePrefix = ["宇宙", "混沌", "创世"].randomElement()!
        }

        let slotName = type.localizedName

        let stats: ItemStats
        switch type.category {
        case .weapon:
            stats = ItemStats(
                bonusHP: baseHP / 4,
                bonusATK: baseATK,
                bonusDEF: baseDEF / 4,
                bonusSPD: type == .bow || type == .crossbow ? max(1, Int(Double(Int.random(in: 1...4)) * multiplier / 3.0)) : 0,
                bonusCritRate: rarity >= .rare ? Double.random(in: 0.01...0.05) * (1.0 + Double(rarity.rank) * 0.08) : 0,
                bonusCritDamage: rarity >= .legendary ? Double.random(in: 0.1...0.3) * (1.0 + Double(rarity.rank) * 0.08) : 0
            )
        case .offhand:
            stats = ItemStats(
                bonusHP: baseHP / 2,
                bonusATK: type == .arrow || type == .bolt || type == .hatchet ? baseATK / 2 : baseATK / 3,
                bonusDEF: type == .shield ? baseDEF : baseDEF / 2,
                bonusSPD: type == .arrow || type == .bolt ? max(1, Int(Double(Int.random(in: 1...4)) * multiplier / 3.0)) : 0,
                bonusCritRate: rarity >= .rare ? Double.random(in: 0.01...0.04) * (1.0 + Double(rarity.rank) * 0.07) : 0,
                bonusCritDamage: rarity >= .legendary ? Double.random(in: 0.08...0.22) * (1.0 + Double(rarity.rank) * 0.07) : 0
            )
        case .armor:
            stats = ItemStats(
                bonusHP: type == .armor || type == .helmet ? baseHP : baseHP / 2,
                bonusATK: type == .gloves ? baseATK / 2 : baseATK / 4,
                bonusDEF: type == .boots ? baseDEF / 2 : baseDEF,
                bonusSPD: type == .boots || type == .gloves ? max(1, Int(Double(Int.random(in: 1...5)) * multiplier / 2.0)) : 0,
                bonusCritRate: type == .gloves && rarity >= .rare ? Double.random(in: 0.01...0.04) * (1.0 + Double(rarity.rank) * 0.08) : 0,
                bonusCritDamage: rarity >= .legendary ? Double.random(in: 0.05...0.18) * (1.0 + Double(rarity.rank) * 0.06) : 0
            )
        case .accessory:
            stats = ItemStats(
                bonusHP: type == .amulet || type == .bracer ? baseHP / 2 : baseHP / 3,
                bonusATK: type == .ring ? baseATK / 2 : baseATK / 3,
                bonusDEF: type == .bracer ? baseDEF : baseDEF / 3,
                bonusSPD: type == .earring ? max(1, Int(Double(Int.random(in: 1...5)) * multiplier / 2.0)) : 0,
                bonusCritRate: rarity >= .rare ? Double.random(in: 0.015...0.06) * (1.0 + Double(rarity.rank) * 0.09) : 0,
                bonusCritDamage: rarity >= .legendary ? Double.random(in: 0.1...0.32) * (1.0 + Double(rarity.rank) * 0.08) : 0
            )
        }

        return Item(
            id: UUID().uuidString,
            name: "\(namePrefix)\(slotName)",
            rarity: rarity,
            slot: slot,
            stats: stats,
            description: "Lv.\(itemLevel) \(rarity.rawValue)品质的\(type.typeLine)",
            itemLevel: itemLevel,
            equipmentType: type
        )
    }

    private static func generateRandomItem(rarity: Rarity, itemLevel: Int = 1) -> Item {
        let type = EquipmentType.allCases.randomElement() ?? .sword
        return makeItem(type: type, rarity: rarity, itemLevel: itemLevel)
    }
}
