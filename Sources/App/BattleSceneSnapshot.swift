import AppKit
import SwiftUI

enum BattleSceneSnapshot {
    enum Fixture: String, CaseIterable {
        case frostBolt
        case meleeArc
        case rapidVolley
        case scatterShot
        case arrowRain
        case piercingArrow
        case skewerShot
        case explosiveBolt
        case meteorStrike
        case lightningStrike
        case shockBolt
        case trapBurst
        case summonProjectile
        case shockCurrent
        case shieldCharge
        case slamJump
        case earthquakeImpact
        case earthquakeRockExplosion
        case axeSpin
        case axeSpinBleedFollowUp
        case shockwaveImpact
        case chaosBurst
        case monsterFireIncoming
        case monsterColdIncoming
        case monsterLightningIncoming
        case monsterChaosIncoming
        case enemyStatusEffects
        case contactPulseBaseline
        case heroContactPulse
        case monsterContactPulse
        case healUtility
        case sanctuaryUtility
        case resurrectionUtility
        case shieldUtility
        case wrathOfHeavenUtility
        case sacredBladeUtility
        case swiftSurgeUtility
        case quickLoaderUtility
        case generalsCryUtility
        case bloodlustUtility
        case criticalFloating
        case dodgeFloating
        case blockFloating
        case victoryFinishScene
        case defeatFinishScene
        case playerStatusRow
        case playerStatusRowCrowded
        case battleLogPanel
        case victoryRewardBanner
        case victoryLevelCapBanner
        case completionSettlement
        case battleTabLayout
        case inventoryPanel
        case characterPanel
        case chestPanel
        case originalFidelityPanel
        case runeEvidencePanel
        case skillEvidencePanel
        case passiveEvidencePanel
    }

    private enum SnapshotError: LocalizedError {
        case missingOutputPath
        case missingFixtureValue
        case invalidFixture(String)
        case missingBackdropTimeValue
        case invalidBackdropTime(String)
        case missingHeroClassValue
        case invalidHeroClass(String)
        case cannotCreateBitmap
        case cannotCreatePNGData

        var errorDescription: String? {
            switch self {
            case .missingOutputPath:
                return "missing output path after --render-battle-scene"
            case .missingFixtureValue:
                return "missing fixture name after --render-battle-scene-fixture"
            case .invalidFixture(let fixture):
                return "unknown battle scene fixture '\(fixture)'; valid fixtures: \(BattleSceneSnapshot.validFixtureList)"
            case .missingBackdropTimeValue:
                return "missing time value after --render-battle-scene-time"
            case .invalidBackdropTime(let value):
                return "invalid battle scene time '\(value)'; expected a finite non-negative second value"
            case .missingHeroClassValue:
                return "missing hero class after --render-battle-scene-hero-class"
            case .invalidHeroClass(let heroClass):
                return "unknown battle scene hero class '\(heroClass)'; valid hero classes: \(BattleSceneSnapshot.validHeroClassList)"
            case .cannotCreateBitmap:
                return "could not create battle scene bitmap"
            case .cannotCreatePNGData:
                return "could not encode battle scene PNG"
            }
        }
    }

    private static var validFixtureList: String {
        Fixture.allCases.map(\.rawValue).joined(separator: ", ")
    }

