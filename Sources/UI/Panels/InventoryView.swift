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
                    // 用像素图标替代 SF Symbol
                    if let nsImage = NSImage.loadExtracted(named: "item_0_0") {
                        Image(nsImage: nsImage)
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 32, height: 32)
                            .opacity(0.3)
                    }
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
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(48)), count: 5), spacing: 4) {
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
                    VStack(spacing: 4) {
                        // 物品详情
                        ItemDetailHeader(item: item)

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
}

/// 物品网格单元格
struct ItemGridCell: View {
    let item: Item
    let isSelected: Bool

    var body: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: item.rarity.color).opacity(isSelected ? 0.4 : 0.15))
                .frame(width: 44, height: 44)

            // 像素物品图标
            if let nsImage = NSImage.loadExtracted(named: itemIconName) {
                Image(nsImage: nsImage)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 32, height: 32)
            } else {
                // 后备：使用槽位图标
                Image(systemName: slotIcon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: item.rarity.color))
            }

            // 选中边框
            if isSelected {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 44, height: 44)
            }
        }
    }

    private var itemIconName: String {
        // 映射到提取的素材名称
        let slot: String
        switch item.slot {
        case .weapon: slot = "0_0"
        case .armor: slot = "0_1"
        case .helmet: slot = "0_2"
        case .boots: slot = "0_3"
        case .accessory: slot = "0_4"
        case .none: slot = "1_0"
        }
        return "item_\(slot)"
    }

    private var slotIcon: String {
        guard let slot = item.slot else { return "questionmark" }
        switch slot {
        case .weapon: return "sword.crossed"
        case .armor: return "shield"
        case .helmet: return "crown"
        case .boots: return "shoe"
        case .accessory: return "sparkles"
        }
    }
}

/// 物品详情头部
struct ItemDetailHeader: View {
    let item: Item

    var body: some View {
        HStack(spacing: 8) {
            // 物品图标
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: item.rarity.color).opacity(0.2))
                    .frame(width: 40, height: 40)
                if let nsImage = NSImage.loadExtracted(named: "item_0_0") {
                    Image(nsImage: nsImage)
                        .resizable()
                        .interpolation(.none)
                        .frame(width: 32, height: 32)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: item.rarity.color))
                Text(item.rarity.rawValue)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
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
