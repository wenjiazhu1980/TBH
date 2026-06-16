import AppKit
import SwiftUI

enum BattleSceneSnapshot {
    enum Fixture: String {
        case frostBolt
        case explosiveBolt
        case meteorStrike
        case lightningStrike
        case trapBurst
        case summonProjectile
        case shockCurrent
        case shieldCharge
        case slamJump
        case earthquakeImpact
        case earthquakeRockExplosion
        case shockwaveImpact
        case chaosBurst
        case monsterFireIncoming
        case monsterColdIncoming
        case monsterLightningIncoming
        case monsterChaosIncoming
        case healUtility
        case resurrectionUtility
        case shieldUtility
        case sacredBladeUtility
        case swiftSurgeUtility
        case quickLoaderUtility
        case generalsCryUtility
        case bloodlustUtility
        case playerStatusRow
        case playerStatusRowCrowded
    }

    private enum SnapshotError: LocalizedError {
        case missingOutputPath
        case cannotCreateBitmap
        case cannotCreatePNGData

        var errorDescription: String? {
            switch self {
            case .missingOutputPath:
                return "missing output path after --render-battle-scene"
            case .cannotCreateBitmap:
                return "could not create battle scene bitmap"
            case .cannotCreatePNGData:
                return "could not encode battle scene PNG"
            }
        }
    }

    static func outputURL(arguments: [String]) -> URL? {
        if let index = arguments.firstIndex(of: "--render-battle-scene") {
            let pathIndex = arguments.index(after: index)
            guard arguments.indices.contains(pathIndex) else { return nil }
            return URL(fileURLWithPath: arguments[pathIndex])
        }

        let prefix = "--render-battle-scene="
        guard let argument = arguments.first(where: { $0.hasPrefix(prefix) }) else { return nil }
        return URL(fileURLWithPath: String(argument.dropFirst(prefix.count)))
    }

    static func fixedBackdropTime(arguments: [String]) -> TimeInterval? {
        if let index = arguments.firstIndex(of: "--render-battle-scene-time") {
            let valueIndex = arguments.index(after: index)
            guard arguments.indices.contains(valueIndex) else { return nil }
            return TimeInterval(arguments[valueIndex])
        }

        let prefix = "--render-battle-scene-time="
        guard let argument = arguments.first(where: { $0.hasPrefix(prefix) }) else { return nil }
        return TimeInterval(String(argument.dropFirst(prefix.count)))
    }

    static func fixture(arguments: [String]) -> Fixture {
        if let index = arguments.firstIndex(of: "--render-battle-scene-fixture") {
            let valueIndex = arguments.index(after: index)
            guard arguments.indices.contains(valueIndex) else { return .frostBolt }
            return Fixture(rawValue: arguments[valueIndex]) ?? .frostBolt
        }

        let prefix = "--render-battle-scene-fixture="
        guard let argument = arguments.first(where: { $0.hasPrefix(prefix) }) else {
            return .frostBolt
        }
        return Fixture(rawValue: String(argument.dropFirst(prefix.count))) ?? .frostBolt
    }

    static func heroClass(arguments: [String]) -> HeroClass {
        if let index = arguments.firstIndex(of: "--render-battle-scene-hero-class") {
            let valueIndex = arguments.index(after: index)
            guard arguments.indices.contains(valueIndex) else { return .knight }
            return heroClass(from: arguments[valueIndex])
        }

        let prefix = "--render-battle-scene-hero-class="
        guard let argument = arguments.first(where: { $0.hasPrefix(prefix) }) else {
            return .knight
        }
        return heroClass(from: String(argument.dropFirst(prefix.count)))
    }

    private static func heroClass(from value: String) -> HeroClass {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return HeroClass.allCases.first { heroClass in
            normalized == heroClass.rawValue.lowercased() ||
                normalized == String(describing: heroClass).lowercased()
        } ?? .knight
    }

