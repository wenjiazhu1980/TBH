import SwiftUI

/// 点击菜单栏图标弹出的主面板
struct MenuBarPopover: View {
    @ObservedObject var gameEngine: GameEngine
    @State private var selectedTab: Tab = .battle

    enum Tab: String, CaseIterable {
        case battle = "战斗"
        case inventory = "背包"
        case character = "角色"
        case settings = "设置"
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部角色概览
            HeroSummaryBar(hero: gameEngine.hero)

            Divider()

            // 内容区
            Group {
                switch selectedTab {
                case .battle:
                    BattleView(gameEngine: gameEngine)
                case .inventory:
                    InventoryView(
                        inventory: gameEngine.inventory,
                        hero: gameEngine.hero,
                        onEquip: { gameEngine.equipItem($0) }
                    )
                case .character:
                    CharacterView(hero: gameEngine.hero)
                case .settings:
                    SettingsView(gameEngine: gameEngine)
                }
            }
            .frame(minHeight: 280)

            Divider()

            // 底部导航栏
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: 2) {
                            Image(systemName: iconName(for: tab))
                                .font(.system(size: 14))
                            Text(tab.rawValue)
                                .font(.system(size: 9))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 320, height: 420)
    }

    private func iconName(for tab: Tab) -> String {
        switch tab {
        case .battle: return "sword.crossed"
        case .inventory: return "bag"
        case .character: return "person"
        case .settings: return "gear"
        }
    }
}

/// 顶部角色概览栏
struct HeroSummaryBar: View {
    @ObservedObject var hero: Hero

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(hero.name)
                        .font(.headline)
                    Text("Lv.\(hero.level)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(hero.heroClass.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(3)
                }

                // HP 条
                HStack(spacing: 4) {
                    Text("HP")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.secondary)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color.red.opacity(0.2))
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geo.size.width * CGFloat(hero.currentHP) / CGFloat(max(hero.maxHP, 1)))
                        }
                    }
                    .frame(height: 6)
                    .cornerRadius(2)
                    Text("\(hero.currentHP)/\(hero.maxHP)")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.yellow)
                    Text("\(hero.currentXP)/\(hero.xpForNextLevel()) XP")
                        .font(.system(size: 8, design: .monospaced))
                }
                HStack(spacing: 2) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.yellow)
                    Text("\(hero.gold) G")
                        .font(.system(size: 8, design: .monospaced))
                }
            }
        }
        .padding(10)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
