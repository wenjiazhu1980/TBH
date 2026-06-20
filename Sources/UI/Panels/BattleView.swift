import SwiftUI

/// 战斗面板 — 使用像素精灵
struct BattleView: View {
    @ObservedObject var gameEngine: GameEngine

    var body: some View {
        Group {
            if let battle = gameEngine.currentBattle {
                VStack(spacing: BattlePanelMetrics.sectionSpacing) {
                    let battleLogPresentation = BattleLogPresentation(from: gameEngine.recentBattleLog)

                    // 战斗场景 — 像素精灵
                    BattleSceneView(
                        battle: battle,
                        progress: gameEngine.progress,
                        latestLogEntry: gameEngine.recentBattleLog.last,
                        logTrigger: gameEngine.recentBattleLog.last?.id
                    )
                        .frame(maxWidth: .infinity)
                        .frame(height: BattleSceneMetrics.compactHeight)
                        .overlay(alignment: .top) {
                            StageHeaderView(
                                progress: gameEngine.progress,
                                battle: battle,
                                clearTargetReduction: gameEngine.runeTree.stageClearTargetReduction
                            )
                            .padding(.horizontal, 8)
                            .padding(.top, 8)
                        }
                        .overlay(alignment: .bottom) {
                            Group {
                                if battle.isOver {
                                    BattleResultBanner(
                                        result: battle.result,
                                        displayedVictoryRewards: displayedVictoryRewards(for: battle.result),
                                        levelCapStatus: HeroLevelPacing.levelCapStatus(
                                            for: gameEngine.hero,
                                            progress: gameEngine.progress
                                        )
                                    )
                                } else {
                                    BattleOngoingStatusView(battle: battle)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.bottom, 8)
                        }
                        .layoutPriority(2)

                    BattleLogPanel(
                        entries: battleLogPresentation.visibleEntries,
                        heroFocusEntries: battleLogPresentation.heroFocusEntries,
                        totalCount: battleLogPresentation.totalCount
                    )
                    .layoutPriority(1)
                }
                .padding(.horizontal, BattlePanelMetrics.horizontalPadding)
                .padding(.vertical, BattlePanelMetrics.verticalPadding)
                .frame(maxHeight: .infinity, alignment: .top)
            } else {
                VStack {
                    if gameEngine.progress.isAwaitingNewGamePlus {
                        CompletionSettlementView(
                            progress: gameEngine.progress,
                            statistics: gameEngine.statistics,
                            onDeferNewGamePlus: {
                                gameEngine.save()
                            },
                            onStartNextPlaythrough: {
                                gameEngine.startNextPlaythrough()
                            }
                        )
                    } else if let reason = gameEngine.battleLockReason {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.orange)
                        Text(reason)
                            .font(.system(size: 11, weight: .semibold))
                            .multilineTextAlignment(.center)
                        Text("开启对应箱子获得灵魂石后可挑战。")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("等待战斗开始...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxHeight: .infinity)
            }
        }
    }

    private func displayedVictoryRewards(for result: BattleResult?) -> BattleResult.Rewards? {
        guard case .victory(let rewards) = result else { return nil }
        return gameEngine.previewVictoryRewards(rewards)
    }
}

enum BattlePanelMetrics {
    static let sectionSpacing: CGFloat = 5
    static let horizontalPadding: CGFloat = 12
    static let verticalPadding: CGFloat = 6
}

struct CompletionSettlementView: View {
    let progress: ProgressTracker
    let statistics: GameStatistics
    let onDeferNewGamePlus: () -> Void
    let onStartNextPlaythrough: () -> Void
    @State private var didDeferNewGamePlus = false

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "crown.fill")
                .font(.system(size: 32))
                .foregroundColor(.yellow)

            VStack(spacing: 4) {
                Text(CompletionSettlementLabels.title(for: progress))
                    .font(.system(size: 15, weight: .bold))
                Text("\(progress.currentDifficulty.name) \(progress.currentStage.displayName) 已完成")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 10) {
                CompletionStatView(title: "击杀", value: statistics.monstersKilled.formatted())
                CompletionStatView(title: "金币", value: statistics.totalGoldEarned.formatted())
                CompletionStatView(title: "死亡", value: statistics.deaths.formatted())
            }

            VStack(alignment: .leading, spacing: 5) {
                CompletionPreviewRow(
                    systemImage: "shield.lefthalf.filled",
                    title: "\(progress.nextPlaythroughText)敌方",
                    value: "x\(String(format: "%.2f", NewGamePlusTuning.enemyStatMultiplier(for: progress.playthrough + 1)))"
                )
                CompletionPreviewRow(
                    systemImage: "sparkles",
                    title: "经验/金币",
                    value: "x\(String(format: "%.2f", NewGamePlusTuning.rewardMultiplier(for: progress.playthrough + 1)))"
                )
                CompletionPreviewRow(
                    systemImage: "shippingbox.fill",
                    title: "保留内容",
                    value: CompletionSettlementLabels.retainedProgressText
                )
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.70))
            .clipShape(RoundedRectangle(cornerRadius: 6))

            HStack(spacing: 8) {
                Button {
                    didDeferNewGamePlus = true
                    onDeferNewGamePlus()
                } label: {
                    Label(CompletionSettlementLabels.deferButtonTitle, systemImage: "bookmark.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button {
                    onStartNextPlaythrough()
                } label: {
                    Label(CompletionSettlementLabels.startButtonTitle(for: progress), systemImage: "arrow.clockwise.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }

            if didDeferNewGamePlus {
                Text(CompletionSettlementLabels.deferredConfirmationText)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
    }
}

enum CompletionSettlementLabels {
    static let deferButtonTitle = "稍后开启"
    static let deferredConfirmationText = "已保留结算状态，游戏会暂停在通关页。"
    static let retainedProgressText = "角色、背包、符文、技能"

    static func title(for progress: ProgressTracker) -> String {
        "\(progress.playthroughText)通关"
    }

    static func startButtonTitle(for progress: ProgressTracker) -> String {
        "开启\(progress.nextPlaythroughText)"
    }
}

private struct CompletionPreviewRow: View {
    let systemImage: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.accentColor)
                .frame(width: 12)

            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
    }
}

private struct CompletionStatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(width: 76, height: 36)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct PlayerBattleStatusSummary: Equatable {
    let allBadges: [PlayerBattleStatusBadge]
    let visibleBadges: [PlayerBattleStatusBadge]
    let overflowCount: Int
}

enum PlayerBattleStatusBadge: String, CaseIterable {
    static let inlineVisibleLimit = 5

    case aegisField
    case sacredBlade
    case wrathOfHeaven
    case flameHydra
    case snowstorm
    case swiftSurge
    case sanctuary
    case mightBlessing
    case wardingBlessing
    case generalsCry
    case quickLoader
    case chargedTrap
    case crossbowTurret
    case shockCurrent
    case axeSpin
    case bloodlust

    private static let skillNameMapping: [(name: String, badge: PlayerBattleStatusBadge)] = [
        ("神盾领域", .aegisField),
        ("神圣之刃", .sacredBlade),
        ("天堂之怒", .wrathOfHeaven),
        ("烈焰九头蛇", .flameHydra),
        ("暴风雪", .snowstorm),
        ("迅捷觉醒", .swiftSurge),
        ("圣域", .sanctuary),
        ("将军怒吼", .generalsCry),
        ("快速装填", .quickLoader),
        ("充能陷阱", .chargedTrap),
        ("弩炮塔", .crossbowTurret),
        ("电击弩箭电流", .shockCurrent),
        ("旋转斧", .axeSpin),
        ("嗜血", .bloodlust)
    ]

    private static let continuousSkillNameMapping: [(name: String, badge: PlayerBattleStatusBadge)] = [
        ("力量祝福", .mightBlessing),
        ("守护祝福", .wardingBlessing)
    ]

    var systemImageName: String {
        switch self {
        case .aegisField:
            return "shield.fill"
        case .sacredBlade:
            return "plus.circle.fill"
        case .wrathOfHeaven, .shockCurrent:
            return "bolt.fill"
        case .flameHydra:
            return "flame.fill"
        case .snowstorm:
            return "snowflake"
        case .swiftSurge, .quickLoader:
            return "speedometer"
        case .sanctuary:
            return "cross.fill"
        case .mightBlessing:
            return "star.fill"
        case .wardingBlessing:
            return "shield.fill"
        case .generalsCry:
            return "speaker.wave.2.fill"
        case .chargedTrap:
            return "dot.circle.fill"
        case .crossbowTurret:
            return "target"
        case .axeSpin:
            return "arrow.triangle.2.circlepath"
        case .bloodlust:
            return "drop.fill"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .aegisField:
            return "神盾领域"
        case .sacredBlade:
            return "神圣之刃"
        case .wrathOfHeaven:
            return "天堂之怒"
        case .flameHydra:
            return "烈焰九头蛇"
        case .snowstorm:
            return "暴风雪"
        case .swiftSurge:
            return "迅捷觉醒"
        case .sanctuary:
            return "圣域"
        case .mightBlessing:
            return "力量祝福"
        case .wardingBlessing:
            return "守护祝福"
        case .generalsCry:
            return "将军怒吼"
        case .quickLoader:
            return "快速装填"
        case .chargedTrap:
            return "充能陷阱"
        case .crossbowTurret:
            return "弩炮塔"
        case .shockCurrent:
            return "电击弩箭电流"
        case .axeSpin:
            return "旋转斧"
        case .bloodlust:
            return "嗜血"
        }
    }

    var tint: Color {
        switch self {
        case .aegisField, .sanctuary:
            return Color(red: 0.45, green: 0.90, blue: 0.72)
        case .sacredBlade, .generalsCry, .mightBlessing:
            return Color(red: 1.0, green: 0.78, blue: 0.18)
        case .wardingBlessing:
            return Color(red: 0.48, green: 0.92, blue: 0.80)
        case .wrathOfHeaven, .shockCurrent:
            return Color(red: 1.0, green: 0.92, blue: 0.20)
        case .flameHydra:
            return Color(red: 1.0, green: 0.42, blue: 0.16)
        case .snowstorm:
            return Color(red: 0.45, green: 0.90, blue: 1.0)
        case .swiftSurge, .quickLoader:
            return Color(red: 0.56, green: 0.78, blue: 1.0)
        case .chargedTrap, .crossbowTurret:
            return Color(red: 0.78, green: 0.72, blue: 0.58)
        case .axeSpin:
            return Color(red: 0.82, green: 0.82, blue: 0.88)
        case .bloodlust:
            return .red
        }
    }

    static func visible(for battle: Battle) -> [PlayerBattleStatusBadge] {
        visible(
            activeBuffNames: battle.activeBuffNames,
            continuousSkillNames: battle.continuousSkillNames,
            shieldRemaining: battle.activeHeroDamageShieldRemaining,
            trapCharges: battle.activeChargedTrapChargesRemaining
        )
    }

    static func summary(for battle: Battle) -> PlayerBattleStatusSummary {
        summary(
            activeBuffNames: battle.activeBuffNames,
            continuousSkillNames: battle.continuousSkillNames,
            shieldRemaining: battle.activeHeroDamageShieldRemaining,
            trapCharges: battle.activeChargedTrapChargesRemaining
        )
    }

    static func summary(
        activeBuffNames: [String],
        continuousSkillNames: [String] = [],
        shieldRemaining: Int,
        trapCharges: Int
    ) -> PlayerBattleStatusSummary {
        let allBadges = visible(
            activeBuffNames: activeBuffNames,
            continuousSkillNames: continuousSkillNames,
            shieldRemaining: shieldRemaining,
            trapCharges: trapCharges
        )
        let visibleBadges = Array(allBadges.prefix(inlineVisibleLimit))
        return PlayerBattleStatusSummary(
            allBadges: allBadges,
            visibleBadges: visibleBadges,
            overflowCount: max(0, allBadges.count - visibleBadges.count)
        )
    }

    static func visible(
        activeBuffNames: [String],
        continuousSkillNames: [String] = [],
        shieldRemaining: Int,
        trapCharges: Int
    ) -> [PlayerBattleStatusBadge] {
        let activeNames = Set(activeBuffNames)
        let continuousNames = Set(continuousSkillNames)
        let continuousBadges: [PlayerBattleStatusBadge] = continuousSkillNameMapping.compactMap { mapping in
            continuousNames.contains(mapping.name) ? mapping.badge : nil
        }
        let activeBadges: [PlayerBattleStatusBadge] = skillNameMapping.compactMap { mapping in
            guard activeNames.contains(mapping.name) else { return nil }
            switch mapping.badge {
            case .aegisField:
                return shieldRemaining > 0 ? mapping.badge : nil
            case .chargedTrap:
                return trapCharges > 0 ? mapping.badge : nil
            default:
                return mapping.badge
            }
        }
        return uniqueBadges(continuousBadges + activeBadges)
    }

    private static func uniqueBadges(_ badges: [PlayerBattleStatusBadge]) -> [PlayerBattleStatusBadge] {
        var seen = Set<PlayerBattleStatusBadge>()
        return badges.filter { seen.insert($0).inserted }
    }

    func displayLabel(shieldRemaining: Int, trapCharges: Int) -> String {
        switch self {
        case .aegisField:
            return "神盾 \(shieldRemaining)"
        case .sacredBlade:
            return "圣刃"
        case .wrathOfHeaven:
            return "天怒"
        case .flameHydra:
            return "九头蛇"
        case .snowstorm:
            return "暴雪"
        case .swiftSurge:
            return "迅捷"
        case .sanctuary:
            return "圣域"
        case .mightBlessing:
            return "力量"
        case .wardingBlessing:
            return "守护"
        case .generalsCry:
            return "怒吼"
        case .quickLoader:
            return "装填"
        case .chargedTrap:
            return "陷阱 x\(trapCharges)"
        case .crossbowTurret:
            return "炮塔"
        case .shockCurrent:
            return "电流"
        case .axeSpin:
            return "旋斧"
        case .bloodlust:
            return "嗜血"
        }
    }
}

enum PlayerBattleDeployable: String, CaseIterable {
    case flameHydra
    case chargedTrap
    case crossbowTurret

    private static let skillNameMapping: [(name: String, deployable: PlayerBattleDeployable)] = [
        ("烈焰九头蛇", .flameHydra),
        ("充能陷阱", .chargedTrap),
        ("弩炮塔", .crossbowTurret)
    ]

    var accessibilityLabel: String {
        switch self {
        case .flameHydra:
            return "烈焰九头蛇"
        case .chargedTrap:
            return "充能陷阱"
        case .crossbowTurret:
            return "弩炮塔"
        }
    }

    static func visible(for battle: Battle) -> [PlayerBattleDeployable] {
        visible(
            activeBuffNames: battle.activeBuffNames,
            trapCharges: battle.activeChargedTrapChargesRemaining
        )
    }

    static func visible(activeBuffNames: [String], trapCharges: Int) -> [PlayerBattleDeployable] {
        let activeNames = Set(activeBuffNames)
        return skillNameMapping.compactMap { mapping in
            guard activeNames.contains(mapping.name) else { return nil }
            if mapping.deployable == .chargedTrap && trapCharges <= 0 {
                return nil
            }
            return mapping.deployable
        }
    }
}

struct BattleOngoingStatusView: View {
    @ObservedObject var battle: Battle

    private var statusSummary: PlayerBattleStatusSummary {
        PlayerBattleStatusBadge.summary(for: battle)
    }

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)

            if statusSummary.allBadges.isEmpty {
                Text("战斗中...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                HStack(spacing: 4) {
                    ForEach(statusSummary.visibleBadges, id: \.self) { badge in
                        PlayerBattleStatusBadgeView(
                            badge: badge,
                            shieldRemaining: battle.activeHeroDamageShieldRemaining,
                            trapCharges: battle.activeChargedTrapChargesRemaining
                        )
                    }

                    if statusSummary.overflowCount > 0 {
                        Spacer(minLength: 2)

                        Text("+\(statusSummary.overflowCount)")
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .foregroundColor(.primary.opacity(0.82))
                            .padding(.horizontal, 3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 22, maxHeight: 22)
    }
}

private struct PlayerBattleStatusBadgeView: View {
    let badge: PlayerBattleStatusBadge
    let shieldRemaining: Int
    let trapCharges: Int

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: badge.systemImageName)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(badge.tint)

            Text(badge.displayLabel(shieldRemaining: shieldRemaining, trapCharges: trapCharges))
                .font(.system(size: 8, weight: .semibold, design: .rounded))
                .foregroundColor(.primary.opacity(0.86))
                .lineLimit(1)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(badge.tint.opacity(0.14))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(badge.tint.opacity(0.40), lineWidth: 0.6)
        )
        .accessibilityLabel(badge.accessibilityLabel)
    }
}

struct StageHeaderView: View {
    let progress: ProgressTracker
    @ObservedObject var battle: Battle
    let clearTargetReduction: Int

    var body: some View {
        let encounter = progress.currentEncounterState(clearTargetReduction: clearTargetReduction)
        let waveProgress = battle.monsterCount > 1
            ? "\(battle.currentMonsterNumber)/\(battle.monsterCount)"
            : "\(encounter.waveEncounterNumber)/\(encounter.waveEncounterTarget)"

        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 1) {
                Text(progress.currentStage.displayName)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.94))
                    .lineLimit(1)
                Text("\(progress.playthroughText) · \(progress.currentChapter.name) · \(progress.currentDifficulty.name) · 波 \(encounter.wave)/\(encounter.waveCount) · \(waveProgress) · \(battle.monster.name)")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.72))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer()

            if progress.currentStage.isBoss {
                Label("Boss", systemImage: "crown.fill")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }

            Text(progress.stageProgressText(clearTargetReduction: clearTargetReduction))
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.50))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

enum BattleIncomingCue: String, CaseIterable {
    case physical
    case fire
    case cold
    case lightning
    case chaos

    static func visible(for entry: BattleLogEntry?) -> BattleIncomingCue? {
        guard let entry, entry.attacker == .monster, entry.kind == .damage, entry.damage > 0 else {
            return nil
        }

        switch entry.damageElement {
        case .fire:
            return .fire
        case .cold:
            return .cold
        case .lightning:
            return .lightning
        case .chaos:
            return .chaos
        case .physical, .none:
            return .physical
        }
    }

    var tint: Color {
        switch self {
        case .physical:
            return Color(red: 0.92, green: 0.94, blue: 0.96)
        case .fire:
            return Color(red: 1.0, green: 0.34, blue: 0.10)
        case .cold:
            return Color(red: 0.36, green: 0.88, blue: 1.0)
        case .lightning:
            return Color(red: 1.0, green: 0.92, blue: 0.20)
        case .chaos:
            return Color(red: 0.74, green: 0.36, blue: 1.0)
        }
    }