    static func run(arguments: [String]) -> Never {
        do {
            guard let outputURL = outputURL(arguments: arguments) else {
                throw SnapshotError.missingOutputPath
            }
            try render(
                to: outputURL,
                fixedBackdropTime: fixedBackdropTime(arguments: arguments),
                fixture: fixture(arguments: arguments),
                heroClass: heroClass(arguments: arguments)
            )
            print("battle_scene_snapshot=\(outputURL.path)")
            exit(0)
        } catch {
            fputs("Battle scene snapshot failed: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }

    static func render(
        to outputURL: URL,
        fixedBackdropTime: TimeInterval? = nil,
        fixture: Fixture = .frostBolt,
        heroClass: HeroClass = .knight
    ) throws {
        let size = snapshotSize(for: fixture)
        let view = BattleSceneSnapshotRootView(
            fixedBackdropTime: fixedBackdropTime,
            fixture: fixture,
            heroClass: heroClass
        )
            .frame(width: size.width, height: size.height)
            .environment(\.colorScheme, .dark)

        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(origin: .zero, size: size)
        hostingView.setFrameSize(size)
        hostingView.layoutSubtreeIfNeeded()

        let outputScale: CGFloat = 2.0
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width * outputScale),
            pixelsHigh: Int(size.height * outputScale),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bitmapFormat: [],
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            throw SnapshotError.cannotCreateBitmap
        }
        bitmap.size = size
        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmap)

        guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw SnapshotError.cannotCreatePNGData
        }

        let directory = outputURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try pngData.write(to: outputURL, options: .atomic)
    }

    private static func snapshotSize(for fixture: Fixture) -> CGSize {
        switch fixture {
        case .playerStatusRow, .playerStatusRowCrowded:
            return CGSize(width: BattleSceneMetrics.expectedPopoverContentWidth, height: 28)
        default:
            return CGSize(
                width: BattleSceneMetrics.expectedPopoverContentWidth,
                height: BattleSceneMetrics.compactHeight
            )
        }
    }
}

private struct BattleSceneSnapshotRootView: View {
    let fixedBackdropTime: TimeInterval?
    let fixture: BattleSceneSnapshot.Fixture
    let heroClass: HeroClass

    var body: some View {
        switch fixture {
        case .playerStatusRow:
            BattleStatusRowSnapshotView(crowded: false)
        case .playerStatusRowCrowded:
            BattleStatusRowSnapshotView(crowded: true)
        default:
            BattleSceneSnapshotView(
                fixedBackdropTime: fixedBackdropTime,
                fixture: fixture,
                heroClass: heroClass
            )
        }
    }
}

private struct BattleSceneSnapshotView: View {
    @StateObject private var battle: Battle
    private let progress = BattleSceneSnapshotFixture.makeProgress()
    let fixedBackdropTime: TimeInterval?

    init(fixedBackdropTime: TimeInterval?, fixture: BattleSceneSnapshot.Fixture, heroClass: HeroClass) {
        _battle = StateObject(wrappedValue: BattleSceneSnapshotFixture.makeBattle(
            heroClass: heroClass,
            fixture: fixture
        ))
        self.fixedBackdropTime = fixedBackdropTime
    }

    var body: some View {
        BattleSceneView(battle: battle, progress: progress, fixedBackdropTime: fixedBackdropTime)
    }
}

private struct BattleStatusRowSnapshotView: View {
    @StateObject private var battle: Battle

    init(crowded: Bool) {
        _battle = StateObject(wrappedValue: BattleSceneSnapshotFixture.makeStatusRowBattle(crowded: crowded))
    }

    var body: some View {
        BattleOngoingStatusView(battle: battle)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color(red: 0.035, green: 0.045, blue: 0.052))
    }
}

private enum BattleSceneSnapshotFixture {
    static func makeProgress() -> ProgressTracker {
        ProgressTracker()
    }

