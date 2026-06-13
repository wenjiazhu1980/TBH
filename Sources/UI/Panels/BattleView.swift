import SwiftUI

/// 战斗面板 — 使用像素精灵
struct BattleView: View {
    @ObservedObject var gameEngine: GameEngine

    var body: some View {
        Group {
            if let battle = gameEngine.currentBattle {
                VStack(spacing: 12) {
                    // 战斗场景 — 像素精灵
                    BattleSceneView(battle: battle)
                        .frame(height: 160)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)

                    // 战斗日志
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 3) {
                            ForEach(battle.log.suffix(6)) { entry in
                                BattleLogRow(entry: entry)
                            }
                        }
                    }
                    .frame(maxHeight: 100)

                    // 战斗状态
                    if battle.isOver {
                        BattleResultBanner(result: battle.result)
                    } else {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.6)
                            Text("战斗中...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            } else {
                VStack {
                    Image(systemName: "sword.crossed")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("等待战斗开始...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
}

/// 战斗场景 — 像素风动画
struct BattleSceneView: View {
    @ObservedObject var battle: Battle
    @State private var heroAttackOffset: CGFloat = 0
    @State private var monsterShake: CGFloat = 0

    var body: some View {
        HStack(spacing: 40) {
            // 英雄
            VStack(spacing: 4) {
                PixelSprite(imageName: "battle_knight", size: CGSize(width: 80, height: 100))
                    .offset(x: heroAttackOffset)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                            heroAttackOffset = 10
                        }
                    }

                // 英雄血条
                VStack(spacing: 1) {
                    Text("HP")
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundColor(.green)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color.green.opacity(0.2))
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geo.size.width * CGFloat(battle.heroHP) / CGFloat(max(battle.hero.maxHP, 1)))
                        }
                    }
                    .frame(width: 60, height: 4)
                    .cornerRadius(1)
                }
            }

            // VS
            Text("VS")
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(.orange)

            // 怪物
            VStack(spacing: 4) {
                BattleSprite(monsterID: battle.monster.id, size: CGSize(width: 80, height: 100))
                    .offset(x: monsterShake)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                            monsterShake = 3
                        }
                    }

                // 怪物血条
                VStack(spacing: 1) {
                    Text("HP")
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundColor(.red)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color.red.opacity(0.2))
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: geo.size.width * CGFloat(battle.monsterHP) / CGFloat(max(battle.monster.hp, 1)))
                        }
                    }
                    .frame(width: 60, height: 4)
                    .cornerRadius(1)
                }
            }
        }
        .padding()
    }
}

struct StatBadge: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, design: .monospaced))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
        }
    }
}

struct BattleLogRow: View {
    let entry: BattleLogEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: entry.attacker == .hero ? "arrow.right" : "arrow.left")
                .font(.system(size: 8))
                .foregroundColor(entry.attacker == .hero ? .blue : .red)
            Text(entry.attacker == .hero ? "英雄" : "怪物")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(entry.attacker == .hero ? .blue : .red)
            Text("造成 \(entry.damage) 伤害")
                .font(.system(size: 9, design: .monospaced))
            if entry.isCrit {
                Text("暴击!")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.orange)
            }
        }
    }
}

struct BattleResultBanner: View {
    let result: BattleResult?

    var body: some View {
        Group {
            switch result {
            case .victory(let rewards):
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("胜利! +\(rewards.xp)XP +\(rewards.gold)G")
                        .font(.system(size: 11, weight: .medium))
                    if let item = rewards.lootItem {
                        Text("[\(item.name)]")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: item.rarity.color))
                    }
                }
            case .defeat:
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("战败! 英雄复活中...")
                        .font(.system(size: 11, weight: .medium))
                }
            case .none:
                EmptyView()
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(4)
    }
}

// Hex 颜色扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
