import SwiftUI
import AppKit

/// 设置面板
struct SettingsView: View {
    @ObservedObject var gameEngine: GameEngine
    @Binding var panelScale: Double
    @State private var showRuneTreeResetAlert = false
    @State private var resetFailureMessage: String?

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
                            Text("等级上限")
                            Spacer()
                            Text(currentHeroLevelCapText)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("等级状态")
                            Spacer()
                            Text(currentHeroLevelCapStatusText)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(currentHeroLevelCapStatus.needsNormalization ? .orange : .secondary)
                        }
                        HStack {
                            Text("XP余量")
                            Spacer()
                            Text(currentHeroLevelCapXPText)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("上限公式")
                            Spacer()
                            Text(currentHeroLevelCapFormulaText)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
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

                GroupBox("原版怪物数据库") {
                    SourceMonsterDatabaseView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版怪物美术映射") {
                    SourceMonsterArtMappingView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版怪物攻击映射") {
                    SourceMonsterAttackReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("本地节奏边界") {
                    LocalPacingReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("支援成员公式复核") {
                    SupportFormulaReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版复核边界") {
                    OriginalFidelityBoundaryView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版物品数据库") {
                    SourceItemDatabaseView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("精确装备记录缺口") {
                    ExactItemRecordGapView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版合成/Cube/炼金规则") {
                    SourceCraftingRuleReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版技能数据库") {
                    SourceSkillDatabaseView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版技能 damage 分布") {
                    SourceSkillDamageReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版技能 activation × damage") {
                    SourceSkillActivationDamageReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版技能 activation × delivery") {
                    SourceSkillActivationDeliveryReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版技能 damage × delivery") {
                    SourceSkillDamageDeliveryReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版技能 delivery 分布") {
                    SourceSkillDeliveryReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版技能 range 分布") {
                    SourceSkillRangeReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("本地技能运行时覆盖") {
                    LocalSkillRuntimeCoverageView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("待接入源技能复核") {
                    PendingSourceSkillReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("本地主动技能数值表") {
                    ModeledActiveSkillValueTableView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版被动技能数据库") {
                    SourcePassiveSkillDatabaseView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                ChestControlsView(gameEngine: gameEngine)

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
                        HStack {
                            Text("可解锁符文")
                            Spacer()
                            Text("\(gameEngine.unlockableRuneTreeNodeCount)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("一键消耗")
                            Spacer()
                            Text("\(gameEngine.unlockableRuneTreeGoldCost.formatted()) G")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(gameEngine.unlockableRuneTreeGoldCost > 0 ? .orange : .secondary)
                        }

                        Button {
                            gameEngine.unlockAllAvailableRuneTreeNodes()
                        } label: {
                            Label("一键解锁符文", systemImage: "sparkles")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .disabled(gameEngine.unlockableRuneTreeNodeCount == 0)

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

                GroupBox("符文证据分层") {
                    SourceRuneEvidenceReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("本地符文成本复核") {
                    LocalRuneCostReviewView()
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

                GroupBox("原版音频/SFX 证据") {
                    SourceAudioSFXEvidenceReviewView()
                        .font(.system(size: 11))
                        .padding(.vertical, 4)
                }

                GroupBox("原版战斗动画证据") {
                    SourceBattleAnimationEvidenceReviewView()
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

                        if isPanelScaleAdjustable {
                            Slider(
                                value: normalizedPanelScaleBinding,
                                in: MenuBarPopoverLayout.minimumScale...MenuBarPopoverLayout.maximumScale,
                                step: MenuBarPopoverLayout.scaleStep
                            )
                            .controlSize(.small)
                        } else {
                            Text("当前窗口尺寸已固定，确保底部菜单栏保持可见。")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }

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
                            confirmAndResetGame()
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
        .alert("确认重置符文树", isPresented: $showRuneTreeResetAlert) {
            Button("取消", role: .cancel) {}
            Button("重置", role: .destructive) {
                gameEngine.resetRuneTree()
            }
        } message: {
            Text("将清空已解锁符文，并返还已核对的金币成本。")
        }
        .alert(
            "重置失败",
            isPresented: Binding(
                get: { resetFailureMessage != nil },
                set: { if !$0 { resetFailureMessage = nil } }
            )
        ) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(resetFailureMessage ?? "")
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

    private var isPanelScaleAdjustable: Bool {
        MenuBarPopoverLayout.maximumScale > MenuBarPopoverLayout.minimumScale
    }

    private var currentHeroLevelCapBreakdown: HeroLevelCapBreakdown {
        HeroLevelPacing.levelCapBreakdown(for: gameEngine.progress)
    }

    private var currentHeroLevelCapStatus: HeroLevelCapStatus {
        HeroLevelPacing.levelCapStatus(for: gameEngine.hero, progress: gameEngine.progress)
    }

    private var currentHeroLevelCapText: String {
        "Lv.\(currentHeroLevelCapBreakdown.maxLevel)"
    }

    private var currentHeroLevelCapStatusText: String {
        "\(currentHeroLevelCapStatus.levelText) · \(currentHeroLevelCapStatus.statusText)"
    }

    private var currentHeroLevelCapXPText: String {
        currentHeroLevelCapStatus.xpSpaceText
    }

    private var currentHeroLevelCapFormulaText: String {
        currentHeroLevelCapBreakdown.formulaText
    }

    private func quitGame() {
        gameEngine.stop()
        NSApplication.shared.terminate(nil)
    }

    private func confirmAndResetGame() {
        let alert = NSAlert()
        alert.messageText = "确认重置"
        alert.informativeText = "将删除所有存档数据，此操作不可撤销。"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "重置")
        alert.addButton(withTitle: "取消")

        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let deletedExistingSave = gameEngine.resetGame()
        if !deletedExistingSave {
            resetFailureMessage = "无法删除旧存档文件，已重置当前内存状态并尝试写入干净存档。请检查存档目录权限。"
        }
    }
}

struct ChestControlsView: View {
    @ObservedObject var gameEngine: GameEngine

    var body: some View {
        GroupBox("箱子") {
            VStack(alignment: .leading, spacing: 7) {
                ChestAutoOpenStatusStrip(gameEngine: gameEngine)

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
                    batchOpenControls
                    chestRows
                }
            }
            .font(.system(size: 11))
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private var batchOpenControls: some View {
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
    }

    private var chestRows: some View {
        VStack(alignment: .leading, spacing: 6) {
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

    private var chestKindsWithSavedChests: [ChestKind] {
        ChestKind.allCases.filter { gameEngine.progress.chests.count(for: $0) > 0 }
    }
}

private struct ChestAutoOpenStatusStrip: View {
    @ObservedObject var gameEngine: GameEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("自动开箱")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 6) {
                ForEach(ChestFamily.allCases) { family in
                    ChestAutoOpenFamilyBadge(
                        family: family,
                        isUnlocked: isUnlocked(family),
                        remaining: gameEngine.autoOpenChestCooldowns.remaining(for: family),
                        cycle: gameEngine.runeTree.autoOpenCooldown(for: family)
                    )
                }
            }
        }
    }

    private func isUnlocked(_ family: ChestFamily) -> Bool {
        switch family {
        case .normalMonster:
            return gameEngine.runeTree.canAutoOpenNormalChests
        case .stageBoss:
            return gameEngine.runeTree.canAutoOpenStageBossChests
        case .actBoss:
            return gameEngine.runeTree.canAutoOpenActBossChests
        }
    }
}

private struct ChestAutoOpenFamilyBadge: View {
    let family: ChestFamily
    let isUnlocked: Bool
    let remaining: TimeInterval
    let cycle: TimeInterval

    var body: some View {
        HStack(spacing: 5) {
            PixelSprite(
                imageName: GameArt.chestIconName(for: sampleChest),
                size: CGSize(width: 16, height: 16)
            )

            VStack(alignment: .leading, spacing: 1) {
                Text(familyShortName)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)
                Text(statusText)
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundColor(isUnlocked ? .green : .secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isUnlocked ? Color.green.opacity(0.14) : Color.secondary.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var sampleChest: LootChest {
        switch family {
        case .normalMonster:
            return LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal, family: .normalMonster)
        case .stageBoss:
            return LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss)
        case .actBoss:
            return LootChest(kind: .normal, itemLevel: 30, sourceStageCode: "1-10", sourceDifficulty: .normal, family: .actBoss)
        }
    }

    private var familyShortName: String {
        switch family {
        case .normalMonster:
            return "普通"
        case .stageBoss:
            return "关底"
        case .actBoss:
            return "Act"
        }
    }

    private var statusText: String {
        guard isUnlocked else { return "未解锁" }
        if remaining > 0 {
            return "剩\(formatSeconds(remaining))"
        }
        return "就绪/\(formatSeconds(cycle))"
    }

    private func formatSeconds(_ seconds: TimeInterval) -> String {
        let rounded = max(0, Int(seconds.rounded()))
        let minutes = rounded / 60
        let secondPart = rounded % 60
        if minutes > 0 {
            return "\(minutes)m\(secondPart)s"
        }
        return "\(secondPart)s"
    }
}

enum OriginalFidelityBoundaryMetrics {
    static let exactItemRecordCount = 0
    static let originalHeroClassCount = 6

    static var hardGapRows: [OriginalFidelityHardGapRowModel] {
        [
            OriginalFidelityHardGapRowModel(
                key: "skill-runtime-evidence",
                title: "技能运行时证据",
                currentEvidence: "\(pendingSourceSkillCount) 个源技能待接入，\(PendingSourceSkillReviewMetrics.minimumEvidencePendingCount) 个达到最小证据候选",
                requiredProof: "本地化名称、归属、delivery、目标/公式、持续/触发、动作帧和 SFX",
                boundary: "不按 value、range、damage 或 ID 前缀生成运行时技能"
            ),
            OriginalFidelityHardGapRowModel(
                key: "rune-cost-economy",
                title: "Rune 成本/退款",
                currentEvidence: "\(LocalRuneCostReviewMetrics.pendingCount) 个节点待核价，\(LocalRuneCostReviewMetrics.pendingCostEvidenceQueueCount) 个成本队列",
                requiredProof: "逐节点费用、路径位置、货币/点数类型、重复节点梯度和重置退款",
                boundary: "不按图标组、maxLevel、分支或单源候选成本生成符文经济"
            ),
            OriginalFidelityHardGapRowModel(
                key: "original-pacing-xp-curve",
                title: "原版节奏/经验曲线",
                currentEvidence: "原作 Tick \(GamePacing.runtimeTickInterval)s，战斗推进 \(GamePacing.simulatedCombatDelta(for: GamePacing.runtimeTickInterval))s，战斗步进 \(GamePacing.combatSimulationStep)s，XP \(Int(GamePacing.appliedXPMultiplier * 100))%，等级上限 +\(GamePacing.stageLevelBuffer)",
                requiredProof: "原版 tick 间隔、战斗步进、攻击间隔、XP 曲线、关卡等级上限和二周目加成",
                boundary: "不按本地 GamePacing 参数声明原版刷怪速度或升级曲线已还原"
            ),
            OriginalFidelityHardGapRowModel(
                key: "exact-item-records",
                title: "精确装备记录",
                currentEvidence: "\(exactItemRecordCount)/\(SourceItemCatalog.expectedGearEntryCount) 条逐件装备记录",
                requiredProof: "逐件变体 ID、词缀/稀有度 rolls、掉落权重、图标变体和来源交叉证明",
                boundary: "不按聚合数量、基础进度图标或稀有度分布生成装备记录或新图标"
            ),
            OriginalFidelityHardGapRowModel(
                key: "source-monster-runtime-art",
                title: "源表怪物运行时/美术",
                currentEvidence: "\(SourceMonsterArtMappingMetrics.sourceRosterArtGapCount) 个源表怪物仍缺关卡/美术/运行时证据：\(SourceMonsterDatabaseMetrics.sourceRosterArtGapNamesText)",
                requiredProof: "原版出场关卡、专属 sprite、动作帧、缩放锚点、技能归属和掉落证据",
                boundary: "不按单张 sprite、best-farm 文本或 ID 前缀生成怪物、关卡遭遇或技能"
            ),
            OriginalFidelityHardGapRowModel(
                key: "original-action-frames",
                title: "原版动作帧",
                currentEvidence: "\(SourceBattleAnimationEvidenceReviewMetrics.exactOriginalActionFrameCount) 组已核对原版动作帧",
                requiredProof: "idle、attack、hit、death、施法、飞行、命中、Buff 和召唤逐帧捕获",
                boundary: "不按本地替代动效或 Steam 单段运动采样声明原版动画还原"
            ),
            OriginalFidelityHardGapRowModel(
                key: "isolated-original-sfx",
                title: "原版单事件 SFX",
                currentEvidence: "\(SourceAudioSFXEvidenceReviewMetrics.originalIsolatedSFXCount) 条已隔离原版 SFX",
                requiredProof: "原版音频资源、带时间码录屏音轨或可复现 per-event 采样",
                boundary: "不按本地 generated_substitute WAV 或 Trailer 总音轨声明原声音效还原"
            )
        ]
    }

    static var hardGapRowCount: Int {
        hardGapRows.count
    }

    static var runtimeSkillCoverageText: String {
        "\(runtimeModeledSourceSkillCount)/\(totalSourceSkillCount)"
    }

    static var runtimeModeledSourceSkillCount: Int {
        SourceSkillCatalog.runtimeModeledSkills.count
    }

    static var totalSourceSkillCount: Int {
        SourceSkillCatalog.all.count
    }

    static var pendingSourceSkillCount: Int {
        max(0, totalSourceSkillCount - runtimeModeledSourceSkillCount)
    }

    static var sourceRuneCoverageText: String {
        "\(SourceRuneCatalog.runtimeModeledNodes.count)/\(SourceRuneCatalog.all.count)"
    }

    static var exactItemRecordCoverageText: String {
        "\(exactItemRecordCount)/\(SourceItemCatalog.expectedGearEntryCount)"
    }

    static var sourceGearProgressionCoverageText: String {
        "\(SourceItemCatalog.totalGearLevelProgressionCount)/\(SourceItemCatalog.expectedGearLevelProgressionCount)"
    }

    static var passiveSkillSourceCoverageText: String {
        "\(SourcePassiveSkillDatabaseMetrics.sourceRowCount)/\(SourcePassiveSkillDatabaseMetrics.sourceRowCount)"
    }

    static var passiveSkillSourceIconCoverageText: String {
        SourcePassiveSkillDatabaseMetrics.sourceIconCoverageText
    }

    static var passiveSkillBoundaryText: String {
        "\(passiveSkillSourceCoverageText) 被动技能源行已进入复核表，\(passiveSkillSourceIconCoverageText) 被动源图标可用；缺图属性 \(SourcePassiveSkillDatabaseMetrics.currentMissingSourceIconStats.sorted().joined(separator: " / ")) 不使用本地图标替代，原版解锁路径和完整运行时语义仍待核对"
    }

    static var battleHeroSpriteCoverageText: String {
        "\(battleHeroSpriteCount)/\(originalHeroClassCount)"
    }

    static var battleHeroSourceSpriteCoverageText: String {
        "\(battleHeroSourceSpriteCount)/\(originalHeroClassCount)"
    }

    static var battleHeroSpriteCount: Int {
        Set(HeroClass.allCases.map(GameArt.battleHeroSpriteName(for:))).count
    }

    static var battleHeroSourceSpriteCount: Int {
        Set(HeroClass.allCases.map(GameArt.heroSpriteName(for:))).count
    }

    static let battleHeroSpriteBoundaryText = "战斗英雄贴图已有职业身份与来源守卫；原版战斗姿态/动作帧仍待核对"

    static var skillEffectBoundaryText: String {
        "当前技能特效/音效为本地可审计替代；\(pendingSourceSkillCount) 个源技能仍缺原版动作帧、命中表现、触发时序和原声音效证据"
    }

    static var pendingSkillReadinessText: String {
        PendingSourceSkillReviewMetrics.pendingValueReadinessText
    }

    static var pendingSkillRuntimeBoundaryText: String {
        "\(pendingSourceSkillCount) 个源技能仍停留在数据态；其中 \(pendingSkillReadinessText)，且 \(PendingSourceSkillReviewMetrics.pendingValueDetailEvidenceText)。这些 value/range 只能证明源页数值，不证明本地化名称、归属、delivery、目标、公式或持续时间"
    }

    static var inventoryExpansionCoverageText: String {
        let sourceCount = SourceRuneCatalog.expectedIconDistribution["MaxInventorySlot"] ?? 0
        return "\(RuneTree.inventoryExpansionNodes.count)/\(sourceCount)"
    }

    static var runeInventoryExpansionSlotBonusText: String {
        "+\(RuneTree.inventoryExpansionSlotBonus)"
    }

    static var directInventoryExpansionSlotBonusText: String {
        "+\(InventoryExpansion.slotBonus)"
    }

    static var directInventoryExpansionBaseCostText: String {
        "\(InventoryExpansion.baseGoldCost.formatted())G"
    }

    static var directInventoryExpansionSecondCostText: String {
        "\(InventoryExpansion.nextGoldCost(after: 1).formatted())G"
    }

    static var inventoryExpansionBoundaryText: String {
        "\(inventoryExpansionCoverageText) MaxInventorySlot 源符文已接入本地背包容量，每个符文本地脚手架 \(runeInventoryExpansionSlotBonusText) 格；背包面板直接扩容每次 \(directInventoryExpansionSlotBonusText) 格，首购 \(directInventoryExpansionBaseCostText)、二次 \(directInventoryExpansionSecondCostText)。原版精确成本、上限、叠加规则和背包布局仍待核对"
    }

    private static let stashPageNodes: [RuneTreeNode] = [
        .stashPage1,
        .stashPage2,
        .stashPage3,
    ]

    static var stashPageCoverageText: String {
        let sourceCount = SourceRuneCatalog.expectedIconDistribution["UnlockStashPageCount"] ?? 0
        return "\(stashPageNodes.count)/\(sourceCount)"
    }

    static var stashPageSlotBonusText: String {
        "+\(RuneTree.stashPageSlotBonus)"
    }

    static var stashPageBoundaryText: String {
        "\(stashPageCoverageText) UnlockStashPageCount 源符文已接入本地容量，每个储存符文本地脚手架 \(stashPageSlotBonusText) 格；当前折算为同一背包容量，不声明原版独立仓库页布局、分页上限、路径成本或重置经济"
    }

    static var sourceMonsterDatabaseCoverageText: String {
        "\(SourceMonsterDatabase.rowCount)/\(SourceMonsterDatabase.rowCount)"
    }

    static var sourceMonsterStageCompositionCoverageText: String {
        SourceMonsterDatabaseMetrics.stageCompositionCoverageText
    }

    static var sourceMonsterDatabaseBoundaryText: String {
        "\(sourceMonsterDatabaseCoverageText) Wiki/datamined 怪物数值行已进入复核表，去重后 \(SourceMonsterDatabaseMetrics.steamRosterIdentityCoverageText) 源怪物名覆盖 Steam 50+ 下限，\(sourceMonsterStageCompositionCoverageText) 关卡组成名能解析到源怪物；另有 \(SourceMonsterDatabaseMetrics.sourceRosterArtGapCount) 个源怪物未进入当前关卡组成/美术映射：\(SourceMonsterDatabaseMetrics.sourceRosterArtGapNamesText)。运行时只采用基础 ATK/攻速标量，HP/金币/经验仍以关卡表为准，不声明怪物技能、美术或动作帧已完整还原，也不绘制新怪物图"
    }

    static var stageMonsterArtCoverageText: String {
        SourceMonsterArtMappingMetrics.artMappingCoverageText
    }

    static var stageMonsterSourceRosterArtGapCount: Int {
        SourceMonsterArtMappingMetrics.sourceRosterArtGapCount
    }

    static let stageMonsterArtBoundaryText = "源表去重怪物名已覆盖 Steam 50+ 下限，但当前只核对关卡组成怪物映射；源表未映射怪物、逐怪物动作帧和精确专属贴图仍待核对"

    static var verifiedRuneCostCount: Int {
        RuneTreeNode.allCases.filter(\.hasVerifiedGoldCost).count
    }

    static var approximateRuneCostCount: Int {
        RuneTreeNode.allCases.filter { $0.approximateGoldCost != nil }.count
    }

    static var unverifiedRuneCostCount: Int {
        RuneTreeNode.allCases.filter { !$0.hasVerifiedGoldCost }.count
    }
}

struct OriginalFidelityHardGapRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let currentEvidence: String
    let requiredProof: String
    let boundary: String

    var id: String { key }
}

struct SourceAudioSFXEvidenceRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let currentEvidence: String
    let boundary: String
    let nextEvidence: String

    var id: String { key }
}

struct SourceAudioSFXEventGateRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let currentEvidence: String
    let requiredProof: String
    let boundary: String

    var id: String { key }
}

enum SourceAudioSFXEvidenceReviewMetrics {
    static let steamTrailerDurationSeconds = 47
    static let steamTrailerSampleRateHz = 48_000
    static let steamTrailerChannels = 2
    static let steamTrailerIntegratedLoudnessLUFS = "-15.3 LUFS"
    static let steamTrailerLoudnessRangeLU = "4.6 LU"
    static let steamTrailerTruePeakDBFS = "0.0 dBFS"
    static let localSFXSampleRateHz = 22_050
    static let localSFXChannels = 1
    static let localSFXBitDepth = 16
    static let localSFXProvenance = "generated_substitute"
    static let localSFXOfficialAudio = false
    static let originalIsolatedSFXCount = 0
    static let sourceBoundaryText = "Steam Trailer 只证明整体音频呈现，不证明任何单个战斗、掉落、装备或 UI 事件的原版 SFX"
    static let localBoundaryText = "本地 WAV 必须保持 generated_substitute / officialAudio=false；取得原版单事件音频前不得声明原声音效还原"
    static let eventGateBoundaryText = "SFX 接入门槛只定义补证顺序；不按本地 WAV、Trailer 混音、事件名称、路由完整度或音量包络生成原版单事件音效"

    static var localSFXEventCount: Int {
        GameAudioEvent.allCases.count
    }

    static var localSFXResourceCount: Int {
        Set(GameAudioEvent.bundledResourceNames).count
    }

    static var localSFXFormatText: String {
        "\(localSFXSampleRateHz.formatted()) Hz / mono / \(localSFXBitDepth)-bit"
    }

    static var steamTrailerFormatText: String {
        "AAC LC \(steamTrailerSampleRateHz.formatted()) Hz stereo"
    }

    static var rows: [SourceAudioSFXEvidenceRowModel] {
        [
            SourceAudioSFXEvidenceRowModel(
                key: "steam-trailer-baseline",
                title: "Steam Trailer 基线",
                currentEvidence: "\(steamTrailerDurationSeconds)s / \(steamTrailerFormatText) / \(steamTrailerIntegratedLoudnessLUFS)",
                boundary: sourceBoundaryText,
                nextEvidence: "保留 `scripts/audit-steam-audio.sh` 复测；不要从 Trailer 音轨切片当作事件音效"
            ),
            SourceAudioSFXEvidenceRowModel(
                key: "steam-loudness-envelope",
                title: "整体响度包络",
                currentEvidence: "\(steamTrailerLoudnessRangeLU) LRA / true peak \(steamTrailerTruePeakDBFS)",
                boundary: "响度包络只用于发现本地音频过响、过静或持续静音风险，不证明逐事件音色相同",
                nextEvidence: "需要游戏内录屏或授权资源才能建立 per-event SFX 对照"
            ),
            SourceAudioSFXEvidenceRowModel(
                key: "local-sfx-manifest",
                title: "本地 SFX 清单",
                currentEvidence: "\(localSFXEventCount) 事件 / \(localSFXResourceCount) WAV / \(localSFXFormatText)",
                boundary: localBoundaryText,
                nextEvidence: "`sfx_manifest.tsv` 继续记录 SHA-256、字节数、格式和非原版来源"
            ),
            SourceAudioSFXEvidenceRowModel(
                key: "runtime-routing",
                title: "运行时路由",
                currentEvidence: "GameAudioEvent 覆盖战斗、掉落、装备、消耗、升级和预览",
                boundary: "路由完整只证明本地事件会播放替代音，不证明原版事件分类或混音规则",
                nextEvidence: "原版事件音频或可复现实测后再拆分更多 per-skill/per-hit 音轨"
            ),
            SourceAudioSFXEvidenceRowModel(
                key: "package-audit",
                title: "发布包守卫",
                currentEvidence: "`audit-local-sfx.sh` 校验源码与 dist 包内 WAV/manifest payload 一致",
                boundary: "打包一致性只防资源缺失或串包，不把替代音升级为官方音频",
                nextEvidence: "发布前继续运行源码和 packaged SFX 审计"
            ),
            SourceAudioSFXEvidenceRowModel(
                key: "isolated-original-gap",
                title: "原版单事件缺口",
                currentEvidence: "\(originalIsolatedSFXCount) 条已隔离原版 SFX",
                boundary: "没有原版施法、命中、持续、结束、掉落或 UI 单事件音频证据",
                nextEvidence: "补原版音频资源、带时间码录屏音轨或可复现采样"
            )
        ]
    }

    static var rowCount: Int {
        rows.count
    }

    static var eventGateRows: [SourceAudioSFXEventGateRowModel] {
        [
            SourceAudioSFXEventGateRowModel(
                key: "basic-combat-hit",
                title: "普攻/受击命中",
                currentEvidence: "本地 battleHit/battleBlock/battleDodge 为 generated_substitute；无原版普攻、暴击、格挡、闪避单事件音频",
                requiredProof: "原版普攻命中、暴击、受击、格挡、闪避和死亡事件的独立采样或带时间码录屏",
                boundary: eventGateBoundaryText
            ),
            SourceAudioSFXEventGateRowModel(
                key: "skill-cast-release",
                title: "技能起手/释放",
                currentEvidence: "本地按 GameAudioEvent 路由通用战斗提示音；无逐职业/逐技能 cast 与 release 音频",
                requiredProof: "每职业技能起手、释放、持续、结束的原版事件划分、触发时机和单事件音频",
                boundary: eventGateBoundaryText
            ),
            SourceAudioSFXEventGateRowModel(
                key: "projectile-impact",
                title: "弹道/爆点/元素",
                currentEvidence: "本地视觉 fixture 区分火/冰/电/混沌等命中效果；音频仍是本地替代清单",
                requiredProof: "投射物发射、飞行、爆点、元素命中、连锁、召唤体攻击的原版 SFX 和时间码",
                boundary: eventGateBoundaryText
            ),
            SourceAudioSFXEventGateRowModel(
                key: "buff-status-loop",
                title: "Buff/状态/循环",
                currentEvidence: "本地状态徽章和敌方状态可见；无原版 Buff 开始、持续循环、刷新、结束音频",
                requiredProof: "原版 Buff、DoT、眩晕、冻结、召唤、陷阱和光环的开始/循环/结束音频与叠加规则",
                boundary: eventGateBoundaryText
            ),
            SourceAudioSFXEventGateRowModel(
                key: "loot-inventory-ui",
                title: "掉落/背包/UI",
                currentEvidence: "本地 lootFound、itemEquipped、itemConsumed、previewTick 等 UI/物品音效为替代音",
                requiredProof: "掉落、开箱、装备、炼金、合成、预览、升级、失败/锁定等原版 UI 与物品音效",
                boundary: eventGateBoundaryText
            ),
            SourceAudioSFXEventGateRowModel(
                key: "mix-throttle-randomization",
                title: "混音/节流/随机",
                currentEvidence: "本地有音量、最小播放间隔和界面关闭静音规则；无原版混音或随机变体证据",
                requiredProof: "原版音量层级、声道、重叠限制、冷却节流、随机音色/音高变体和界面静音行为",
                boundary: eventGateBoundaryText
            ),
            SourceAudioSFXEventGateRowModel(
                key: "package-provenance",
                title: "来源/打包/授权",
                currentEvidence: "本地 manifest 记录 generated_substitute、officialAudio=false 和 SHA-256；无授权原版资源",
                requiredProof: "原版资源来源、授权状态、SHA-256、格式、采样率、声道、字节数和发布包路径",
                boundary: eventGateBoundaryText
            )
        ]
    }

    static var eventGateCount: Int {
        eventGateRows.count
    }

    static var eventGateMissingCount: Int {
        eventGateRows.count - originalIsolatedSFXCount
    }

    static var localGeneratedSubstituteText: String {
        "\(localSFXEventCount)/\(localSFXResourceCount) \(localSFXProvenance)"
    }
}

struct SourceBattleAnimationEvidenceRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let currentEvidence: String
    let boundary: String
    let nextEvidence: String

    var id: String { key }
}

struct SourceBattleAnimationMotionSampleRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let value: String
    let boundary: String

    var id: String { key }
}

struct SourceBattleAnimationActionFrameGateRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let currentEvidence: String
    let requiredProof: String
    let boundary: String

    var id: String { key }
}

enum SourceBattleAnimationEvidenceReviewMetrics {
    static let officialVideoWidth = 776
    static let officialVideoHeight = 180
    static let officialFPS = 30
    static let officialDurationMilliseconds = 6_133
    static let officialFrameCount = 184
    static let officialMotionSampleStartFrame = 0
    static let officialMotionSampleEndFrame = 8
    static let officialMotionSampleMilliseconds = 267
    static let officialMotionPixels = 26_623
    static let officialPlatformMotionPixels = 11_920
    static let officialNonPlatformMotionPixels = 14_703
    static let officialMotionPercentX10000 = 1_906
    static let localRenderWidthPixels = 1_232
    static let localRenderHeightPixels = 600
    static let localBattleTabRenderWidthPixels = 1_280
    static let localBattleTabRenderHeightPixels = 1_200
    static let localConfiguredRatioX100 = 205
    static let localPopoverWidthPoints = 640
    static let localPopoverHeightPoints = 600
    static let localContentHeightPoints = 488
    static let localBattleSceneHeightPoints = 300
    static let localBottomTabHeightPoints = 46
    static let exactOriginalActionFrameCount = 0
    static let sourceBoundaryText = "Steam battle media 只证明整体构图和采样运动，不证明原版逐动作关键帧、攻击时序或 sprite 锚点"
    static let localBoundaryText = "本地确定性渲染只用于回归守卫；不能替代原版逐帧动画、动作帧数量、sprite 比例或命中帧证据"
    static let keyframeGapBoundaryText = "原版 idle/attack/hit/death 关键帧仍未取得；不得按当前本地动效声明原版动画还原"
    static let actionFrameGateBoundaryText = "动作帧门槛只定义接入前必须补齐的原版证据；不按本地速度线、命中闪光、替代特效或单段宣传片运动采样生成原版动作帧"

    static var officialDurationText: String {
        secondsText(milliseconds: officialDurationMilliseconds)
    }

    static var officialMotionSampleText: String {
        secondsText(milliseconds: officialMotionSampleMilliseconds)
    }

    static var officialMotionSampleFramePairText: String {
        "frame \(officialMotionSampleStartFrame)->\(officialMotionSampleEndFrame)"
    }

    static var officialMotionPercentText: String {
        String(format: "%.4f", Double(officialMotionPercentX10000) / 10_000)
    }

    static var officialPlatformMotionShareText: String {
        percentText(officialPlatformMotionPixels, of: officialMotionPixels)
    }

    static var officialNonPlatformMotionShareText: String {
        percentText(officialNonPlatformMotionPixels, of: officialMotionPixels)
    }

    static var localConfiguredRatioText: String {
        String(format: "%.2f:1", Double(localConfiguredRatioX100) / 100)
    }

    static var officialVideoSizeText: String {
        "\(officialVideoWidth)x\(officialVideoHeight)"
    }

    static var localRenderSizeText: String {
        "\(localRenderWidthPixels)x\(localRenderHeightPixels)"
    }

    static var localBattleTabRenderSizeText: String {
        "\(localBattleTabRenderWidthPixels)x\(localBattleTabRenderHeightPixels)"
    }

    static var localPopoverSizeText: String {
        "\(localPopoverWidthPoints)x\(localPopoverHeightPoints)pt"
    }

    static var localLayoutFootprintText: String {
        "\(localPopoverSizeText) / content \(localContentHeightPoints)pt / scene \(localBattleSceneHeightPoints)pt / tab \(localBottomTabHeightPoints)pt"
    }

    static var rows: [SourceBattleAnimationEvidenceRowModel] {
        [
            SourceBattleAnimationEvidenceRowModel(
                key: "official-media-baseline",
                title: "官方媒体基线",
                currentEvidence: "\(officialVideoSizeText) / \(officialFPS)fps / \(officialFrameCount) frames / \(officialDurationText)",
                boundary: sourceBoundaryText,
                nextEvidence: "继续用 `scripts/audit-steam-battle-scene.sh` 复测 Steam media；不要从单段宣传视频推导完整动作表"
            ),
            SourceBattleAnimationEvidenceRowModel(
                key: "official-motion-sample",
                title: "官方运动采样",
                currentEvidence: "\(officialMotionSampleFramePairText) / \(officialMotionSampleText) / \(officialMotionPixels.formatted()) px / \(officialMotionPercentText)",
                boundary: "采样运动只证明官方片段非静态；不证明攻击、施法、受击或死亡动作的关键帧归属",
                nextEvidence: "补可复现的逐帧原版捕获，按角色、怪物、技能和事件拆分"
            ),
            SourceBattleAnimationEvidenceRowModel(
                key: "local-deterministic-render",
                title: "本地确定性渲染",
                currentEvidence: "\(localRenderSizeText) battle scene / \(localConfiguredRatioText) / fixed 0s + \(officialMotionSampleText)",
                boundary: localBoundaryText,
                nextEvidence: "继续用确定性快照防止本地动效、HP 条、投射物和底部菜单消失"
            ),
            SourceBattleAnimationEvidenceRowModel(
                key: "fixture-coverage",
                title: "本地 fixture 覆盖",
                currentEvidence: "\(localBattleTabRenderSizeText) full Battle tab + damage/utility/status/log fixtures",
                boundary: "fixture 覆盖只证明本地替代效果可见，不证明原版特效贴图、关键帧或帧率一致",
                nextEvidence: "补官方逐技能/逐怪物动作帧后再建立 fixture 对照表"
            ),
            SourceBattleAnimationEvidenceRowModel(
                key: "battle-tab-layout",
                title: "完整 Battle tab 布局",
                currentEvidence: "\(localLayoutFootprintText)，底部菜单固定在内容区下方",
                boundary: "弹窗尺寸、战斗区高度和底部菜单位置是本地 macOS 布局守卫；不证明原版 Windows 任务栏窗口比例或 UI 间距",
                nextEvidence: "继续用 battleTabLayout 截图审计防止战斗区缩小、底部菜单丢失或内容被压缩"
            ),
            SourceBattleAnimationEvidenceRowModel(
                key: "layout-translation",
                title: "macOS 布局翻译",
                currentEvidence: "官方 4.31:1 宽条证据；本地扩展为 \(localConfiguredRatioText) 高视口",
                boundary: "放大视口是 macOS 可读性优化，不声明等同官方窗口比例或 Windows 任务栏布局",
                nextEvidence: "补原版运行截图和窗口/任务栏锚点后再校准最终比例"
            ),
            SourceBattleAnimationEvidenceRowModel(
                key: "exact-keyframe-gap",
                title: "精确关键帧缺口",
                currentEvidence: "\(exactOriginalActionFrameCount) 组已核对原版动作帧",
                boundary: keyframeGapBoundaryText,
                nextEvidence: "补 idle、attack、hit、death、施法、飞行、命中、Buff 和召唤帧"
            )
        ]
    }

    static var motionSampleRows: [SourceBattleAnimationMotionSampleRowModel] {
        [
            SourceBattleAnimationMotionSampleRowModel(
                key: "frame-pair",
                title: "采样帧对",
                value: "\(officialMotionSampleFramePairText) · \(officialMotionSampleText) · \(officialFPS)fps",
                boundary: "只表示 Steam battlescene 宣传片中的固定采样帧对，不等同完整动作循环"
            ),
            SourceBattleAnimationMotionSampleRowModel(
                key: "full-frame-delta",
                title: "全画面变化",
                value: "\(officialMotionPixels.formatted()) px · coverage \(officialMotionPercentText)",
                boundary: "证明该采样片段有可测运动；不拆分为 idle、attack、hit 或 death 帧"
            ),
            SourceBattleAnimationMotionSampleRowModel(
                key: "platform-delta",
                title: "下方平台变化",
                value: "\(officialPlatformMotionPixels.formatted()) px · \(officialPlatformMotionShareText) of changed pixels",
                boundary: "证明火焰/平台区域有运动；不证明本地火焰帧序或速度完全一致"
            ),
            SourceBattleAnimationMotionSampleRowModel(
                key: "non-platform-delta",
                title: "非平台变化",
                value: "\(officialNonPlatformMotionPixels.formatted()) px · \(officialNonPlatformMotionShareText) of changed pixels",
                boundary: "证明平台外也有运动；不证明具体角色、怪物、投射物或命中关键帧"
            )
        ]
    }

    static var actionFrameGateRows: [SourceBattleAnimationActionFrameGateRowModel] {
        [
            SourceBattleAnimationActionFrameGateRowModel(
                key: "hero-idle-move",
                title: "英雄 idle/move",
                currentEvidence: "6 个职业有本地战斗 sprite 和低频 idle 替代；无逐职业原版 idle/move 帧表",
                requiredProof: "每职业朝向、锚点、循环帧数、帧时长、站位偏移和缩放",
                boundary: actionFrameGateBoundaryText
            ),
            SourceBattleAnimationActionFrameGateRowModel(
                key: "hero-attack-cast",
                title: "英雄攻击/施法",
                currentEvidence: "本地按日志触发速度线、压缩和命中闪光；无原版 windup/release/hit 帧",
                requiredProof: "普攻、BASEATTACK_COUNT、COOLDOWN 和 CONTINUOUS 技能的起手、释放、命中帧",
                boundary: actionFrameGateBoundaryText
            ),
            SourceBattleAnimationActionFrameGateRowModel(
                key: "hero-hit-death",
                title: "英雄受击/倒下",
                currentEvidence: "本地有 dodge/block/critical 浮字和终局提示；无原版受击、格挡、闪避、死亡、复活帧",
                requiredProof: "受击硬直、格挡、闪避、死亡、复活和胜负收尾帧序",
                boundary: actionFrameGateBoundaryText
            ),
            SourceBattleAnimationActionFrameGateRowModel(
                key: "support-party",
                title: "支援小队动作",
                currentEvidence: "本地支援成员复用职业战斗 sprite 和状态徽章；无原版小队动作节奏",
                requiredProof: "支援动作帧、站位、攻击/施法同步、缩放层级、出手间隔和被遮挡规则",
                boundary: actionFrameGateBoundaryText
            ),
            SourceBattleAnimationActionFrameGateRowModel(
                key: "monster-idle-move",
                title: "怪物 idle/move",
                currentEvidence: "49 个当前关卡怪物有本地映射，3 个源怪物只有数据/单图证据；无原版 idle/move 帧表",
                requiredProof: "每怪物 idle/move 循环帧数、朝向、锚点、尺寸、地面接触点和站位范围",
                boundary: actionFrameGateBoundaryText
            ),
            SourceBattleAnimationActionFrameGateRowModel(
                key: "monster-attack-hit-death",
                title: "怪物攻击/受击/死亡",
                currentEvidence: "4 个怪物攻击有源表元数据和本地 incoming cue；无原版攻击、受击、死亡关键帧",
                requiredProof: "怪物出手帧、命中帧、受击反应、死亡/消失帧、Boss 特殊动作",
                boundary: actionFrameGateBoundaryText
            ),
            SourceBattleAnimationActionFrameGateRowModel(
                key: "projectile-impact-status",
                title: "弹道/命中/状态",
                currentEvidence: "本地 fixture 覆盖元素弹道、命中、状态和召唤替代效果；无原版逐技能 VFX 帧",
                requiredProof: "飞行帧、轨迹锚点、爆点、持续区域、Buff/DoT/召唤体帧和结束帧",
                boundary: actionFrameGateBoundaryText
            ),
            SourceBattleAnimationActionFrameGateRowModel(
                key: "timing-audio-sync",
                title: "时序/音画同步",
                currentEvidence: "本地审计对齐 0.267s 运动采样；无原版每动作帧时长、hit-stop 或 SFX 同步点",
                requiredProof: "帧率、每动作帧时长、攻击间隔、命中停顿、投射物速度和 per-event SFX 时间码",
                boundary: actionFrameGateBoundaryText
            )
        ]
    }

    static var rowCount: Int {
        rows.count
    }

    static var motionSampleRowCount: Int {
        motionSampleRows.count
    }

    static var actionFrameGateCount: Int {
        actionFrameGateRows.count
    }

    static var actionFrameGateMissingCount: Int {
        actionFrameGateRows.count - exactOriginalActionFrameCount
    }

    private static func secondsText(milliseconds: Int) -> String {
        let seconds = Double(milliseconds) / 1_000
        return String(format: "%.3fs", seconds)
    }

    private static func percentText(_ value: Int, of total: Int) -> String {
        guard total > 0 else { return "0.0%" }
        return String(format: "%.1f%%", Double(value) / Double(total) * 100)
    }
}

struct SupportFormulaReviewRowModel: Identifiable, Equatable {
    let title: String
    let localFormula: String
    let boundary: String

    var id: String { title }
}

enum SupportFormulaReviewMetrics {
    static let supportAttackScalar: Double = 0.35
    static let attackLevelBonusPerHeroLevel = 2
    static let hpLevelBonusPerHeroLevel = 10
    static let defenseLevelBonusPerHeroLevel = 1
    static let speedLevelBonusPerHeroLevel = 0
    static let sampleHeroLevel = 20
    static let localFormulaBoundaryText = "支援属性仍使用主角等级缩放"
    static let runeBoundaryText = "只接入全英雄符文加成"
    static let independentLevelBoundaryText = "独立支援等级/装备公式待核对"
    static let runtimeScopeBoundaryText = "本地公式只用于当前支援战斗脚手架"

    static let rows: [SupportFormulaReviewRowModel] = [
        SupportFormulaReviewRowModel(
            title: "攻击",
            localFormula: "round((基础 ATK + (主角等级-1)*2 + 全英雄攻击) * 全英雄攻击倍率 * 35%)",
            boundary: independentLevelBoundaryText
        ),
        SupportFormulaReviewRowModel(
            title: "生命",
            localFormula: "基础 HP + (主角等级-1)*10",
            boundary: independentLevelBoundaryText
        ),
        SupportFormulaReviewRowModel(
            title: "护甲",
            localFormula: "ceil((基础 DEF + (主角等级-1) + 全英雄护甲) * 全英雄护甲倍率)",
            boundary: independentLevelBoundaryText
        ),
        SupportFormulaReviewRowModel(
            title: "速度",
            localFormula: "基础 SPD + 全英雄移速",
            boundary: "速度当前不随主角等级增长；原版支援速度/装备待核对"
        )
    ]

    static var rowCount: Int {
        rows.count
    }

    static var sampleMember: PartyMember {
        PartyMember(slotIndex: 1, heroClass: .ranger, isUnlocked: true)
    }

    static var lockedSampleMember: PartyMember {
        PartyMember(slotIndex: 1, heroClass: .ranger, isUnlocked: false)
    }

    static var sampleAttack: Int {
        sampleMember.supportAttackPower(heroLevel: sampleHeroLevel)
    }

    static var sampleHP: Int {
        sampleMember.supportMaxHP(heroLevel: sampleHeroLevel)
    }

    static var sampleDefense: Int {
        sampleMember.supportDefense(heroLevel: sampleHeroLevel)
    }

    static var sampleSpeed: Int {
        sampleMember.supportSpeed()
    }
}

enum LocalRuneCostStatus: String {
    case verified = "已核对"
    case approximate = "约值"
    case pending = "待核对"

    var color: Color {
        switch self {
        case .verified:
            return .green
        case .approximate:
            return .orange
        case .pending:
            return .secondary
        }
    }
}

struct LocalRuneCostReviewRowModel: Identifiable, Equatable {
    let node: RuneTreeNode
    let sourceNode: SourceRuneNode?

    var id: String { node.rawValue }
    var sourceID: String { node.sourceRuneID }
    var title: String { node.displayName }
    var costText: String { node.costText }
    var approximateSourceText: String? { node.approximateGoldCostSourceText }

    var status: LocalRuneCostStatus {
        if node.hasVerifiedGoldCost {
            return .verified
        }
        if node.approximateGoldCost != nil {
            return .approximate
        }
        return .pending
    }
}

struct LocalRuneApproximateCostEvidenceRowModel: Identifiable, Equatable {
    let row: LocalRuneCostReviewRowModel

    var id: String {
        "approximate-\(row.id)"
    }

    var title: String {
        row.title
    }

    var sourceIDText: String {
        "#\(row.sourceID)"
    }

    var sourceNameText: String {
        if let sourceNode = row.sourceNode {
            return "\(sourceNode.zhName) / \(sourceNode.enName)"
        }
        return "源 Rune 行待核对"
    }

    var currentEvidence: String {
        let source = row.approximateSourceText ?? "近似来源待核对"
        return "\(row.costText) / \(source)"
    }

    var missingEvidence: String {
        "缺原版游戏内扣费记录、前置路径总价、重置退款比例和点数经济证明"
    }

    var requiredProof: String {
        "同一 Rune ID 的解锁扣费 UI、退款日志或可复现实测记录"
    }

    var boundary: String {
        "不把 \(row.costText) 写入运行时扣费、路径成本、重置退款或点数经济"
    }
}

struct LocalRunePendingCostGroupModel: Identifiable, Equatable {
    let iconName: String
    let rows: [LocalRuneCostReviewRowModel]

    var id: String { iconName }
    var pendingCount: Int { rows.count }

    var sourceNameText: String {
        let names = Array(
            Set(rows.compactMap { row -> String? in
                guard let sourceNode = row.sourceNode else { return nil }
                return "\(sourceNode.zhName) / \(sourceNode.enName)"
            })
        )
        .sorted()
        .prefix(2)

        return names.isEmpty ? "源表名称待核对" : names.joined(separator: "；")
    }

    var sampleSourceIDText: String {
        rows
            .map(\.sourceID)
            .prefix(5)
            .map { "#\($0)" }
            .joined(separator: " ")
    }
}

struct LocalRunePendingCostBranchRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let iconNames: [String]
    let groups: [LocalRunePendingCostGroupModel]

    var id: String { key }
    var groupCount: Int { groups.count }
    var pendingCount: Int { groups.reduce(0) { $0 + $1.pendingCount } }

    var sampleIconText: String {
        groups
            .map(\.iconName)
            .prefix(4)
            .joined(separator: ", ")
    }

    var sampleSourceIDText: String {
        groups
            .flatMap { $0.rows.map(\.sourceID) }
            .prefix(6)
            .map { "#\($0)" }
            .joined(separator: " ")
    }
}

struct LocalRunePendingCostEvidenceQueueRowModel: Identifiable, Equatable {
    let branch: LocalRunePendingCostBranchRowModel

    var id: String {
        "cost-queue-\(branch.key)"
    }

    var title: String {
        "\(branch.title)成本"
    }

    var currentEvidence: String {
        "\(branch.pendingCount) 节点 / \(branch.groupCount) 图标组 / \(branch.sampleSourceIDText)"
    }

    var nextEvidence: String {
        switch branch.key {
        case "chest":
            return "逐节点费用、自动开箱费用截图、容量/掉率升级阶梯和重置退款"
        case "inventory-storage":
            return "背包/仓库页节点费用、容量递增、上限和退款规则"
        case "combat-reward":
            return "金币/经验奖励节点费用、重复节点梯度和路径成本"
        case "hero-stat":
            return "全英雄属性节点费用、重复节点梯度、等级门槛和退款规则"
        case "cube-alchemy":
            return "Cube/炼金收益节点费用、收益曲线和重置经济"
        case "offline":
            return "离线奖励解锁/收益节点费用、8 小时上限和退款规则"
        case "stage-pacing":
            return "关卡节奏节点费用、路径位置、叠加上限和退款规则"
        default:
            return "逐节点费用、路径位置、货币类型和退款规则"
        }
    }

    var boundary: String {
        "不按 \(branch.groupCount) 个图标组推断 \(branch.pendingCount) 个节点价格"
    }
}

struct LocalRunePendingCostBranchEvidenceRowModel: Identifiable, Equatable {
    let branch: LocalRunePendingCostBranchRowModel
    let group: LocalRunePendingCostGroupModel

    var id: String {
        "\(branch.key)-\(group.iconName)"
    }

    var title: String {
        "\(branch.title) · \(group.iconName)"
    }

    var currentEvidence: String {
        "\(group.pendingCount) 节点 / \(group.sampleSourceIDText)"
    }

    var sourceNameText: String {
        group.sourceNameText
    }

    var missingEvidence: String {
        "缺逐节点费用、路径位置、货币/点数类型、重复节点梯度和重置退款证据"
    }

    var requiredProof: String {
        "同一 Rune ID 的 Wiki/游戏内截图/第二来源费用与路径证据"
    }

    var boundary: String {
        "不按 \(group.iconName) 图标组或 \(group.pendingCount) 个重复节点推断符文价格、路径成本、重置退款或点数经济"
    }
}

struct LocalRunePendingCostMaxLevelEvidenceRowModel: Identifiable, Equatable {
    let maxLevel: Int
    let rows: [LocalRuneCostReviewRowModel]

    var id: String {
        "max-level-\(maxLevel)"
    }

    var title: String {
        "maxLevel \(maxLevel) 待核价"
    }

    var pendingCount: Int {
        rows.count
    }

    var iconGroupCount: Int {
        Set(rows.compactMap { $0.sourceNode?.iconName }).count
    }

    var sampleSourceIDText: String {
        rows
            .map(\.sourceID)
            .prefix(6)
            .map { "#\($0)" }
            .joined(separator: " ")
    }

    var sampleIconText: String {
        Array(Set(rows.compactMap { $0.sourceNode?.iconName }))
            .sorted()
            .prefix(4)
            .joined(separator: ", ")
    }

    var currentEvidence: String {
        "\(pendingCount) 节点 / \(iconGroupCount) 图标组 / \(sampleSourceIDText)"
    }

    var nextEvidence: String {
        "补 maxLevel \(maxLevel) 节点的逐级费用、等级上限含义、重复节点成本梯度、路径成本和重置退款"
    }

    var boundary: String {
        "maxLevel 只证明源表等级上限；不按 \(maxLevel) 生成逐级价格、成本梯度、路径成本、重置退款或点数经济"
    }
}

struct LocalRuneCostEvidenceGateRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let currentEvidence: String
    let missingEvidence: String
    let requiredProof: String
    let affectedNodeCount: Int

    var id: String { key }
}

enum LocalRuneCostReviewMetrics {
    static let approximateBoundaryText = "约值成本不参与已核对退款"
    static let approximateEvidenceBoundaryText = "约值证据只证明页面/指南层成本线索；缺游戏内扣费、路径成本、重置退款和点数经济前，不转入已核对运行时成本"
    static let pendingBoundaryText = "成本待核对节点不伪造成金币成本"
    static let resetRefundBoundaryText = "重置仅返还已核对金币成本"
    static let pendingGroupBoundaryText = "分组只定位成本缺口所在源表图标/分支，不推断成本梯度、路径价格或退款规则"
    static let pendingBranchBoundaryText = "玩法分支只用于排列复核优先级，不推断分支价格、前置路径成本、重置退款或点数经济"
    static let costEvidenceGateBoundaryText = "接入门槛只定义成本缺失证据，不生成符文价格、路径成本、重置退款或点数经济"
    static let pendingCostEvidenceQueueBoundaryText = "接入队列只排列互斥复核顺序，不按玩法分支、源表图标、重复节点数量或单源候选数据生成符文价格；不生成符文价格、路径成本、重置退款或点数经济"
    static let pendingCostMaxLevelEvidenceBoundaryText = "maxLevel 队列只排列源表等级上限复核顺序，不按 maxLevel 生成逐级价格、成本梯度、路径成本、重置退款或点数经济"

    private static let pendingBranchDefinitions: [(key: String, title: String, iconNames: [String])] = [
        (
            "chest",
            "箱子掉落/容量/自动开箱",
            [
                "DropChanceNormalChest",
                "DropChanceStageBossChest",
                "MaxAmountActBossChest",
                "MaxAmountNormalChest",
                "MaxAmountStageBossChest",
                "OpenAllTypeChestAllAtOnce",
                "OpenOneTypeChestAllAtOnce",
                "ReduceAutoOpenActBossChestTime",
                "ReduceAutoOpenNormalChestTime",
                "ReduceAutoOpenStageBossChestTime",
                "UnlockAutoOpenActBossChest",
                "UnlockAutoOpenNormalChest",
                "UnlockAutoOpenStageBossChest"
            ]
        ),
        (
            "inventory-storage",
            "背包/仓库容量",
            [
                "MaxInventorySlot",
                "UnlockStashPageCount"
            ]
        ),
        (
            "combat-reward",
            "战斗金币/经验奖励",
            [
                "AdditionalExp",
                "AdditionalExpActBoss",
                "AdditionalExpNormalMonster",
                "AdditionalExpStageBoss",
                "AdditionalGold",
                "AdditionalGoldActBoss",
                "AdditionalGoldNormalMonster",
                "AdditionalGoldStageBoss",
                "IncreaseExpAmount",
                "IncreaseGoldAmount"
            ]
        ),
        (
            "hero-stat",
            "全英雄战斗属性",
            [
                "AllHeroArmor",
                "AllHeroArmorPercent",
                "AllHeroAttackDamage",
                "AllHeroAttackDamagePercent",
                "AllHeroAttackSpeed",
                "AllHeroMoveSpeed"
            ]
        ),
        (
            "cube-alchemy",
            "Cube/炼金收益",
            [
                "CubeAlchemyGoldPercent",
                "CubeExpPercent"
            ]
        ),
        (
            "offline",
            "离线奖励",
            [
                "OfflineRewardExpPercent",
                "OfflineRewardGoldPercent",
                "UnlockOfflineReward"
            ]
        ),
        (
            "stage-pacing",
            "关卡节奏",
            [
                "WaveCountReduction"
            ]
        )
    ]

    static var rows: [LocalRuneCostReviewRowModel] {
        RuneTreeNode.allCases.map {
            LocalRuneCostReviewRowModel(
                node: $0,
                sourceNode: SourceRuneCatalog.byID[$0.sourceRuneID]
            )
        }
    }

    static var rowCount: Int {
        rows.count
    }

    static var verifiedCount: Int {
        rows.filter { $0.status == .verified }.count
    }

    static var approximateCount: Int {
        rows.filter { $0.status == .approximate }.count
    }

    static var approximateSourceBackedCount: Int {
        rows.filter { $0.approximateSourceText != nil }.count
    }

    static var approximateSourceEvidenceText: String {
        rows
            .compactMap(\.approximateSourceText)
            .joined(separator: "；")
    }

    static var approximateEvidenceRows: [LocalRuneApproximateCostEvidenceRowModel] {
        rows
            .filter { $0.status == .approximate }
            .map { LocalRuneApproximateCostEvidenceRowModel(row: $0) }
    }

    static var approximateEvidenceRowCount: Int {
        approximateEvidenceRows.count
    }

    static func approximateEvidenceRow(node: RuneTreeNode) -> LocalRuneApproximateCostEvidenceRowModel? {
        approximateEvidenceRows.first { $0.row.node == node }
    }

    static var pendingCount: Int {
        rows.filter { $0.status == .pending }.count
    }

    static var pendingGroups: [LocalRunePendingCostGroupModel] {
        Dictionary(grouping: rows.filter { $0.status == .pending }) { row in
            row.sourceNode?.iconName ?? "Unknown"
        }
        .map { iconName, rows in
            LocalRunePendingCostGroupModel(
                iconName: iconName,
                rows: rows.sorted { lhs, rhs in lhs.sourceID.localizedStandardCompare(rhs.sourceID) == .orderedAscending }
            )
        }
        .sorted { lhs, rhs in
            if lhs.pendingCount != rhs.pendingCount {
                return lhs.pendingCount > rhs.pendingCount
            }
            return lhs.iconName.localizedStandardCompare(rhs.iconName) == .orderedAscending
        }
    }

    static var pendingGroupCount: Int {
        pendingGroups.count
    }

    static var pendingBranchRows: [LocalRunePendingCostBranchRowModel] {
        let groupsByIconName = Dictionary(
            uniqueKeysWithValues: pendingGroups.map { group in
                (group.iconName, group)
            }
        )

        return pendingBranchDefinitions.compactMap { definition in
            let groups = definition.iconNames.compactMap { groupsByIconName[$0] }
            guard !groups.isEmpty else { return nil }
            return LocalRunePendingCostBranchRowModel(
                key: definition.key,
                title: definition.title,
                iconNames: definition.iconNames,
                groups: groups
            )
        }
    }

    static var pendingBranchCount: Int {
        pendingBranchRows.count
    }

    static var costEvidenceGateRows: [LocalRuneCostEvidenceGateRowModel] {
        [
            LocalRuneCostEvidenceGateRowModel(
                key: "per-node-cost",
                title: "逐节点费用",
                currentEvidence: "\(verifiedCount) 已验证 / \(approximateCount) 近似 / \(pendingCount) 待核对",
                missingEvidence: "每个源 ID 的 gold/point 成本",
                requiredProof: "Wiki、游戏内或第二来源能绑定同一 Rune ID 与费用",
                affectedNodeCount: pendingCount
            ),
            LocalRuneCostEvidenceGateRowModel(
                key: "branch-path-cost",
                title: "路径/前置成本",
                currentEvidence: "\(pendingGroupCount) 图标组 / \(pendingBranchCount) 玩法分支仅用于复核排序",
                missingEvidence: "前置路径总价、分支位置和重复节点成本梯度",
                requiredProof: "完整 Rune Tree 路径、节点费用和重复节点等级成本表",
                affectedNodeCount: pendingCount
            ),
            LocalRuneCostEvidenceGateRowModel(
                key: "reset-refund",
                title: "重置/退款经济",
                currentEvidence: "重置功能源表存在但退款比例未核对",
                missingEvidence: "重置价格、退款比例、已花费成本回流规则",
                requiredProof: "重置 UI、退款日志或可复现实测记录",
                affectedNodeCount: rowCount
            ),
            LocalRuneCostEvidenceGateRowModel(
                key: "candidate-cross-source",
                title: "候选成本交叉证明",
                currentEvidence: "\(SourceRuneEvidenceReviewMetrics.candidateCostRows) tbh.city 候选成本未进 verified",
                missingEvidence: "第二来源或游戏内截图佐证",
                requiredProof: "独立页面、录屏或实测能复核同一 ID 与费用",
                affectedNodeCount: SourceRuneEvidenceReviewMetrics.candidateCostRows
            ),
            LocalRuneCostEvidenceGateRowModel(
                key: "currency-point",
                title: "货币/点数类型",
                currentEvidence: "本地只扣 Gold 的少数已核对路径",
                missingEvidence: "Gold/point/level gating 的完整规则",
                requiredProof: "原版 UI 或数据源证明货币类型、等级门槛和扣费顺序",
                affectedNodeCount: pendingCount
            ),
            LocalRuneCostEvidenceGateRowModel(
                key: "stacking-cap",
                title: "重复节点叠加/上限",
                currentEvidence: "本地效果 scaffold 已接入，成本梯度未核对",
                missingEvidence: "重复节点每级价格、叠加上限、分支 caps",
                requiredProof: "完整多级 Rune 表、游戏内升级录屏或可复现实测",
                affectedNodeCount: pendingCount
            )
        ]
    }

    static var costEvidenceGateCount: Int {
        costEvidenceGateRows.count
    }

    static var pendingCostEvidenceQueueRows: [LocalRunePendingCostEvidenceQueueRowModel] {
        pendingBranchRows.map {
            LocalRunePendingCostEvidenceQueueRowModel(branch: $0)
        }
    }

    static var pendingCostEvidenceQueueCount: Int {
        pendingCostEvidenceQueueRows.count
    }

    static var pendingCostEvidenceQueueCoverage: Int {
        pendingCostEvidenceQueueRows.reduce(0) { $0 + $1.branch.pendingCount }
    }

    static var pendingCostEvidenceQueueGroupCoverage: Int {
        pendingCostEvidenceQueueRows.reduce(0) { $0 + $1.branch.groupCount }
    }

    static var pendingCostBranchEvidenceRows: [LocalRunePendingCostBranchEvidenceRowModel] {
        pendingBranchRows.flatMap { branch in
            branch.groups.map { group in
                LocalRunePendingCostBranchEvidenceRowModel(
                    branch: branch,
                    group: group
                )
            }
        }
    }

    static var pendingCostBranchEvidenceRowCount: Int {
        pendingCostBranchEvidenceRows.count
    }

    static var pendingCostBranchEvidenceCoverage: Int {
        pendingCostBranchEvidenceRows.reduce(0) { $0 + $1.group.pendingCount }
    }

    static var pendingCostBranchEvidenceCoverageText: String {
        "\(pendingCostBranchEvidenceCoverage)/\(pendingCount)"
    }

    static var pendingCostMaxLevelEvidenceRows: [LocalRunePendingCostMaxLevelEvidenceRowModel] {
        Dictionary(grouping: rows.filter { $0.status == .pending }) { row in
            row.sourceNode?.maxLevel ?? -1
        }
        .map { maxLevel, rows in
            LocalRunePendingCostMaxLevelEvidenceRowModel(
                maxLevel: maxLevel,
                rows: rows.sorted { lhs, rhs in
                    lhs.sourceID.localizedStandardCompare(rhs.sourceID) == .orderedAscending
                }
            )
        }
        .sorted { lhs, rhs in lhs.maxLevel < rhs.maxLevel }
    }

    static var pendingCostMaxLevelEvidenceCount: Int {
        pendingCostMaxLevelEvidenceRows.count
    }

    static var pendingCostMaxLevelEvidenceCoverage: Int {
        pendingCostMaxLevelEvidenceRows.reduce(0) { $0 + $1.pendingCount }
    }

    static var pendingCostMaxLevelEvidenceIconBucketTotal: Int {
        pendingCostMaxLevelEvidenceRows.reduce(0) { $0 + $1.iconGroupCount }
    }

    static var pendingCostMaxLevelEvidenceSummaryText: String {
        pendingCostMaxLevelEvidenceRows
            .map { "\($0.maxLevel):\($0.pendingCount)" }
            .joined(separator: ",")
    }

    static var sourceBackedCount: Int {
        rows.filter { $0.sourceNode != nil }.count
    }

    static var verifiedGoldTotal: Int {
        RuneTreeNode.allCases
            .filter(\.hasVerifiedGoldCost)
            .reduce(0) { total, node in total + node.goldCost }
    }

    static var approximateGoldTotal: Int {
        RuneTreeNode.allCases
            .compactMap(\.approximateGoldCost)
            .reduce(0, +)
    }

    static func row(node: RuneTreeNode) -> LocalRuneCostReviewRowModel? {
        rows.first { $0.node == node }
    }

    static func pendingGroup(iconName: String) -> LocalRunePendingCostGroupModel? {
        pendingGroups.first { $0.iconName == iconName }
    }

    static func pendingBranch(key: String) -> LocalRunePendingCostBranchRowModel? {
        pendingBranchRows.first { $0.key == key }
    }

    static func pendingCostMaxLevelEvidenceRow(maxLevel: Int) -> LocalRunePendingCostMaxLevelEvidenceRowModel? {
        pendingCostMaxLevelEvidenceRows.first { $0.maxLevel == maxLevel }
    }
}

struct SourceRuneEvidenceReviewRowModel: Identifiable, Equatable {
    let title: String
    let evidence: String
    let boundary: String
    let confidence: String

    var id: String { title }
}

struct SourceRuneCandidateCostQueueRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let sourceEvidence: String
    let affectedCandidateCount: Int
    let candidateGold: Int
    let missingEvidence: String
    let boundary: String

    var id: String { key }

    var candidateGoldText: String {
        "\(candidateGold.formatted())G"
    }
}

enum SourceRuneEvidenceReviewMetrics {
    static let wikiLocaleCount = 2
    static let independentSourceCount = 6
    static let singleSourceCandidateMirrorCount = 1
    static let verifiedCostRows = 2
    static let approximateCostRows = 1
    static let candidateCostRows = 13
    static let candidateCostGoldTotal = 383_790_000
    static let tbhCityCandidateCostTableRows = 197
    static let tbhCityCandidateCostTableGoldTotal = 10_040_515_050
    static let timerEvidenceRows = 1
    static let sourceFamilyText = "taskbarhero.org zh/en v1.00.09"
    static let independentSourcesText = "GamesRadar / Games.gg / GameRant / Mobalytics / Steam 指南 / Steam 讨论"
    static let candidateCostSourceText = "tbh.city 单源数据镜像：完整 total_cost_to_max 表覆盖 197/197 节点，自动开箱子集 13 节点合计 383,790,000G；不计入已核对成本或退款"
    static let fullCostTableBoundaryText = "完整可验证 197 节点成本/路径表仍缺"
    static let resetEconomyBoundaryText = "重置价格、退款比例与点数经济仍缺"
    static let runtimeTimerBoundaryText = "本地已接入已核对冷却值；完整成本、路径、重置经济与点数规则仍缺"
    static let candidateCostQueueBoundaryText = "候选成本队列只拆分 tbh.city 单源证据；不按候选金额生成符文价格、路径成本、重置退款或点数经济"
    static let fullCandidateCostBoundaryText = "tbh.city total_cost_to_max 仍是单源候选；没有逐级截图、第二来源、路径成本和重置规则前，不写入运行时扣费、退款或点数经济"
    static let tbhCityCandidateCostSampleText = "#1 100G / #21 1,000G / #24 150,000G / #27 50,000G / #13002 10,000G"

    static let candidateCostQueueRows: [SourceRuneCandidateCostQueueRowModel] = [
        SourceRuneCandidateCostQueueRowModel(
            key: "candidate-10k",
            title: "10k 候选",
            sourceEvidence: "tbh.city 单源：10k",
            affectedCandidateCount: 1,
            candidateGold: 10_000,
            missingEvidence: "缺 Rune ID 逐项绑定、第二来源和游戏内截图",
            boundary: "不把 10k 写入运行时扣费或退款"
        ),
        SourceRuneCandidateCostQueueRowModel(
            key: "candidate-200k",
            title: "200k 候选",
            sourceEvidence: "tbh.city 单源：200k",
            affectedCandidateCount: 1,
            candidateGold: 200_000,
            missingEvidence: "缺 Rune ID 逐项绑定、第二来源和游戏内截图",
            boundary: "不把 200k 写入运行时扣费或退款"
        ),
        SourceRuneCandidateCostQueueRowModel(
            key: "candidate-1m",
            title: "1M 候选",
            sourceEvidence: "tbh.city 单源：1M",
            affectedCandidateCount: 1,
            candidateGold: 1_000_000,
            missingEvidence: "缺 Rune ID 逐项绑定、第二来源和游戏内截图",
            boundary: "不把 1M 写入运行时扣费或退款"
        ),
        SourceRuneCandidateCostQueueRowModel(
            key: "candidate-lubrication-aggregate",
            title: "润滑合计候选",
            sourceEvidence: "tbh.city 单源：润滑合计 382.58M",
            affectedCandidateCount: 10,
            candidateGold: 382_580_000,
            missingEvidence: "缺逐节点截图、逐项 Rune ID 绑定、第二来源和重置规则",
            boundary: "不把润滑合计拆成逐节点价格、路径成本或退款"
        )
    ]

    static let rows: [SourceRuneEvidenceReviewRowModel] = [
        SourceRuneEvidenceReviewRowModel(
            title: "结构",
            evidence: "197 节点 / 195 连线 / Lv3 解锁 / 可重置",
            boundary: "Wiki 中英文页面一致；不证明完整费用、退款或点数经济",
            confidence: "中"
        ),
        SourceRuneEvidenceReviewRowModel(
            title: "编队成本",
            evidence: "第 2 位 50,000G / 第 3 位 150,000G",
            boundary: "Wiki、Games.gg、GameRant、Mobalytics 与 Steam 指南交叉佐证；当前可作为已核对成本",
            confidence: "高"
        ),
        SourceRuneEvidenceReviewRowModel(
            title: "主动技能槽",
            evidence: "第二主动技能槽 50,000G / ~50,000g",
            boundary: "Wiki 使用约值，Games.gg 与 Steam 指南给 50,000G；仍不推导完整技能槽经济",
            confidence: "中"
        ),
        SourceRuneEvidenceReviewRowModel(
            title: "离线奖励",
            evidence: "Repose unlock / Gold +10% / XP +10% / 8h cap",
            boundary: "Wiki 与 GamesRadar 名称和效果一致；节点费用与重复叠加仍缺",
            confidence: "中"
        ),
        SourceRuneEvidenceReviewRowModel(
            title: "自动开箱",
            evidence: "普通箱 300s / 关卡 Boss 箱 600s / Act Boss 箱 60s / 冷却减少 9s、15s、3s",
            boundary: runtimeTimerBoundaryText,
            confidence: "中"
        ),
        SourceRuneEvidenceReviewRowModel(
            title: "自动开箱成本候选",
            evidence: "tbh.city 13 节点：10k / 200k / 1M / 润滑合计 382.58M",
            boundary: "单源数据镜像，仅作为候选成本；不参与本地扣费、退款或已核对成本统计",
            confidence: "低"
        ),
        SourceRuneEvidenceReviewRowModel(
            title: "完整候选成本表",
            evidence: "tbh.city \(tbhCityCandidateCostTableCoverageText) / \(tbhCityCandidateCostTableGoldText) / \(tbhCityCandidateCostSampleText)",
            boundary: fullCandidateCostBoundaryText,
            confidence: "低"
        ),
        SourceRuneEvidenceReviewRowModel(
            title: "末端高价",
            evidence: "1-3M / 5M Gale / 50M stash 示例",
            boundary: "社区指南和讨论只证明存在高价例子，不构成完整可验证成本表",
            confidence: "低"
        ),
        SourceRuneEvidenceReviewRowModel(
            title: "仍缺",
            evidence: "\(LocalRuneCostReviewMetrics.pendingCount) 待核对成本 / 重置价格 / 退款 / 点数经济",
            boundary: "\(fullCostTableBoundaryText)；\(resetEconomyBoundaryText)",
            confidence: "高"
        )
    ]

    static var rowCount: Int {
        rows.count
    }

    static var highConfidenceRows: Int {
        rows.filter { $0.confidence == "高" }.count
    }

    static var unresolvedPendingCostNodes: Int {
        LocalRuneCostReviewMetrics.pendingCount
    }

    static var candidateCostQueueCount: Int {
        candidateCostQueueRows.count
    }

    static var candidateCostQueueCoverageCount: Int {
        candidateCostQueueRows.reduce(0) { $0 + $1.affectedCandidateCount }
    }

    static var candidateCostQueueGoldTotal: Int {
        candidateCostQueueRows.reduce(0) { $0 + $1.candidateGold }
    }

    static var candidateCostQueueGoldText: String {
        "\(candidateCostQueueGoldTotal.formatted())G"
    }

    static var tbhCityCandidateCostTableCoverageText: String {
        "\(tbhCityCandidateCostTableRows)/\(SourceRuneCatalog.expectedNodeCount)"
    }

    static var tbhCityCandidateCostTableGoldText: String {
        "\(tbhCityCandidateCostTableGoldTotal.formatted())G"
    }

    static var sourceScopeText: String {
        "\(wikiLocaleCount) Wiki locale / \(independentSourceCount) external pages / \(singleSourceCandidateMirrorCount) candidate mirror"
    }
}

struct LocalSkillRuntimeCoverageRowModel: Identifiable, Equatable {
    let activation: SkillActivation
    let sourceCount: Int
    let runtimeCount: Int

    var id: String { activation.rawValue }
    var pendingCount: Int { sourceCount - runtimeCount }
}

enum LocalSkillRuntimeCoverageMetrics {
    static let sourceCatalogBoundaryText = "源表完整不等于运行时完整"
    static let pendingRuntimeBoundaryText = "未接入技能不伪造战斗语义"
    static let monsterBoundaryText = "怪物完整技能表/施法帧待核对"

    static var sourceCount: Int {
        SourceSkillCatalog.all.count
    }

    static var runtimeModeledCount: Int {
        SourceSkillCatalog.runtimeModeledSkills.count
    }

    static var pendingCount: Int {
        sourceCount - runtimeModeledCount
    }

    static var heroNamedCount: Int {
        SourceSkillCatalog.runtimeNamedHeroSkillIDs.count
    }

    static var heroBaseAttackCount: Int {
        SourceSkillCatalog.runtimeHeroBaseAttackSkillIDs.count
    }

    static var monsterAttackCount: Int {
        SourceSkillCatalog.runtimeMonsterAttackSkillIDs.count
    }

    static var activationRows: [LocalSkillRuntimeCoverageRowModel] {
        SkillActivation.allCases.map { activation in
            let sourceCount = SourceSkillCatalog.all.filter { $0.activation == activation }.count
            let runtimeCount = SourceSkillCatalog.runtimeModeledSkills.filter { $0.activation == activation }.count
            return LocalSkillRuntimeCoverageRowModel(
                activation: activation,
                sourceCount: sourceCount,
                runtimeCount: runtimeCount
            )
        }
    }

    static var pendingSkillIDs: [String] {
        SourceSkillCatalog.all
            .filter { !SourceSkillCatalog.runtimeModeledSkillIDs.contains($0.id) }
            .map(\.id)
    }

    static var pendingPreviewText: String {
        pendingSkillIDs.prefix(8).joined(separator: ", ")
    }
}

enum PendingSourceSkillCategory: String {
    case activation
    case damage
    case sourcePrefix
    case responsibility
    case range
}

struct PendingSourceSkillCategoryRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let count: Int
    let sampleIDs: [String]
    let category: PendingSourceSkillCategory

    var id: String {
        "\(category.rawValue)-\(key)"
    }

    var sampleText: String {
        sampleIDs.prefix(5).joined(separator: ", ")
    }
}

struct PendingSourceSkillActivationDamageQueueRowModel: Identifiable, Equatable {
    let activation: SkillActivation
    let damageType: String
    let skills: [SourceSkill]

    var id: String {
        "\(activation.rawValue)-\(damageType)"
    }

    var title: String {
        "\(activation.rawValue) / \(damageType)"
    }

    var count: Int {
        skills.count
    }

    var valueCount: Int {
        skills.filter { $0.sourceValue != nil }.count
    }

    var emptyDeliveryCount: Int {
        skills.filter { $0.delivery.isEmpty }.count
    }

    var sampleIDs: [String] {
        skills.map(\.id)
    }

    var sampleText: String {
        sampleIDs.prefix(8).joined(separator: ", ")
    }

    var currentEvidence: String {
        "\(count) 行 / \(valueCount) value / \(emptyDeliveryCount) 空 delivery"
    }

    var nextEvidence: String {
        "补 \(activation.rawValue) \(damageType) 的归属、名称、delivery、目标/公式、动作帧和音效"
    }

    var boundary: String {
        "交叉桶只排列复核顺序；不按 activation、damage 或 value 生成技能效果"
    }
}

struct PendingSourceSkillRangeEvidenceQueueRowModel: Identifiable, Equatable {
    let range: Int
    let skills: [SourceSkill]

    var id: String {
        "range-\(range)"
    }

    var title: String {
        "range \(range)"
    }

    var count: Int {
        skills.count
    }

    var valueCount: Int {
        skills.filter { $0.sourceValue != nil }.count
    }

    var emptyDeliveryCount: Int {
        skills.filter { $0.delivery.isEmpty }.count
    }

    var sampleIDs: [String] {
        skills.map(\.id)
    }

    var sampleText: String {
        sampleIDs.prefix(8).joined(separator: ", ")
    }

    var activationSummaryText: String {
        let activationOrder: [SkillActivation] = [.baseAttack, .baseAttackCount, .cooldown, .continuous]
        return activationOrder.compactMap { activation in
            let count = skills.filter { $0.activation == activation }.count
            return count > 0 ? "\(activation.rawValue) \(count)" : nil
        }
        .joined(separator: " / ")
    }

    var damageSummaryText: String {
        ["Physical", "Fire", "Cold", "Lightning", "Chaos"].compactMap { damageType in
            let count = skills.filter { $0.damageType == damageType }.count
            return count > 0 ? "\(damageType) \(count)" : nil
        }
        .joined(separator: " / ")
    }

    var currentEvidence: String {
        "\(count) 行 / \(valueCount) value / \(emptyDeliveryCount) 空 delivery / \(activationSummaryText) / \(damageSummaryText)"
    }

    var nextEvidence: String {
        "核对该距离档的目标距离、弹道形态、命中半径、动作帧和音效"
    }

    var boundary: String {
        "range 只作为源表字段；不按数值生成射程、AOE、弹道速度或命中范围"
    }
}

struct PendingSourceSkillPrefixEvidenceQueueRowModel: Identifiable, Equatable {
    let prefix: String
    let skills: [SourceSkill]

    var id: String {
        "prefix-\(prefix)"
    }

    var title: String {
        "ID 前缀 \(prefix)"
    }

    var count: Int {
        skills.count
    }

    var valueCount: Int {
        skills.filter { $0.sourceValue != nil }.count
    }

    var emptyDeliveryCount: Int {
        skills.filter { $0.delivery.isEmpty }.count
    }

    var sampleIDs: [String] {
        skills.map(\.id)
    }

    var sampleText: String {
        sampleIDs.prefix(8).joined(separator: ", ")
    }

    var activationSummaryText: String {
        let activationOrder: [SkillActivation] = [.baseAttack, .baseAttackCount, .cooldown, .continuous]
        return activationOrder.compactMap { activation in
            let count = skills.filter { $0.activation == activation }.count
            return count > 0 ? "\(activation.rawValue) \(count)" : nil
        }
        .joined(separator: " / ")
    }

    var damageSummaryText: String {
        ["Physical", "Fire", "Cold", "Lightning", "Chaos"].compactMap { damageType in
            let count = skills.filter { $0.damageType == damageType }.count
            return count > 0 ? "\(damageType) \(count)" : nil
        }
        .joined(separator: " / ")
    }

    var currentEvidence: String {
        "\(count) 行 / \(valueCount) value / \(emptyDeliveryCount) 空 delivery / \(activationSummaryText) / \(damageSummaryText)"
    }

    var nextEvidence: String {
        "核对前缀 \(prefix) 的本地化名称、英雄/怪物归属、delivery、公式、动作帧和音效"
    }

    var boundary: String {
        "ID 前缀只作为源表命名空间；不按前缀推断职业、怪物、关卡、技能归属、公式、弹道、动作帧或音效"
    }
}

struct PendingSourceSkillValueEvidenceQueueRowModel: Identifiable, Equatable {
    let sourceValue: Int
    let skills: [SourceSkill]

    var id: String {
        "value-\(sourceValue)"
    }

    var title: String {
        "value \(sourceValue)"
    }

    var count: Int {
        skills.count
    }

    var emptyDeliveryCount: Int {
        skills.filter { $0.delivery.isEmpty }.count
    }

    var sampleIDs: [String] {
        skills.map(\.id)
    }

    var sampleText: String {
        sampleIDs.prefix(8).joined(separator: ", ")
    }

    var rangeSummaryText: String {
        let ranges = Set(skills.map(\.range)).sorted()
        return ranges.compactMap { range in
            let count = skills.filter { $0.range == range }.count
            return count > 0 ? "r\(range) \(count)" : nil
        }
        .joined(separator: " / ")
    }

    var activationSummaryText: String {
        let activationOrder: [SkillActivation] = [.baseAttack, .baseAttackCount, .cooldown, .continuous]
        return activationOrder.compactMap { activation in
            let count = skills.filter { $0.activation == activation }.count
            return count > 0 ? "\(activation.rawValue) \(count)" : nil
        }
        .joined(separator: " / ")
    }

    var damageSummaryText: String {
        ["Physical", "Fire", "Cold", "Lightning", "Chaos"].compactMap { damageType in
            let count = skills.filter { $0.damageType == damageType }.count
            return count > 0 ? "\(damageType) \(count)" : nil
        }
        .joined(separator: " / ")
    }

    var currentEvidence: String {
        "\(count) 行 / \(emptyDeliveryCount) 空 delivery / \(rangeSummaryText) / \(activationSummaryText) / \(damageSummaryText)"
    }

    var nextEvidence: String {
        "核对 value \(sourceValue) 的等级表、倍率公式、目标规则、持续时间、delivery、动作帧和音效"
    }

    var boundary: String {
        "value 只作为单技能页数值字段；不按 value 推断倍率公式、伤害、目标、持续时间、弹道、动作帧或音效"
    }
}

struct PendingSourceSkillVisualPriorityRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let skills: [SourceSkill]
    let currentEvidence: String
    let nextEvidence: String
    let boundary: String

    var id: String { key }

    var count: Int {
        skills.count
    }

    var valueCount: Int {
        skills.filter { $0.sourceValue != nil }.count
    }

    var emptyDeliveryCount: Int {
        skills.filter { $0.delivery.isEmpty }.count
    }

    var sampleIDs: [String] {
        skills.map(\.id)
    }

    var sampleText: String {
        sampleIDs.isEmpty ? "无" : sampleIDs.prefix(8).joined(separator: ", ")
    }
}

struct PendingSourceSkillReadinessRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let count: Int
    let sampleIDs: [String]
    let missingEvidence: String

    var id: String { key }

    var sampleText: String {
        sampleIDs.isEmpty ? "无" : sampleIDs.prefix(6).joined(separator: ", ")
    }
}

struct PendingSourceSkillRuntimeProofRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let provedCount: Int
    let missingCount: Int
    let currentEvidence: String
    let missingEvidence: String
    let boundary: String

    var id: String { key }

    var statusText: String {
        "\(provedCount) 已证 / \(missingCount) 缺证"
    }
}

struct PendingSourceSkillValueEvidenceRowModel: Identifiable, Equatable {
    let skill: SourceSkill

    var id: String { skill.id }

    var title: String {
        "\(skill.id) · \(skill.activation.rawValue)"
    }

    var detailPath: String {
        "/zh/skills/active/id-\(skill.id)/"
    }

    var currentEvidence: String {
        "\(skill.damageType) · range \(skill.range) · value \(skill.sourceValueText) · delivery \(skill.delivery.isEmpty ? "空" : skill.delivery)"
    }

    var missingEvidence: String {
        "缺本地化名称、说明、施放者/目标、delivery 命中形态、公式/持续时间、动作帧和音效"
    }

    var boundary: String {
        "不以单页 value/range 生成技能效果、倍率公式、弹道、动作帧或音效"
    }
}

struct PendingSourceSkillCooldownChaosPageEvidenceRowModel: Identifiable, Equatable {
    let skill: SourceSkill

    var id: String { skill.id }

    var title: String {
        "\(skill.id) · COOLDOWN Chaos"
    }

    var localePathText: String {
        "zh:/zh/skills/active/id-\(skill.id)/ · en:/en/skills/active/id-\(skill.id)/"
    }

    var currentEvidence: String {
        "value \(skill.sourceValueText) · range \(skill.range) · Skill ID · delivery — · Lv —"
    }

    var missingEvidence: String {
        "缺本地化名称/说明、delivery 命中形态、施放者/目标、公式/持续时间、动作帧和原版 SFX"
    }

    var boundary: String {
        "不以 COOLDOWN、Chaos、value 或 range 生成运行时技能、混沌特效、目标规则、持续伤害、动作帧或音效"
    }
}

struct PendingSourceSkillBaseAttackEvidenceRowModel: Identifiable, Equatable {
    let skill: SourceSkill

    var id: String { skill.id }

    var title: String {
        "\(skill.id) · \(skill.damageType) BASEATTACK"
    }

    var currentEvidence: String {
        "\(skill.activation.rawValue) · \(skill.damageType) · range \(skill.range) · value \(skill.sourceValueText) · delivery \(skill.delivery.isEmpty ? "空" : skill.delivery)"
    }

    var catalogState: String {
        "\(skill.name) · 目录行 · 单技能 value/range 未核对"
    }

    var missingEvidence: String {
        "缺本地化名称/说明、英雄或怪物归属、目标规则、命中形态、公式、动作帧和音效"
    }

    var boundary: String {
        "不以 damage、range 或 ID 段生成基础攻击、怪物招式、元素状态、弹道、动作帧或音效"
    }
}

struct PendingSourceSkillUnmappedMonsterCandidateRowModel: Identifiable, Equatable {
    let monsterRow: SourceMonsterUnmappedEvidenceQueueRowModel
    let skill: SourceSkill

    var id: String {
        "\(monsterRow.monster.id)-\(skill.id)"
    }

    var title: String {
        "\(skill.id) · \(monsterRow.monster.zhName)"
    }

    var currentEvidence: String {
        "\(monsterRow.title) · \(skill.damageType) \(skill.activation.rawValue) r\(skill.range) · value \(skill.sourceValueText) · delivery \(skill.delivery.isEmpty ? "空" : skill.delivery)"
    }

    var stageEvidence: String {
        monsterRow.bestFarmStageCompositionEvidence
    }

    var missingEvidence: String {
        "缺关卡出场证明、怪物技能归属、命中形态、倍率公式、动作帧和音效"
    }

    var boundary: String {
        "同前缀只作为未映射怪物复核入口；不证明怪物技能归属、出场、delivery、公式、动作帧或音效"
    }
}

struct PendingSourceSkillRuntimeGateRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let currentEvidence: String
    let missingEvidence: String
    let requiredProof: String
    let affectedSkillCount: Int

    var id: String { key }
}

struct PendingSourceSkillEvidenceQueueRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let count: Int
    let sampleIDs: [String]
    let currentEvidence: String
    let nextEvidence: String
    let boundary: String

    var id: String { key }

    var sampleText: String {
        sampleIDs.isEmpty ? "无" : sampleIDs.prefix(8).joined(separator: ", ")
    }
}

struct SourceSkillDeliveryRowModel: Identifiable, Equatable {
    let delivery: String
    let sourceCount: Int
    let runtimeCount: Int
    let sampleIDs: [String]

    var id: String {
        delivery.isEmpty ? "empty-delivery" : delivery
    }

    var title: String {
        delivery.isEmpty ? "空 delivery" : delivery
    }

    var pendingCount: Int {
        sourceCount - runtimeCount
    }

    var sampleText: String {
        sampleIDs.prefix(5).joined(separator: ", ")
    }
}

struct SourceSkillDamageRowModel: Identifiable, Equatable {
    let damageType: String
    let sourceCount: Int
    let runtimeCount: Int
    let sampleIDs: [String]

    var id: String {
        damageType
    }

    var pendingCount: Int {
        sourceCount - runtimeCount
    }

    var sampleText: String {
        sampleIDs.prefix(5).joined(separator: ", ")
    }
}

struct SourceSkillRangeRowModel: Identifiable, Equatable {
    let range: Int
    let sourceCount: Int
    let runtimeCount: Int
    let sampleIDs: [String]

    var id: String {
        "range-\(range)"
    }

    var title: String {
        "range \(range)"
    }

    var pendingCount: Int {
        sourceCount - runtimeCount
    }

    var sampleText: String {
        sampleIDs.prefix(5).joined(separator: ", ")
    }
}

struct SourceSkillActivationDamageCellModel: Identifiable, Equatable {
    let damageType: String
    let sourceCount: Int
    let runtimeCount: Int

    var id: String {
        damageType
    }

    var pendingCount: Int {
        sourceCount - runtimeCount
    }

    var compactText: String {
        "\(damageType) \(runtimeCount)/\(sourceCount)"
    }
}

struct SourceSkillActivationDamageRowModel: Identifiable, Equatable {
    let activation: SkillActivation
    let sourceCount: Int
    let runtimeCount: Int
    let damageCells: [SourceSkillActivationDamageCellModel]
    let sampleIDs: [String]

    var id: String {
        activation.rawValue
    }

    var pendingCount: Int {
        sourceCount - runtimeCount
    }

    var damageSummaryText: String {
        damageCells.map(\.compactText).joined(separator: " · ")
    }

    var sampleText: String {
        sampleIDs.prefix(5).joined(separator: ", ")
    }
}

struct SourceSkillActivationDeliveryRowModel: Identifiable, Equatable {
    let activation: SkillActivation
    let sourceCount: Int
    let runtimeCount: Int
    let deliveryCells: [SourceSkillDamageDeliveryCellModel]
    let sampleIDs: [String]

    var id: String {
        activation.rawValue
    }

    var pendingCount: Int {
        sourceCount - runtimeCount
    }

    var deliverySummaryText: String {
        deliveryCells.map(\.compactText).joined(separator: " · ")
    }

    var sampleText: String {
        sampleIDs.prefix(5).joined(separator: ", ")
    }
}

struct SourceSkillDamageDeliveryCellModel: Identifiable, Equatable {
    let delivery: String
    let sourceCount: Int
    let runtimeCount: Int

    var id: String {
        delivery.isEmpty ? "empty-delivery" : delivery
    }

    var title: String {
        delivery.isEmpty ? "空 delivery" : delivery
    }

    var pendingCount: Int {
        sourceCount - runtimeCount
    }

    var compactText: String {
        "\(title) \(runtimeCount)/\(sourceCount)"
    }
}

struct SourceSkillDamageDeliveryRowModel: Identifiable, Equatable {
    let damageType: String
    let sourceCount: Int
    let runtimeCount: Int
    let deliveryCells: [SourceSkillDamageDeliveryCellModel]
    let sampleIDs: [String]

    var id: String {
        damageType
    }

    var pendingCount: Int {
        sourceCount - runtimeCount
    }

    var deliverySummaryText: String {
        deliveryCells.map(\.compactText).joined(separator: " · ")
    }

    var sampleText: String {
        sampleIDs.prefix(5).joined(separator: ", ")
    }
}

enum SourceSkillDamageReviewMetrics {
    static let damageBoundaryText = "damage 仅作源表伤害类型字段，不代表抗性/异常状态完整"
    static let visualBoundaryText = "元素类型不等于原版 VFX/SFX 或命中特效已还原"
    static let runtimeBoundaryText = "已接入只表示运行时引用该源行，不代表原版元素规则完整"

    static var rows: [SourceSkillDamageRowModel] {
        let preferredOrder = ["Physical", "Fire", "Cold", "Lightning", "Chaos"]
        let runtimeIDs = SourceSkillCatalog.runtimeModeledSkillIDs
        return preferredOrder.compactMap { damageType in
            let skills = SourceSkillCatalog.all.filter { $0.damageType == damageType }
            guard !skills.isEmpty else { return nil }
            return SourceSkillDamageRowModel(
                damageType: damageType,
                sourceCount: skills.count,
                runtimeCount: skills.filter { runtimeIDs.contains($0.id) }.count,
                sampleIDs: skills.map(\.id)
            )
        }
    }

    static var sourceCount: Int {
        SourceSkillCatalog.all.count
    }

    static var damageBucketCount: Int {
        rows.count
    }

    static var runtimeMappedCount: Int {
        rows.map(\.runtimeCount).reduce(0, +)
    }

    static var physicalCount: Int {
        rows.first { $0.damageType == "Physical" }?.sourceCount ?? 0
    }

    static var nonPhysicalRuntimeCount: Int {
        rows
            .filter { $0.damageType != "Physical" }
            .map(\.runtimeCount)
            .reduce(0, +)
    }

    static var chaosRuntimeCount: Int {
        rows.first { $0.damageType == "Chaos" }?.runtimeCount ?? 0
    }

    static var mostCommonDamageText: String {
        guard let row = rows.max(by: { lhs, rhs in
            if lhs.sourceCount == rhs.sourceCount {
                return lhs.damageType > rhs.damageType
            }
            return lhs.sourceCount < rhs.sourceCount
        }) else {
            return "无"
        }
        return "\(row.damageType) x\(row.sourceCount)"
    }
}

enum SourceSkillActivationDamageReviewMetrics {
    static let activationBoundaryText = "activation 仅作源表触发字段，不等于完整施法/攻击时序"
    static let crossTabBoundaryText = "交叉分布只展示源字段组合，不推导技能归属/触发频率"
    static let runtimeBoundaryText = "已接入只表示本地引用该源行，不代表原版运行时语义完整"

    static var rows: [SourceSkillActivationDamageRowModel] {
        let activationOrder: [SkillActivation] = [.baseAttack, .baseAttackCount, .cooldown, .continuous]
        let damageOrder = ["Physical", "Fire", "Cold", "Lightning", "Chaos"]
        let runtimeIDs = SourceSkillCatalog.runtimeModeledSkillIDs

        return activationOrder.compactMap { activation -> SourceSkillActivationDamageRowModel? in
            let skills = SourceSkillCatalog.all.filter { $0.activation == activation }
            guard !skills.isEmpty else { return nil }
            let runtimeSkills = skills.filter { runtimeIDs.contains($0.id) }
            let cells = damageOrder.compactMap { damageType -> SourceSkillActivationDamageCellModel? in
                let damageSkills = skills.filter { $0.damageType == damageType }
                guard !damageSkills.isEmpty else { return nil }
                return SourceSkillActivationDamageCellModel(
                    damageType: damageType,
                    sourceCount: damageSkills.count,
                    runtimeCount: damageSkills.filter { runtimeIDs.contains($0.id) }.count
                )
            }

            return SourceSkillActivationDamageRowModel(
                activation: activation,
                sourceCount: skills.count,
                runtimeCount: runtimeSkills.count,
                damageCells: cells,
                sampleIDs: skills.map(\.id)
            )
        }
    }

    static var sourceCount: Int {
        SourceSkillCatalog.all.count
    }

    static var runtimeMappedCount: Int {
        rows.map(\.runtimeCount).reduce(0, +)
    }

    static var pairCount: Int {
        rows.map(\.damageCells.count).reduce(0, +)
    }

    static var runtimePairCount: Int {
        rows
            .flatMap(\.damageCells)
            .filter { $0.runtimeCount > 0 }
            .count
    }

    static var baseAttackRuntimeText: String {
        guard let row = rows.first(where: { $0.activation == .baseAttack }) else { return "0/0" }
        return "\(row.runtimeCount)/\(row.sourceCount)"
    }

    static var cooldownChaosRuntimeCount: Int {
        rows
            .first { $0.activation == .cooldown }?
            .damageCells
            .first { $0.damageType == "Chaos" }?
            .runtimeCount ?? 0
    }

    static var cooldownChaosPendingSkills: [SourceSkill] {
        let runtimeIDs = SourceSkillCatalog.runtimeModeledSkillIDs
        return SourceSkillCatalog.all
            .filter {
                $0.activation == .cooldown &&
                    $0.damageType == "Chaos" &&
                    !runtimeIDs.contains($0.id)
            }
            .sorted { $0.id < $1.id }
    }

    static var cooldownChaosPendingIDs: [String] {
        cooldownChaosPendingSkills.map(\.id)
    }

    static var cooldownChaosPendingIDText: String {
        cooldownChaosPendingIDs.joined(separator: ", ")
    }

    static var largestPendingPairText: String {
        let pairs = rows.flatMap { row in
            row.damageCells.map { cell in
                (activation: row.activation.rawValue, damageType: cell.damageType, pendingCount: cell.pendingCount)
            }
        }
        guard let pair = pairs.max(by: { lhs, rhs in
            if lhs.pendingCount == rhs.pendingCount {
                return "\(lhs.activation)-\(lhs.damageType)" > "\(rhs.activation)-\(rhs.damageType)"
            }
            return lhs.pendingCount < rhs.pendingCount
        }) else {
            return "无"
        }
        return "\(pair.activation)/\(pair.damageType) \(pair.pendingCount)"
    }
}

enum SourceSkillActivationDeliveryReviewMetrics {
    static let crossTabBoundaryText = "activation/delivery 仅作源表字段组合，不等于完整触发时序或表现形态"
    static let emptyDeliveryBoundaryText = "空 delivery 不推导无弹道/无范围；attack-count 空形态保持待核对"
    static let runtimeBoundaryText = "已接组合只表示本地引用该源行，不代表原版施法帧/动画完整"

    static var rows: [SourceSkillActivationDeliveryRowModel] {
        let activationOrder: [SkillActivation] = [.baseAttack, .baseAttackCount, .cooldown, .continuous]
        let deliveryOrder = [
            "",
            "AOE",
            "Melee",
            "Melee, AOE",
            "Projectile",
            "Projectile, AOE",
            "Projectile, Summon",
            "Trap"
        ]
        let runtimeIDs = SourceSkillCatalog.runtimeModeledSkillIDs

        return activationOrder.compactMap { activation -> SourceSkillActivationDeliveryRowModel? in
            let skills = SourceSkillCatalog.all.filter { $0.activation == activation }
            guard !skills.isEmpty else { return nil }
            let runtimeSkills = skills.filter { runtimeIDs.contains($0.id) }
            let cells = deliveryOrder.compactMap { delivery -> SourceSkillDamageDeliveryCellModel? in
                let deliverySkills = skills.filter { $0.delivery == delivery }
                guard !deliverySkills.isEmpty else { return nil }
                return SourceSkillDamageDeliveryCellModel(
                    delivery: delivery,
                    sourceCount: deliverySkills.count,
                    runtimeCount: deliverySkills.filter { runtimeIDs.contains($0.id) }.count
                )
            }

            return SourceSkillActivationDeliveryRowModel(
                activation: activation,
                sourceCount: skills.count,
                runtimeCount: runtimeSkills.count,
                deliveryCells: cells,
                sampleIDs: skills.map(\.id)
            )
        }
    }

    static var sourceCount: Int {
        SourceSkillCatalog.all.count
    }

    static var runtimeMappedCount: Int {
        rows.map(\.runtimeCount).reduce(0, +)
    }

    static var pairCount: Int {
        rows.map(\.deliveryCells.count).reduce(0, +)
    }

    static var runtimePairCount: Int {
        rows
            .flatMap(\.deliveryCells)
            .filter { $0.runtimeCount > 0 }
            .count
    }

    static var emptyDeliveryRuntimeText: String {
        let cells = rows.flatMap(\.deliveryCells).filter { $0.delivery.isEmpty }
        let sourceCount = cells.map(\.sourceCount).reduce(0, +)
        let runtimeCount = cells.map(\.runtimeCount).reduce(0, +)
        return "\(runtimeCount)/\(sourceCount)"
    }

    static var baseAttackEmptyRuntimeText: String {
        guard let cell = rows
            .first(where: { $0.activation == .baseAttack })?
            .deliveryCells
            .first(where: { $0.delivery.isEmpty }) else {
            return "0/0"
        }
        return "\(cell.runtimeCount)/\(cell.sourceCount)"
    }

    static var baseAttackCountEmptyRuntimeText: String {
        guard let cell = rows
            .first(where: { $0.activation == .baseAttackCount })?
            .deliveryCells
            .first(where: { $0.delivery.isEmpty }) else {
            return "0/0"
        }
        return "\(cell.runtimeCount)/\(cell.sourceCount)"
    }

    static var largestPendingPairText: String {
        let pairs = rows.flatMap { row in
            row.deliveryCells.map { cell in
                (activation: row.activation.rawValue, deliveryTitle: cell.title, pendingCount: cell.pendingCount)
            }
        }
        guard let pair = pairs.max(by: { lhs, rhs in
            if lhs.pendingCount == rhs.pendingCount {
                return "\(lhs.activation)-\(lhs.deliveryTitle)" > "\(rhs.activation)-\(rhs.deliveryTitle)"
            }
            return lhs.pendingCount < rhs.pendingCount
        }) else {
            return "无"
        }
        return "\(pair.activation)/\(pair.deliveryTitle) \(pair.pendingCount)"
    }
}

enum SourceSkillDamageDeliveryReviewMetrics {
    static let crossTabBoundaryText = "damage/delivery 仅作源表字段组合，不等于原版特效已还原"
    static let emptyDeliveryBoundaryText = "空 delivery 仍保留为待核对形态，不推导无弹道/无范围"
    static let runtimeBoundaryText = "已接组合只表示本地引用该源行，不代表命中几何/动画完整"

    static var rows: [SourceSkillDamageDeliveryRowModel] {
        let damageOrder = ["Physical", "Fire", "Cold", "Lightning", "Chaos"]
        let deliveryOrder = [
            "",
            "AOE",
            "Melee",
            "Melee, AOE",
            "Projectile",
            "Projectile, AOE",
            "Projectile, Summon",
            "Trap"
        ]
        let runtimeIDs = SourceSkillCatalog.runtimeModeledSkillIDs

        return damageOrder.compactMap { damageType -> SourceSkillDamageDeliveryRowModel? in
            let skills = SourceSkillCatalog.all.filter { $0.damageType == damageType }
            guard !skills.isEmpty else { return nil }
            let runtimeSkills = skills.filter { runtimeIDs.contains($0.id) }
            let cells = deliveryOrder.compactMap { delivery -> SourceSkillDamageDeliveryCellModel? in
                let deliverySkills = skills.filter { $0.delivery == delivery }
                guard !deliverySkills.isEmpty else { return nil }
                return SourceSkillDamageDeliveryCellModel(
                    delivery: delivery,
                    sourceCount: deliverySkills.count,
                    runtimeCount: deliverySkills.filter { runtimeIDs.contains($0.id) }.count
                )
            }

            return SourceSkillDamageDeliveryRowModel(
                damageType: damageType,
                sourceCount: skills.count,
                runtimeCount: runtimeSkills.count,
                deliveryCells: cells,
                sampleIDs: skills.map(\.id)
            )
        }
    }

    static var sourceCount: Int {
        SourceSkillCatalog.all.count
    }

    static var runtimeMappedCount: Int {
        rows.map(\.runtimeCount).reduce(0, +)
    }

    static var pairCount: Int {
        rows.map(\.deliveryCells.count).reduce(0, +)
    }

    static var runtimePairCount: Int {
        rows
            .flatMap(\.deliveryCells)
            .filter { $0.runtimeCount > 0 }
            .count
    }

    static var emptyDeliveryRuntimeText: String {
        let cells = rows.flatMap(\.deliveryCells).filter { $0.delivery.isEmpty }
        let sourceCount = cells.map(\.sourceCount).reduce(0, +)
        let runtimeCount = cells.map(\.runtimeCount).reduce(0, +)
        return "\(runtimeCount)/\(sourceCount)"
    }

    static var physicalEmptyRuntimeText: String {
        guard let cell = rows
            .first(where: { $0.damageType == "Physical" })?
            .deliveryCells
            .first(where: { $0.delivery.isEmpty }) else {
            return "0/0"
        }
        return "\(cell.runtimeCount)/\(cell.sourceCount)"
    }

    static var largestPendingPairText: String {
        let pairs = rows.flatMap { row in
            row.deliveryCells.map { cell in
                (damageType: row.damageType, deliveryTitle: cell.title, pendingCount: cell.pendingCount)
            }
        }
        guard let pair = pairs.max(by: { lhs, rhs in
            if lhs.pendingCount == rhs.pendingCount {
                return "\(lhs.damageType)-\(lhs.deliveryTitle)" > "\(rhs.damageType)-\(rhs.deliveryTitle)"
            }
            return lhs.pendingCount < rhs.pendingCount
        }) else {
            return "无"
        }
        return "\(pair.damageType)/\(pair.deliveryTitle) \(pair.pendingCount)"
    }
}

enum SourceSkillDeliveryReviewMetrics {
    static let deliveryBoundaryText = "delivery 仅作源表形态字段，不推导投射物/范围几何/施法帧"
    static let emptyDeliveryBoundaryText = "空 delivery 不等于无技能效果；未核对前不伪造形态"
    static let runtimeBoundaryText = "已接入仅表示本地有运行时映射，不代表原版几何/动画完整"

    static var rows: [SourceSkillDeliveryRowModel] {
        let preferredOrder = [
            "",
            "AOE",
            "Projectile",
            "Melee",
            "Melee, AOE",
            "Projectile, AOE",
            "Projectile, Summon",
            "Trap"
        ]
        let runtimeIDs = SourceSkillCatalog.runtimeModeledSkillIDs
        return preferredOrder.compactMap { delivery in
            let skills = SourceSkillCatalog.all.filter { $0.delivery == delivery }
            guard !skills.isEmpty else { return nil }
            let runtimeCount = skills.filter { runtimeIDs.contains($0.id) }.count
            return SourceSkillDeliveryRowModel(
                delivery: delivery,
                sourceCount: skills.count,
                runtimeCount: runtimeCount,
                sampleIDs: skills.map(\.id)
            )
        }
    }

    static var deliveryBucketCount: Int {
        rows.count
    }

    static var emptyDeliveryCount: Int {
        rows.first { $0.delivery.isEmpty }?.sourceCount ?? 0
    }

    static var nonEmptyDeliveryCount: Int {
        SourceSkillCatalog.all.filter { !$0.delivery.isEmpty }.count
    }

    static var nonEmptyRuntimeCount: Int {
        rows
            .filter { !$0.delivery.isEmpty }
            .map(\.runtimeCount)
            .reduce(0, +)
    }

    static var mostCommonDeliveryText: String {
        guard let row = rows.max(by: { lhs, rhs in
            if lhs.sourceCount == rhs.sourceCount {
                return lhs.title > rhs.title
            }
            return lhs.sourceCount < rhs.sourceCount
        }) else {
            return "无"
        }
        return "\(row.title) x\(row.sourceCount)"
    }
}

enum SourceSkillRangeReviewMetrics {
    static let rangeBoundaryText = "range 仅作源表距离字段，不推导命中范围/弹道/移动速度"
    static let runtimeBoundaryText = "已接入只表示运行时引用该源行，不代表原版射程几何完整"
    static let scaleBoundaryText = "最小/最大 range 只作数据边界，不当作屏幕像素比例"

    static var rows: [SourceSkillRangeRowModel] {
        let ranges = Set(SourceSkillCatalog.all.map(\.range)).sorted()
        let runtimeIDs = SourceSkillCatalog.runtimeModeledSkillIDs
        return ranges.map { range in
            let skills = SourceSkillCatalog.all.filter { $0.range == range }
            return SourceSkillRangeRowModel(
                range: range,
                sourceCount: skills.count,
                runtimeCount: skills.filter { runtimeIDs.contains($0.id) }.count,
                sampleIDs: skills.map(\.id)
            )
        }
    }

    static var sourceCount: Int {
        SourceSkillCatalog.all.count
    }

    static var rangeBucketCount: Int {
        rows.count
    }

    static var runtimeMappedCount: Int {
        rows.map(\.runtimeCount).reduce(0, +)
    }

    static var minimumRange: Int {
        rows.first?.range ?? 0
    }

    static var maximumRange: Int {
        rows.last?.range ?? 0
    }

    static var minMaxRangeText: String {
        "\(minimumRange)-\(maximumRange)"
    }

    static var mostCommonRangeText: String {
        guard let row = rows.max(by: { lhs, rhs in
            if lhs.sourceCount == rhs.sourceCount {
                return lhs.range > rhs.range
            }
            return lhs.sourceCount < rhs.sourceCount
        }) else {
            return "无"
        }
        return "\(row.range) x\(row.sourceCount)"
    }
}

enum PendingSourceSkillReviewMetrics {
    static let noRuntimeSemanticsBoundaryText = "待接入源技能不生成战斗效果"
    static let emptyDeliveryBoundaryText = "来源 delivery 为空时不伪造弹道/范围"
    static let monsterOwnershipBoundaryText = "怪物归属/施法帧待核对"
    static let sixDigitUnnamedBoundaryText = "六位未命名源技能先按数据态候选展示"
    static let checkedMonsterAttackBoundaryText = "仅四条地狱祭司攻击已接入运行时"
    static let triggeredPendingBoundaryText = "触发/冷却候选不伪造怪物技能语义"
    static let rangeBoundaryText = "range 仅作源表距离字段，不推导命中范围/弹道"
    static let triggeredValueBoundaryText = "触发/冷却 value 来自单技能页，仍不推导倍率公式/目标/持续时间"
    static let cooldownChaosValueBoundaryText = "Chaos 冷却 value 来自单技能页，仍不推导公式/目标/持续时间"
    static let sourceValueReadinessBoundaryText = "有 value 的候选仍需核对本地化名称、归属、delivery 和描述后才可接入 runtime"
    static let valueDetailBoundaryText = "value 详情页只证明数值/范围，不证明名称、归属、形态或公式"
    static let highestValueDetailBoundaryText = "最高 value 详情页当前仍为 Skill ID、无本地化说明且 delivery 为空"
    static let readinessBoundaryText = "成熟度分组互斥统计；最小证据候选仍需核对公式、目标、动作帧、音效和运行触发后才可接入"
    static let runtimeGateBoundaryText = "接入门槛只定义缺失证据，不生成技能效果、公式、弹道、动作帧或音效"
    static let evidenceQueueBoundaryText = "接入队列为互斥复核顺序；不按 value、damage 或 ID 段推断技能归属、倍率、弹道、动作帧或音效"
    static let unmappedMonsterCandidateBoundaryText = "未映射怪物同前缀候选是交叉复核索引，不改变互斥接入队列；不证明怪物出场、技能归属、delivery、公式、动作帧或音效"
    static let rangeEvidenceQueueBoundaryText = "range 队列只排列距离档复核顺序；不按 range 数值生成技能射程、AOE、弹道、动作帧或音效"
    static let prefixEvidenceQueueBoundaryText = "ID 前缀队列只排列源表命名空间复核顺序；不按前缀生成职业、怪物、关卡、技能归属、公式、弹道、动作帧或音效"
    static let valueEvidenceQueueBoundaryText = "value 队列只排列单技能页数值复核顺序；不按 value 生成倍率公式、伤害、目标、持续时间、弹道、动作帧或音效"
    static let visualPriorityBoundaryText = "视觉复核优先队列可重叠，只聚合需要先找原版画面/动作帧/SFX 的候选；不按元素、value、ID 前缀或未映射怪物关系生成素材、特效、公式、弹道或音效"
    static let visualReviewTotalCoverageBoundaryText = "视觉复核总覆盖由优先队列唯一项加低优先 backlog 差集组成；只保证每个 pending 源技能进入找图/找帧/SFX 复核路线，不按覆盖状态生成技能效果、素材、弹道、动作帧或音效"
    static let visualPriorityUnqueuedBoundaryText = "未入视觉优先队列是当前视觉复核差集，只暴露剩余待找原版画面/动作帧/SFX 的 Physical 源行；不按未入队状态、Physical damage、value 或 range 生成技能效果、素材、弹道、动作帧或音效"
    static let runtimeProofMatrixBoundaryText = "runtime 证明矩阵只拆分已证字段与缺证门槛；source catalog、value/range、activation 或 ID 前缀不生成技能归属、公式、delivery、目标规则、动作帧、VFX 或 SFX"
    static let sourcePageSnapshotVersion = "v1.00.13"
    static let reviewedSourcePageLocales = ["zh", "en"]
    static let sourcePageSnapshotBoundaryText = "中英页同属 taskbarhero.org \(sourcePageSnapshotVersion) 快照；只能证明当前页面缺字段一致，不是第二独立来源或 runtime 许可"

    static var pendingSkills: [SourceSkill] {
        SourceSkillCatalog.all.filter { !SourceSkillCatalog.runtimeModeledSkillIDs.contains($0.id) }
    }

    static var pendingSkillIDs: Set<String> {
        Set(pendingSkills.map(\.id))
    }

    static var pendingCount: Int {
        pendingSkills.count
    }

    static var emptyDeliveryCount: Int {
        pendingSkills.filter { $0.delivery.isEmpty }.count
    }

    static var pendingPreviewText: String {
        pendingSkills.prefix(8).map(\.id).joined(separator: ", ")
    }

    static var catalogOnlyPendingSkills: [SourceSkill] {
        pendingSkills.filter { $0.sourceValue == nil }
    }

    static var valueRangeOnlyPendingSkills: [SourceSkill] {
        pendingSkills.filter {
            $0.sourceValue != nil &&
                !hasMinimumRuntimeEvidence($0)
        }
    }

    static var minimumEvidencePendingSkills: [SourceSkill] {
        pendingSkills.filter(hasMinimumRuntimeEvidence)
    }

    static var readinessRows: [PendingSourceSkillReadinessRowModel] {
        [
            PendingSourceSkillReadinessRowModel(
                key: "catalogOnly",
                title: "目录级元数据",
                count: catalogOnlyPendingSkills.count,
                sampleIDs: catalogOnlyPendingSkills.map(\.id),
                missingEvidence: "缺单技能 value/range 详情、名称、delivery、说明和运行归属"
            ),
            PendingSourceSkillReadinessRowModel(
                key: "valueRangeOnly",
                title: "value/range 详情",
                count: valueRangeOnlyPendingSkills.count,
                sampleIDs: valueRangeOnlyPendingSkills.sorted { $0.id < $1.id }.map(\.id),
                missingEvidence: "已有 value/range，但仍缺本地化名称、delivery、说明、目标/公式和动作帧"
            ),
            PendingSourceSkillReadinessRowModel(
                key: "minimumEvidence",
                title: "最小证据候选",
                count: minimumEvidencePendingSkills.count,
                sampleIDs: minimumEvidencePendingSkills.map(\.id),
                missingEvidence: "当前为 0；即便出现也仍需逐技能验证运行语义"
            )
        ]
    }

    static var runtimeProofRows: [PendingSourceSkillRuntimeProofRowModel] {
        [
            PendingSourceSkillRuntimeProofRowModel(
                key: "source-catalog",
                title: "源表目录行",
                provedCount: pendingCount,
                missingCount: 0,
                currentEvidence: "\(pendingCount)/\(pendingCount) 待接入源行在 SourceSkillCatalog",
                missingEvidence: "无目录缺口；仍只是数据态候选",
                boundary: "目录行不等于本地化名称、归属、delivery、公式、动作帧或音效"
            ),
            PendingSourceSkillRuntimeProofRowModel(
                key: "value-range-detail",
                title: "value/range 详情",
                provedCount: pendingValuedCandidateCount,
                missingCount: catalogOnlyPendingCount,
                currentEvidence: "\(pendingValuedCandidateCount) 页有 sourceValue/range；\(catalogOnlyPendingCount) 行仍仅目录级",
                missingEvidence: "目录级行缺单技能 value/range 详情；value/range 行仍缺运行语义",
                boundary: "value/range 只证明页面字段，不证明倍率公式、目标规则、命中形态或持续时间"
            ),
            PendingSourceSkillRuntimeProofRowModel(
                key: "localized-identity",
                title: "本地化名称/说明",
                provedCount: pendingCount - sixDigitUnnamedPendingSkills.count,
                missingCount: sixDigitUnnamedPendingSkills.count,
                currentEvidence: "\(sixDigitUnnamedPendingSkills.count)/\(pendingCount) 仍显示 Skill ID",
                missingEvidence: "缺中文名、英文名和说明文本",
                boundary: "无名称/说明时不把 ID 行接成可见技能或怪物招式"
            ),
            PendingSourceSkillRuntimeProofRowModel(
                key: "delivery-hit-shape",
                title: "delivery/命中形态",
                provedCount: pendingCount - emptyDeliveryCount,
                missingCount: emptyDeliveryCount,
                currentEvidence: "\(emptyDeliveryCount)/\(pendingCount) 空 delivery",
                missingEvidence: "缺投射物、AOE、近战、召唤、陷阱或无形态规则",
                boundary: "空 delivery 不生成弹道、AOE 半径、命中点、持续区域或触发形态"
            ),
            PendingSourceSkillRuntimeProofRowModel(
                key: "ownership-target-formula",
                title: "归属/目标/公式",
                provedCount: 0,
                missingCount: pendingCount,
                currentEvidence: "\(checkedMonsterAttackSkills.count) 条已接怪物攻击不属于待接入清单；pending 仍 0 可接入",
                missingEvidence: "缺英雄/怪物归属、目标选择、友敌范围、倍率公式、等级曲线和状态规则",
                boundary: "不按 ID 前缀、damage、range、activation 或 value 推断归属、目标和公式"
            ),
            PendingSourceSkillRuntimeProofRowModel(
                key: "animation-vfx",
                title: "动作帧/VFX",
                provedCount: 0,
                missingCount: pendingCount,
                currentEvidence: "当前 0 组原版施法/飞行/命中/持续/结束关键帧",
                missingEvidence: "缺原版动作帧、VFX 贴图、运动轨迹和命中时序",
                boundary: "本地替代 cue 不能证明原版动作帧或 VFX parity"
            ),
            PendingSourceSkillRuntimeProofRowModel(
                key: "audio-sfx",
                title: "原版 SFX",
                provedCount: 0,
                missingCount: pendingCount,
                currentEvidence: "当前 0 个 pending 源技能有隔离原版 SFX",
                missingEvidence: "缺施法、命中、持续和结束音效证据",
                boundary: "本地生成/替代 SFX 不证明原版技能音效"
            )
        ]
    }

    static var runtimeProofRowCount: Int {
        runtimeProofRows.count
    }

    static var runtimeProofCoverageCount: Int {
        pendingCount
    }

    static var runtimeProofCoverageText: String {
        "\(runtimeProofCoverageCount)/\(pendingCount)"
    }

    static var runtimeProofCatalogCount: Int {
        pendingCount
    }

    static var runtimeProofValueRangeCount: Int {
        pendingValuedCandidateCount
    }

    static var runtimeProofMinimumReadyCount: Int {
        minimumEvidencePendingCount
    }

    static var runtimeProofLocalizedMissingCount: Int {
        sixDigitUnnamedPendingSkills.count
    }

    static var runtimeProofDeliveryMissingCount: Int {
        emptyDeliveryCount
    }

    static var runtimeProofOwnershipFormulaMissingCount: Int {
        pendingCount
    }

    static var runtimeProofAnimationMissingCount: Int {
        pendingCount
    }

    static var runtimeProofSFXMissingCount: Int {
        pendingCount
    }

    static var runtimeProofPositiveText: String {
        "目录 \(runtimeProofCatalogCount) / value \(runtimeProofValueRangeCount) / 可接入 \(runtimeProofMinimumReadyCount)"
    }

    static var runtimeProofMissingText: String {
        "名称 \(runtimeProofLocalizedMissingCount) / delivery \(runtimeProofDeliveryMissingCount) / 归属公式 \(runtimeProofOwnershipFormulaMissingCount) / 动作帧 \(runtimeProofAnimationMissingCount) / SFX \(runtimeProofSFXMissingCount)"
    }

    static var runtimeGateRows: [PendingSourceSkillRuntimeGateRowModel] {
        [
            PendingSourceSkillRuntimeGateRowModel(
                key: "localized-identity",
                title: "本地化名称/说明",
                currentEvidence: "\(pendingValuedCandidateCount) value/range 页仍为 Skill ID",
                missingEvidence: "中文名、英文名、说明文本",
                requiredProof: "中英文技能页或同源数据能证明名称、说明和 ID 绑定",
                affectedSkillCount: pendingCount
            ),
            PendingSourceSkillRuntimeGateRowModel(
                key: "ownership-target",
                title: "归属与目标规则",
                currentEvidence: "\(checkedMonsterAttackSkills.count) 怪物攻击已接入；其余待核对",
                missingEvidence: "英雄/怪物/召唤归属、目标选择、友敌范围",
                requiredProof: "技能页、战斗记录或原版画面能证明施放者和目标规则",
                affectedSkillCount: pendingCount
            ),
            PendingSourceSkillRuntimeGateRowModel(
                key: "delivery-hit-shape",
                title: "delivery/命中形态",
                currentEvidence: "\(emptyDeliveryCount)/\(pendingCount) 空 delivery",
                missingEvidence: "投射物、AOE、近战、召唤、陷阱或无形态规则",
                requiredProof: "来源 delivery、命中类型或原版画面能证明形态",
                affectedSkillCount: emptyDeliveryCount
            ),
            PendingSourceSkillRuntimeGateRowModel(
                key: "formula-scaling",
                title: "公式与等级表",
                currentEvidence: "\(pendingValuedCandidateCount) 有 sourceValue/range",
                missingEvidence: "倍率公式、等级曲线、状态/元素规则",
                requiredProof: "多等级数值、公式来源或可复现实测数据",
                affectedSkillCount: pendingCount
            ),
            PendingSourceSkillRuntimeGateRowModel(
                key: "trigger-cadence",
                title: "触发节奏",
                currentEvidence: "BASEATTACK/BASEATTACK_COUNT/COOLDOWN 源字段",
                missingEvidence: "攻击次数、冷却、持续时间、刷新/叠加",
                requiredProof: "源字段、实测视频或日志能证明触发时间线",
                affectedSkillCount: pendingCount
            ),
            PendingSourceSkillRuntimeGateRowModel(
                key: "animation-vfx",
                title: "动作帧/VFX",
                currentEvidence: "当前仅本地替代 cue",
                missingEvidence: "施法/飞行/命中/持续/结束关键帧",
                requiredProof: "原版帧截图、视频采样或资源文件证据",
                affectedSkillCount: pendingCount
            ),
            PendingSourceSkillRuntimeGateRowModel(
                key: "audio-sfx",
                title: "音效证据",
                currentEvidence: "当前仅本地替代 SFX",
                missingEvidence: "原版施法/命中/持续/结束音频",
                requiredProof: "原版音频资源、录屏音轨或可复现采样",
                affectedSkillCount: pendingCount
            )
        ]
    }

    static var runtimeGateCount: Int {
        runtimeGateRows.count
    }

    static var valueRangeEvidenceQueueSkills: [SourceSkill] {
        pendingValueDetailSkills
    }

    static var nonPhysicalBaseAttackCatalogQueueSkills: [SourceSkill] {
        catalogOnlyPendingSkills
            .filter {
                $0.activation == .baseAttack &&
                    $0.damageType != "Physical"
            }
            .sorted { $0.id < $1.id }
    }

    static var physicalBaseAttackCatalogQueueSkills: [SourceSkill] {
        catalogOnlyPendingSkills
            .filter {
                $0.activation == .baseAttack &&
                    $0.damageType == "Physical"
            }
            .sorted { $0.id < $1.id }
    }

    static var unmappedMonsterCandidateRows: [PendingSourceSkillUnmappedMonsterCandidateRowModel] {
        SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueRows
            .flatMap { monsterRow in
                monsterRow.sourceSkillCandidates
                    .filter { pendingSkillIDs.contains($0.id) }
                    .map {
                        PendingSourceSkillUnmappedMonsterCandidateRowModel(
                            monsterRow: monsterRow,
                            skill: $0
                        )
                    }
            }
    }

    static var unmappedMonsterCandidateSkills: [SourceSkill] {
        unmappedMonsterCandidateRows.map(\.skill)
    }

    static var unmappedMonsterCandidateIDs: [String] {
        unmappedMonsterCandidateSkills.map(\.id)
    }

    static var unmappedMonsterCandidateCount: Int {
        unmappedMonsterCandidateRows.count
    }

    static var unmappedMonsterCandidateEmptyDeliveryCount: Int {
        unmappedMonsterCandidateSkills.filter { $0.delivery.isEmpty }.count
    }

    static var unmappedMonsterCandidateCoverageText: String {
        "\(unmappedMonsterCandidateCount)/\(SourceMonsterDatabaseMetrics.stageCompositionUnmappedCandidateSkillCount)"
    }

    static var unmappedMonsterCandidateIDText: String {
        unmappedMonsterCandidateIDs.joined(separator: ", ")
    }

    static var visualPriorityRows: [PendingSourceSkillVisualPriorityRowModel] {
        [
            PendingSourceSkillVisualPriorityRowModel(
                key: "elemental-vfx",
                title: "元素 VFX 候选",
                skills: pendingElementalDamageCandidateSkills,
                currentEvidence: "\(pendingElementalDamageCandidateSummaryText)；\(pendingElementalValueCount) value；\(pendingElementalEmptyDeliveryCount) 空 delivery",
                nextEvidence: "优先查找 Fire/Cold/Chaos 的原版投射物、动作帧、命中帧、状态表现和 SFX",
                boundary: "元素 damage 只证明源表标签；不生成元素状态、弹道、范围、动作帧或音效"
            ),
            PendingSourceSkillVisualPriorityRowModel(
                key: "cooldown-chaos",
                title: "Chaos 冷却高风险",
                skills: pendingCooldownChaosValueSkills,
                currentEvidence: pendingCooldownChaosValueText,
                nextEvidence: "核对 Chaos 冷却技能的施法者、目标、持续时间、动作帧/关键帧、命中表现和音效",
                boundary: "Chaos value/range 只证明单页字段；不生成公式、目标、持续效果、VFX 或 SFX"
            ),
            PendingSourceSkillVisualPriorityRowModel(
                key: "unmapped-monster-prefix",
                title: "未映射怪物同前缀",
                skills: unmappedMonsterCandidateSkills,
                currentEvidence: unmappedMonsterCandidateIDText,
                nextEvidence: "先补怪物出场、战斗图、动作帧和技能归属证据，再考虑接入",
                boundary: "同前缀只作为交叉复核入口；不证明怪物出场、技能归属、素材或音效"
            ),
            PendingSourceSkillVisualPriorityRowModel(
                key: "highest-value-pages",
                title: "最高 value 页面",
                skills: highestPendingValueSkillsForReview,
                currentEvidence: highestPendingValueText,
                nextEvidence: "核对最高 value 候选的等级曲线、公式、目标、动作帧、命中特效和音效",
                boundary: "最高 value 只排列复核优先级；不生成伤害倍率、公式、目标、动作帧或音效"
            )
        ]
    }

    static var visualPriorityQueueCount: Int {
        visualPriorityRows.count
    }

    static var visualPriorityTotalEntries: Int {
        visualPriorityRows.map(\.count).reduce(0, +)
    }

    static var visualPriorityUniqueSkillIDs: [String] {
        Set(visualPriorityRows.flatMap(\.sampleIDs)).sorted()
    }

    static var visualPriorityUniqueSkillCount: Int {
        visualPriorityUniqueSkillIDs.count
    }

    static var visualPriorityOverlapCount: Int {
        visualPriorityTotalEntries - visualPriorityUniqueSkillCount
    }

    static var visualPriorityUnqueuedPendingCount: Int {
        pendingCount - visualPriorityUniqueSkillCount
    }

    static var visualPriorityCoverageText: String {
        "\(visualPriorityUniqueSkillCount)/\(pendingCount)"
    }

    static var visualReviewTotalQueueCount: Int {
        visualPriorityQueueCount + visualPriorityUnqueuedQueueCount
    }

    static var visualReviewTotalCoverageCount: Int {
        visualPriorityUniqueSkillCount + visualPriorityUnqueuedQueueCoverageCount
    }

    static var visualReviewTotalCoverageText: String {
        "\(visualReviewTotalCoverageCount)/\(pendingCount)"
    }

    static var visualPriorityUnqueuedSkillIDs: [String] {
        let queuedIDs = Set(visualPriorityUniqueSkillIDs)
        return pendingSkills
            .filter { !queuedIDs.contains($0.id) }
            .map(\.id)
            .sorted()
    }

    static var visualPriorityUnqueuedSkills: [SourceSkill] {
        let unqueuedIDs = Set(visualPriorityUnqueuedSkillIDs)
        return pendingSkills
            .filter { unqueuedIDs.contains($0.id) }
            .sorted { $0.id < $1.id }
    }

    static var visualPriorityUnqueuedValueSkills: [SourceSkill] {
        visualPriorityUnqueuedSkills.filter { $0.sourceValue != nil }
    }

    static var visualPriorityUnqueuedBaseAttackCatalogSkills: [SourceSkill] {
        visualPriorityUnqueuedSkills.filter {
            $0.sourceValue == nil &&
                $0.activation == .baseAttack
        }
    }

    static var visualPriorityUnqueuedQueueRows: [PendingSourceSkillEvidenceQueueRowModel] {
        [
            PendingSourceSkillEvidenceQueueRowModel(
                key: "unqueued-physical-value-pages",
                title: "未入视觉 value/range",
                count: visualPriorityUnqueuedValueSkills.count,
                sampleIDs: visualPriorityUnqueuedValueSkills.map(\.id),
                currentEvidence: "\(visualPriorityUnqueuedValueSkills.count) Physical value/range 页；\(visualPriorityUnqueuedValueSkills.filter { $0.delivery.isEmpty }.count) 空 delivery",
                nextEvidence: "补这些 Physical value 候选的本地化名称、归属、目标/公式、动作帧、命中特效和 SFX",
                boundary: "未入视觉只表示尚未进入优先找图/找帧队列；不按 value 生成倍率、目标、弹道、动作帧或音效"
            ),
            PendingSourceSkillEvidenceQueueRowModel(
                key: "unqueued-physical-baseattack-catalog",
                title: "未入视觉 Physical BASEATTACK",
                count: visualPriorityUnqueuedBaseAttackCatalogSkills.count,
                sampleIDs: visualPriorityUnqueuedBaseAttackCatalogSkills.map(\.id),
                currentEvidence: "\(visualPriorityUnqueuedBaseAttackCatalogSkills.count) Physical BASEATTACK 目录行；无 sourceValue；全部空 delivery",
                nextEvidence: "补命名、英雄/怪物归属、武器或怪物动作、命中形态、动作帧和音效",
                boundary: "Physical BASEATTACK 目录行仍只作复核目标；不按 ID、range 或 Physical 标签生成普通攻击或怪物招式"
            )
        ]
    }

    static var visualPriorityUnqueuedQueueCount: Int {
        visualPriorityUnqueuedQueueRows.count
    }

    static var visualPriorityUnqueuedQueueCoverageCount: Int {
        visualPriorityUnqueuedQueueRows.map(\.count).reduce(0, +)
    }

    static var visualPriorityUnqueuedValueCount: Int {
        visualPriorityUnqueuedSkills.filter { $0.sourceValue != nil }.count
    }

    static var visualPriorityUnqueuedEmptyDeliveryCount: Int {
        visualPriorityUnqueuedSkills.filter { $0.delivery.isEmpty }.count
    }

    static var visualPriorityUnqueuedDamageRows: [PendingSourceSkillCategoryRowModel] {
        let preferredOrder = ["Physical", "Fire", "Cold", "Lightning", "Chaos"]
        return preferredOrder.compactMap { damageType in
            let skills = visualPriorityUnqueuedSkills.filter { $0.damageType == damageType }
            guard !skills.isEmpty else { return nil }
            return PendingSourceSkillCategoryRowModel(
                key: "unqueued-damage-\(damageType)",
                title: "未入视觉 \(damageType)",
                count: skills.count,
                sampleIDs: skills.map(\.id),
                category: .damage
            )
        }
    }

    static var visualPriorityUnqueuedActivationRows: [PendingSourceSkillCategoryRowModel] {
        let activationOrder: [SkillActivation] = [.baseAttack, .baseAttackCount, .cooldown, .continuous]
        return activationOrder.compactMap { activation in
            let skills = visualPriorityUnqueuedSkills.filter { $0.activation == activation }
            guard !skills.isEmpty else { return nil }
            return PendingSourceSkillCategoryRowModel(
                key: "unqueued-activation-\(activation.rawValue)",
                title: "未入视觉 \(activation.rawValue)",
                count: skills.count,
                sampleIDs: skills.map(\.id),
                category: .activation
            )
        }
    }

    static var visualPriorityUnqueuedRangeRows: [PendingSourceSkillCategoryRowModel] {
        let ranges = Set(visualPriorityUnqueuedSkills.map(\.range)).sorted()
        return ranges.map { range in
            let skills = visualPriorityUnqueuedSkills.filter { $0.range == range }
            return PendingSourceSkillCategoryRowModel(
                key: "unqueued-range-\(range)",
                title: "未入视觉 range \(range)",
                count: skills.count,
                sampleIDs: skills.map(\.id),
                category: .range
            )
        }
    }

    static var pendingElementalDamageCandidateSkills: [SourceSkill] {
        pendingElementalDamageTypes.flatMap { damageType in
            pendingDamageCandidateSkills(damageType)
        }
    }

    static var pendingElementalValueCount: Int {
        pendingElementalDamageCandidateSkills.filter { $0.sourceValue != nil }.count
    }

    static var pendingElementalEmptyDeliveryCount: Int {
        pendingElementalDamageCandidateSkills.filter { $0.delivery.isEmpty }.count
    }

    static var highestPendingValueSkillsForReview: [SourceSkill] {
        guard let highestValue = pendingValuedCandidateSkills.first?.sourceValue else { return [] }
        return highestPendingValueSkills(highestValue: highestValue)
    }

    static var nonPhysicalBaseAttackCatalogSummaryText: String {
        let preferredOrder = ["Fire", "Cold", "Chaos"]
        return preferredOrder.compactMap { damageType in
            let count = nonPhysicalBaseAttackCatalogQueueSkills.filter { $0.damageType == damageType }.count
            guard count > 0 else { return nil }
            return "\(damageType) \(count)"
        }
        .joined(separator: " / ")
    }

    static var evidenceQueueRows: [PendingSourceSkillEvidenceQueueRowModel] {
        [
            PendingSourceSkillEvidenceQueueRowModel(
                key: "value-range-pages",
                title: "先核对 value/range 页",
                count: valueRangeEvidenceQueueSkills.count,
                sampleIDs: valueRangeEvidenceQueueSkills.map(\.id),
                currentEvidence: "\(pendingValuedCandidateCount) 页有 sourceValue/range；\(pendingValuedEmptyDeliveryCount) 空 delivery",
                nextEvidence: "补中英文名、说明、delivery、目标/公式、动作帧与音效",
                boundary: "不以 value 数值直接接入倍率或技能效果"
            ),
            PendingSourceSkillEvidenceQueueRowModel(
                key: "nonphysical-baseattack-catalog",
                title: "非物理基础攻击目录",
                count: nonPhysicalBaseAttackCatalogQueueSkills.count,
                sampleIDs: nonPhysicalBaseAttackCatalogQueueSkills.map(\.id),
                currentEvidence: "\(nonPhysicalBaseAttackCatalogSummaryText)；目录行无 sourceValue",
                nextEvidence: "补怪物/职业归属、命中形态、元素表现、原版动作帧与音效",
                boundary: "不把 damage 类型直接解释为原版元素特效或状态"
            ),
            PendingSourceSkillEvidenceQueueRowModel(
                key: "physical-baseattack-catalog",
                title: "物理基础攻击目录",
                count: physicalBaseAttackCatalogQueueSkills.count,
                sampleIDs: physicalBaseAttackCatalogQueueSkills.map(\.id),
                currentEvidence: "\(physicalBaseAttackCatalogQueueSkills.count) Physical BASEATTACK 目录行；无 sourceValue",
                nextEvidence: "补命名、武器/怪物归属、命中距离、动作帧与音效",
                boundary: "不把 ID 段直接解释为职业或怪物招式"
            )
        ]
    }

    static var evidenceQueueCount: Int {
        evidenceQueueRows.count
    }

    static var evidenceQueueCoverageCount: Int {
        evidenceQueueRows.map(\.count).reduce(0, +)
    }

    static let activationDamageQueueBoundaryText = "activation × damage 队列只显示待核对复核顺序；不按触发类型、伤害类型或 value 推断归属、命中形态、公式、动作帧或音效"

    static var activationDamageQueueRows: [PendingSourceSkillActivationDamageQueueRowModel] {
        let activationOrder: [SkillActivation] = [.baseAttack, .baseAttackCount, .cooldown, .continuous]
        let damageOrder = ["Physical", "Fire", "Cold", "Lightning", "Chaos"]
        return activationOrder.flatMap { activation in
            damageOrder.compactMap { damageType in
                let skills = pendingSkills
                    .filter { $0.activation == activation && $0.damageType == damageType }
                    .sorted { $0.id < $1.id }
                guard !skills.isEmpty else { return nil }
                return PendingSourceSkillActivationDamageQueueRowModel(
                    activation: activation,
                    damageType: damageType,
                    skills: skills
                )
            }
        }
    }

    static var rangeEvidenceQueueRows: [PendingSourceSkillRangeEvidenceQueueRowModel] {
        let ranges = Set(pendingSkills.map(\.range)).sorted()
        return ranges.map { range in
            PendingSourceSkillRangeEvidenceQueueRowModel(
                range: range,
                skills: pendingSkills
                    .filter { $0.range == range }
                    .sorted { $0.id < $1.id }
            )
        }
    }

    static var prefixEvidenceQueueRows: [PendingSourceSkillPrefixEvidenceQueueRowModel] {
        let prefixes = Set(pendingSkills.compactMap { $0.id.first.map(String.init) }).sorted()
        return prefixes.map { prefix in
            PendingSourceSkillPrefixEvidenceQueueRowModel(
                prefix: prefix,
                skills: pendingSkills
                    .filter { $0.id.hasPrefix(prefix) }
                    .sorted { $0.id < $1.id }
            )
        }
    }

    static var valueEvidenceQueueRows: [PendingSourceSkillValueEvidenceQueueRowModel] {
        let sourceValues = Set(pendingValueDetailSkills.compactMap(\.sourceValue)).sorted()
        return sourceValues.map { sourceValue in
            PendingSourceSkillValueEvidenceQueueRowModel(
                sourceValue: sourceValue,
                skills: pendingValueDetailSkills
                    .filter { $0.sourceValue == sourceValue }
                    .sorted { $0.id < $1.id }
            )
        }
    }

    static var valueEvidenceQueueCount: Int {
        valueEvidenceQueueRows.count
    }

    static var valueEvidenceQueueCoverageCount: Int {
        valueEvidenceQueueRows.map(\.count).reduce(0, +)
    }

    static var valueEvidenceQueueEmptyDeliveryCount: Int {
        valueEvidenceQueueRows.map(\.emptyDeliveryCount).reduce(0, +)
    }

    static var prefixEvidenceQueueCount: Int {
        prefixEvidenceQueueRows.count
    }

    static var prefixEvidenceQueueCoverageCount: Int {
        prefixEvidenceQueueRows.map(\.count).reduce(0, +)
    }

    static var prefixEvidenceQueueValueCoverageCount: Int {
        prefixEvidenceQueueRows.map(\.valueCount).reduce(0, +)
    }

    static var prefixEvidenceQueueEmptyDeliveryCount: Int {
        prefixEvidenceQueueRows.map(\.emptyDeliveryCount).reduce(0, +)
    }

    static var rangeEvidenceQueueCount: Int {
        rangeEvidenceQueueRows.count
    }

    static var rangeEvidenceQueueCoverageCount: Int {
        rangeEvidenceQueueRows.map(\.count).reduce(0, +)
    }

    static var rangeEvidenceQueueValueCoverageCount: Int {
        rangeEvidenceQueueRows.map(\.valueCount).reduce(0, +)
    }

    static var rangeEvidenceQueueEmptyDeliveryCount: Int {
        rangeEvidenceQueueRows.map(\.emptyDeliveryCount).reduce(0, +)
    }

    static var activationDamageQueueCount: Int {
        activationDamageQueueRows.count
    }

    static var activationDamageQueueCoverageCount: Int {
        activationDamageQueueRows.map(\.count).reduce(0, +)
    }

    static var activationDamageValueCoverageCount: Int {
        activationDamageQueueRows.map(\.valueCount).reduce(0, +)
    }

    static var activationDamageEmptyDeliveryCount: Int {
        activationDamageQueueRows.map(\.emptyDeliveryCount).reduce(0, +)
    }

    static var catalogOnlyPendingCount: Int {
        catalogOnlyPendingSkills.count
    }

    static var valueRangeOnlyPendingCount: Int {
        valueRangeOnlyPendingSkills.count
    }

    static var minimumEvidencePendingCount: Int {
        minimumEvidencePendingSkills.count
    }

    static var activationRows: [PendingSourceSkillCategoryRowModel] {
        SkillActivation.allCases.compactMap { activation in
            let skills = pendingSkills.filter { $0.activation == activation }
            guard !skills.isEmpty else { return nil }
            return PendingSourceSkillCategoryRowModel(
                key: activation.rawValue,
                title: activation.rawValue,
                count: skills.count,
                sampleIDs: skills.map(\.id),
                category: .activation
            )
        }
    }

    static var damageRows: [PendingSourceSkillCategoryRowModel] {
        let preferredOrder = ["Physical", "Fire", "Cold", "Lightning", "Chaos"]
        return preferredOrder.compactMap { damageType in
            let skills = pendingSkills.filter { $0.damageType == damageType }
            guard !skills.isEmpty else { return nil }
            return PendingSourceSkillCategoryRowModel(
                key: damageType,
                title: damageType,
                count: skills.count,
                sampleIDs: skills.map(\.id),
                category: .damage
            )
        }
    }

    static var sourcePrefixRows: [PendingSourceSkillCategoryRowModel] {
        let prefixes = Set(pendingSkills.compactMap { $0.id.first.map(String.init) }).sorted()
        return prefixes.compactMap { prefix in
            let skills = pendingSkills.filter { $0.id.hasPrefix(prefix) }
            guard !skills.isEmpty else { return nil }
            return PendingSourceSkillCategoryRowModel(
                key: prefix,
                title: "ID 段 \(prefix)",
                count: skills.count,
                sampleIDs: skills.map(\.id),
                category: .sourcePrefix
            )
        }
    }

    static var rangeRows: [PendingSourceSkillCategoryRowModel] {
        let ranges = Set(pendingSkills.map(\.range)).sorted()
        return ranges.map { range in
            let skills = pendingSkills.filter { $0.range == range }
            return PendingSourceSkillCategoryRowModel(
                key: "\(range)",
                title: "range \(range)",
                count: skills.count,
                sampleIDs: skills.map(\.id),
                category: .range
            )
        }
    }

    static var mostCommonRangeText: String {
        guard let row = rangeRows.max(by: { lhs, rhs in
            if lhs.count == rhs.count {
                return lhs.key > rhs.key
            }
            return lhs.count < rhs.count
        }) else {
            return "无"
        }
        return "\(row.key) x\(row.count)"
    }

    static var sixDigitUnnamedPendingSkills: [SourceSkill] {
        pendingSkills.filter { $0.id.count == 6 && $0.name.hasPrefix("Skill ") }
    }

    static var pendingBaseAttackCandidateSkills: [SourceSkill] {
        pendingSkills.filter { $0.activation == .baseAttack }
    }

    static var pendingBaseAttackCandidatePrefixRows: [PendingSourceSkillCategoryRowModel] {
        let prefixes = Set(pendingBaseAttackCandidateSkills.compactMap { $0.id.first.map(String.init) }).sorted()
        return prefixes.compactMap { prefix in
            let skills = pendingBaseAttackCandidateSkills.filter { $0.id.hasPrefix(prefix) }
            guard !skills.isEmpty else { return nil }
            return PendingSourceSkillCategoryRowModel(
                key: "baseAttack-\(prefix)",
                title: "BASEATTACK ID 段 \(prefix)",
                count: skills.count,
                sampleIDs: skills.map(\.id),
                category: .sourcePrefix
            )
        }
    }

    static var pendingTriggeredCandidateSkills: [SourceSkill] {
        pendingSkills.filter { $0.activation == .baseAttackCount || $0.activation == .cooldown }
    }

    static var pendingTriggeredCandidateIDs: [String] {
        pendingTriggeredCandidateSkills.map(\.id)
    }

    static var pendingTriggeredCandidateIDText: String {
        pendingTriggeredCandidateIDs.joined(separator: ", ")
    }

    static var pendingTriggeredValueSkills: [SourceSkill] {
        pendingTriggeredCandidateSkills.sorted { $0.id < $1.id }
    }

    static var pendingTriggeredValueText: String {
        pendingTriggeredValueSkills
            .map { "\($0.id)=\($0.sourceValueText)/r\($0.range)" }
            .joined(separator: "; ")
    }

    static var pendingTriggeredValueCount: Int {
        pendingTriggeredValueSkills.filter { $0.sourceValue != nil }.count
    }

    static var pendingValuedCandidateSkills: [SourceSkill] {
        pendingSkills
            .filter { $0.sourceValue != nil }
            .sorted {
                if ($0.sourceValue ?? 0) == ($1.sourceValue ?? 0) {
                    return $0.id < $1.id
                }
                return ($0.sourceValue ?? 0) > ($1.sourceValue ?? 0)
            }
    }

    static var pendingValuedCandidateCount: Int {
        pendingValuedCandidateSkills.count
    }

    static var pendingValuedEmptyDeliveryCount: Int {
        pendingValuedCandidateSkills.filter { $0.delivery.isEmpty }.count
    }

    static var pendingValuedUnnamedCount: Int {
        pendingValuedCandidateSkills.filter { $0.name.hasPrefix("Skill ") }.count
    }

    static var highestPendingValueText: String {
        guard let highestValue = pendingValuedCandidateSkills.first?.sourceValue else { return "无" }
        return highestPendingValueSkills(highestValue: highestValue)
            .map { "\($0.id)=\(highestValue)/r\($0.range)" }
            .joined(separator: "; ")
    }

    static var highestPendingValueDetailPathText: String {
        guard let highestValue = pendingValuedCandidateSkills.first?.sourceValue else { return "无" }
        return highestPendingValueSkills(highestValue: highestValue)
            .map { "\($0.id)=/zh/skills/active/id-\($0.id)/" }
            .joined(separator: "; ")
    }

    static var highestPendingValueDetailEvidenceText: String {
        guard let highestValue = pendingValuedCandidateSkills.first?.sourceValue else { return "无" }
        let reviewedCount = highestPendingValueSkills(highestValue: highestValue).count
        return "\(reviewedCount) 页 / Skill ID / 无说明 / 空 delivery"
    }

    static var highestPendingValueLocalePageCount: Int {
        guard let highestValue = pendingValuedCandidateSkills.first?.sourceValue else { return 0 }
        return highestPendingValueSkills(highestValue: highestValue).count * reviewedSourcePageLocales.count
    }

    static var highestPendingValueSnapshotText: String {
        guard highestPendingValueLocalePageCount > 0 else { return "无" }
        return "\(highestPendingValueLocalePageCount) 中英页 / \(sourcePageSnapshotVersion) / Skill ID / 无说明 / delivery —"
    }

    static var pendingValueReadinessText: String {
        "\(pendingValuedCandidateCount) value / \(pendingValuedUnnamedCount) 未命名 / \(pendingValuedEmptyDeliveryCount) 空形态"
    }

    static var pendingValueDetailSkills: [SourceSkill] {
        pendingValuedCandidateSkills.sorted { $0.id < $1.id }
    }

    static var valueEvidenceRows: [PendingSourceSkillValueEvidenceRowModel] {
        pendingValueDetailSkills.map {
            PendingSourceSkillValueEvidenceRowModel(skill: $0)
        }
    }

    static var valueEvidenceRowCount: Int {
        valueEvidenceRows.count
    }

    static var valueEvidenceCoverageText: String {
        "\(valueEvidenceRowCount)/\(pendingValuedCandidateCount)"
    }

    static var nonPhysicalBaseAttackEvidenceRows: [PendingSourceSkillBaseAttackEvidenceRowModel] {
        nonPhysicalBaseAttackCatalogQueueSkills.map {
            PendingSourceSkillBaseAttackEvidenceRowModel(skill: $0)
        }
    }

    static var physicalBaseAttackEvidenceRows: [PendingSourceSkillBaseAttackEvidenceRowModel] {
        physicalBaseAttackCatalogQueueSkills.map {
            PendingSourceSkillBaseAttackEvidenceRowModel(skill: $0)
        }
    }

    static var baseAttackEvidenceRows: [PendingSourceSkillBaseAttackEvidenceRowModel] {
        nonPhysicalBaseAttackEvidenceRows + physicalBaseAttackEvidenceRows
    }

    static var nonPhysicalBaseAttackEvidenceRowCount: Int {
        nonPhysicalBaseAttackEvidenceRows.count
    }

    static var physicalBaseAttackEvidenceRowCount: Int {
        physicalBaseAttackEvidenceRows.count
    }

    static var baseAttackEvidenceRowCount: Int {
        baseAttackEvidenceRows.count
    }

    static var baseAttackEvidenceCoverageText: String {
        "\(baseAttackEvidenceRowCount)/\(pendingBaseAttackCandidateSkills.count)"
    }

    static var pendingValueDetailPathText: String {
        pendingValueDetailSkills
            .map { "\($0.id)=/zh/skills/active/id-\($0.id)/" }
            .joined(separator: "; ")
    }

    static var pendingValueDetailEvidenceText: String {
        "\(pendingValueDetailSkills.count) 页 / Skill ID / 无说明 / 空 delivery / 命中类型 —"
    }

    static var pendingValueDetailLocalePageCount: Int {
        pendingValueDetailSkills.count * reviewedSourcePageLocales.count
    }

    static var pendingValueDetailSnapshotText: String {
        "\(pendingValueDetailLocalePageCount) 中英页 / \(sourcePageSnapshotVersion) / Skill ID / 无说明 / delivery — / 命中类型 —"
    }

    private static func highestPendingValueSkills(highestValue: Int) -> [SourceSkill] {
        pendingValuedCandidateSkills
            .filter { $0.sourceValue == highestValue }
            .sorted { $0.id < $1.id }
    }

    static var pendingCooldownChaosValueSkills: [SourceSkill] {
        pendingSkills
            .filter {
                $0.activation == .cooldown &&
                    $0.damageType == "Chaos"
            }
            .sorted { $0.id < $1.id }
    }

    static var pendingCooldownChaosValueText: String {
        pendingCooldownChaosValueSkills
            .map { "\($0.id)=\($0.sourceValueText)/r\($0.range)" }
            .joined(separator: "; ")
    }

    static var pendingCooldownChaosValueCount: Int {
        pendingCooldownChaosValueSkills.filter { $0.sourceValue != nil }.count
    }

    static var cooldownChaosPageEvidenceRows: [PendingSourceSkillCooldownChaosPageEvidenceRowModel] {
        pendingCooldownChaosValueSkills.map {
            PendingSourceSkillCooldownChaosPageEvidenceRowModel(skill: $0)
        }
    }

    static var cooldownChaosPageEvidenceRowCount: Int {
        cooldownChaosPageEvidenceRows.count
    }

    static var cooldownChaosPageLocaleCount: Int {
        cooldownChaosPageEvidenceRowCount * reviewedSourcePageLocales.count
    }

    static var cooldownChaosPageEmptyDeliveryCount: Int {
        pendingCooldownChaosValueSkills.filter { $0.delivery.isEmpty }.count
    }

    static var cooldownChaosPageUnnamedCount: Int {
        pendingCooldownChaosValueSkills.filter { $0.name.hasPrefix("Skill ") }.count
    }

    static var cooldownChaosPageSnapshotText: String {
        "\(cooldownChaosPageLocaleCount) 中英页 / \(sourcePageSnapshotVersion) / Skill ID / 无说明 / delivery — / Lv —"
    }

    static var cooldownChaosPageBoundaryText: String {
        "COOLDOWN/Chaos 页证据只证明三行当前源页字段仍缺；中英页同属 taskbarhero.org \(sourcePageSnapshotVersion)，不是第二独立来源，也不证明目标、持续时间、命中形态、动画或 SFX"
    }

    static let pendingDamageCandidateTypes = ["Physical", "Fire", "Cold", "Chaos"]
    static let pendingElementalDamageTypes = ["Fire", "Cold", "Chaos"]

    static func pendingDamageCandidateSkills(_ damageType: String) -> [SourceSkill] {
        pendingSkills.filter { $0.damageType == damageType }
    }

    static var pendingDamageCandidateRows: [PendingSourceSkillCategoryRowModel] {
        pendingDamageCandidateTypes.compactMap { damageType in
            let skills = pendingDamageCandidateSkills(damageType)
            guard !skills.isEmpty else { return nil }
            return PendingSourceSkillCategoryRowModel(
                key: "pendingDamage-\(damageType)",
                title: "\(damageType) 待接入源技能",
                count: skills.count,
                sampleIDs: skills.map(\.id),
                category: .damage
            )
        }
    }

    static var pendingDamageCandidateSummaryText: String {
        pendingDamageCandidateTypes
            .map { "\($0) \(pendingDamageCandidateSkills($0).count)" }
            .joined(separator: " / ")
    }

    static var pendingDamageCandidateIDText: String {
        pendingDamageCandidateTypes
            .map { damageType in
                "\(damageType):\(pendingDamageCandidateSkills(damageType).map(\.id).joined(separator: ","))"
            }
            .joined(separator: ";")
    }

    static var pendingElementalDamageCandidateRows: [PendingSourceSkillCategoryRowModel] {
        pendingDamageCandidateRows.filter { row in
            pendingElementalDamageTypes.contains(row.key.replacingOccurrences(of: "pendingDamage-", with: ""))
        }
    }

    static var pendingElementalDamageCandidateSummaryText: String {
        pendingElementalDamageTypes
            .map { "\($0) \(pendingDamageCandidateSkills($0).count)" }
            .joined(separator: " / ")
    }

    static var pendingElementalDamageCandidateIDText: String {
        pendingElementalDamageTypes
            .map { damageType in
                "\(damageType):\(pendingDamageCandidateSkills(damageType).map(\.id).joined(separator: ","))"
            }
            .joined(separator: ";")
    }

    static var pendingChaosDamageCandidateSkills: [SourceSkill] {
        pendingDamageCandidateSkills("Chaos")
    }

    static var pendingChaosDamageCandidateIDs: [String] {
        pendingChaosDamageCandidateSkills.map(\.id)
    }

    static var pendingChaosDamageCandidateIDText: String {
        pendingChaosDamageCandidateIDs.joined(separator: ", ")
    }

    static var pendingChaosDamageCandidateRow: PendingSourceSkillCategoryRowModel {
        PendingSourceSkillCategoryRowModel(
            key: "pendingChaosDamage",
            title: "Chaos 待接入源技能",
            count: pendingChaosDamageCandidateSkills.count,
            sampleIDs: pendingChaosDamageCandidateIDs,
            category: .damage
        )
    }

    static var checkedMonsterAttackSkills: [SourceSkill] {
        SourceSkillCatalog.runtimeMonsterAttackSkillIDs
            .sorted()
            .compactMap { SourceSkillCatalog.skill(id: $0) }
    }

    static var responsibilityRows: [PendingSourceSkillCategoryRowModel] {
        [
            PendingSourceSkillCategoryRowModel(
                key: "sixDigitUnnamed",
                title: "六位未命名源技能",
                count: sixDigitUnnamedPendingSkills.count,
                sampleIDs: sixDigitUnnamedPendingSkills.map(\.id),
                category: .responsibility
            ),
            PendingSourceSkillCategoryRowModel(
                key: "pendingBaseAttack",
                title: "待核对基础攻击候选",
                count: pendingBaseAttackCandidateSkills.count,
                sampleIDs: pendingBaseAttackCandidateSkills.map(\.id),
                category: .responsibility
            ),
            PendingSourceSkillCategoryRowModel(
                key: "pendingTriggered",
                title: "待核对触发/冷却候选",
                count: pendingTriggeredCandidateSkills.count,
                sampleIDs: pendingTriggeredCandidateSkills.map(\.id),
                category: .responsibility
            ),
            PendingSourceSkillCategoryRowModel(
                key: "checkedMonsterAttack",
                title: "已接入怪物攻击",
                count: checkedMonsterAttackSkills.count,
                sampleIDs: checkedMonsterAttackSkills.map(\.id),
                category: .responsibility
            )
        ]
    }

    static func activationCount(_ activation: SkillActivation) -> Int {
        pendingSkills.filter { $0.activation == activation }.count
    }

    static func damageCount(_ damageType: String) -> Int {
        pendingSkills.filter { $0.damageType == damageType }.count
    }

    private static func hasMinimumRuntimeEvidence(_ skill: SourceSkill) -> Bool {
        !skill.name.hasPrefix("Skill ") &&
            !skill.delivery.isEmpty &&
            skill.sourceValue != nil
    }
}

enum SourcePassiveSkillDatabaseMetrics {
    static let missingSourceIconStats: Set<String> = ["IncreaseProjectileDamage", "SkillHealIncrease"]

    static var sourceRowCount: Int {
        PassiveSkills.all.count
    }

    static var statCount: Int {
        Set(PassiveSkills.all.map(\.stat)).count
    }

    static var sourceIconMappedRowCount: Int {
        PassiveSkills.all.filter { GameArt.passiveSkillIconName(for: $0) != nil }.count
    }

    static var sourceIconCoverageText: String {
        "\(sourceIconMappedRowCount)/\(sourceRowCount)"
    }

    static var sourceIconFamilyCount: Int {
        GameArt.passiveSkillIconNames.count
    }

    static var valueTypeCount: Int {
        Set(PassiveSkills.all.map(\.valueType)).count
    }

    static var heroClassRowCounts: [HeroClass: Int] {
        Dictionary(
            uniqueKeysWithValues: HeroClass.allCases.map { heroClass in
                (heroClass, PassiveSkills.skills(for: heroClass).count)
            }
        )
    }

    static var currentMissingSourceIconStats: Set<String> {
        Set(
            PassiveSkills.all
                .filter { GameArt.passiveSkillIconName(for: $0) == nil }
                .map(\.stat)
        )
    }
}

struct ExactItemRecordGapCategoryRowModel: Identifiable, Equatable {
    let category: EquipmentCategory
    let typeCount: Int
    let aggregateEntryCount: Int
    let baseProgressionCount: Int
    let exactRecordCount: Int

    var id: String {
        category.rawValue
    }

    var missingRecordCount: Int {
        aggregateEntryCount - exactRecordCount
    }
}

struct ExactItemRecordGapTypeRowModel: Identifiable, Equatable {
    let gearType: SourceGearTypeEntry
    let exactRecordCount: Int

    var id: String {
        gearType.id
    }

    var category: EquipmentCategory {
        gearType.equipmentType.category
    }

    var aggregateEntryCount: Int {
        gearType.gearEntryCount
    }

    var baseProgressionCount: Int {
        gearType.progressions.count
    }

    var missingRecordCount: Int {
        aggregateEntryCount - exactRecordCount
    }

    var rarityDistributionText: String {
        Rarity.allCases
            .map { rarity in
                "\(Self.rarityCode(for: rarity)):\(gearType.rarityCount(for: rarity))"
            }
            .joined(separator: " ")
    }

    private static func rarityCode(for rarity: Rarity) -> String {
        switch rarity {
        case .common: return "C"
        case .uncommon: return "U"
        case .rare: return "R"
        case .legendary: return "L"
        case .immortal: return "I"
        case .arcana: return "A"
        case .beyond: return "B"
        case .celestial: return "Ce"
        case .divine: return "D"
        case .cosmic: return "Co"
        }
    }
}

struct ExactItemMissingEvidenceRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let currentEvidence: String
    let missingEvidence: String
    let requiredProof: String
    let affectedRecordCount: Int

    var id: String {
        key
    }
}

struct ExactItemRecordCategoryEvidenceQueueRowModel: Identifiable, Equatable {
    let row: ExactItemRecordGapCategoryRowModel

    var id: String {
        "category-queue-\(row.id)"
    }

    var title: String {
        "\(row.category.rawValue)精确记录"
    }

    var currentEvidence: String {
        "\(row.typeCount) 类型 / \(row.aggregateEntryCount) 聚合项 / \(row.baseProgressionCount) 基础进度"
    }

    var nextEvidence: String {
        "逐类型变体 ID、稀有度行、词缀 roll、掉落来源和图标共享规则"
    }

    var boundary: String {
        "不按聚合项自动生成 \(row.aggregateEntryCount) 条装备记录"
    }
}

struct ExactItemRecordTypeEvidenceQueueRowModel: Identifiable, Equatable {
    let row: ExactItemRecordGapTypeRowModel

    var id: String {
        "type-queue-\(row.id)"
    }

    var title: String {
        "\(row.gearType.equipmentType.localizedName) / \(row.gearType.sourceTitle)"
    }

    var progressionSpanText: String {
        guard let first = row.gearType.progressions.first,
              let last = row.gearType.progressions.last else {
            return "无基础进度"
        }
        return "\(first.id) L\(first.itemLevel) -> \(last.id) L\(last.itemLevel)"
    }

    var currentEvidence: String {
        "聚合 \(row.aggregateEntryCount) / 基础 \(row.baseProgressionCount) / \(progressionSpanText)"
    }

    var nextEvidence: String {
        "补 \(row.gearType.sourceTitle) 的逐稀有度变体 ID、词缀池、属性范围、掉落权重"
    }

    var boundary: String {
        "不从 \(row.baseProgressionCount) 个基础进度扩展出 \(row.aggregateEntryCount) 条精确记录"
    }
}

struct ExactItemRecordRarityEvidenceQueueRowModel: Identifiable, Equatable {
    let rarity: Rarity
    let aggregateEntryCount: Int
    let typeCount: Int
    let exactRecordCount: Int

    var id: String {
        rarity.rawValue
    }

    var title: String {
        "\(rarity.rawValue)精确记录"
    }

    var missingRecordCount: Int {
        aggregateEntryCount - exactRecordCount
    }

    var currentEvidence: String {
        "\(typeCount) 类型含该稀有度 / \(aggregateEntryCount) 聚合项 / \(exactRecordCount) 精确记录"
    }

    var nextEvidence: String {
        "补 \(rarity.rawValue) 装备逐件变体 ID、词缀池、属性范围、掉落权重和图标共享规则"
    }

    var boundary: String {
        "不从 \(aggregateEntryCount) 个稀有度聚合项生成精确装备记录；不生成词缀或掉落权重"
    }
}

struct ExactItemRecordCategoryRarityEvidenceQueueRowModel: Identifiable, Equatable {
    let category: EquipmentCategory
    let rarity: Rarity
    let aggregateEntryCount: Int
    let typeCount: Int
    let exactRecordCount: Int

    var id: String {
        "\(category.rawValue)-\(rarity.rawValue)"
    }

    var title: String {
        "\(category.rawValue) / \(rarity.rawValue)"
    }

    var missingRecordCount: Int {
        aggregateEntryCount - exactRecordCount
    }

    var currentEvidence: String {
        "\(typeCount) 类型 / \(aggregateEntryCount) 聚合项 / \(exactRecordCount) 精确记录"
    }

    var nextEvidence: String {
        "补 \(category.rawValue) \(rarity.rawValue) 逐件变体 ID、词缀池、属性范围、掉落权重和图标共享规则"
    }

    var boundary: String {
        "矩阵只交叉统计来源类别与稀有度；不生成装备记录、词缀、掉落权重或新图标"
    }
}

struct ExactItemRecordProgressionEvidenceQueueRowModel: Identifiable, Equatable {
    let gearType: SourceGearTypeEntry
    let progression: SourceGearLevelProgression

    var id: String {
        "\(gearType.id)-\(progression.id)"
    }

    var title: String {
        "\(gearType.equipmentType.localizedName) / \(progression.name)"
    }

    var currentEvidence: String {
        "#\(progression.id) / L\(progression.itemLevel) / \(gearType.sourceTitle) / 0 精确记录"
    }

    var nextEvidence: String {
        "补该基础进度下逐稀有度变体 ID、词缀池、属性范围、掉落权重和图标共享规则"
    }

    var boundary: String {
        "基础进度只证明来源 ID、等级、名称和源图标；不扩展为装备记录、词缀、掉落权重或新图标"
    }
}

enum ExactItemRecordGapMetrics {
    static let noExactRecordBoundaryText = "未取得逐件词缀/稀有度记录"
    static let progressionBoundaryText = "基础进度图标不等于完整物品变体"
    static let statRollBoundaryText = "属性 rolls/掉落权重待核对"
    static let typePageBoundaryText = "类型页只证明聚合数量/稀有度分布/基础等级进度"
    static let missingEvidenceBoundaryText = "证据清单只定义接入门槛，不生成装备记录、词缀数值、掉落权重或新图标"
    static let evidenceQueueBoundaryText = "接入队列只排列复核顺序，不按类别、类型、基础图标或稀有度分布生成装备记录；不生成装备记录、词缀、掉落权重或新图标"
    static let largestMissingTypeBoundaryText = "最大类型缺口只按当前类型页聚合数量排序，用于安排复核优先级；不按最大缺口批量生成，也不生成装备记录、词缀、掉落权重或新图标"

    static let exactRecordCount = 0

    static var aggregateEntryCount: Int {
        SourceItemCatalog.totalGearEntryCount
    }

    static var baseProgressionCount: Int {
        SourceItemCatalog.totalGearLevelProgressionCount
    }

    static var missingRecordCount: Int {
        aggregateEntryCount - exactRecordCount
    }

    static var sourceGearTypeCount: Int {
        SourceItemCatalog.allGearTypes.count
    }

    static var coverageText: String {
        "\(exactRecordCount)/\(aggregateEntryCount)"
    }

    static var sourceProgressionCoverageText: String {
        "\(baseProgressionCount)/\(SourceItemCatalog.expectedGearLevelProgressionCount)"
    }

    static var missingEvidenceRows: [ExactItemMissingEvidenceRowModel] {
        [
            ExactItemMissingEvidenceRowModel(
                key: "variant-id",
                title: "逐件变体 ID",
                currentEvidence: "20 类型页 / 396 基础进度",
                missingEvidence: "逐稀有度/逐词缀的 5,760 行记录",
                requiredProof: "来源行需能唯一定位每个装备变体",
                affectedRecordCount: missingRecordCount
            ),
            ExactItemMissingEvidenceRowModel(
                key: "affix-roll",
                title: "属性与词缀 rolls",
                currentEvidence: "类型页稀有度计数",
                missingEvidence: "主属性、副属性、词缀池、roll 范围",
                requiredProof: "可复算装备面板数值的原始表",
                affectedRecordCount: missingRecordCount
            ),
            ExactItemMissingEvidenceRowModel(
                key: "drop-weight",
                title: "掉落池与权重",
                currentEvidence: "59 行箱子源表 / 3 箱子族",
                missingEvidence: "关卡/箱子/稀有度到具体装备的权重",
                requiredProof: "逐来源掉落表或可交叉验证概率表",
                affectedRecordCount: missingRecordCount
            ),
            ExactItemMissingEvidenceRowModel(
                key: "icon-variant",
                title: "图标变体证据",
                currentEvidence: "396 个基础进度 source_gear 图标",
                missingEvidence: "逐变体图标差异或共享图标规则",
                requiredProof: "证明 5,760 记录如何映射到已提取图标",
                affectedRecordCount: missingRecordCount
            ),
            ExactItemMissingEvidenceRowModel(
                key: "provenance",
                title: "来源交叉证明",
                currentEvidence: "同一 Wiki 源族聚合页",
                missingEvidence: "官方或第二独立来源核对",
                requiredProof: "能排除聚合页解析误差的独立证据",
                affectedRecordCount: missingRecordCount
            )
        ]
    }

    static var categoryEvidenceQueueRows: [ExactItemRecordCategoryEvidenceQueueRowModel] {
        categoryRows.map { row in
            ExactItemRecordCategoryEvidenceQueueRowModel(row: row)
        }
    }

    static var typeEvidenceQueueRows: [ExactItemRecordTypeEvidenceQueueRowModel] {
        typeRows.map { row in
            ExactItemRecordTypeEvidenceQueueRowModel(row: row)
        }
    }

    static var largestMissingTypeEvidenceRows: [ExactItemRecordTypeEvidenceQueueRowModel] {
        let rows = typeEvidenceQueueRows
        guard let largestMissingRecordCount = rows.map(\.row.missingRecordCount).max() else {
            return []
        }
        return rows
            .filter { $0.row.missingRecordCount == largestMissingRecordCount }
            .sorted { lhs, rhs in
                let lhsIndex = EquipmentType.allCases.firstIndex(of: lhs.row.gearType.equipmentType) ?? Int.max
                let rhsIndex = EquipmentType.allCases.firstIndex(of: rhs.row.gearType.equipmentType) ?? Int.max
                return lhsIndex < rhsIndex
            }
    }

    static var rarityEvidenceQueueRows: [ExactItemRecordRarityEvidenceQueueRowModel] {
        Rarity.allCases.map { rarity in
            ExactItemRecordRarityEvidenceQueueRowModel(
                rarity: rarity,
                aggregateEntryCount: SourceItemCatalog.aggregateRarityCounts[rarity] ?? 0,
                typeCount: SourceItemCatalog.allGearTypes.filter { $0.rarityCount(for: rarity) > 0 }.count,
                exactRecordCount: exactRecordCount
            )
        }
    }

    static var categoryRarityEvidenceQueueRows: [ExactItemRecordCategoryRarityEvidenceQueueRowModel] {
        EquipmentCategory.allCases.flatMap { category in
            let entries = SourceItemCatalog.allGearTypes.filter { $0.equipmentType.category == category }
            return Rarity.allCases.map { rarity in
                ExactItemRecordCategoryRarityEvidenceQueueRowModel(
                    category: category,
                    rarity: rarity,
                    aggregateEntryCount: entries.reduce(0) { $0 + $1.rarityCount(for: rarity) },
                    typeCount: entries.filter { $0.rarityCount(for: rarity) > 0 }.count,
                    exactRecordCount: exactRecordCount
                )
            }
        }
    }

    static var progressionEvidenceQueueRows: [ExactItemRecordProgressionEvidenceQueueRowModel] {
        typeRows.flatMap { row in
            row.gearType.progressions.map { progression in
                ExactItemRecordProgressionEvidenceQueueRowModel(
                    gearType: row.gearType,
                    progression: progression
                )
            }
        }
    }

    static var categoryEvidenceQueueCount: Int {
        categoryEvidenceQueueRows.count
    }

    static var typeEvidenceQueueCount: Int {
        typeEvidenceQueueRows.count
    }

    static var largestMissingTypeEvidenceCount: Int {
        largestMissingTypeEvidenceRows.count
    }

    static var largestMissingTypeMissingRecordCount: Int {
        largestMissingTypeEvidenceRows.first?.row.missingRecordCount ?? 0
    }

    static var rarityEvidenceQueueCount: Int {
        rarityEvidenceQueueRows.count
    }

    static var categoryRarityEvidenceQueueCount: Int {
        categoryRarityEvidenceQueueRows.count
    }

    static var progressionEvidenceQueueCount: Int {
        progressionEvidenceQueueRows.count
    }

    static var evidenceQueueCoverageCount: Int {
        categoryEvidenceQueueRows.reduce(0) { $0 + $1.row.aggregateEntryCount }
    }

    static var rarityEvidenceQueueCoverageCount: Int {
        rarityEvidenceQueueRows.reduce(0) { $0 + $1.aggregateEntryCount }
    }

    static var categoryRarityEvidenceQueueCoverageCount: Int {
        categoryRarityEvidenceQueueRows.reduce(0) { $0 + $1.aggregateEntryCount }
    }

    static var progressionEvidenceQueueCoverageCount: Int {
        progressionEvidenceQueueRows.count
    }

    static var largestMissingTypeEvidenceCoverageCount: Int {
        largestMissingTypeEvidenceRows.reduce(0) { $0 + $1.row.missingRecordCount }
    }

    static var largestMissingTypeCategorySummaryText: String {
        let categoryCounts = Dictionary(grouping: largestMissingTypeEvidenceRows) { row in
            row.row.category
        }.mapValues(\.count)
        return EquipmentCategory.allCases.compactMap { category in
            guard let count = categoryCounts[category], count > 0 else { return nil }
            return "\(category.rawValue) \(count)"
        }
        .joined(separator: " / ")
    }

    static var categoryRows: [ExactItemRecordGapCategoryRowModel] {
        EquipmentCategory.allCases.map { category in
            let entries = SourceItemCatalog.allGearTypes.filter { $0.equipmentType.category == category }
            return ExactItemRecordGapCategoryRowModel(
                category: category,
                typeCount: entries.count,
                aggregateEntryCount: entries.reduce(0) { $0 + $1.gearEntryCount },
                baseProgressionCount: entries.reduce(0) { $0 + $1.progressions.count },
                exactRecordCount: 0
            )
        }
    }

    static var typeRows: [ExactItemRecordGapTypeRowModel] {
        EquipmentType.allCases.compactMap { equipmentType in
            guard let gearType = SourceItemCatalog.byType[equipmentType] else { return nil }
            return ExactItemRecordGapTypeRowModel(
                gearType: gearType,
                exactRecordCount: exactRecordCount
            )
        }
    }

    static func row(category: EquipmentCategory) -> ExactItemRecordGapCategoryRowModel? {
        categoryRows.first { $0.category == category }
    }

    static func row(equipmentType: EquipmentType) -> ExactItemRecordGapTypeRowModel? {
        typeRows.first { $0.gearType.equipmentType == equipmentType }
    }
}

enum SourceCraftingRuleMetrics {
    static let unknownSynthesisProbabilityText = "完整概率/失败/跳阶表待核对"
    static let unknownItemLevelDowngradeText = "等级降级公式待核对"
    static let unknownSynthesisLevelCostText = "合成等级成本待核对"
    static let unknownCubeLevelRewardText = "Cube 等级/奖励公式待核对"

    static var rarityCount: Int {
        Rarity.allCases.count
    }

    static var synthesisInputCount: Int {
        Rarity.synthesisInputCount
    }

    static var synthesisModeledTransitionCount: Int {
        Rarity.allCases.filter { $0.synthesisOutputRarity != nil }.count
    }

    static var cubeXPTableCount: Int {
        Rarity.allCases.filter { $0.cubeExperience > 0 }.count
    }

    static var alchemyGoldTableCount: Int {
        Rarity.allCases.filter { $0.alchemyGoldValue > 0 }.count
    }

    static var tableCoverageText: String {
        "\(cubeXPTableCount)/\(alchemyGoldTableCount)"
    }

    static var cubeRewardRuneCoverageText: String {
        "\(RuneTree.cubeXPBoostNodes.count)/\(RuneTree.alchemyGoldBoostNodes.count)"
    }

    static var cubeRewardBonusPerNodeText: String {
        "\(Int((RuneTree.cubeRewardMultiplierBonus * 100).rounded()))%"
    }

    static var cubeRewardMaximumSideBonusText: String {
        "\(Int((RuneTree.cubeRewardMultiplierBonus * Double(RuneTree.cubeXPBoostNodes.count) * 100).rounded()))%"
    }

    static var cubeRewardRuneBoundaryText: String {
        "本地仅把 \(RuneTree.cubeXPBoostNodes.count) 个 Forging/Cube XP 节点和 \(RuneTree.alchemyGoldBoostNodes.count) 个 Alchemy Gold 节点接为每层 \(cubeRewardBonusPerNodeText) 的奖励倍率脚手架；原版成本、Cube 等级奖励和炼金经济曲线仍待核对"
    }

    static var synthesisSkipExamples: [SourceSynthesisSkipExample] {
        Rarity.sourceSynthesisSkipExamples
    }
}

private struct SupportFormulaReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "公式项",
                    value: "\(SupportFormulaReviewMetrics.rowCount)"
                )
                SourceRuneSummaryPill(
                    label: "样本等级",
                    value: "Lv.\(SupportFormulaReviewMetrics.sampleHeroLevel)"
                )
                SourceRuneSummaryPill(
                    label: "攻击标量",
                    value: "\(Int((SupportFormulaReviewMetrics.supportAttackScalar * 100).rounded()))%"
                )
                SourceRuneSummaryPill(
                    label: "原版独立公式",
                    value: "待核对"
                )
            }

            VStack(alignment: .leading, spacing: 5) {
                ForEach(SupportFormulaReviewMetrics.rows) { row in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.title)
                            .font(.system(size: 10, weight: .semibold))
                        Text(row.localFormula)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(row.boundary)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 2)
                }
            }

            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "当前运行时公式",
                detail: "\(SupportFormulaReviewMetrics.localFormulaBoundaryText)，攻击、生命、护甲读取主角等级；速度读取基础 SPD 和全英雄移速。"
            )
            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "符文加成范围",
                detail: "\(SupportFormulaReviewMetrics.runeBoundaryText)：攻击、护甲、移速会读取当前已建模的全英雄 Rune 加成。"
            )
            OriginalFidelityBoundaryRow(
                status: .gap,
                title: "原版公式缺口",
                detail: "\(SupportFormulaReviewMetrics.independentLevelBoundaryText)，支援独立等级、装备、技能等级和原版成长曲线仍未取得足够证据。"
            )
            OriginalFidelityBoundaryRow(
                status: .gap,
                title: "适用边界",
                detail: SupportFormulaReviewMetrics.runtimeScopeBoundaryText
            )
        }
    }
}

struct OriginalFidelityBoundaryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "技能运行",
                    value: OriginalFidelityBoundaryMetrics.runtimeSkillCoverageText
                )
                SourceRuneSummaryPill(
                    label: "符文源表",
                    value: OriginalFidelityBoundaryMetrics.sourceRuneCoverageText
                )
                SourceRuneSummaryPill(
                    label: "装备精确",
                    value: OriginalFidelityBoundaryMetrics.exactItemRecordCoverageText
                )
                SourceRuneSummaryPill(
                    label: "基础图标",
                    value: OriginalFidelityBoundaryMetrics.sourceGearProgressionCoverageText
                )
                SourceRuneSummaryPill(
                    label: "战斗英雄",
                    value: OriginalFidelityBoundaryMetrics.battleHeroSpriteCoverageText
                )
                SourceRuneSummaryPill(
                    label: "怪物数值",
                    value: OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseCoverageText
                )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("剩余硬缺口")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)

                ForEach(OriginalFidelityBoundaryMetrics.hardGapRows) { row in
                    OriginalFidelityBoundaryRow(
                        status: .gap,
                        title: row.title,
                        detail: "\(row.currentEvidence)；需要：\(row.requiredProof)。界限：\(row.boundary)。"
                    )
                }
            }

            OriginalFidelityBoundaryRow(
                status: .covered,
                title: "已核对源数据",
                detail: "技能 106、符文 197、关卡 120、怪物数值 \(OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseCoverageText)、装备聚合 5,760 已进入本地复核表。"
            )
            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "运行时技能边界",
                detail: "\(OriginalFidelityBoundaryMetrics.runtimeSkillCoverageText) 源技能已接入运行时；其余仍只作数据或视觉复核。"
            )
            OriginalFidelityBoundaryRow(
                status: .gap,
                title: "待接入技能边界",
                detail: OriginalFidelityBoundaryMetrics.pendingSkillRuntimeBoundaryText
            )
            OriginalFidelityBoundaryRow(
                status: .gap,
                title: "技能特效边界",
                detail: OriginalFidelityBoundaryMetrics.skillEffectBoundaryText
            )
            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "符文成本边界",
                detail: "已核对金币成本 \(OriginalFidelityBoundaryMetrics.verifiedRuneCostCount) 个，成本待核对 \(OriginalFidelityBoundaryMetrics.unverifiedRuneCostCount) 个，其中约值 \(OriginalFidelityBoundaryMetrics.approximateRuneCostCount) 个。"
            )
            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "背包扩容边界",
                detail: OriginalFidelityBoundaryMetrics.inventoryExpansionBoundaryText
            )
            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "仓库页容量边界",
                detail: OriginalFidelityBoundaryMetrics.stashPageBoundaryText
            )
            OriginalFidelityBoundaryRow(
                status: .gap,
                title: "装备记录边界",
                detail: "\(OriginalFidelityBoundaryMetrics.exactItemRecordCoverageText) 精确词缀/稀有度物品记录；当前只使用聚合表与 \(OriginalFidelityBoundaryMetrics.sourceGearProgressionCoverageText) 基础进度图标。"
            )
            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "被动技能边界",
                detail: OriginalFidelityBoundaryMetrics.passiveSkillBoundaryText
            )
            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "战斗英雄美术边界",
                detail: "\(OriginalFidelityBoundaryMetrics.battleHeroSpriteCoverageText) 战斗英雄贴图映射，\(OriginalFidelityBoundaryMetrics.battleHeroSourceSpriteCoverageText) 官方英雄来源图；\(OriginalFidelityBoundaryMetrics.battleHeroSpriteBoundaryText)。"
            )
            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "怪物数值边界",
                detail: OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseBoundaryText
            )
            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "怪物美术边界",
                detail: "\(OriginalFidelityBoundaryMetrics.stageMonsterArtCoverageText) 源表怪物名已有当前战斗美术映射，仍有 \(OriginalFidelityBoundaryMetrics.stageMonsterSourceRosterArtGapCount) 个源表怪物缺少关卡/美术/运行时证据；\(OriginalFidelityBoundaryMetrics.stageMonsterArtBoundaryText)。"
            )
            OriginalFidelityBoundaryRow(
                status: .gap,
                title: "本地替代边界",
                detail: "战斗动效和音效是可审计的本地替代效果，不可替代为原版逐帧动画或原声音效结论。"
            )
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct SourceAudioSFXEvidenceReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "Trailer",
                    value: "\(SourceAudioSFXEvidenceReviewMetrics.steamTrailerDurationSeconds)s"
                )
                SourceRuneSummaryPill(
                    label: "响度",
                    value: SourceAudioSFXEvidenceReviewMetrics.steamTrailerIntegratedLoudnessLUFS
                )
                SourceRuneSummaryPill(
                    label: "本地 SFX",
                    value: "\(SourceAudioSFXEvidenceReviewMetrics.localSFXEventCount)"
                )
                SourceRuneSummaryPill(
                    label: "官方单事件",
                    value: "\(SourceAudioSFXEvidenceReviewMetrics.originalIsolatedSFXCount)"
                )
                SourceRuneSummaryPill(
                    label: "SFX 门槛",
                    value: "\(SourceAudioSFXEvidenceReviewMetrics.eventGateCount)"
                )
            }

            VStack(alignment: .leading, spacing: 5) {
                ForEach(SourceAudioSFXEvidenceReviewMetrics.rows) { row in
                    SourceAudioSFXEvidenceRow(row: row)
                }
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceAudioSFXEvidenceReviewMetrics.eventGateRows) { row in
                        SourceAudioSFXEventGateRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "原版单事件 SFX 接入门槛",
                    value: "\(SourceAudioSFXEvidenceReviewMetrics.eventGateCount) 项 / \(SourceAudioSFXEvidenceReviewMetrics.eventGateMissingCount) 缺证"
                )
            }

            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "Steam 音频基线",
                detail: "\(SourceAudioSFXEvidenceReviewMetrics.steamTrailerFormatText)，\(SourceAudioSFXEvidenceReviewMetrics.steamTrailerIntegratedLoudnessLUFS)，\(SourceAudioSFXEvidenceReviewMetrics.sourceBoundaryText)"
            )
            OriginalFidelityBoundaryRow(
                status: .gap,
                title: "原版 SFX 缺口",
                detail: SourceAudioSFXEvidenceReviewMetrics.localBoundaryText
            )
        }
    }
}

private struct SourceAudioSFXEventGateRow: View {
    let row: SourceAudioSFXEventGateRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 8, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    Text(row.key)
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.50)
                }

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("需：\(row.requiredProof)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "basic-combat-hit":
            return "burst.fill"
        case "skill-cast-release":
            return "wand.and.stars"
        case "projectile-impact":
            return "scope"
        case "buff-status-loop":
            return "waveform.path.ecg"
        case "loot-inventory-ui":
            return "shippingbox.fill"
        case "mix-throttle-randomization":
            return "slider.horizontal.3"
        case "package-provenance":
            return "checkmark.seal.fill"
        default:
            return "speaker.wave.2.fill"
        }
    }
}

private struct SourceAudioSFXEvidenceRow: View {
    let row: SourceAudioSFXEvidenceRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(iconColor)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    Text(row.key)
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.52)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text(row.boundary)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("补：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "steam-trailer-baseline", "steam-loudness-envelope":
            return "waveform"
        case "local-sfx-manifest":
            return "doc.text.magnifyingglass"
        case "runtime-routing":
            return "point.topleft.down.curvedto.point.bottomright.up"
        case "package-audit":
            return "shippingbox.fill"
        case "isolated-original-gap":
            return "questionmark.diamond.fill"
        default:
            return "speaker.wave.2.fill"
        }
    }

    private var iconColor: Color {
        row.key == "isolated-original-gap" ? .secondary : .orange
    }
}

private struct SourceBattleAnimationEvidenceReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "官方媒体",
                    value: SourceBattleAnimationEvidenceReviewMetrics.officialVideoSizeText
                )
                SourceRuneSummaryPill(
                    label: "帧率",
                    value: "\(SourceBattleAnimationEvidenceReviewMetrics.officialFPS)fps"
                )
                SourceRuneSummaryPill(
                    label: "运动像素",
                    value: SourceBattleAnimationEvidenceReviewMetrics.officialMotionPixels.formatted()
                )
                SourceRuneSummaryPill(
                    label: "本地渲染",
                    value: SourceBattleAnimationEvidenceReviewMetrics.localRenderSizeText
                )
                SourceRuneSummaryPill(
                    label: "Battle tab",
                    value: SourceBattleAnimationEvidenceReviewMetrics.localBattleTabRenderSizeText
                )
                SourceRuneSummaryPill(
                    label: "原版帧",
                    value: "\(SourceBattleAnimationEvidenceReviewMetrics.exactOriginalActionFrameCount)"
                )
                SourceRuneSummaryPill(
                    label: "动作门槛",
                    value: "\(SourceBattleAnimationEvidenceReviewMetrics.actionFrameGateCount)"
                )
            }

            VStack(alignment: .leading, spacing: 5) {
                ForEach(SourceBattleAnimationEvidenceReviewMetrics.rows) { row in
                    SourceBattleAnimationEvidenceRow(row: row)
                }
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceBattleAnimationEvidenceReviewMetrics.motionSampleRows) { row in
                        SourceBattleAnimationMotionSampleRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "官方 frame 0->8 运动采样明细",
                    value: "\(SourceBattleAnimationEvidenceReviewMetrics.motionSampleRowCount) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceBattleAnimationEvidenceReviewMetrics.actionFrameGateRows) { row in
                        SourceBattleAnimationActionFrameGateRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "原版动作帧接入门槛",
                    value: "\(SourceBattleAnimationEvidenceReviewMetrics.actionFrameGateCount) 项 / \(SourceBattleAnimationEvidenceReviewMetrics.actionFrameGateMissingCount) 缺证"
                )
            }

            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "官方媒体运动",
                detail: "\(SourceBattleAnimationEvidenceReviewMetrics.officialVideoSizeText)，\(SourceBattleAnimationEvidenceReviewMetrics.officialFPS)fps，frame 0->8 \(SourceBattleAnimationEvidenceReviewMetrics.officialMotionSampleText) 采样 \(SourceBattleAnimationEvidenceReviewMetrics.officialMotionPixels.formatted()) px；\(SourceBattleAnimationEvidenceReviewMetrics.sourceBoundaryText)"
            )
            OriginalFidelityBoundaryRow(
                status: .gap,
                title: "关键帧缺口",
                detail: SourceBattleAnimationEvidenceReviewMetrics.keyframeGapBoundaryText
            )
        }
    }
}

private struct SourceBattleAnimationActionFrameGateRow: View {
    let row: SourceBattleAnimationActionFrameGateRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 8, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    Text(row.key)
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.50)
                }

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("需：\(row.requiredProof)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "hero-idle-move":
            return "figure.walk"
        case "hero-attack-cast":
            return "bolt.fill"
        case "hero-hit-death":
            return "heart.slash.fill"
        case "support-party":
            return "person.3.fill"
        case "monster-idle-move":
            return "eye.fill"
        case "monster-attack-hit-death":
            return "burst.fill"
        case "projectile-impact-status":
            return "sparkles"
        case "timing-audio-sync":
            return "metronome.fill"
        default:
            return "film.stack"
        }
    }
}

private struct SourceBattleAnimationMotionSampleRow: View {
    let row: SourceBattleAnimationMotionSampleRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 8, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    Text(row.key)
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.52)
                }

                Text(row.value)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text(row.boundary)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        row.key == "frame-pair" ? "film.stack" : "waveform.path.ecg.rectangle"
    }
}

private struct SourceBattleAnimationEvidenceRow: View {
    let row: SourceBattleAnimationEvidenceRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(iconColor)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    Text(row.key)
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.52)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text(row.boundary)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("补：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "official-media-baseline":
            return "film.stack.fill"
        case "official-motion-sample":
            return "figure.run.circle.fill"
        case "local-deterministic-render":
            return "camera.metering.matrix"
        case "fixture-coverage":
            return "checklist"
        case "layout-translation":
            return "rectangle.resize"
        case "exact-keyframe-gap":
            return "questionmark.diamond.fill"
        default:
            return "film.fill"
        }
    }

    private var iconColor: Color {
        row.key == "exact-keyframe-gap" ? .secondary : .orange
    }
}

private enum OriginalFidelityBoundaryStatus {
    case covered
    case partial
    case gap

    var title: String {
        switch self {
        case .covered:
            return "已核对"
        case .partial:
            return "部分"
        case .gap:
            return "缺口"
        }
    }

    var systemImage: String {
        switch self {
        case .covered:
            return "checkmark.seal.fill"
        case .partial:
            return "exclamationmark.triangle.fill"
        case .gap:
            return "questionmark.diamond.fill"
        }
    }

    var color: Color {
        switch self {
        case .covered:
            return .green
        case .partial:
            return .orange
        case .gap:
            return .secondary
        }
    }
}

private struct OriginalFidelityBoundaryRow: View {
    let status: OriginalFidelityBoundaryStatus
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: status.systemImage)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(status.color)
                .frame(width: 14, height: 14)
                .accessibilityLabel(status.title)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                Text(detail)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct SourceCraftingRuleReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "稀有度",
                    value: "\(SourceCraftingRuleMetrics.rarityCount)"
                )
                SourceRuneSummaryPill(
                    label: "合成输入",
                    value: "\(SourceCraftingRuleMetrics.synthesisInputCount)"
                )
                SourceRuneSummaryPill(
                    label: "确定转阶",
                    value: "\(SourceCraftingRuleMetrics.synthesisModeledTransitionCount)"
                )
                SourceRuneSummaryPill(
                    label: "Cube/炼金",
                    value: SourceCraftingRuleMetrics.tableCoverageText
                )
                SourceRuneSummaryPill(
                    label: "奖励符文",
                    value: SourceCraftingRuleMetrics.cubeRewardRuneCoverageText
                )
            }

            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "运行时合成",
                detail: "当前运行时只实现 \(Rarity.synthesisInputCount) 件同稀有度物品确定转为下一稀有度；跳阶、失败和降级未作为概率系统实现。"
            )
            OriginalFidelityBoundaryRow(
                status: .partial,
                title: "Cube 与炼金",
                detail: "Cube 只累计已核对的稀有度 XP；炼金只使用已核对的稀有度金币表并叠加本地符文倍率。"
            )
            OriginalFidelityBoundaryRow(
                status: .gap,
                title: "Cube/炼金符文边界",
                detail: "\(SourceCraftingRuleMetrics.cubeRewardRuneBoundaryText)；当前单侧满层本地上限 +\(SourceCraftingRuleMetrics.cubeRewardMaximumSideBonusText)。"
            )
            OriginalFidelityBoundaryRow(
                status: .gap,
                title: "待核对边界",
                detail: "\(SourceCraftingRuleMetrics.unknownSynthesisProbabilityText)、\(SourceCraftingRuleMetrics.unknownItemLevelDowngradeText)、\(SourceCraftingRuleMetrics.unknownSynthesisLevelCostText)、\(SourceCraftingRuleMetrics.unknownCubeLevelRewardText)。"
            )

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Rarity.allCases, id: \.self) { rarity in
                        SourceCraftingRarityRuleRow(rarity: rarity)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(title: "稀有度规则表", value: "\(Rarity.allCases.count) 行")
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceCraftingRuleMetrics.synthesisSkipExamples) { example in
                        SourceSynthesisSkipExampleRow(example: example)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "跳阶示例",
                    value: "\(SourceCraftingRuleMetrics.synthesisSkipExamples.count) 条"
                )
            }
        }
    }
}

private struct SourceCraftingRarityRuleRow: View {
    let rarity: Rarity

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(Color(hex: rarity.color))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 1) {
                Text(rarity.rawValue)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)

                Text("D/E/I \(rarity.slotSummary) · Cube +\(rarity.cubeExperience) · 炼金 +\(rarity.alchemyGoldValue)G")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Spacer(minLength: 4)

            Text(synthesisText)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 2)
    }

    private var synthesisText: String {
        guard let output = rarity.synthesisOutputRarity else {
            return "合成: 无"
        }
        return "合成: \(output.rawValue)"
    }
}

private struct SourceSynthesisSkipExampleRow: View {
    let example: SourceSynthesisSkipExample

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 14)

            Text("\(example.from.rawValue) -> \(example.to.rawValue)")
                .font(.system(size: 9, weight: .semibold))

            Spacer(minLength: 4)

            Text(example.chanceText)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

private struct SourceItemDatabaseView: View {
    private let materialCategoryCount = SourceItemCatalog.materialCountsByCategory.count
    private let chestIconFamilyCount = Set(SourceItemCatalog.allStageChests.map(\.iconName)).count

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "装备类",
                    value: "\(SourceItemCatalog.allGearTypes.count)"
                )
                SourceRuneSummaryPill(
                    label: "聚合装备",
                    value: "\(SourceItemCatalog.totalGearEntryCount)"
                )
                SourceRuneSummaryPill(
                    label: "基础进度",
                    value: "\(SourceItemCatalog.totalGearLevelProgressionCount)"
                )
                SourceRuneSummaryPill(
                    label: "精确记录",
                    value: OriginalFidelityBoundaryMetrics.exactItemRecordCoverageText
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "材料",
                    value: "\(SourceItemCatalog.allMaterials.count)"
                )
                SourceRuneSummaryPill(
                    label: "材料类",
                    value: "\(materialCategoryCount)"
                )
                SourceRuneSummaryPill(
                    label: "箱子",
                    value: "\(SourceItemCatalog.allStageChests.count)"
                )
                SourceRuneSummaryPill(
                    label: "箱子图标",
                    value: "\(chestIconFamilyCount)"
                )
            }

            Text("该表只展示页面可核对的聚合装备、基础进度、材料和箱子，不声明完整词缀/稀有度 5,760 物品记录。")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceItemCatalog.allGearTypes) { gearType in
                        SourceGearTypeSourceRow(gearType: gearType)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(title: "装备类型源表", value: "\(SourceItemCatalog.allGearTypes.count) 类")
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceItemCatalog.allMaterials) { material in
                        SourceMaterialSourceRow(material: material)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(title: "材料源表", value: "\(SourceItemCatalog.allMaterials.count) 行")
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceItemCatalog.allStageChests) { chest in
                        SourceStageChestSourceRow(chest: chest)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(title: "箱子源表", value: "\(SourceItemCatalog.allStageChests.count) 行")
            }
        }
    }
}

private struct ExactItemRecordGapView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "聚合装备",
                    value: "\(ExactItemRecordGapMetrics.aggregateEntryCount)"
                )
                SourceRuneSummaryPill(
                    label: "基础图标",
                    value: "\(ExactItemRecordGapMetrics.baseProgressionCount)"
                )
                SourceRuneSummaryPill(
                    label: "精确记录",
                    value: ExactItemRecordGapMetrics.coverageText
                )
                SourceRuneSummaryPill(
                    label: "缺口",
                    value: "\(ExactItemRecordGapMetrics.missingRecordCount)"
                )
                SourceRuneSummaryPill(
                    label: "类型明细",
                    value: "\(ExactItemRecordGapMetrics.typeRows.count)"
                )
                SourceRuneSummaryPill(
                    label: "证据项",
                    value: "\(ExactItemRecordGapMetrics.missingEvidenceRows.count)"
                )
                SourceRuneSummaryPill(
                    label: "类别队列",
                    value: "\(ExactItemRecordGapMetrics.categoryEvidenceQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "稀有队列",
                    value: "\(ExactItemRecordGapMetrics.rarityEvidenceQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "矩阵队列",
                    value: "\(ExactItemRecordGapMetrics.categoryRarityEvidenceQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "基础队列",
                    value: "\(ExactItemRecordGapMetrics.progressionEvidenceQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "类型队列",
                    value: "\(ExactItemRecordGapMetrics.typeEvidenceQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "最大类型",
                    value: "\(ExactItemRecordGapMetrics.largestMissingTypeEvidenceCount)"
                )
            }

            Text("\(ExactItemRecordGapMetrics.noExactRecordBoundaryText)；\(ExactItemRecordGapMetrics.progressionBoundaryText)；\(ExactItemRecordGapMetrics.typePageBoundaryText)；\(ExactItemRecordGapMetrics.statRollBoundaryText)。")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(ExactItemRecordGapMetrics.missingEvidenceBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(ExactItemRecordGapMetrics.evidenceQueueBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(ExactItemRecordGapMetrics.largestMissingTypeBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 5) {
                ForEach(ExactItemRecordGapMetrics.categoryRows) { row in
                    ExactItemRecordGapCategoryRow(row: row)
                }
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(ExactItemRecordGapMetrics.categoryEvidenceQueueRows) { row in
                        ExactItemRecordCategoryEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "精确记录类别队列",
                    value: "\(ExactItemRecordGapMetrics.evidenceQueueCoverageCount) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(ExactItemRecordGapMetrics.rarityEvidenceQueueRows) { row in
                        ExactItemRecordRarityEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "精确记录稀有度队列",
                    value: "\(ExactItemRecordGapMetrics.rarityEvidenceQueueCoverageCount) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(ExactItemRecordGapMetrics.categoryRarityEvidenceQueueRows) { row in
                        ExactItemRecordCategoryRarityEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "精确记录类别稀有矩阵",
                    value: "\(ExactItemRecordGapMetrics.categoryRarityEvidenceQueueCoverageCount) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(ExactItemRecordGapMetrics.typeEvidenceQueueRows) { row in
                        ExactItemRecordTypeEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "精确记录类型队列",
                    value: "\(ExactItemRecordGapMetrics.typeEvidenceQueueCount) 类"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(ExactItemRecordGapMetrics.largestMissingTypeCategorySummaryText)；覆盖缺口 \(ExactItemRecordGapMetrics.largestMissingTypeEvidenceCoverageCount)")
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(ExactItemRecordGapMetrics.largestMissingTypeEvidenceRows) { row in
                        ExactItemRecordTypeEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "精确记录最大类型缺口",
                    value: "\(ExactItemRecordGapMetrics.largestMissingTypeEvidenceCoverageCount) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(ExactItemRecordGapMetrics.progressionEvidenceQueueRows) { row in
                        ExactItemRecordProgressionEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "精确记录基础进度队列",
                    value: "\(ExactItemRecordGapMetrics.progressionEvidenceQueueCoverageCount) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(ExactItemRecordGapMetrics.typeRows) { row in
                        ExactItemRecordGapTypeRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "装备类型缺口",
                    value: "\(ExactItemRecordGapMetrics.typeRows.count) 类"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(ExactItemRecordGapMetrics.missingEvidenceRows) { row in
                        ExactItemMissingEvidenceRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "精确记录接入门槛",
                    value: "\(ExactItemRecordGapMetrics.missingEvidenceRows.count) 项"
                )
            }
        }
    }
}

private struct ExactItemRecordGapCategoryRow: View {
    let row: ExactItemRecordGapCategoryRowModel

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(row.category.rawValue)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)

                Text("\(row.typeCount) 类 · 聚合 \(row.aggregateEntryCount) · 基础进度 \(row.baseProgressionCount)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(row.exactRecordCount)/\(row.aggregateEntryCount)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                Text("缺 \(row.missingRecordCount)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .frame(width: 82, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.category {
        case .weapon:
            return "sword"
        case .offhand:
            return "shield"
        case .armor:
            return "tshirt"
        case .accessory:
            return "circle.hexagonpath"
        }
    }
}

private struct ExactItemRecordGapTypeRow: View {
    let row: ExactItemRecordGapTypeRowModel

    var body: some View {
        HStack(spacing: 7) {
            PixelSprite(
                imageName: gearIconName,
                size: CGSize(width: 18, height: 18)
            )

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(row.gearType.equipmentType.localizedName)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                    Text(row.gearType.sourceTitle)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Text("聚合 \(row.aggregateEntryCount) · 基础 \(row.baseProgressionCount) · \(row.rarityDistributionText)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.50)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(row.exactRecordCount)/\(row.aggregateEntryCount)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                Text("缺 \(row.missingRecordCount)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .frame(width: 82, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    private var gearIconName: String {
        row.gearType.progressions.first?.iconName ?? GameArt.itemIconName(for: row.gearType.equipmentType)
    }
}

private struct ExactItemRecordCategoryEvidenceQueueRow: View {
    let row: ExactItemRecordCategoryEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(row.row.missingRecordCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.52)

                Text("下步：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.row.category {
        case .weapon:
            return "sword"
        case .offhand:
            return "shield"
        case .armor:
            return "tshirt"
        case .accessory:
            return "circle.hexagonpath"
        }
    }
}

private struct ExactItemRecordRarityEvidenceQueueRow: View {
    let row: ExactItemRecordRarityEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Circle()
                .fill(rarityColor)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(0.35), lineWidth: 0.5)
                )
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                    Text("\(row.missingRecordCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)

                Text("下步：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var rarityColor: Color {
        Color(hex: row.rarity.color)
    }
}

private struct ExactItemRecordCategoryRarityEvidenceQueueRow: View {
    let row: ExactItemRecordCategoryRarityEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: iconName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
                    .frame(width: 18, height: 18)
                Circle()
                    .fill(Color(hex: row.rarity.color))
                    .frame(width: 7, height: 7)
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.35), lineWidth: 0.5)
                    )
                    .offset(x: 2, y: 2)
            }
            .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                    Text("\(row.missingRecordCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)

                Text("下步：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.category {
        case .weapon:
            return "sword"
        case .offhand:
            return "shield"
        case .armor:
            return "tshirt"
        case .accessory:
            return "circle.hexagonpath"
        }
    }
}

private struct ExactItemRecordTypeEvidenceQueueRow: View {
    let row: ExactItemRecordTypeEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            PixelSprite(
                imageName: gearIconName,
                size: CGSize(width: 18, height: 18)
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                    Text("\(row.row.missingRecordCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)

                Text("下步：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var gearIconName: String {
        row.row.gearType.progressions.first?.iconName ?? GameArt.itemIconName(for: row.row.gearType.equipmentType)
    }
}

private struct ExactItemRecordProgressionEvidenceQueueRow: View {
    let row: ExactItemRecordProgressionEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            PixelSprite(
                imageName: row.progression.iconName,
                size: CGSize(width: 18, height: 18)
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                    Text("#\(row.progression.id)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)

                Text("下步：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct ExactItemMissingEvidenceRow: View {
    let row: ExactItemMissingEvidenceRowModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.magnifyingglass")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
                    .frame(width: 16, height: 16)

                Text(row.title)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)

                Spacer(minLength: 4)

                Text("影响 \(row.affectedRecordCount)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }

            Text("已知：\(row.currentEvidence)")
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.50)

            Text("缺少：\(row.missingEvidence)")
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.48)

            Text("门槛：\(row.requiredProof)")
                .font(.system(size: 7, weight: .semibold))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.48)
        }
        .padding(.vertical, 2)
    }
}

private struct SourceItemDisclosureLabel: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
            Spacer()
            Text(value)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

private struct SourceGearTypeSourceRow: View {
    let gearType: SourceGearTypeEntry

    var body: some View {
        HStack(spacing: 7) {
            PixelSprite(
                imageName: gearIconName,
                size: CGSize(width: 18, height: 18)
            )

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(gearType.equipmentType.localizedName)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                    Text(gearType.sourceTitle)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Text(gearDetailText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(gearType.gearEntryCount)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                Text("\(gearType.levelStepCount) 档")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(width: 48, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    private var gearIconName: String {
        gearType.progressions.first?.iconName ?? GameArt.itemIconName(for: gearType.equipmentType)
    }

    private var gearDetailText: String {
        let levelRange = [gearType.progressions.first?.itemLevel, gearType.progressions.last?.itemLevel]
            .compactMap { $0 }
        let levelText: String
        if levelRange.count == 2 {
            levelText = "Lv.\(levelRange[0])-\(levelRange[1])"
        } else {
            levelText = "Lv.?"
        }
        let rarityText = Rarity.allCases
            .compactMap { rarity -> String? in
                let count = gearType.rarityCount(for: rarity)
                guard count > 0 else { return nil }
                return "\(rarity.rawValue)\(count)"
            }
            .prefix(4)
            .joined(separator: " ")
        let overflow = gearType.rarityCounts.count > 4 ? " +" : ""
        return "\(levelText) · \(gearType.progressions.count) 基础 · \(rarityText)\(overflow)"
    }
}

private struct SourceMaterialSourceRow: View {
    let material: SourceMaterialEntry

    var body: some View {
        HStack(spacing: 7) {
            PixelSprite(
                imageName: GameArt.itemIconName(for: material),
                size: CGSize(width: 18, height: 18)
            )

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(material.name)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text("#\(material.id)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Text("\(material.category.rawValue) · \(material.rarity.rawValue)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct SourceStageChestSourceRow: View {
    let chest: SourceStageChestEntry

    var body: some View {
        HStack(spacing: 7) {
            PixelSprite(
                imageName: GameArt.stageChestIconName(for: chest),
                size: CGSize(width: 18, height: 18)
            )

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(chest.name)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text("#\(chest.id)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Text("\(chest.rarity.rawValue) · \(chest.iconName)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct LocalPacingReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    SourceRuneSummaryPill(
                        label: "Tick",
                        value: formattedSeconds(GamePacing.runtimeTickInterval)
                    )
                    SourceRuneSummaryPill(
                        label: "战斗步进",
                        value: formattedSeconds(GamePacing.combatSimulationStep)
                    )
                    SourceRuneSummaryPill(
                        label: "模拟倍率",
                        value: "\(Int(GamePacing.combatDeltaMultiplier * 100))%"
                    )
                    SourceRuneSummaryPill(
                        label: "经验",
                        value: "\(Int(GamePacing.appliedXPMultiplier * 100))%"
                    )
                }

                HStack(spacing: 6) {
                    SourceRuneSummaryPill(
                        label: "阶段上限",
                        value: "+\(GamePacing.stageLevelBuffer)"
                    )
                    SourceRuneSummaryPill(
                        label: "基础下限",
                        value: formattedSeconds(GamePacing.minimumAttackInterval)
                    )
                    SourceRuneSummaryPill(
                        label: "增益下限",
                        value: formattedSeconds(GamePacing.minimumHastedAttackInterval)
                    )
                }
            }

            HStack {
                Text("每 tick 战斗推进")
                Spacer()
                Text(formattedSeconds(GamePacing.simulatedCombatDelta(for: GamePacing.runtimeTickInterval)))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("二周目等级加成")
                Spacer()
                Text("+\(GamePacing.playthroughLevelBonus) / 周目")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("正经验保底")
                Spacer()
                Text("\(GamePacing.pacedXP(from: 1)) XP")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Text("当前数值按原作每秒一个 tick 约束；每个运行 tick 只推进 1 秒战斗时间，高攻速也至少间隔 1 秒出手。XP 曲线和完整升级公式仍按未核对处理。")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func formattedSeconds(_ value: TimeInterval) -> String {
        String(format: "%.1fs", value)
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

struct LocalRuneCostReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "节点",
                    value: "\(LocalRuneCostReviewMetrics.rowCount)"
                )
                SourceRuneSummaryPill(
                    label: "已核对",
                    value: "\(LocalRuneCostReviewMetrics.verifiedCount)"
                )
                SourceRuneSummaryPill(
                    label: "约值",
                    value: "\(LocalRuneCostReviewMetrics.approximateCount)"
                )
                SourceRuneSummaryPill(
                    label: "约值来源",
                    value: "\(LocalRuneCostReviewMetrics.approximateSourceBackedCount)"
                )
                SourceRuneSummaryPill(
                    label: "约值证据",
                    value: "\(LocalRuneCostReviewMetrics.approximateEvidenceRowCount)"
                )
                SourceRuneSummaryPill(
                    label: "待核对",
                    value: "\(LocalRuneCostReviewMetrics.pendingCount)"
                )
                SourceRuneSummaryPill(
                    label: "缺口组",
                    value: "\(LocalRuneCostReviewMetrics.pendingGroupCount)"
                )
                SourceRuneSummaryPill(
                    label: "玩法分支",
                    value: "\(LocalRuneCostReviewMetrics.pendingBranchCount)"
                )
                SourceRuneSummaryPill(
                    label: "成本门槛",
                    value: "\(LocalRuneCostReviewMetrics.costEvidenceGateCount)"
                )
                SourceRuneSummaryPill(
                    label: "接入队列",
                    value: "\(LocalRuneCostReviewMetrics.pendingCostEvidenceQueueCount)"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "源ID",
                    value: "\(LocalRuneCostReviewMetrics.sourceBackedCount)/\(LocalRuneCostReviewMetrics.rowCount)"
                )
                SourceRuneSummaryPill(
                    label: "退款",
                    value: "\(LocalRuneCostReviewMetrics.verifiedGoldTotal.formatted())G"
                )
                SourceRuneSummaryPill(
                    label: "约值合计",
                    value: "\(LocalRuneCostReviewMetrics.approximateGoldTotal.formatted())G"
                )
                SourceRuneSummaryPill(
                    label: "队列覆盖",
                    value: "\(LocalRuneCostReviewMetrics.pendingCostEvidenceQueueCoverage)/\(LocalRuneCostReviewMetrics.pendingCount)"
                )
                SourceRuneSummaryPill(
                    label: "分支明细",
                    value: "\(LocalRuneCostReviewMetrics.pendingCostBranchEvidenceRowCount)"
                )
                SourceRuneSummaryPill(
                    label: "明细覆盖",
                    value: LocalRuneCostReviewMetrics.pendingCostBranchEvidenceCoverageText
                )
                SourceRuneSummaryPill(
                    label: "maxLevel",
                    value: "\(LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceCount)"
                )
                SourceRuneSummaryPill(
                    label: "maxLevel覆盖",
                    value: "\(LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceCoverage)/\(LocalRuneCostReviewMetrics.pendingCount)"
                )
                SourceRuneSummaryPill(
                    label: "等级图标桶",
                    value: "\(LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceIconBucketTotal)"
                )
            }

            Text("\(LocalRuneCostReviewMetrics.approximateBoundaryText)；\(LocalRuneCostReviewMetrics.pendingBoundaryText)；\(LocalRuneCostReviewMetrics.resetRefundBoundaryText)。")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(LocalRuneCostReviewMetrics.pendingGroupBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(LocalRuneCostReviewMetrics.pendingBranchBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(LocalRuneCostReviewMetrics.costEvidenceGateBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(LocalRuneCostReviewMetrics.pendingCostEvidenceQueueBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            if !LocalRuneCostReviewMetrics.approximateSourceEvidenceText.isEmpty {
                Text(LocalRuneCostReviewMetrics.approximateSourceEvidenceText)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(LocalRuneCostReviewMetrics.approximateEvidenceBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(LocalRuneCostReviewMetrics.approximateEvidenceRows) { row in
                        LocalRuneApproximateCostEvidenceRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text("约值成本证据")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                    Text("\(LocalRuneCostReviewMetrics.approximateEvidenceRowCount) 行")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(LocalRuneCostReviewMetrics.costEvidenceGateRows) { row in
                        LocalRuneCostEvidenceGateRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text("成本接入门槛")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                    Text("\(LocalRuneCostReviewMetrics.costEvidenceGateCount) 项")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(LocalRuneCostReviewMetrics.pendingCostEvidenceQueueRows) { row in
                        LocalRunePendingCostEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text("待核对成本接入队列")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                    Text("\(LocalRuneCostReviewMetrics.pendingCostEvidenceQueueCount) 队列 / \(LocalRuneCostReviewMetrics.pendingCostEvidenceQueueCoverage) 节点")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceRows) { row in
                        LocalRunePendingCostMaxLevelEvidenceRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text("待核价 maxLevel 队列")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                    Text("\(LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceCount) 桶 / \(LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceCoverage) 节点")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(LocalRuneCostReviewMetrics.pendingCostBranchEvidenceRows) { row in
                        LocalRunePendingCostBranchEvidenceRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text("待核价图标组逐项")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                    Text("\(LocalRuneCostReviewMetrics.pendingCostBranchEvidenceRowCount) 组 / \(LocalRuneCostReviewMetrics.pendingCostBranchEvidenceCoverage) 节点")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(LocalRuneCostReviewMetrics.pendingBranchRows) { branch in
                        LocalRunePendingCostBranchRow(branch: branch)
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text("待核对玩法分支")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                    Text("\(LocalRuneCostReviewMetrics.pendingBranchCount) 分支 / \(LocalRuneCostReviewMetrics.pendingCount) 节点")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(LocalRuneCostReviewMetrics.pendingGroups) { group in
                        LocalRunePendingCostGroupRow(group: group)
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text("待核对成本分组")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                    Text("\(LocalRuneCostReviewMetrics.pendingGroupCount) 组 / \(LocalRuneCostReviewMetrics.pendingCount) 节点")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(LocalRuneCostReviewMetrics.rows) { row in
                        LocalRuneCostReviewRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text("成本状态明细")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                    Text("\(LocalRuneCostReviewMetrics.verifiedCount)/\(LocalRuneCostReviewMetrics.rowCount)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

private struct LocalRuneApproximateCostEvidenceRow: View {
    let row: LocalRuneApproximateCostEvidenceRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            PixelSprite(
                imageName: iconName,
                size: CGSize(width: 20, height: 20)
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.sourceIDText)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                }

                Text(row.sourceNameText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("证：\(row.requiredProof)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        GameArt.sourceRuneIconName(forIconFamily: row.row.sourceNode?.iconName ?? "UnlockSkillSlotCount")
    }
}

private struct LocalRunePendingCostEvidenceQueueRow: View {
    let row: LocalRunePendingCostEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)

                    Text("\(row.branch.pendingCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("补：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(row.boundary)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.branch.key {
        case "chest":
            return "shippingbox.fill"
        case "inventory-storage":
            return "archivebox.fill"
        case "combat-reward":
            return "chart.bar.fill"
        case "hero-stat":
            return "bolt.fill"
        case "cube-alchemy":
            return "cube.fill"
        case "offline":
            return "moon.fill"
        case "stage-pacing":
            return "flag.fill"
        default:
            return "questionmark.circle"
        }
    }
}

private struct LocalRunePendingCostMaxLevelEvidenceRow: View {
    let row: LocalRunePendingCostMaxLevelEvidenceRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "number.square.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)

                    Text("\(row.pendingCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                if !row.sampleIconText.isEmpty {
                    Text(row.sampleIconText)
                        .font(.system(size: 7, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.46)
                }

                Text("补：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct LocalRunePendingCostBranchEvidenceRow: View {
    let row: LocalRunePendingCostBranchEvidenceRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            PixelSprite(
                imageName: GameArt.sourceRuneIconName(forIconFamily: row.group.iconName),
                size: CGSize(width: 20, height: 20)
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)

                    Text("\(row.group.pendingCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text(row.sourceNameText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("证：\(row.requiredProof)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct LocalRunePendingCostBranchRow: View {
    let branch: LocalRunePendingCostBranchRowModel

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(branch.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(branch.sampleSourceIDText)
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.48)
                }

                Text(branch.sampleIconText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(branch.pendingCount)")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundColor(.orange)
                Text("\(branch.groupCount) 组")
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch branch.key {
        case "chest":
            return "shippingbox.fill"
        case "inventory-storage":
            return "archivebox.fill"
        case "combat-reward":
            return "chart.bar.fill"
        case "hero-stat":
            return "bolt.fill"
        case "cube-alchemy":
            return "cube.fill"
        case "offline":
            return "moon.fill"
        case "stage-pacing":
            return "flag.fill"
        default:
            return "questionmark.circle"
        }
    }
}

private struct LocalRuneCostEvidenceGateRow: View {
    let row: LocalRuneCostEvidenceGateRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(row.affectedNodeCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("证：\(row.requiredProof)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "per-node-cost":
            return "number"
        case "branch-path-cost":
            return "link"
        case "reset-refund":
            return "arrow.counterclockwise.circle.fill"
        case "candidate-cross-source":
            return "checkmark.seal.fill"
        case "currency-point":
            return "creditcard.fill"
        case "stacking-cap":
            return "square.stack.3d.up.fill"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
}

private struct LocalRunePendingCostGroupRow: View {
    let group: LocalRunePendingCostGroupModel

    var body: some View {
        HStack(spacing: 8) {
            PixelSprite(
                imageName: GameArt.sourceRuneIconName(forIconFamily: group.iconName),
                size: CGSize(width: 22, height: 22)
            )

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(group.iconName)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)

                    Text(group.sampleSourceIDText)
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.48)
                }

                Text(group.sourceNameText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(group.pendingCount)")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundColor(.orange)
                Text("待核对")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 2)
    }
}

struct SourceRuneEvidenceReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "分层",
                    value: "\(SourceRuneEvidenceReviewMetrics.rowCount)"
                )
                SourceRuneSummaryPill(
                    label: "Wiki",
                    value: "\(SourceRuneEvidenceReviewMetrics.wikiLocaleCount)"
                )
                SourceRuneSummaryPill(
                    label: "外部",
                    value: "\(SourceRuneEvidenceReviewMetrics.independentSourceCount)"
                )
                SourceRuneSummaryPill(
                    label: "高置信",
                    value: "\(SourceRuneEvidenceReviewMetrics.highConfidenceRows)"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "候选队列",
                    value: "\(SourceRuneEvidenceReviewMetrics.candidateCostQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "候选节点",
                    value: "\(SourceRuneEvidenceReviewMetrics.candidateCostQueueCoverageCount)"
                )
                SourceRuneSummaryPill(
                    label: "候选总额",
                    value: SourceRuneEvidenceReviewMetrics.candidateCostQueueGoldText
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "总表覆盖",
                    value: SourceRuneEvidenceReviewMetrics.tbhCityCandidateCostTableCoverageText
                )
                SourceRuneSummaryPill(
                    label: "总表金币",
                    value: SourceRuneEvidenceReviewMetrics.tbhCityCandidateCostTableGoldText
                )
            }

            HStack {
                Text("来源范围")
                Spacer()
                Text(SourceRuneEvidenceReviewMetrics.sourceScopeText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)
            }

            HStack {
                Text("外部页面")
                Spacer()
                Text(SourceRuneEvidenceReviewMetrics.independentSourcesText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.40)
            }

            Text(SourceRuneEvidenceReviewMetrics.candidateCostSourceText)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(SourceRuneEvidenceReviewMetrics.candidateCostQueueBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(SourceRuneEvidenceReviewMetrics.fullCandidateCostBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(SourceRuneEvidenceReviewMetrics.fullCostTableBoundaryText)；\(SourceRuneEvidenceReviewMetrics.resetEconomyBoundaryText)。")
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(SourceRuneEvidenceReviewMetrics.candidateCostQueueRows) { row in
                        SourceRuneCandidateCostQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "候选成本队列",
                    value: "\(SourceRuneEvidenceReviewMetrics.candidateCostQueueCoverageCount)"
                )
            }

            VStack(alignment: .leading, spacing: 5) {
                ForEach(SourceRuneEvidenceReviewMetrics.rows) { row in
                    SourceRuneEvidenceReviewRow(row: row)
                }
            }
        }
    }
}

private struct SourceRuneCandidateCostQueueRow: View {
    let row: SourceRuneCandidateCostQueueRowModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.magnifyingglass")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
                    .frame(width: 16, height: 16)

                Text(row.title)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 4)

                Text(row.candidateGoldText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)

                Text("候选 \(row.affectedCandidateCount)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Text("证据：\(row.sourceEvidence)")
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.50)

            Text("缺少：\(row.missingEvidence)")
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("界限：\(row.boundary)")
                .font(.system(size: 7, weight: .semibold))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 2)
    }
}

private struct SourceRuneEvidenceReviewRow: View {
    let row: SourceRuneEvidenceReviewRowModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text(row.title)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(row.confidence)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(confidenceColor)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(confidenceColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Spacer(minLength: 6)
            }

            Text(row.evidence)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.52)

            Text(row.boundary)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 3)
    }

    private var confidenceColor: Color {
        switch row.confidence {
        case "高":
            return .green
        case "中":
            return .orange
        default:
            return .secondary
        }
    }
}

private struct LocalRuneCostReviewRow: View {
    let row: LocalRuneCostReviewRowModel

    var body: some View {
        HStack(spacing: 8) {
            PixelSprite(
                imageName: iconName,
                size: CGSize(width: 22, height: 22)
            )

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text("#\(row.sourceID)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }

                Text(sourceText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)

                if let approximateSourceText = row.approximateSourceText {
                    Text(approximateSourceText)
                        .font(.system(size: 7, weight: .medium, design: .monospaced))
                        .foregroundColor(row.status.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                }
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 1) {
                Text(row.costText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(row.status.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(row.status.rawValue)
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(row.status.color)
            }
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        if let sourceNode = row.sourceNode {
            return GameArt.sourceRuneIconName(for: sourceNode)
        }
        return GameArt.runeTreeIconName(for: row.node)
    }

    private var sourceText: String {
        guard let sourceNode = row.sourceNode else {
            return "源表缺失"
        }
        return "\(sourceNode.zhName) / \(sourceNode.enName) · \(sourceNode.iconName)"
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
        let pacedXPPreview = GamePacing.pacedXP(from: runtime.xpReward)
        return "\(runtime.goldReward)G/原始\(runtime.xpReward)XP/实得≈\(pacedXPPreview)XP · HP \(runtime.hp) · \(compositionText)"
    }
}

struct SourceMonsterUnmappedEvidenceGateRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let currentEvidence: String
    let missingEvidence: String
    let requiredProof: String
    let affectedMonsterCount: Int

    var id: String { key }
}

struct SourceMonsterUnmappedEvidenceQueueRowModel: Identifiable, Equatable {
    let monster: SourceMonsterDatabaseEntry

    var id: Int { monster.id }

    var title: String {
        "\(monster.id):\(monster.zhName)"
    }

    var currentEvidence: String {
        "HP \(monster.hp) / ATK \(monster.attack) / AS \(SourceMonsterDatabaseMetrics.decimalTextForRow(monster.attackSpeed)) / best \(monster.bestFarm) / \(sourceOnlySpriteEvidence) / \(sourcePageFieldEvidenceText) / \(sourceStageAppearanceEvidenceText) / \(bestFarmStageCompositionEvidence) / \(sourceSkillCandidateEvidence)"
    }

    var nextEvidence: String {
        if monster.bestFarm == "—" {
            return "先补关卡组成槽位，再补战斗锚点、技能归属、掉落和动作帧"
        }
        return "核对 best-farm 对应 stage code 是否证明出场，再补组成数量、战斗锚点、技能归属、掉落和动作帧"
    }

    var boundary: String {
        "不从源表数值、best-farm 文本、单张 sprite 或 ID 前缀推断关卡遭遇、技能归属、掉落或动作帧；\(sourceSkillCandidateBoundary)"
    }

    var sourceOnlySpriteEvidence: String {
        guard let resourceName = SourceMonsterDatabase.sourceOnlySpriteResourceName(for: monster) else {
            return "源表 sprite 未接入"
        }
        return "源表 sprite \(resourceName)"
    }

    var sourcePageFieldEvidence: SourceMonsterSourcePageFieldEvidenceRowModel? {
        SourceMonsterDatabaseMetrics.sourceOnlyPageFieldEvidenceRow(for: monster.id)
    }

    var sourcePageFieldEvidenceText: String {
        sourcePageFieldEvidence?.sourceFieldText ?? "怪物页字段未核对"
    }

    var bestFarmStageCode: String? {
        guard monster.bestFarm != "—",
              let code = monster.bestFarm
              .split(separator: "·", omittingEmptySubsequences: false)
              .first?
              .trimmingCharacters(in: .whitespacesAndNewlines),
              code.count == 4,
              code.allSatisfy(\.isNumber) else {
            return nil
        }
        return code
    }

    var bestFarmStageCompositionText: String {
        guard let code = bestFarmStageCode,
              let runtime = StageDefinition.runtimeData(sourceCode: code) else {
            return "无可核对 stage composition"
        }

        let entries = runtime.monsterComposition.map { spawn in
            "\(spawn.name):\(spawn.count)\(spawn.isStageLeader ? ":leader" : "")"
        }
        return entries.isEmpty ? "无组成行" : entries.joined(separator: " / ")
    }

    var bestFarmStageCompositionContainsMonster: Bool {
        guard let code = bestFarmStageCode,
              let runtime = StageDefinition.runtimeData(sourceCode: code) else {
            return false
        }
        return runtime.monsterComposition.contains { $0.name == monster.zhName }
    }

    var bestFarmStageCompositionEvidence: String {
        guard let code = bestFarmStageCode else {
            return "best-farm 无 stage code，不能证明出场"
        }
        let inclusion = bestFarmStageCompositionContainsMonster ? "包含" : "未列出"
        return "best \(code) 组成\(inclusion)\(monster.zhName)：\(bestFarmStageCompositionText)"
    }

    var sourceStageAppearanceEvidence: SourceMonsterSourceStageEvidenceRowModel? {
        SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceEvidenceRow(for: monster.id)
    }

    var sourceStageAppearanceEvidenceText: String {
        sourceStageAppearanceEvidence?.sourceEvidenceText ?? "来源页出场未核对"
    }

    var sourceSkillCandidates: [SourceSkill] {
        SourceSkillCatalog.all
            .filter { $0.id.hasPrefix(String(monster.id)) }
            .sorted { $0.id < $1.id }
    }

    var sourceSkillCandidateIDs: [String] {
        sourceSkillCandidates.map(\.id)
    }

    var sourceSkillCandidateEvidence: String {
        let summaries = sourceSkillCandidates.map { skill in
            "#\(skill.id) \(skill.damageType) \(skill.activation.rawValue) r\(skill.range) value \(skill.sourceValueText) delivery \(skill.delivery.isEmpty ? "空" : skill.delivery)"
        }
        return summaries.isEmpty ? "同前缀候选技能无" : "同前缀候选技能 " + summaries.joined(separator: " / ")
    }

    var sourceSkillCandidateBoundary: String {
        "ID 前缀只给复核队列排序；不证明怪物技能归属、倍率公式、delivery、动作帧或音效"
    }
}

struct SourceMonsterSourceOnlySpriteRowModel: Identifiable, Equatable {
    let monster: SourceMonsterDatabaseEntry
    let resourceName: String

    var id: Int { monster.id }

    var title: String {
        "\(monster.id):\(monster.zhName)"
    }

    var subtitle: String {
        "\(monster.enName) · \(resourceName)"
    }

    var boundaryText: String {
        "只作素材证据，不接入战斗生成、关卡遭遇、技能、掉落或动作帧"
    }
}

struct SourceMonsterSourceStageEvidenceRowModel: Identifiable, Equatable {
    let monster: SourceMonsterDatabaseEntry
    let monsterPageStageRowCount: Int
    let crossCheckStagePageCount: Int
    let hasSourceStageAppearance: Bool
    let sourceEvidenceText: String
    let localRuntimeEvidenceText: String
    let sourceURLText: String

    var id: Int { monster.id }

    var title: String {
        "\(monster.id):\(monster.zhName)"
    }

    var summaryText: String {
        "怪物页 \(monsterPageStageRowCount) stage rows / stage页 \(crossCheckStagePageCount)"
    }

    var boundaryText: String {
        "同属 taskbarhero.org v1.00.13 来源族；不是第二独立来源；只证明来源页出场字段，不证明本地 runtimeData、波次顺序、技能归属、动作帧或 SFX"
    }
}

struct SourceMonsterSourcePageFieldEvidenceRowModel: Identifiable, Equatable {
    let monster: SourceMonsterDatabaseEntry
    let spritePath: String
    let move: Int
    let damage: String
    let range: String

    var id: Int { monster.id }

    var title: String {
        "\(monster.id):\(monster.zhName)"
    }

    var sourceFieldText: String {
        "Move \(move) / Damage \(damage) / Range \(range)"
    }

    var spritePathText: String {
        spritePath
    }

    var hasSpritePathProof: Bool {
        spritePath.hasPrefix("/assets/tbhdb/game/monsters/") && spritePath.hasSuffix(".png")
    }

    var hasMoveProof: Bool {
        move > 0
    }

    var hasDamageProof: Bool {
        damage != "—"
    }

    var hasRangeProof: Bool {
        range != "—"
    }

    var boundaryText: String {
        "怪物页字段只作来源证据；sprite URL、Move、Damage、Range 不证明本地移动速度、攻击距离、技能归属、命中形态、动作帧或 SFX"
    }
}

struct SourceMonsterSourceOnlyProofRowModel: Identifiable, Equatable {
    let unmappedRow: SourceMonsterUnmappedEvidenceQueueRowModel

    var id: Int { unmappedRow.id }

    var monster: SourceMonsterDatabaseEntry {
        unmappedRow.monster
    }

    var title: String {
        unmappedRow.title
    }

    var verifiedEvidenceText: String {
        "源表行 + \(unmappedRow.sourceOnlySpriteEvidence)"
    }

    var stageProofText: String {
        unmappedRow.bestFarmStageCompositionEvidence
    }

    var sourceStageAppearanceText: String {
        unmappedRow.sourceStageAppearanceEvidenceText
    }

    var sourcePageFieldText: String {
        unmappedRow.sourcePageFieldEvidenceText
    }

    var runtimeProofText: String {
        "无 StageMonsterSpawn / 无当前 Battle encounter"
    }

    var skillOwnershipText: String {
        "\(unmappedRow.sourceSkillCandidateEvidence)；归属未证明"
    }

    var animationProofText: String {
        "无 idle/attack/hit/death 动作帧；无原版 SFX"
    }

    var missingProofText: String {
        "缺关卡槽位、运行时遭遇、技能归属、动作帧和 SFX"
    }

    var hasSourceRowProof: Bool { true }

    var hasSourceOnlySpriteProof: Bool {
        SourceMonsterDatabase.sourceOnlySpriteResourceName(for: monster) != nil
    }

    var hasSourceStageAppearanceProof: Bool {
        unmappedRow.sourceStageAppearanceEvidence?.hasSourceStageAppearance ?? false
    }

    var hasSourcePageFieldProof: Bool {
        unmappedRow.sourcePageFieldEvidence != nil
    }

    var hasStageCompositionProof: Bool {
        unmappedRow.bestFarmStageCompositionContainsMonster
    }

    var hasRuntimeEncounterProof: Bool { false }
    var hasSkillOwnershipProof: Bool { false }
    var hasAnimationFrameProof: Bool { false }
    var hasOriginalSFXProof: Bool { false }

    var isRuntimeBlocked: Bool {
        !hasStageCompositionProof ||
            !hasRuntimeEncounterProof ||
            !hasSkillOwnershipProof ||
            !hasAnimationFrameProof ||
            !hasOriginalSFXProof
    }
}

enum SourceMonsterDatabaseMetrics {
    static let sourceURLText = "zh/en: taskbarhero.org/monsters"
    static let sourceAbsentBestFarmBoundaryText = "best-farm 为 — 是源表空值，只保留为数据证据；不当作待补刷取地，也不反推关卡出场"
    static let stageCompositionUnmappedEvidenceGateBoundaryText = "接入门槛只定义缺失证据；源表单张 sprite 只作素材证据，不生成关卡遭遇、技能、掉落或动作帧"
    static let stageCompositionUnmappedEvidenceQueueBoundaryText = "接入队列只排列互斥复核顺序，不按源表数值、best-farm 文本、近似同族外观或现有单张 sprite 生成关卡遭遇；不生成关卡遭遇、技能、掉落或动作帧"
    static let sourceOnlyProofMatrixBoundaryText = "source-only 证明矩阵只拆分已证和缺证；源表行、best-farm 文本、同前缀技能或单张 sprite 不接入运行时，也不生成怪物图、技能、掉落、动作帧或 SFX"
    static let sourceOnlyStageAppearanceBoundaryText = "source-only 来源出场证据只记录 taskbarhero.org 怪物页和同站关卡页交叉结果；同站中英页面不是独立来源，不解锁本地关卡组成、运行时遭遇、技能归属、动作帧或 SFX"
    static let sourceOnlyPageFieldBoundaryText = "source-only 页面字段证据只记录 taskbarhero.org 怪物页上的 sprite URL、Move、Damage、Range；同站字段不证明本地移动速度、攻击距离、技能归属、命中形态、动作帧或 SFX"

    static var rows: [SourceMonsterDatabaseEntry] {
        SourceMonsterDatabase.entries
    }

    static var rowCount: Int {
        SourceMonsterDatabase.rowCount
    }

    static var uniqueIDCount: Int {
        SourceMonsterDatabase.uniqueIDCount
    }

    static var uniqueNameCount: Int {
        SourceMonsterDatabase.uniqueNameCount
    }

    static let officialSteamMinimumMonsterTypeCount = 50

    static var steamRosterIdentityCoverageText: String {
        "\(uniqueNameCount)/\(officialSteamMinimumMonsterTypeCount)+"
    }

    static var steamRosterIdentityGapCount: Int {
        max(0, officialSteamMinimumMonsterTypeCount - uniqueNameCount)
    }

    static var missingBestFarmCount: Int {
        SourceMonsterDatabase.missingBestFarmCount
    }

    static var sourceOnlySpriteRows: [SourceMonsterDatabaseEntry] {
        SourceMonsterDatabase.sourceOnlySpriteEntries
    }

    static var sourceOnlySpritePreviewRows: [SourceMonsterSourceOnlySpriteRowModel] {
        sourceOnlySpriteRows.compactMap { row in
            guard let resourceName = SourceMonsterDatabase.sourceOnlySpriteResourceName(for: row) else {
                return nil
            }
            return SourceMonsterSourceOnlySpriteRowModel(monster: row, resourceName: resourceName)
        }
    }

    static var sourceOnlySpriteCount: Int {
        sourceOnlySpriteRows.count
    }

    static var sourceOnlySpritePreviewCount: Int {
        sourceOnlySpritePreviewRows.count
    }

    static var sourceOnlySpriteNamesText: String {
        let names = sourceOnlySpriteRows.map(\.zhName)
        return names.isEmpty ? "无" : names.joined(separator: " / ")
    }

    static var sourceOnlySpriteResourceText: String {
        let names = SourceMonsterDatabase.sourceOnlySpriteResourceNames
        return names.isEmpty ? "无" : names.joined(separator: ",")
    }

    static var sourceOnlySpriteCoverageText: String {
        "\(sourceOnlySpriteCount)/\(stageCompositionUnmappedCount)"
    }

    static var sourceOnlyPageFieldEvidenceRows: [SourceMonsterSourcePageFieldEvidenceRowModel] {
        [
            sourceOnlyPageFieldEvidenceRow(
                monsterID: 20_042,
                spritePath: "/assets/tbhdb/game/monsters/RedExplosionInsect/RedExplosionInsect_Idle_character_2.png",
                move: 220,
                damage: "—",
                range: "—"
            ),
            sourceOnlyPageFieldEvidenceRow(
                monsterID: 20_121,
                spritePath: "/assets/tbhdb/game/monsters/GiantTick/GiantTick_Idle_character_4.png",
                move: 400,
                damage: "Physical",
                range: "130"
            ),
            sourceOnlyPageFieldEvidenceRow(
                monsterID: 30_044,
                spritePath: "/assets/tbhdb/game/monsters/FrozenWizard/FrozenWizard_Idle_character_2.png",
                move: 220,
                damage: "—",
                range: "—"
            )
        ]
        .compactMap { $0 }
    }

    static func sourceOnlyPageFieldEvidenceRow(for monsterID: Int) -> SourceMonsterSourcePageFieldEvidenceRowModel? {
        sourceOnlyPageFieldEvidenceRows.first { $0.monster.id == monsterID }
    }

    private static func sourceOnlyPageFieldEvidenceRow(
        monsterID: Int,
        spritePath: String,
        move: Int,
        damage: String,
        range: String
    ) -> SourceMonsterSourcePageFieldEvidenceRowModel? {
        guard let monster = SourceMonsterDatabase.entry(id: monsterID) else {
            return nil
        }
        return SourceMonsterSourcePageFieldEvidenceRowModel(
            monster: monster,
            spritePath: spritePath,
            move: move,
            damage: damage,
            range: range
        )
    }

    static var sourceOnlyPageFieldEvidenceRowCount: Int {
        sourceOnlyPageFieldEvidenceRows.count
    }

    static var sourceOnlyPageFieldSpritePathCount: Int {
        sourceOnlyPageFieldEvidenceRows.filter(\.hasSpritePathProof).count
    }

    static var sourceOnlyPageFieldMoveKnownCount: Int {
        sourceOnlyPageFieldEvidenceRows.filter(\.hasMoveProof).count
    }

    static var sourceOnlyPageFieldDamageKnownCount: Int {
        sourceOnlyPageFieldEvidenceRows.filter(\.hasDamageProof).count
    }

    static var sourceOnlyPageFieldRangeKnownCount: Int {
        sourceOnlyPageFieldEvidenceRows.filter(\.hasRangeProof).count
    }

    static var sourceOnlyPageFieldUnknownDamageRangeCount: Int {
        sourceOnlyPageFieldEvidenceRows.filter {
            !$0.hasDamageProof && !$0.hasRangeProof
        }.count
    }

    static var sourceOnlyPageFieldSummaryText: String {
        "页面字段 \(sourceOnlyPageFieldEvidenceRowCount)/\(stageCompositionUnmappedCount) / sprite URL \(sourceOnlyPageFieldSpritePathCount) / Move \(sourceOnlyPageFieldMoveKnownCount) / Damage \(sourceOnlyPageFieldDamageKnownCount) / Range \(sourceOnlyPageFieldRangeKnownCount)"
    }

    static var sourceOnlyStageAppearanceEvidenceRows: [SourceMonsterSourceStageEvidenceRowModel] {
        [
            sourceOnlyStageAppearanceEvidenceRow(
                monsterID: 20_042,
                monsterPageStageRowCount: 5,
                crossCheckStagePageCount: 2,
                hasSourceStageAppearance: true,
                sourceEvidenceText: "怪物页 5 stage rows；关卡页 4207=74、3204=39",
                localRuntimeEvidenceText: "本地 4207/3204 stage composition 未列出剧毒领主；runtime 仍阻断",
                sourceURLText: "en/monsters/20042 + en/zh stages 4207 + en stage 3204"
            ),
            sourceOnlyStageAppearanceEvidenceRow(
                monsterID: 20_121,
                monsterPageStageRowCount: 0,
                crossCheckStagePageCount: 0,
                hasSourceStageAppearance: false,
                sourceEvidenceText: "怪物页 stage appearances 空；仅 Damage Physical / Range 130",
                localRuntimeEvidenceText: "无 best-farm stage code；runtime 仍阻断",
                sourceURLText: "en/monsters/20121"
            ),
            sourceOnlyStageAppearanceEvidenceRow(
                monsterID: 30_044,
                monsterPageStageRowCount: 9,
                crossCheckStagePageCount: 2,
                hasSourceStageAppearance: true,
                sourceEvidenceText: "怪物页 9 stage rows；关卡页 4303=70、2303=30",
                localRuntimeEvidenceText: "本地 4303/2303 stage composition 未列出雪山法师；runtime 仍阻断",
                sourceURLText: "en/monsters/30044 + en/zh stages 4303 + en stage 2303"
            )
        ]
        .compactMap { $0 }
    }

    static func sourceOnlyStageAppearanceEvidenceRow(for monsterID: Int) -> SourceMonsterSourceStageEvidenceRowModel? {
        sourceOnlyStageAppearanceEvidenceRows.first { $0.monster.id == monsterID }
    }

    private static func sourceOnlyStageAppearanceEvidenceRow(
        monsterID: Int,
        monsterPageStageRowCount: Int,
        crossCheckStagePageCount: Int,
        hasSourceStageAppearance: Bool,
        sourceEvidenceText: String,
        localRuntimeEvidenceText: String,
        sourceURLText: String
    ) -> SourceMonsterSourceStageEvidenceRowModel? {
        guard let monster = SourceMonsterDatabase.entry(id: monsterID) else {
            return nil
        }
        return SourceMonsterSourceStageEvidenceRowModel(
            monster: monster,
            monsterPageStageRowCount: monsterPageStageRowCount,
            crossCheckStagePageCount: crossCheckStagePageCount,
            hasSourceStageAppearance: hasSourceStageAppearance,
            sourceEvidenceText: sourceEvidenceText,
            localRuntimeEvidenceText: localRuntimeEvidenceText,
            sourceURLText: sourceURLText
        )
    }

    static var sourceOnlyStageAppearanceEvidenceRowCount: Int {
        sourceOnlyStageAppearanceEvidenceRows.count
    }

    static var sourceOnlyStageAppearanceConfirmedCount: Int {
        sourceOnlyStageAppearanceEvidenceRows.filter(\.hasSourceStageAppearance).count
    }

    static var sourceOnlyStageAppearanceAbsentCount: Int {
        sourceOnlyStageAppearanceEvidenceRows.filter { !$0.hasSourceStageAppearance }.count
    }

    static var sourceOnlyStageAppearanceTotalStageRows: Int {
        sourceOnlyStageAppearanceEvidenceRows.map(\.monsterPageStageRowCount).reduce(0, +)
    }

    static var sourceOnlyStageAppearanceCrossCheckPageCount: Int {
        sourceOnlyStageAppearanceEvidenceRows.map(\.crossCheckStagePageCount).reduce(0, +)
    }

    static var sourceOnlyStageAppearanceCoverageText: String {
        "\(sourceOnlyStageAppearanceConfirmedCount)/\(sourceOnlyStageAppearanceEvidenceRowCount)"
    }

    static var sourceOnlyStageAppearanceSummaryText: String {
        "来源出场 \(sourceOnlyStageAppearanceCoverageText) / monster rows \(sourceOnlyStageAppearanceTotalStageRows) / stage页 \(sourceOnlyStageAppearanceCrossCheckPageCount)"
    }

    static var sourceOnlyProofRows: [SourceMonsterSourceOnlyProofRowModel] {
        stageCompositionUnmappedEvidenceQueueRows.map {
            SourceMonsterSourceOnlyProofRowModel(unmappedRow: $0)
        }
    }

    static var sourceOnlyProofRowCount: Int {
        sourceOnlyProofRows.count
    }

    static var sourceOnlyProofCoverageText: String {
        "\(sourceOnlyProofRowCount)/\(stageCompositionUnmappedCount)"
    }

    static var sourceOnlyStageProofMissingCount: Int {
        sourceOnlyProofRows.filter { !$0.hasStageCompositionProof }.count
    }

    static var sourceOnlyRuntimeBlockedCount: Int {
        sourceOnlyProofRows.filter(\.isRuntimeBlocked).count
    }

    static var sourceOnlySkillOwnershipUnprovenCount: Int {
        sourceOnlyProofRows.filter { !$0.hasSkillOwnershipProof }.count
    }

    static var sourceOnlyAnimationFrameMissingCount: Int {
        sourceOnlyProofRows.filter { !$0.hasAnimationFrameProof }.count
    }

    static var sourceOnlyOriginalSFXMissingCount: Int {
        sourceOnlyProofRows.filter { !$0.hasOriginalSFXProof }.count
    }

    static var sourceOnlyPositiveProofText: String {
        "\(sourceOnlyProofRowCount) 源表行 / sprite \(sourceOnlySpriteCoverageText)"
    }

    static var sourceOnlyBlockedProofText: String {
        "关卡 \(sourceOnlyStageProofMissingCount) / 运行时 \(sourceOnlyRuntimeBlockedCount) / 技能 \(sourceOnlySkillOwnershipUnprovenCount) / 动作帧 \(sourceOnlyAnimationFrameMissingCount) / SFX \(sourceOnlyOriginalSFXMissingCount)"
    }

    static var stageCompositionCoverageText: String {
        "\(SourceMonsterDatabase.stageCompositionNameCoverageCount)/\(SourceMonsterArtMappingMetrics.sourceNameCount)"
    }

    static var hpRangeText: String {
        numericRangeText(rows.map(\.hp))
    }

    static var attackRangeText: String {
        numericRangeText(rows.map(\.attack))
    }

    static var attackSpeedRangeText: String {
        guard let minimum = rows.map(\.attackSpeed).min(),
              let maximum = rows.map(\.attackSpeed).max() else {
            return "0"
        }
        return "\(decimalText(minimum))-\(decimalText(maximum))"
    }

    static var sourceCooldownRangeText: String {
        rangeText(rows.map { SourceMonsterDatabase.sourceCooldownSeconds(fromAttackSpeed: $0.attackSpeed) })
    }

    static var localLoopCooldownRangeText: String {
        rangeText(rows.map { SourceMonsterDatabase.localLoopCooldownSeconds(fromAttackSpeed: $0.attackSpeed) })
    }

    static var attackSpeedQuantizationText: String {
        "来源冷却 \(sourceCooldownRangeText)；本地循环 \(localLoopCooldownRangeText)"
    }

    static var missingStageCompositionNamesText: String {
        let names = SourceMonsterDatabase.stageCompositionMissingNames
        return names.isEmpty ? "无" : names.joined(separator: ",")
    }

    static var sourceRosterArtGapRows: [SourceMonsterDatabaseEntry] {
        let compositionNames = Set(SourceMonsterArtMappingMetrics.mappings.map(\.sourceName))
        var seenNames = Set<String>()
        return rows.filter { row in
            guard !compositionNames.contains(row.zhName) else { return false }
            return seenNames.insert(row.zhName).inserted
        }
    }

    static var sourceRosterArtGapCount: Int {
        sourceRosterArtGapRows.count
    }

    static var sourceRosterArtGapNamesText: String {
        let names = sourceRosterArtGapRows.map(\.zhName)
        return names.isEmpty ? "无" : names.joined(separator: " / ")
    }

    static var stageCompositionUnmappedRows: [SourceMonsterDatabaseEntry] {
        sourceRosterArtGapRows
    }

    static var stageCompositionUnmappedCount: Int {
        sourceRosterArtGapCount
    }

    static var stageCompositionUnmappedNamesText: String {
        sourceRosterArtGapNamesText
    }

    static var stageCompositionUnmappedDetailText: String {
        stageCompositionUnmappedRows
            .map { "\($0.id):\($0.zhName)" }
            .joined(separator: ",")
    }

    static let stageCompositionUnmappedBoundaryText = "这些源怪物只证明源表存在；当前没有关卡组成、运行时遭遇、掉落或动作帧证据。已接入的源表单张 sprite 只作素材审计，不接入战斗生成，也不复用或绘制新图"

    static var stageCompositionUnmappedEvidenceGateRows: [SourceMonsterUnmappedEvidenceGateRowModel] {
        [
            SourceMonsterUnmappedEvidenceGateRowModel(
                key: "stage-slot",
                title: "关卡组成槽位",
                currentEvidence: "\(stageCompositionUnmappedCount) 源表行有 best-farm 文本，但当前 120 行关卡组成未出现",
                missingEvidence: "明确 stage code、波次/组成数量、是否 Boss 或普通遭遇",
                requiredProof: "drops/stages 表、原版录屏或同源关卡组合数据能证明实际出场",
                affectedMonsterCount: stageCompositionUnmappedCount
            ),
            SourceMonsterUnmappedEvidenceGateRowModel(
                key: "battle-art",
                title: "战斗图资源",
                currentEvidence: "\(sourceOnlySpriteCoverageText) 源表缺口已有 source_monster_* 单张 sprite；仍无关卡战斗映射",
                missingEvidence: "出场证明、战斗缩放/锚点、动作帧或明确同图规则",
                requiredProof: "来源资源、官方媒体帧或可复现截图；不得自行绘制",
                affectedMonsterCount: stageCompositionUnmappedCount
            ),
            SourceMonsterUnmappedEvidenceGateRowModel(
                key: "runtime-encounter",
                title: "运行时遭遇",
                currentEvidence: "无 StageMonsterSpawn / 无当前战斗遭遇",
                missingEvidence: "HP/金币/经验与关卡运行表的对应关系",
                requiredProof: "能把源怪物 ID 与现有关卡 runtimeData 绑定的证据",
                affectedMonsterCount: stageCompositionUnmappedCount
            ),
            SourceMonsterUnmappedEvidenceGateRowModel(
                key: "attack-skill",
                title: "攻击/技能来源",
                currentEvidence: "仅有源表 ATK/Atk Spd；无 source skill ID",
                missingEvidence: "技能 ID、伤害元素、delivery、range、施法归属",
                requiredProof: "技能表、怪物页或战斗记录证明攻击语义",
                affectedMonsterCount: stageCompositionUnmappedCount
            ),
            SourceMonsterUnmappedEvidenceGateRowModel(
                key: "animation-sfx",
                title: "动作帧/SFX",
                currentEvidence: "无原版待机、移动、受击、攻击、死亡帧或音效证据",
                missingEvidence: "关键帧、命中帧、死亡帧、施放/命中音频",
                requiredProof: "原版资源文件、官方视频帧采样或可复现录屏音轨",
                affectedMonsterCount: stageCompositionUnmappedCount
            )
        ]
    }

    static var stageCompositionUnmappedEvidenceGateCount: Int {
        stageCompositionUnmappedEvidenceGateRows.count
    }

    static var stageCompositionUnmappedEvidenceQueueRows: [SourceMonsterUnmappedEvidenceQueueRowModel] {
        stageCompositionUnmappedRows.map {
            SourceMonsterUnmappedEvidenceQueueRowModel(monster: $0)
        }
    }

    static var stageCompositionUnmappedEvidenceQueueCount: Int {
        stageCompositionUnmappedEvidenceQueueRows.count
    }

    static var stageCompositionUnmappedEvidenceQueueCoverage: Int {
        stageCompositionUnmappedEvidenceQueueRows.count
    }

    static var stageCompositionUnmappedCandidateSkillCount: Int {
        stageCompositionUnmappedEvidenceQueueRows.map(\.sourceSkillCandidates.count).reduce(0, +)
    }

    static var sourceBoundaryText: String {
        SourceMonsterDatabase.sourceBoundaryText
    }

    static var runtimeBoundaryText: String {
        SourceMonsterDatabase.runtimeBoundaryText
    }

    private static func numericRangeText(_ values: [Int]) -> String {
        guard let minimum = values.min(), let maximum = values.max() else {
            return "0"
        }
        return "\(minimum)-\(maximum)"
    }

    private static func decimalText(_ value: Double) -> String {
        if value.rounded(.towardZero) == value {
            return "\(Int(value))"
        }
        return "\(value)"
    }

    private static func rangeText(_ values: [Double]) -> String {
        guard let minimum = values.min(), let maximum = values.max() else {
            return "0s"
        }
        return "\(secondsText(minimum))-\(secondsText(maximum))"
    }

    private static func secondsText(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        return "\(decimalText(rounded))s"
    }
}

private struct SourceMonsterDatabaseView: View {
    private let rows = SourceMonsterDatabaseMetrics.rows

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "来源行",
                    value: "\(SourceMonsterDatabaseMetrics.rowCount)"
                )
                SourceRuneSummaryPill(
                    label: "唯一ID",
                    value: "\(SourceMonsterDatabaseMetrics.uniqueIDCount)"
                )
                SourceRuneSummaryPill(
                    label: "唯一名",
                    value: "\(SourceMonsterDatabaseMetrics.uniqueNameCount)"
                )
                SourceRuneSummaryPill(
                    label: "源空刷取",
                    value: "\(SourceMonsterDatabaseMetrics.missingBestFarmCount)"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "名录下限",
                    value: SourceMonsterDatabaseMetrics.steamRosterIdentityCoverageText
                )
                SourceRuneSummaryPill(
                    label: "关卡名",
                    value: SourceMonsterDatabaseMetrics.stageCompositionCoverageText
                )
                SourceRuneSummaryPill(
                    label: "未进关卡",
                    value: "\(SourceMonsterDatabaseMetrics.sourceRosterArtGapCount)"
                )
                SourceRuneSummaryPill(
                    label: "源表图",
                    value: SourceMonsterDatabaseMetrics.sourceOnlySpriteCoverageText
                )
            }

            HStack {
                Text("HP/ATK/攻速")
                Spacer()
                Text("\(SourceMonsterDatabaseMetrics.hpRangeText) / \(SourceMonsterDatabaseMetrics.attackRangeText) / \(SourceMonsterDatabaseMetrics.attackSpeedRangeText)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            HStack {
                Text("攻速表现")
                Spacer()
                Text(SourceMonsterDatabaseMetrics.attackSpeedQuantizationText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.50)
            }

            HStack {
                Text("源表单张 sprite")
                Spacer()
                Text(SourceMonsterDatabaseMetrics.sourceOnlySpriteResourceText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceMonsterDatabaseMetrics.sourceOnlySpritePreviewRows) { row in
                        SourceMonsterSourceOnlySpritePreviewRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "源表单张 sprite 预览",
                    value: SourceMonsterDatabaseMetrics.sourceOnlySpriteCoverageText
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "证明矩阵",
                    value: SourceMonsterDatabaseMetrics.sourceOnlyProofCoverageText
                )
                SourceRuneSummaryPill(
                    label: "关卡缺证",
                    value: "\(SourceMonsterDatabaseMetrics.sourceOnlyStageProofMissingCount)"
                )
                SourceRuneSummaryPill(
                    label: "运行时阻断",
                    value: "\(SourceMonsterDatabaseMetrics.sourceOnlyRuntimeBlockedCount)"
                )
                SourceRuneSummaryPill(
                    label: "技能未证",
                    value: "\(SourceMonsterDatabaseMetrics.sourceOnlySkillOwnershipUnprovenCount)"
                )
            }

            HStack {
                Text("source-only 证明")
                Spacer()
                Text(SourceMonsterDatabaseMetrics.sourceOnlyPositiveProofText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.54)
            }

            HStack {
                Text("source-only 缺证")
                Spacer()
                Text(SourceMonsterDatabaseMetrics.sourceOnlyBlockedProofText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)
            }

            Text(SourceMonsterDatabaseMetrics.sourceOnlyProofMatrixBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "页面字段",
                    value: "\(SourceMonsterDatabaseMetrics.sourceOnlyPageFieldEvidenceRowCount)/\(SourceMonsterDatabaseMetrics.stageCompositionUnmappedCount)"
                )
                SourceRuneSummaryPill(
                    label: "sprite URL",
                    value: "\(SourceMonsterDatabaseMetrics.sourceOnlyPageFieldSpritePathCount)"
                )
                SourceRuneSummaryPill(
                    label: "Move",
                    value: "\(SourceMonsterDatabaseMetrics.sourceOnlyPageFieldMoveKnownCount)"
                )
                SourceRuneSummaryPill(
                    label: "Damage/Range",
                    value: "\(SourceMonsterDatabaseMetrics.sourceOnlyPageFieldDamageKnownCount)/\(SourceMonsterDatabaseMetrics.sourceOnlyPageFieldRangeKnownCount)"
                )
            }

            HStack {
                Text("source-only 页面字段")
                Spacer()
                Text(SourceMonsterDatabaseMetrics.sourceOnlyPageFieldSummaryText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.36)
            }

            Text(SourceMonsterDatabaseMetrics.sourceOnlyPageFieldBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceMonsterDatabaseMetrics.sourceOnlyPageFieldEvidenceRows) { row in
                        SourceMonsterSourcePageFieldEvidenceRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "source-only 页面字段证据",
                    value: SourceMonsterDatabaseMetrics.sourceOnlyPageFieldSummaryText
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "来源出场",
                    value: SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceCoverageText
                )
                SourceRuneSummaryPill(
                    label: "怪物页行",
                    value: "\(SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceTotalStageRows)"
                )
                SourceRuneSummaryPill(
                    label: "同站关卡页",
                    value: "\(SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceCrossCheckPageCount)"
                )
                SourceRuneSummaryPill(
                    label: "空出场",
                    value: "\(SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceAbsentCount)"
                )
            }

            HStack {
                Text("source-only 来源出场")
                Spacer()
                Text(SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceSummaryText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)
            }

            Text(SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceEvidenceRows) { row in
                        SourceMonsterSourceStageEvidenceRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "source-only 来源出场证据",
                    value: SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceCoverageText
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceMonsterDatabaseMetrics.sourceOnlyProofRows) { row in
                        SourceMonsterSourceOnlyProofRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "source-only 证明矩阵",
                    value: SourceMonsterDatabaseMetrics.sourceOnlyProofCoverageText
                )
            }

            HStack {
                Text("来源")
                Spacer()
                Text(SourceMonsterDatabaseMetrics.sourceURLText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }

            Text(SourceMonsterDatabaseMetrics.sourceBoundaryText)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(SourceMonsterDatabaseMetrics.sourceAbsentBestFarmBoundaryText)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(SourceMonsterDatabaseMetrics.runtimeBoundaryText)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("未覆盖关卡组合名")
                Spacer()
                Text(SourceMonsterDatabaseMetrics.missingStageCompositionNamesText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }

            HStack {
                Text("源表未进关卡组成")
                Spacer()
                Text("\(SourceMonsterDatabaseMetrics.stageCompositionUnmappedCount) · sprite \(SourceMonsterDatabaseMetrics.sourceOnlySpriteCount)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }

            Text(SourceMonsterDatabaseMetrics.stageCompositionUnmappedNamesText)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(SourceMonsterDatabaseMetrics.stageCompositionUnmappedBoundaryText)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "接入门槛",
                    value: "\(SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateCount)"
                )
                SourceRuneSummaryPill(
                    label: "受影响",
                    value: "\(SourceMonsterDatabaseMetrics.stageCompositionUnmappedCount)"
                )
                SourceRuneSummaryPill(
                    label: "接入队列",
                    value: "\(SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "队列覆盖",
                    value: "\(SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueCoverage)/\(SourceMonsterDatabaseMetrics.stageCompositionUnmappedCount)"
                )
            }

            Text(SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateRows) { row in
                        SourceMonsterUnmappedEvidenceGateRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "未映射接入门槛",
                    value: "\(SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateCount) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueRows) { row in
                        SourceMonsterUnmappedEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "未映射接入队列",
                    value: "\(SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueCount) 队列"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceMonsterDatabaseMetrics.stageCompositionUnmappedRows) { row in
                        SourceMonsterUnmappedDatabaseRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "未映射源怪物",
                    value: "\(SourceMonsterDatabaseMetrics.stageCompositionUnmappedCount) 行"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(rows) { row in
                        SourceMonsterDatabaseRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(title: "完整怪物数据库", value: "\(rows.count) 行")
            }
        }
    }
}

private struct SourceMonsterSourceOnlySpritePreviewRow: View {
    let row: SourceMonsterSourceOnlySpriteRowModel

    var body: some View {
        HStack(alignment: .center, spacing: 7) {
            PixelSprite(
                imageName: row.resourceName,
                size: CGSize(width: 42, height: 42)
            )
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)

                Text(row.subtitle)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.50)

                Text(row.boundaryText)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct SourceMonsterSourcePageFieldEvidenceRow: View {
    let row: SourceMonsterSourcePageFieldEvidenceRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: row.hasSpritePathProof ? "photo.fill" : "questionmark.square.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(row.hasSpritePathProof ? .green : .orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)

                    Text(row.monster.enName)
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.52)
                }

                Text(row.sourceFieldText)
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .foregroundColor(row.hasDamageProof || row.hasRangeProof ? .green : .orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.50)

                Text(row.spritePathText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.30)

                Text(row.boundaryText)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct SourceMonsterSourceStageEvidenceRow: View {
    let row: SourceMonsterSourceStageEvidenceRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: row.hasSourceStageAppearance ? "checkmark.seal.fill" : "questionmark.diamond.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(row.hasSourceStageAppearance ? .green : .orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)

                    Text(row.monster.enName)
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.52)
                }

                Text(row.summaryText)
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .foregroundColor(row.hasSourceStageAppearance ? .green : .orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.50)

                Text(row.sourceEvidenceText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)

                Text(row.localRuntimeEvidenceText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)

                Text(row.sourceURLText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.36)

                Text(row.boundaryText)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct SourceMonsterSourceOnlyProofRow: View {
    let row: SourceMonsterSourceOnlyProofRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)

                    Text(row.monster.enName)
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.52)
                }

                Text(row.verifiedEvidenceText)
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)

                Text(row.sourcePageFieldText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(row.hasSourcePageFieldProof ? .green : .orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)

                Text(row.sourceStageAppearanceText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(row.hasSourceStageAppearanceProof ? .green : .orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)

                Text(row.stageProofText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)

                Text(row.runtimeProofText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.50)

                Text(row.skillOwnershipText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.36)

                Text(row.animationProofText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.50)

                Text(row.missingProofText)
                    .font(.system(size: 7, weight: .semibold))
                    .foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct SourceMonsterUnmappedDatabaseRow: View {
    let row: SourceMonsterDatabaseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text(row.zhName)
                    .font(.system(size: 9, weight: .semibold))
                Text(row.enName)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                Spacer(minLength: 4)
                Text("\(row.id)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }

            Text("HP \(row.hp) · ATK \(row.attack) · AS \(SourceMonsterDatabaseMetrics.decimalTextForRow(row.attackSpeed)) · \(row.gold)G/\(row.xp)XP · best \(row.bestFarm) · \(spriteEvidence) · 无关卡组成/运行时")
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.42)
        }
        .padding(.vertical, 2)
    }

    private var spriteEvidence: String {
        SourceMonsterDatabase.sourceOnlySpriteResourceName(for: row) ?? "源表 sprite 未接入"
    }
}

private struct SourceMonsterUnmappedEvidenceQueueRow: View {
    let row: SourceMonsterUnmappedEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)

                    Text(row.monster.enName)
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.52)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("补：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(row.boundary)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        row.monster.bestFarm == "—" ? "questionmark.diamond.fill" : "checklist"
    }
}

private struct SourceMonsterUnmappedEvidenceGateRow: View {
    let row: SourceMonsterUnmappedEvidenceGateRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(row.affectedMonsterCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("证：\(row.requiredProof)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "stage-slot":
            return "map"
        case "battle-art":
            return "photo"
        case "runtime-encounter":
            return "figure.run"
        case "attack-skill":
            return "bolt.fill"
        case "animation-sfx":
            return "waveform"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
}

private struct SourceMonsterDatabaseRow: View {
    let row: SourceMonsterDatabaseEntry

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "list.bullet.rectangle.portrait")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(row.zhName)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(row.enName)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                }

                Text("HP \(row.hp) · ATK \(row.attack) · AS \(SourceMonsterDatabaseMetrics.decimalTextForRow(row.attackSpeed)) · \(row.gold)G/\(row.xp)XP · \(row.bestFarm)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)
            }

            Spacer(minLength: 4)

            Text("\(row.id)")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

private extension SourceMonsterDatabaseMetrics {
    static func decimalTextForRow(_ value: Double) -> String {
        decimalText(value)
    }
}

struct SourceMonsterArtEvidenceGateRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let currentEvidence: String
    let missingEvidence: String
    let requiredProof: String
    let affectedMappingCount: Int

    var id: String { key }
}

struct SourceMonsterArtEvidenceQueueRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let mappingCount: Int
    let currentEvidence: String
    let nextEvidence: String
    let boundary: String

    var id: String { key }
}

enum SourceMonsterArtMappingMetrics {
    static let artEvidenceGateBoundaryText = "接入门槛只定义怪物美术缺失证据，不生成怪物图、动作帧、缩放、音效或完整图鉴"
    static let artEvidenceQueueBoundaryText = "接入队列只排列怪物美术复核顺序；不生成怪物图、动作帧、缩放、音效或完整图鉴，也不按近似同族、通用官方图、现有单张 sprite、源表缺口或 Steam 50+ 下限补齐缺失美术"

    static let forbiddenLegacySpriteNames: Set<String> = [
        "monster_slime_red",
        "monster_skeleton_boss",
        "boss_golden",
        "boss_demon"
    ]

    static var mappings: [StageMonsterArtMapping] {
        StageDefinition.stageMonsterArtMappings
    }

    static var sourceNameCount: Int {
        mappings.count
    }

    static var sourceRosterNameCount: Int {
        SourceMonsterDatabaseMetrics.uniqueNameCount
    }

    static var officialSteamMinimumMonsterTypeCount: Int {
        SourceMonsterDatabaseMetrics.officialSteamMinimumMonsterTypeCount
    }

    static var steamRosterIdentityCoverageText: String {
        SourceMonsterDatabaseMetrics.steamRosterIdentityCoverageText
    }

    static var steamRosterIdentityGapCount: Int {
        SourceMonsterDatabaseMetrics.steamRosterIdentityGapCount
    }

    static var sourceRosterArtGapCount: Int {
        SourceMonsterDatabaseMetrics.sourceRosterArtGapCount
    }

    static var sourceRosterArtGapNamesText: String {
        SourceMonsterDatabaseMetrics.sourceRosterArtGapNamesText
    }

    static var artMappingCoverageText: String {
        "\(sourceNameCount)/\(sourceRosterNameCount)"
    }

    static var stageCompositionCoverageText: String {
        artMappingCoverageText
    }

    static var rosterBoundaryText: String {
        "源表去重怪物名录 \(steamRosterIdentityCoverageText) 覆盖 Steam 50+ 下限；当前关卡战斗美术映射 \(artMappingCoverageText) 源表名，另有 \(SourceMonsterDatabaseMetrics.sourceOnlySpriteCoverageText) 未进关卡源表怪物已有单张 sprite：\(sourceRosterArtGapNamesText)。该表不证明关卡出场、逐怪物专属动作帧、比例锚点或完整图鉴。"
    }

    static var extractedStageSpriteCount: Int {
        mappings.filter { $0.fidelity == .extractedStageSprite }.count
    }

    static var genericOfficialSpriteCount: Int {
        mappings.filter { $0.fidelity == .genericOfficialSprite }.count
    }

    static var typeNearApproximationCount: Int {
        mappings.filter { $0.fidelity == .typeNearApproximation }.count
    }

    static var spriteFamilyCount: Int {
        Set(mappings.map { GameArt.battleMonsterSpriteName(for: $0.runtimeMonsterID) }).count
    }

    static var slimeFallbackMappings: [StageMonsterArtMapping] {
        mappings.filter { mapping in
            let spriteName = GameArt.battleMonsterSpriteName(for: mapping.runtimeMonsterID)
            return mapping.sourceName != "史莱姆" &&
                (mapping.runtimeMonsterID == "slime_green" || spriteName == "official_monster_slime")
        }
    }

    static var legacyUICropMappings: [StageMonsterArtMapping] {
        mappings.filter { mapping in
            forbiddenLegacySpriteNames.contains(GameArt.battleMonsterSpriteName(for: mapping.runtimeMonsterID))
        }
    }

    static var approximateMappingCount: Int {
        genericOfficialSpriteCount + typeNearApproximationCount
    }

    static var artEvidenceGateRows: [SourceMonsterArtEvidenceGateRowModel] {
        [
            SourceMonsterArtEvidenceGateRowModel(
                key: "full-roster-identity",
                title: "完整怪物名录",
                currentEvidence: "\(steamRosterIdentityCoverageText) 源表去重名覆盖 Steam 下限；\(artMappingCoverageText) 有当前关卡战斗美术映射；源表 sprite \(SourceMonsterDatabaseMetrics.sourceOnlySpriteCoverageText)",
                missingEvidence: "官方逐名名录关系、源表未进关卡怪物的出场/战斗锚点证据",
                requiredProof: "官方资料、原版资源表或可复核 Wiki/录屏能证明完整名录和缺口出场",
                affectedMappingCount: max(sourceRosterArtGapCount, 1)
            ),
            SourceMonsterArtEvidenceGateRowModel(
                key: "dedicated-sprite",
                title: "逐怪物专属 sprite",
                currentEvidence: "\(extractedStageSpriteCount) 源图 / \(genericOfficialSpriteCount) 通用 / \(typeNearApproximationCount) 近似",
                missingEvidence: "通用与近似项的专属战斗图或明确同图规则",
                requiredProof: "原版资源、官方视频帧或可复现截图；不得自行绘制",
                affectedMappingCount: approximateMappingCount
            ),
            SourceMonsterArtEvidenceGateRowModel(
                key: "animation-frame-set",
                title: "动作帧序列",
                currentEvidence: "当前为单张 battle sprite 映射",
                missingEvidence: "待机、移动、攻击、受击、死亡、施法关键帧",
                requiredProof: "sprite sheet、视频逐帧采样或资源导出能定位关键帧",
                affectedMappingCount: sourceNameCount
            ),
            SourceMonsterArtEvidenceGateRowModel(
                key: "scale-anchor",
                title: "比例/地面锚点",
                currentEvidence: "当前使用本地统一战斗平台和局部 sprite 尺寸",
                missingEvidence: "逐怪物缩放、脚底锚点、Boss 体型和横向间距",
                requiredProof: "原版画面量测、资源 metadata 或可复现截图对齐",
                affectedMappingCount: sourceNameCount
            ),
            SourceMonsterArtEvidenceGateRowModel(
                key: "provenance-audit",
                title: "来源与回归证明",
                currentEvidence: "非史莱姆回退 \(slimeFallbackMappings.count) / 旧裁图 \(legacyUICropMappings.count)",
                missingEvidence: "逐图来源、尺寸、透明度、哈希和无旧 UI 裁图证明",
                requiredProof: "资源清单、hash 审计和打包后资源一致性检查",
                affectedMappingCount: sourceNameCount
            )
        ]
    }

    static var artEvidenceGateCount: Int {
        artEvidenceGateRows.count
    }

    static var artEvidenceQueueRows: [SourceMonsterArtEvidenceQueueRowModel] {
        [
            SourceMonsterArtEvidenceQueueRowModel(
                key: "type-near-approximation",
                title: "近似同族复核",
                mappingCount: typeNearApproximationCount,
                currentEvidence: "\(typeNearApproximationCount) 个近似同族复用 sprite",
                nextEvidence: "补专属 sprite、来源证明、动作帧和比例锚点，或明确同图规则",
                boundary: "不按近似同族外观推断专属怪物图、动作帧、缩放、音效或完整图鉴"
            ),
            SourceMonsterArtEvidenceQueueRowModel(
                key: "generic-official",
                title: "通用官方图复核",
                mappingCount: genericOfficialSpriteCount,
                currentEvidence: "\(genericOfficialSpriteCount) 个通用官方图映射",
                nextEvidence: "补逐怪物专属 sprite，或补官方同图/换色规则",
                boundary: "不按通用官方图生成专属怪物图、动作帧、缩放、音效或完整图鉴"
            ),
            SourceMonsterArtEvidenceQueueRowModel(
                key: "extracted-stage",
                title: "已提取源图复核",
                mappingCount: extractedStageSpriteCount,
                currentEvidence: "\(extractedStageSpriteCount) 个已提取源图映射",
                nextEvidence: "补 provenance、hash、透明度、动作帧和原版比例锚点",
                boundary: "不按现有单张 sprite 推断动作帧、缩放、音效或完整图鉴"
            ),
            SourceMonsterArtEvidenceQueueRowModel(
                key: "source-roster-art-gap",
                title: "源表未出场 sprite",
                mappingCount: sourceRosterArtGapCount,
                currentEvidence: "\(SourceMonsterDatabaseMetrics.sourceOnlySpriteCoverageText) 源表未进关卡怪物已有单张 sprite：\(sourceRosterArtGapNamesText)",
                nextEvidence: "补出场证明、战斗缩放/锚点、动作帧和运行时关卡关系",
                boundary: "不按源表缺口、best-farm 文本、现有单张 sprite 或 Steam 50+ 下限生成缺失怪物、动作帧、技能、掉落或完整图鉴"
            )
        ]
    }

    static var artEvidenceQueueCount: Int {
        artEvidenceQueueRows.count
    }

    static var artEvidenceQueueCoverage: Int {
        artEvidenceQueueRows
            .filter { $0.key != "source-roster-art-gap" }
            .reduce(0) { $0 + $1.mappingCount }
    }

    static var artEvidenceQueueSourceRosterArtGapCoverage: Int {
        artEvidenceQueueRows.first { $0.key == "source-roster-art-gap" }?.mappingCount ?? 0
    }
}

private struct SourceMonsterArtMappingView: View {
    private let mappings = SourceMonsterArtMappingMetrics.mappings

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "源名",
                    value: "\(SourceMonsterArtMappingMetrics.sourceNameCount)"
                )
                SourceRuneSummaryPill(
                    label: "源图",
                    value: "\(SourceMonsterArtMappingMetrics.extractedStageSpriteCount)"
                )
                SourceRuneSummaryPill(
                    label: "通用",
                    value: "\(SourceMonsterArtMappingMetrics.genericOfficialSpriteCount)"
                )
                SourceRuneSummaryPill(
                    label: "近似",
                    value: "\(SourceMonsterArtMappingMetrics.typeNearApproximationCount)"
                )
                SourceRuneSummaryPill(
                    label: "美术覆盖",
                    value: SourceMonsterArtMappingMetrics.artMappingCoverageText
                )
                SourceRuneSummaryPill(
                    label: "美术门槛",
                    value: "\(SourceMonsterArtMappingMetrics.artEvidenceGateCount)"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "接入队列",
                    value: "\(SourceMonsterArtMappingMetrics.artEvidenceQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "队列覆盖",
                    value: "\(SourceMonsterArtMappingMetrics.artEvidenceQueueCoverage)/\(SourceMonsterArtMappingMetrics.sourceNameCount)"
                )
                SourceRuneSummaryPill(
                    label: "源表缺图",
                    value: "\(SourceMonsterArtMappingMetrics.artEvidenceQueueSourceRosterArtGapCoverage)"
                )
            }

            HStack {
                Text("图片族")
                Spacer()
                Text("\(SourceMonsterArtMappingMetrics.spriteFamilyCount)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("源表未进关卡")
                Spacer()
                Text("\(SourceMonsterArtMappingMetrics.sourceRosterArtGapCount)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }

            HStack {
                Text("源表单张 sprite")
                Spacer()
                Text(SourceMonsterDatabaseMetrics.sourceOnlySpriteResourceText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)
            }

            Text(SourceMonsterArtMappingMetrics.rosterBoundaryText)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(SourceMonsterArtMappingMetrics.artEvidenceGateBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(SourceMonsterArtMappingMetrics.artEvidenceQueueBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text("该表展示关卡组成怪物名到本地战斗图的当前映射；源表单张 sprite 只作未进关卡怪物素材证据。近似项只复用已有来源图，不绘制或替换新怪物图。非史莱姆不得回退到史莱姆图。")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("回退/旧裁图")
                Spacer()
                Text("\(SourceMonsterArtMappingMetrics.slimeFallbackMappings.count)/\(SourceMonsterArtMappingMetrics.legacyUICropMappings.count)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceMonsterArtMappingMetrics.artEvidenceGateRows) { row in
                        SourceMonsterArtEvidenceGateRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "专属美术接入门槛",
                    value: "\(SourceMonsterArtMappingMetrics.artEvidenceGateCount) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceMonsterArtMappingMetrics.artEvidenceQueueRows) { row in
                        SourceMonsterArtEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "怪物美术接入队列",
                    value: "\(SourceMonsterArtMappingMetrics.artEvidenceQueueCount) 队列"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(mappings) { mapping in
                        SourceMonsterArtMappingRow(mapping: mapping)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(title: "完整怪物美术映射", value: "\(mappings.count) 行")
            }
        }
    }
}

private struct SourceMonsterArtEvidenceQueueRow: View {
    let row: SourceMonsterArtEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)

                    Text("\(row.mappingCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("补：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(row.boundary)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "type-near-approximation":
            return "arrow.triangle.branch"
        case "generic-official":
            return "photo.on.rectangle"
        case "extracted-stage":
            return "checkmark.seal.fill"
        case "source-roster-art-gap":
            return "list.bullet.rectangle"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
}

private struct SourceMonsterArtEvidenceGateRow: View {
    let row: SourceMonsterArtEvidenceGateRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(row.affectedMappingCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("证：\(row.requiredProof)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "full-roster-identity":
            return "list.bullet.rectangle"
        case "dedicated-sprite":
            return "photo"
        case "animation-frame-set":
            return "film"
        case "scale-anchor":
            return "ruler"
        case "provenance-audit":
            return "checkmark.seal.fill"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
}

private struct SourceMonsterArtMappingRow: View {
    let mapping: StageMonsterArtMapping

    private var spriteName: String {
        GameArt.battleMonsterSpriteName(for: mapping.runtimeMonsterID)
    }

    var body: some View {
        HStack(spacing: 7) {
            PixelSprite(
                imageName: spriteName,
                size: CGSize(width: 22, height: 22)
            )

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(mapping.sourceName)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    if mapping.isStageLeader {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.orange)
                    }

                    Text(mapping.runtimeMonsterID)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                }

                Text("\(mapping.sampleStageCode) · \(mapping.sampleDifficulty.name) · \(spriteName)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }

            Spacer(minLength: 4)

            Text(fidelityLabel)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(fidelityColor)
                .lineLimit(1)
        }
        .padding(.vertical, 2)
    }

    private var fidelityLabel: String {
        switch mapping.fidelity {
        case .extractedStageSprite:
            return "源图"
        case .genericOfficialSprite:
            return "通用"
        case .typeNearApproximation:
            return "近似"
        }
    }

    private var fidelityColor: Color {
        switch mapping.fidelity {
        case .extractedStageSprite:
            return .green
        case .genericOfficialSprite:
            return .blue
        case .typeNearApproximation:
            return .orange
        }
    }
}

struct SourceMonsterAttackReviewRowModel: Identifiable, Equatable {
    let monsterName: String
    let sourceSkillID: String
    let sourceDamageType: String
    let sourceDelivery: String
    let activation: SkillActivation
    let runtimeElement: SkillDamageElement
    let runtimeDelivery: SkillDelivery
    let range: Int

    var id: String {
        sourceSkillID
    }

    var runtimeElementLabel: String {
        runtimeElement.battleLogLabel ?? "无"
    }

    var sourceDeliveryLabel: String {
        sourceDelivery.isEmpty ? "来源为空" : sourceDelivery
    }

    var runtimeDeliveryLabel: String {
        runtimeDelivery == .none ? "none" : runtimeDelivery.rawValue
    }
}

struct SourceMonsterAttackEvidenceGateRowModel: Identifiable, Equatable {
    let key: String
    let title: String
    let currentEvidence: String
    let missingEvidence: String
    let requiredProof: String
    let affectedRowCount: Int

    var id: String { key }
}

enum SourceMonsterAttackReviewMetrics {
    static let deliveryBoundaryText = "来源 delivery 为空；运行时不伪造投射物/范围形态"
    static let fullMonsterSkillBoundaryText = "完整怪物技能表/投射物/施法帧待核对"
    static let attackEvidenceGateBoundaryText = "接入门槛只定义怪物攻击缺失证据，不生成怪物技能、投射物、公式、动作帧或音效"

    static var mappings: [SourceMonsterAttackReviewRowModel] {
        SourceSkillCatalog.runtimeMonsterAttackMappings.compactMap { mapping in
            guard SourceSkillCatalog.sourceSkillID(forMonsterNamed: mapping.monsterName) == mapping.sourceSkillID,
                  let sourceSkill = SourceSkillCatalog.skill(id: mapping.sourceSkillID) else {
                return nil
            }

            return SourceMonsterAttackReviewRowModel(
                monsterName: mapping.monsterName,
                sourceSkillID: mapping.sourceSkillID,
                sourceDamageType: sourceSkill.damageType,
                sourceDelivery: sourceSkill.delivery,
                activation: sourceSkill.activation,
                runtimeElement: sourceSkill.runtimeDamageElement,
                runtimeDelivery: sourceSkill.runtimeDelivery,
                range: sourceSkill.range
            )
        }
    }

    static var mappingCount: Int {
        mappings.count
    }

    static var runtimeElementCount: Int {
        Set(mappings.map { $0.runtimeElement.rawValue }).count
    }

    static var baseAttackCount: Int {
        mappings.filter { $0.activation == .baseAttack }.count
    }

    static var emptySourceDeliveryCount: Int {
        mappings.filter(\.sourceDelivery.isEmpty).count
    }

    static var sourceRangeText: String {
        Set(mappings.map(\.range))
            .sorted()
            .map(String.init)
            .joined(separator: ",")
    }

    static var attackEvidenceGateRows: [SourceMonsterAttackEvidenceGateRowModel] {
        [
            SourceMonsterAttackEvidenceGateRowModel(
                key: "skill-roster",
                title: "怪物技能名录",
                currentEvidence: "\(mappingCount) 已接入 / \(SourceMonsterArtMappingMetrics.sourceNameCount) 关卡组成名 / \(SourceMonsterDatabaseMetrics.rowCount) 源怪物行",
                missingEvidence: "逐怪物 source skill ID、技能名、归属和是否普通/精英/Boss 专属",
                requiredProof: "怪物页、技能表、原版资源或战斗记录能绑定怪物名与技能 ID",
                affectedRowCount: max(SourceMonsterArtMappingMetrics.sourceNameCount - mappingCount, 1)
            ),
            SourceMonsterAttackEvidenceGateRowModel(
                key: "delivery-hit-shape",
                title: "delivery/命中形态",
                currentEvidence: "\(emptySourceDeliveryCount)/\(mappingCount) 已接入行来源 delivery 为空",
                missingEvidence: "近战、投射物、AOE、召唤、光环或无形态规则",
                requiredProof: "来源 delivery、命中类型字段或原版画面能证明形态",
                affectedRowCount: max(emptySourceDeliveryCount, 1)
            ),
            SourceMonsterAttackEvidenceGateRowModel(
                key: "trigger-cadence",
                title: "触发节奏/冷却",
                currentEvidence: "\(baseAttackCount) BASEATTACK 行；攻速来自怪物表量化",
                missingEvidence: "攻击次数、冷却、施法前摇、持续时间、刷新/叠加规则",
                requiredProof: "源字段、战斗日志、视频逐帧或可复现实测时间线",
                affectedRowCount: SourceMonsterArtMappingMetrics.sourceNameCount
            ),
            SourceMonsterAttackEvidenceGateRowModel(
                key: "target-formula",
                title: "目标与公式",
                currentEvidence: "运行时只保留元素标签和 none delivery",
                missingEvidence: "目标选择、倍率公式、抗性/状态/暴击/范围结算顺序",
                requiredProof: "技能公式、怪物页或实测能复算命中与伤害",
                affectedRowCount: SourceMonsterArtMappingMetrics.sourceNameCount
            ),
            SourceMonsterAttackEvidenceGateRowModel(
                key: "animation-sfx",
                title: "动作帧/SFX",
                currentEvidence: "当前为本地 incoming cue，不是原版投射物或音效",
                missingEvidence: "施放、飞行、命中、受击关键帧和原版音频",
                requiredProof: "原版资源、官方视频帧采样或可复现录屏音轨",
                affectedRowCount: SourceMonsterArtMappingMetrics.sourceNameCount
            )
        ]
    }

    static var attackEvidenceGateCount: Int {
        attackEvidenceGateRows.count
    }
}

private struct SourceMonsterAttackReviewView: View {
    private let mappings = SourceMonsterAttackReviewMetrics.mappings

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "映射",
                    value: "\(SourceMonsterAttackReviewMetrics.mappingCount)"
                )
                SourceRuneSummaryPill(
                    label: "元素",
                    value: "\(SourceMonsterAttackReviewMetrics.runtimeElementCount)"
                )
                SourceRuneSummaryPill(
                    label: "基础攻",
                    value: "\(SourceMonsterAttackReviewMetrics.baseAttackCount)"
                )
                SourceRuneSummaryPill(
                    label: "范围",
                    value: SourceMonsterAttackReviewMetrics.sourceRangeText
                )
                SourceRuneSummaryPill(
                    label: "攻击门槛",
                    value: "\(SourceMonsterAttackReviewMetrics.attackEvidenceGateCount)"
                )
            }

            Text("\(SourceMonsterAttackReviewMetrics.deliveryBoundaryText)；\(SourceMonsterAttackReviewMetrics.fullMonsterSkillBoundaryText)。")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(SourceMonsterAttackReviewMetrics.attackEvidenceGateBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("空 delivery")
                Spacer()
                Text("\(SourceMonsterAttackReviewMetrics.emptySourceDeliveryCount)/\(SourceMonsterAttackReviewMetrics.mappingCount)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceMonsterAttackReviewMetrics.attackEvidenceGateRows) { row in
                        SourceMonsterAttackEvidenceGateRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "怪物攻击接入门槛",
                    value: "\(SourceMonsterAttackReviewMetrics.attackEvidenceGateCount) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(mappings) { mapping in
                        SourceMonsterAttackReviewRow(mapping: mapping)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(title: "已核对怪物攻击来源", value: "\(mappings.count) 行")
            }
        }
    }
}

private struct SourceMonsterAttackEvidenceGateRow: View {
    let row: SourceMonsterAttackEvidenceGateRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(row.affectedRowCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("证：\(row.requiredProof)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "skill-roster":
            return "list.bullet.rectangle"
        case "delivery-hit-shape":
            return "scope"
        case "trigger-cadence":
            return "timer"
        case "target-formula":
            return "function"
        case "animation-sfx":
            return "waveform"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
}

private struct SourceMonsterAttackReviewRow: View {
    let mapping: SourceMonsterAttackReviewRowModel

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(mapping.monsterName)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text("#\(mapping.sourceSkillID)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Text("源 \(mapping.sourceDamageType) · \(mapping.activation.rawValue) · range \(mapping.range)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)

                Text("运行时 \(mapping.runtimeElementLabel) · delivery \(mapping.runtimeDeliveryLabel) · \(mapping.sourceDeliveryLabel)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch mapping.runtimeElement {
        case .fire:
            return "flame.fill"
        case .cold:
            return "snowflake"
        case .lightning:
            return "bolt.fill"
        case .chaos:
            return "sparkles"
        case .physical, .none:
            return "burst.fill"
        }
    }

    private var tint: Color {
        switch mapping.runtimeElement {
        case .fire:
            return .orange
        case .cold:
            return .cyan
        case .lightning:
            return .yellow
        case .chaos:
            return .purple
        case .physical:
            return .secondary
        case .none:
            return .gray
        }
    }
}

struct ModeledActiveSkillValueRowModel: Identifiable, Equatable {
    let heroClass: HeroClass
    let skillID: String
    let skillName: String
    let activation: SkillActivation
    let cooldown: TimeInterval
    let levelValues: [Int]
    let damageElement: SkillDamageElement
    let delivery: SkillDelivery

    var id: String {
        skillID
    }

    var sourceSkill: SourceSkill? {
        SourceSkillCatalog.skill(id: skillID)
    }

    var levelCount: Int {
        levelValues.count
    }

    var levelOneValue: Int {
        value(at: 1)
    }

    var levelTenValue: Int {
        value(at: 10)
    }

    var elementLabel: String {
        damageElement.battleLogLabel ?? "无"
    }

    var valuesText: String {
        levelValues.enumerated()
            .map { index, value in "\(index + 1):\(value)" }
            .joined(separator: " ")
    }

    func value(at skillLevel: Int) -> Int {
        guard !levelValues.isEmpty else { return 0 }
        let index = min(max(skillLevel, 1), levelValues.count) - 1
        return levelValues[index]
    }
}

enum ModeledActiveSkillValueTableMetrics {
    static let modeledOnlyBoundaryText = "仅展示当前运行时已建模的 36 个命名主动技能"
    static let fullRuntimeBoundaryText = "其余源技能/基础攻击/怪物技能完整运行时语义待核对"

    static var rows: [ModeledActiveSkillValueRowModel] {
        HeroClass.allCases.flatMap { heroClass in
            HeroSkills.named(for: heroClass).map { skill in
                ModeledActiveSkillValueRowModel(
                    heroClass: heroClass,
                    skillID: skill.id,
                    skillName: skill.name,
                    activation: skill.activation,
                    cooldown: skill.cooldown,
                    levelValues: skill.levelValues,
                    damageElement: skill.damageElement,
                    delivery: skill.delivery
                )
            }
        }
    }

    static var rowCount: Int {
        rows.count
    }

    static var fullTenLevelTableCount: Int {
        rows.filter { $0.levelCount == 10 }.count
    }

    static var heroClassCount: Int {
        Set(rows.map(\.heroClass)).count
    }

    static var sourceBackedCount: Int {
        rows.filter { $0.sourceSkill != nil }.count
    }

    static var heroClassRowCounts: [HeroClass: Int] {
        Dictionary(
            uniqueKeysWithValues: HeroClass.allCases.map { heroClass in
                (heroClass, rows.filter { $0.heroClass == heroClass }.count)
            }
        )
    }

    static func row(skillID: String) -> ModeledActiveSkillValueRowModel? {
        rows.first { $0.skillID == skillID }
    }
}

private struct ModeledActiveSkillValueTableView: View {
    private let rows = ModeledActiveSkillValueTableMetrics.rows

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "技能",
                    value: "\(ModeledActiveSkillValueTableMetrics.rowCount)"
                )
                SourceRuneSummaryPill(
                    label: "10级表",
                    value: "\(ModeledActiveSkillValueTableMetrics.fullTenLevelTableCount)"
                )
                SourceRuneSummaryPill(
                    label: "职业",
                    value: "\(ModeledActiveSkillValueTableMetrics.heroClassCount)"
                )
                SourceRuneSummaryPill(
                    label: "源ID",
                    value: "\(ModeledActiveSkillValueTableMetrics.sourceBackedCount)/\(ModeledActiveSkillValueTableMetrics.rowCount)"
                )
            }

            Text("\(ModeledActiveSkillValueTableMetrics.modeledOnlyBoundaryText)；\(ModeledActiveSkillValueTableMetrics.fullRuntimeBoundaryText)。")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(rows) { row in
                        ModeledActiveSkillValueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(title: "运行时命名主动技能", value: "\(rows.count) 行")
            }
        }
    }
}

private struct ModeledActiveSkillValueRow: View {
    let row: ModeledActiveSkillValueRowModel

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text("#\(row.skillID)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                    Text(row.skillName)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Text("\(row.activation.rawValue) · \(row.elementLabel) · \(row.delivery.rawValue) · CD \(Int(row.cooldown.rounded()))s")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)

                Text("Lv1 \(row.levelOneValue) -> Lv10 \(row.levelTenValue) · \(row.valuesText)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.50)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 1) {
                Text(row.heroClass.rawValue)
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(SourceSkillCatalog.skill(id: row.skillID) == nil ? "源缺失" : "\(row.levelCount)级")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(SourceSkillCatalog.skill(id: row.skillID) == nil ? .orange : .green)
                    .lineLimit(1)
            }
            .frame(width: 42, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.delivery {
        case .buff:
            return "sparkles"
        case .heal, .resurrection:
            return "cross.fill"
        case .projectile, .projectileAOE, .summonProjectile:
            return "arrow.up.right"
        case .range, .rangeAOE:
            return "scope"
        case .trap:
            return "dot.circle.fill"
        case .melee, .meleeAOE:
            return "burst.fill"
        case .none:
            return "circle"
        }
    }

    private var tint: Color {
        switch row.damageElement {
        case .fire:
            return .orange
        case .cold:
            return .cyan
        case .lightning:
            return .yellow
        case .chaos:
            return .purple
        case .physical:
            return .secondary
        case .none:
            return .blue
        }
    }
}

struct SourcePassiveSkillDatabaseView: View {
    private let missingSourceIconStats = SourcePassiveSkillDatabaseMetrics.currentMissingSourceIconStats

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "被动",
                    value: "\(SourcePassiveSkillDatabaseMetrics.sourceRowCount)"
                )
                SourceRuneSummaryPill(
                    label: "属性",
                    value: "\(SourcePassiveSkillDatabaseMetrics.statCount)"
                )
                SourceRuneSummaryPill(
                    label: "图标",
                    value: SourcePassiveSkillDatabaseMetrics.sourceIconCoverageText
                )
                SourceRuneSummaryPill(
                    label: "图标族",
                    value: "\(SourcePassiveSkillDatabaseMetrics.sourceIconFamilyCount)"
                )
            }

            Text("该表只展示已核对的被动技能源行、当前源图标覆盖和本地运行时钩子边界；缺失来源图标的属性不使用本地图标替代。")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("缺图属性")
                Spacer()
                Text(missingSourceIconStats.sorted().joined(separator: " / "))
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PassiveSkills.all) { passiveSkill in
                        SourcePassiveSkillRow(passiveSkill: passiveSkill)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(title: "完整被动源表", value: "\(PassiveSkills.all.count) 行")
            }
        }
    }
}

struct SourcePassiveSkillRow: View {
    let passiveSkill: PassiveSkill

    var body: some View {
        HStack(spacing: 7) {
            passiveIcon
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text("#\(passiveSkill.id)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                    Text(passiveSkill.name)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Text(passiveSkillDetailText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 1) {
                Text(passiveSkill.heroClass?.rawValue ?? "未知")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(iconStatusText)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(iconName == nil ? .orange : .green)
                    .lineLimit(1)
            }
            .frame(width: 62, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var passiveIcon: some View {
        if let iconName {
            PixelSprite(
                imageName: iconName,
                size: CGSize(width: 18, height: 18)
            )
        } else {
            Image(systemName: "questionmark.square.dashed")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.orange)
                .accessibilityLabel("无源图标")
        }
    }

    private var iconName: String? {
        GameArt.passiveSkillIconName(for: passiveSkill)
    }

    private var iconStatusText: String {
        iconName == nil ? "无源图标" : "源图标"
    }

    private var passiveSkillDetailText: String {
        "\(passiveSkill.stat) · \(passiveSkill.valueType.rawValue) · \(passiveSkill.value)"
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

struct SourceSkillDamageReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "damage 类",
                    value: "\(SourceSkillDamageReviewMetrics.damageBucketCount)"
                )
                SourceRuneSummaryPill(
                    label: "物理源行",
                    value: "\(SourceSkillDamageReviewMetrics.physicalCount)"
                )
                SourceRuneSummaryPill(
                    label: "非物理已接",
                    value: "\(SourceSkillDamageReviewMetrics.nonPhysicalRuntimeCount)"
                )
                SourceRuneSummaryPill(
                    label: "最多",
                    value: SourceSkillDamageReviewMetrics.mostCommonDamageText
                )
            }

            Text("\(SourceSkillDamageReviewMetrics.damageBoundaryText)；\(SourceSkillDamageReviewMetrics.visualBoundaryText)；\(SourceSkillDamageReviewMetrics.runtimeBoundaryText)。")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceSkillDamageReviewMetrics.rows) { row in
                        SourceSkillDamageRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按源表 damage",
                    value: "\(SourceSkillDamageReviewMetrics.rows.count) 类"
                )
            }
        }
    }
}

private struct SourceSkillDamageRow: View {
    let row: SourceSkillDamageRowModel

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(row.damageType)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .lineLimit(1)
                Text("源 \(row.sourceCount) · 已接入 \(row.runtimeCount) · 待接入 \(row.pendingCount)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Text(row.sampleText)
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.damageType {
        case "Fire":
            return "flame.fill"
        case "Cold":
            return "snowflake"
        case "Lightning":
            return "bolt.fill"
        case "Chaos":
            return "sparkles"
        default:
            return "hammer.fill"
        }
    }

    private var tint: Color {
        switch row.damageType {
        case "Fire":
            return .orange
        case "Cold":
            return .cyan
        case "Lightning":
            return .yellow
        case "Chaos":
            return .purple
        default:
            return row.pendingCount == 0 ? .green : .secondary
        }
    }
}

private struct SourceSkillActivationDamageReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "字段组合",
                    value: "\(SourceSkillActivationDamageReviewMetrics.pairCount)"
                )
                SourceRuneSummaryPill(
                    label: "已接组合",
                    value: "\(SourceSkillActivationDamageReviewMetrics.runtimePairCount)"
                )
                SourceRuneSummaryPill(
                    label: "BASEATTACK",
                    value: SourceSkillActivationDamageReviewMetrics.baseAttackRuntimeText
                )
                SourceRuneSummaryPill(
                    label: "Chaos冷却",
                    value: SourceSkillActivationDamageReviewMetrics.cooldownChaosPendingIDText
                )
                SourceRuneSummaryPill(
                    label: "最大缺口",
                    value: SourceSkillActivationDamageReviewMetrics.largestPendingPairText
                )
            }

            Text("\(SourceSkillActivationDamageReviewMetrics.activationBoundaryText)；\(SourceSkillActivationDamageReviewMetrics.crossTabBoundaryText)；\(SourceSkillActivationDamageReviewMetrics.runtimeBoundaryText)。")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceSkillActivationDamageReviewMetrics.rows) { row in
                        SourceSkillActivationDamageRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按 activation × damage",
                    value: "\(SourceSkillActivationDamageReviewMetrics.rows.count) 类"
                )
            }
        }
    }
}

private struct SourceSkillActivationDamageRow: View {
    let row: SourceSkillActivationDamageRowModel

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(row.activation.rawValue)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .lineLimit(1)
                Text("源 \(row.sourceCount) · 已接入 \(row.runtimeCount) · 待接入 \(row.pendingCount)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(row.damageSummaryText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Spacer(minLength: 4)

            Text(row.sampleText)
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.activation {
        case .baseAttack:
            return "bolt.horizontal.fill"
        case .baseAttackCount:
            return "number.circle.fill"
        case .cooldown:
            return "timer"
        case .continuous:
            return "repeat.circle.fill"
        }
    }

    private var tint: Color {
        row.pendingCount == 0 ? .green : .orange
    }
}

private struct SourceSkillActivationDeliveryReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "字段组合",
                    value: "\(SourceSkillActivationDeliveryReviewMetrics.pairCount)"
                )
                SourceRuneSummaryPill(
                    label: "已接组合",
                    value: "\(SourceSkillActivationDeliveryReviewMetrics.runtimePairCount)"
                )
                SourceRuneSummaryPill(
                    label: "空 delivery",
                    value: SourceSkillActivationDeliveryReviewMetrics.emptyDeliveryRuntimeText
                )
                SourceRuneSummaryPill(
                    label: "最大缺口",
                    value: SourceSkillActivationDeliveryReviewMetrics.largestPendingPairText
                )
            }

            Text("\(SourceSkillActivationDeliveryReviewMetrics.crossTabBoundaryText)；\(SourceSkillActivationDeliveryReviewMetrics.emptyDeliveryBoundaryText)；\(SourceSkillActivationDeliveryReviewMetrics.runtimeBoundaryText)。")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceSkillActivationDeliveryReviewMetrics.rows) { row in
                        SourceSkillActivationDeliveryRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按 activation × delivery",
                    value: "\(SourceSkillActivationDeliveryReviewMetrics.rows.count) 类"
                )
            }
        }
    }
}

private struct SourceSkillActivationDeliveryRow: View {
    let row: SourceSkillActivationDeliveryRowModel

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(row.activation.rawValue)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .lineLimit(1)
                Text("源 \(row.sourceCount) · 已接入 \(row.runtimeCount) · 待接入 \(row.pendingCount)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(row.deliverySummaryText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)
            }

            Spacer(minLength: 4)

            Text(row.sampleText)
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.activation {
        case .baseAttack:
            return "bolt.horizontal.fill"
        case .baseAttackCount:
            return "number.circle.fill"
        case .cooldown:
            return "timer"
        case .continuous:
            return "repeat.circle.fill"
        }
    }

    private var tint: Color {
        row.pendingCount == 0 ? .green : .orange
    }
}

private struct SourceSkillDamageDeliveryReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "字段组合",
                    value: "\(SourceSkillDamageDeliveryReviewMetrics.pairCount)"
                )
                SourceRuneSummaryPill(
                    label: "已接组合",
                    value: "\(SourceSkillDamageDeliveryReviewMetrics.runtimePairCount)"
                )
                SourceRuneSummaryPill(
                    label: "空 delivery",
                    value: SourceSkillDamageDeliveryReviewMetrics.emptyDeliveryRuntimeText
                )
                SourceRuneSummaryPill(
                    label: "最大缺口",
                    value: SourceSkillDamageDeliveryReviewMetrics.largestPendingPairText
                )
            }

            Text("\(SourceSkillDamageDeliveryReviewMetrics.crossTabBoundaryText)；\(SourceSkillDamageDeliveryReviewMetrics.emptyDeliveryBoundaryText)；\(SourceSkillDamageDeliveryReviewMetrics.runtimeBoundaryText)。")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceSkillDamageDeliveryReviewMetrics.rows) { row in
                        SourceSkillDamageDeliveryRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按 damage × delivery",
                    value: "\(SourceSkillDamageDeliveryReviewMetrics.rows.count) 类"
                )
            }
        }
    }
}

private struct SourceSkillDamageDeliveryRow: View {
    let row: SourceSkillDamageDeliveryRowModel

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(row.damageType)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .lineLimit(1)
                Text("源 \(row.sourceCount) · 已接入 \(row.runtimeCount) · 待接入 \(row.pendingCount)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(row.deliverySummaryText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)
            }

            Spacer(minLength: 4)

            Text(row.sampleText)
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.damageType {
        case "Fire":
            return "flame.fill"
        case "Cold":
            return "snowflake"
        case "Lightning":
            return "bolt.fill"
        case "Chaos":
            return "sparkles"
        default:
            return "scope"
        }
    }

    private var tint: Color {
        row.pendingCount == 0 ? .green : .orange
    }
}

private struct SourceSkillDeliveryReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "delivery 桶",
                    value: "\(SourceSkillDeliveryReviewMetrics.deliveryBucketCount)"
                )
                SourceRuneSummaryPill(
                    label: "空 delivery",
                    value: "\(SourceSkillDeliveryReviewMetrics.emptyDeliveryCount)"
                )
                SourceRuneSummaryPill(
                    label: "非空已接",
                    value: "\(SourceSkillDeliveryReviewMetrics.nonEmptyRuntimeCount)/\(SourceSkillDeliveryReviewMetrics.nonEmptyDeliveryCount)"
                )
                SourceRuneSummaryPill(
                    label: "最多",
                    value: SourceSkillDeliveryReviewMetrics.mostCommonDeliveryText
                )
            }

            Text("\(SourceSkillDeliveryReviewMetrics.deliveryBoundaryText)；\(SourceSkillDeliveryReviewMetrics.emptyDeliveryBoundaryText)；\(SourceSkillDeliveryReviewMetrics.runtimeBoundaryText)。")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceSkillDeliveryReviewMetrics.rows) { row in
                        SourceSkillDeliveryRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按源表 delivery",
                    value: "\(SourceSkillDeliveryReviewMetrics.rows.count) 桶"
                )
            }
        }
    }
}

private struct SourceSkillDeliveryRow: View {
    let row: SourceSkillDeliveryRowModel

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(row.title)
                    .font(.system(size: 9, weight: .semibold, design: row.delivery.isEmpty ? .default : .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text("源 \(row.sourceCount) · 已接入 \(row.runtimeCount) · 待接入 \(row.pendingCount)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Text(row.sampleText)
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        if row.delivery.isEmpty {
            return "questionmark.diamond"
        }
        if row.delivery.contains("Trap") {
            return "smallcircle.filled.circle"
        }
        if row.delivery.contains("Summon") {
            return "plus.square.on.square"
        }
        if row.delivery.contains("Projectile") {
            return "arrow.right"
        }
        if row.delivery.contains("AOE") {
            return "circle.dotted"
        }
        return "scope"
    }

    private var tint: Color {
        if row.pendingCount == 0 {
            return .green
        }
        if row.delivery.isEmpty {
            return .orange
        }
        return .secondary
    }
}

struct SourceSkillRangeReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "range 桶",
                    value: "\(SourceSkillRangeReviewMetrics.rangeBucketCount)"
                )
                SourceRuneSummaryPill(
                    label: "范围跨度",
                    value: SourceSkillRangeReviewMetrics.minMaxRangeText
                )
                SourceRuneSummaryPill(
                    label: "已接入",
                    value: "\(SourceSkillRangeReviewMetrics.runtimeMappedCount)/\(SourceSkillRangeReviewMetrics.sourceCount)"
                )
                SourceRuneSummaryPill(
                    label: "最多",
                    value: SourceSkillRangeReviewMetrics.mostCommonRangeText
                )
            }

            Text("\(SourceSkillRangeReviewMetrics.rangeBoundaryText)；\(SourceSkillRangeReviewMetrics.runtimeBoundaryText)；\(SourceSkillRangeReviewMetrics.scaleBoundaryText)。")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(SourceSkillRangeReviewMetrics.rows) { row in
                        SourceSkillRangeRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按源表 range",
                    value: "\(SourceSkillRangeReviewMetrics.rows.count) 档"
                )
            }
        }
    }
}

private struct SourceSkillRangeRow: View {
    let row: SourceSkillRangeRowModel

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(row.title)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .lineLimit(1)
                Text("源 \(row.sourceCount) · 已接入 \(row.runtimeCount) · 待接入 \(row.pendingCount)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Text(row.sampleText)
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        if row.range >= 1000 {
            return "arrow.left.and.right"
        }
        if row.range <= 200 {
            return "scope"
        }
        return "ruler"
    }

    private var tint: Color {
        if row.pendingCount == 0 {
            return .green
        }
        if row.runtimeCount == 0 {
            return .orange
        }
        return .blue
    }
}

struct LocalSkillRuntimeCoverageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "源技能",
                    value: "\(LocalSkillRuntimeCoverageMetrics.sourceCount)"
                )
                SourceRuneSummaryPill(
                    label: "已接入",
                    value: "\(LocalSkillRuntimeCoverageMetrics.runtimeModeledCount)"
                )
                SourceRuneSummaryPill(
                    label: "待接入",
                    value: "\(LocalSkillRuntimeCoverageMetrics.pendingCount)"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "命名主动",
                    value: "\(LocalSkillRuntimeCoverageMetrics.heroNamedCount)"
                )
                SourceRuneSummaryPill(
                    label: "英雄普攻",
                    value: "\(LocalSkillRuntimeCoverageMetrics.heroBaseAttackCount)"
                )
                SourceRuneSummaryPill(
                    label: "怪物攻击",
                    value: "\(LocalSkillRuntimeCoverageMetrics.monsterAttackCount)"
                )
            }

            Text("\(LocalSkillRuntimeCoverageMetrics.sourceCatalogBoundaryText)；\(LocalSkillRuntimeCoverageMetrics.pendingRuntimeBoundaryText)；\(LocalSkillRuntimeCoverageMetrics.monsterBoundaryText)。")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 5) {
                ForEach(LocalSkillRuntimeCoverageMetrics.activationRows) { row in
                    LocalSkillRuntimeCoverageRow(row: row)
                }
            }

            HStack {
                Text("待接入示例")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(LocalSkillRuntimeCoverageMetrics.pendingPreviewText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }
        }
    }
}

private struct LocalSkillRuntimeCoverageRow: View {
    let row: LocalSkillRuntimeCoverageRowModel

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(row.activation.rawValue)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text("源 \(row.sourceCount) · 已接入 \(row.runtimeCount) · 待接入 \(row.pendingCount)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Text("\(row.runtimeCount)/\(row.sourceCount)")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(row.pendingCount == 0 ? .green : .orange)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.activation {
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

    private var tint: Color {
        row.pendingCount == 0 ? .green : .orange
    }
}

struct PendingSourceSkillReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "待接入",
                    value: "\(PendingSourceSkillReviewMetrics.pendingCount)"
                )
                SourceRuneSummaryPill(
                    label: "空形态",
                    value: "\(PendingSourceSkillReviewMetrics.emptyDeliveryCount)"
                )
                SourceRuneSummaryPill(
                    label: "激活类",
                    value: "\(PendingSourceSkillReviewMetrics.activationRows.count)"
                )
                SourceRuneSummaryPill(
                    label: "伤害类",
                    value: "\(PendingSourceSkillReviewMetrics.damageRows.count)"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "未命名",
                    value: "\(PendingSourceSkillReviewMetrics.sixDigitUnnamedPendingSkills.count)"
                )
                SourceRuneSummaryPill(
                    label: "基础候选",
                    value: "\(PendingSourceSkillReviewMetrics.pendingBaseAttackCandidateSkills.count)"
                )
                SourceRuneSummaryPill(
                    label: "触发候选",
                    value: "\(PendingSourceSkillReviewMetrics.pendingTriggeredCandidateSkills.count)"
                )
                SourceRuneSummaryPill(
                    label: "怪攻已接",
                    value: "\(PendingSourceSkillReviewMetrics.checkedMonsterAttackSkills.count)"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "未映射候选",
                    value: "\(PendingSourceSkillReviewMetrics.unmappedMonsterCandidateCount)"
                )
                SourceRuneSummaryPill(
                    label: "候选空形态",
                    value: "\(PendingSourceSkillReviewMetrics.unmappedMonsterCandidateEmptyDeliveryCount)"
                )
                SourceRuneSummaryPill(
                    label: "候选覆盖",
                    value: PendingSourceSkillReviewMetrics.unmappedMonsterCandidateCoverageText
                )
            }

            Text("\(PendingSourceSkillReviewMetrics.noRuntimeSemanticsBoundaryText)；\(PendingSourceSkillReviewMetrics.emptyDeliveryBoundaryText)；\(PendingSourceSkillReviewMetrics.monsterOwnershipBoundaryText)；\(PendingSourceSkillReviewMetrics.sixDigitUnnamedBoundaryText)；\(PendingSourceSkillReviewMetrics.checkedMonsterAttackBoundaryText)；\(PendingSourceSkillReviewMetrics.triggeredPendingBoundaryText)。")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(PendingSourceSkillReviewMetrics.unmappedMonsterCandidateBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "距离档",
                    value: "\(PendingSourceSkillReviewMetrics.rangeRows.count)"
                )
                SourceRuneSummaryPill(
                    label: "最多范围",
                    value: PendingSourceSkillReviewMetrics.mostCommonRangeText
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "有数值",
                    value: "\(PendingSourceSkillReviewMetrics.pendingValuedCandidateCount)"
                )
                SourceRuneSummaryPill(
                    label: "数值空形态",
                    value: "\(PendingSourceSkillReviewMetrics.pendingValuedEmptyDeliveryCount)"
                )
                SourceRuneSummaryPill(
                    label: "数值未命名",
                    value: "\(PendingSourceSkillReviewMetrics.pendingValuedUnnamedCount)"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "目录级",
                    value: "\(PendingSourceSkillReviewMetrics.catalogOnlyPendingCount)"
                )
                SourceRuneSummaryPill(
                    label: "值/范围",
                    value: "\(PendingSourceSkillReviewMetrics.valueRangeOnlyPendingCount)"
                )
                SourceRuneSummaryPill(
                    label: "最小证据",
                    value: "\(PendingSourceSkillReviewMetrics.minimumEvidencePendingCount)"
                )
            }

            Text(PendingSourceSkillReviewMetrics.readinessBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.readinessRows) { row in
                        PendingSourceSkillReadinessRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按证据成熟度",
                    value: "\(PendingSourceSkillReviewMetrics.readinessRows.count) 层"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "证明矩阵",
                    value: "\(PendingSourceSkillReviewMetrics.runtimeProofRowCount)"
                )
                SourceRuneSummaryPill(
                    label: "矩阵覆盖",
                    value: PendingSourceSkillReviewMetrics.runtimeProofCoverageText
                )
                SourceRuneSummaryPill(
                    label: "目录已证",
                    value: "\(PendingSourceSkillReviewMetrics.runtimeProofCatalogCount)"
                )
                SourceRuneSummaryPill(
                    label: "value已证",
                    value: "\(PendingSourceSkillReviewMetrics.runtimeProofValueRangeCount)"
                )
            }

            HStack {
                Text("runtime 已证")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.runtimeProofPositiveText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.54)
            }

            HStack {
                Text("runtime 缺证")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.runtimeProofMissingText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.38)
            }

            Text(PendingSourceSkillReviewMetrics.runtimeProofMatrixBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.runtimeProofRows) { row in
                        PendingSourceSkillRuntimeProofRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "runtime 证明矩阵",
                    value: PendingSourceSkillReviewMetrics.runtimeProofCoverageText
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "接入队列",
                    value: "\(PendingSourceSkillReviewMetrics.evidenceQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "队列覆盖",
                    value: "\(PendingSourceSkillReviewMetrics.evidenceQueueCoverageCount)"
                )
            }

            Text(PendingSourceSkillReviewMetrics.evidenceQueueBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.evidenceQueueRows) { row in
                        PendingSourceSkillEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "接入证据队列",
                    value: "\(PendingSourceSkillReviewMetrics.evidenceQueueCoverageCount) 项"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "交叉队列",
                    value: "\(PendingSourceSkillReviewMetrics.activationDamageQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "交叉覆盖",
                    value: "\(PendingSourceSkillReviewMetrics.activationDamageQueueCoverageCount)"
                )
                SourceRuneSummaryPill(
                    label: "交叉 value",
                    value: "\(PendingSourceSkillReviewMetrics.activationDamageValueCoverageCount)"
                )
                SourceRuneSummaryPill(
                    label: "交叉空形态",
                    value: "\(PendingSourceSkillReviewMetrics.activationDamageEmptyDeliveryCount)"
                )
            }

            Text(PendingSourceSkillReviewMetrics.activationDamageQueueBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.activationDamageQueueRows) { row in
                        PendingSourceSkillActivationDamageQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "activation × damage 队列",
                    value: "\(PendingSourceSkillReviewMetrics.activationDamageQueueCoverageCount) 项"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "range 队列",
                    value: "\(PendingSourceSkillReviewMetrics.rangeEvidenceQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "range 覆盖",
                    value: "\(PendingSourceSkillReviewMetrics.rangeEvidenceQueueCoverageCount)"
                )
                SourceRuneSummaryPill(
                    label: "range value",
                    value: "\(PendingSourceSkillReviewMetrics.rangeEvidenceQueueValueCoverageCount)"
                )
                SourceRuneSummaryPill(
                    label: "range 空形态",
                    value: "\(PendingSourceSkillReviewMetrics.rangeEvidenceQueueEmptyDeliveryCount)"
                )
            }

            Text(PendingSourceSkillReviewMetrics.rangeEvidenceQueueBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.rangeEvidenceQueueRows) { row in
                        PendingSourceSkillRangeEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "range 证据队列",
                    value: "\(PendingSourceSkillReviewMetrics.rangeEvidenceQueueCoverageCount) 项"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "前缀队列",
                    value: "\(PendingSourceSkillReviewMetrics.prefixEvidenceQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "前缀覆盖",
                    value: "\(PendingSourceSkillReviewMetrics.prefixEvidenceQueueCoverageCount)"
                )
                SourceRuneSummaryPill(
                    label: "前缀 value",
                    value: "\(PendingSourceSkillReviewMetrics.prefixEvidenceQueueValueCoverageCount)"
                )
                SourceRuneSummaryPill(
                    label: "前缀空形态",
                    value: "\(PendingSourceSkillReviewMetrics.prefixEvidenceQueueEmptyDeliveryCount)"
                )
            }

            Text(PendingSourceSkillReviewMetrics.prefixEvidenceQueueBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.prefixEvidenceQueueRows) { row in
                        PendingSourceSkillPrefixEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "ID 前缀证据队列",
                    value: "\(PendingSourceSkillReviewMetrics.prefixEvidenceQueueCoverageCount) 项"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "base 明细",
                    value: "\(PendingSourceSkillReviewMetrics.baseAttackEvidenceRowCount)"
                )
                SourceRuneSummaryPill(
                    label: "非物理",
                    value: "\(PendingSourceSkillReviewMetrics.nonPhysicalBaseAttackEvidenceRowCount)"
                )
                SourceRuneSummaryPill(
                    label: "物理",
                    value: "\(PendingSourceSkillReviewMetrics.physicalBaseAttackEvidenceRowCount)"
                )
                SourceRuneSummaryPill(
                    label: "明细覆盖",
                    value: PendingSourceSkillReviewMetrics.baseAttackEvidenceCoverageText
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 6) {
                    Text("非物理目录行")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                    ForEach(PendingSourceSkillReviewMetrics.nonPhysicalBaseAttackEvidenceRows) { row in
                        PendingSourceSkillBaseAttackEvidenceRow(row: row)
                    }

                    Divider()

                    Text("物理目录行")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                    ForEach(PendingSourceSkillReviewMetrics.physicalBaseAttackEvidenceRows) { row in
                        PendingSourceSkillBaseAttackEvidenceRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "基础攻击候选逐项",
                    value: "\(PendingSourceSkillReviewMetrics.baseAttackEvidenceRowCount) 行"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.unmappedMonsterCandidateRows) { row in
                        PendingSourceSkillUnmappedMonsterCandidateRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "未映射怪物同前缀候选",
                    value: "\(PendingSourceSkillReviewMetrics.unmappedMonsterCandidateCount) 行"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "接入门槛",
                    value: "\(PendingSourceSkillReviewMetrics.runtimeGateCount)"
                )
                SourceRuneSummaryPill(
                    label: "受影响",
                    value: "\(PendingSourceSkillReviewMetrics.pendingCount)"
                )
            }

            Text(PendingSourceSkillReviewMetrics.runtimeGateBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.runtimeGateRows) { row in
                        PendingSourceSkillRuntimeGateRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "runtime 接入门槛",
                    value: "\(PendingSourceSkillReviewMetrics.runtimeGateCount) 项"
                )
            }

            Text(PendingSourceSkillReviewMetrics.rangeBoundaryText)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("待接入示例")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.pendingPreviewText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }

            HStack(alignment: .top) {
                Text("触发/冷却候选")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.pendingTriggeredCandidateIDText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top) {
                Text("触发/冷却 value")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.pendingTriggeredValueText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top) {
                Text("value 页证据")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.pendingValueDetailEvidenceText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top) {
                Text("页面快照")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.pendingValueDetailSnapshotText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top) {
                Text("value 页路径")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.pendingValueDetailPathText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "value 明细",
                    value: "\(PendingSourceSkillReviewMetrics.valueEvidenceRowCount)"
                )
                SourceRuneSummaryPill(
                    label: "明细覆盖",
                    value: PendingSourceSkillReviewMetrics.valueEvidenceCoverageText
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "value 队列",
                    value: "\(PendingSourceSkillReviewMetrics.valueEvidenceQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "value 覆盖",
                    value: "\(PendingSourceSkillReviewMetrics.valueEvidenceQueueCoverageCount)"
                )
                SourceRuneSummaryPill(
                    label: "value 空形态",
                    value: "\(PendingSourceSkillReviewMetrics.valueEvidenceQueueEmptyDeliveryCount)"
                )
            }

            Text(PendingSourceSkillReviewMetrics.valueEvidenceQueueBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.valueEvidenceQueueRows) { row in
                        PendingSourceSkillValueEvidenceQueueRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "value 证据队列",
                    value: "\(PendingSourceSkillReviewMetrics.valueEvidenceQueueCoverageCount) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.valueEvidenceRows) { row in
                        PendingSourceSkillValueEvidenceRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "value/range 候选逐项",
                    value: "\(PendingSourceSkillReviewMetrics.valueEvidenceRowCount) 行"
                )
            }

            HStack(alignment: .top) {
                Text("最高 value 候选")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.highestPendingValueText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top) {
                Text("最高页证据")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.highestPendingValueDetailEvidenceText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top) {
                Text("最高页快照")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.highestPendingValueSnapshotText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top) {
                Text("最高页路径")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.highestPendingValueDetailPathText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(PendingSourceSkillReviewMetrics.sourcePageSnapshotBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top) {
                Text("Chaos 冷却 value")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.pendingCooldownChaosValueText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.purple)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "Chaos页",
                    value: "\(PendingSourceSkillReviewMetrics.cooldownChaosPageLocaleCount)"
                )
                SourceRuneSummaryPill(
                    label: "Chaos明细",
                    value: "\(PendingSourceSkillReviewMetrics.cooldownChaosPageEvidenceRowCount)"
                )
                SourceRuneSummaryPill(
                    label: "Chaos空形态",
                    value: "\(PendingSourceSkillReviewMetrics.cooldownChaosPageEmptyDeliveryCount)"
                )
                SourceRuneSummaryPill(
                    label: "Chaos未命名",
                    value: "\(PendingSourceSkillReviewMetrics.cooldownChaosPageUnnamedCount)"
                )
            }

            HStack(alignment: .top) {
                Text("Chaos 页快照")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.cooldownChaosPageSnapshotText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.purple)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(PendingSourceSkillReviewMetrics.cooldownChaosPageBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.cooldownChaosPageEvidenceRows) { row in
                        PendingSourceSkillCooldownChaosPageEvidenceRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "COOLDOWN/Chaos 页证据",
                    value: "\(PendingSourceSkillReviewMetrics.cooldownChaosPageEvidenceRowCount) 行"
                )
            }

            Text("\(PendingSourceSkillReviewMetrics.pendingValueReadinessText)；\(PendingSourceSkillReviewMetrics.triggeredValueBoundaryText)；\(PendingSourceSkillReviewMetrics.cooldownChaosValueBoundaryText)；\(PendingSourceSkillReviewMetrics.sourceValueReadinessBoundaryText)；\(PendingSourceSkillReviewMetrics.valueDetailBoundaryText)；\(PendingSourceSkillReviewMetrics.highestValueDetailBoundaryText)。")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top) {
                Text("伤害候选")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(PendingSourceSkillReviewMetrics.pendingDamageCandidateSummaryText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "视觉队列",
                    value: "\(PendingSourceSkillReviewMetrics.visualPriorityQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "视觉条目",
                    value: "\(PendingSourceSkillReviewMetrics.visualPriorityTotalEntries)"
                )
                SourceRuneSummaryPill(
                    label: "唯一覆盖",
                    value: PendingSourceSkillReviewMetrics.visualPriorityCoverageText
                )
                SourceRuneSummaryPill(
                    label: "重叠",
                    value: "\(PendingSourceSkillReviewMetrics.visualPriorityOverlapCount)"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "元素候选",
                    value: "\(PendingSourceSkillReviewMetrics.pendingElementalDamageCandidateSkills.count)"
                )
                SourceRuneSummaryPill(
                    label: "Chaos冷却",
                    value: "\(PendingSourceSkillReviewMetrics.pendingCooldownChaosValueCount)"
                )
                SourceRuneSummaryPill(
                    label: "未入视觉",
                    value: "\(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedPendingCount)"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "总队列",
                    value: "\(PendingSourceSkillReviewMetrics.visualReviewTotalQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "总覆盖",
                    value: PendingSourceSkillReviewMetrics.visualReviewTotalCoverageText
                )
                SourceRuneSummaryPill(
                    label: "低优先",
                    value: "\(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedPendingCount)"
                )
            }

            Text(PendingSourceSkillReviewMetrics.visualPriorityBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(PendingSourceSkillReviewMetrics.visualReviewTotalCoverageBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.visualPriorityRows) { row in
                        PendingSourceSkillVisualPriorityRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "视觉复核优先队列",
                    value: "\(PendingSourceSkillReviewMetrics.visualPriorityTotalEntries) 项"
                )
            }

            HStack(spacing: 6) {
                SourceRuneSummaryPill(
                    label: "未入队列",
                    value: "\(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedQueueCount)"
                )
                SourceRuneSummaryPill(
                    label: "未入覆盖",
                    value: "\(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedQueueCoverageCount)"
                )
                SourceRuneSummaryPill(
                    label: "未入 value",
                    value: "\(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedValueCount)"
                )
                SourceRuneSummaryPill(
                    label: "未入空形态",
                    value: "\(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedEmptyDeliveryCount)"
                )
            }

            Text(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedBoundaryText)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 6) {
                    Text("互斥差集")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                    ForEach(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedQueueRows) { row in
                        PendingSourceSkillEvidenceQueueRow(row: row)
                    }

                    Divider()

                    Text("按 activation")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                    ForEach(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedActivationRows) { row in
                        PendingSourceSkillCategoryRow(row: row)
                    }

                    Divider()

                    Text("按 damage")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                    ForEach(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedDamageRows) { row in
                        PendingSourceSkillCategoryRow(row: row)
                    }

                    Divider()

                    Text("按 range")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                    ForEach(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedRangeRows) { row in
                        PendingSourceSkillCategoryRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "未入视觉优先队列",
                    value: "\(PendingSourceSkillReviewMetrics.visualPriorityUnqueuedQueueCoverageCount) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.pendingDamageCandidateRows) { row in
                        PendingSourceSkillManifestRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "伤害类型候选清单",
                    value: "\(PendingSourceSkillReviewMetrics.pendingDamageCandidateRows.map(\.count).reduce(0, +)) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.pendingBaseAttackCandidatePrefixRows) { row in
                        PendingSourceSkillManifestRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "基础攻击候选清单",
                    value: "\(PendingSourceSkillReviewMetrics.pendingBaseAttackCandidateSkills.count) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.responsibilityRows) { row in
                        PendingSourceSkillCategoryRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按职责边界",
                    value: "\(PendingSourceSkillReviewMetrics.responsibilityRows.count) 项"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.activationRows) { row in
                        PendingSourceSkillCategoryRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按激活类型",
                    value: "\(PendingSourceSkillReviewMetrics.activationRows.count) 类"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.damageRows) { row in
                        PendingSourceSkillCategoryRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按伤害类型",
                    value: "\(PendingSourceSkillReviewMetrics.damageRows.count) 类"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.sourcePrefixRows) { row in
                        PendingSourceSkillCategoryRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按来源 ID 段",
                    value: "\(PendingSourceSkillReviewMetrics.sourcePrefixRows.count) 段"
                )
            }

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(PendingSourceSkillReviewMetrics.rangeRows) { row in
                        PendingSourceSkillCategoryRow(row: row)
                    }
                }
                .padding(.top, 4)
            } label: {
                SourceItemDisclosureLabel(
                    title: "按源表 range",
                    value: "\(PendingSourceSkillReviewMetrics.rangeRows.count) 档"
                )
            }
        }
    }
}

private struct PendingSourceSkillCategoryRow: View {
    let row: PendingSourceSkillCategoryRowModel

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(row.title)
                    .font(.system(size: 9, weight: .semibold, design: row.category == .activation || row.category == .damage ? .monospaced : .default))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text("样例 \(row.sampleText)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Spacer(minLength: 4)

            Text("\(row.count)")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(tint)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.category {
        case .activation:
            return "timer"
        case .damage:
            return "sparkles"
        case .sourcePrefix:
            return "number"
        case .responsibility:
            return "target"
        case .range:
            return "ruler"
        }
    }

    private var tint: Color {
        switch row.category {
        case .activation:
            return .orange
        case .damage:
            return damageTint
        case .sourcePrefix:
            return .secondary
        case .responsibility:
            return row.key == "checkedMonsterAttack" ? .green : .orange
        case .range:
            return .blue
        }
    }

    private var damageTint: Color {
        switch row.key {
        case "Fire":
            return .orange
        case "Cold":
            return .cyan
        case "Lightning":
            return .yellow
        case "Chaos":
            return .purple
        case "Physical":
            return .gray
        default:
            return .secondary
        }
    }
}

private struct PendingSourceSkillActivationDamageQueueRow: View {
    let row: PendingSourceSkillActivationDamageQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: iconName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
                    .frame(width: 18, height: 18)
                Circle()
                    .fill(damageTint)
                    .frame(width: 7, height: 7)
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.35), lineWidth: 0.5)
                    )
                    .offset(x: 2, y: 2)
            }
            .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                    Text("\(row.count)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.50)

                Text("样例 \(row.sampleText)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("下步：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.activation {
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

    private var damageTint: Color {
        switch row.damageType {
        case "Fire":
            return .orange
        case "Cold":
            return .cyan
        case "Lightning":
            return .yellow
        case "Chaos":
            return .purple
        case "Physical":
            return .gray
        default:
            return .secondary
        }
    }
}

private struct PendingSourceSkillRangeEvidenceQueueRow: View {
    let row: PendingSourceSkillRangeEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "ruler")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.blue)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)

                    Text("\(row.count)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                }

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.44)

                Text("样例 \(row.sampleText)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("下步：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct PendingSourceSkillValueEvidenceQueueRow: View {
    let row: PendingSourceSkillValueEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "number.circle")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)

                    Text("\(row.count)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.40)

                Text("样例 \(row.sampleText)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("下步：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct PendingSourceSkillReadinessRow: View {
    let row: PendingSourceSkillReadinessRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(row.count)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(tint)
                }

                Text("样例 \(row.sampleText)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)

                Text(row.missingEvidence)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "catalogOnly":
            return "list.bullet.rectangle"
        case "valueRangeOnly":
            return "number.square"
        default:
            return "checkmark.seal"
        }
    }

    private var tint: Color {
        switch row.key {
        case "catalogOnly":
            return .secondary
        case "valueRangeOnly":
            return .orange
        default:
            return row.count == 0 ? .secondary : .green
        }
    }
}

private struct PendingSourceSkillRuntimeProofRow: View {
    let row: PendingSourceSkillRuntimeProofRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                    Text(row.statusText)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(tint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.56)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.44)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "source-catalog":
            return "checkmark.seal.fill"
        case "value-range-detail":
            return "number.square"
        default:
            return "exclamationmark.triangle.fill"
        }
    }

    private var tint: Color {
        row.missingCount == 0 ? .green : .orange
    }
}

private struct PendingSourceSkillEvidenceQueueRow: View {
    let row: PendingSourceSkillEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(row.count)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(tint)
                }

                Text("样例 \(row.sampleText)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("下步：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "value-range-pages":
            return "number.square"
        case "nonphysical-baseattack-catalog":
            return "flame"
        case "physical-baseattack-catalog":
            return "target"
        case "unqueued-physical-value-pages":
            return "number.square"
        case "unqueued-physical-baseattack-catalog":
            return "scope"
        default:
            return "list.bullet.rectangle"
        }
    }

    private var tint: Color {
        switch row.key {
        case "value-range-pages":
            return .orange
        case "nonphysical-baseattack-catalog":
            return .purple
        case "physical-baseattack-catalog":
            return .gray
        case "unqueued-physical-value-pages":
            return .orange
        case "unqueued-physical-baseattack-catalog":
            return .gray
        default:
            return .secondary
        }
    }
}

private struct PendingSourceSkillValueEvidenceRow: View {
    let row: PendingSourceSkillValueEvidenceRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)

                    Text(row.skill.damageType)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(tint)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)

                Text(row.detailPath)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.skill.damageType {
        case "Fire":
            return "flame"
        case "Cold":
            return "snowflake"
        case "Chaos":
            return "sparkles"
        default:
            return "number.square"
        }
    }

    private var tint: Color {
        switch row.skill.damageType {
        case "Fire":
            return .orange
        case "Cold":
            return .cyan
        case "Chaos":
            return .purple
        default:
            return .gray
        }
    }
}

private struct PendingSourceSkillCooldownChaosPageEvidenceRow: View {
    let row: PendingSourceSkillCooldownChaosPageEvidenceRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.purple)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)

                    Text("单源页")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.orange)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)

                Text(row.localePathText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.40)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct PendingSourceSkillBaseAttackEvidenceRow: View {
    let row: PendingSourceSkillBaseAttackEvidenceRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.54)

                    Text(row.skill.damageType)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(tint)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text(row.catalogState)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.skill.damageType {
        case "Fire":
            return "flame"
        case "Cold":
            return "snowflake"
        case "Chaos":
            return "sparkles"
        default:
            return "target"
        }
    }

    private var tint: Color {
        switch row.skill.damageType {
        case "Fire":
            return .orange
        case "Cold":
            return .cyan
        case "Chaos":
            return .purple
        default:
            return .gray
        }
    }
}

private struct PendingSourceSkillPrefixEvidenceQueueRow: View {
    let row: PendingSourceSkillPrefixEvidenceQueueRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "number")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)

                    Text("\(row.count)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.44)

                Text(row.sampleText)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("补：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }
}

private struct PendingSourceSkillUnmappedMonsterCandidateRow: View {
    let row: PendingSourceSkillUnmappedMonsterCandidateRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.54)

                    Text(row.skill.damageType)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(tint)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)

                Text(row.stageEvidence)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.skill.damageType {
        case "Cold":
            return "snowflake"
        case "Chaos":
            return "sparkles"
        default:
            return "scope"
        }
    }

    private var tint: Color {
        switch row.skill.damageType {
        case "Cold":
            return .cyan
        case "Chaos":
            return .purple
        default:
            return .gray
        }
    }
}

private struct PendingSourceSkillRuntimeGateRow: View {
    let row: PendingSourceSkillRuntimeGateRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(row.affectedSkillCount)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }

                Text(row.currentEvidence)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)

                Text("缺：\(row.missingEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("证：\(row.requiredProof)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "localized-identity":
            return "textformat"
        case "ownership-target":
            return "person.2.fill"
        case "delivery-hit-shape":
            return "scope"
        case "formula-scaling":
            return "function"
        case "trigger-cadence":
            return "timer"
        case "animation-vfx":
            return "sparkles"
        case "audio-sfx":
            return "speaker.wave.2.fill"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
}

private struct PendingSourceSkillVisualPriorityRow: View {
    let row: PendingSourceSkillVisualPriorityRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    Text("\(row.count)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(tint)

                    Text("\(row.valueCount)v/\(row.emptyDeliveryCount)空")
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Text("样例 \(row.sampleText)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.46)

                Text("现：\(row.currentEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("下步：\(row.nextEvidence)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("界限：\(row.boundary)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch row.key {
        case "elemental-vfx":
            return "sparkles"
        case "cooldown-chaos":
            return "timer"
        case "unmapped-monster-prefix":
            return "questionmark.diamond.fill"
        case "highest-value-pages":
            return "number.square"
        default:
            return "list.bullet.rectangle"
        }
    }

    private var tint: Color {
        switch row.key {
        case "elemental-vfx":
            return .purple
        case "cooldown-chaos":
            return .purple
        case "unmapped-monster-prefix":
            return .orange
        case "highest-value-pages":
            return .red
        default:
            return .secondary
        }
    }
}

private struct PendingSourceSkillManifestRow: View {
    let row: PendingSourceSkillCategoryRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "number")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(row.count)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Text(row.sampleIDs.joined(separator: ", "))
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 2)
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
        let value = sourceSkill.sourceValue.map { " · V\($0)" } ?? ""
        return "\(sourceSkill.damageType) · \(delivery) · R\(sourceSkill.range)\(value)"
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