    var secondaryTint: Color {
        switch self {
        case .physical:
            return Color(red: 0.46, green: 0.52, blue: 0.58)
        case .fire:
            return Color(red: 1.0, green: 0.82, blue: 0.16)
        case .cold, .lightning:
            return Color.white
        case .chaos:
            return Color(red: 0.20, green: 0.96, blue: 0.60)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .physical:
            return "敌方物理来袭"
        case .fire:
            return "敌方火焰来袭"
        case .cold:
            return "敌方冰冷来袭"
        case .lightning:
            return "敌方闪电来袭"
        case .chaos:
            return "敌方混沌来袭"
        }
    }
}

enum BattleImpactCue: String, CaseIterable {
    case physicalSlash
    case axeSpinImpact
    case bleedRendImpact
    case shockwaveImpact
    case earthquakeImpact
    case earthquakeRockExplosion
    case fireBurst
    case explosiveBoltImpact
    case meteorImpact
    case coldBurst
    case frostBoltImpact
    case lightningSpark
    case shockBoltImpact
    case shockCurrentImpact
    case chaosBurst
    case trapBurst
    case summonProjectile

    static func visible(for entry: BattleLogEntry?) -> BattleImpactCue? {
        guard let entry, entry.kind == .damage, entry.damage > 0 else { return nil }
        guard entry.attacker.isHeroSide else { return nil }

        if let skillSpecificCue = skillSpecificCue(for: entry.skillName) {
            return skillSpecificCue
        }

        switch entry.delivery {
        case .trap:
            return .trapBurst
        case .summonProjectile:
            return .summonProjectile
        case .buff, .heal, .resurrection, .none:
            break
        case .melee, .meleeAOE, .projectile, .projectileAOE, .range, .rangeAOE:
            break
        }

        switch entry.damageElement {
        case .fire:
            return .fireBurst
        case .cold:
            return .coldBurst
        case .lightning:
            return .lightningSpark
        case .chaos:
            return .chaosBurst
        case .physical:
            return .physicalSlash
        case .none:
            switch entry.delivery {
            case .melee, .meleeAOE, .projectile, .projectileAOE, .range, .rangeAOE:
                return .physicalSlash
            case .trap, .summonProjectile, .buff, .heal, .resurrection, .none:
                return nil
            }
        }
    }

    private static func skillSpecificCue(for skillName: String?) -> BattleImpactCue? {
        guard let skillName else { return nil }
        if skillName == "旋转斧流血追击" {
            return .bleedRendImpact
        }
        if skillName == "粉碎强击冲击波" {
            return .shockwaveImpact
        }
        if skillName == "大地强击岩石爆炸" {
            return .earthquakeRockExplosion
        }
        if skillName == "电击弩箭电流" {
            return .shockCurrentImpact
        }
        guard let skill = HeroSkills.skill(forLogSkillName: skillName) else { return nil }
        switch skill.id {
        case "60501":
            return .axeSpinImpact
        case "50101":
            return .explosiveBoltImpact
        case "50201":
            return .frostBoltImpact
        case "50601":
            return .shockBoltImpact
        case "30601":
            return .meteorImpact
        case "60401":
            return .earthquakeImpact
        default:
            return nil
        }
    }

    var tint: Color {
        switch self {
        case .physicalSlash:
            return Color(red: 0.90, green: 0.94, blue: 0.96)
        case .axeSpinImpact:
            return Color(red: 0.96, green: 0.74, blue: 0.38)
        case .bleedRendImpact:
            return Color(red: 0.96, green: 0.14, blue: 0.12)
        case .shockwaveImpact:
            return Color(red: 0.84, green: 0.90, blue: 0.96)
        case .earthquakeImpact:
            return Color(red: 0.72, green: 0.58, blue: 0.42)
        case .earthquakeRockExplosion:
            return Color(red: 0.88, green: 0.64, blue: 0.34)
        case .fireBurst:
            return Color(red: 1.0, green: 0.42, blue: 0.12)
        case .explosiveBoltImpact:
            return Color(red: 1.0, green: 0.36, blue: 0.08)
        case .meteorImpact:
            return Color(red: 1.0, green: 0.50, blue: 0.14)
        case .coldBurst:
            return Color(red: 0.40, green: 0.92, blue: 1.0)
        case .frostBoltImpact:
            return Color(red: 0.34, green: 0.90, blue: 1.0)
        case .lightningSpark:
            return Color(red: 1.0, green: 0.92, blue: 0.20)
        case .shockBoltImpact:
            return Color(red: 1.0, green: 0.88, blue: 0.18)
        case .shockCurrentImpact:
            return Color(red: 1.0, green: 0.96, blue: 0.28)
        case .chaosBurst:
            return Color(red: 0.72, green: 0.42, blue: 1.0)
        case .trapBurst:
            return Color(red: 0.42, green: 1.0, blue: 0.88)
        case .summonProjectile:
            return Color(red: 1.0, green: 0.66, blue: 0.18)
        }
    }

    var secondaryTint: Color {
        switch self {
        case .physicalSlash:
            return Color(red: 0.42, green: 0.50, blue: 0.56)
        case .axeSpinImpact:
            return Color(red: 0.48, green: 0.30, blue: 0.16)
        case .bleedRendImpact:
            return Color(red: 0.42, green: 0.02, blue: 0.04)
        case .shockwaveImpact:
            return Color(red: 0.36, green: 0.44, blue: 0.52)
        case .earthquakeImpact:
            return Color(red: 0.34, green: 0.24, blue: 0.16)
        case .earthquakeRockExplosion:
            return Color(red: 0.42, green: 0.26, blue: 0.14)
        case .fireBurst:
            return Color(red: 1.0, green: 0.86, blue: 0.18)
        case .explosiveBoltImpact:
            return Color(red: 0.48, green: 0.12, blue: 0.04)
        case .meteorImpact:
            return Color(red: 0.50, green: 0.18, blue: 0.08)
        case .coldBurst:
            return Color.white
        case .frostBoltImpact:
            return Color.white
        case .lightningSpark:
            return Color.white
        case .shockBoltImpact:
            return Color.white
        case .shockCurrentImpact:
            return Color(red: 0.42, green: 0.54, blue: 0.72)
        case .chaosBurst:
            return Color(red: 0.22, green: 0.92, blue: 0.58)
        case .trapBurst:
            return Color(red: 0.08, green: 0.32, blue: 0.34)
        case .summonProjectile:
            return Color(red: 0.72, green: 0.16, blue: 0.08)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .physicalSlash:
            return "物理命中"
        case .axeSpinImpact:
            return "旋转斧命中"
        case .bleedRendImpact:
            return "流血追击"
        case .shockwaveImpact:
            return "冲击波命中"
        case .earthquakeImpact:
            return "地震命中"
        case .earthquakeRockExplosion:
            return "岩石爆炸"
        case .fireBurst:
            return "火焰命中"
        case .explosiveBoltImpact:
            return "爆炸弩箭命中"
        case .meteorImpact:
            return "陨石冲击"
        case .coldBurst:
            return "冰冷命中"
        case .frostBoltImpact:
            return "寒霜弩箭命中"
        case .lightningSpark:
            return "闪电命中"
        case .shockBoltImpact:
            return "电击弩箭命中"
        case .shockCurrentImpact:
            return "电击电流命中"
        case .chaosBurst:
            return "混沌命中"
        case .trapBurst:
            return "陷阱爆发"
        case .summonProjectile:
            return "召唤投射命中"
        }
    }
}

enum BattleTrajectoryCue: String, CaseIterable {
    case meleeArc
    case projectile
    case rapidVolley
    case trackingVolley
    case arrowRain
    case piercingArrow
    case lodgedArrow
    case explosiveBolt
    case frostBolt
    case shockBolt
    case shockCurrentArc
    case rangeField
    case summonProjectile
    case trapArc
    case chargeDash
    case leapArc
    case meteorFall
    case axeSpinArc
    case bleedRendTrail
    case shockwaveRing
    case groundRupture
    case rockBurst

    static func visible(for entry: BattleLogEntry?) -> BattleTrajectoryCue? {
        guard let entry, entry.kind == .damage, entry.damage > 0 else { return nil }
        guard entry.attacker.isHeroSide else { return nil }

        if let skillSpecificCue = skillSpecificCue(for: entry.skillName) {
            return skillSpecificCue
        }

        switch entry.delivery {
        case .melee, .meleeAOE:
            return .meleeArc
        case .projectile, .projectileAOE:
            return .projectile
        case .range, .rangeAOE:
            return .rangeField
        case .summonProjectile:
            return .summonProjectile
        case .trap:
            return .trapArc
        case .buff, .heal, .resurrection, .none:
            return nil
        }
    }

    private static func skillSpecificCue(for skillName: String?) -> BattleTrajectoryCue? {
        guard let skillName else { return nil }
        if skillName == "旋转斧流血追击" {
            return .bleedRendTrail
        }
        if skillName == "粉碎强击冲击波" {
            return .shockwaveRing
        }
        if skillName == "大地强击岩石爆炸" {
            return .rockBurst
        }
        if skillName == "电击弩箭电流" {
            return .shockCurrentArc
        }
        guard let skill = HeroSkills.skill(forLogSkillName: skillName) else { return nil }
        switch skill.id {
        case "20101":
            return .rapidVolley
        case "20201":
            return .trackingVolley
        case "20301":
            return .arrowRain
        case "20501":
            return .piercingArrow
        case "20601":
            return .lodgedArrow
        case "50101":
            return .explosiveBolt
        case "50201":
            return .frostBolt
        case "50601":
            return .shockBolt
        case "10201":
            return .chargeDash
        case "60101":
            return .leapArc
        case "30601":
            return .meteorFall
        case "60401":
            return .groundRupture
        case "60501":
            return .axeSpinArc
        default:
            return nil
        }
    }

    var tint: Color {
        switch self {
        case .meleeArc:
            return Color(red: 0.92, green: 0.96, blue: 1.0)
        case .projectile:
            return Color(red: 0.40, green: 0.92, blue: 1.0)
        case .rapidVolley:
            return Color(red: 0.90, green: 0.94, blue: 0.96)
        case .trackingVolley:
            return Color(red: 0.78, green: 0.90, blue: 1.0)
        case .arrowRain:
            return Color(red: 0.82, green: 0.90, blue: 0.94)
        case .piercingArrow:
            return Color(red: 0.94, green: 0.96, blue: 0.98)
        case .lodgedArrow:
            return Color(red: 0.92, green: 0.84, blue: 0.72)
        case .explosiveBolt:
            return Color(red: 1.0, green: 0.42, blue: 0.12)
        case .frostBolt:
            return Color(red: 0.40, green: 0.92, blue: 1.0)
        case .shockBolt:
            return Color(red: 1.0, green: 0.92, blue: 0.20)
        case .shockCurrentArc:
            return Color(red: 1.0, green: 0.96, blue: 0.28)
        case .rangeField:
            return Color(red: 0.86, green: 0.90, blue: 1.0)
        case .summonProjectile:
            return Color(red: 1.0, green: 0.62, blue: 0.16)
        case .trapArc:
            return Color(red: 0.42, green: 1.0, blue: 0.88)
        case .chargeDash:
            return Color(red: 0.90, green: 0.94, blue: 0.96)
        case .leapArc:
            return Color(red: 0.96, green: 0.86, blue: 0.58)
        case .meteorFall:
            return Color(red: 1.0, green: 0.52, blue: 0.14)
        case .axeSpinArc:
            return Color(red: 0.96, green: 0.74, blue: 0.38)
        case .bleedRendTrail:
            return Color(red: 0.96, green: 0.14, blue: 0.12)
        case .shockwaveRing:
            return Color(red: 0.84, green: 0.90, blue: 0.96)
        case .groundRupture:
            return Color(red: 0.72, green: 0.58, blue: 0.42)
        case .rockBurst:
            return Color(red: 0.88, green: 0.64, blue: 0.34)
        }
    }

    static func tint(for entry: BattleLogEntry) -> Color {
        switch entry.damageElement {
        case .none, .physical:
            return Color(red: 0.86, green: 0.90, blue: 0.94)
        case .fire:
            return Color(red: 1.0, green: 0.45, blue: 0.14)
        case .cold:
            return Color(red: 0.40, green: 0.92, blue: 1.0)
        case .lightning:
            return Color(red: 1.0, green: 0.92, blue: 0.20)
        case .chaos:
            return Color(red: 0.72, green: 0.42, blue: 1.0)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .meleeArc:
            return "近战弧光轨迹"
        case .projectile:
            return "投射物轨迹"
        case .rapidVolley:
            return "快速连射轨迹"
        case .trackingVolley:
            return "追踪箭轨迹"
        case .arrowRain:
            return "箭雨轨迹"
        case .piercingArrow:
            return "穿透箭轨迹"
        case .lodgedArrow:
            return "穿刺箭轨迹"
        case .explosiveBolt:
            return "爆炸弩箭轨迹"
        case .frostBolt:
            return "寒霜弩箭轨迹"
        case .shockBolt:
            return "电击弩箭轨迹"
        case .shockCurrentArc:
            return "电流扩散轨迹"
        case .rangeField:
            return "范围技能轨迹"
        case .summonProjectile:
            return "召唤投射轨迹"
        case .trapArc:
            return "陷阱触发轨迹"
        case .chargeDash:
            return "冲锋轨迹"
        case .leapArc:
            return "跃击轨迹"
        case .meteorFall:
            return "陨石下落轨迹"
        case .axeSpinArc:
            return "旋转斧轨迹"
        case .bleedRendTrail:
            return "流血追击轨迹"
        case .shockwaveRing:
            return "冲击波轨迹"
        case .groundRupture:
            return "地裂轨迹"
        case .rockBurst:
            return "岩石爆裂轨迹"
        }
    }
}

enum BattleUtilityCue: String, CaseIterable {
    case healPulse
    case sanctuaryPulse
    case resurrectionRise
    case shieldField
    case wrathOfHeavenStorm
    case sacredBladeGlow
    case swiftSurgeHaste
    case quickLoaderHaste
    case generalsCryRoar
    case bloodlustSurge
    case buffAura

    static func visible(for entry: BattleLogEntry?) -> BattleUtilityCue? {
        guard let entry, entry.attacker.isHeroSide else { return nil }
        guard entry.kind == .heal || entry.kind == .buff else { return nil }
        guard let skillName = entry.skillName,
              let skill = HeroSkills.skill(forLogSkillName: skillName) else {
            return entry.kind == .buff ? .buffAura : .healPulse
        }

        switch skill.id {
        case "10401":
            return .shieldField
        case "40301":
            return .wrathOfHeavenStorm
        case "10501":
            return .sacredBladeGlow
        case "20401":
            return .swiftSurgeHaste
        case "50301":
            return .quickLoaderHaste
        case "60301":
            return .generalsCryRoar
        case "60601":
            return .bloodlustSurge
        case "10601", "40601":
            return .resurrectionRise
        case "40101":
            return .healPulse
        case "40401":
            return .sanctuaryPulse
        default:
            switch entry.kind {
            case .heal:
                return .healPulse
            case .buff:
                return .buffAura
            case .damage, .dodge, .block:
                return nil
            }
        }
    }

    var tint: Color {
        switch self {
        case .healPulse:
            return Color(red: 0.45, green: 1.0, blue: 0.70)
        case .sanctuaryPulse:
            return Color(red: 0.50, green: 0.96, blue: 0.86)
        case .resurrectionRise:
            return Color(red: 1.0, green: 0.92, blue: 0.32)
        case .shieldField:
            return Color(red: 0.42, green: 0.82, blue: 1.0)
        case .wrathOfHeavenStorm:
            return Color(red: 1.0, green: 0.88, blue: 0.24)
        case .sacredBladeGlow:
            return Color(red: 1.0, green: 0.84, blue: 0.24)
        case .swiftSurgeHaste:
            return Color(red: 0.35, green: 0.76, blue: 1.0)
        case .quickLoaderHaste:
            return Color(red: 0.58, green: 1.0, blue: 0.45)
        case .generalsCryRoar:
            return Color(red: 0.96, green: 0.70, blue: 0.28)
        case .bloodlustSurge:
            return Color(red: 1.0, green: 0.18, blue: 0.18)
        case .buffAura:
            return Color(red: 0.76, green: 0.84, blue: 1.0)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .healPulse:
            return "治疗反馈"
        case .sanctuaryPulse:
            return "圣域反馈"
        case .resurrectionRise:
            return "复活反馈"
        case .shieldField:
            return "护盾反馈"
        case .wrathOfHeavenStorm:
            return "天堂之怒反馈"
        case .sacredBladeGlow:
            return "神圣之刃反馈"
        case .swiftSurgeHaste:
            return "迅捷觉醒反馈"
        case .quickLoaderHaste:
            return "快速装填反馈"
        case .generalsCryRoar:
            return "将军怒吼反馈"
        case .bloodlustSurge:
            return "嗜血反馈"
        case .buffAura:
            return "增益反馈"
        }
    }
}

enum BattleSceneMetrics {
    static let officialWidth: CGFloat = 776
    static let officialHeight: CGFloat = 180
    static let expectedPopoverContentWidth: CGFloat = 616
    static let compactHeight: CGFloat = 300
    static let maximumVisualScaleHeight: CGFloat = 300
    static let referenceCompactHeight: CGFloat = 92
    static let groundHeightRatio: CGFloat = 0.14
    static let groundPlatformWidthRatio: CGFloat = 0.90
    static let partyPlatformXRatio: CGFloat = 0.50
    static let enemyPlatformXRatio: CGFloat = 0.80
    static let combatantBaselineRatio: CGFloat = 0.92
    static let flameColumnCount = 28
    static let flameAnimationFrameRate: Double = 12
    static let combatAnimationFrameRate: Double = 12
    static let actionFrameHoldDuration: TimeInterval = 0.30
    static let strikeLungeDistance: CGFloat = 10
    static let hitSquashYScale: CGFloat = 0.92
    static let supportHPBarWidth: CGFloat = 32
    static let finishCueWidth: CGFloat = 82
    static let finishCueHeight: CGFloat = 46
    static let sceneCornerRadius: CGFloat = 0
    static let sceneBorderLineWidth: CGFloat = 0

    static var officialAspectRatio: CGFloat {
        officialWidth / officialHeight
    }