    static func makeBattle(
        heroClass: HeroClass = .knight,
        fixture: BattleSceneSnapshot.Fixture = .frostBolt
    ) -> Battle {
        let hero = Hero()
        hero.changeClass(to: heroClass)
        let party = HeroParty(primaryClass: heroClass, unlockedSlotCount: 3)

        let stage = ProgressTracker().currentStage
        let monsters = (0..<3).map {
            stage.spawnMonster(difficulty: .normal, encounterIndex: $0)
        }

        let battle = Battle(
            hero: hero,
            monsters: monsters,
            party: party,
            activeSkillSlotCount: 2
        )

        battle.activateBattleSceneSnapshotDeployables()

        switch fixture {
        case .playerStatusRow, .playerStatusRowCrowded:
            break
        case .frostBolt:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "寒霜弩箭",
                    kind: .damage
                )
            )
        case .explosiveBolt:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "爆炸弩箭",
                    kind: .damage
                )
            )
        case .meteorStrike:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "陨石打击",
                    kind: .damage
                )
            )
        case .lightningStrike:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "闪电术",
                    kind: .damage
                )
            )
        case .trapBurst:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "充能陷阱爆炸",
                    kind: .damage
                )
            )
        case .summonProjectile:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "弩炮塔",
                    kind: .damage
                )
            )
        case .shockCurrent:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "电击弩箭电流",
                    kind: .damage
                )
            )
        case .shieldCharge:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "盾牌冲锋",
                    kind: .damage
                )
            )
        case .slamJump:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "猛击跳跃",
                    kind: .damage
                )
            )
        case .earthquakeImpact:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "大地强击",
                    kind: .damage
                )
            )
        case .earthquakeRockExplosion:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "大地强击岩石爆炸",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .meleeAOE
                )
            )
        case .shockwaveImpact:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "粉碎强击冲击波",
                    kind: .damage
                )
            )
        case .chaosBurst:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    kind: .damage,
                    damageElement: .chaos,
                    delivery: .range
                )
            )
        case .monsterFireIncoming:
            battle.log.append(
                BattleLogEntry(
                    attacker: .monster,
                    damage: 777,
                    isCrit: false,
                    kind: .damage,
                    damageElement: .fire
                )
            )
        case .monsterColdIncoming:
            battle.log.append(
                BattleLogEntry(
                    attacker: .monster,
                    damage: 777,
                    isCrit: false,
                    kind: .damage,
                    damageElement: .cold
                )
            )
        case .monsterLightningIncoming:
            battle.log.append(
                BattleLogEntry(
                    attacker: .monster,
                    damage: 777,
                    isCrit: false,
                    kind: .damage,
                    damageElement: .lightning
                )
            )
        case .monsterChaosIncoming:
            battle.log.append(
                BattleLogEntry(
                    attacker: .monster,
                    damage: 777,
                    isCrit: false,
                    kind: .damage,
                    damageElement: .chaos
                )
            )
        case .healUtility:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 100,
                    isCrit: false,
                    skillName: "治愈",
                    kind: .heal
                )
            )
        case .resurrectionUtility:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 300,
                    isCrit: false,
                    skillName: "复活",
                    kind: .heal
                )
            )
        case .shieldUtility:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 0,
                    isCrit: false,
                    skillName: "神盾领域",
                    kind: .buff
                )
            )
        case .sacredBladeUtility:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 0,
                    isCrit: false,
                    skillName: "神圣之刃",
                    kind: .buff
                )
            )
        case .swiftSurgeUtility:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 0,
                    isCrit: false,
                    skillName: "迅捷觉醒",
                    kind: .buff
                )
            )
        case .quickLoaderUtility:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 0,
                    isCrit: false,
                    skillName: "快速装填",
                    kind: .buff
                )
            )
        case .generalsCryUtility:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 0,
                    isCrit: false,
                    skillName: "将军怒吼",
                    kind: .buff
                )
            )
        case .bloodlustUtility:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 0,
                    isCrit: false,
                    skillName: "嗜血",
                    kind: .buff
                )
            )
        }

        return battle
    }

    static func makeStatusRowBattle(crowded: Bool = false) -> Battle {
        let hero = Hero()
        hero.changeClass(to: .priest)

        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["40201", "40501"], for: .priest)

        let battle = Battle(
            hero: hero,
            monster: Monster(
                id: "status-row-training",
                name: "Status Row Training Dummy",
                hp: 9_999,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "status-row"
            ),
            party: HeroParty(primaryClass: .priest),
            activeSkillSlotCount: 2,
            activeSkillLoadouts: loadouts
        )

        if crowded {
            battle.activateCrowdedBattleStatusSnapshotBuffs()
        } else {
            battle.activateBattleStatusSnapshotBuffs()
        }

        return battle
    }
}
