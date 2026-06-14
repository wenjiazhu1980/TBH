import SwiftUI

/// 设置面板
struct SettingsView: View {
    @ObservedObject var gameEngine: GameEngine
    @State private var showResetAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                GroupBox("游戏") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("当前章节")
                            Spacer()
                            Text(gameEngine.progress.currentChapter.name)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("当前难度")
                            Spacer()
                            Text(gameEngine.progress.currentDifficulty.name)
                                .foregroundColor(.secondary)
                        }
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
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }

                GroupBox("关于") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TBH: Task Bar Hero — macOS Edition")
                            .font(.system(size: 10, weight: .medium))
                        Text("v0.1.0 MVP")
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
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        return "\(h)h \(m)m"
    }
}