    static var popoverSceneAspectRatio: CGFloat {
        expectedPopoverContentWidth / compactHeight
    }

    static var visualScale: CGFloat {
        min(compactHeight, maximumVisualScaleHeight) / referenceCompactHeight
    }

    static var combatantFrameHeight: CGFloat {
        68 * visualScale
    }

    static var combatantBaselineY: CGFloat {
        compactHeight * combatantBaselineRatio
    }

    static var deployableScale: CGFloat {
        min(max(visualScale, 1.25), 1.75)
    }

    static var effectScale: CGFloat {
        min(max(compactHeight / 130, 1.0), 1.90)
    }

    static var utilityCueScale: CGFloat {
        min(max(effectScale * 0.72, 1.0), 1.34)
    }

    static func sourceRangeVisualScale(for sourceRange: Int?) -> CGFloat {
        guard let sourceRange, sourceRange > 0 else { return 1.0 }
        let scale = CGFloat(sourceRange) / 900
        return min(max(scale, 0.84), 1.36)
    }

    static func sourceRangeVerticalScale(for sourceRange: Int?) -> CGFloat {
        let horizontalScale = sourceRangeVisualScale(for: sourceRange)
        return min(max(0.92 + (horizontalScale - 1.0) * 0.25, 0.88), 1.10)
    }

    static var platformSideInsetRatio: CGFloat {
        (1 - groundPlatformWidthRatio) / 2
    }
}

enum BattleLogMetrics {
    static let visibleEntryLimit = 50
    static let heroHighlightEntryLimit = 3
    static let minimumVisibleHeroSideEntries = 8
    static let heroFocusLookbackEntryCount = 8
    static let panelHeight: CGFloat = 168
    static let rowSpacing: CGFloat = 3
}

struct BattleLogPresentation {
    let visibleEntries: [BattleLogEntry]
    let heroFocusEntries: [BattleLogEntry]
    let totalCount: Int

    init(from entries: [BattleLogEntry]) {
        visibleEntries = BattleLogDisplayEntries.visible(
            from: entries,
            limit: BattleLogMetrics.visibleEntryLimit
        )
        heroFocusEntries = BattleLogDisplayEntries.heroSideHighlights(from: entries)
        totalCount = entries.count
    }

    var visibleScrollTargetID: UUID? {
        BattleLogDisplayEntries.scrollTargetID(in: visibleEntries)
    }
}

enum BattleLogDisplayEntries {
    static func visible(
        from entries: [BattleLogEntry],
        limit: Int,
        minimumHeroSideEntries: Int = BattleLogMetrics.minimumVisibleHeroSideEntries
    ) -> [BattleLogEntry] {
        guard limit > 0, !entries.isEmpty else { return [] }

        let requiredHeroEntries = min(max(0, minimumHeroSideEntries), limit)
        let monsterSoftLimit = max(1, limit - requiredHeroEntries)
        var selected: [BattleLogEntry] = []
        var selectedHeroEntries = 0
        var selectedMonsterEntries = 0

        for entry in entries.reversed() where selected.count < limit {
            if entry.attacker.isHeroSide {
                selected.append(entry)
                selectedHeroEntries += 1
                continue
            }

            let remainingSlots = limit - selected.count
            let remainingRequiredHeroes = max(0, requiredHeroEntries - selectedHeroEntries)
            if selectedMonsterEntries < monsterSoftLimit || remainingRequiredHeroes < remainingSlots {
                selected.append(entry)
                selectedMonsterEntries += 1
            }
        }

        if selected.isEmpty {
            return Array(entries.suffix(limit))
        }

        return selected.reversed()
    }

    static func scrollTargetID(in entries: [BattleLogEntry]) -> UUID? {
        guard let latestEntry = entries.last else { return nil }
        let latestViewportEntries = entries.suffix(BattleLogMetrics.heroFocusLookbackEntryCount)
        if latestViewportEntries.contains(where: { $0.attacker.isHeroSide }) {
            return latestEntry.id
        }
        return entries.last(where: { $0.attacker.isHeroSide })?.id ?? latestEntry.id
    }

    static func heroSideHighlights(
        from entries: [BattleLogEntry],
        limit: Int = BattleLogMetrics.heroHighlightEntryLimit
    ) -> [BattleLogEntry] {
        guard limit > 0 else { return [] }
        return Array(entries.filter { $0.attacker.isHeroSide }.suffix(limit))
    }
}

enum BattleSceneLabels {
    static func stagePillText(progress: ProgressTracker) -> String {
        progress.currentStage.displayCode
    }
}

enum BattleHeroSpriteMetrics {
    static let mainScale: CGFloat = 1.16 * BattleSceneMetrics.visualScale
    static let supportScale: CGFloat = 0.76 * BattleSceneMetrics.visualScale
    static let enemyFacingXScale: CGFloat = -1

    static func mainSize(for heroClass: HeroClass) -> CGSize {
        GameArt.battleHeroDisplaySize(for: heroClass, scale: mainScale)
    }

    static func supportSize(for heroClass: HeroClass) -> CGSize {
        GameArt.battleHeroDisplaySize(for: heroClass, scale: supportScale)
    }
}

/// 战斗场景 — 像素风动画
struct BattleSceneView: View {
    @ObservedObject var battle: Battle
    let progress: ProgressTracker
    let fixedBackdropTime: TimeInterval?
    let latestLogEntry: BattleLogEntry?
    let logTrigger: UUID?
    @State private var heroStrike = false
    @State private var supportStrike = false
    @State private var monsterStrike = false
    @State private var heroHit = false
    @State private var monsterHit = false

    init(
        battle: Battle,
        progress: ProgressTracker,
        fixedBackdropTime: TimeInterval? = nil,
        latestLogEntry: BattleLogEntry? = nil,
        logTrigger: UUID? = nil
    ) {
        self.battle = battle
        self.progress = progress
        self.fixedBackdropTime = fixedBackdropTime
        self.latestLogEntry = latestLogEntry
        self.logTrigger = logTrigger ?? battle.log.last?.id
    }

    var body: some View {
        Group {
            if let fixedBackdropTime {
                sceneFrame(animationTime: fixedBackdropTime)
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / BattleSceneMetrics.combatAnimationFrameRate)) { timeline in
                    sceneFrame(animationTime: timeline.date.timeIntervalSinceReferenceDate)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: BattleSceneMetrics.sceneCornerRadius))
        .onChange(of: logTrigger) { _ in
            playHitAnimation()
        }
    }

    @ViewBuilder
    private func sceneFrame(animationTime: TimeInterval) -> some View {
        GeometryReader { proxy in
            let sceneWidth = proxy.size.width
            let platformWidth = sceneWidth * BattleSceneMetrics.groundPlatformWidthRatio
            let platformLeading = sceneWidth * BattleSceneMetrics.platformSideInsetRatio
            let snapshotActionAttacker = fixedBackdropTime == nil ? nil : visualLogEntry?.attacker

            ZStack(alignment: .topLeading) {
                BattleArenaBackdrop(fixedTime: animationTime)

                StagePill(progress: progress)
                    .padding(.top, BattleSceneMetrics.compactHeight * 0.36)
                    .padding(.leading, platformLeading + 20)

                PartyCombatantView(
                    battle: battle,
                    isHeroStriking: heroStrike || snapshotActionAttacker == .hero,
                    isSupportStriking: supportStrike || snapshotActionAttacker?.isSupport == true,
                    isHit: heroHit || snapshotActionAttacker == .monster,
                    animationTime: animationTime
                )
                .frame(width: 220 * BattleSceneMetrics.visualScale, height: BattleSceneMetrics.combatantFrameHeight, alignment: .bottom)
                .position(
                    x: platformLeading + platformWidth * BattleSceneMetrics.partyPlatformXRatio,
                    y: BattleSceneMetrics.combatantBaselineY - BattleSceneMetrics.combatantFrameHeight / 2
                )

                EnemyWaveView(
                    battle: battle,
                    spriteSize: battleMonsterSpriteSize(for: battle.monster.id),
                    isStriking: monsterStrike || snapshotActionAttacker == .monster,
                    isHit: monsterHit || snapshotActionAttacker?.isHeroSide == true,
                    animationTime: animationTime
                )
                .frame(width: 104 * BattleSceneMetrics.visualScale, height: BattleSceneMetrics.combatantFrameHeight, alignment: .bottom)
                .position(
                    x: platformLeading + platformWidth * BattleSceneMetrics.enemyPlatformXRatio,
                    y: BattleSceneMetrics.combatantBaselineY - BattleSceneMetrics.combatantFrameHeight / 2
                )

                if let pulse = BattleContactPulse.visible(for: visualLogEntry) {
                    BattleContactPulseView(pulse: pulse)
                        .frame(
                            width: 42 * BattleSceneMetrics.effectScale,
                            height: 26 * BattleSceneMetrics.effectScale,
                            alignment: .center
                        )
                        .padding(.leading, platformLeading + platformWidth * pulse.xAnchorRatio)
                        .padding(.top, BattleSceneMetrics.compactHeight * 0.70)
                        .zIndex(7)
                }

                PlayerDeployableStack(deployables: PlayerBattleDeployable.visible(for: battle))
                    .frame(
                        width: 72 * BattleSceneMetrics.deployableScale,
                        height: 24 * BattleSceneMetrics.deployableScale,
                        alignment: .bottomLeading
                    )
                    .padding(.leading, platformLeading + platformWidth * 0.30)
                    .padding(.top, BattleSceneMetrics.compactHeight * 0.32)
                    .zIndex(4)

                if let cue = BattleIncomingCue.visible(for: visualLogEntry) {
                    BattleIncomingCueView(cue: cue)
                        .frame(
                            width: 54 * BattleSceneMetrics.effectScale,
                            height: 32 * BattleSceneMetrics.effectScale,
                            alignment: .center
                        )
                        .padding(.leading, platformLeading + platformWidth * 0.27)
                        .padding(.top, BattleSceneMetrics.compactHeight * 0.38)
                        .zIndex(6)
                }

                if let trajectory = BattleTrajectoryCue.visible(for: visualLogEntry),
                   let last = visualLogEntry {
                    let rangeScale = BattleSceneMetrics.sourceRangeVisualScale(for: last.sourceRange)
                    BattleTrajectoryCueView(
                        cue: trajectory,
                        tint: BattleTrajectoryCue.tint(for: last),
                        sourceRangeScale: rangeScale
                    )
                    .frame(
                        width: 86 * BattleSceneMetrics.effectScale * rangeScale,
                        height: 30 * BattleSceneMetrics.effectScale * BattleSceneMetrics.sourceRangeVerticalScale(for: last.sourceRange),
                        alignment: .center
                    )
                    .padding(.leading, platformLeading + platformWidth * 0.33)
                    .padding(.top, BattleSceneMetrics.compactHeight * 0.40)
                    .zIndex(5)
                }

                if let cue = BattleImpactCue.visible(for: visualLogEntry) {
                    BattleImpactCueView(cue: cue)
                        .frame(
                            width: 62 * BattleSceneMetrics.effectScale,
                            height: 42 * BattleSceneMetrics.effectScale,
                            alignment: .center
                        )
                        .padding(.leading, platformLeading + platformWidth * 0.54)
                        .padding(.top, BattleSceneMetrics.compactHeight * 0.40)
                        .zIndex(6)
                }

                if let cue = BattleUtilityCue.visible(for: visualLogEntry) {
                    BattleUtilityCueView(cue: cue)
                        .frame(
                            width: 58 * BattleSceneMetrics.effectScale,
                            height: 38 * BattleSceneMetrics.effectScale,
                            alignment: .center
                        )
                        .padding(.leading, platformLeading + platformWidth * 0.30)
                        .padding(.top, BattleSceneMetrics.compactHeight * 0.38)
                        .zIndex(6)
                }

                if let finishCue = BattleFinishCue.visible(for: battle.result) {
                    BattleFinishCueView(cue: finishCue)
                        .frame(
                            width: BattleSceneMetrics.finishCueWidth * BattleSceneMetrics.effectScale,
                            height: BattleSceneMetrics.finishCueHeight * BattleSceneMetrics.effectScale,
                            alignment: .center
                        )
                        .padding(.leading, platformLeading + platformWidth * finishCue.xAnchorRatio)
                        .padding(.top, BattleSceneMetrics.compactHeight * finishCue.yAnchorRatio)
                        .zIndex(8)
                }

                if let last = visualLogEntry {
                    FloatingDamageText(entry: last)
                        .padding(.top, 18)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }

    private var visualLogEntry: BattleLogEntry? {
        latestLogEntry ?? battle.log.last
    }

    private func playHitAnimation() {
        guard let attacker = visualLogEntry?.attacker else { return }

        withAnimation(.easeOut(duration: 0.10)) {
            heroStrike = attacker == .hero
            supportStrike = attacker.isSupport
            monsterStrike = attacker == .monster
            heroHit = attacker == .monster
            monsterHit = attacker.isHeroSide
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + BattleSceneMetrics.actionFrameHoldDuration) {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.62)) {
                heroStrike = false
                supportStrike = false
                monsterStrike = false
                heroHit = false
                monsterHit = false
            }
        }
    }

    private func battleMonsterSpriteSize(for monsterID: String) -> CGSize {
        let scale = BattleSceneMetrics.visualScale
        if monsterID.hasPrefix("boss_") {
            return CGSize(width: 64 * scale, height: 68 * scale)
        }
        switch monsterID {
        case "slime_green", "slime_blue":
            return CGSize(width: 46 * scale, height: 28 * scale)
        default:
            return CGSize(width: 50 * scale, height: 60 * scale)
        }
    }
}

private enum BattleFinishCue {
    case victory
    case defeat

    static func visible(for result: BattleResult?) -> BattleFinishCue? {
        switch result {
        case .victory:
            return .victory
        case .defeat:
            return .defeat
        case nil:
            return nil
        }
    }

    var xAnchorRatio: CGFloat {
        switch self {
        case .victory:
            return 0.55
        case .defeat:
            return 0.24
        }
    }

    var yAnchorRatio: CGFloat {
        switch self {
        case .victory:
            return 0.36
        case .defeat:
            return 0.39
        }
    }
}

private struct BattleFinishCueView: View {
    let cue: BattleFinishCue

    var body: some View {
        Canvas { context, size in
            let scale = max(
                CGFloat(1),
                min(
                    size.width / BattleSceneMetrics.finishCueWidth,
                    size.height / BattleSceneMetrics.finishCueHeight
                )
            )
            let center = CGPoint(x: size.width * 0.50, y: size.height * 0.50)

            switch cue {
            case .victory:
                drawVictoryCue(context: context, center: center, scale: scale)
            case .defeat:
                drawDefeatCue(context: context, center: center, scale: scale)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func drawVictoryCue(context: GraphicsContext, center: CGPoint, scale: CGFloat) {
        let rayColor = Color(red: 1.0, green: 0.76, blue: 0.18)
        let coreColor = Color(red: 1.0, green: 0.93, blue: 0.42)

        for index in 0..<8 {
            let angle = CGFloat(index) * .pi / 4
            let length = CGFloat(index.isMultiple(of: 2) ? 28 : 20) * scale
            let width = CGFloat(index.isMultiple(of: 2) ? 5 : 4) * scale
            let midpoint = CGPoint(
                x: center.x + CGFloat(cos(Double(angle))) * length * 0.48,
                y: center.y + CGFloat(sin(Double(angle))) * length * 0.48
            )
            let rayRect = CGRect(
                x: midpoint.x - width / 2,
                y: midpoint.y - length / 2,
                width: width,
                height: length
            )
            let rayPath = Path(roundedRect: rayRect, cornerRadius: 1.5 * scale)
                .applying(.init(translationX: -midpoint.x, y: -midpoint.y))
                .applying(.init(rotationAngle: angle + .pi / 2))
                .applying(.init(translationX: midpoint.x, y: midpoint.y))
            context.fill(rayPath, with: .color(rayColor.opacity(0.72)))
        }

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - 14 * scale,
                y: center.y - 10 * scale,
                width: 28 * scale,
                height: 20 * scale
            )),
            with: .color(coreColor.opacity(0.82))
        )
        context.stroke(
            Path(ellipseIn: CGRect(
                x: center.x - 21 * scale,
                y: center.y - 15 * scale,
                width: 42 * scale,
                height: 30 * scale
            )),
            with: .color(rayColor.opacity(0.68)),
            lineWidth: 3 * scale
        )
    }

    private func drawDefeatCue(context: GraphicsContext, center: CGPoint, scale: CGFloat) {
        let shardColor = Color(red: 0.95, green: 0.20, blue: 0.14)
        let dimColor = Color(red: 0.48, green: 0.05, blue: 0.06)

        for index in 0..<6 {
            let x = center.x + CGFloat(index - 3) * 9 * scale
            let y = center.y + CGFloat(index % 3 - 1) * 7 * scale
            var path = Path()
            path.move(to: CGPoint(x: x, y: y - 11 * scale))
            path.addLine(to: CGPoint(x: x + 6 * scale, y: y + 2 * scale))
            path.addLine(to: CGPoint(x: x - 5 * scale, y: y + 9 * scale))
            path.closeSubpath()
            context.fill(path, with: .color(shardColor.opacity(0.78)))
        }

        context.fill(
            Path(roundedRect: CGRect(
                x: center.x - 30 * scale,
                y: center.y + 12 * scale,
                width: 60 * scale,
                height: 7 * scale
            ), cornerRadius: 2 * scale),
            with: .color(dimColor.opacity(0.82))
        )
        context.stroke(
            Path(roundedRect: CGRect(
                x: center.x - 34 * scale,
                y: center.y - 18 * scale,
                width: 68 * scale,
                height: 40 * scale
            ), cornerRadius: 3 * scale),
            with: .color(shardColor.opacity(0.42)),
            lineWidth: 3 * scale
        )
    }
}

enum BattleContactPulse: Equatable {
    case heroHitEnemy
    case monsterHitParty

    static func visible(for entry: BattleLogEntry?) -> BattleContactPulse? {
        guard let entry, entry.kind == .damage, entry.damage > 0 else { return nil }
        if entry.attacker.isHeroSide {
            return .heroHitEnemy
        }
        if entry.attacker == .monster {
            return .monsterHitParty
        }
        return nil
    }

    var xAnchorRatio: CGFloat {
        switch self {
        case .heroHitEnemy:
            return 0.57
        case .monsterHitParty:
            return 0.24
        }
    }

