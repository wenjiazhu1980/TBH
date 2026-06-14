import SwiftUI

/// 背包面板 — 使用像素物品图标
struct InventoryView: View {
    @ObservedObject var inventory: Inventory
    @ObservedObject var hero: Hero
    /// 装备动作交由 GameEngine 处理（旧装备会放回背包）
    let onEquip: (Item) -> Void
    @State private var selectedItems: Set<Item> = []

    var selectedItem: Item? { selectedItems.first }

    var body: some View {
        VStack(spacing: 0) {
            // 背包容量
            HStack {
                Text("背包 (\(inventory.items.count)/\(inventory.maxCapacity))")
                    .font(.system(size: 11, weight: .medium))
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor))

            if inventory.items.isEmpty {
                VStack(spacing: 8) {
                    PixelSprite(
                        imageName: "official_item_box",
                        size: CGSize(width: 42, height: 42)
                    )
                    .opacity(0.35)
                    Text("背包为空")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("击败怪物获取战利品")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                // 物品网格（5列）
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(50)), count: 5), spacing: 6) {
                        ForEach(inventory.items) { item in
                            ItemGridCell(item: item, isSelected: selectedItems.contains(item))
                                .onTapGesture {
                                    if selectedItems.contains(item) {
                                        selectedItems.remove(item)
                                    } else {
                                        selectedItems = [item]
                                    }
                                }
                        }
                    }
                    .padding(8)
                }

                // 操作按钮
                if let item = selectedItem {
                    VStack(spacing: 6) {
                        // 物品详情
                        ItemDetailHeader(item: item, currentItem: currentEquippedItem(for: item))

                        EquipmentComparisonView(hero: hero, item: item)

                        HStack {
                            if item.slot != nil {
                                Button("装备") {
                                    onEquip(item)
                                    selectedItems.removeAll()
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            }
                            Button("丢弃") {
                                inventory.remove(item)
                                selectedItems.removeAll()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .foregroundColor(.red)
                        }
                    }
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor))
                }
            }
        }
    }

    private func currentEquippedItem(for item: Item) -> Item? {
        guard let slot = item.slot else { return nil }
        return hero.equipment.item(in: slot)
    }
}

/// 物品网格单元格
struct ItemGridCell: View {
    let item: Item
    let isSelected: Bool

    var body: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: item.rarity.color).opacity(isSelected ? 0.38 : 0.20),
                            Color.black.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 46, height: 46)

            // 像素物品图标
            PixelSprite(
                imageName: GameArt.itemIconName(for: item),
                size: CGSize(width: 32, height: 32)
            )

            // 选中边框
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    isSelected ? Color.white : Color(hex: item.rarity.color).opacity(0.35),
                    lineWidth: isSelected ? 2 : 1
                )
                .frame(width: 46, height: 46)

            Text(item.rarity.rawValue.prefix(1))
                .font(.system(size: 7, weight: .black, design: .monospaced))
                .foregroundColor(Color(hex: item.rarity.color))
                .padding(.horizontal, 3)
                .padding(.vertical, 1)
                .background(Color.black.opacity(0.55))
                .cornerRadius(2)
                .offset(x: 14, y: 15)
        }
        .frame(width: 50, height: 50)
    }
}

/// 物品详情头部
struct ItemDetailHeader: View {
    let item: Item
    let currentItem: Item?

