import Foundation

/// 掉落表
struct LootTable {
    static func roll(for monster: Monster) -> Item? {
        // 40% 掉落概率
        guard Double.random(in: 0..<1) < 0.4 else { return nil }

        // 根据怪物等级决定稀有度
        let rarity = rollRarity(monsterLevel: monster.xpReward)
        return generateRandomItem(rarity: rarity)
    }

    private static func rollRarity(monsterLevel: Int) -> Rarity {
        let roll = Double.random(in: 0..<1)
        if monsterLevel > 80 && roll < 0.05 { return .legendary }
        if monsterLevel > 40 && roll < 0.15 { return .rare }
        if roll < 0.35 { return .uncommon }
        return .common
    }

    private static func generateRandomItem(rarity: Rarity) -> Item {
        let slot = EquipSlot.allCases.randomElement() ?? .weapon
        let multiplier: Double
        switch rarity {
        case .common: multiplier = 1.0
        case .uncommon: multiplier = 1.5
        case .rare: multiplier = 2.5
        case .legendary: multiplier = 4.0
        }

        let baseATK = Int(Double(Int.random(in: 3...15)) * multiplier)
        let baseDEF = Int(Double(Int.random(in: 2...10)) * multiplier)
        let baseHP = Int(Double(Int.random(in: 10...50)) * multiplier)

        let namePrefix: String
        switch rarity {
        case .common: namePrefix = ["旧", "普通的", "简陋的"].randomElement()!
        case .uncommon: namePrefix = ["精良的", "坚固的", "锋利的"].randomElement()!
        case .rare: namePrefix = ["魔法", "附魔", "秘银"].randomElement()!
        case .legendary: namePrefix = ["远古", "龙裔", "神圣"].randomElement()!
        }

        let slotName: String
        switch slot {
        case .weapon: slotName = ["剑", "斧", "锤", "匕首"].randomElement()!
        case .armor: slotName = ["铠甲", "皮甲", "锁甲"].randomElement()!
        case .helmet: slotName = ["头盔", "兜帽", "王冠"].randomElement()!
        case .boots: slotName = ["长靴", "便鞋", "战靴"].randomElement()!
        case .accessory: slotName = ["戒指", "项链", "护符"].randomElement()!
        }

        return Item(
            id: UUID().uuidString,
            name: "\(namePrefix)\(slotName)",
            rarity: rarity,
            slot: slot,
            stats: ItemStats(
                bonusHP: slot == .armor || slot == .helmet ? baseHP : baseHP / 3,
                bonusATK: slot == .weapon ? baseATK : baseATK / 3,
                bonusDEF: slot == .armor || slot == .boots ? baseDEF : baseDEF / 3,
                bonusSPD: slot == .boots ? Int.random(in: 1...5) : 0,
                bonusCritRate: rarity >= .rare ? Double.random(in: 0.01...0.05) : 0,
                bonusCritDamage: rarity == .legendary ? Double.random(in: 0.1...0.3) : 0
            ),
            description: "\(rarity.rawValue)品质的\(slotName)"
        )
    }
}
