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
                        .frame(height: 176)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.34),
                                    Color(red: 0.10, green: 0.11, blue: 0.15).opacity(0.46)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
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
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text("战斗中...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 18)
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
    @State private var heroStrike = false
    @State private var monsterStrike = false
    @State private var heroHit = false
    @State private var monsterHit = false

    var body: some View {
        ZStack {
            HStack(spacing: 10) {
                CombatantView(
                    name: battle.hero.heroClass.rawValue,
                    imageName: GameArt.heroSpriteName(for: battle.hero.heroClass),
                    hp: battle.heroHP,
                    maxHP: battle.hero.maxHP,
                    tint: .green,
                    spriteSize: CGSize(width: 96, height: 116),
                    isHero: true,
                    isStriking: heroStrike,
                    isHit: heroHit
                )

                VStack(spacing: 2) {
                    Text("VS")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(.orange)
                    if let last = battle.log.last {
                        Text(last.isCrit ? "CRIT" : "\(last.damage)")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(last.isCrit ? .yellow : .secondary)
                            .frame(height: 10)
                    } else {
                        Text("")
                            .frame(height: 10)
                    }
                }
                .frame(width: 38)

                CombatantView(
                    name: battle.monster.name,
                    imageName: GameArt.monsterSpriteName(for: battle.monster.id),
                    hp: battle.monsterHP,
                    maxHP: battle.monster.hp,
                    tint: .red,
                    spriteSize: CGSize(width: 96, height: 116),
                    isHero: false,
                    isStriking: monsterStrike,
                    isHit: monsterHit
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .onChange(of: battle.log.count) { _ in
            playHitAnimation()
        }
    }

    private func playHitAnimation() {
        guard let attacker = battle.log.last?.attacker else { return }

        withAnimation(.easeOut(duration: 0.10)) {
            heroStrike = attacker == .hero
            monsterStrike = attacker == .monster
            heroHit = attacker == .monster
            monsterHit = attacker == .hero
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.62)) {
                heroStrike = false
                monsterStrike = false
                heroHit = false
                monsterHit = false
            }
        }
    }
}

struct CombatantView: View {
    let name: String
    let imageName: String
    let hp: Int
    let maxHP: Int
    let tint: Color
    let spriteSize: CGSize
    let isHero: Bool
    let isStriking: Bool
    let isHit: Bool

    var body: some View {
        VStack(spacing: 5) {
            ZStack(alignment: .center) {
                Ellipse()
                    .fill(Color.black.opacity(0.26))
                    .frame(width: 74, height: 14)
                    .offset(y: 48)

                PixelSprite(imageName: imageName, size: spriteSize)
                    .scaleEffect(isStriking ? 1.08 : 1.0, anchor: .center)
                    .offset(x: isStriking ? (isHero ? 12 : -12) : 0)
                    .brightness(isHit ? 0.28 : 0)
                    .saturation(isHit ? 0.75 : 1)

                if isHit {
                    Image(systemName: "burst.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(color: .orange, radius: 5)
                        .offset(x: isHero ? 24 : -24, y: -22)
                }
            }
            .frame(width: 104, height: 118)

            Text(name)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(width: 88)

            VStack(spacing: 2) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(tint.opacity(0.22))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(tint)
                            .frame(width: geo.size.width * CGFloat(hp) / CGFloat(max(maxHP, 1)))
                    }
                }
                .frame(width: 78, height: 5)

                Text("\(hp)/\(maxHP)")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
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