    var body: some View {
        HStack(spacing: 8) {
            // 物品图标
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: item.rarity.color).opacity(0.2))
                    .frame(width: 40, height: 40)
                PixelSprite(
                    imageName: GameArt.itemIconName(for: item),
                    size: CGSize(width: 32, height: 32)
                )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: item.rarity.color))
                Text(item.rarity.rawValue)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                if let currentItem {
                    Text("当前: \(currentItem.name)")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 属性
            VStack(alignment: .trailing, spacing: 1) {
                if item.stats.bonusATK > 0 {
                    Text("ATK +\(item.stats.bonusATK)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.red)
                }
                if item.stats.bonusDEF > 0 {
                    Text("DEF +\(item.stats.bonusDEF)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.blue)
                }
                if item.stats.bonusHP > 0 {
                    Text("HP +\(item.stats.bonusHP)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct EquipmentComparisonView: View {
    @ObservedObject var hero: Hero
    let item: Item

    private var currentItem: Item? {
        guard let slot = item.slot else { return nil }
        return hero.equipment.item(in: slot)
    }

    private var delta: ItemStats {
        let currentStats = currentItem?.stats ?? ItemStats()
        return ItemStats(
            bonusHP: item.stats.bonusHP - currentStats.bonusHP,
            bonusATK: item.stats.bonusATK - currentStats.bonusATK,
            bonusDEF: item.stats.bonusDEF - currentStats.bonusDEF,
            bonusSPD: item.stats.bonusSPD - currentStats.bonusSPD,
            bonusCritRate: item.stats.bonusCritRate - currentStats.bonusCritRate,
            bonusCritDamage: item.stats.bonusCritDamage - currentStats.bonusCritDamage
        )
    }

    var body: some View {
        if item.slot == nil {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
                Text("不可装备")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.vertical, 2)
        } else {
            VStack(spacing: 5) {
                HStack(spacing: 6) {
                    EquipmentDeltaChip(label: "HP", value: delta.bonusHP)
                    EquipmentDeltaChip(label: "ATK", value: delta.bonusATK)
                    EquipmentDeltaChip(label: "DEF", value: delta.bonusDEF)
                    EquipmentDeltaChip(label: "SPD", value: delta.bonusSPD)
                }

                HStack(spacing: 6) {
                    EquipmentDeltaChip(label: "暴击", valueText: percentDelta(delta.bonusCritRate), isPositive: delta.bonusCritRate > 0, isNegative: delta.bonusCritRate < 0)
                    EquipmentDeltaChip(label: "暴伤", valueText: percentDelta(delta.bonusCritDamage), isPositive: delta.bonusCritDamage > 0, isNegative: delta.bonusCritDamage < 0)
                    EquipmentDeltaChip(label: "评分", valueText: scoreDeltaText, isPositive: scoreDelta > 0, isNegative: scoreDelta < 0)
                }

                VStack(spacing: 2) {
                    PreviewStatRow(label: "生命", current: "\(hero.maxHP)", projected: "\(hero.maxHP + delta.bonusHP)", delta: Double(delta.bonusHP))
                    PreviewStatRow(label: "攻击", current: "\(hero.attack)", projected: "\(hero.attack + delta.bonusATK)", delta: Double(delta.bonusATK))
                    PreviewStatRow(label: "防御", current: "\(hero.defense)", projected: "\(hero.defense + delta.bonusDEF)", delta: Double(delta.bonusDEF))
                    PreviewStatRow(label: "速度", current: "\(hero.speed)", projected: "\(hero.speed + delta.bonusSPD)", delta: Double(delta.bonusSPD))
                }
            }
            .padding(6)
            .background(Color.black.opacity(0.14))
            .cornerRadius(5)
        }
    }

    private var scoreDelta: Double {
        item.equipmentScore - (currentItem?.equipmentScore ?? 0)
    }

    private var scoreDeltaText: String {
        if scoreDelta > 0 {
            return "+\(Int(scoreDelta.rounded()))"
        }
        return "\(Int(scoreDelta.rounded()))"
    }

    private func percentDelta(_ value: Double) -> String {
        let percent = value * 100
        if percent > 0 {
            return String(format: "+%.1f%%", percent)
        }
        return String(format: "%.1f%%", percent)
    }
}

struct EquipmentDeltaChip: View {
    let label: String
    var value: Int? = nil
    var valueText: String? = nil
    var isPositive: Bool? = nil
    var isNegative: Bool? = nil

    var body: some View {
        HStack(spacing: 3) {
            Text(label)
                .foregroundColor(.secondary)
            Text(displayValue)
                .foregroundColor(valueColor)
        }
        .font(.system(size: 8, weight: .medium, design: .monospaced))
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(valueColor.opacity(0.12))
        .cornerRadius(4)
    }

    private var displayValue: String {
        if let valueText {
            return valueText
        }
        let value = value ?? 0
        return value > 0 ? "+\(value)" : "\(value)"
    }

    private var valueColor: Color {
        let positive = isPositive ?? ((value ?? 0) > 0)
        let negative = isNegative ?? ((value ?? 0) < 0)
        if positive { return .green }
        if negative { return .red }
        return .secondary
    }
}

struct PreviewStatRow: View {
    let label: String
    let current: String
    let projected: String
    let delta: Double

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(current)
                .foregroundColor(.secondary)
            Image(systemName: "arrow.right")
                .font(.system(size: 7, weight: .semibold))
                .foregroundColor(.secondary)
            Text(projected)
                .foregroundColor(deltaColor)
        }
        .font(.system(size: 8, weight: .medium, design: .monospaced))
    }

    private var deltaColor: Color {
        if delta > 0 { return .green }
        if delta < 0 { return .red }
        return .secondary
    }
}