    var tint: Color {
        switch self {
        case .heroHitEnemy:
            return Color(red: 1.0, green: 0.82, blue: 0.16)
        case .monsterHitParty:
            return Color(red: 1.0, green: 0.26, blue: 0.12)
        }
    }

    var secondaryTint: Color {
        switch self {
        case .heroHitEnemy:
            return Color.white.opacity(0.90)
        case .monsterHitParty:
            return Color(red: 1.0, green: 0.82, blue: 0.18)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .heroHitEnemy:
            return "我方命中反馈"
        case .monsterHitParty:
            return "敌方命中反馈"
        }
    }
}

private struct BattleContactPulseView: View {
    let pulse: BattleContactPulse

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Ellipse()
                    .stroke(pulse.tint.opacity(0.86), lineWidth: max(1.0, width * 0.035))
                    .frame(width: width * 0.58, height: height * 0.42)
                    .position(x: width * 0.50, y: height * 0.56)

                Ellipse()
                    .stroke(pulse.secondaryTint.opacity(0.74), lineWidth: max(0.8, width * 0.022))
                    .frame(width: width * 0.34, height: height * 0.24)
                    .position(x: width * 0.52, y: height * 0.55)

                ForEach(0..<5, id: \.self) { index in
                    Capsule()
                        .fill(index.isMultiple(of: 2) ? pulse.secondaryTint : pulse.tint)
                        .frame(width: width * 0.055, height: height * rayHeightRatio(for: index))
                        .rotationEffect(.degrees(rayRotation(for: index)))
                        .position(
                            x: width * rayXRatio(for: index),
                            y: height * rayYRatio(for: index)
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityLabel(pulse.accessibilityLabel)
    }

    private func rayHeightRatio(for index: Int) -> CGFloat {
        [0.44, 0.36, 0.50, 0.32, 0.38][index]
    }

    private func rayXRatio(for index: Int) -> CGFloat {
        [0.20, 0.36, 0.52, 0.66, 0.80][index]
    }

    private func rayYRatio(for index: Int) -> CGFloat {
        [0.42, 0.24, 0.22, 0.28, 0.46][index]
    }

    private func rayRotation(for index: Int) -> Double {
        [-42, -18, 0, 20, 44][index]
    }
}

private struct BattleTrajectoryCueView: View {
    let cue: BattleTrajectoryCue
    let tint: Color
    let sourceRangeScale: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(tint.opacity(0.16))
                .frame(width: 80, height: 22)
                .blur(radius: 2)

            switch cue {
            case .meleeArc:
                MeleeArcTrailCue(tint: tint)
            case .projectile:
                ProjectileTrailCue(tint: tint)
            case .rapidVolley:
                RapidVolleyTrailCue(tint: tint)
            case .trackingVolley:
                TrackingVolleyTrailCue(tint: tint)
            case .arrowRain:
                ArrowRainTrailCue(tint: tint)
            case .piercingArrow:
                PiercingArrowTrailCue(tint: tint)
            case .lodgedArrow:
                LodgedArrowTrailCue(tint: tint)
            case .explosiveBolt:
                ExplosiveBoltTrailCue(tint: tint)
            case .frostBolt:
                FrostBoltTrailCue(tint: tint)
            case .shockBolt:
                ShockBoltTrailCue(tint: tint)
            case .shockCurrentArc:
                ShockCurrentArcTrailCue(tint: tint)
            case .rangeField:
                RangeFieldTrailCue(tint: tint)
            case .summonProjectile:
                SummonTrailCue(tint: tint)
            case .trapArc:
                TrapArcTrailCue(tint: tint)
            case .chargeDash:
                ChargeDashTrailCue(tint: tint)
            case .leapArc:
                LeapArcTrailCue(tint: tint)
            case .meteorFall:
                MeteorFallTrailCue(tint: tint)
            case .axeSpinArc:
                AxeSpinArcTrailCue(tint: tint)
            case .bleedRendTrail:
                BleedRendTrailCue(tint: tint)
            case .shockwaveRing:
                ShockwaveRingTrailCue(tint: tint)
            case .groundRupture:
                GroundRuptureTrailCue(tint: tint)
            case .rockBurst:
                RockBurstTrailCue(tint: tint)
            }
        }
        .scaleEffect(x: sourceRangeScale, y: 1.0, anchor: .center)
        .shadow(color: tint.opacity(0.82), radius: 6, x: 0, y: 0)
        .accessibilityLabel(cue.accessibilityLabel)
    }
}

private struct MeleeArcTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            ArcSegment()
                .stroke(tint.opacity(0.36), style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .frame(width: 58, height: 30)
                .rotationEffect(.degrees(-8))
                .offset(x: 6, y: -2)

            ArcSegment()
                .stroke(tint.opacity(0.92), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 58, height: 30)
                .rotationEffect(.degrees(-8))
                .offset(x: 6, y: -2)

            ForEach([CGPoint(x: 44, y: 6), CGPoint(x: 52, y: 12), CGPoint(x: 47, y: 20)], id: \.x) { point in
                Rectangle()
                    .fill(Color.white.opacity(0.76))
                    .frame(width: 7, height: 2)
                    .rotationEffect(.degrees(point.y > 12 ? -28 : 28))
                    .position(point)
            }

            Capsule()
                .fill(Color.white.opacity(0.72))
                .frame(width: 22, height: 2)
                .rotationEffect(.degrees(-12))
                .offset(x: 22, y: -8)
        }
        .frame(width: 66, height: 30)
    }
}

private struct ProjectileTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            Capsule()
                .fill(tint.opacity(0.20))
                .frame(width: 66, height: 12)
                .rotationEffect(.degrees(-5))

            Capsule()
                .fill(tint.opacity(0.58))
                .frame(width: 64, height: 6)
                .rotationEffect(.degrees(-5))
            Capsule()
                .fill(tint)
                .frame(width: 50, height: 3)
                .rotationEffect(.degrees(-5))
                .offset(x: 8, y: -1)
            Circle()
                .fill(tint)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.76))
                        .frame(width: 5, height: 5)
                        .offset(x: 2, y: -2)
                )
                .offset(x: 30, y: -2)
            ForEach([-25.0, -13.0, 0.0, 13.0], id: \.self) { offset in
                Rectangle()
                    .fill(Color.white.opacity(0.78))
                    .frame(width: 6, height: 2)
                    .offset(x: offset, y: 6)
            }
        }
    }
}

private struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private struct ArcSegment: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY * 0.78),
            radius: min(rect.width, rect.height) * 0.58,
            startAngle: .degrees(205),
            endAngle: .degrees(335),
            clockwise: false
        )
        return path
    }
}

private struct RapidVolleyTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                let y = CGFloat(index - 1) * 4

                Capsule()
                    .fill(tint.opacity(index == 1 ? 0.82 : 0.54))
                    .frame(width: index == 1 ? 52 : 42, height: 2)
                    .rotationEffect(.degrees(-5))
                    .offset(x: 8, y: y)

                Circle()
                    .fill(tint)
                    .frame(width: 5, height: 5)
                    .offset(x: 30, y: y - 1)
            }

            ForEach([-24.0, -15.0, -6.0], id: \.self) { offset in
                Rectangle()
                    .fill(Color.white.opacity(0.72))
                    .frame(width: 4, height: 1.5)
                    .offset(x: offset, y: 7)
            }
        }
        .frame(width: 66, height: 18)
    }
}

private struct TrackingVolleyTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                let endY = CGFloat([4.0, 9.0, 14.0][index])
                let controlY = CGFloat([-3.0, 9.0, 21.0][index])

                Path { path in
                    path.move(to: CGPoint(x: 5, y: 9))
                    path.addQuadCurve(
                        to: CGPoint(x: 60, y: endY),
                        control: CGPoint(x: 31, y: controlY)
                    )
                }
                .stroke(tint.opacity(index == 1 ? 0.86 : 0.62), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

                Circle()
                    .fill(tint)
                    .frame(width: 5, height: 5)
                    .position(x: 60, y: endY)
            }

            Circle()
                .fill(Color.white.opacity(0.78))
                .frame(width: 3, height: 3)
                .offset(x: -18, y: -1)
        }
        .frame(width: 66, height: 18)
    }
}

private struct ArrowRainTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                let x = CGFloat(index) * 11 + 8
                let y = CGFloat(index % 2) * -2

                Path { path in
                    path.move(to: CGPoint(x: x, y: 0 + y))
                    path.addLine(to: CGPoint(x: x - 12, y: 17 + y))
                }
                .stroke(tint.opacity(0.52 + Double(index % 2) * 0.20), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

                Path { path in
                    path.move(to: CGPoint(x: x - 12, y: 17 + y))
                    path.addLine(to: CGPoint(x: x - 8, y: 12 + y))
                    path.addLine(to: CGPoint(x: x - 5, y: 18 + y))
                }
                .stroke(Color.white.opacity(0.70), style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
            }
        }
        .frame(width: 66, height: 18)
    }
}

private struct PiercingArrowTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            Capsule()
                .fill(tint.opacity(0.36))
                .frame(width: 62, height: 5)
                .rotationEffect(.degrees(-3))

            Capsule()
                .fill(tint)
                .frame(width: 54, height: 2)
                .rotationEffect(.degrees(-3))
                .offset(x: 2)

            Path { path in
                path.move(to: CGPoint(x: 64, y: 9))
                path.addLine(to: CGPoint(x: 52, y: 3))
                path.addLine(to: CGPoint(x: 55, y: 9))
                path.addLine(to: CGPoint(x: 52, y: 15))
                path.closeSubpath()
            }
            .fill(Color.white.opacity(0.84))
        }
        .frame(width: 66, height: 18)
    }
}

private struct LodgedArrowTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            Capsule()
                .fill(tint.opacity(0.62))
                .frame(width: 42, height: 2)
                .rotationEffect(.degrees(-8))
                .offset(x: -5, y: -1)

            Path { path in
                path.move(to: CGPoint(x: 42, y: 10))
                path.addLine(to: CGPoint(x: 34, y: 5))
                path.addLine(to: CGPoint(x: 36, y: 10))
                path.addLine(to: CGPoint(x: 34, y: 15))
                path.closeSubpath()
            }
            .fill(tint)

            RoundedRectangle(cornerRadius: 1)
                .stroke(Color.red.opacity(0.78), lineWidth: 1.5)
                .frame(width: 13, height: 13)
                .rotationEffect(.degrees(45))
                .offset(x: 23)

            Capsule()
                .fill(Color.white.opacity(0.72))
                .frame(width: 10, height: 2)
                .rotationEffect(.degrees(38))
                .offset(x: 26, y: -3)
        }
        .frame(width: 66, height: 18)
    }
}

private struct ExplosiveBoltTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            Capsule()
                .fill(tint.opacity(0.48))
                .frame(width: 48, height: 5)
                .rotationEffect(.degrees(-6))
                .offset(x: -4)

            Capsule()
                .fill(Color(red: 1.0, green: 0.84, blue: 0.20))
                .frame(width: 32, height: 2)
                .rotationEffect(.degrees(-6))
                .offset(x: 1, y: -1)

            Circle()
                .fill(tint)
                .frame(width: 9, height: 9)
                .overlay(
                    Circle()
                        .fill(Color(red: 1.0, green: 0.78, blue: 0.18))
                        .frame(width: 4, height: 4)
                )
                .offset(x: 28, y: -1)

            ForEach([CGPoint(x: 45, y: 4), CGPoint(x: 51, y: 9), CGPoint(x: 43, y: 14)], id: \.x) { point in
                Rectangle()
                    .fill(tint.opacity(0.72))
                    .frame(width: 4, height: 2)
                    .rotationEffect(.degrees(point.y > 9 ? -28 : 34))
                    .position(point)
            }
        }
        .frame(width: 66, height: 18)
    }
}

private struct FrostBoltTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            Capsule()
                .fill(tint.opacity(0.42))
                .frame(width: 50, height: 5)
                .rotationEffect(.degrees(-4))

            Capsule()
                .fill(Color.white.opacity(0.78))
                .frame(width: 30, height: 2)
                .rotationEffect(.degrees(-4))
                .offset(x: -8, y: -4)

            Diamond()
                .fill(tint)
                .frame(width: 12, height: 12)
                .overlay(
                    Diamond()
                        .fill(Color.white.opacity(0.78))
                        .frame(width: 5, height: 5)
                )
                .offset(x: 25, y: 0)

            ForEach([11.0, 25.0, 39.0], id: \.self) { offset in
                Rectangle()
                    .fill(tint.opacity(0.78))
                    .frame(width: 2, height: 8)
                    .rotationEffect(.degrees(offset == 25 ? 90 : 45))
                    .offset(x: offset - 33, y: offset == 25 ? 5 : 3)
            }
        }
        .frame(width: 66, height: 18)
    }
}

private struct ShockBoltTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 4, y: 12))
                path.addLine(to: CGPoint(x: 22, y: 6))
                path.addLine(to: CGPoint(x: 33, y: 10))
                path.addLine(to: CGPoint(x: 50, y: 3))
                path.addLine(to: CGPoint(x: 61, y: 8))
            }
            .stroke(tint.opacity(0.80), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .miter))

            Path { path in
                path.move(to: CGPoint(x: 49, y: 2))
                path.addLine(to: CGPoint(x: 42, y: 10))
                path.addLine(to: CGPoint(x: 48, y: 10))
                path.addLine(to: CGPoint(x: 42, y: 17))
            }
            .stroke(Color.white.opacity(0.84), style: StrokeStyle(lineWidth: 1.4, lineCap: .square, lineJoin: .miter))

            Circle()
                .fill(tint)
                .frame(width: 6, height: 6)
                .offset(x: 27, y: -1)
        }
        .frame(width: 66, height: 18)
    }
}

private struct ShockCurrentArcTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            ForEach([0.0, 10.0, 20.0], id: \.self) { offset in
                ArcSegment()
                    .stroke(tint.opacity(0.74 - offset / 55), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
                    .frame(width: 28 + offset, height: 14 + offset * 0.18)
                    .offset(x: offset * 0.28)
            }

            ForEach([CGPoint(x: 14, y: 12), CGPoint(x: 33, y: 5), CGPoint(x: 55, y: 12)], id: \.x) { point in
                Circle()
                    .fill(Color.white.opacity(0.74))
                    .frame(width: 3, height: 3)
                    .position(point)
            }
        }
        .frame(width: 66, height: 18)
    }
}

private struct RangeFieldTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            ForEach([0.0, 9.0, 18.0], id: \.self) { offset in
                Capsule()
                    .stroke(tint.opacity(0.68), lineWidth: 1.6)
                    .frame(width: 46 - offset, height: 12 + offset * 0.24)
                    .offset(x: offset * 0.45)
            }
            Rectangle()
                .fill(tint)
                .frame(width: 20, height: 2)
                .offset(x: 16)
        }
    }
}

private struct SummonTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            Capsule()
                .fill(tint.opacity(0.36))
                .frame(width: 52, height: 6)
                .rotationEffect(.degrees(-7))
            ForEach([-18.0, -5.0, 8.0], id: \.self) { offset in
                Circle()
                    .fill(tint)
                    .frame(width: offset == 8 ? 8 : 5, height: offset == 8 ? 8 : 5)
                    .offset(x: offset, y: offset == 8 ? -2 : 2)
            }
            Circle()
                .fill(Color.white.opacity(0.75))
                .frame(width: 3, height: 3)
                .offset(x: 11, y: -4)
        }
    }
}

private struct TrapArcTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 5, y: 13))
                path.addQuadCurve(to: CGPoint(x: 60, y: 10), control: CGPoint(x: 31, y: 0))
            }
            .stroke(tint, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 4]))
            RoundedRectangle(cornerRadius: 1)
                .stroke(tint, lineWidth: 1.5)
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(45))
                .offset(x: 24, y: 1)
        }
        .frame(width: 66, height: 18)
    }
}

private struct ChargeDashTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            ForEach([0.0, 10.0, 20.0], id: \.self) { offset in
                Capsule()
                    .fill(tint.opacity(0.30 + offset / 60))
                    .frame(width: 42 - offset * 0.8, height: 4)
                    .offset(x: offset - 11, y: offset == 20 ? -2 : 2)
            }
            Rectangle()
                .fill(Color.white.opacity(0.82))
                .frame(width: 11, height: 9)
                .rotationEffect(.degrees(45))
                .offset(x: 21, y: -1)
            Capsule()
                .fill(tint)
                .frame(width: 30, height: 2)
                .offset(x: 9, y: -5)
        }
        .frame(width: 66, height: 18)
    }
}

private struct LeapArcTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 4, y: 19))
                path.addQuadCurve(to: CGPoint(x: 62, y: 15), control: CGPoint(x: 28, y: -11))
            }
            .stroke(tint, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [3, 3]))

            ForEach([CGPoint(x: 15, y: 10), CGPoint(x: 31, y: 3), CGPoint(x: 47, y: 9)], id: \.x) { point in
                Circle()
                    .fill(tint.opacity(0.74))
                    .frame(width: 5, height: 5)
                    .position(point)
            }

            Capsule()
                .fill(Color.white.opacity(0.84))
                .frame(width: 15, height: 4)
                .rotationEffect(.degrees(-16))
                .offset(x: 22, y: 6)
        }
        .frame(width: 66, height: 24)
        .scaleEffect(x: 1.0, y: 1.20, anchor: .center)
    }
}

private struct MeteorFallTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            Capsule()
                .fill(tint.opacity(0.38))
                .frame(width: 56, height: 5)
                .rotationEffect(.degrees(-32))
                .offset(x: -4, y: -1)

            Capsule()
                .fill(Color.white.opacity(0.72))
                .frame(width: 35, height: 2)
                .rotationEffect(.degrees(-32))
                .offset(x: -12, y: -6)

            Circle()
                .fill(tint)
                .frame(width: 13, height: 13)
                .overlay(
                    Circle()
                        .fill(Color(red: 1.0, green: 0.84, blue: 0.24))
                        .frame(width: 6, height: 6)
                )
                .offset(x: 24, y: 6)
        }
        .frame(width: 66, height: 18)
    }
}

private struct AxeSpinArcTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            ForEach([0.0, 12.0, 24.0], id: \.self) { offset in
                ArcSegment()
                    .stroke(tint.opacity(0.78 - offset / 70), style: StrokeStyle(lineWidth: 2.2, lineCap: .square))
                    .frame(width: 34 + offset, height: 16 + offset * 0.20)
                    .rotationEffect(.degrees(offset == 12 ? 4 : -4))
                    .offset(x: offset * 0.25)
            }

            Capsule()
                .fill(Color.white.opacity(0.82))
                .frame(width: 26, height: 3)
                .rotationEffect(.degrees(-12))
                .offset(x: 19, y: -3)

            ForEach([CGPoint(x: 14, y: 12), CGPoint(x: 33, y: 5), CGPoint(x: 55, y: 12)], id: \.x) { point in
                Diamond()
                    .fill(tint.opacity(0.82))
                    .frame(width: 5, height: 5)
                    .position(point)
            }
        }
        .frame(width: 66, height: 18)
    }
}

