import SwiftUI
import AppKit

/// 背包面板 — 使用像素物品图标
struct InventoryView: View {
    @ObservedObject var inventory: Inventory
    @ObservedObject var hero: Hero
    let cubeProgress: CubeProgress
    let purchasedExpansionCount: Int
    let nextExpansionCost: Int
    let worseEquipmentHandling: WorseEquipmentHandling
    /// 装备动作交由 GameEngine 处理（旧装备会放回背包）
    let onEquip: (Item) -> Void
    let onExpandInventory: () -> Void
    let onWorseEquipmentHandlingChange: (WorseEquipmentHandling) -> Void
    let onInfuseIntoCube: (Item) -> Void
    let onAlchemize: (Item) -> Void
    let onSynthesize: (Rarity) -> Item?
    @State private var selectedItems: Set<Item> = []

    var selectedItem: Item? {
        guard let selected = selectedItems.first else { return nil }
        return inventory.items.first { $0.id == selected.id }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 背包容量
            HStack {
                Text("背包 (\(inventory.items.count)/\(inventory.maxCapacity))")
                    .font(.system(size: 11, weight: .medium))
                Button {
                    onExpandInventory()
                } label: {
                    Label("+10", systemImage: "plus.square")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
                .disabled(hero.gold < nextExpansionCost)
                .help("扩容 +10 格，消耗 \(nextExpansionCost.formatted()) G；已扩容 \(purchasedExpansionCount) 次")
                Picker("", selection: Binding(
                    get: { worseEquipmentHandling },
                    set: { onWorseEquipmentHandlingChange($0) }
                )) {
                    ForEach(WorseEquipmentHandling.allCases) { handling in
                        Label(handling.displayName, systemImage: handling.systemImage)
                            .tag(handling)
                    }
                }
                .pickerStyle(.menu)
                .controlSize(.mini)
                .frame(width: 104)
                .help("新获得的同槽位较差装备处理方式")
                Spacer()
                Label(cubeProgress.displayText, systemImage: "cube.fill")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary)
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
                                    switch InventoryInteraction.actionForItemClick(
                                        isSelected: selectedItems.contains(item),
                                        modifierFlags: NSEvent.modifierFlags
                                    ) {
                                    case .toggleLock:
                                        toggleLock(item)
                                    case .deselect:
                                        selectedItems.remove(item)
                                    case .selectExclusive:
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

                        SynthesisPreviewView(
                            preview: synthesisPreview(for: item.rarity)
                        )

                        VStack(spacing: 5) {
                            if item.slot != nil {
                                Button("装备") {
                                    onEquip(item)
                                    selectedItems.removeAll()
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                                .frame(maxWidth: .infinity)
                            }

                            Button {
                                if let output = onSynthesize(item.rarity) {
                                    selectedItems = [output]
                                }
                            } label: {
                                Label("合成", systemImage: "arrow.triangle.2.circlepath")
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .disabled(!canSynthesize(rarity: item.rarity))
                            .frame(maxWidth: .infinity)

                            HStack {
                                Button {
                                    toggleLock(item)
                                } label: {
                                    Label(item.isLocked ? "解锁" : "锁定", systemImage: item.isLocked ? "lock.open" : "lock")
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                                Button {
                                    onInfuseIntoCube(item)
                                    selectedItems.removeAll()
                                } label: {
                                    Label("Cube", systemImage: "cube")
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .disabled(item.isLocked)

                                Button {
                                    onAlchemize(item)
                                    selectedItems.removeAll()
                                } label: {
                                    Label("炼金", systemImage: "dollarsign.circle")
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .disabled(item.isLocked)

                                Button("丢弃") {
                                    if inventory.discard(item) {
                                        selectedItems.removeAll()
                                    }
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .foregroundColor(.red)
                                .disabled(item.isLocked)
                            }
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

    private func toggleLock(_ item: Item) {
        if let updated = inventory.toggleLock(item) {
            selectedItems = [updated]
        }
    }

    private func synthesisPreview(for rarity: Rarity) -> SynthesisPreview {
        SynthesisPreview.make(for: rarity, in: inventory.items)
    }

    private func canSynthesize(rarity: Rarity) -> Bool {
        synthesisPreview(for: rarity).isReady
    }
}

enum InventoryItemClickAction: Equatable {
    case selectExclusive
    case deselect
    case toggleLock
}

enum InventoryInteraction {
    static func actionForItemClick(
        isSelected: Bool,
        modifierFlags: NSEvent.ModifierFlags
    ) -> InventoryItemClickAction {
        if modifierFlags.contains(.option) {
            return .toggleLock
        }
        return isSelected ? .deselect : .selectExclusive
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

            if item.isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(3)
                    .background(Color.black.opacity(0.65))
                    .clipShape(Circle())
                    .offset(x: -15, y: -15)
            }
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
                Text("Lv.\(item.itemLevel) · \(item.rarity.rawValue)")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                if let equipmentType = item.equipmentType {
                    Text(equipmentType.typeLine)
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
                Text("D/E/I \(item.rarity.slotSummary) · Cube +\(item.rarity.cubeExperience) · 炼金 +\(item.rarity.alchemyGoldValue)G")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.secondary)
                if item.isLocked {
                    Label("已锁定", systemImage: "lock.fill")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.secondary)
                }
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

private struct SynthesisPreviewView: View {
    let preview: SynthesisPreview

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(preview.isReady ? .green : .secondary)

                if let outputRarity = preview.outputRarity {
                    Text("合成 \(Rarity.synthesisInputCount)x \(preview.inputRarity.rawValue) -> \(outputRarity.rawValue)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(min(preview.unlockedInputCount, Rarity.synthesisInputCount))/\(Rarity.synthesisInputCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(preview.isReady ? .green : .secondary)
                } else {
                    Text("宇宙品质无法继续合成")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }

            if preview.outputRarity != nil {
                HStack(spacing: 6) {
                    if let outputItemLevel = preview.outputItemLevel {
                        Label("Lv.\(outputItemLevel)", systemImage: "scope")
                            .foregroundColor(.secondary)
                    }
                    if let source = preview.outputSourceProgression {
                        Label("\(source.name) #\(source.id)", systemImage: "tag.fill")
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    if preview.lockedInputCount > 0 {
                        Label("锁定 \(preview.lockedInputCount)", systemImage: "lock.fill")
                            .foregroundColor(.secondary)
                    }
                    if let boundary = preview.sourceVariantBoundary {
                        Text(boundary)
                            .foregroundColor(.secondary.opacity(0.9))
                    }
                    Spacer()
                }
                .font(.system(size: 8, weight: .medium))
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.12))
        .cornerRadius(5)
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
