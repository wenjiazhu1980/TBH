import SwiftUI
import AppKit

/// 点击菜单栏图标弹出的主面板
struct MenuBarPopover: View {
    @ObservedObject var gameEngine: GameEngine
    @State private var selectedTab: Tab = .battle
    @AppStorage("tbh.popoverScale") private var popoverScale: Double = MenuBarPopoverLayout.defaultScale

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
                        cubeProgress: gameEngine.cubeProgress,
                        purchasedExpansionCount: gameEngine.purchasedInventoryExpansionCount,
                        nextExpansionCost: gameEngine.nextInventoryExpansionGoldCost,
                        worseEquipmentHandling: gameEngine.worseEquipmentHandling,
                        onEquip: { gameEngine.equipItem($0) },
                        onExpandInventory: { gameEngine.purchaseInventoryExpansion() },
                        onWorseEquipmentHandlingChange: { gameEngine.setWorseEquipmentHandling($0) },
                        onInfuseIntoCube: { gameEngine.infuseItemIntoCube($0) },
                        onAlchemize: { gameEngine.alchemizeItem($0) },
                        onSynthesize: { gameEngine.synthesizeItems(rarity: $0) }
                    )
                case .character:
                    CharacterView(
                        hero: gameEngine.hero,
                        party: gameEngine.party,
                        activeSkillLoadouts: gameEngine.activeSkillLoadouts,
                        activeSkillSlotCount: gameEngine.runeTree.activeSkillSlotCount,
                        allHeroAttackDamageBonus: gameEngine.runeTree.allHeroAttackDamage,
                        allHeroAttackDamageMultiplier: gameEngine.runeTree.allHeroAttackDamageMultiplier,
                        onClassChange: { gameEngine.setHeroClass($0) },
                        onPartyMemberChange: { slotIndex, heroClass in
                            gameEngine.setPartyMember(slotIndex: slotIndex, heroClass: heroClass)
                        },
                        partySlotUnlockCost: { slotIndex in
                            gameEngine.directPartySlotUnlockCost(slotIndex: slotIndex)
                        },
                        canUnlockPartySlot: { slotIndex in
                            gameEngine.canDirectlyUnlockPartySlot(slotIndex: slotIndex)
                        },
                        onPartySlotUnlock: { slotIndex in
                            gameEngine.directlyUnlockPartySlot(slotIndex: slotIndex)
                        },
                        onActiveSkillChange: { heroClass, slotIndex, skillID in
                            gameEngine.setActiveSkill(skillID, for: heroClass, slotIndex: slotIndex)
                        }
                    )
                case .settings:
                    SettingsView(
                        gameEngine: gameEngine,
                        panelScale: panelScaleBinding
                    )
                }
            }
            .frame(minHeight: MenuBarPopoverLayout.contentMinHeight, maxHeight: .infinity)

            Divider()

            // 底部菜单栏
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
            .frame(height: MenuBarPopoverLayout.bottomTabHeight)
        }
        .frame(
            width: MenuBarPopoverLayout.size(for: popoverScale).width,
            height: MenuBarPopoverLayout.size(for: popoverScale).height
        )
        .onAppear {
            gameEngine.setInterfaceAudioActive(true)
        }
        .onDisappear {
            gameEngine.setInterfaceAudioActive(false)
        }
    }

    private var panelScaleBinding: Binding<Double> {
        Binding(
            get: {
                MenuBarPopoverLayout.normalizedScale(popoverScale)
            },
            set: { scale in
                popoverScale = MenuBarPopoverLayout.normalizedScale(scale)
            }
        )
    }
}

enum MenuBarPopoverLayout {
    static let defaultScale: Double = 1.0
    static let minimumScale: Double = 1.0
    static let maximumScale: Double = 1.0
    static let scaleStep: Double = 0.05
    static let contentMinHeight: CGFloat = 488
    static let bottomTabHeight: CGFloat = 46
    static let defaultSize = CGSize(width: 640, height: 600)

    static func normalizedScale(_ scale: Double) -> Double {
        min(max(scale, minimumScale), maximumScale)
    }

    static func size(for scale: Double) -> CGSize {
        let normalized = normalizedScale(scale)
        return CGSize(
            width: defaultSize.width * normalized,
            height: defaultSize.height * normalized
        )
    }
}

enum OriginalControlShortcuts {
    static let scaleResetFunctionKeyCode = Int(NSF11FunctionKey)
    static let scaleResetModifiers: EventModifiers = [.shift]

    static var scaleResetKey: KeyEquivalent {
        guard let scalar = UnicodeScalar(scaleResetFunctionKeyCode) else {
            return KeyEquivalent(" ")
        }
        return KeyEquivalent(Character(scalar))
    }
}

struct TabBarButton: View {
    let tab: MenuBarPopover.Tab
    let isSelected: Bool
    let action: () -> Void