private struct BleedRendTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            ForEach([0.0, 1.0, 2.0], id: \.self) { index in
                Path { path in
                    let y = 5 + index * 4
                    path.move(to: CGPoint(x: 8, y: y + 4))
                    path.addQuadCurve(
                        to: CGPoint(x: 58, y: y),
                        control: CGPoint(x: 30, y: y - 8)
                    )
                }
                .stroke(tint.opacity(0.82 - index * 0.12), style: StrokeStyle(lineWidth: 2.4 - index * 0.3, lineCap: .round))
            }

            ForEach([CGPoint(x: 21, y: 13), CGPoint(x: 39, y: 8), CGPoint(x: 52, y: 14)], id: \.x) { point in
                Circle()
                    .fill(Color(red: 1.0, green: 0.46, blue: 0.38).opacity(0.82))
                    .frame(width: 4, height: 4)
                    .position(point)
            }
        }
        .frame(width: 66, height: 18)
    }
}

private struct ShockwaveRingTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            ForEach([0.0, 10.0, 20.0], id: \.self) { offset in
                Ellipse()
                    .stroke(tint.opacity(0.72 - offset / 55), lineWidth: 1.8)
                    .frame(width: 34 + offset, height: 8 + offset * 0.18)
                    .offset(x: offset * 0.25)
            }
            Capsule()
                .fill(Color.white.opacity(0.74))
                .frame(width: 12, height: 2)
                .offset(x: 24, y: -1)
        }
        .frame(width: 66, height: 18)
    }
}

private struct GroundRuptureTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 6, y: 12))
                path.addLine(to: CGPoint(x: 19, y: 8))
                path.addLine(to: CGPoint(x: 31, y: 13))
                path.addLine(to: CGPoint(x: 43, y: 7))
                path.addLine(to: CGPoint(x: 60, y: 11))
            }
            .stroke(tint, style: StrokeStyle(lineWidth: 2, lineCap: .square, lineJoin: .miter))

            ForEach([12.0, 33.0, 51.0], id: \.self) { offset in
                Rectangle()
                    .fill(tint.opacity(0.82))
                    .frame(width: 5, height: 4)
                    .rotationEffect(.degrees(45))
                    .offset(x: offset - 33, y: offset == 33 ? -5 : -2)
            }
        }
        .frame(width: 66, height: 18)
    }
}

private struct RockBurstTrailCue: View {
    let tint: Color

    var body: some View {
        ZStack {
            ForEach([0.0, 8.0, 16.0], id: \.self) { offset in
                Rectangle()
                    .fill(tint.opacity(0.88 - offset / 40))
                    .frame(width: 8, height: 6)
                    .rotationEffect(.degrees(35 + offset * 3))
                    .offset(x: offset - 14, y: -offset * 0.35)
            }

            ForEach([CGPoint(x: 47, y: 7), CGPoint(x: 55, y: 12), CGPoint(x: 37, y: 14)], id: \.x) { point in
                Rectangle()
                    .fill(Color.white.opacity(0.74))
                    .frame(width: 4, height: 3)
                    .rotationEffect(.degrees(-25))
                    .position(point)
            }

            Path { path in
                path.move(to: CGPoint(x: 5, y: 15))
                path.addLine(to: CGPoint(x: 18, y: 10))
                path.addLine(to: CGPoint(x: 29, y: 14))
                path.addLine(to: CGPoint(x: 43, y: 9))
                path.addLine(to: CGPoint(x: 61, y: 13))
            }
            .stroke(tint.opacity(0.68), style: StrokeStyle(lineWidth: 1.6, lineCap: .square, lineJoin: .miter))
        }
        .frame(width: 66, height: 18)
    }
}

private struct BattleUtilityCueView: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            switch cue {
            case .healPulse:
                HealPulseCue(cue: cue)
            case .sanctuaryPulse:
                SanctuaryPulseCue(cue: cue)
            case .resurrectionRise:
                ResurrectionRiseCue(cue: cue)
            case .shieldField:
                ShieldFieldCue(cue: cue)
            case .wrathOfHeavenStorm:
                WrathOfHeavenStormCue(cue: cue)
            case .sacredBladeGlow:
                SacredBladeGlowCue(cue: cue)
            case .swiftSurgeHaste:
                SwiftSurgeHasteCue(cue: cue)
            case .quickLoaderHaste:
                QuickLoaderHasteCue(cue: cue)
            case .generalsCryRoar:
                GeneralsCryRoarCue(cue: cue)
            case .bloodlustSurge:
                BloodlustSurgeCue(cue: cue)
            case .buffAura:
                BuffAuraCue(cue: cue)
            }
        }
        .scaleEffect(BattleSceneMetrics.utilityCueScale)
        .shadow(color: cue.tint.opacity(0.58), radius: 4, x: 0, y: 0)
        .accessibilityLabel(cue.accessibilityLabel)
    }
}

private struct HealPulseCue: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            ForEach([0.0, 10.0, 20.0], id: \.self) { offset in
                Circle()
                    .stroke(cue.tint.opacity(0.72 - offset / 58), lineWidth: 1.8)
                    .frame(width: 15 + offset, height: 15 + offset)
            }

            Rectangle()
                .fill(Color.white.opacity(0.86))
                .frame(width: 5, height: 20)
            Rectangle()
                .fill(Color.white.opacity(0.86))
                .frame(width: 20, height: 5)
        }
        .frame(width: 58, height: 38)
    }
}

private struct SanctuaryPulseCue: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            ForEach([0.0, 9.0, 18.0], id: \.self) { offset in
                Ellipse()
                    .stroke(cue.tint.opacity(0.72 - offset / 54), lineWidth: 1.6)
                    .frame(width: 28 + offset, height: 10 + offset * 0.22)
                    .offset(y: 8)
            }

            ForEach([0.0, 90.0, 180.0, 270.0], id: \.self) { angle in
                Capsule()
                    .fill(cue.tint.opacity(0.74))
                    .frame(width: 3, height: 17)
                    .offset(y: -9)
                    .rotationEffect(.degrees(angle))
            }

            Circle()
                .fill(Color.white.opacity(0.82))
                .frame(width: 6, height: 6)
                .offset(y: -2)
        }
        .frame(width: 58, height: 38)
    }
}

private struct ResurrectionRiseCue: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            ForEach([-15.0, 0.0, 15.0], id: \.self) { offset in
                Capsule()
                    .fill(cue.tint.opacity(offset == 0 ? 0.82 : 0.52))
                    .frame(width: offset == 0 ? 5 : 3, height: offset == 0 ? 40 : 30)
                    .offset(x: offset, y: offset == 0 ? -5 : 3)
            }

            Diamond()
                .fill(cue.tint)
                .frame(width: 14, height: 14)
                .overlay(
                    Diamond()
                        .fill(Color.white.opacity(0.82))
                        .frame(width: 6, height: 6)
                )
                .offset(y: -16)

            Capsule()
                .stroke(cue.tint.opacity(0.70), lineWidth: 1.6)
                .frame(width: 38, height: 9)
                .offset(y: 16)
        }
        .frame(width: 58, height: 46)
    }
}

private struct ShieldFieldCue: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .stroke(cue.tint.opacity(0.86), lineWidth: 2)
                .frame(width: 42, height: 30)
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
                .frame(width: 30, height: 21)

            Path { path in
                path.move(to: CGPoint(x: 29, y: 7))
                path.addLine(to: CGPoint(x: 39, y: 13))
                path.addLine(to: CGPoint(x: 35, y: 27))
                path.addLine(to: CGPoint(x: 29, y: 32))
                path.addLine(to: CGPoint(x: 23, y: 27))
                path.addLine(to: CGPoint(x: 19, y: 13))
                path.closeSubpath()
            }
            .fill(cue.tint.opacity(0.28))
            .overlay(
                Path { path in
                    path.move(to: CGPoint(x: 29, y: 7))
                    path.addLine(to: CGPoint(x: 39, y: 13))
                    path.addLine(to: CGPoint(x: 35, y: 27))
                    path.addLine(to: CGPoint(x: 29, y: 32))
                    path.addLine(to: CGPoint(x: 23, y: 27))
                    path.addLine(to: CGPoint(x: 19, y: 13))
                    path.closeSubpath()
                }
                .stroke(cue.tint, lineWidth: 1.6)
            )
        }
        .frame(width: 58, height: 38)
    }
}

private struct WrathOfHeavenStormCue: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            ForEach([0.0, 1.0, 2.0], id: \.self) { index in
                let xOffset = CGFloat(index - 1) * 16

                Path { path in
                    path.move(to: CGPoint(x: 31 + xOffset, y: 4))
                    path.addLine(to: CGPoint(x: 24 + xOffset, y: 18))
                    path.addLine(to: CGPoint(x: 32 + xOffset, y: 18))
                    path.addLine(to: CGPoint(x: 26 + xOffset, y: 36))
                }
                .stroke(cue.tint.opacity(index == 1 ? 0.92 : 0.64), style: StrokeStyle(lineWidth: index == 1 ? 2.5 : 1.8, lineCap: .square, lineJoin: .miter))
            }

            Ellipse()
                .stroke(cue.tint.opacity(0.70), lineWidth: 1.7)
                .frame(width: 46, height: 13)
                .offset(y: 13)

            ForEach([CGPoint(x: 15, y: 9), CGPoint(x: 47, y: 8), CGPoint(x: 31, y: 25)], id: \.x) { point in
                Diamond()
                    .fill(Color.white.opacity(0.82))
                    .frame(width: 5, height: 5)
                    .position(point)
            }
        }
        .frame(width: 62, height: 40)
    }
}

private struct SacredBladeGlowCue: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            Capsule()
                .fill(cue.tint.opacity(0.82))
                .frame(width: 8, height: 30)
                .rotationEffect(.degrees(38))
            Capsule()
                .fill(Color.white.opacity(0.82))
                .frame(width: 3, height: 25)
                .rotationEffect(.degrees(38))
                .offset(x: -2, y: -1)

            Rectangle()
                .fill(cue.tint)
                .frame(width: 19, height: 4)
                .rotationEffect(.degrees(38))
                .offset(x: -7, y: 9)

            Rectangle()
                .fill(Color.white.opacity(0.82))
                .frame(width: 4, height: 13)
                .offset(x: 15, y: -10)
            Rectangle()
                .fill(Color.white.opacity(0.82))
                .frame(width: 13, height: 4)
                .offset(x: 15, y: -10)
        }
        .frame(width: 58, height: 38)
    }
}

private struct BuffAuraCue: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            ForEach([0.0, 12.0, 24.0], id: \.self) { angle in
                RoundedRectangle(cornerRadius: 2)
                    .stroke(cue.tint.opacity(0.68), lineWidth: 1.5)
                    .frame(width: 27, height: 17)
                    .rotationEffect(.degrees(angle))
            }

            ForEach([CGPoint(x: 15, y: 11), CGPoint(x: 29, y: 5), CGPoint(x: 43, y: 12)], id: \.x) { point in
                Circle()
                    .fill(Color.white.opacity(0.72))
                    .frame(width: 4, height: 4)
                    .position(point)
            }
        }
        .frame(width: 58, height: 38)
    }
}

private struct GeneralsCryRoarCue: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            ForEach([0.0, 1.0, 2.0], id: \.self) { index in
                Ellipse()
                    .stroke(cue.tint.opacity(0.76 - index * 0.16), lineWidth: 1.7)
                    .frame(width: 24 + index * 14, height: 13 + index * 8)
            }

            ForEach([-18.0, -8.0, 8.0, 18.0], id: \.self) { offset in
                Rectangle()
                    .fill(Color.white.opacity(0.76))
                    .frame(width: 4, height: 10)
                    .rotationEffect(.degrees(offset > 0 ? 18 : -18))
                    .offset(x: offset, y: -14)
            }

            Capsule()
                .fill(Color(red: 0.45, green: 0.17, blue: 0.08))
                .frame(width: 18, height: 7)
        }
        .frame(width: 66, height: 42)
    }
}

private struct BloodlustSurgeCue: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            ForEach([0.0, 1.0, 2.0], id: \.self) { index in
                Capsule()
                    .fill(cue.tint.opacity(0.74 - index * 0.14))
                    .frame(width: 8, height: 25 - index * 4)
                    .rotationEffect(.degrees(-24 + index * 24))
                    .offset(x: -18 + index * 18, y: 2)
            }

            Diamond()
                .fill(Color(red: 0.55, green: 0.02, blue: 0.04))
                .frame(width: 24, height: 24)

            Diamond()
                .stroke(Color.white.opacity(0.72), lineWidth: 1.3)
                .frame(width: 13, height: 13)

            ForEach([CGPoint(x: 12, y: 8), CGPoint(x: 49, y: 9), CGPoint(x: 34, y: 31)], id: \.x) { point in
                Circle()
                    .fill(Color(red: 1.0, green: 0.72, blue: 0.48).opacity(0.88))
                    .frame(width: 4, height: 4)
                    .position(point)
            }
        }
        .frame(width: 62, height: 40)
    }
}

private struct SwiftSurgeHasteCue: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            ForEach([0.0, 1.0, 2.0], id: \.self) { index in
                Path { path in
                    let y = 12 + index * 8
                    path.move(to: CGPoint(x: 7, y: y))
                    path.addLine(to: CGPoint(x: 31, y: y - 6))
                    path.addLine(to: CGPoint(x: 57, y: y - 2))
                }
                .stroke(cue.tint.opacity(0.78 - index * 0.13), style: StrokeStyle(lineWidth: 3 - index * 0.35, lineCap: .square, lineJoin: .miter))
            }

            ForEach([CGPoint(x: 22, y: 11), CGPoint(x: 38, y: 18), CGPoint(x: 51, y: 27)], id: \.x) { point in
                Diamond()
                    .fill(Color.white.opacity(0.78))
                    .frame(width: 5, height: 5)
                    .position(point)
            }

            Capsule()
                .stroke(cue.tint.opacity(0.64), lineWidth: 1.5)
                .frame(width: 40, height: 18)
                .rotationEffect(.degrees(-9))
        }
        .frame(width: 66, height: 40)
    }
}

private struct QuickLoaderHasteCue: View {
    let cue: BattleUtilityCue

    var body: some View {
        ZStack {
            ForEach([0.0, 120.0, 240.0], id: \.self) { angle in
                Capsule()
                    .fill(cue.tint.opacity(0.74))
                    .frame(width: 5, height: 20)
                    .offset(y: -11)
                    .rotationEffect(.degrees(angle))
            }

            Circle()
                .stroke(cue.tint.opacity(0.86), lineWidth: 2)
                .frame(width: 34, height: 34)

            ForEach([-17.0, 0.0, 17.0], id: \.self) { offset in
                Capsule()
                    .fill(Color.white.opacity(0.72))
                    .frame(width: 12, height: 4)
                    .offset(x: offset, y: 12)
            }

            Path { path in
                path.move(to: CGPoint(x: 32, y: 7))
                path.addLine(to: CGPoint(x: 41, y: 18))
                path.addLine(to: CGPoint(x: 32, y: 29))
            }
            .stroke(cue.tint, style: StrokeStyle(lineWidth: 2.2, lineCap: .square, lineJoin: .miter))
        }
        .frame(width: 64, height: 40)
    }
}

private struct BattleImpactCueView: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            Circle()
                .fill(cue.tint.opacity(0.16))
                .frame(width: 50, height: 50)
                .blur(radius: 2)

            switch cue {
            case .physicalSlash:
                PhysicalSlashCue(cue: cue)
            case .axeSpinImpact:
                AxeSpinImpactCue(cue: cue)
            case .bleedRendImpact:
                BleedRendImpactCue(cue: cue)
            case .shockwaveImpact:
                ShockwaveImpactCue(cue: cue)
            case .earthquakeImpact:
                EarthquakeImpactCue(cue: cue)
            case .earthquakeRockExplosion:
                EarthquakeRockExplosionCue(cue: cue)
            case .fireBurst:
                FireBurstCue(cue: cue)
            case .explosiveBoltImpact:
                ExplosiveBoltImpactCue(cue: cue)
            case .meteorImpact:
                MeteorImpactCue(cue: cue)
            case .coldBurst:
                ColdBurstCue(cue: cue)
            case .frostBoltImpact:
                FrostBoltImpactCue(cue: cue)
            case .lightningSpark:
                LightningSparkCue(cue: cue)
            case .shockBoltImpact:
                ShockBoltImpactCue(cue: cue)
            case .shockCurrentImpact:
                ShockCurrentImpactCue(cue: cue)
            case .chaosBurst:
                FireBurstCue(cue: cue)
            case .trapBurst:
                TrapBurstCue(cue: cue)
            case .summonProjectile:
                SummonProjectileCue(cue: cue)
            }
        }
        .scaleEffect(BattleSceneMetrics.effectScale)
        .shadow(color: cue.tint.opacity(0.86), radius: 7, x: 0, y: 0)
        .accessibilityLabel(cue.accessibilityLabel)
    }
}

private struct BattleIncomingCueView: View {
    let cue: BattleIncomingCue

    var body: some View {
        ZStack {
            ForEach([0.0, 9.0, 18.0], id: \.self) { offset in
                Capsule()
                    .fill(offset == 9 ? cue.secondaryTint : cue.tint)
                    .frame(width: 29 - offset * 0.35, height: offset == 9 ? 4 : 3)
                    .rotationEffect(.degrees(22))
                    .offset(x: 8 - offset, y: -8 + offset * 0.72)
            }

            Circle()
                .fill(cue.tint.opacity(0.72))
                .frame(width: 20, height: 20)
                .offset(x: -14, y: 6)
            Circle()
                .stroke(cue.secondaryTint.opacity(0.85), lineWidth: 2)
                .frame(width: 27, height: 27)
                .offset(x: -14, y: 6)
            Circle()
                .fill(Color.white.opacity(0.76))
                .frame(width: 5, height: 5)
                .offset(x: -18, y: 2)

            if cue == .lightning {
                Path { path in
                    path.move(to: CGPoint(x: 35, y: 2))
                    path.addLine(to: CGPoint(x: 24, y: 14))
                    path.addLine(to: CGPoint(x: 31, y: 14))
                    path.addLine(to: CGPoint(x: 18, y: 30))
                }
                .stroke(cue.tint, style: StrokeStyle(lineWidth: 3, lineCap: .square, lineJoin: .miter))
            }

            if cue == .chaos {
                ForEach([0.0, 120.0, 240.0], id: \.self) { angle in
                    Capsule()
                        .fill(cue.secondaryTint.opacity(0.85))
                        .frame(width: 4, height: 17)
                        .offset(x: -14, y: -7)
                        .rotationEffect(.degrees(angle))
                }
            }
        }
        .shadow(color: cue.tint.opacity(0.70), radius: 4, x: 0, y: 0)
        .accessibilityLabel(cue.accessibilityLabel)
    }
}

