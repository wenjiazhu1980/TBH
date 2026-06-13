import SwiftUI

/// 角色面板 — 显示英雄像素精灵
struct CharacterView: View {
    @ObservedObject var hero: Hero

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // 英雄立绘
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        // 像素英雄精灵
                        PixelSprite(
                            imageName: "hero_knight",
                            size: CGSize(width: 80, height: 100)
                        )
                        Text(hero.name)
                            .font(.headline)
                        HStack {
                            Text("Lv.\(hero.level)")
                                .font(.caption)
                            Text(hero.heroClass.rawValue)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)

                // 基础信息
                GroupBox("基础属性") {
                    VStack(alignment: .leading, spacing: 6) {
                        StatRow(label: "等级", value: "\(hero.level)")
                        StatRow(label: "职业", value: hero.heroClass.rawValue)
                        StatRow(label: "经验", value: "\(hero.currentXP) / \(hero.xpForNextLevel())")
                        StatRow(label: "金币", value: "\(hero.gold) G")
                    }
                    .padding(.vertical, 4)
                }

                // 战斗属性
                GroupBox("战斗属性") {
                    VStack(alignment: .leading, spacing: 6) {
                        StatRow(label: "生命", value: "\(hero.maxHP)")
                        StatRow(label: "攻击", value: "\(hero.attack)")
                        StatRow(label: "防御", value: "\(hero.defense)")
                        StatRow(label: "速度", value: "\(hero.speed)")
                        StatRow(label: "暴击率", value: String(format: "%.1f%%", hero.critRate * 100))
                        StatRow(label: "暴击伤害", value: String(format: "%.0f%%", hero.critDamage * 100))
                    }
                    .padding(.vertical, 4)
                }

                // 装备栏
                GroupBox("装备") {
                    VStack(alignment: .leading, spacing: 4) {
                        EquipmentRow(slot: "武器", item: hero.equipment.weapon)
                        EquipmentRow(slot: "护甲", item: hero.equipment.armor)
                        EquipmentRow(slot: "头盔", item: hero.equipment.helmet)
                        EquipmentRow(slot: "靴子", item: hero.equipment.boots)
                        EquipmentRow(slot: "饰品", item: hero.equipment.accessory)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
        }
    }
}

struct EquipmentRow: View {
    let slot: String
    let item: Item?

    var body: some View {
        HStack(spacing: 8) {
            // 槽位图标
            if item != nil, let nsImage = NSImage.loadExtracted(named: "item_0_0") {
                Image(nsImage: nsImage)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: slotIcon)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
            }

            Text(slot)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 36, alignment: .leading)

            if let item = item {
                Text(item.name)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: item.rarity.color))
            } else {
                Text("— 空 —")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            Spacer()
        }
    }

    private var slotIcon: String {
        switch slot {
        case "武器": return "sword.crossed"
        case "护甲": return "shield"
        case "头盔": return "crown"
        case "靴子": return "shoe"
        case "饰品": return "sparkles"
        default: return "questionmark"
        }
    }
}
