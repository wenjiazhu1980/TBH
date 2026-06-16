import SwiftUI
import AppKit

/// 设置面板
struct SettingsView: View {
    @ObservedObject var gameEngine: GameEngine
    @Binding var panelScale: Double
    @State private var showResetAlert = false
    @State private var showRuneTreeResetAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                GroupBox("游戏") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("当前 Act")
                            Spacer()
                            Text(gameEngine.progress.currentChapter.name)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("当前关卡")
                            Spacer()
                            Text(gameEngine.progress.currentStage.displayName)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("当前难度")
                            Spacer()
                            Text(gameEngine.progress.currentDifficulty.name)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("关卡进度")
                            Spacer()
                            Text(gameEngine.progress.stageProgressText)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("当前波次")
                            Spacer()
                            Text(gameEngine.progress.waveProgressText)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("波内进度")
                            Spacer()
                            Text(gameEngine.progress.waveEncounterProgressText)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("当前敌人")
                            Spacer()
                            Text(gameEngine.progress.currentEncounterState.monsterSpawn.name)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                    }
                    .font(.system(size: 11))
                    .padding(.vertical, 4)
                }

                GroupBox("关卡选择") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("已解锁至")
                            Spacer()
                            Text(gameEngine.progress.highestUnlockedStageText)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                        }

                        Picker("目标关卡", selection: stageSelectionBinding) {
                            ForEach(gameEngine.progress.unlockedStageSelections) { selection in
                                Text(selection.menuLabel)
                                    .tag(selection.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .controlSize(.small)

                        Button {
                            gameEngine.restartCurrentStage()
                        } label: {
                            Label("重打本关", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .font(.system(size: 11))
                    .padding(.vertical, 4)
                }

                GroupBox("原版关卡数据库") {
                    SourceStageDatabaseView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版技能数据库") {
                    SourceSkillDatabaseView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("箱子") {
                    VStack(alignment: .leading, spacing: 6) {
                        if gameEngine.progress.chests.chests.isEmpty {
                            HStack {
                                Text("暂无箱子")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("0")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            if gameEngine.runeTree.canOpenAllChestTypesAtOnce {
                                Button {
                                    gameEngine.openAllChests()
                                } label: {
                                    Label("全部开启 \(gameEngine.progress.chests.totalCount)", systemImage: "shippingbox.fill")
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            } else if gameEngine.runeTree.canOpenOneChestTypeAtOnce {
                                ForEach(chestKindsWithSavedChests) { kind in
                                    Button {
                                        gameEngine.openChests(kind: kind)
                                    } label: {
                                        Label("开启\(kind.displayName) \(gameEngine.progress.chests.count(for: kind))", systemImage: "shippingbox.fill")
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            } else {
                                Label("解锁开启符文后可批量开箱", systemImage: "lock.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }

                            ForEach(gameEngine.progress.chests.chests) { chest in
                                HStack(spacing: 8) {
                                    PixelSprite(
                                        imageName: GameArt.chestIconName(for: chest),
                                        size: CGSize(width: 24, height: 24)
                                    )

                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(chest.displayName)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.78)
                                        Text("#\(chest.databaseID) · \(chest.kind.displayName) · \(chest.rarity.rawValue) · \(chest.sourceStageCode)")
                                            .font(.system(size: 8, design: .monospaced))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }

                                    Spacer()

                                    Button {
                                        gameEngine.openChest(id: chest.id)
                                    } label: {
                                        Label("开启", systemImage: "shippingbox")
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.mini)
                                }
                            }
                        }
                    }
                    .font(.system(size: 11))
                    .padding(.vertical, 4)
                }

                GroupBox("灵魂石") {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(SoulStoneKind.allCases) { kind in
                            HStack(spacing: 8) {
                                PixelSprite(
                                    imageName: GameArt.soulStoneIconName(for: kind),
                                    size: CGSize(width: 18, height: 18)
                                )
                                Text(kind.displayName)
                                Spacer()
                                Text("\(gameEngine.progress.soulStones.count(for: kind))")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .font(.system(size: 11))
                    .padding(.vertical, 4)
                }

                GroupBox("符文树") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("解锁条件")
                            Spacer()
                            Text("Lv.\(RuneTree.requiredHeroLevel)+")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("当前金币")
                            Spacer()
                            Text("\(gameEngine.hero.gold.formatted()) G")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("编队位")
                            Spacer()
                            Text("\(gameEngine.runeTree.unlockedPartySlotCount)/\(HeroParty.maxSlots)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("主动技能槽")
                            Spacer()
                            Text("\(gameEngine.runeTree.activeSkillSlotCount)/2")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("背包容量")
                            Spacer()
                            Text("\(gameEngine.inventory.maxCapacity)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                        }

                        ForEach(RuneTreeNode.allCases) { node in
                            RuneTreeNodeRow(
                                node: node,
                                isUnlocked: gameEngine.runeTree.isUnlocked(node),
                                canUnlock: gameEngine.canUnlockRuneTreeNode(node),
                                onUnlock: { gameEngine.unlockRuneTreeNode(node) }
                            )
                        }

                        Divider()
                            .padding(.vertical, 2)

                        Button(role: .destructive) {
                            showRuneTreeResetAlert = true
                        } label: {
                            Label("重置符文树", systemImage: "arrow.counterclockwise")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                        .disabled(gameEngine.runeTree.unlockedNodes.isEmpty)
                    }
                    .font(.system(size: 11))
                    .padding(.vertical, 4)
                }

                GroupBox("原版符文数据库") {
                    SourceRuneDatabaseView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("自动化") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(
                            "自动装备最强物品",
                            isOn: Binding(
                                get: { gameEngine.autoEquipBestItems },
                                set: { gameEngine.setAutoEquipBestItems($0) }
                            )
                        )
                        .toggleStyle(.switch)
                        .controlSize(.small)

                        Button("立即装备最强") {
                            gameEngine.equipBestItemsFromInventory()
                            gameEngine.save()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .font(.system(size: 11))
                    .padding(.vertical, 4)
                }

                GroupBox("音效") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(
                            "播放战斗音效",
                            isOn: Binding(
                                get: { gameEngine.soundEffectsEnabled },
                                set: { gameEngine.setSoundEffectsEnabled($0) }
                            )
                        )
                        .toggleStyle(.switch)
                        .controlSize(.small)

                        Button {
                            gameEngine.previewSoundEffect()
                        } label: {
                            Label("测试音效", systemImage: "speaker.wave.2")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .disabled(!gameEngine.soundEffectsEnabled)
                    }
                    .font(.system(size: 11))
                    .padding(.vertical, 4)
                }

                GroupBox("显示") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("面板缩放")
                            Spacer()
                            Text(panelScalePercentText)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                        }

                        Slider(
                            value: normalizedPanelScaleBinding,
                            in: MenuBarPopoverLayout.minimumScale...MenuBarPopoverLayout.maximumScale,
                            step: MenuBarPopoverLayout.scaleStep
                        )
                        .controlSize(.small)

                        Button {
                            panelScale = MenuBarPopoverLayout.defaultScale
                        } label: {
                            Label("重置面板尺寸", systemImage: "arrow.up.left.and.down.right.magnifyingglass")
                        }
                        .keyboardShortcut(
                            OriginalControlShortcuts.scaleResetKey,
                            modifiers: OriginalControlShortcuts.scaleResetModifiers
                        )
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .disabled(panelScale == MenuBarPopoverLayout.defaultScale)
                    }
                    .font(.system(size: 11))
                    .padding(.vertical, 4)
                }

                GroupBox("统计") {
                    VStack(alignment: .leading, spacing: 6) {
                        StatRow(label: "击杀怪物", value: "\(gameEngine.statistics.monstersKilled)")
                        StatRow(label: "获取装备", value: "\(gameEngine.statistics.itemsFound)")
                        StatRow(label: "在线时长", value: formatTime(gameEngine.statistics.totalPlayTime))
                        StatRow(label: "离线经验", value: "\(gameEngine.statistics.offlineXP)")
                        StatRow(label: "离线金币", value: "\(gameEngine.statistics.offlineGold)")
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("操作") {
                    VStack(spacing: 8) {
                        Button("立即保存") {
                            gameEngine.save()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Button("重置存档", role: .destructive) {
                            showResetAlert = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Divider()
                            .padding(.vertical, 2)

                        Button {
                            quitGame()
                        } label: {
                            Label("退出游戏", systemImage: "power")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .keyboardShortcut("q", modifiers: .command)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }

                GroupBox("关于") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TBH: Task Bar Hero — macOS Edition")
                            .font(.system(size: 10, weight: .medium))
                        Text(AppVersion.displayString)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding()
        }
        .alert("确认重置", isPresented: $showResetAlert) {
            Button("取消", role: .cancel) {}
            Button("重置", role: .destructive) {
                gameEngine.resetGame()
            }
        } message: {
            Text("将删除所有存档数据，此操作不可撤销。")
        }
        .alert("确认重置符文树", isPresented: $showRuneTreeResetAlert) {
            Button("取消", role: .cancel) {}
            Button("重置", role: .destructive) {
                gameEngine.resetRuneTree()
            }
        } message: {
            Text("将清空已解锁符文，并返还已核对的金币成本。")
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        return "\(h)h \(m)m"
    }

    private var stageSelectionBinding: Binding<String> {
        Binding(
            get: {
                gameEngine.progress.currentStageSelectionID
            },
            set: { selectionID in
                guard let selection = gameEngine.progress.unlockedStageSelections.first(where: { $0.id == selectionID }) else {
                    return
                }
                gameEngine.selectStage(selection)
            }
        )
    }

    private var normalizedPanelScaleBinding: Binding<Double> {
        Binding(
            get: {
                MenuBarPopoverLayout.normalizedScale(panelScale)
            },
            set: { scale in
                panelScale = MenuBarPopoverLayout.normalizedScale(scale)
            }
        )
    }

    private var panelScalePercentText: String {
        "\(Int((MenuBarPopoverLayout.normalizedScale(panelScale) * 100).rounded()))%"
    }

    private var chestKindsWithSavedChests: [ChestKind] {
        ChestKind.allCases.filter { gameEngine.progress.chests.count(for: $0) > 0 }
    }

    private func quitGame() {
        gameEngine.stop()
        NSApplication.shared.terminate(nil)
    }
}

private struct SourceRuneDatabaseView: View {
    private let runtimeModeledSourceIDs = SourceRuneCatalog.runtimeModeledSourceIDs

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "节点",
                    value: "\(SourceRuneCatalog.all.count)"
                )
                SourceRuneSummaryPill(
                    label: "连线",
                    value: "\(SourceRuneCatalog.connectionCount)"
                )
                SourceRuneSummaryPill(
                    label: "运行时",
                    value: "\(SourceRuneCatalog.runtimeModeledNodes.count)"
                )
                SourceRuneSummaryPill(
                    label: "数据",
                    value: "\(SourceRuneCatalog.runtimeUnmodeledNodes.count)"
                )
            }

            HStack {
                Text("图标族")
                Spacer()
                Text("\(SourceRuneCatalog.iconNames.count)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceRuneCatalog.all) { sourceNode in
                        SourceRuneNodeSourceRow(
                            sourceNode: sourceNode,
                            isRuntimeModeled: runtimeModeledSourceIDs.contains(sourceNode.id)
                        )
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text("完整源表")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                    Text("v1.00.09")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

private struct SourceRuneSummaryPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .lineLimit(1)
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.08))
        .cornerRadius(4)
    }
}

private struct SourceStageDatabaseView: View {
    private let uniqueMonsterNames = Set(
        StageDefinition.all.flatMap { stage in
            Difficulty.allCases.flatMap { difficulty in
                stage.runtimeData(for: difficulty).monsterComposition.map(\.name)
            }
        }
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "关卡",
                    value: "\(StageDefinition.all.count)"
                )
                SourceRuneSummaryPill(
                    label: "难度行",
                    value: "\(StageDefinition.runtimeDataCount)"
                )
                SourceRuneSummaryPill(
                    label: "难度",
                    value: "\(Difficulty.allCases.count)"
                )
                SourceRuneSummaryPill(
                    label: "怪物",
                    value: "\(uniqueMonsterNames.count)"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Difficulty.allCases, id: \.rawValue) { difficulty in
                        ForEach(StageDefinition.all) { stage in
                            SourceStageRuntimeRow(stage: stage, difficulty: difficulty)
                        }
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text("完整源表")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                    Text("120 行")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

private struct SourceStageRuntimeRow: View {
    let stage: StageDefinition
    let difficulty: Difficulty

    private var runtime: StageRuntimeData {
        stage.runtimeData(for: difficulty)
    }

    var body: some View {
        HStack(spacing: 7) {
            VStack(spacing: 1) {
                Text(runtime.code)
                    .font(.system(size: 8, weight: .black, design: .monospaced))
                    .lineLimit(1)
                Text(difficulty.name)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 40, alignment: .leading)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(stage.displayName)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    if runtime.isBoss {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }

                Text(stageRuntimeDetailText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 1) {
                Text(runtimePaceText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(runtime.isBoss ? .orange : .secondary)
                Text("Lv.\(runtime.level)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var runtimePaceText: String {
        runtime.isBoss ? "Boss" : "\(runtime.waves)W/\(runtime.killsRequired)K"
    }

    private var stageRuntimeDetailText: String {
        let monsters = runtime.monsterComposition
            .prefix(3)
            .map { spawn in
                "\(spawn.name)x\(spawn.count)"
            }
            .joined(separator: ",")
        let overflow = runtime.monsterComposition.count > 3 ? ",+" : ""
        let compositionText = monsters.isEmpty ? runtime.monsterName : "\(monsters)\(overflow)"
        return "\(runtime.goldReward)G/\(runtime.xpReward)XP · HP \(runtime.hp) · \(compositionText)"
    }
}

private struct SourceSkillDatabaseView: View {
    private let runtimeModeledSkillIDs = SourceSkillCatalog.runtimeModeledSkillIDs
    private let activationTypes = Set(SourceSkillCatalog.all.map(\.activation))

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "源技能",
                    value: "\(SourceSkillCatalog.all.count)"
                )
                SourceRuneSummaryPill(
                    label: "运行时",
                    value: "\(SourceSkillCatalog.runtimeModeledSkills.count)"
                )
                SourceRuneSummaryPill(
                    label: "数据",
                    value: "\(SourceSkillCatalog.all.count - SourceSkillCatalog.runtimeModeledSkills.count)"
                )
                SourceRuneSummaryPill(
                    label: "激活",
                    value: "\(activationTypes.count)"
                )
            }

            HStack {
                Text("伤害 / 投射")
                Spacer()
                Text("\(SourceSkillCatalog.damageTypes.count) / \(SourceSkillCatalog.deliveries.count)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceSkillCatalog.all) { sourceSkill in
                        SourceSkillRow(
                            sourceSkill: sourceSkill,
                            isRuntimeModeled: runtimeModeledSkillIDs.contains(sourceSkill.id)
                        )
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text("完整源表")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                    Text("106 行")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

private struct SourceSkillRow: View {
    let sourceSkill: SourceSkill
    let isRuntimeModeled: Bool

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: sourceSkillIconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(sourceSkillTint)
                .frame(width: 18, height: 18)
                .opacity(isRuntimeModeled ? 1 : 0.58)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text("#\(sourceSkill.id)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                    Text(sourceSkill.name)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    if isRuntimeModeled {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.green)
                    }
                }

                Text(sourceSkillDetailText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 1) {
                Text(sourceSkill.activation.rawValue)
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                Text(isRuntimeModeled ? "已接入" : "源数据")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(isRuntimeModeled ? .green : .secondary)
            }
            .frame(width: 78, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    private var sourceSkillDetailText: String {
        let delivery = sourceSkill.delivery.isEmpty ? "NoDelivery" : sourceSkill.delivery
        return "\(sourceSkill.damageType) · \(delivery) · R\(sourceSkill.range)"
    }

    private var sourceSkillIconName: String {
        switch sourceSkill.activation {
        case .cooldown:
            return "timer"
        case .baseAttack:
            return "target"
        case .baseAttackCount:
            return "number.circle"
        case .continuous:
            return "infinity"
        }
    }

    private var sourceSkillTint: Color {
        switch sourceSkill.runtimeDamageElement {
        case .physical:
            return .gray
        case .fire:
            return .orange
        case .cold:
            return .cyan
        case .lightning:
            return .yellow
        case .chaos:
            return .purple
        case .none:
            return .secondary
        }
    }
}

private struct SourceRuneNodeSourceRow: View {
    let sourceNode: SourceRuneNode
    let isRuntimeModeled: Bool

    var body: some View {
        HStack(spacing: 7) {
            PixelSprite(
                imageName: GameArt.sourceRuneIconName(for: sourceNode),
                size: CGSize(width: 18, height: 18)
            )
            .opacity(isRuntimeModeled ? 1 : 0.58)
            .saturation(isRuntimeModeled ? 1 : 0.55)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text("#\(sourceNode.id)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                    Text(sourceNode.zhName)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    if isRuntimeModeled {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.green)
                    }
                }

                Text("\(sourceNode.enName) · Lv.\(sourceNode.maxLevel) · \(sourceNode.iconName)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(sourceNode.previousIDs.count) / \(sourceNode.nextIDs.count)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                Text(isRuntimeModeled ? "已接入" : "源数据")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(isRuntimeModeled ? .green : .secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct RuneTreeNodeRow: View {
    let node: RuneTreeNode
    let isUnlocked: Bool
    let canUnlock: Bool
    let onUnlock: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                PixelSprite(
                    imageName: GameArt.runeTreeIconName(for: node),
                    size: CGSize(width: 28, height: 28)
                )
                .opacity(isUnlocked ? 1 : 0.48)
                .saturation(isUnlocked ? 1 : 0.35)

                Image(systemName: isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(isUnlocked ? .green : .secondary)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
                    .offset(x: 2, y: 2)
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 1) {
                Text(node.displayName)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isUnlocked ? .green : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(node.costText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                onUnlock()
            } label: {
                Label("解锁", systemImage: "sparkles")
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
            .disabled(!canUnlock)
        }
    }
}