    private static var validHeroClassList: String {
        HeroClass.allCases
            .map { "\(String(describing: $0))(\($0.rawValue))" }
            .joined(separator: ", ")
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

    static func fixedBackdropTime(arguments: [String]) throws -> TimeInterval? {
        if let index = arguments.firstIndex(of: "--render-battle-scene-time") {
            let valueIndex = arguments.index(after: index)
            guard arguments.indices.contains(valueIndex) else { throw SnapshotError.missingBackdropTimeValue }
            return try backdropTime(from: arguments[valueIndex])
        }

        let prefix = "--render-battle-scene-time="
        guard let argument = arguments.first(where: { $0.hasPrefix(prefix) }) else { return nil }
        return try backdropTime(from: String(argument.dropFirst(prefix.count)))
    }

    private static func backdropTime(from value: String) throws -> TimeInterval {
        guard let parsed = TimeInterval(value), parsed.isFinite, parsed >= 0 else {
            throw SnapshotError.invalidBackdropTime(value)
        }
        return parsed
    }

    static func fixture(arguments: [String]) throws -> Fixture {
        if let index = arguments.firstIndex(of: "--render-battle-scene-fixture") {
            let valueIndex = arguments.index(after: index)
            guard arguments.indices.contains(valueIndex) else { throw SnapshotError.missingFixtureValue }
            guard let fixture = Fixture(rawValue: arguments[valueIndex]) else {
                throw SnapshotError.invalidFixture(arguments[valueIndex])
            }
            return fixture
        }

        let prefix = "--render-battle-scene-fixture="
        guard let argument = arguments.first(where: { $0.hasPrefix(prefix) }) else {
            return .frostBolt
        }
        let fixtureName = String(argument.dropFirst(prefix.count))
        guard let fixture = Fixture(rawValue: fixtureName) else {
            throw SnapshotError.invalidFixture(fixtureName)
        }
        return fixture
    }

    static func heroClass(arguments: [String]) throws -> HeroClass {
        if let index = arguments.firstIndex(of: "--render-battle-scene-hero-class") {
            let valueIndex = arguments.index(after: index)
            guard arguments.indices.contains(valueIndex) else { throw SnapshotError.missingHeroClassValue }
            guard let heroClass = heroClass(from: arguments[valueIndex]) else {
                throw SnapshotError.invalidHeroClass(arguments[valueIndex])
            }
            return heroClass
        }

        let prefix = "--render-battle-scene-hero-class="
        guard let argument = arguments.first(where: { $0.hasPrefix(prefix) }) else {
            return .knight
        }
        let heroClassName = String(argument.dropFirst(prefix.count))
        guard let heroClass = heroClass(from: heroClassName) else {
            throw SnapshotError.invalidHeroClass(heroClassName)
        }
        return heroClass
    }

    private static func heroClass(from value: String) -> HeroClass? {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return nil }
        return HeroClass.allCases.first { heroClass in
            normalized == heroClass.rawValue.lowercased() ||
                normalized == String(describing: heroClass).lowercased()
        }
    }

