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
                        Text("v0.2.0")
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