private struct PhysicalSlashCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            Capsule()
                .fill(cue.tint.opacity(0.20))
                .frame(width: 42, height: 22)
                .rotationEffect(.degrees(-24))

            Capsule()
                .fill(cue.secondaryTint.opacity(0.90))
                .frame(width: 40, height: 7)
                .rotationEffect(.degrees(-24))
            Capsule()
                .fill(cue.tint)
                .frame(width: 34, height: 3)
                .rotationEffect(.degrees(-24))
                .offset(x: 2, y: -1)
            Capsule()
                .fill(cue.tint.opacity(0.82))
                .frame(width: 26, height: 3)
                .rotationEffect(.degrees(22))
                .offset(x: -2, y: 6)
            Capsule()
                .fill(Color.white.opacity(0.86))
                .frame(width: 22, height: 2)
                .rotationEffect(.degrees(-24))
                .offset(x: 7, y: -5)
        }
    }
}

private struct AxeSpinImpactCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            ForEach([0.0, 10.0, 20.0], id: \.self) { offset in
                ArcSegment()
                    .stroke(offset == 10 ? cue.tint : cue.secondaryTint.opacity(0.75), style: StrokeStyle(lineWidth: offset == 10 ? 3 : 2, lineCap: .square))
                    .frame(width: 24 + offset, height: 15 + offset * 0.22)
                    .rotationEffect(.degrees(offset == 20 ? 8 : -8))
            }

            Capsule()
                .fill(Color.white.opacity(0.84))
                .frame(width: 24, height: 3)
                .rotationEffect(.degrees(-18))
                .offset(x: 8, y: -6)

            Diamond()
                .fill(cue.tint.opacity(0.90))
                .frame(width: 9, height: 9)
                .offset(x: 18, y: 6)
        }
        .frame(width: 50, height: 34)
    }
}

private struct BleedRendImpactCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            ForEach([0.0, 1.0, 2.0], id: \.self) { index in
                Path { path in
                    let y = 11 + index * 5
                    path.move(to: CGPoint(x: 5, y: y + 4))
                    path.addQuadCurve(
                        to: CGPoint(x: 43, y: y - 5),
                        control: CGPoint(x: 20, y: y - 12)
                    )
                }
                .stroke(index == 1 ? cue.tint : cue.secondaryTint.opacity(0.85), style: StrokeStyle(lineWidth: 3 - index * 0.35, lineCap: .round))
            }

            ForEach([CGPoint(x: 19, y: 23), CGPoint(x: 31, y: 14), CGPoint(x: 39, y: 24)], id: \.x) { point in
                Circle()
                    .fill(Color(red: 1.0, green: 0.48, blue: 0.36).opacity(0.82))
                    .frame(width: 4, height: 4)
                    .position(point)
            }
        }
        .frame(width: 50, height: 34)
    }
}

private struct ShockwaveImpactCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            ForEach([0.0, 10.0, 20.0], id: \.self) { offset in
                Circle()
                    .stroke(offset == 0 ? cue.secondaryTint : cue.tint.opacity(0.68), lineWidth: offset == 0 ? 3 : 1.5)
                    .frame(width: 14 + offset, height: 14 + offset)
            }
            Capsule()
                .fill(Color.white.opacity(0.78))
                .frame(width: 25, height: 2)
                .rotationEffect(.degrees(-8))
        }
    }
}

private struct EarthquakeImpactCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 3, y: 24))
                path.addLine(to: CGPoint(x: 13, y: 16))
                path.addLine(to: CGPoint(x: 21, y: 24))
                path.addLine(to: CGPoint(x: 31, y: 12))
                path.addLine(to: CGPoint(x: 42, y: 23))
            }
            .stroke(cue.secondaryTint, style: StrokeStyle(lineWidth: 3, lineCap: .square, lineJoin: .miter))

            ForEach([5.0, 17.0, 29.0, 39.0], id: \.self) { offset in
                Rectangle()
                    .fill(cue.tint)
                    .frame(width: 6, height: 5)
                    .rotationEffect(.degrees(offset == 29 ? -28 : 38))
                    .offset(x: offset - 22, y: offset == 17 ? -6 : -2)
            }
        }
        .frame(width: 48, height: 32)
    }
}

private struct EarthquakeRockExplosionCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            ForEach([0.0, 45.0, 90.0, 135.0, 180.0], id: \.self) { angle in
                Rectangle()
                    .fill(angle == 90 ? Color.white.opacity(0.78) : cue.tint)
                    .frame(width: 6, height: 15)
                    .rotationEffect(.degrees(angle))
                    .offset(y: -9)
            }

            Circle()
                .fill(cue.secondaryTint)
                .frame(width: 18, height: 18)

            ForEach([CGPoint(x: 8, y: 28), CGPoint(x: 21, y: 4), CGPoint(x: 39, y: 26)], id: \.x) { point in
                Rectangle()
                    .fill(cue.tint)
                    .frame(width: 7, height: 5)
                    .rotationEffect(.degrees(35))
                    .position(point)
            }
        }
        .frame(width: 48, height: 32)
    }
}

private struct FireBurstCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            ForEach([0.0, 72.0, 144.0, 216.0, 288.0], id: \.self) { angle in
                Capsule()
                    .fill(cue.tint)
                    .frame(width: 5, height: 18)
                    .offset(y: -8)
                    .rotationEffect(.degrees(angle))
            }
            Circle()
                .fill(cue.secondaryTint)
                .frame(width: 12, height: 12)
            Circle()
                .fill(Color.white.opacity(0.80))
                .frame(width: 5, height: 5)
        }
    }
}

private struct ExplosiveBoltImpactCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            ForEach([0.0, 60.0, 120.0, 180.0, 240.0, 300.0], id: \.self) { angle in
                Capsule()
                    .fill(cue.tint)
                    .frame(width: 5, height: 20)
                    .offset(y: -9)
                    .rotationEffect(.degrees(angle))
            }

            Circle()
                .fill(cue.secondaryTint)
                .frame(width: 18, height: 18)
            Circle()
                .fill(Color(red: 1.0, green: 0.78, blue: 0.18))
                .frame(width: 10, height: 10)

            ForEach([CGPoint(x: 7, y: 22), CGPoint(x: 37, y: 9), CGPoint(x: 33, y: 27)], id: \.x) { point in
                Rectangle()
                    .fill(Color.white.opacity(0.76))
                    .frame(width: 6, height: 2)
                    .rotationEffect(.degrees(point.y > 20 ? -26 : 34))
                    .position(point)
            }
        }
        .frame(width: 48, height: 32)
    }
}

private struct MeteorImpactCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            ForEach([0.0, 45.0, 90.0, 135.0], id: \.self) { angle in
                Capsule()
                    .fill(cue.tint)
                    .frame(width: 5, height: 24)
                    .offset(y: -10)
                    .rotationEffect(.degrees(angle))
            }
            Circle()
                .fill(cue.secondaryTint)
                .frame(width: 24, height: 24)
            Circle()
                .fill(cue.tint)
                .frame(width: 15, height: 15)
            Circle()
                .fill(Color(red: 1.0, green: 0.88, blue: 0.28))
                .frame(width: 6, height: 6)
        }
    }
}

private struct ColdBurstCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            ForEach([0.0, 60.0, 120.0], id: \.self) { angle in
                Rectangle()
                    .fill(cue.tint)
                    .frame(width: 3, height: 25)
                    .rotationEffect(.degrees(angle))
            }
            Circle()
                .stroke(cue.tint, lineWidth: 2)
                .frame(width: 20, height: 20)
            ForEach([0.0, 90.0, 180.0, 270.0], id: \.self) { angle in
                Rectangle()
                    .fill(cue.secondaryTint)
                    .frame(width: 4, height: 4)
                    .offset(y: -12)
                    .rotationEffect(.degrees(angle))
            }
        }
    }
}

private struct FrostBoltImpactCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            Circle()
                .stroke(cue.tint, lineWidth: 3)
                .frame(width: 25, height: 25)
            Circle()
                .stroke(Color.white.opacity(0.72), lineWidth: 1.4)
                .frame(width: 15, height: 15)

            ForEach([0.0, 45.0, 90.0, 135.0], id: \.self) { angle in
                Rectangle()
                    .fill(cue.tint)
                    .frame(width: 3, height: 25)
                    .rotationEffect(.degrees(angle))
            }

            ForEach([CGPoint(x: 8, y: 7), CGPoint(x: 39, y: 9), CGPoint(x: 15, y: 27), CGPoint(x: 34, y: 25)], id: \.x) { point in
                Diamond()
                    .fill(Color.white.opacity(0.78))
                    .frame(width: 5, height: 5)
                    .position(point)
            }
        }
        .frame(width: 48, height: 32)
    }
}

private struct LightningSparkCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 26, y: 1))
                path.addLine(to: CGPoint(x: 15, y: 14))
                path.addLine(to: CGPoint(x: 22, y: 14))
                path.addLine(to: CGPoint(x: 11, y: 31))
            }
            .stroke(cue.tint, style: StrokeStyle(lineWidth: 4, lineCap: .square, lineJoin: .miter))

            Path { path in
                path.move(to: CGPoint(x: 24, y: 2))
                path.addLine(to: CGPoint(x: 16, y: 13))
                path.addLine(to: CGPoint(x: 23, y: 13))
                path.addLine(to: CGPoint(x: 14, y: 29))
            }
            .stroke(cue.secondaryTint, style: StrokeStyle(lineWidth: 1.5, lineCap: .square, lineJoin: .miter))
        }
        .frame(width: 36, height: 32)
    }
}

private struct ShockBoltImpactCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            Diamond()
                .fill(cue.secondaryTint.opacity(0.82))
                .frame(width: 15, height: 15)
                .offset(x: 5, y: 5)

            Path { path in
                path.move(to: CGPoint(x: 31, y: 1))
                path.addLine(to: CGPoint(x: 19, y: 14))
                path.addLine(to: CGPoint(x: 27, y: 14))
                path.addLine(to: CGPoint(x: 15, y: 31))
            }
            .stroke(cue.tint, style: StrokeStyle(lineWidth: 4, lineCap: .square, lineJoin: .miter))

            Path { path in
                path.move(to: CGPoint(x: 29, y: 2))
                path.addLine(to: CGPoint(x: 21, y: 13))
                path.addLine(to: CGPoint(x: 28, y: 13))
                path.addLine(to: CGPoint(x: 19, y: 29))
            }
            .stroke(Color.white.opacity(0.80), style: StrokeStyle(lineWidth: 1.5, lineCap: .square, lineJoin: .miter))
        }
        .frame(width: 48, height: 32)
    }
}

private struct ShockCurrentImpactCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            ForEach([0.0, 9.0, 18.0], id: \.self) { offset in
                Circle()
                    .stroke(cue.tint.opacity(0.78 - offset / 52), lineWidth: offset == 0 ? 2.6 : 1.5)
                    .frame(width: 13 + offset, height: 13 + offset)
            }

            ForEach([0.0, 120.0, 240.0], id: \.self) { angle in
                Path { path in
                    path.move(to: CGPoint(x: 24, y: 4))
                    path.addLine(to: CGPoint(x: 18, y: 15))
                    path.addLine(to: CGPoint(x: 24, y: 15))
                    path.addLine(to: CGPoint(x: 18, y: 28))
                }
                .stroke(Color.white.opacity(0.78), style: StrokeStyle(lineWidth: 1.4, lineCap: .square, lineJoin: .miter))
                .rotationEffect(.degrees(angle))
            }
        }
        .frame(width: 48, height: 32)
    }
}

private struct TrapBurstCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1)
                .stroke(cue.tint, lineWidth: 2)
                .frame(width: 23, height: 23)
                .rotationEffect(.degrees(45))
            RoundedRectangle(cornerRadius: 1)
                .fill(cue.secondaryTint.opacity(0.78))
                .frame(width: 15, height: 15)
                .rotationEffect(.degrees(45))
            Circle()
                .fill(cue.tint)
                .frame(width: 5, height: 5)
        }
    }
}

private struct SummonProjectileCue: View {
    let cue: BattleImpactCue

    var body: some View {
        ZStack {
            Capsule()
                .fill(cue.secondaryTint)
                .frame(width: 30, height: 8)
                .rotationEffect(.degrees(-12))
                .offset(x: -5, y: 2)
            Circle()
                .fill(cue.tint)
                .frame(width: 15, height: 15)
                .offset(x: 10, y: -1)
            Circle()
                .fill(Color.white.opacity(0.72))
                .frame(width: 5, height: 5)
                .offset(x: 13, y: -4)
        }
    }
}

private struct PlayerDeployableStack: View {
    let deployables: [PlayerBattleDeployable]

    var body: some View {
        let scale = BattleSceneMetrics.deployableScale

        HStack(alignment: .bottom, spacing: 3 * scale) {
            ForEach(Array(deployables.prefix(3)), id: \.self) { deployable in
                PlayerDeployableGlyph(deployable: deployable)
                    .scaleEffect(scale, anchor: .bottom)
                    .frame(width: 18 * scale, height: 20 * scale, alignment: .bottom)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PlayerDeployableGlyph: View {
    let deployable: PlayerBattleDeployable

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(Color.black.opacity(0.32))
                .frame(width: 18, height: 4)
                .offset(y: 1)

            switch deployable {
            case .flameHydra:
                HydraGlyph()
            case .chargedTrap:
                TrapGlyph()
            case .crossbowTurret:
                TurretGlyph()
            }
        }
        .frame(width: 18, height: 20, alignment: .bottom)
        .accessibilityLabel(deployable.accessibilityLabel)
    }
}

private struct HydraGlyph: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(0..<3, id: \.self) { index in
                VStack(spacing: 0) {
                    Circle()
                        .fill(index == 1 ? Color(red: 1.0, green: 0.78, blue: 0.24) : Color(red: 1.0, green: 0.34, blue: 0.10))
                        .frame(width: index == 1 ? 5 : 4, height: index == 1 ? 5 : 4)
                    Rectangle()
                        .fill(Color(red: 0.62, green: 0.12, blue: 0.08))
                        .frame(width: 2, height: index == 1 ? 10 : 8)
                }
                .offset(y: index == 1 ? -1 : 0)
            }
        }
        .padding(.bottom, 3)
    }
}

private struct TrapGlyph: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.10, green: 0.34, blue: 0.34))
                .frame(width: 15, height: 15)
                .rotationEffect(.degrees(45))

            RoundedRectangle(cornerRadius: 1)
                .stroke(Color(red: 0.42, green: 1.0, blue: 0.88), lineWidth: 1.8)
                .frame(width: 14, height: 14)
                .rotationEffect(.degrees(45))

            Circle()
                .fill(Color(red: 1.0, green: 0.92, blue: 0.24))
                .frame(width: 4, height: 4)
        }
        .padding(.bottom, 3)
    }
}

private struct TurretGlyph: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(red: 0.78, green: 0.62, blue: 0.34))
                .frame(width: 13, height: 4)
                .offset(y: -3)

            Rectangle()
                .fill(Color(red: 0.82, green: 0.84, blue: 0.82))
                .frame(width: 8, height: 7)
                .offset(y: -6)

            Rectangle()
                .fill(Color(red: 0.08, green: 0.10, blue: 0.10))
                .frame(width: 12, height: 2)
                .offset(x: 4, y: -10)

            Rectangle()
                .fill(Color(red: 0.44, green: 0.30, blue: 0.18))
                .frame(width: 3, height: 8)
        }
        .frame(width: 17, height: 18)
        .padding(.bottom, 2)
    }
}

private struct EnemyWaveView: View {
    @ObservedObject var battle: Battle
    let spriteSize: CGSize
    let isStriking: Bool
    let isHit: Bool
    let animationTime: TimeInterval

    var body: some View {
        ZStack(alignment: .bottom) {
            if let activeEnemy = battle.activeEnemyState {
                let sideEnemies = Array(battle.aliveEnemyStates.filter { $0.index != activeEnemy.index }.prefix(3))

                PeripheralEnemyStack(enemyStates: sideEnemies, animationTime: animationTime)
                    .offset(x: -14, y: -2)
                    .zIndex(1)

                CombatantView(
                    imageName: GameArt.battleMonsterSpriteName(for: activeEnemy.monster.id),
                    hp: activeEnemy.hp,
                    maxHP: activeEnemy.maxHP,
                    tint: .red,
                    spriteSize: spriteSize,
                    isHero: false,
                    isStriking: isStriking,
                    isHit: isHit,
                    statusBadges: EnemyStatusBadge.visible(for: activeEnemy),
                    animationTime: animationTime,
                    idlePhase: 2.1
                )
                .zIndex(3)

                if battle.monsterCount > 1 {
                    WaveProgressDots(current: battle.currentMonsterNumber, total: battle.monsterCount)
                        .offset(y: 1)
                        .zIndex(4)
                }
            }
        }
    }
}

private struct PeripheralEnemyStack: View {
    let enemyStates: [BattleEnemyState]
    let animationTime: TimeInterval

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ForEach(Array(enemyStates.enumerated()), id: \.element.id) { index, state in
                MiniEnemyView(state: state, animationTime: animationTime, idlePhase: Double(index) * 0.7)
                    .opacity(0.72 - Double(index) * 0.10)
                    .offset(x: CGFloat(index) * -10 * BattleSceneMetrics.visualScale, y: CGFloat(index) * -2 * BattleSceneMetrics.visualScale)
                    .zIndex(Double(enemyStates.count - index))
            }
        }
        .frame(width: 48 * BattleSceneMetrics.visualScale, height: 34 * BattleSceneMetrics.visualScale, alignment: .bottomTrailing)
        .accessibilityHidden(true)
    }
}