    static func run(arguments: [String]) -> Never {
        do {
            guard let outputURL = outputURL(arguments: arguments) else {
                throw SnapshotError.missingOutputPath
            }
            try render(
                to: outputURL,
                fixedBackdropTime: try fixedBackdropTime(arguments: arguments),
                fixture: try fixture(arguments: arguments),
                heroClass: try heroClass(arguments: arguments)
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
        case .battleLogPanel:
            return CGSize(
                width: BattleSceneMetrics.expectedPopoverContentWidth,
                height: BattleLogMetrics.panelHeight
            )
        case .victoryRewardBanner, .victoryLevelCapBanner:
            return CGSize(width: BattleSceneMetrics.expectedPopoverContentWidth, height: 72)
        case .completionSettlement:
            return CGSize(width: BattleSceneMetrics.expectedPopoverContentWidth, height: 320)
        case .battleTabLayout:
            return MenuBarPopoverLayout.defaultSize
        case .inventoryPanel:
            return CGSize(width: BattleSceneMetrics.expectedPopoverContentWidth, height: 720)
        case .characterPanel:
            return CGSize(width: BattleSceneMetrics.expectedPopoverContentWidth, height: MenuBarPopoverLayout.contentMinHeight)
        case .chestPanel:
            return CGSize(width: BattleSceneMetrics.expectedPopoverContentWidth, height: 360)
        case .originalFidelityPanel:
            return CGSize(width: BattleSceneMetrics.expectedPopoverContentWidth, height: 600)
        case .runeEvidencePanel:
            return CGSize(width: BattleSceneMetrics.expectedPopoverContentWidth, height: 620)
        case .skillEvidencePanel:
            return CGSize(width: BattleSceneMetrics.expectedPopoverContentWidth, height: 720)
        case .passiveEvidencePanel:
            return CGSize(width: BattleSceneMetrics.expectedPopoverContentWidth, height: 720)
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
        case .battleLogPanel:
            BattleLogPanelSnapshotView()
        case .victoryRewardBanner:
            BattleVictoryRewardBannerSnapshotView(levelCap: false)
        case .victoryLevelCapBanner:
            BattleVictoryRewardBannerSnapshotView(levelCap: true)
        case .completionSettlement:
            CompletionSettlementSnapshotView()
        case .battleTabLayout:
            BattleTabLayoutSnapshotView(fixedBackdropTime: fixedBackdropTime)
        case .inventoryPanel:
            InventoryPanelSnapshotView()
        case .characterPanel:
            CharacterPanelSnapshotView()
        case .chestPanel:
            ChestPanelSnapshotView()
        case .originalFidelityPanel:
            OriginalFidelityPanelSnapshotView()
        case .runeEvidencePanel:
            RuneEvidencePanelSnapshotView()
        case .skillEvidencePanel:
            SkillEvidencePanelSnapshotView()
        case .passiveEvidencePanel:
            PassiveEvidencePanelSnapshotView()
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

private struct BattleLogPanelSnapshotView: View {
    private let presentation = BattleLogPresentation(
        from: BattleSceneSnapshotFixture.makeBattleLogPanelEntries()
    )

    var body: some View {
        BattleLogPanel(
            entries: presentation.visibleEntries,
            heroFocusEntries: presentation.heroFocusEntries,
            totalCount: presentation.totalCount
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(red: 0.035, green: 0.045, blue: 0.052))
    }
}

private struct BattleVictoryRewardBannerSnapshotView: View {
    private let result: BattleResult
    private let displayedRewards: BattleResult.Rewards
    private let levelCapStatus: HeroLevelCapStatus

    init(levelCap: Bool) {
        let progress = ProgressTracker()
        let hero = Hero()
        let loot = Item(
            id: "snapshot-victory-scepter",
            name: "源力权杖",
            rarity: .rare,
            slot: .weapon,
            stats: ItemStats(bonusATK: 12),
            description: "checked source progression fixture",
            itemLevel: 12,
            equipmentType: .scepter
        )
        let extraLoot = Item(
            id: "snapshot-victory-ring",
            name: "源力戒指",
            rarity: .uncommon,
            slot: .ring,
            stats: ItemStats(bonusHP: 8),
            description: "checked source progression fixture",
            itemLevel: 8,
            equipmentType: .ring
        )

        if levelCap {
            hero.level = HeroLevelPacing.maxHeroLevel(for: progress)
            hero.currentXP = hero.xpForNextLevel() - 1
            result = .victory(BattleResult.Rewards(xp: 100, gold: 12, lootItem: nil))
            displayedRewards = BattleResult.Rewards(xp: 0, gold: 12, lootItem: nil)
        } else {
            result = .victory(BattleResult.Rewards(
                xp: 100,
                gold: 100,
                lootItems: [loot, extraLoot],
                encountersCleared: 3
            ))
            displayedRewards = BattleResult.Rewards(
                xp: 35,
                gold: 120,
                lootItems: [loot, extraLoot],
                encountersCleared: 3
            )
        }
        levelCapStatus = HeroLevelPacing.levelCapStatus(for: hero, progress: progress)
    }

    var body: some View {
        BattleResultBanner(
            result: result,
            displayedVictoryRewards: displayedRewards,
            levelCapStatus: levelCapStatus
        )
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color(red: 0.035, green: 0.045, blue: 0.052))
    }
}

private struct CompletionSettlementSnapshotView: View {
    private let progress: ProgressTracker
    private let statistics: GameStatistics

    init() {
        var progress = ProgressTracker()
        progress.currentDifficultyIndex = max(Difficulty.allCases.count - 1, 0)
        progress.currentChapterIndex = max(Chapter.allCases.count - 1, 0)
        progress.currentStageIndex = max(ProgressTracker.stagesPerAct - 1, 0)
        progress.isAwaitingNewGamePlus = true
        progress.completedPlaythroughs = progress.playthrough
        self.progress = progress

        var statistics = GameStatistics()
        statistics.monstersKilled = 12_345
        statistics.totalGoldEarned = 678_900
        statistics.deaths = 7
        self.statistics = statistics
    }

    var body: some View {
        CompletionSettlementView(
            progress: progress,
            statistics: statistics,
            onDeferNewGamePlus: {},
            onStartNextPlaythrough: {}
        )
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color(red: 0.035, green: 0.045, blue: 0.052))
    }
}

private struct BattleTabLayoutSnapshotView: View {
    @StateObject private var battle: Battle
    private let progress = BattleSceneSnapshotFixture.makeProgress()
    private let fixedBackdropTime: TimeInterval?
    private let logPresentation = BattleLogPresentation(
        from: BattleSceneSnapshotFixture.makeBattleLogPanelEntries()
    )

    init(fixedBackdropTime: TimeInterval?) {
        let battle = BattleSceneSnapshotFixture.makeBattle(fixture: .frostBolt)
        _battle = StateObject(wrappedValue: battle)
        self.fixedBackdropTime = fixedBackdropTime
    }

    var body: some View {
        VStack(spacing: 0) {
            HeroSummaryBar(hero: battle.hero)

            Divider()

            VStack(spacing: BattlePanelMetrics.sectionSpacing) {
                BattleSceneView(
                    battle: battle,
                    progress: progress,
                    fixedBackdropTime: fixedBackdropTime,
                    latestLogEntry: battle.log.last,
                    logTrigger: battle.log.last?.id
                )
                .frame(maxWidth: .infinity)
                .frame(height: BattleSceneMetrics.compactHeight)
                .overlay(alignment: .top) {
                    StageHeaderView(
                        progress: progress,
                        battle: battle,
                        clearTargetReduction: 0
                    )
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                }
                .overlay(alignment: .bottom) {
                    BattleOngoingStatusView(battle: battle)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                }
                .layoutPriority(2)

                BattleLogPanel(
                    entries: logPresentation.visibleEntries,
                    heroFocusEntries: logPresentation.heroFocusEntries,
                    totalCount: logPresentation.totalCount
                )
                .layoutPriority(1)
            }
            .padding(.horizontal, BattlePanelMetrics.horizontalPadding)
            .padding(.vertical, BattlePanelMetrics.verticalPadding)
            .frame(minHeight: MenuBarPopoverLayout.contentMinHeight, maxHeight: .infinity, alignment: .top)

            Divider()

            HStack(spacing: 0) {
                ForEach(MenuBarPopover.Tab.allCases, id: \.self) { tab in
                    TabBarButton(
                        tab: tab,
                        isSelected: tab == .battle,
                        action: {}
                    )
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
            .frame(height: MenuBarPopoverLayout.bottomTabHeight)
        }
        .frame(width: MenuBarPopoverLayout.defaultSize.width, height: MenuBarPopoverLayout.defaultSize.height)
    }
}

private struct InventoryPanelSnapshotView: View {
    @StateObject private var inventory: Inventory
    @StateObject private var hero: Hero
    private let cubeProgress: CubeProgress
    private let selectedItem: Item

    init() {
        let hero = Hero()
        hero.level = 12
        hero.gold = 250_000

        let equippedSword = Self.makeGear(
            id: "snapshot-equipped-sword",
            type: .sword,
            level: 5,
            rarity: .common,
            stats: ItemStats(bonusATK: 3, bonusDEF: 1)
        )
        _ = hero.equipment.equip(equippedSword)

        let selectedItem = Self.makeGear(
            id: "snapshot-inventory-selected",
            type: .sword,
            level: 10,
            rarity: .common,
            stats: ItemStats(bonusATK: 12, bonusDEF: 3, bonusSPD: 1, bonusCritRate: 0.02)
        )

        let inventory = Inventory()
        inventory.setMaxCapacity(Inventory.baseCapacity + InventoryExpansion.slotBonus * 3)
        let synthesisInputs = [
            selectedItem,
            Self.makeGear(id: "snapshot-synthesis-bow", type: .bow, level: 10, rarity: .common, stats: ItemStats(bonusATK: 8)),
            Self.makeGear(id: "snapshot-synthesis-staff", type: .staff, level: 10, rarity: .common, stats: ItemStats(bonusHP: 4, bonusATK: 7)),
            Self.makeGear(id: "snapshot-synthesis-shield", type: .shield, level: 10, rarity: .common, stats: ItemStats(bonusDEF: 10)),
            Self.makeGear(id: "snapshot-synthesis-helmet", type: .helmet, level: 10, rarity: .common, stats: ItemStats(bonusHP: 16, bonusDEF: 5)),
            Self.makeGear(id: "snapshot-synthesis-armor", type: .armor, level: 10, rarity: .common, stats: ItemStats(bonusHP: 18, bonusDEF: 8)),
            Self.makeGear(id: "snapshot-synthesis-boots", type: .boots, level: 10, rarity: .common, stats: ItemStats(bonusSPD: 3)),
            Self.makeGear(id: "snapshot-synthesis-ring", type: .ring, level: 10, rarity: .common, stats: ItemStats(bonusHP: 12)),
            Self.makeGear(id: "snapshot-synthesis-bracer", type: .bracer, level: 10, rarity: .common, stats: ItemStats(bonusHP: 10, bonusATK: 4))
        ]
        let comparisonItems = [
            Self.makeGear(id: "snapshot-locked-scepter", type: .scepter, level: 15, rarity: .rare, stats: ItemStats(bonusATK: 16), isLocked: true),
            Self.makeGear(id: "snapshot-legendary-crossbow", type: .crossbow, level: 20, rarity: .legendary, stats: ItemStats(bonusATK: 24, bonusCritDamage: 0.15)),
            Self.makeGear(id: "snapshot-immortal-amulet", type: .amulet, level: 25, rarity: .immortal, stats: ItemStats(bonusHP: 34, bonusCritRate: 0.03))
        ]
        (synthesisInputs + comparisonItems).forEach { inventory.add($0) }

        var cubeProgress = CubeProgress()
        _ = cubeProgress.infuse(comparisonItems[0])
        _ = cubeProgress.infuse(comparisonItems[1])

        _inventory = StateObject(wrappedValue: inventory)
        _hero = StateObject(wrappedValue: hero)
        self.cubeProgress = cubeProgress
        self.selectedItem = selectedItem
    }

    var body: some View {
        InventoryView(
            inventory: inventory,
            hero: hero,
            cubeProgress: cubeProgress,
            purchasedExpansionCount: 3,
            nextExpansionCost: InventoryExpansion.nextGoldCost(after: 3),
            worseEquipmentHandling: .alchemize,
            onEquip: { _ in },
            onExpandInventory: {},
            onWorseEquipmentHandlingChange: { _ in },
            onInfuseIntoCube: { _ in },
            onAlchemize: { _ in },
            onSynthesize: { _ in nil },
            initialSelectedItems: [selectedItem]
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(red: 0.035, green: 0.045, blue: 0.052))
    }

    private static func makeGear(
        id: String,
        type: EquipmentType,
        level: Int,
        rarity: Rarity,
        stats: ItemStats,
        isLocked: Bool = false
    ) -> Item {
        let progression = SourceItemCatalog.progression(for: type, itemLevel: level)
        return Item(
            id: id,
            name: progression?.name ?? type.localizedName,
            rarity: rarity,
            slot: type.equipSlot,
            stats: stats,
            description: "来源装备 \(progression?.id ?? "unknown")",
            itemLevel: level,
            isLocked: isLocked,
            equipmentType: type,
            sourceGearID: progression?.id
        )
    }
}

private struct CharacterPanelSnapshotView: View {
    @StateObject private var hero: Hero
    private let party: HeroParty
    private let activeSkillLoadouts: ActiveSkillLoadouts

    init() {
        let hero = Hero()
        hero.name = "Snapshot Hunter"
        hero.changeClass(to: .hunter)
        hero.level = 12
        hero.currentXP = 340
        hero.gold = 250_000
        hero.unlockedPassiveSkillIDs = ["501021", "501022", "501061"]
        _ = hero.equipment.equip(Self.makeGear(
            id: "snapshot-character-crossbow",
            type: .crossbow,
            level: 20,
            rarity: .legendary,
            stats: ItemStats(bonusATK: 24, bonusCritDamage: 0.15)
        ))
        _ = hero.equipment.equip(Self.makeGear(
            id: "snapshot-character-bolt",
            type: .bolt,
            level: 15,
            rarity: .rare,
            stats: ItemStats(bonusATK: 10, bonusSPD: 1)
        ))
        _ = hero.equipment.equip(Self.makeGear(
            id: "snapshot-character-armor",
            type: .armor,
            level: 20,
            rarity: .uncommon,
            stats: ItemStats(bonusHP: 24, bonusDEF: 8)
        ))

        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["50101", "50201"], for: .hunter)

        _hero = StateObject(wrappedValue: hero)
        party = HeroParty(primaryClass: .hunter, unlockedSlotCount: 1)
        activeSkillLoadouts = loadouts
    }

    var body: some View {
        CharacterView(
            hero: hero,
            party: party,
            activeSkillLoadouts: activeSkillLoadouts,
            activeSkillSlotCount: 2,
            allHeroAttackDamageBonus: 4,
            allHeroAttackDamageMultiplier: 1.30,
            onClassChange: { _ in },
            onPartyMemberChange: { _, _ in },
            partySlotUnlockCost: { slotIndex in
                RuneTree(unlockedPartySlotCount: 1).directPartySlotUnlockCost(for: slotIndex)
            },
            canUnlockPartySlot: { slotIndex in
                RuneTree(unlockedPartySlotCount: 1).canDirectlyUnlockPartySlot(slotIndex, availableGold: hero.gold)
            },
            onPartySlotUnlock: { _ in },
            onActiveSkillChange: { _, _, _ in }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(red: 0.035, green: 0.045, blue: 0.052))
    }

    private static func makeGear(
        id: String,
        type: EquipmentType,
        level: Int,
        rarity: Rarity,
        stats: ItemStats
    ) -> Item {
        let progression = SourceItemCatalog.progression(for: type, itemLevel: level)
        return Item(
            id: id,
            name: progression?.name ?? type.localizedName,
            rarity: rarity,
            slot: type.equipSlot,
            stats: stats,
            description: "来源装备 \(progression?.id ?? "unknown")",
            itemLevel: level,
            equipmentType: type,
            sourceGearID: progression?.id
        )
    }
}

private struct ChestPanelSnapshotView: View {
    @StateObject private var gameEngine: GameEngine

    init() {
        let engine = GameEngine()
        engine.runeTree = RuneTree(unlockedNodes: [
            .openOneChestType,
            .openAllChestTypes,
            .autoOpenNormalChests,
            .autoOpenStageBossChests,
            .autoOpenActBossChests,
            .normalChestAutoOpenSpeed1,
            .stageBossChestAutoOpenSpeed1,
            .actBossChestAutoOpenSpeed1
        ])
        engine.progress.chests.add(LootChest(
            id: "snapshot-normal-monster-chest",
            kind: .normal,
            itemLevel: 1,
            sourceStageCode: "1-1",
            sourceDifficulty: .normal,
            family: .normalMonster
        ))
        engine.progress.chests.add(LootChest(
            id: "snapshot-stage-boss-chest",
            kind: .normal,
            itemLevel: 10,
            sourceStageCode: "1-9",
            sourceDifficulty: .normal,
            family: .stageBoss
        ))
        engine.progress.chests.add(LootChest(
            id: "snapshot-act-boss-chest",
            kind: .nightmare,
            itemLevel: 30,
            sourceStageCode: "2-10",
            sourceDifficulty: .nightmare,
            family: .actBoss
        ))
        engine.progress.chests.add(LootChest(
            id: "snapshot-torment-normal-chest",
            kind: .torment,
            itemLevel: 90,
            sourceStageCode: "4-10",
            sourceDifficulty: .torment,
            family: .normalMonster
        ))

        _gameEngine = StateObject(wrappedValue: engine)
    }

    var body: some View {
        ChestControlsView(gameEngine: gameEngine)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(12)
            .background(Color(red: 0.035, green: 0.045, blue: 0.052))
    }
}

private struct OriginalFidelityPanelSnapshotView: View {
    var body: some View {
        ScrollView {
            OriginalFidelityBoundaryView()
                .font(.system(size: 11))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(red: 0.035, green: 0.045, blue: 0.052))
    }
}

private struct RuneEvidencePanelSnapshotView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(red: 0.035, green: 0.045, blue: 0.052))
    }
}