    private var itemColor: Color {
        isSelected ? .accentColor : .secondary
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                TabBarIcon(tab: tab, color: itemColor)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .frame(width: TabBarIconMetrics.width, height: TabBarIconMetrics.height)
                    .accessibilityHidden(true)

                Text(tab.rawValue)
                    .font(.system(size: 9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .foregroundStyle(itemColor)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
    }
}

enum TabBarIconMetrics {
    static let width: CGFloat = 18
    static let height: CGFloat = 16
}

struct TabBarIcon: View {
    let tab: MenuBarPopover.Tab
    let color: Color

    var body: some View {
        Group {
            if TabBarIconResolver.usesCustomArtwork(for: tab) {
                BattleTabIconGlyph(color: color)
            } else {
                SafeSystemImage(descriptor: TabBarIconResolver.descriptor(for: tab))
            }
        }
        .foregroundStyle(color)
    }
}

struct TabBarIconDescriptor: Equatable {
    let primaryName: String
    let fallbackName: String
}

enum TabBarIconResolver {
    static func usesCustomArtwork(for tab: MenuBarPopover.Tab) -> Bool {
        tab == .battle
    }

    static func descriptor(for tab: MenuBarPopover.Tab) -> TabBarIconDescriptor {
        switch tab {
        case .battle:
            return TabBarIconDescriptor(primaryName: "figure.fencing", fallbackName: "shield.fill")
        case .inventory:
            return TabBarIconDescriptor(primaryName: "bag", fallbackName: "shippingbox.fill")
        case .character:
            return TabBarIconDescriptor(primaryName: "person", fallbackName: "person.fill")
        case .settings:
            return TabBarIconDescriptor(primaryName: "gear", fallbackName: "gearshape.fill")
        }
    }

    static func resolvedName(for tab: MenuBarPopover.Tab) -> String {
        resolvedName(for: descriptor(for: tab))
    }

    static func resolvedName(for descriptor: TabBarIconDescriptor) -> String {
        if isAvailable(descriptor.primaryName) {
            return descriptor.primaryName
        }
        if isAvailable(descriptor.fallbackName) {
            return descriptor.fallbackName
        }
        return "circle.fill"
    }

    private static func isAvailable(_ systemName: String) -> Bool {
        NSImage(systemSymbolName: systemName, accessibilityDescription: nil) != nil
    }
}

private struct BattleTabIconGlyph: View {
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let bladeWidth = max(width * 0.12, 2)
            let bladeHeight = height * 0.78
            let guardWidth = width * 0.34
            let guardHeight = max(height * 0.12, 2)
            let pommelSide = max(height * 0.18, 3)

            ZStack {
                sword(
                    bladeWidth: bladeWidth,
                    bladeHeight: bladeHeight,
                    guardWidth: guardWidth,
                    guardHeight: guardHeight,
                    pommelSide: pommelSide,
                    rotation: 42,
                    xOffset: -width * 0.05,
                    yOffset: 0
                )

                sword(
                    bladeWidth: bladeWidth,
                    bladeHeight: bladeHeight,
                    guardWidth: guardWidth,
                    guardHeight: guardHeight,
                    pommelSide: pommelSide,
                    rotation: -42,
                    xOffset: width * 0.05,
                    yOffset: 0
                )
            }
            .frame(width: width, height: height)
        }
    }

    private func sword(
        bladeWidth: CGFloat,
        bladeHeight: CGFloat,
        guardWidth: CGFloat,
        guardHeight: CGFloat,
        pommelSide: CGFloat,
        rotation: Double,
        xOffset: CGFloat,
        yOffset: CGFloat
    ) -> some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(color)
                .frame(width: bladeWidth, height: bladeHeight)
                .offset(y: -bladeHeight * 0.08)

            Capsule(style: .continuous)
                .fill(color)
                .frame(width: guardWidth, height: guardHeight)
                .offset(y: bladeHeight * 0.28)

            Capsule(style: .continuous)
                .fill(color)
                .frame(width: bladeWidth * 0.92, height: bladeHeight * 0.24)
                .offset(y: bladeHeight * 0.42)

            Circle()
                .fill(color)
                .frame(width: pommelSide, height: pommelSide)
                .offset(y: bladeHeight * 0.56)
        }
        .rotationEffect(.degrees(rotation))
        .offset(x: xOffset, y: yOffset)
    }
}

private struct SafeSystemImage: View {
    let descriptor: TabBarIconDescriptor

    var body: some View {
        Image(systemName: TabBarIconResolver.resolvedName(for: descriptor))
            .resizable()
            .scaledToFit()
            .symbolRenderingMode(.monochrome)
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
                        let hpRatio = min(max(CGFloat(hero.currentHP) / CGFloat(max(hero.maxHP, 1)), 0), 1)
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color.red.opacity(0.2))
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geo.size.width * hpRatio)
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
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