private struct MiniEnemyView: View {
    let state: BattleEnemyState
    let animationTime: TimeInterval
    let idlePhase: Double

    var body: some View {
        VStack(spacing: 1) {
            CompactHPBar(hp: state.hp, maxHP: state.maxHP, tint: .red, width: 18 * BattleSceneMetrics.visualScale)
            ZStack(alignment: .topTrailing) {
                EnemyStatusAuraView(
                    badges: EnemyStatusBadge.visible(for: state),
                    compact: true,
                    scale: BattleSceneMetrics.effectScale
                )
                .offset(y: battleIdleYOffset(time: animationTime, phase: idlePhase, amplitude: 1))

                PixelSprite(
                    imageName: GameArt.battleMonsterSpriteName(for: state.monster.id),
                    size: CGSize(width: 18 * BattleSceneMetrics.visualScale, height: 24 * BattleSceneMetrics.visualScale)
                )
                .saturation(0.86)
                .offset(y: battleIdleYOffset(time: animationTime, phase: idlePhase, amplitude: 1))

                EnemyStatusBadgeStack(
                    badges: EnemyStatusBadge.visible(for: state),
                    iconSize: 5 * BattleSceneMetrics.effectScale
                )
                .offset(x: 3 * BattleSceneMetrics.effectScale, y: -2 * BattleSceneMetrics.effectScale)
            }
        }
    }
}

enum EnemyStatusBadge: String, CaseIterable {
    case stunned
    case chilled
    case frozen
    case bleeding

    var systemImageName: String {
        switch self {
        case .stunned:
            return "star.fill"
        case .chilled, .frozen:
            return "snowflake"
        case .bleeding:
            return "drop.fill"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .stunned:
            return "眩晕"
        case .chilled:
            return "寒冷"
        case .frozen:
            return "冻结"
        case .bleeding:
            return "出血"
        }
    }

    var tint: Color {
        switch self {
        case .stunned:
            return Color(red: 1.0, green: 0.78, blue: 0.18)
        case .chilled:
            return Color(red: 0.45, green: 0.90, blue: 1.0)
        case .frozen:
            return Color(red: 0.20, green: 0.55, blue: 1.0)
        case .bleeding:
            return .red
        }
    }

    static func visible(for state: BattleEnemyState) -> [EnemyStatusBadge] {
        var badges: [EnemyStatusBadge] = []
        if state.isStunned {
            badges.append(.stunned)
        }
        switch state.coldStatus {
        case .chilled:
            badges.append(.chilled)
        case .frozen:
            badges.append(.frozen)
        case .none:
            break
        }
        if state.isBleeding {
            badges.append(.bleeding)
        }
        return badges
    }
}

private struct EnemyStatusBadgeStack: View {
    let badges: [EnemyStatusBadge]
    let iconSize: CGFloat

    var body: some View {
        HStack(spacing: 2) {
            ForEach(badges, id: \.self) { badge in
                Image(systemName: badge.systemImageName)
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundColor(badge.tint)
                    .shadow(color: .black.opacity(0.55), radius: 1, x: 0, y: 0)
                    .accessibilityLabel(badge.accessibilityLabel)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct EnemyStatusAuraView: View {
    let badges: [EnemyStatusBadge]
    let compact: Bool
    let scale: CGFloat

    var body: some View {
        ZStack {
            if badges.contains(.chilled) {
                chilledMist
            }
            if badges.contains(.frozen) {
                frozenCrystals
            }
            if badges.contains(.stunned) {
                stunnedSparks
            }
            if badges.contains(.bleeding) {
                bleedingMarks
            }
        }
        .frame(width: baseWidth * scale, height: baseHeight * scale)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var baseWidth: CGFloat { compact ? 24 : 56 }
    private var baseHeight: CGFloat { compact ? 30 : 62 }
    private var strokeWidth: CGFloat { max(1.0, (compact ? 0.75 : 1.25) * scale) }

    private var chilledMist: some View {
        ZStack {
            Capsule()
                .stroke(Color(red: 0.36, green: 0.95, blue: 1.0).opacity(0.72), lineWidth: strokeWidth)
                .frame(width: baseWidth * 0.82 * scale, height: baseHeight * 0.40 * scale)
                .offset(y: baseHeight * 0.12 * scale)

            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color(red: 0.46, green: 0.94, blue: 1.0).opacity(0.82))
                    .frame(width: mistDotSize(for: index) * scale, height: mistDotSize(for: index) * scale)
                    .offset(
                        x: mistXOffset(for: index) * scale,
                        y: mistYOffset(for: index) * scale
                    )
            }
        }
    }

    private var frozenCrystals: some View {
        ZStack {
            Capsule()
                .fill(Color(red: 0.18, green: 0.50, blue: 1.0).opacity(0.28))
                .frame(width: baseWidth * 0.72 * scale, height: baseHeight * 0.82 * scale)

            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(frostColor(for: index))
                    .frame(
                        width: (compact ? 2.2 : 3.6) * scale,
                        height: frostHeight(for: index) * scale
                    )
                    .rotationEffect(.degrees(frostRotation(for: index)))
                    .offset(
                        x: frostXOffset(for: index) * scale,
                        y: frostYOffset(for: index) * scale
                    )
            }
        }
    }

    private var stunnedSparks: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Image(systemName: index == 1 ? "sparkle" : "star.fill")
                    .font(.system(size: stunSparkSize(for: index) * scale, weight: .black))
                    .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.14))
                    .shadow(color: Color(red: 1.0, green: 0.48, blue: 0.04).opacity(0.75), radius: compact ? 0.8 : 1.6)
                    .offset(
                        x: stunXOffset(for: index) * scale,
                        y: stunYOffset(for: index) * scale
                    )
            }
        }
    }

    private var bleedingMarks: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(Color(red: 0.95, green: 0.06, blue: 0.06).opacity(index == 2 ? 0.86 : 0.95))
                    .frame(
                        width: bloodWidth(for: index) * scale,
                        height: bloodHeight(for: index) * scale
                    )
                    .rotationEffect(.degrees(bloodRotation(for: index)))
                    .offset(
                        x: bloodXOffset(for: index) * scale,
                        y: bloodYOffset(for: index) * scale
                    )
            }
        }
    }

    private func mistDotSize(for index: Int) -> CGFloat {
        compact ? [2.4, 2.0, 1.8][index] : [4.8, 3.8, 3.4][index]
    }

    private func mistXOffset(for index: Int) -> CGFloat {
        compact ? [-8, 0, 8][index] : [-17, 0, 17][index]
    }

    private func mistYOffset(for index: Int) -> CGFloat {
        compact ? [1, -4, 2][index] : [4, -8, 5][index]
    }

    private func frostColor(for index: Int) -> Color {
        index.isMultiple(of: 2)
            ? Color(red: 0.80, green: 0.96, blue: 1.0).opacity(0.88)
            : Color(red: 0.20, green: 0.56, blue: 1.0).opacity(0.86)
    }

    private func frostHeight(for index: Int) -> CGFloat {
        compact ? [12, 9, 10, 8][index] : [28, 20, 24, 18][index]
    }

    private func frostXOffset(for index: Int) -> CGFloat {
        compact ? [-7, -2, 5, 9][index] : [-18, -5, 12, 20][index]
    }

    private func frostYOffset(for index: Int) -> CGFloat {
        compact ? [-1, -7, -5, 1][index] : [-2, -16, -11, 4][index]
    }

    private func frostRotation(for index: Int) -> Double {
        [-18, 12, -8, 20][index]
    }

    private func stunSparkSize(for index: Int) -> CGFloat {
        compact ? [3.2, 2.6, 2.8, 2.2][index] : [7.4, 5.8, 6.6, 5.2][index]
    }

    private func stunXOffset(for index: Int) -> CGFloat {
        compact ? [-8, -1, 7, 2][index] : [-20, -3, 18, 6][index]
    }

    private func stunYOffset(for index: Int) -> CGFloat {
        compact ? [-13, -17, -13, -9][index] : [-31, -39, -30, -23][index]
    }

    private func bloodWidth(for index: Int) -> CGFloat {
        compact ? [2.5, 2.0, 1.8][index] : [5.0, 4.0, 3.4][index]
    }

    private func bloodHeight(for index: Int) -> CGFloat {
        compact ? [9, 7, 5][index] : [18, 14, 11][index]
    }

    private func bloodXOffset(for index: Int) -> CGFloat {
        compact ? [-6, -1, 5][index] : [-14, -2, 12][index]
    }

    private func bloodYOffset(for index: Int) -> CGFloat {
        compact ? [6, 9, 7][index] : [14, 22, 17][index]
    }

    private func bloodRotation(for index: Int) -> Double {
        [-18, 8, 24][index]
    }
}

private struct WaveProgressDots: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<min(total, 10), id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(index < current ? Color.red.opacity(0.95) : Color.white.opacity(0.28))
                    .frame(width: 5, height: 3)
            }
            if total > 10 {
                Text("+\(total - 10)")
                    .font(.system(size: 5, weight: .black, design: .monospaced))
                    .foregroundColor(.white.opacity(0.72))
            }
        }
        .padding(.horizontal, 3)
        .padding(.vertical, 1)
        .background(Color.black.opacity(0.42))
        .cornerRadius(2)
        .accessibilityHidden(true)
    }
}

private enum BattleActionFrameDirection {
    case left
    case right
}

private struct BattleActionFrameCueView: View {
    let direction: BattleActionFrameDirection
    let tint: Color

    var body: some View {
        let scale = BattleSceneMetrics.effectScale
        let sign: CGFloat = direction == .right ? 1 : -1

        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Rectangle()
                    .fill(tint.opacity(0.72 - Double(index) * 0.16))
                    .frame(
                        width: (18 - CGFloat(index) * 4) * scale,
                        height: max(CGFloat(2), 2 * scale)
                    )
                    .offset(
                        x: sign * (CGFloat(index) * 5 - 4) * scale,
                        y: (CGFloat(index) - 1) * 4 * scale
                    )
            }
        }
        .frame(width: 32 * scale, height: 22 * scale)
        .rotationEffect(.degrees(direction == .right ? -8 : 8))
        .shadow(color: tint.opacity(0.55), radius: 2 * scale)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct PartyCombatantView: View {
    @ObservedObject var battle: Battle
    let isHeroStriking: Bool
    let isSupportStriking: Bool
    let isHit: Bool
    let animationTime: TimeInterval

    var body: some View {
        ZStack(alignment: .bottom) {
            CompactHPBar(
                hp: battle.heroHP,
                maxHP: battle.hero.maxHP,
                tint: .green,
                width: 46 * BattleSceneMetrics.visualScale
            )
            .offset(x: mainHeroXOffset, y: -62 * BattleSceneMetrics.visualScale)
            .zIndex(6)

            ZStack(alignment: .bottom) {
                Ellipse()
                    .fill(Color.black.opacity(0.24))
                    .frame(width: 88 * BattleSceneMetrics.visualScale, height: 8 * BattleSceneMetrics.visualScale)
                    .offset(y: -2 * BattleSceneMetrics.visualScale)

                ForEach(Array(battle.supportStates.enumerated()), id: \.element.id) { index, state in
                    ZStack(alignment: .top) {
                        PixelSprite(
                            imageName: GameArt.battleHeroSpriteName(for: state.member.heroClass),
                            size: BattleHeroSpriteMetrics.supportSize(for: state.member.heroClass)
                        )
                        .scaleEffect(x: BattleHeroSpriteMetrics.enemyFacingXScale, y: 1, anchor: .center)
                        .scaleEffect(
                            x: isHit && !state.isDefeated ? 1.04 : 1,
                            y: isHit && !state.isDefeated ? BattleSceneMetrics.hitSquashYScale : 1,
                            anchor: .bottom
                        )
                        .overlay {
                            if isSupportStriking && !state.isDefeated {
                                BattleActionFrameCueView(direction: .right, tint: .cyan)
                                    .offset(x: 14 * BattleSceneMetrics.effectScale, y: -2 * BattleSceneMetrics.effectScale)
                            }
                        }

                        CompactHPBar(
                            hp: state.hp,
                            maxHP: state.maxHP,
                            tint: state.isDefeated ? .gray : .green,
                            width: BattleSceneMetrics.supportHPBarWidth * BattleSceneMetrics.visualScale
                        )
                        .offset(y: -3 * BattleSceneMetrics.visualScale)
                    }
                    .opacity(state.isDefeated ? 0.30 : 0.72)
                    .saturation(state.isDefeated ? 0.25 : 1)
                    .scaleEffect(isSupportStriking && !state.isDefeated ? 1.06 : 1.0, anchor: .bottom)
                    .offset(
                        x: supportOffset(index: index) + battleIdleXOffset(time: animationTime, phase: Double(index) * 0.9 + 0.6, amplitude: state.isDefeated ? 0 : 1),
                        y: supportYOffset(index: index) + battleIdleYOffset(time: animationTime, phase: Double(index) * 0.9 + 0.6, amplitude: state.isDefeated ? 0 : 1)
                    )
                    .brightness(isHit && !state.isDefeated ? 0.18 : 0)
                    .zIndex(Double(index + 1))
                }

                PixelSprite(
                    imageName: GameArt.battleHeroSpriteName(for: battle.primaryHeroClass),
                    size: BattleHeroSpriteMetrics.mainSize(for: battle.primaryHeroClass)
                )
                .scaleEffect(x: BattleHeroSpriteMetrics.enemyFacingXScale, y: 1, anchor: .center)
                .scaleEffect(
                    x: isHit ? 1.06 : 1,
                    y: isHit ? BattleSceneMetrics.hitSquashYScale : 1,
                    anchor: .bottom
                )
                .scaleEffect(isHeroStriking ? 1.05 : 1.0, anchor: .bottom)
                .overlay {
                    if isHeroStriking {
                        BattleActionFrameCueView(direction: .right, tint: .white)
                            .offset(x: 16 * BattleSceneMetrics.effectScale, y: -3 * BattleSceneMetrics.effectScale)
                    }
                }
                .offset(
                    x: mainHeroXOffset + (isHeroStriking ? BattleSceneMetrics.strikeLungeDistance : 0) + battleIdleXOffset(time: animationTime, phase: 0.0, amplitude: 1),
                    y: battleIdleYOffset(time: animationTime, phase: 0.0, amplitude: 2)
                )
                .brightness(isHit ? 0.28 : 0)
                .saturation(isHit ? 0.75 : 1)
                .zIndex(5)

                if isHit {
                    Image(systemName: "burst.fill")
                        .font(.system(size: 11 * BattleSceneMetrics.visualScale, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(color: .orange, radius: 3)
                        .offset(x: 20 * BattleSceneMetrics.visualScale, y: -40 * BattleSceneMetrics.visualScale)
                        .zIndex(7)
                }
            }
            .frame(width: 126 * BattleSceneMetrics.visualScale, height: BattleSceneMetrics.combatantFrameHeight, alignment: .bottom)
        }
    }

    private var mainHeroXOffset: CGFloat {
        -40 * BattleSceneMetrics.visualScale
    }

    private func supportOffset(index: Int) -> CGFloat {
        (index == 0 ? -58 : -74) * BattleSceneMetrics.visualScale
    }

    private func supportYOffset(index: Int) -> CGFloat {
        (index == 0 ? -1 : 2) * BattleSceneMetrics.visualScale
    }
}

struct CombatantView: View {
    let imageName: String
    let hp: Int
    let maxHP: Int
    let tint: Color
    let spriteSize: CGSize
    let isHero: Bool
    let isStriking: Bool
    let isHit: Bool
    let statusBadges: [EnemyStatusBadge]
    let animationTime: TimeInterval
    let idlePhase: Double

    var body: some View {
        ZStack(alignment: .bottom) {
            CompactHPBar(hp: hp, maxHP: maxHP, tint: tint, width: 46 * BattleSceneMetrics.visualScale)
                .offset(y: -62 * BattleSceneMetrics.visualScale)
            .zIndex(4)

            ZStack(alignment: .center) {
                Ellipse()
                    .fill(Color.black.opacity(0.26))
                    .frame(width: 58 * BattleSceneMetrics.visualScale, height: 8 * BattleSceneMetrics.visualScale)
                    .offset(y: 28 * BattleSceneMetrics.visualScale)

                if !statusBadges.isEmpty {
                    EnemyStatusAuraView(
                        badges: statusBadges,
                        compact: false,
                        scale: BattleSceneMetrics.effectScale
                    )
                    .offset(
                        x: (isHero ? 0 : -2) * BattleSceneMetrics.effectScale,
                        y: -2 * BattleSceneMetrics.effectScale
                    )
                    .zIndex(1)
                }

                PixelSprite(imageName: imageName, size: spriteSize)
                    .scaleEffect(
                        x: isHit ? 1.06 : 1,
                        y: isHit ? BattleSceneMetrics.hitSquashYScale : 1,
                        anchor: .bottom
                    )
                    .scaleEffect(isStriking ? 1.05 : 1.0, anchor: .bottom)
                    .overlay {
                        if isStriking {
                            BattleActionFrameCueView(
                                direction: isHero ? .right : .left,
                                tint: isHero ? .white : .red
                            )
                            .offset(
                                x: (isHero ? 16 : -16) * BattleSceneMetrics.effectScale,
                                y: -3 * BattleSceneMetrics.effectScale
                            )
                        }
                    }
                    .offset(
                        x: (isStriking ? (isHero ? BattleSceneMetrics.strikeLungeDistance : -BattleSceneMetrics.strikeLungeDistance) : 0) + battleIdleXOffset(time: animationTime, phase: idlePhase, amplitude: 1),
                        y: battleIdleYOffset(time: animationTime, phase: idlePhase, amplitude: 2)
                    )
                    .brightness(isHit ? 0.28 : 0)
                    .saturation(isHit ? 0.75 : 1)
                    .zIndex(2)

                if isHit {
                    Image(systemName: "burst.fill")
                        .font(.system(size: 11 * BattleSceneMetrics.visualScale, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(color: .orange, radius: 3)
                        .offset(x: (isHero ? 15 : -18) * BattleSceneMetrics.visualScale, y: -12 * BattleSceneMetrics.visualScale)
                        .zIndex(3)
                }

                if !statusBadges.isEmpty {
                    EnemyStatusBadgeStack(badges: statusBadges, iconSize: 8 * BattleSceneMetrics.effectScale)
                        .padding(3 * BattleSceneMetrics.effectScale)
                        .background(Color.black.opacity(0.42))
                        .clipShape(Capsule())
                        .offset(x: (isHero ? 18 : -22) * BattleSceneMetrics.effectScale, y: -28 * BattleSceneMetrics.effectScale)
                        .zIndex(4)
                }
            }
            .frame(width: 76 * BattleSceneMetrics.visualScale, height: BattleSceneMetrics.combatantFrameHeight)
        }
    }
}

private func battleIdleYOffset(time: TimeInterval, phase: Double, amplitude: CGFloat) -> CGFloat {
    guard amplitude > 0 else { return 0 }
    let wave = sin(time * 5.0 + phase)
    if wave > 0.45 { return -amplitude }
    if wave < -0.45 { return amplitude * 0.5 }
    return 0
}

private func battleIdleXOffset(time: TimeInterval, phase: Double, amplitude: CGFloat) -> CGFloat {
    guard amplitude > 0 else { return 0 }
    let wave = sin(time * 3.1 + phase + 1.2)
    if wave > 0.70 { return amplitude }
    if wave < -0.70 { return -amplitude }
    return 0
}

private struct BattleArenaBackdrop: View {
    let fixedTime: TimeInterval?

    var body: some View {
        Group {
            if let fixedTime {
                BattleArenaBackdropFrame(time: fixedTime)
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / BattleSceneMetrics.flameAnimationFrameRate)) { timeline in
                    BattleArenaBackdropFrame(time: timeline.date.timeIntervalSinceReferenceDate)
                }
            }
        }
    }
}

private struct BattleArenaBackdropFrame: View {
    let time: TimeInterval

    var body: some View {
        GeometryReader { proxy in
            let platformWidth = proxy.size.width * BattleSceneMetrics.groundPlatformWidthRatio

            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.14, blue: 0.18),
                        Color(red: 0.11, green: 0.18, blue: 0.21),
                        Color(red: 0.28, green: 0.11, blue: 0.06)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.96, green: 0.58, blue: 0.16),
                                Color(red: 0.61, green: 0.27, blue: 0.10)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(
                        width: platformWidth,
                        height: BattleSceneMetrics.compactHeight * BattleSceneMetrics.groundHeightRatio
                    )

                PixelFlameBand(time: time)
                    .frame(width: platformWidth, height: BattleSceneMetrics.compactHeight)

                Rectangle()
                    .fill(Color.yellow.opacity(0.22))
                    .frame(width: platformWidth, height: 2)
                    .offset(y: -(BattleSceneMetrics.compactHeight * BattleSceneMetrics.groundHeightRatio - 1))
            }
        }
    }
}