private struct SkillEvidencePanelSnapshotView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GroupBox("本地技能运行时覆盖") {
                LocalSkillRuntimeCoverageView()
                    .font(.system(size: 11))
                    .padding(.vertical, 4)
            }

            GroupBox("原版技能伤害/射程复核") {
                VStack(alignment: .leading, spacing: 8) {
                    SourceSkillDamageReviewView()
                    SourceSkillRangeReviewView()
                }
                .font(.system(size: 11))
                .padding(.vertical, 4)
            }

            GroupBox("待接入源技能复核") {
                PendingSourceSkillReviewView()
                    .font(.system(size: 11))
                    .padding(.vertical, 4)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(red: 0.035, green: 0.045, blue: 0.052))
    }
}

private struct PassiveEvidencePanelSnapshotView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GroupBox("被动技能源表") {
                SourcePassiveSkillDatabaseView()
                    .font(.system(size: 11))
                    .padding(.vertical, 4)
            }

            GroupBox("被动源图标样本") {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(Self.samplePassiveSkills) { passiveSkill in
                        SourcePassiveSkillRow(passiveSkill: passiveSkill)
                    }
                }
                .font(.system(size: 11))
                .padding(.vertical, 4)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(red: 0.035, green: 0.045, blue: 0.052))
    }

    private static var samplePassiveSkills: [PassiveSkill] {
        let visibleSourceIconRows = Array(PassiveSkills.all.prefix(18))
        let missingSourceIconRows = PassiveSkills.all.filter {
            GameArt.passiveSkillIconName(for: $0) == nil
        }
        var seenIDs = Set<String>()
        return (visibleSourceIconRows + missingSourceIconRows).filter { passiveSkill in
            seenIDs.insert(passiveSkill.id).inserted
        }
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
        case .playerStatusRow,
             .playerStatusRowCrowded,
             .battleLogPanel,
             .victoryRewardBanner,
             .victoryLevelCapBanner,
             .completionSettlement,
             .battleTabLayout,
             .inventoryPanel,
             .characterPanel,
             .chestPanel,
             .originalFidelityPanel,
             .runeEvidencePanel,
             .skillEvidencePanel,
             .passiveEvidencePanel,
             .contactPulseBaseline:
            break
        case .frostBolt:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "寒霜弩箭",
                    kind: .damage,
                    damageElement: .cold,
                    delivery: .projectileAOE
                )
            )
        case .meleeArc:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "穿透突刺",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .melee
                )
            )
        case .rapidVolley:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "快速射击",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .projectile
                )
            )
        case .scatterShot:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "散弹射击",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .projectile
                )
            )
        case .arrowRain:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "箭雨",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .rangeAOE
                )
            )
        case .piercingArrow:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "穿透之箭",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .projectile
                )
            )
        case .skewerShot:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "穿刺射击",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .projectile
                )
            )
        case .explosiveBolt:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "爆炸弩箭",
                    kind: .damage,
                    damageElement: .fire,
                    delivery: .projectileAOE
                )
            )
        case .meteorStrike:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "陨石打击",
                    kind: .damage,
                    damageElement: .fire,
                    delivery: .rangeAOE
                )
            )
        case .lightningStrike:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "闪电术",
                    kind: .damage,
                    damageElement: .lightning,
                    delivery: .rangeAOE
                )
            )
        case .shockBolt:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "电击弩箭",
                    kind: .damage,
                    damageElement: .lightning,
                    delivery: .projectile
                )
            )
        case .trapBurst:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "充能陷阱爆炸",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .trap
                )
            )
        case .summonProjectile:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "弩炮塔",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .summonProjectile
                )
            )
        case .shockCurrent:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "电击弩箭电流",
                    kind: .damage,
                    damageElement: .lightning,
                    delivery: .projectile
                )
            )
        case .shieldCharge:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "盾牌冲锋",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .melee
                )
            )
        case .slamJump:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "猛击跳跃",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .meleeAOE
                )
            )
        case .earthquakeImpact:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "大地强击",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .meleeAOE
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
        case .axeSpin:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "旋转斧",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .meleeAOE
                )
            )
        case .axeSpinBleedFollowUp:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 777,
                    isCrit: false,
                    skillName: "旋转斧流血追击",
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
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .meleeAOE
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
                    damageElement: .fire,
                    delivery: .none
                )
            )
        case .monsterColdIncoming:
            battle.log.append(
                BattleLogEntry(
                    attacker: .monster,
                    damage: 777,
                    isCrit: false,
                    kind: .damage,
                    damageElement: .cold,
                    delivery: .none
                )
            )
        case .monsterLightningIncoming:
            battle.log.append(
                BattleLogEntry(
                    attacker: .monster,
                    damage: 777,
                    isCrit: false,
                    kind: .damage,
                    damageElement: .lightning,
                    delivery: .none
                )
            )
        case .monsterChaosIncoming:
            battle.log.append(
                BattleLogEntry(
                    attacker: .monster,
                    damage: 777,
                    isCrit: false,
                    kind: .damage,
                    damageElement: .chaos,
                    delivery: .none
                )
            )
        case .enemyStatusEffects:
            battle.activateBattleSceneSnapshotEnemyStatuses()
        case .heroContactPulse:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 444,
                    isCrit: false,
                    skillName: "接触脉冲测试",
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .melee
                )
            )
        case .monsterContactPulse:
            battle.log.append(
                BattleLogEntry(
                    attacker: .monster,
                    damage: 222,
                    isCrit: false,
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .none,
                    attackerName: "接触脉冲测试怪物"
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
        case .sanctuaryUtility:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 300,
                    isCrit: false,
                    skillName: "圣域",
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
        case .wrathOfHeavenUtility:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 0,
                    isCrit: false,
                    skillName: "天堂之怒",
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
        case .criticalFloating:
            battle.log.append(
                BattleLogEntry(
                    attacker: .hero,
                    damage: 999,
                    isCrit: true,
                    kind: .damage,
                    damageElement: .physical,
                    delivery: .melee
                )
            )
        case .dodgeFloating:
            battle.log.append(
                BattleLogEntry(
                    attacker: .monster,
                    damage: 0,
                    isCrit: false,
                    kind: .dodge,
                    damageElement: .fire,
                    delivery: .none,
                    attackerName: "规避测试攻击者"
                )
            )
        case .blockFloating:
            battle.log.append(
                BattleLogEntry(
                    attacker: .monster,
                    damage: 0,
                    isCrit: false,
                    kind: .block,
                    damageElement: .physical,
                    delivery: .none,
                    attackerName: "格挡测试攻击者"
                )
            )
        case .victoryFinishScene:
            battle.activateBattleSceneSnapshotTerminalState(victory: true)
        case .defeatFinishScene:
            battle.activateBattleSceneSnapshotTerminalState(victory: false)
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

    static func makeBattleLogPanelEntries() -> [BattleLogEntry] {
        var entries: [BattleLogEntry] = []
        for index in 0..<12 {
            entries.append(BattleLogEntry(
                attacker: index.isMultiple(of: 2) ? .hero : .support(.priest),
                damage: 160 + index * 11,
                isCrit: index == 10,
                skillName: index.isMultiple(of: 2) ? "劈砍" : "治愈",
                kind: index.isMultiple(of: 2) ? .damage : .heal,
                damageElement: index.isMultiple(of: 2) ? .physical : .none,
                delivery: index.isMultiple(of: 2) ? .melee : .heal
            ))
        }
        for index in 0..<62 {
            entries.append(BattleLogEntry(
                attacker: .monster,
                damage: 18 + index,
                isCrit: false,
                damageElement: index.isMultiple(of: 5) ? .fire : .physical,
                delivery: .melee,
                attackerName: index.isMultiple(of: 5) ? "燃烧的地狱祭司" : "长战斗怪物 \(index)"
            ))
        }
        return entries
    }
}