private struct PixelFlameBand: View {
    let time: TimeInterval

    var body: some View {
        Canvas { context, size in
            let groundHeight = BattleSceneMetrics.compactHeight * BattleSceneMetrics.groundHeightRatio
            let columnCount = max(BattleSceneMetrics.flameColumnCount, 1)
            let columnWidth = max(size.width / CGFloat(columnCount), 3)
            let bottom = size.height

            for index in 0..<columnCount {
                let x = CGFloat(index) * columnWidth
                let phase = time * 4.2 + Double(index) * 0.73
                let lift = CGFloat((sin(phase) + 1) / 2)
                let flicker = CGFloat((sin(phase * 1.7 + 1.3) + 1) / 2)
                let flameHeight = groundHeight * (0.22 + lift * 0.58)
                let baseOpacity = 0.18 + Double(flicker) * 0.18

                let baseRect = CGRect(
                    x: x.rounded(.down),
                    y: bottom - flameHeight,
                    width: ceil(columnWidth),
                    height: flameHeight
                )
                context.fill(
                    Path(baseRect),
                    with: .color(Color(red: 1.0, green: 0.34, blue: 0.08).opacity(baseOpacity))
                )

                let tipWidth = max(columnWidth * 0.42, 2)
                let tipHeight = max(flameHeight * 0.34, 2)
                let tipRect = CGRect(
                    x: x + (columnWidth - tipWidth) / 2,
                    y: bottom - flameHeight - tipHeight * 0.16,
                    width: tipWidth,
                    height: tipHeight
                )
                context.fill(
                    Path(tipRect),
                    with: .color(Color(red: 1.0, green: 0.78, blue: 0.20).opacity(0.10 + Double(lift) * 0.14))
                )
            }
        }
        .frame(height: BattleSceneMetrics.compactHeight)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct StagePill: View {
    let progress: ProgressTracker

    var body: some View {
        Text(BattleSceneLabels.stagePillText(progress: progress))
            .font(.system(size: 8, weight: .black, design: .monospaced))
            .lineLimit(1)
            .foregroundColor(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.55))
            .cornerRadius(3)
    }
}

private struct CompactHPBar: View {
    let hp: Int
    let maxHP: Int
    let tint: Color
    let width: CGFloat

    var body: some View {
        GeometryReader { geo in
            let hpRatio = min(max(CGFloat(hp) / CGFloat(max(maxHP, 1)), 0), 1)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.black.opacity(0.55))
                RoundedRectangle(cornerRadius: 1)
                    .fill(tint)
                    .frame(width: geo.size.width * hpRatio)
            }
        }
        .frame(width: width, height: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 1)
                .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
        )
    }
}

private struct FloatingDamageText: View {
    let entry: BattleLogEntry

    var body: some View {
        let style = BattleFloatingDamageStyle.presentation(for: entry)

        Text(BattleFloatingDamageText.displayText(for: entry))
            .font(.system(size: style.fontSize, weight: style.isHeavy ? .black : .bold, design: .monospaced))
            .foregroundColor(textColor)
            .lineLimit(1)
            .minimumScaleFactor(0.65)
            .padding(.horizontal, style.horizontalPadding)
            .padding(.vertical, style.verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(style.backgroundOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(textColor.opacity(style.borderOpacity), lineWidth: 0.7)
                    )
            )
            .cornerRadius(3)
            .shadow(color: shadowColor, radius: style.shadowRadius)
            .offset(y: style.verticalOffset)
    }

    private var textColor: Color {
        switch entry.kind {
        case .damage:
            if entry.isCrit, entry.damageElement == .none || entry.damageElement == .physical {
                return .orange
            }
            return entry.damageElement.battleColor
        case .heal:
            return .green
        case .buff:
            return .cyan
        case .dodge:
            return .mint
        case .block:
            return .blue
        }
    }

    private var shadowColor: Color {
        if entry.isCrit {
            return entry.damageElement == .none ? .orange : entry.damageElement.battleColor
        }
        return entry.damageElement == .none ? .black.opacity(0.5) : entry.damageElement.battleColor.opacity(0.45)
    }
}

enum BattleFloatingDamageTone: Equatable {
    case damage
    case criticalDamage
    case heal
    case buff
    case dodge
    case block
}

struct BattleFloatingDamageStyle: Equatable {
    let tone: BattleFloatingDamageTone
    let fontSize: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let backgroundOpacity: Double
    let borderOpacity: Double
    let shadowRadius: CGFloat
    let verticalOffset: CGFloat
    let isHeavy: Bool

    static func presentation(for entry: BattleLogEntry) -> BattleFloatingDamageStyle {
        switch entry.kind {
        case .damage where entry.isCrit:
            return BattleFloatingDamageStyle(
                tone: .criticalDamage,
                fontSize: 11,
                horizontalPadding: 5,
                verticalPadding: 2,
                backgroundOpacity: 0.58,
                borderOpacity: 0.92,
                shadowRadius: 6,
                verticalOffset: -2,
                isHeavy: true
            )
        case .damage:
            let hasElementBorder = entry.damageElement != .none && entry.damageElement != .physical
            return BattleFloatingDamageStyle(
                tone: .damage,
                fontSize: 8,
                horizontalPadding: 4,
                verticalPadding: 1,
                backgroundOpacity: 0.48,
                borderOpacity: hasElementBorder ? 0.65 : 0,
                shadowRadius: 2,
                verticalOffset: 0,
                isHeavy: true
            )
        case .heal:
            return utilityStyle(tone: .heal, fontSize: 8, borderOpacity: 0.55, verticalOffset: -1)
        case .buff:
            return utilityStyle(tone: .buff, fontSize: 8, borderOpacity: 0.55, verticalOffset: -1)
        case .dodge:
            return utilityStyle(tone: .dodge, fontSize: 9, borderOpacity: 0.68, verticalOffset: -2)
        case .block:
            return utilityStyle(tone: .block, fontSize: 9, borderOpacity: 0.68, verticalOffset: -2)
        }
    }

    private static func utilityStyle(
        tone: BattleFloatingDamageTone,
        fontSize: CGFloat,
        borderOpacity: Double,
        verticalOffset: CGFloat
    ) -> BattleFloatingDamageStyle {
        BattleFloatingDamageStyle(
            tone: tone,
            fontSize: fontSize,
            horizontalPadding: 5,
            verticalPadding: 2,
            backgroundOpacity: 0.54,
            borderOpacity: borderOpacity,
            shadowRadius: 3,
            verticalOffset: verticalOffset,
            isHeavy: false
        )
    }
}

enum BattleFloatingDamageText {
    static let criticalPrefix = "暴击"
    static let dodgeText = "闪避!"
    static let blockText = "格挡!"
    static let healFallbackText = "治疗"
    static let buffFallbackText = "增益"

    static func displayText(for entry: BattleLogEntry) -> String {
        switch entry.kind {
        case .damage:
            let damageText = entry.isCrit ? "\(criticalPrefix) \(entry.damage)" : "\(entry.damage)"
            if let skillName = entry.skillName {
                return "\(skillName) \(damageText)"
            }
            return damageText
        case .heal:
            return "\(entry.skillName ?? healFallbackText) +\(entry.damage)"
        case .buff:
            return entry.skillName ?? buffFallbackText
        case .dodge:
            return dodgeText
        case .block:
            return blockText
        }
    }
}

enum BattleLogActionText {
    static let damageVerb = "造成"
    static let damageSuffix = "伤害"
    static let healVerb = "恢复"
    static let healSuffix = "生命"
    static let buffText = "触发增益"
    static let incomingDodgeText = "攻击被闪避"
    static let incomingBlockText = "攻击被格挡"
    static let dodgeText = "闪避了攻击"
    static let blockText = "格挡了攻击"
    static let criticalLabel = "暴击!"

    static func displayText(for entry: BattleLogEntry) -> String {
        switch entry.kind {
        case .damage:
            return "\(damageVerb) \(entry.damage) \(damageSuffix)"
        case .heal:
            return "\(healVerb) \(entry.damage) \(healSuffix)"
        case .buff:
            return buffText
        case .dodge:
            return entry.attacker == .monster ? incomingDodgeText : dodgeText
        case .block:
            return entry.attacker == .monster ? incomingBlockText : blockText
        }
    }

    static func criticalText(for entry: BattleLogEntry) -> String? {
        entry.isCrit ? criticalLabel : nil
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
            Image(systemName: entry.attacker.iconName)
                .font(.system(size: 8))
                .foregroundColor(entry.attacker.tint)
            Text(entry.attackerDisplayName)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(entry.attacker.tint)
            if entry.kind == .damage, let elementLabel = entry.damageElement.battleLogLabel {
                BattleLogElementMarker(label: elementLabel, color: entry.damageElement.battleColor)
            }
            if let skillName = entry.skillName {
                HStack(spacing: 3) {
                    Text(skillName)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(entry.damageElement.battleColor)
                        .lineLimit(1)
                }
            }
            Text(BattleLogActionText.displayText(for: entry))
                .font(.system(size: 9, design: .monospaced))
                .lineLimit(1)
            if let criticalText = BattleLogActionText.criticalText(for: entry) {
                Text(criticalText)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.orange)
            }
        }
    }
}

private struct BattleLogElementMarker: View {
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 4, height: 4)
            Text(label)
                .font(.system(size: 8, weight: .semibold, design: .rounded))
                .foregroundColor(color)
                .lineLimit(1)
        }
        .accessibilityLabel("伤害类型\(label)")
    }
}

struct BattleLogPanel: View {
    let entries: [BattleLogEntry]
    let heroFocusEntries: [BattleLogEntry]
    let totalCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: "list.bullet.rectangle.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                Text("战斗日志")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                Spacer()
                Text("\(totalCount)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Divider()

            if entries.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.system(size: 10, weight: .semibold))
                    Text("暂无战斗日志")
                        .font(.system(size: 9, weight: .medium))
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                if !heroFocusEntries.isEmpty {
                    BattleHeroLogFocus(entries: heroFocusEntries)

                    Divider()
                        .opacity(0.55)
                }

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: BattleLogMetrics.rowSpacing) {
                            ForEach(entries) { entry in
                                BattleLogRow(entry: entry)
                                    .id(entry.id)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 1)
                    }
                    .onAppear {
                        scrollToLatestEntry(with: proxy, animated: false)
                    }
                    .onChange(of: entries.last?.id) { _ in
                        scrollToLatestEntry(with: proxy, animated: true)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(height: BattleLogMetrics.panelHeight)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.primary.opacity(0.10), lineWidth: 0.6)
        )
    }

    private func scrollToLatestEntry(with proxy: ScrollViewProxy, animated: Bool) {
        guard let targetEntryID = BattleLogDisplayEntries.scrollTargetID(in: entries) else { return }
        DispatchQueue.main.async {
            if animated {
                withAnimation(.easeOut(duration: 0.18)) {
                    proxy.scrollTo(targetEntryID, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(targetEntryID, anchor: .bottom)
            }
        }
    }
}

private struct BattleHeroLogFocus: View {
    let entries: [BattleLogEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.blue)
                Text("英雄行动")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary.opacity(0.82))
                Spacer(minLength: 6)
                Text("\(entries.count)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: BattleLogMetrics.rowSpacing) {
                ForEach(entries) { entry in
                    BattleLogRow(entry: entry)
                }
            }
        }
    }
}

private extension BattleLogEntry.Battler {
    var isSupport: Bool {
        if case .support = self { return true }
        return false
    }

    var iconName: String {
        switch self {
        case .hero:
            return "arrow.right"
        case .support:
            return "sparkles"
        case .monster:
            return "arrow.left"
        }
    }

    var tint: Color {
        switch self {
        case .hero:
            return .blue
        case .support:
            return .purple
        case .monster:
            return .red
        }
    }
}

private extension SkillDamageElement {
    var battleColor: Color {
        switch self {
        case .none, .physical:
            return .white
        case .fire:
            return Color(red: 1.0, green: 0.45, blue: 0.14)
        case .cold:
            return Color(red: 0.42, green: 0.88, blue: 1.0)
        case .lightning:
            return Color(red: 1.0, green: 0.92, blue: 0.20)
        case .chaos:
            return Color(red: 0.72, green: 0.42, blue: 1.0)
        }
    }
}

struct BattleResultBanner: View {
    let result: BattleResult?
    let displayedVictoryRewards: BattleResult.Rewards?
    let levelCapStatus: HeroLevelCapStatus

    var body: some View {
        Group {
            switch result {
            case .victory(let rewards):
                let displayedRewards = displayedVictoryRewards ?? rewards
                let presentation = BattleVictoryRewardPresentation(
                    sourceRewards: rewards,
                    displayedRewards: displayedRewards,
                    levelCapStatus: levelCapStatus
                )
                VStack(spacing: 2) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(presentation.summaryText)
                            .font(.system(size: 11, weight: .medium))
                        if let loot = BattleRewardLootPresentation.make(from: displayedRewards) {
                            HStack(spacing: 3) {
                                PixelSprite(
                                    imageName: loot.iconName,
                                    size: CGSize(width: 18, height: 18)
                                )
                                Text(loot.displayText)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color(hex: loot.rarityColor))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                            .accessibilityLabel("掉落 \(loot.accessibilityText)")
                        }
                    }

                    if let rewardDetailText = presentation.rewardDetailText {
                        Text(rewardDetailText)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(presentation.rewardDetailIsWarning ? .orange : .secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
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

struct BattleVictoryRewardPresentation {
    static let levelCapXPStopMessage = "已达等级上限 · 升级停止"
    static let encounterClearLabel = "清理"
    static let adjustedXPLabel = "XP实得"
    static let adjustedGoldLabel = "金币实得"

    let sourceRewards: BattleResult.Rewards
    let displayedRewards: BattleResult.Rewards
    let levelCapStatus: HeroLevelCapStatus

    var summaryText: String {
        "胜利! +\(displayedRewards.xp)XP +\(displayedRewards.gold)G"
    }

    var rewardDetailText: String? {
        let detailParts = [
            encounterClearText,
            levelCapXPStopText ?? xpAdjustmentText,
            goldAdjustmentText
        ].compactMap { $0 }
        guard !detailParts.isEmpty else { return nil }
        return detailParts.joined(separator: " · ")
    }

    var rewardDetailIsWarning: Bool {
        levelCapXPStopText != nil
    }

    var encounterClearText: String? {
        guard displayedRewards.encountersCleared > 1 else {
            return nil
        }
        return "\(Self.encounterClearLabel) x\(displayedRewards.encountersCleared)"
    }

    var xpDetailText: String? {
        rewardDetailText
    }

    var xpDetailIsWarning: Bool {
        rewardDetailIsWarning
    }

    var levelCapXPStopText: String? {
        guard sourceRewards.xp > 0,
              displayedRewards.xp == 0,
              levelCapStatus.isAtLevelCap
        else {
            return nil
        }
        return Self.levelCapXPStopMessage
    }

    var xpAdjustmentText: String? {
        guard sourceRewards.xp > 0,
              displayedRewards.xp > 0,
              displayedRewards.xp != sourceRewards.xp
        else {
            return nil
        }
        return "\(Self.adjustedXPLabel) \(sourceRewards.xp)->\(displayedRewards.xp)"
    }

    var goldAdjustmentText: String? {
        guard sourceRewards.gold > 0,
              displayedRewards.gold > 0,
              displayedRewards.gold != sourceRewards.gold
        else {
            return nil
        }
        return "\(Self.adjustedGoldLabel) \(sourceRewards.gold)->\(displayedRewards.gold)"
    }
}

struct BattleRewardLootPresentation: Equatable {
    let displayText: String
    let accessibilityText: String
    let iconName: String
    let rarityColor: String

    static func make(from rewards: BattleResult.Rewards) -> BattleRewardLootPresentation? {
        guard let item = rewards.lootItem else { return nil }
        let extraCount = max(0, rewards.lootItems.count - 1)
        let displayText = extraCount == 0 ? item.name : "\(item.name) +\(extraCount)"
        return BattleRewardLootPresentation(
            displayText: displayText,
            accessibilityText: displayText,
            iconName: GameArt.itemIconName(for: item),
            rarityColor: item.rarity.color
        )
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
