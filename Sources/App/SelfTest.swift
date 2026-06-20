import Foundation
import CoreGraphics
import AppKit

#if DEBUG
/// 本地自检 — 在缺少 XCTest/swift-testing 的 CLT 环境下提供最小测试反馈。
/// 完整测试套件位于 Tests/GameTests（swift-testing，在带完整 Xcode 的环境/CI 上运行）。
/// 用法：swift run TBH --self-test
enum SelfTest {
    private static var failures: [String] = []

    private final class SilentAudio: GameAudioPlaying {
        var isEnabled = true
        var isMutedByInterface = true
        private(set) var events: [GameAudioEvent] = []

        func play(_ event: GameAudioEvent) {
            guard isEnabled, !isMutedByInterface else { return }
            events.append(event)
        }

        func clearEvents() {
            events.removeAll()
        }
    }

    private static func expect(
        _ condition: Bool,
        _ message: String,
        file: String = #fileID,
        line: UInt = #line
    ) {
        if condition {
            print("  ✓ \(message)")
        } else {
            failures.append("\(file):\(line) \(message)")
            print("  ✗ \(message)")
        }
    }

    private static func nearlyEqual(_ lhs: CGFloat, _ rhs: CGFloat, tolerance: CGFloat = 0.001) -> Bool {
        abs(lhs - rhs) <= tolerance
    }

    private static func nearlyEqual(_ lhs: Double, _ rhs: Double, tolerance: Double = 0.0001) -> Bool {
        abs(lhs - rhs) <= tolerance
    }

    static func runAll() -> Never {
        print("=== TBH Self Test ===")

        damageCalculator()
        tabBarIcons()
        controlsFidelity()
        settingsFidelityBoundaries()
        settingsBattleAnimationEvidenceReview()
        settingsAudioSFXEvidenceReview()
        settingsSupportFormulaReview()
        settingsLocalRuneCostReview()
        settingsSourceRuneEvidenceReview()
        settingsSourceMonsterDatabase()
        settingsSourceMonsterArtMapping()
        settingsSourceMonsterAttackMappings()
        settingsSourceItemDatabase()
        settingsExactItemRecordGap()
        settingsSourceCraftingRules()
        settingsLocalSkillRuntimeCoverage()
        settingsSourceSkillDamageReview()
        settingsSourceSkillActivationDamageReview()
        settingsSourceSkillActivationDeliveryReview()
        settingsSourceSkillDamageDeliveryReview()
        settingsSourceSkillDeliveryReview()
        settingsSourceSkillRangeReview()
        settingsPendingSourceSkillReview()
        settingsModeledActiveSkillValueTables()
        settingsSourcePassiveSkillDatabase()
        heroArtMappings()
        skillArtMappings()
        runeTreeArtMappings()
        battleSceneMetrics()
        battleSceneSnapshot()
        playerBattleStatusBadges()
        playerBattleDeployables()
        battleLogDisplayEntries()
        battleResultRewardPresentation()
        battleImpactCues()
        battleIncomingCues()
        battleTrajectoryCues()
        battleUtilityCues()
        heroClasses()
        partyAndSupport()
        battleSkills()
        sourceSkillCatalog()
        passiveSkills()
        runeTree()
        progressTracker()
        offlineProgress()
        offlineRuneGate()
        gameStatistics()
        itemContract()
        inventoryCapacity()
        inventoryInteractions()
        gameEngineEquip()
        gameEngineRuntimeLoop()
        gameAudioRoutes()
        saveRoundTrip()

        if failures.isEmpty {
            print("=== ALL PASSED ===")
            exit(0)
        } else {
            print("=== \(failures.count) FAILURE(S) ===")
            failures.forEach { print("  FAIL: \($0)") }
            exit(1)
        }
    }

    // MARK: - Suites

    private static func tabBarIcons() {
        print("[TabBarIcons]")

        let systemIconTabs = MenuBarPopover.Tab.allCases.filter {
            !TabBarIconResolver.usesCustomArtwork(for: $0)
        }
        let resolvedNames = systemIconTabs.map { tab in
            (tab, TabBarIconResolver.resolvedName(for: tab))
        }

        expect(
            resolvedNames.allSatisfy { !$0.1.isEmpty && $0.1 != "circle.fill" },
            "menu tabs resolve dedicated SF Symbol icons"
        )
        expect(
            TabBarIconResolver.usesCustomArtwork(for: .battle),
            "battle tab uses bundled vector combat artwork"
        )
        expect(
            TabBarIconMetrics.width >= 16 &&
                TabBarIconMetrics.height >= 14,
            "tab icons reserve visible non-zero geometry"
        )
    }

    private static func controlsFidelity() {
        print("[Controls]")

        let defaultSize = MenuBarPopoverLayout.size(for: MenuBarPopoverLayout.defaultScale)
        let minimumSize = MenuBarPopoverLayout.size(for: MenuBarPopoverLayout.minimumScale)
        let maximumSize = MenuBarPopoverLayout.size(for: MenuBarPopoverLayout.maximumScale)

        expect(
            nearlyEqual(defaultSize.width, MenuBarPopoverLayout.defaultSize.width) &&
                nearlyEqual(defaultSize.height, MenuBarPopoverLayout.defaultSize.height),
            "panel scale reset returns to the default menu-bar popover size"
        )
        expect(
            MenuBarPopoverLayout.defaultSize.width <= 660 &&
                MenuBarPopoverLayout.defaultSize.width >= BattleSceneMetrics.expectedPopoverContentWidth &&
                MenuBarPopoverLayout.defaultSize.height <= 600 &&
                MenuBarPopoverLayout.contentMinHeight <= 500 &&
                MenuBarPopoverLayout.bottomTabHeight >= 44,
            "menu-bar popover keeps the bottom-tab battle layout within a visible macOS menu window"
        )
        let battleTabContentHeight = BattleSceneMetrics.compactHeight +
            BattleLogMetrics.panelHeight +
            BattlePanelMetrics.sectionSpacing +
            BattlePanelMetrics.verticalPadding * 2
        expect(
            MenuBarPopoverLayout.contentMinHeight >= battleTabContentHeight &&
                MenuBarPopoverLayout.defaultSize.width >=
                BattleSceneMetrics.expectedPopoverContentWidth + BattlePanelMetrics.horizontalPadding * 2,
            "bottom-tab popover content can fit the battle scene and battle log without vertical compression"
        )
        expect(
            MenuBarPopoverLayout.normalizedScale(0.01) == MenuBarPopoverLayout.minimumScale &&
                MenuBarPopoverLayout.normalizedScale(99) == MenuBarPopoverLayout.maximumScale,
            "panel scale clamps to the supported macOS menu-bar translation range"
        )
        expect(
                MenuBarPopoverLayout.minimumScale == MenuBarPopoverLayout.defaultScale &&
                minimumSize.width == defaultSize.width &&
                maximumSize.width == defaultSize.width &&
                minimumSize.height == defaultSize.height &&
                maximumSize.height == defaultSize.height,
            "panel scale preserves the visible default size without growing beyond the screen"
        )
        expect(
            MenuBarPopoverLayout.scaleStep == 0.05,
            "panel scale uses deterministic five-percent steps"
        )
        expect(
            OriginalControlShortcuts.scaleResetFunctionKeyCode == Int(NSF11FunctionKey) &&
                OriginalControlShortcuts.scaleResetModifiers == [.shift],
            "panel scale reset maps the checked original Shift+F11 shortcut"
        )
        expect(
            CompletionSettlementLabels.deferButtonTitle == "稍后开启" &&
                CompletionSettlementLabels.deferredConfirmationText.contains("保留结算状态") &&
                CompletionSettlementLabels.startButtonTitle(for: ProgressTracker()) == "开启第 2 周目",
            "completion settlement exposes explicit defer and next-playthrough choices"
        )
    }

    private static func heroArtMappings() {
        print("[HeroArtMappings]")

        let mappings = HeroClass.allCases.map { heroClass in
            (
                heroClass,
                GameArt.heroSpriteName(for: heroClass),
                GameArt.battleHeroSpriteName(for: heroClass)
            )
        }

        expect(
            mappings.allSatisfy { $0.1 != $0.2 },
            "battle scene hero sprites use dedicated battle sprite files instead of UI portrait files"
        )
        expect(
            mappings.allSatisfy { $0.2.hasPrefix("battle_hero_") },
            "battle scene hero sprites resolve to compact transparent battle figures"
        )
        expect(
            Set(mappings.map(\.2)).count == HeroClass.allCases.count,
            "each hero class keeps a dedicated battle scene sprite"
        )

        let mainSpritesPreserveNativeScale = HeroClass.allCases.allSatisfy { heroClass in
            let pixelSize = GameArt.battleHeroPixelSize(for: heroClass)
            let displaySize = BattleHeroSpriteMetrics.mainSize(for: heroClass)
            return nearlyEqual(displaySize.width / pixelSize.width, BattleHeroSpriteMetrics.mainScale) &&
                nearlyEqual(displaySize.height / pixelSize.height, BattleHeroSpriteMetrics.mainScale)
        }
        expect(
            mainSpritesPreserveNativeScale,
            "main battle hero sprites preserve each class sprite's native pixel proportions"
        )

        let supportSpritesPreserveNativeScale = HeroClass.allCases.allSatisfy { heroClass in
            let pixelSize = GameArt.battleHeroPixelSize(for: heroClass)
            let displaySize = BattleHeroSpriteMetrics.supportSize(for: heroClass)
            return nearlyEqual(displaySize.width / pixelSize.width, BattleHeroSpriteMetrics.supportScale) &&
                nearlyEqual(displaySize.height / pixelSize.height, BattleHeroSpriteMetrics.supportScale)
        }
        expect(
            supportSpritesPreserveNativeScale,
            "support battle hero sprites preserve each class sprite's native pixel proportions"
        )
        expect(
            BattleHeroSpriteMetrics.mainScale > BattleHeroSpriteMetrics.supportScale &&
                HeroClass.allCases.allSatisfy { heroClass in
                    let mainSize = BattleHeroSpriteMetrics.mainSize(for: heroClass)
                    let supportSize = BattleHeroSpriteMetrics.supportSize(for: heroClass)
                    return mainSize.width > supportSize.width &&
                        mainSize.height > supportSize.height
                },
            "battle tab keeps the primary hero visually dominant over support members"
        )

        let maximumBattleHeroHeight = BattleSceneMetrics.compactHeight * 0.72
        let heroSpritesFitCompactBattleStrip = HeroClass.allCases.allSatisfy { heroClass in
            let mainSize = BattleHeroSpriteMetrics.mainSize(for: heroClass)
            let supportSize = BattleHeroSpriteMetrics.supportSize(for: heroClass)
            return mainSize.height <= maximumBattleHeroHeight &&
                supportSize.height <= maximumBattleHeroHeight
        }
        expect(
            heroSpritesFitCompactBattleStrip,
            "battle scene hero sprites fit inside the compact taskbar battle strip without cropping"
        )
        expect(
            BattleHeroSpriteMetrics.enemyFacingXScale == -1,
            "battle scene flips player hero sprites to face the right-side monster lane"
        )
    }

    private static func skillArtMappings() {
        print("[SkillArtMappings]")

        let allNamedSkills = HeroClass.allCases.flatMap { HeroSkills.named(for: $0) }
        let iconNames = allNamedSkills.map { GameArt.skillIconName(for: $0) }

        expect(
            iconNames.count == 36,
            "all modeled active skills resolve to category icons"
        )
        expect(
            iconNames.allSatisfy { $0.hasPrefix("skill_") },
            "skill icons use bundled skill_* resources"
        )
        expect(
            Set(iconNames).count >= 8,
            "skill icon mapping keeps visual variety across skill categories"
        )

        let fireball = HeroSkills.named(for: .sorcerer).first { $0.id == "30101" }
        let iceOrb = HeroSkills.named(for: .sorcerer).first { $0.id == "30201" }
        let lightning = HeroSkills.named(for: .sorcerer).first { $0.id == "30301" }
        let heal = HeroSkills.named(for: .priest).first { $0.id == "40101" }
        let resurrection = HeroSkills.named(for: .priest).first { $0.id == "40601" }
        let chargeTrap = HeroSkills.named(for: .hunter).first { $0.id == "50401" }
        let quickLoader = HeroSkills.named(for: .hunter).first { $0.id == "50301" }

        expect(
            fireball.map(GameArt.skillIconName(for:)) == "skill_0_2" &&
                iceOrb.map(GameArt.skillIconName(for:)) == "skill_2_1" &&
                lightning.map(GameArt.skillIconName(for:)) == "skill_2_2",
            "elemental skills resolve to distinct fire, cold and lightning icons"
        )
        expect(
            heal.map(GameArt.skillIconName(for:)) == "skill_0_3" &&
                resurrection.map(GameArt.skillIconName(for:)) == "skill_0_3",
            "healing and resurrection skills resolve to the blessing icon"
        )
        expect(
            chargeTrap.map(GameArt.skillIconName(for:)) == "skill_1_0" &&
                quickLoader.map(GameArt.skillIconName(for:)) == "skill_1_3",
            "utility Hunter skills keep separate trap and rapid-attack icons"
        )
    }

    private static func runeTreeArtMappings() {
        print("[RuneTreeArtMappings]")

        let mappedIcons = RuneTreeNode.allCases.map { GameArt.runeTreeIconName(for: $0) }

        expect(
            mappedIcons.allSatisfy { $0.hasPrefix("source_rune_") },
            "modeled Rune Tree nodes resolve to source Rune icon artwork"
        )
        expect(
            Set(mappedIcons).isSubset(of: Set(GameArt.runeTreeIconNames)) &&
                GameArt.runeTreeIconNames.count == SourceRuneCatalog.iconNames.count,
            "Rune Tree icon resource list covers the checked source icon families"
        )
        expect(
            GameArt.runeTreeIconName(for: .partySlot2) == GameArt.runeTreeIconName(for: .partySlot3) &&
                GameArt.runeTreeIconName(for: .partySlot2) == "source_rune_UnlockArrangeSlotCount",
            "Rune of Command formation slots share the checked source formation icon"
        )
        expect(
                GameArt.runeTreeIconName(for: .activeSkillSlot2) == "source_rune_UnlockSkillSlotCount" &&
                RuneTree.combatGoldBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_IncreaseGoldAmount" } &&
                RuneTree.combatXPBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_IncreaseExpAmount" } &&
                RuneTree.additionalGoldBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalGold" } &&
                RuneTree.additionalGoldNormalMonsterNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalGoldNormalMonster" } &&
                RuneTree.additionalGoldStageBossNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalGoldStageBoss" } &&
                RuneTree.additionalGoldActBossNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalGoldActBoss" } &&
                RuneTree.additionalXPBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalExp" } &&
                RuneTree.additionalXPNormalMonsterNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalExpNormalMonster" } &&
                RuneTree.additionalXPStageBossNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalExpStageBoss" } &&
                RuneTree.additionalXPActBossNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalExpActBoss" } &&
                RuneTree.cubeXPBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_CubeExpPercent" } &&
                RuneTree.alchemyGoldBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_CubeAlchemyGoldPercent" } &&
                RuneTree.inventoryExpansionNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_MaxInventorySlot" } &&
                GameArt.runeTreeIconName(for: .openOneChestType) == "source_rune_OpenOneTypeChestAllAtOnce" &&
                GameArt.runeTreeIconName(for: .openAllChestTypes) == "source_rune_OpenAllTypeChestAllAtOnce" &&
                GameArt.runeTreeIconName(for: .autoOpenNormalChests) == "source_rune_UnlockAutoOpenNormalChest" &&
                GameArt.runeTreeIconName(for: .autoOpenStageBossChests) == "source_rune_UnlockAutoOpenStageBossChest" &&
                GameArt.runeTreeIconName(for: .autoOpenActBossChests) == "source_rune_UnlockAutoOpenActBossChest" &&
                RuneTree.normalChestDropChanceNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_DropChanceNormalChest" } &&
                RuneTree.stageBossChestDropChanceNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_DropChanceStageBossChest" } &&
                RuneTree.normalChestAutoOpenSpeedNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_ReduceAutoOpenNormalChestTime" } &&
                RuneTree.stageBossChestAutoOpenSpeedNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_ReduceAutoOpenStageBossChestTime" } &&
                RuneTree.actBossChestAutoOpenSpeedNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_ReduceAutoOpenActBossChestTime" } &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage2) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage3) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage4) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage5) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage6) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage7) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage8) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage9) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage10) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage11) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage12) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage13) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage14) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxNormalChestStorage15) == "source_rune_MaxAmountNormalChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage2) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage3) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage4) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage5) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage6) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage7) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage8) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage9) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage10) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage11) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage12) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxStageBossChestStorage13) == "source_rune_MaxAmountStageBossChest" &&
                GameArt.runeTreeIconName(for: .maxActBossChestStorage) == "source_rune_MaxAmountActBossChest" &&
                GameArt.runeTreeIconName(for: .maxActBossChestStorage2) == "source_rune_MaxAmountActBossChest" &&
                GameArt.runeTreeIconName(for: .maxActBossChestStorage3) == "source_rune_MaxAmountActBossChest" &&
                GameArt.runeTreeIconName(for: .maxActBossChestStorage4) == "source_rune_MaxAmountActBossChest" &&
                GameArt.runeTreeIconName(for: .maxActBossChestStorage5) == "source_rune_MaxAmountActBossChest" &&
                GameArt.runeTreeIconName(for: .maxActBossChestStorage6) == "source_rune_MaxAmountActBossChest" &&
                GameArt.runeTreeIconName(for: .maxActBossChestStorage7) == "source_rune_MaxAmountActBossChest" &&
                GameArt.runeTreeIconName(for: .maxActBossChestStorage8) == "source_rune_MaxAmountActBossChest" &&
                GameArt.runeTreeIconName(for: .maxActBossChestStorage9) == "source_rune_MaxAmountActBossChest" &&
                GameArt.runeTreeIconName(for: .maxActBossChestStorage10) == "source_rune_MaxAmountActBossChest" &&
                GameArt.runeTreeIconName(for: .offlineRewards) == "source_rune_UnlockOfflineReward" &&
                RuneTree.offlineGoldBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_OfflineRewardGoldPercent" } &&
                RuneTree.offlineXPBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_OfflineRewardExpPercent" } &&
                GameArt.runeTreeIconName(for: .stashPage1) == "source_rune_UnlockStashPageCount" &&
                GameArt.runeTreeIconName(for: .stashPage2) == "source_rune_UnlockStashPageCount" &&
                GameArt.runeTreeIconName(for: .stashPage3) == "source_rune_UnlockStashPageCount" &&
                GameArt.runeTreeIconName(for: .waveCountReduction1) == "source_rune_WaveCountReduction" &&
                GameArt.runeTreeIconName(for: .allHeroMoveSpeed1) == "source_rune_AllHeroMoveSpeed" &&
                GameArt.runeTreeIconName(for: .allHeroMoveSpeed2) == "source_rune_AllHeroMoveSpeed" &&
                GameArt.runeTreeIconName(for: .allHeroMoveSpeed3) == "source_rune_AllHeroMoveSpeed" &&
                GameArt.runeTreeIconName(for: .allHeroMoveSpeed4) == "source_rune_AllHeroMoveSpeed" &&
                GameArt.runeTreeIconName(for: .allHeroMoveSpeed5) == "source_rune_AllHeroMoveSpeed" &&
                GameArt.runeTreeIconName(for: .allHeroAttackDamagePercent1) == "source_rune_AllHeroAttackDamagePercent" &&
                GameArt.runeTreeIconName(for: .allHeroArmorPercent1) == "source_rune_AllHeroArmorPercent" &&
                GameArt.runeTreeIconName(for: .allHeroAttackDamagePercent2) == "source_rune_AllHeroAttackDamagePercent" &&
                GameArt.runeTreeIconName(for: .allHeroAttackDamagePercent3) == "source_rune_AllHeroAttackDamagePercent" &&
                GameArt.runeTreeIconName(for: .allHeroAttackSpeed3) == "source_rune_AllHeroAttackSpeed" &&
                GameArt.runeTreeIconName(for: .allHeroArmor3) == "source_rune_AllHeroArmor" &&
                GameArt.runeTreeIconName(for: .allHeroArmorPercent2) == "source_rune_AllHeroArmorPercent",
            "modeled active-skill, inventory, storage, chest-opening, chest-capacity and offline Rune Tree nodes use source category icons"
        )
        expect(Set(mappedIcons).count == 39, "current modeled Rune Tree nodes use all thirty-nine checked source icon families")
    }

    private static func battleSceneMetrics() {
        print("[BattleSceneMetrics]")

        let officialRatio = Double(BattleSceneMetrics.officialAspectRatio)
        let popoverRatio = Double(BattleSceneMetrics.popoverSceneAspectRatio)
        let ratioDelta = abs(officialRatio - popoverRatio)

        expect(
            officialRatio > 4.25 && officialRatio < 4.35,
            "official Steam battle scene ratio is modeled as a wide strip"
        )
        expect(
            popoverRatio >= 2.04 && popoverRatio <= 2.06 && ratioDelta <= 2.30,
            "popover battle scene uses a visible macOS viewport while preserving a horizontal combat lane"
        )
        expect(
            BattleSceneMetrics.compactHeight >= 280 &&
                BattleSceneMetrics.compactHeight <= 320,
            "battle scene reserves a large visible combat viewport above the bottom tab bar"
        )
        expect(
            BattleLogMetrics.visibleEntryLimit >= 50 &&
                BattleLogMetrics.minimumVisibleHeroSideEntries >= 8 &&
                BattleLogMetrics.heroHighlightEntryLimit >= 3 &&
                BattleLogMetrics.panelHeight >= 160 &&
                BattleLogMetrics.panelHeight <= 180,
            "battle tab keeps a taller scrollable combat log below the visible scene"
        )
        expect(
            BattleSceneMetrics.groundHeightRatio >= 0.13 &&
                BattleSceneMetrics.groundHeightRatio <= 0.15,
            "battle scene reserves most vertical space for dark negative space above the lane"
        )
        expect(
            BattleSceneMetrics.partyPlatformXRatio >= 0.43 &&
                BattleSceneMetrics.partyPlatformXRatio < BattleSceneMetrics.enemyPlatformXRatio &&
                BattleSceneMetrics.enemyPlatformXRatio <= 0.90,
            "battle scene keeps the player party inside the left combat lane facing the enemy"
        )
        expect(
            BattleSceneMetrics.combatantBaselineRatio >= 0.92 &&
                BattleSceneMetrics.combatantBaselineRatio <= 0.94 &&
                BattleSceneMetrics.combatantBaselineY < BattleSceneMetrics.compactHeight,
            "battle scene keeps combatants on the lower ground lane"
        )
        expect(
            nearlyEqual(
                BattleSceneMetrics.visualScale,
                BattleSceneMetrics.maximumVisualScaleHeight / BattleSceneMetrics.referenceCompactHeight
            ),
            "battle scene enlarges the viewport without over-scaling combatants into cropped figures"
        )
        expect(
            BattleSceneMetrics.effectScale >= 1.85,
            "battle scene scales combat cues with the enlarged viewport"
        )
        expect(
            nearlyEqual(BattleSceneMetrics.sourceRangeVisualScale(for: nil), 1.0) &&
                nearlyEqual(BattleSceneMetrics.sourceRangeVisualScale(for: 150), 0.84) &&
                nearlyEqual(BattleSceneMetrics.sourceRangeVisualScale(for: 900), 1.0) &&
                nearlyEqual(BattleSceneMetrics.sourceRangeVisualScale(for: 1_650), 1.36) &&
                BattleSceneMetrics.sourceRangeVerticalScale(for: 1_650) > BattleSceneMetrics.sourceRangeVerticalScale(for: 150),
            "battle scene uses checked source range as a conservative trajectory-size visual cue"
        )
        expect(
            BattleSceneMetrics.utilityCueScale > 1.28 &&
                BattleSceneMetrics.utilityCueScale < BattleSceneMetrics.effectScale,
            "battle scene keeps utility cues readable without overpowering hit effects"
        )
        expect(
            BattleSceneMetrics.groundPlatformWidthRatio >= 0.86 &&
                BattleSceneMetrics.groundPlatformWidthRatio <= 0.94,
            "battle scene keeps only subtle dark side margins around the ground platform"
        )
        expect(
            BattleSceneMetrics.sceneCornerRadius == 0 &&
                BattleSceneMetrics.sceneBorderLineWidth == 0,
            "battle scene avoids decorative card frame styling"
        )
        let stagePillLabel = BattleSceneLabels.stagePillText(progress: ProgressTracker())
        expect(
            stagePillLabel == "1-1" &&
                !stagePillLabel.contains("W") &&
                !stagePillLabel.contains("/"),
            "battle scene stage pill shows only the original-style stage code"
        )
        expect(
            BattleSceneMetrics.flameColumnCount >= 16,
            "battle scene models the official moving flame strip with multiple pixel columns"
        )
        expect(
            BattleSceneMetrics.flameAnimationFrameRate >= 8 &&
                BattleSceneMetrics.flameAnimationFrameRate <= 15,
            "battle scene flame animation uses a low-rate pixel cadence"
        )
        expect(
            BattleSceneMetrics.combatAnimationFrameRate >= 8 &&
                BattleSceneMetrics.combatAnimationFrameRate <= 15,
            "battle scene combatants keep a low-rate pixel idle animation cadence"
        )
        expect(
            BattleSceneMetrics.actionFrameHoldDuration >= 0.24 &&
                BattleSceneMetrics.actionFrameHoldDuration <= 0.42 &&
                BattleSceneMetrics.strikeLungeDistance > 0 &&
                BattleSceneMetrics.hitSquashYScale < 1 &&
                BattleSceneMetrics.supportHPBarWidth >= 30 &&
                BattleSceneMetrics.finishCueWidth >= 72 &&
                BattleSceneMetrics.finishCueHeight >= 40,
            "battle scene keeps log-triggered strike and hit action frames visible without changing combat timing"
        )
    }

    private static func battleSceneSnapshot() {
        print("[BattleSceneSnapshot]")

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-battle-scene-\(UUID().uuidString).png")
        let motionOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-battle-scene-motion-\(UUID().uuidString).png")
        let statusRowOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-battle-status-row-\(UUID().uuidString).png")
        let crowdedStatusRowOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-battle-status-row-crowded-\(UUID().uuidString).png")
        let battleLogPanelOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-battle-log-panel-\(UUID().uuidString).png")
        let battleTabLayoutOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-battle-tab-layout-\(UUID().uuidString).png")
        let inventoryPanelOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-inventory-panel-\(UUID().uuidString).png")
        let characterPanelOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-character-panel-\(UUID().uuidString).png")
        let chestPanelOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-chest-panel-\(UUID().uuidString).png")
        let originalFidelityPanelOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-original-fidelity-panel-\(UUID().uuidString).png")
        let runeEvidencePanelOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-rune-evidence-panel-\(UUID().uuidString).png")
        let skillEvidencePanelOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-skill-evidence-panel-\(UUID().uuidString).png")
        let passiveEvidencePanelOutputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tbh-self-test-passive-evidence-panel-\(UUID().uuidString).png")
        let defaultSceneFixtures: [BattleSceneSnapshot.Fixture] = [
            .frostBolt,
            .contactPulseBaseline
        ]
        let damageFixtures: [BattleSceneSnapshot.Fixture] = [
            .meleeArc,
            .rapidVolley,
            .scatterShot,
            .arrowRain,
            .piercingArrow,
            .skewerShot,
            .explosiveBolt,
            .meteorStrike,
            .lightningStrike,
            .shockBolt,
            .trapBurst,
            .summonProjectile,
            .shockCurrent,
            .shieldCharge,
            .slamJump,
            .earthquakeImpact,
            .earthquakeRockExplosion,
            .axeSpin,
            .axeSpinBleedFollowUp,
            .shockwaveImpact,
            .chaosBurst,
            .monsterFireIncoming,
            .monsterColdIncoming,
            .monsterLightningIncoming,
            .monsterChaosIncoming
        ]
        let utilityFixtures: [BattleSceneSnapshot.Fixture] = [
            .healUtility,
            .sanctuaryUtility,
            .resurrectionUtility,
            .shieldUtility,
            .wrathOfHeavenUtility,
            .sacredBladeUtility,
            .swiftSurgeUtility,
            .quickLoaderUtility,
            .generalsCryUtility,
            .bloodlustUtility,
            .criticalFloating,
            .dodgeFloating,
            .blockFloating
        ]
        let terminalSceneFixtures: [BattleSceneSnapshot.Fixture] = [
            .victoryFinishScene,
            .defeatFinishScene
        ]
        let enemyStatusFixtures: [BattleSceneSnapshot.Fixture] = [
            .enemyStatusEffects
        ]
        let contactPulseFixtures: [BattleSceneSnapshot.Fixture] = [
            .heroContactPulse,
            .monsterContactPulse
        ]
        let statusRowFixtures: [BattleSceneSnapshot.Fixture] = [
            .playerStatusRow,
            .playerStatusRowCrowded
        ]
        let logFixtures: [BattleSceneSnapshot.Fixture] = [
            .battleLogPanel
        ]
        let bannerFixtures: [BattleSceneSnapshot.Fixture] = [
            .victoryRewardBanner,
            .victoryLevelCapBanner
        ]
        let settlementFixtures: [BattleSceneSnapshot.Fixture] = [
            .completionSettlement
        ]
        let layoutFixtures: [BattleSceneSnapshot.Fixture] = [
            .battleTabLayout
        ]
        let inventoryFixtures: [BattleSceneSnapshot.Fixture] = [
            .inventoryPanel
        ]
        let characterFixtures: [BattleSceneSnapshot.Fixture] = [
            .characterPanel
        ]
        let chestFixtures: [BattleSceneSnapshot.Fixture] = [
            .chestPanel
        ]
        let originalFidelityFixtures: [BattleSceneSnapshot.Fixture] = [
            .originalFidelityPanel
        ]
        let runeEvidenceFixtures: [BattleSceneSnapshot.Fixture] = [
            .runeEvidencePanel
        ]
        let skillEvidenceFixtures: [BattleSceneSnapshot.Fixture] = [
            .skillEvidencePanel
        ]
        let passiveEvidenceFixtures: [BattleSceneSnapshot.Fixture] = [
            .passiveEvidencePanel
        ]
        let categorizedFixtures = defaultSceneFixtures +
            damageFixtures +
            utilityFixtures +
            terminalSceneFixtures +
            enemyStatusFixtures +
            contactPulseFixtures +
            statusRowFixtures +
            logFixtures +
            bannerFixtures +
            settlementFixtures +
            layoutFixtures +
            inventoryFixtures +
            characterFixtures +
            chestFixtures +
            originalFidelityFixtures +
            runeEvidenceFixtures +
            skillEvidenceFixtures +
            passiveEvidenceFixtures
        expect(
            Set(categorizedFixtures) == Set(BattleSceneSnapshot.Fixture.allCases) &&
                categorizedFixtures.count == BattleSceneSnapshot.Fixture.allCases.count,
            "battle scene snapshot self-test categorizes every render fixture"
        )
        do {
            let defaultTime = try BattleSceneSnapshot.fixedBackdropTime(arguments: ["TBH"])
            let positionalTime = try BattleSceneSnapshot.fixedBackdropTime(arguments: [
                "TBH",
                "--render-battle-scene-time",
                "0.25"
            ])
            let inlineTime = try BattleSceneSnapshot.fixedBackdropTime(arguments: [
                "TBH",
                "--render-battle-scene-time=0.5"
            ])
            expect(
                defaultTime == nil &&
                    abs((positionalTime ?? -1) - 0.25) < 0.0001 &&
                    abs((inlineTime ?? -1) - 0.5) < 0.0001,
                "battle scene snapshot CLI resolves deterministic fixed animation times"
            )
        } catch {
            expect(false, "battle scene snapshot CLI resolves deterministic fixed animation times: \(error.localizedDescription)")
        }
        do {
            _ = try BattleSceneSnapshot.fixedBackdropTime(arguments: ["TBH", "--render-battle-scene-time"])
            expect(false, "battle scene snapshot CLI rejects missing fixed animation time values")
        } catch {
            expect(true, "battle scene snapshot CLI rejects missing fixed animation time values")
        }
        do {
            _ = try BattleSceneSnapshot.fixedBackdropTime(arguments: ["TBH", "--render-battle-scene-time", "not-a-number"])
            expect(false, "battle scene snapshot CLI rejects non-numeric fixed animation times")
        } catch {
            expect(true, "battle scene snapshot CLI rejects non-numeric fixed animation times")
        }
        do {
            _ = try BattleSceneSnapshot.fixedBackdropTime(arguments: ["TBH", "--render-battle-scene-time", "-0.25"])
            expect(false, "battle scene snapshot CLI rejects negative fixed animation times")
        } catch {
            expect(true, "battle scene snapshot CLI rejects negative fixed animation times")
        }
        do {
            let defaultHeroClass = try BattleSceneSnapshot.heroClass(arguments: ["TBH"])
            let caseNameHeroClasses = try HeroClass.allCases.map { heroClass in
                try BattleSceneSnapshot.heroClass(arguments: [
                    "TBH",
                    "--render-battle-scene-hero-class",
                    String(describing: heroClass)
                ])
            }
            let displayNameHeroClasses = try HeroClass.allCases.map { heroClass in
                try BattleSceneSnapshot.heroClass(arguments: [
                    "TBH",
                    "--render-battle-scene-hero-class=\(heroClass.rawValue)"
                ])
            }
            expect(
                defaultHeroClass == .knight &&
                    caseNameHeroClasses == HeroClass.allCases &&
                    displayNameHeroClasses == HeroClass.allCases,
                "battle scene snapshot CLI resolves every hero class case name and Chinese display name"
            )
        } catch {
            expect(false, "battle scene snapshot CLI resolves every hero class case name and Chinese display name: \(error.localizedDescription)")
        }
        do {
            _ = try BattleSceneSnapshot.heroClass(arguments: ["TBH", "--render-battle-scene-hero-class"])
            expect(false, "battle scene snapshot CLI rejects missing hero-class values")
        } catch {
            expect(true, "battle scene snapshot CLI rejects missing hero-class values")
        }
        do {
            _ = try BattleSceneSnapshot.heroClass(arguments: ["TBH", "--render-battle-scene-hero-class", "definitelyNotAHero"])
            expect(false, "battle scene snapshot CLI rejects invalid hero-class values")
        } catch {
            expect(true, "battle scene snapshot CLI rejects invalid hero-class values")
        }
        let damageOutputURLs = damageFixtures.map { fixture in
            (
                fixture,
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("tbh-self-test-battle-scene-\(fixture.rawValue)-\(UUID().uuidString).png")
            )
        }
        let utilityOutputURLs = utilityFixtures.map { fixture in
            (
                fixture,
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("tbh-self-test-battle-scene-\(fixture.rawValue)-\(UUID().uuidString).png")
            )
        }
        let terminalSceneOutputURLs = terminalSceneFixtures.map { fixture in
            (
                fixture,
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("tbh-self-test-battle-scene-\(fixture.rawValue)-\(UUID().uuidString).png")
            )
        }
        let enemyStatusOutputURLs = enemyStatusFixtures.map { fixture in
            (
                fixture,
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("tbh-self-test-battle-scene-\(fixture.rawValue)-\(UUID().uuidString).png")
            )
        }
        let contactPulseOutputURLs = contactPulseFixtures.map { fixture in
            (
                fixture,
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("tbh-self-test-battle-scene-\(fixture.rawValue)-\(UUID().uuidString).png")
            )
        }
        let heroClassOutputURLs = HeroClass.allCases.map { heroClass in
            (
                heroClass,
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("tbh-self-test-battle-scene-\(heroClass)-\(UUID().uuidString).png")
            )
        }
        let bannerOutputURLs = bannerFixtures.map { fixture in
            (
                fixture,
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("tbh-self-test-battle-banner-\(fixture.rawValue)-\(UUID().uuidString).png")
            )
        }
        let settlementOutputURLs = settlementFixtures.map { fixture in
            (
                fixture,
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("tbh-self-test-settlement-\(fixture.rawValue)-\(UUID().uuidString).png")
            )
        }

        do {
            let officialMotionSampleTime = 8.0 / 30.0
            try BattleSceneSnapshot.render(to: outputURL, fixedBackdropTime: 0)
            try BattleSceneSnapshot.render(to: motionOutputURL, fixedBackdropTime: officialMotionSampleTime)
            try BattleSceneSnapshot.render(
                to: statusRowOutputURL,
                fixture: .playerStatusRow
            )
            try BattleSceneSnapshot.render(
                to: crowdedStatusRowOutputURL,
                fixture: .playerStatusRowCrowded
            )
            try BattleSceneSnapshot.render(
                to: battleLogPanelOutputURL,
                fixture: .battleLogPanel
            )
            for (fixture, url) in bannerOutputURLs {
                try BattleSceneSnapshot.render(
                    to: url,
                    fixture: fixture
                )
            }
            for (fixture, url) in settlementOutputURLs {
                try BattleSceneSnapshot.render(
                    to: url,
                    fixture: fixture
                )
            }
            try BattleSceneSnapshot.render(
                to: battleTabLayoutOutputURL,
                fixedBackdropTime: 0,
                fixture: .battleTabLayout
            )
            try BattleSceneSnapshot.render(
                to: inventoryPanelOutputURL,
                fixture: .inventoryPanel
            )
            try BattleSceneSnapshot.render(
                to: characterPanelOutputURL,
                fixture: .characterPanel
            )
            try BattleSceneSnapshot.render(
                to: chestPanelOutputURL,
                fixture: .chestPanel
            )
            try BattleSceneSnapshot.render(
                to: originalFidelityPanelOutputURL,
                fixture: .originalFidelityPanel
            )
            try BattleSceneSnapshot.render(
                to: runeEvidencePanelOutputURL,
                fixture: .runeEvidencePanel
            )
            try BattleSceneSnapshot.render(
                to: skillEvidencePanelOutputURL,
                fixture: .skillEvidencePanel
            )
            try BattleSceneSnapshot.render(
                to: passiveEvidencePanelOutputURL,
                fixture: .passiveEvidencePanel
            )
            for (fixture, url) in damageOutputURLs {
                try BattleSceneSnapshot.render(
                    to: url,
                    fixedBackdropTime: 0,
                    fixture: fixture
                )
            }
            for (fixture, url) in utilityOutputURLs {
                try BattleSceneSnapshot.render(
                    to: url,
                    fixedBackdropTime: 0,
                    fixture: fixture
                )
            }
            for (fixture, url) in terminalSceneOutputURLs {
                try BattleSceneSnapshot.render(
                    to: url,
                    fixedBackdropTime: 0,
                    fixture: fixture
                )
            }
            for (fixture, url) in enemyStatusOutputURLs {
                try BattleSceneSnapshot.render(
                    to: url,
                    fixedBackdropTime: 0,
                    fixture: fixture
                )
            }
            for (fixture, url) in contactPulseOutputURLs {
                try BattleSceneSnapshot.render(
                    to: url,
                    fixedBackdropTime: 0,
                    fixture: fixture
                )
            }
            for (heroClass, url) in heroClassOutputURLs {
                try BattleSceneSnapshot.render(
                    to: url,
                    fixedBackdropTime: 0,
                    heroClass: heroClass
                )
            }
            let data = try Data(contentsOf: outputURL)
            let motionData = try Data(contentsOf: motionOutputURL)
            let statusRowData = try Data(contentsOf: statusRowOutputURL)
            let crowdedStatusRowData = try Data(contentsOf: crowdedStatusRowOutputURL)
            let battleLogPanelData = try Data(contentsOf: battleLogPanelOutputURL)
            let battleTabLayoutData = try Data(contentsOf: battleTabLayoutOutputURL)
            let inventoryPanelData = try Data(contentsOf: inventoryPanelOutputURL)
            let characterPanelData = try Data(contentsOf: characterPanelOutputURL)
            let chestPanelData = try Data(contentsOf: chestPanelOutputURL)
            let originalFidelityPanelData = try Data(contentsOf: originalFidelityPanelOutputURL)
            let runeEvidencePanelData = try Data(contentsOf: runeEvidencePanelOutputURL)
            let skillEvidencePanelData = try Data(contentsOf: skillEvidencePanelOutputURL)
            let passiveEvidencePanelData = try Data(contentsOf: passiveEvidencePanelOutputURL)
            let damageData = try damageOutputURLs.map { try Data(contentsOf: $0.1) }
            let utilityData = try utilityOutputURLs.map { try Data(contentsOf: $0.1) }
            let terminalSceneData = try terminalSceneOutputURLs.map { try Data(contentsOf: $0.1) }
            let enemyStatusData = try enemyStatusOutputURLs.map { try Data(contentsOf: $0.1) }
            let contactPulseData = try contactPulseOutputURLs.map { try Data(contentsOf: $0.1) }
            let heroClassData = try heroClassOutputURLs.map { try Data(contentsOf: $0.1) }
            let bannerData = try bannerOutputURLs.map { try Data(contentsOf: $0.1) }
            let settlementData = try settlementOutputURLs.map { try Data(contentsOf: $0.1) }
            let pngSize = pngDimensions(data: data)
            let motionPNGSize = pngDimensions(data: motionData)
            let statusRowPNGSize = pngDimensions(data: statusRowData)
            let crowdedStatusRowPNGSize = pngDimensions(data: crowdedStatusRowData)
            let battleLogPanelPNGSize = pngDimensions(data: battleLogPanelData)
            let battleTabLayoutPNGSize = pngDimensions(data: battleTabLayoutData)
            let inventoryPanelPNGSize = pngDimensions(data: inventoryPanelData)
            let characterPanelPNGSize = pngDimensions(data: characterPanelData)
            let chestPanelPNGSize = pngDimensions(data: chestPanelData)
            let originalFidelityPanelPNGSize = pngDimensions(data: originalFidelityPanelData)
            let runeEvidencePanelPNGSize = pngDimensions(data: runeEvidencePanelData)
            let skillEvidencePanelPNGSize = pngDimensions(data: skillEvidencePanelData)
            let passiveEvidencePanelPNGSize = pngDimensions(data: passiveEvidencePanelData)
            let damagePNGSizes = damageData.map(pngDimensions(data:))
            let utilityPNGSizes = utilityData.map(pngDimensions(data:))
            let terminalScenePNGSizes = terminalSceneData.map(pngDimensions(data:))
            let enemyStatusPNGSizes = enemyStatusData.map(pngDimensions(data:))
            let contactPulsePNGSizes = contactPulseData.map(pngDimensions(data:))
            let heroClassPNGSizes = heroClassData.map(pngDimensions(data:))
            let bannerPNGSizes = bannerData.map(pngDimensions(data:))
            let settlementPNGSizes = settlementData.map(pngDimensions(data:))
            let expectedScenePixelWidth = Int(BattleSceneMetrics.expectedPopoverContentWidth * 2)
            let expectedScenePixelHeight = Int(BattleSceneMetrics.compactHeight * 2)
            let expectedStatusRowPixelHeight = 56
            let expectedBattleLogPanelPixelHeight = Int(BattleLogMetrics.panelHeight * 2)
            let expectedBannerPixelHeight = 144
            let expectedSettlementPixelHeight = 640
            let expectedBattleTabLayoutPixelWidth = Int(MenuBarPopoverLayout.defaultSize.width * 2)
            let expectedBattleTabLayoutPixelHeight = Int(MenuBarPopoverLayout.defaultSize.height * 2)
            let expectedInventoryPanelPixelHeight = 1_440
            let expectedCharacterPanelPixelHeight = Int(MenuBarPopoverLayout.contentMinHeight * 2)
            let expectedChestPanelPixelHeight = 720
            let expectedOriginalFidelityPanelPixelHeight = 1_200
            let expectedRuneEvidencePanelPixelHeight = 1_240
            let expectedSkillEvidencePanelPixelHeight = 1_440
            let expectedPassiveEvidencePanelPixelHeight = 1_440
            expect(
                pngSize?.width == expectedScenePixelWidth &&
                    pngSize?.height == expectedScenePixelHeight &&
                    motionPNGSize?.width == expectedScenePixelWidth &&
                    motionPNGSize?.height == expectedScenePixelHeight &&
                    statusRowPNGSize?.width == expectedScenePixelWidth &&
                    statusRowPNGSize?.height == expectedStatusRowPixelHeight &&
                    crowdedStatusRowPNGSize?.width == expectedScenePixelWidth &&
                    crowdedStatusRowPNGSize?.height == expectedStatusRowPixelHeight &&
                    battleLogPanelPNGSize?.width == expectedScenePixelWidth &&
                    battleLogPanelPNGSize?.height == expectedBattleLogPanelPixelHeight &&
                    bannerPNGSizes.allSatisfy { $0?.width == expectedScenePixelWidth && $0?.height == expectedBannerPixelHeight } &&
                    settlementPNGSizes.allSatisfy { $0?.width == expectedScenePixelWidth && $0?.height == expectedSettlementPixelHeight } &&
                    battleTabLayoutPNGSize?.width == expectedBattleTabLayoutPixelWidth &&
                    battleTabLayoutPNGSize?.height == expectedBattleTabLayoutPixelHeight &&
                    inventoryPanelPNGSize?.width == expectedScenePixelWidth &&
                    inventoryPanelPNGSize?.height == expectedInventoryPanelPixelHeight &&
                    characterPanelPNGSize?.width == expectedScenePixelWidth &&
                    characterPanelPNGSize?.height == expectedCharacterPanelPixelHeight &&
                    chestPanelPNGSize?.width == expectedScenePixelWidth &&
                    chestPanelPNGSize?.height == expectedChestPanelPixelHeight &&
                    originalFidelityPanelPNGSize?.width == expectedScenePixelWidth &&
                    originalFidelityPanelPNGSize?.height == expectedOriginalFidelityPanelPixelHeight &&
                    runeEvidencePanelPNGSize?.width == expectedScenePixelWidth &&
                    runeEvidencePanelPNGSize?.height == expectedRuneEvidencePanelPixelHeight &&
                    skillEvidencePanelPNGSize?.width == expectedScenePixelWidth &&
                    skillEvidencePanelPNGSize?.height == expectedSkillEvidencePanelPixelHeight &&
                    passiveEvidencePanelPNGSize?.width == expectedScenePixelWidth &&
                    passiveEvidencePanelPNGSize?.height == expectedPassiveEvidencePanelPixelHeight &&
                    damagePNGSizes.allSatisfy { $0?.width == expectedScenePixelWidth && $0?.height == expectedScenePixelHeight } &&
                    utilityPNGSizes.allSatisfy { $0?.width == expectedScenePixelWidth && $0?.height == expectedScenePixelHeight } &&
                    terminalScenePNGSizes.allSatisfy { $0?.width == expectedScenePixelWidth && $0?.height == expectedScenePixelHeight } &&
                    enemyStatusPNGSizes.allSatisfy { $0?.width == expectedScenePixelWidth && $0?.height == expectedScenePixelHeight } &&
                    contactPulsePNGSizes.allSatisfy { $0?.width == expectedScenePixelWidth && $0?.height == expectedScenePixelHeight } &&
                    heroClassPNGSizes.allSatisfy { $0?.width == expectedScenePixelWidth && $0?.height == expectedScenePixelHeight } &&
                    data.count > 1_024,
                "battle scene snapshot renderer produces an audit-ready PNG"
            )
            expect(
                data != motionData,
                "battle scene snapshot renderer captures animated flame phase changes"
            )
            expect(
                damageData.allSatisfy { data != $0 } &&
                    Set(damageData).count == damageFixtures.count,
                "battle scene snapshot renderer can render distinct damage-cue fixtures"
            )
            expect(
                utilityData.allSatisfy { data != $0 } &&
                    Set(utilityData).count == utilityFixtures.count,
                "battle scene snapshot renderer can render distinct utility-cue fixtures"
            )
            expect(
                utilityFixtures.contains(.criticalFloating) &&
                    utilityFixtures.contains(.dodgeFloating) &&
                    utilityFixtures.contains(.blockFloating),
                "battle scene snapshot renderer captures critical and avoidance floating feedback fixtures"
            )
            expect(
                terminalSceneData.count == terminalSceneFixtures.count &&
                    Set(terminalSceneData).count == terminalSceneFixtures.count &&
                    terminalSceneData.allSatisfy { data != $0 && $0.count > 1_024 },
                "battle scene snapshot renderer captures victory and defeat finish-cue fixtures"
            )
            expect(
                enemyStatusData.count == enemyStatusFixtures.count &&
                    enemyStatusData.allSatisfy { data != $0 && $0.count > 1_024 },
                "battle scene snapshot renderer captures enemy status body-effect fixtures"
            )
            expect(
                contactPulseData.count == contactPulseFixtures.count &&
                    Set(contactPulseData).count == contactPulseFixtures.count &&
                    contactPulseData.allSatisfy { data != $0 && $0.count > 1_024 },
                "battle scene snapshot renderer captures hero and monster contact-pulse fixtures"
            )
            expect(
                Set(heroClassData).count == HeroClass.allCases.count,
                "battle scene snapshot renderer follows each selected main hero class"
            )
            expect(
                statusRowData != data && statusRowData.count > 512,
                "battle scene snapshot renderer captures player battle status row fixtures"
            )
            expect(
                crowdedStatusRowData != statusRowData && crowdedStatusRowData.count > 512,
                "battle scene snapshot renderer captures crowded player battle status row fixtures"
            )
            expect(
                battleLogPanelData != data && battleLogPanelData.count > 1_024,
                "battle scene snapshot renderer captures the real battle log panel fixture"
            )
            expect(
                bannerData.count == bannerFixtures.count &&
                    Set(bannerData).count == bannerFixtures.count &&
                    bannerData.allSatisfy { $0.count > 1_024 },
                "battle scene snapshot renderer captures victory reward and level-cap banner fixtures"
            )
            expect(
                settlementData.count == settlementFixtures.count &&
                    settlementData.allSatisfy { $0.count > 4_096 },
                "battle scene snapshot renderer captures the completion settlement fixture"
            )
            expect(
                battleTabLayoutData != data && battleTabLayoutData.count > 8_192,
                "battle scene snapshot renderer captures the full battle tab layout with the bottom menu bar"
            )
            expect(
                inventoryPanelData != data && inventoryPanelData.count > 8_192,
                "battle scene snapshot renderer captures the real inventory panel with source-backed icons and comparison preview"
            )
            expect(
                characterPanelData != data && characterPanelData.count > 8_192,
                "battle scene snapshot renderer captures the real character panel with hero art, party unlocks and active skill loadout"
            )
            expect(
                chestPanelData != data && chestPanelData.count > 4_096,
                "battle scene snapshot renderer captures the real chest controls with batch opening, auto-open status and source-backed chest icons"
            )
            expect(
                originalFidelityPanelData != data && originalFidelityPanelData.count > 8_192,
                "battle scene snapshot renderer captures the real original-fidelity boundary panel"
            )
            expect(
                runeEvidencePanelData != data && runeEvidencePanelData.count > 8_192,
                "battle scene snapshot renderer captures the real Rune evidence and cost review panels"
            )
            expect(
                skillEvidencePanelData != data && skillEvidencePanelData.count > 8_192,
                "battle scene snapshot renderer captures the real source skill and pending-skill review panels"
            )
            expect(
                passiveEvidencePanelData != data && passiveEvidencePanelData.count > 8_192,
                "battle scene snapshot renderer captures the real passive skill source and icon review panels"
            )
        } catch {
            expect(false, "battle scene snapshot renderer produces an audit-ready PNG: \(error.localizedDescription)")
        }

        try? FileManager.default.removeItem(at: outputURL)
        try? FileManager.default.removeItem(at: motionOutputURL)
        try? FileManager.default.removeItem(at: statusRowOutputURL)
        try? FileManager.default.removeItem(at: crowdedStatusRowOutputURL)
        try? FileManager.default.removeItem(at: battleLogPanelOutputURL)
        try? FileManager.default.removeItem(at: battleTabLayoutOutputURL)
        try? FileManager.default.removeItem(at: inventoryPanelOutputURL)
        try? FileManager.default.removeItem(at: characterPanelOutputURL)
        try? FileManager.default.removeItem(at: chestPanelOutputURL)
        try? FileManager.default.removeItem(at: originalFidelityPanelOutputURL)
        try? FileManager.default.removeItem(at: runeEvidencePanelOutputURL)
        try? FileManager.default.removeItem(at: skillEvidencePanelOutputURL)
        try? FileManager.default.removeItem(at: passiveEvidencePanelOutputURL)
        for (_, url) in damageOutputURLs {
            try? FileManager.default.removeItem(at: url)
        }
        for (_, url) in utilityOutputURLs {
            try? FileManager.default.removeItem(at: url)
        }
        for (_, url) in enemyStatusOutputURLs {
            try? FileManager.default.removeItem(at: url)
        }
        for (_, url) in contactPulseOutputURLs {
            try? FileManager.default.removeItem(at: url)
        }
        for (_, url) in heroClassOutputURLs {
            try? FileManager.default.removeItem(at: url)
        }
        for (_, url) in bannerOutputURLs {
            try? FileManager.default.removeItem(at: url)
        }
        for (_, url) in settlementOutputURLs {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private static func playerBattleStatusBadges() {
        print("[PlayerBattleStatusBadges]")

        let mappedBadges = PlayerBattleStatusBadge.visible(
            activeBuffNames: [
                "神盾领域",
                "充能陷阱",
                "弩炮塔",
                "电击弩箭电流",
                "嗜血"
            ],
            shieldRemaining: 320,
            trapCharges: 1
        )
        expect(
            mappedBadges == [
                .aegisField,
                .chargedTrap,
                .crossbowTurret,
                .shockCurrent,
                .bloodlust
            ],
            "player battle status badges map active buff names into deterministic compact icons"
        )

        let continuousBadges = PlayerBattleStatusBadge.visible(
            activeBuffNames: ["神盾领域"],
            continuousSkillNames: ["力量祝福", "守护祝福"],
            shieldRemaining: 320,
            trapCharges: 0
        )
        expect(
            continuousBadges == [.mightBlessing, .wardingBlessing, .aegisField],
            "player battle status badges expose source-checked continuous Priest blessings"
        )

        let statusRowFixtureSummary = PlayerBattleStatusBadge.summary(
            activeBuffNames: ["神盾领域", "充能陷阱"],
            continuousSkillNames: ["力量祝福", "守护祝福"],
            shieldRemaining: 320,
            trapCharges: 1
        )
        expect(
            statusRowFixtureSummary.allBadges == [.mightBlessing, .wardingBlessing, .aegisField, .chargedTrap] &&
                statusRowFixtureSummary.visibleBadges == statusRowFixtureSummary.allBadges &&
                statusRowFixtureSummary.overflowCount == 0,
            "player battle status row fixture preserves badge count and deterministic order"
        )

        let crowdedStatusSummary = PlayerBattleStatusBadge.summary(
            activeBuffNames: [
                "神盾领域",
                "神圣之刃",
                "天堂之怒",
                "烈焰九头蛇",
                "暴风雪",
                "迅捷觉醒",
                "圣域",
                "将军怒吼",
                "快速装填",
                "充能陷阱",
                "弩炮塔",
                "电击弩箭电流",
                "旋转斧",
                "嗜血"
            ],
            continuousSkillNames: ["力量祝福", "守护祝福"],
            shieldRemaining: 320,
            trapCharges: 1
        )
        expect(
            crowdedStatusSummary.allBadges == [
                .mightBlessing,
                .wardingBlessing,
                .aegisField,
                .sacredBlade,
                .wrathOfHeaven,
                .flameHydra,
                .snowstorm,
                .swiftSurge,
                .sanctuary,
                .generalsCry,
                .quickLoader,
                .chargedTrap,
                .crossbowTurret,
                .shockCurrent,
                .axeSpin,
                .bloodlust
            ] &&
                crowdedStatusSummary.visibleBadges == [
                    .mightBlessing,
                    .wardingBlessing,
                    .aegisField,
                    .sacredBlade,
                    .wrathOfHeaven
                ] &&
                crowdedStatusSummary.overflowCount == 11,
            "player battle status row keeps source blessings first and folds crowded status badges deterministically"
        )

        expect(
            PlayerBattleStatusBadge.aegisField.displayLabel(shieldRemaining: 320, trapCharges: 0) == "神盾 320" &&
                PlayerBattleStatusBadge.chargedTrap.displayLabel(shieldRemaining: 0, trapCharges: 1) == "陷阱 x1" &&
                PlayerBattleStatusBadge.mightBlessing.displayLabel(shieldRemaining: 0, trapCharges: 0) == "力量" &&
                PlayerBattleStatusBadge.wardingBlessing.displayLabel(shieldRemaining: 0, trapCharges: 0) == "守护",
            "player battle status badges expose live shield and trap counters"
        )
        expect(
            PlayerBattleStatusBadge.allCases.allSatisfy {
                NSImage(systemSymbolName: $0.systemImageName, accessibilityDescription: nil) != nil
            },
            "player battle status badges resolve visible SF Symbol artwork"
        )

        let drainedShieldBadges = PlayerBattleStatusBadge.visible(
            activeBuffNames: ["神盾领域"],
            shieldRemaining: 0,
            trapCharges: 0
        )
        let detonatedTrapBadges = PlayerBattleStatusBadge.visible(
            activeBuffNames: ["充能陷阱"],
            shieldRemaining: 0,
            trapCharges: 0
        )
        expect(
            drainedShieldBadges.isEmpty && detonatedTrapBadges.isEmpty,
            "player battle status badges hide depleted shield and spent trap states"
        )

        let aegisHero = Hero()
        let aegisMonster = Monster(
            id: "status-aegis-training",
            name: "状态神盾训练木桩",
            hp: 10_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let aegisBattle = Battle(hero: aegisHero, monster: aegisMonster, party: HeroParty(primaryClass: .knight))
        aegisBattle.update(deltaTime: 1)
        aegisBattle.update(deltaTime: 1)
        expect(
            PlayerBattleStatusBadge.visible(for: aegisBattle).contains(.aegisField),
            "Aegis Field active shield exposes a player-side battle status badge"
        )

        let turretHero = Hero()
        turretHero.changeClass(to: .hunter)
        let turretMonster = Monster(
            id: "status-turret-training",
            name: "状态炮塔训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let turretBattle = Battle(hero: turretHero, monster: turretMonster, party: HeroParty(primaryClass: .hunter))
        for _ in 0..<10 {
            turretBattle.update(deltaTime: 1)
            if PlayerBattleStatusBadge.visible(for: turretBattle).contains(.crossbowTurret) {
                break
            }
        }
        expect(
            PlayerBattleStatusBadge.visible(for: turretBattle).contains(.crossbowTurret),
            "Crossbow Turret summon exposes a player-side battle status badge"
        )

        let supportBlessingBattle = Battle(
            hero: Hero(),
            monster: Monster(
                id: "status-support-blessing-training",
                name: "状态支援祝福训练木桩",
                hp: 10_000,
                atk: 100,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            ),
            party: HeroParty(primaryClass: .knight, unlockedSlotCount: 2),
            activeSkillSlotCount: HeroSkills.maximumModeledActiveSkillSlots
        )
        let supportBlessingBadges = PlayerBattleStatusBadge.visible(for: supportBlessingBattle)
        expect(
            supportBlessingBadges.contains(.mightBlessing) &&
                supportBlessingBadges.contains(.wardingBlessing),
            "equipped support Priest continuous blessings expose player-side battle status badges"
        )
    }

    private static func playerBattleDeployables() {
        print("[PlayerBattleDeployables]")

        let deployables = PlayerBattleDeployable.visible(
            activeBuffNames: ["烈焰九头蛇", "充能陷阱", "弩炮塔"],
            trapCharges: 1
        )
        expect(
            deployables == [.flameHydra, .chargedTrap, .crossbowTurret],
            "player battle deployables map active summon and trap buffs into deterministic scene objects"
        )
        expect(
            PlayerBattleDeployable.visible(activeBuffNames: ["充能陷阱"], trapCharges: 0).isEmpty,
            "player battle deployables hide spent traps"
        )

        var trapLoadouts = ActiveSkillLoadouts()
        trapLoadouts.setSkills(["50401"], for: .hunter)
        let trapHero = Hero()
        trapHero.changeClass(to: .hunter)
        let trapMonster = Monster(
            id: "deployable-trap-training",
            name: "部署陷阱训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let trapBattle = Battle(
            hero: trapHero,
            monster: trapMonster,
            party: HeroParty(primaryClass: .hunter),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: trapLoadouts
        )
        trapBattle.update(deltaTime: 1)
        expect(
            PlayerBattleDeployable.visible(for: trapBattle).contains(.chargedTrap),
            "Charge Trap active state exposes an in-scene deployable before detonation"
        )

        var turretLoadouts = ActiveSkillLoadouts()
        turretLoadouts.setSkills(["50501"], for: .hunter)
        let turretHero = Hero()
        turretHero.changeClass(to: .hunter)
        let turretBattle = Battle(
            hero: turretHero,
            monster: trapMonster,
            party: HeroParty(primaryClass: .hunter),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: turretLoadouts
        )
        turretBattle.update(deltaTime: 1)
        expect(
            PlayerBattleDeployable.visible(for: turretBattle).contains(.crossbowTurret),
            "Crossbow Turret active state exposes an in-scene deployable"
        )

        var hydraLoadouts = ActiveSkillLoadouts()
        hydraLoadouts.setSkills(["30401"], for: .sorcerer)
        let hydraHero = Hero()
        hydraHero.changeClass(to: .sorcerer)
        let hydraBattle = Battle(
            hero: hydraHero,
            monster: trapMonster,
            party: HeroParty(primaryClass: .sorcerer),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: hydraLoadouts
        )
        hydraBattle.update(deltaTime: 1)
        expect(
            PlayerBattleDeployable.visible(for: hydraBattle).contains(.flameHydra),
            "Flame Hydra active state exposes an in-scene deployable"
        )
    }

    private static func battleLogDisplayEntries() {
        print("[BattleLogDisplay]")

        let isHeroSideEntry: (BattleLogEntry) -> Bool = { entry in
            switch entry.attacker {
            case .hero, .support:
                return true
            case .monster:
                return false
            }
        }

        var entries: [BattleLogEntry] = []
        for index in 0..<6 {
            entries.append(BattleLogEntry(
                attacker: .hero,
                damage: 10 + index,
                isCrit: false,
                skillName: index.isMultiple(of: 2) ? "劈砍" : nil,
                damageElement: .physical,
                delivery: .melee
            ))
        }
        for index in 0..<24 {
            entries.append(BattleLogEntry(
                attacker: .monster,
                damage: 3 + index,
                isCrit: false,
                damageElement: .physical,
                delivery: .melee
            ))
        }

        let visibleEntries = BattleLogDisplayEntries.visible(
            from: entries,
            limit: 12,
            minimumHeroSideEntries: 5
        )
        let visibleHeroEntries = visibleEntries.filter { entry in
            switch entry.attacker {
            case .hero, .support:
                return true
            case .monster:
                return false
            }
        }

        expect(visibleEntries.count == 12, "battle log display keeps a compact visible window")
        expect(
            visibleHeroEntries.count >= 5,
            "battle log display preserves hero-side records during monster streaks"
        )
        expect(visibleEntries.last?.id == entries.last?.id, "battle log display keeps the newest battle record visible")
        expect(
            BattleLogDisplayEntries.scrollTargetID(in: entries) == entries.last(where: { entry in
                isHeroSideEntry(entry)
            })?.id,
            "battle log display focuses the latest hero-side record when monster entries fill the visible tail"
        )

        var productionWindowEntries: [BattleLogEntry] = []
        for index in 0..<12 {
            productionWindowEntries.append(BattleLogEntry(
                attacker: index.isMultiple(of: 2) ? .hero : .support(.priest),
                damage: 20 + index,
                isCrit: false,
                skillName: index.isMultiple(of: 2) ? "劈砍" : "治愈",
                damageElement: index.isMultiple(of: 2) ? .physical : .none,
                delivery: index.isMultiple(of: 2) ? .melee : .heal
            ))
        }
        let expectedProductionHeroIDs = productionWindowEntries
            .filter(isHeroSideEntry)
            .suffix(BattleLogMetrics.minimumVisibleHeroSideEntries)
            .map(\.id)
        let latestProductionHeroID = expectedProductionHeroIDs.last
        for index in 0..<120 {
            productionWindowEntries.append(BattleLogEntry(
                attacker: .monster,
                damage: 4 + index,
                isCrit: false,
                damageElement: .physical,
                delivery: .melee,
                attackerName: "长战斗怪物 \(index)"
            ))
        }
        let productionVisibleEntries = BattleLogDisplayEntries.visible(
            from: productionWindowEntries,
            limit: BattleLogMetrics.visibleEntryLimit
        )
        let productionPresentation = BattleLogPresentation(from: productionWindowEntries)
        let productionHeroIDs = productionVisibleEntries
            .filter(isHeroSideEntry)
            .map(\.id)

        expect(
            productionVisibleEntries.count == BattleLogMetrics.visibleEntryLimit,
            "battle log display fills the default production window for long fights"
        )
        expect(
            productionHeroIDs.count >= BattleLogMetrics.minimumVisibleHeroSideEntries &&
                Array(productionHeroIDs.suffix(expectedProductionHeroIDs.count)) == expectedProductionHeroIDs,
            "battle log display preserves eight hero-side rows in the default production window"
        )
        expect(
            productionVisibleEntries.last?.id == productionWindowEntries.last?.id,
            "battle log display keeps the latest monster-side row in the default production window"
        )
        expect(
            BattleLogDisplayEntries.scrollTargetID(in: productionWindowEntries) == latestProductionHeroID,
            "battle log default production window scroll target returns to the latest hero-side row after long monster streaks"
        )
        expect(
            BattleLogDisplayEntries.scrollTargetID(in: productionVisibleEntries) == latestProductionHeroID,
            "battle log panel scroll target uses the retained hero-side row inside the visible production window"
        )
        expect(
            productionPresentation.totalCount == productionWindowEntries.count &&
                productionPresentation.visibleEntries.map(\.id) == productionVisibleEntries.map(\.id),
            "battle log presentation feeds the panel with the default retained production window"
        )

        let heroHighlights = BattleLogDisplayEntries.heroSideHighlights(from: entries, limit: 3)
        expect(
            heroHighlights.count == 3 &&
                heroHighlights.allSatisfy(isHeroSideEntry),
            "battle log display exposes a fixed hero-side highlight strip"
        )
        expect(
            heroHighlights.map(\.id) == entries.filter { entry in
                isHeroSideEntry(entry)
            }.suffix(3).map(\.id),
            "battle log hero-side highlight strip keeps the latest player-side records"
        )
        let productionHeroHighlights = BattleLogDisplayEntries.heroSideHighlights(from: productionWindowEntries)
        expect(
            productionHeroHighlights.map(\.id) == Array(expectedProductionHeroIDs.suffix(BattleLogMetrics.heroHighlightEntryLimit)),
            "battle log hero-side highlight strip survives long monster-only tails"
        )
        expect(
            productionPresentation.heroFocusEntries.map(\.id) == productionHeroHighlights.map(\.id) &&
                productionPresentation.visibleScrollTargetID == latestProductionHeroID,
            "battle log presentation preserves hero focus and scroll target for BattleLogPanel"
        )
        let namedMonsterEntry = BattleLogEntry(
            attacker: .monster,
            damage: 8,
            isCrit: false,
            attackerName: "燃烧的地狱祭司"
        )
        let genericMonsterEntry = BattleLogEntry(attacker: .monster, damage: 8, isCrit: false)
        expect(
            namedMonsterEntry.attackerDisplayName == "燃烧的地狱祭司" &&
                genericMonsterEntry.attackerDisplayName == "怪物",
            "battle log entries preserve source monster attacker names with a generic fallback"
        )
        expect(
            SkillDamageElement.none.battleLogLabel == nil &&
                SkillDamageElement.physical.battleLogLabel == "物理" &&
                SkillDamageElement.fire.battleLogLabel == "火" &&
                SkillDamageElement.cold.battleLogLabel == "冰" &&
                SkillDamageElement.lightning.battleLogLabel == "电" &&
                SkillDamageElement.chaos.battleLogLabel == "混沌",
            "battle log damage elements expose compact Chinese labels for source metadata"
        )
        let unnamedSourceMonsterEntry = BattleLogEntry(
            attacker: .monster,
            damage: 8,
            isCrit: false,
            damageElement: .fire,
            attackerName: "燃烧的地狱祭司"
        )
        expect(
            unnamedSourceMonsterEntry.skillName == nil &&
                unnamedSourceMonsterEntry.damageElement.battleLogLabel == "火",
            "unnamed source monster attacks keep visible damage-element labels"
        )
        expect(
            BattleLogActionText.displayText(
                for: BattleLogEntry(attacker: .hero, damage: 88, isCrit: false)
            ) == "造成 88 伤害" &&
                BattleLogActionText.displayText(
                    for: BattleLogEntry(attacker: .hero, damage: 25, isCrit: false, skillName: "治愈", kind: .heal)
                ) == "恢复 25 生命" &&
                BattleLogActionText.displayText(
                    for: BattleLogEntry(attacker: .support(.priest), damage: 0, isCrit: false, skillName: "守护祝福", kind: .buff)
                ) == "触发增益",
            "battle log action text keeps damage, healing and buff rows deterministic"
        )
        expect(
            BattleLogActionText.displayText(
                for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .dodge)
            ) == "攻击被闪避" &&
                BattleLogActionText.displayText(
                    for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .block)
                ) == "攻击被格挡" &&
                BattleLogActionText.displayText(
                    for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, kind: .dodge)
                ) == "闪避了攻击" &&
                BattleLogActionText.criticalText(
                    for: BattleLogEntry(attacker: .monster, damage: 30, isCrit: true)
                ) == "暴击!",
            "battle log action text disambiguates incoming dodge, block and critical rows"
        )
        expect(
            BattleFloatingDamageText.displayText(
                for: BattleLogEntry(attacker: .monster, damage: 123, isCrit: true, attackerName: "骷髅弓手")
            ) == "暴击 123" &&
                BattleFloatingDamageText.displayText(
                    for: BattleLogEntry(attacker: .hero, damage: 456, isCrit: true, skillName: "爆炸弩箭")
                ) == "爆炸弩箭 暴击 456" &&
                BattleFloatingDamageText.displayText(
                    for: BattleLogEntry(attacker: .monster, damage: 123, isCrit: false)
                ) == "123",
            "floating battle damage text localizes critical hits as visible Chinese battle feedback"
        )
        expect(
            BattleFloatingDamageText.displayText(
                for: BattleLogEntry(attacker: .hero, damage: 25, isCrit: false, skillName: nil, kind: .heal)
            ) == "治疗 +25" &&
                BattleFloatingDamageText.displayText(
                    for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "神盾领域", kind: .buff)
                ) == "神盾领域" &&
                BattleFloatingDamageText.displayText(
                    for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .dodge)
                ) == "闪避!" &&
                BattleFloatingDamageText.displayText(
                    for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .block)
                ) == "格挡!",
            "floating battle text keeps heal, buff, dodge and block feedback explicit in the battle lane"
        )
        let ordinaryFloatingStyle = BattleFloatingDamageStyle.presentation(
            for: BattleLogEntry(attacker: .hero, damage: 80, isCrit: false, damageElement: .physical)
        )
        let criticalFloatingStyle = BattleFloatingDamageStyle.presentation(
            for: BattleLogEntry(attacker: .hero, damage: 160, isCrit: true, damageElement: .physical)
        )
        expect(
            ordinaryFloatingStyle.tone == .damage &&
                criticalFloatingStyle.tone == .criticalDamage &&
                criticalFloatingStyle.fontSize > ordinaryFloatingStyle.fontSize &&
                criticalFloatingStyle.borderOpacity > ordinaryFloatingStyle.borderOpacity &&
                criticalFloatingStyle.shadowRadius > ordinaryFloatingStyle.shadowRadius &&
                criticalFloatingStyle.verticalOffset < ordinaryFloatingStyle.verticalOffset,
            "floating battle text style makes critical hits visually stronger than ordinary physical hits"
        )
        let dodgeFloatingStyle = BattleFloatingDamageStyle.presentation(
            for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .dodge)
        )
        let blockFloatingStyle = BattleFloatingDamageStyle.presentation(
            for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .block)
        )
        let healFloatingStyle = BattleFloatingDamageStyle.presentation(
            for: BattleLogEntry(attacker: .hero, damage: 25, isCrit: false, kind: .heal)
        )
        expect(
            dodgeFloatingStyle.tone == .dodge &&
                blockFloatingStyle.tone == .block &&
                healFloatingStyle.tone == .heal &&
                dodgeFloatingStyle.fontSize > ordinaryFloatingStyle.fontSize &&
                blockFloatingStyle.fontSize > ordinaryFloatingStyle.fontSize &&
                dodgeFloatingStyle.borderOpacity >= healFloatingStyle.borderOpacity &&
                blockFloatingStyle.borderOpacity >= healFloatingStyle.borderOpacity,
            "floating battle text style keeps dodge and block feedback readable in the battle lane"
        )
    }

    private static func battleResultRewardPresentation() {
        print("[BattleResultRewardPresentation]")

        let primaryLoot = Item(
            id: "reward-scepter",
            name: "源力权杖",
            rarity: .rare,
            slot: .weapon,
            stats: ItemStats(bonusATK: 12),
            description: "checked source progression fixture",
            itemLevel: 12,
            equipmentType: .scepter
        )
        let extraLoot = Item(
            id: "reward-ring",
            name: "源力戒指",
            rarity: .uncommon,
            slot: .ring,
            stats: ItemStats(bonusHP: 8),
            description: "checked source progression fixture",
            itemLevel: 8,
            equipmentType: .ring
        )
        let rewards = BattleResult.Rewards(
            xp: 12,
            gold: 34,
            lootItems: [primaryLoot, extraLoot],
            encountersCleared: 2
        )
        let presentation = BattleRewardLootPresentation.make(from: rewards)
        expect(
            presentation?.displayText == "源力权杖 +1" &&
                presentation?.accessibilityText == "源力权杖 +1" &&
                presentation?.iconName == SourceItemCatalog.progression(for: .scepter, itemLevel: 12)?.iconName &&
                presentation?.iconName == "source_gear_330003" &&
                presentation?.rarityColor == Rarity.rare.color,
            "victory reward banner uses source-backed loot icon presentation"
        )
        expect(
            BattleRewardLootPresentation.make(from: BattleResult.Rewards(xp: 1, gold: 1, lootItem: nil)) == nil,
            "victory reward banner hides loot presentation when no item drops"
        )

        let capProgress = ProgressTracker()
        let cappedHero = Hero()
        cappedHero.level = HeroLevelPacing.maxHeroLevel(for: capProgress)
        cappedHero.currentXP = cappedHero.xpForNextLevel() - 1
        let cappedPresentation = BattleVictoryRewardPresentation(
            sourceRewards: BattleResult.Rewards(xp: 100, gold: 12, lootItem: nil),
            displayedRewards: BattleResult.Rewards(xp: 0, gold: 12, lootItem: nil),
            levelCapStatus: HeroLevelPacing.levelCapStatus(for: cappedHero, progress: capProgress)
        )
        expect(
            cappedPresentation.summaryText == "胜利! +0XP +12G" &&
                cappedPresentation.levelCapXPStopText == BattleVictoryRewardPresentation.levelCapXPStopMessage &&
                cappedPresentation.xpDetailText == BattleVictoryRewardPresentation.levelCapXPStopMessage &&
                cappedPresentation.xpDetailIsWarning,
            "victory reward banner exposes local level-cap XP stop"
        )

        let pacedPresentation = BattleVictoryRewardPresentation(
            sourceRewards: BattleResult.Rewards(xp: 100, gold: 12, lootItem: nil),
            displayedRewards: BattleResult.Rewards(xp: 35, gold: 12, lootItem: nil),
            levelCapStatus: HeroLevelPacing.levelCapStatus(for: Hero(), progress: capProgress)
        )
        expect(
            pacedPresentation.levelCapXPStopText == nil &&
                pacedPresentation.xpAdjustmentText == "XP实得 100->35" &&
                pacedPresentation.goldAdjustmentText == nil &&
                pacedPresentation.rewardDetailText == "XP实得 100->35" &&
                pacedPresentation.xpDetailText == "XP实得 100->35" &&
                !pacedPresentation.rewardDetailIsWarning &&
                !pacedPresentation.xpDetailIsWarning,
            "victory reward banner exposes local applied XP when pacing changes the source reward"
        )

        let boostedRewardPresentation = BattleVictoryRewardPresentation(
            sourceRewards: BattleResult.Rewards(xp: 100, gold: 100, lootItem: nil, encountersCleared: 3),
            displayedRewards: BattleResult.Rewards(xp: 35, gold: 120, lootItem: nil, encountersCleared: 3),
            levelCapStatus: HeroLevelPacing.levelCapStatus(for: Hero(), progress: capProgress)
        )
        expect(
            boostedRewardPresentation.encounterClearText == "清理 x3" &&
                boostedRewardPresentation.xpAdjustmentText == "XP实得 100->35" &&
                boostedRewardPresentation.goldAdjustmentText == "金币实得 100->120" &&
                boostedRewardPresentation.rewardDetailText == "清理 x3 · XP实得 100->35 · 金币实得 100->120" &&
                !boostedRewardPresentation.rewardDetailIsWarning,
            "victory reward banner exposes multi-encounter reward context and local applied gold"
        )

        let multiEncounterPresentation = BattleVictoryRewardPresentation(
            sourceRewards: BattleResult.Rewards(xp: 35, gold: 12, lootItem: nil, encountersCleared: 2),
            displayedRewards: BattleResult.Rewards(xp: 35, gold: 12, lootItem: nil, encountersCleared: 2),
            levelCapStatus: HeroLevelPacing.levelCapStatus(for: Hero(), progress: capProgress)
        )
        expect(
            multiEncounterPresentation.encounterClearText == "清理 x2" &&
                multiEncounterPresentation.rewardDetailText == "清理 x2",
            "victory reward banner exposes multi-encounter context even when reward values are unchanged"
        )

        let unchangedPresentation = BattleVictoryRewardPresentation(
            sourceRewards: BattleResult.Rewards(xp: 35, gold: 12, lootItem: nil),
            displayedRewards: BattleResult.Rewards(xp: 35, gold: 12, lootItem: nil),
            levelCapStatus: HeroLevelPacing.levelCapStatus(for: Hero(), progress: capProgress)
        )
        expect(
            unchangedPresentation.rewardDetailText == nil &&
                unchangedPresentation.xpDetailText == nil,
            "victory reward banner hides reward adjustment detail when displayed rewards are unchanged"
        )
    }

    private static func battleImpactCues() {
        print("[BattleImpactCues]")

        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "穿透突刺")
            ) == .physicalSlash,
            "physical damaging skills expose a slash impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "粉碎强击")
            ) == .physicalSlash,
            "Crushing Blow's primary hit keeps the ordinary physical impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "粉碎强击冲击波")
            ) == .shockwaveImpact,
            "Crushing Blow's kill rider exposes a dedicated shockwave impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "大地强击")
            ) == .earthquakeImpact,
            "Ground Slam exposes a dedicated earthquake impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "大地强击岩石爆炸")
            ) == .earthquakeRockExplosion,
            "Ground Slam rock explosion exposes a dedicated rock impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "旋转斧")
            ) == .axeSpinImpact,
            "Axe Spin exposes a dedicated spinning impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "旋转斧流血追击")
            ) == .bleedRendImpact,
            "Axe Spin bleed follow-up exposes a dedicated rend impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "火球术")
            ) == .fireBurst,
            "fire damaging skills expose a fire impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "爆炸弩箭")
            ) == .explosiveBoltImpact,
            "Explosive Bolt exposes a dedicated explosion impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "陨石打击")
            ) == .meteorImpact,
            "Meteor Strike exposes a dedicated meteor impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(
                    attacker: .hero,
                    damage: 100,
                    isCrit: false,
                    damageElement: .cold,
                    delivery: .projectile
                )
            ) == .coldBurst,
            "cold projectile metadata exposes a cold impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "寒霜弩箭")
            ) == .frostBoltImpact,
            "Frost Bolt exposes a dedicated cold explosion impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "闪电术")
            ) == .lightningSpark,
            "lightning damaging skills expose a lightning impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "电击弩箭")
            ) == .shockBoltImpact,
            "Shock Bolt exposes a dedicated lodged-bolt impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "电击弩箭电流")
            ) == .shockCurrentImpact,
            "Shock Bolt's current rider exposes a dedicated current impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(
                    attacker: .hero,
                    damage: 100,
                    isCrit: false,
                    damageElement: .chaos,
                    delivery: .range
                )
            ) == .chaosBurst,
            "source chaos damage metadata exposes a chaos impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(
                    attacker: .hero,
                    damage: 100,
                    isCrit: false,
                    skillName: "充能陷阱",
                    damageElement: .physical,
                    delivery: .trap
                )
            ) == .trapBurst,
            "trap damage exposes a trap impact cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "烈焰九头蛇")
            ) == .summonProjectile,
            "summon projectile damage exposes a summon projectile cue"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false)
            ) == nil,
            "monster attacks do not render player skill impact cues"
        )
        expect(
            BattleImpactCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "治愈", kind: .heal)
            ) == nil,
            "healing entries do not render damage impact cues"
        )
    }

    private static func battleIncomingCues() {
        print("[BattleIncomingCues]")

        expect(
            BattleIncomingCue.visible(
                for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false)
            ) == .physical,
            "generic monster damage exposes a separate physical incoming cue"
        )
        expect(
            BattleIncomingCue.visible(
                for: BattleLogEntry(
                    attacker: .monster,
                    damage: 100,
                    isCrit: false,
                    damageElement: .fire
                )
            ) == .fire &&
                BattleIncomingCue.visible(
                    for: BattleLogEntry(
                        attacker: .monster,
                        damage: 100,
                        isCrit: false,
                        damageElement: .cold
                    )
                ) == .cold &&
                BattleIncomingCue.visible(
                    for: BattleLogEntry(
                        attacker: .monster,
                        damage: 100,
                        isCrit: false,
                        damageElement: .lightning
                    )
                ) == .lightning &&
                BattleIncomingCue.visible(
                    for: BattleLogEntry(
                        attacker: .monster,
                        damage: 100,
                        isCrit: false,
                        damageElement: .chaos
                    )
                ) == .chaos,
            "source monster attack elements expose distinct incoming cues"
        )
        expect(
            BattleIncomingCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "火球术")
            ) == nil &&
                BattleIncomingCue.visible(
                    for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, damageElement: .fire)
                ) == nil &&
                BattleIncomingCue.visible(
                    for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false, skillName: "治愈", kind: .heal)
                ) == nil,
            "incoming cues stay limited to damaging monster hits"
        )
    }

    private static func battleTrajectoryCues() {
        print("[BattleTrajectoryCues]")

        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(
                    attacker: .hero,
                    damage: 100,
                    isCrit: false,
                    damageElement: .physical,
                    delivery: .projectile
                )
            ) == .projectile,
            "projectile metadata exposes a generic projectile trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "快速射击")
            ) == .rapidVolley,
            "Rapid Fire exposes a dedicated multi-arrow volley trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "散弹射击")
            ) == .trackingVolley,
            "Scatter Shot exposes a dedicated tracking-volley trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "箭雨")
            ) == .arrowRain,
            "Arrow Rain exposes a dedicated falling-arrow trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "穿透之箭")
            ) == .piercingArrow,
            "Piercing Arrow exposes a dedicated piercing trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "穿刺射击")
            ) == .lodgedArrow,
            "Skewer Shot exposes a dedicated lodged-arrow trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "爆炸弩箭")
            ) == .explosiveBolt,
            "Explosive Bolt exposes a dedicated explosive-bolt trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "寒霜弩箭")
            ) == .frostBolt,
            "Frost Bolt exposes a dedicated frost-bolt trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "电击弩箭")
            ) == .shockBolt,
            "Shock Bolt exposes a dedicated shock-bolt trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "电击弩箭电流")
            ) == .shockCurrentArc,
            "Shock Bolt's current rider exposes a dedicated current-arc trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "暴风雪")
            ) == .rangeField,
            "range damage entries expose a range-field trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "大地强击")
            ) == .groundRupture,
            "Ground Slam exposes a dedicated ground-rupture trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "大地强击岩石爆炸")
            ) == .rockBurst,
            "Ground Slam rock explosion exposes a dedicated rock-burst trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "粉碎强击冲击波")
            ) == .shockwaveRing,
            "Crushing Blow's kill rider exposes a dedicated shockwave trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "陨石打击")
            ) == .meteorFall,
            "Meteor Strike exposes a dedicated falling meteor trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "旋转斧")
            ) == .axeSpinArc,
            "Axe Spin exposes a dedicated spinning trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "旋转斧流血追击")
            ) == .bleedRendTrail,
            "Axe Spin bleed follow-up exposes a dedicated rend trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "烈焰九头蛇")
            ) == .summonProjectile,
            "summon projectile damage entries expose a summon trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(
                    attacker: .hero,
                    damage: 100,
                    isCrit: false,
                    skillName: "充能陷阱",
                    damageElement: .physical,
                    delivery: .trap
                )
            ) == .trapArc,
            "trap damage entries expose a trap arc trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "盾牌冲锋")
            ) == .chargeDash,
            "Shield Charge exposes a dedicated charge trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "猛击跳跃")
            ) == .leapArc,
            "Slam Jump exposes a dedicated leap trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "穿透突刺")
            ) == .meleeArc,
            "ordinary melee damage entries expose a short melee arc without using movement trajectories"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "粉碎强击")
            ) == .meleeArc,
            "Crushing Blow's primary melee hit renders the local melee arc instead of the shockwave trajectory cue"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false)
            ) == nil,
            "monster attacks do not render player trajectory cues"
        )
    }

    private static func battleUtilityCues() {
        print("[BattleUtilityCues]")

        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "治愈", kind: .heal)
            ) == .healPulse,
            "Heal exposes a dedicated utility cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 300, isCrit: false, skillName: "圣域", kind: .heal)
            ) == .sanctuaryPulse,
            "Sanctuary healing exposes a dedicated utility cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 300, isCrit: false, skillName: "复活", kind: .heal)
            ) == .resurrectionRise,
            "Resurrection exposes a dedicated utility cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 500, isCrit: false, skillName: "不屈意志", kind: .heal)
            ) == .resurrectionRise,
            "Unyielding Will's self-stand-up log reuses the resurrection cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "神盾领域", kind: .buff)
            ) == .shieldField,
            "Aegis Field exposes a dedicated shield utility cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "天堂之怒", kind: .buff)
            ) == .wrathOfHeavenStorm,
            "Wrath of Heaven exposes a dedicated lightning utility cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "神圣之刃", kind: .buff)
            ) == .sacredBladeGlow,
            "Sacred Blade exposes a dedicated utility cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "迅捷觉醒", kind: .buff)
            ) == .swiftSurgeHaste,
            "Swift Surge exposes a dedicated haste utility cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "快速装填", kind: .buff)
            ) == .quickLoaderHaste,
            "Quick Loader exposes a dedicated reload-haste utility cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "将军怒吼", kind: .buff)
            ) == .generalsCryRoar,
            "General's Cry exposes a dedicated roar utility cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "嗜血", kind: .buff)
            ) == .bloodlustSurge,
            "Bloodlust exposes a dedicated surge utility cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "力量祝福", kind: .buff)
            ) == .buffAura,
            "other buff entries expose a generic utility aura"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "火球术")
            ) == nil,
            "damage entries do not render utility cues"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false)
            ) == nil,
            "monster entries do not render player utility cues"
        )
    }

    private static func pngDimensions(data: Data) -> (width: Int, height: Int)? {
        let signature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        guard data.count >= 24 else { return nil }
        guard Array(data.prefix(signature.count)) == signature else { return nil }

        func readInt32(at offset: Int) -> Int {
            data[offset..<offset + 4].reduce(0) { partial, byte in
                (partial << 8) + Int(byte)
            }
        }

        return (readInt32(at: 16), readInt32(at: 20))
    }

    private static func heroClasses() {
        print("[HeroClass]")
        expect(HeroClass.allCases.count == 6, "six original hero classes are available")
        expect(HeroClass.allCases.allSatisfy { !$0.role.isEmpty && !$0.grade.isEmpty }, "hero classes expose role and grade metadata")

        let legacy = try? JSONDecoder().decode(HeroClass.self, from: Data(#""战士""#.utf8))
        expect(legacy == .knight, "legacy 战士 save value decodes as knight")

        let hero = Hero()
        expect(hero.heroClass == .knight, "new hero defaults to knight")
        expect(hero.maxHP == hero.heroClass.baseStats.hp, "level 1 HP matches base stats")
        hero.changeClass(to: .ranger)
        expect(hero.heroClass == .ranger, "hero can switch to ranger")
        expect(hero.currentHP == hero.maxHP, "full-health class switch keeps hero at new max HP")
        hero.takeDamage(hero.currentHP + 100)
        let revived = hero.revive(withHP: hero.maxHP * 3)
        let cappedHeal = hero.heal(999)
        expect(revived == hero.maxHP * 3 && hero.currentHP == hero.maxHP * 3 && cappedHeal == 0, "revive can restore above max HP without heal clamping it down")

        let pacedHero = Hero()
        let pacedProgress = ProgressTracker()
        let pacedLevelCapBreakdown = HeroLevelPacing.levelCapBreakdown(for: pacedProgress)
        let pacedMaxLevel = HeroLevelPacing.maxHeroLevel(for: pacedProgress)
        let pacedXP = HeroLevelPacing.grantXP(1_000_000, to: pacedHero, maxLevel: pacedMaxLevel)
        expect(
            GamePacing.runtimeTickInterval == 1.0 &&
                GamePacing.combatSimulationStep == 1.0 &&
                GamePacing.combatDeltaMultiplier == 1.0 &&
                abs(GamePacing.simulatedCombatDelta(for: GamePacing.runtimeTickInterval) - 1.0) < 0.0001 &&
                GamePacing.appliedXPMultiplier == 0.35 &&
                GamePacing.minimumAttackInterval == 1.0 &&
                GamePacing.minimumHastedAttackInterval == 1.0 &&
                pacedMaxLevel == 3 &&
                pacedXP < 1_000_000 &&
                pacedHero.level == pacedMaxLevel &&
                pacedHero.currentXP == pacedHero.xpForNextLevel() - 1,
            "hero XP gain and combat simulation are slowed and capped by current campaign progress to prevent runaway levels"
        )
        expect(
            pacedLevelCapBreakdown.stageLevel == 1 &&
                pacedLevelCapBreakdown.stageLevelBuffer == 2 &&
                pacedLevelCapBreakdown.completedPlaythroughCycles == 0 &&
                pacedLevelCapBreakdown.playthroughBonusPerCycle == 15 &&
                pacedLevelCapBreakdown.playthroughBonus == 0 &&
                pacedLevelCapBreakdown.maxLevel == 3 &&
                pacedLevelCapBreakdown.formulaText == "Lv.1 + 2 + 0 = Lv.3",
            "hero level cap breakdown exposes stage, buffer and new-game-plus components"
        )
        let freshLevelCapStatus = HeroLevelPacing.levelCapStatus(for: Hero(), progress: pacedProgress)
        expect(
            freshLevelCapStatus.heroLevel == 1 &&
                freshLevelCapStatus.maxLevel == 3 &&
                freshLevelCapStatus.levelText == "Lv.1/3" &&
                freshLevelCapStatus.statusText == "可升级" &&
                freshLevelCapStatus.nextLevelXPRemaining == Hero.xpForNextLevel(at: 1) &&
                freshLevelCapStatus.xpSpaceText == "下级 100 XP" &&
                freshLevelCapStatus.canLevelUp &&
                !freshLevelCapStatus.isAtLevelCap &&
                !freshLevelCapStatus.needsNormalization,
            "hero level cap status exposes remaining upgrade headroom before the local cap"
        )
        let pacedLevelCapStatus = HeroLevelPacing.levelCapStatus(for: pacedHero, progress: pacedProgress)
        expect(
            pacedLevelCapStatus.heroLevel == 3 &&
                pacedLevelCapStatus.maxLevel == 3 &&
                pacedLevelCapStatus.currentXP == pacedHero.xpForNextLevel() - 1 &&
                pacedLevelCapStatus.maxCurrentXP == pacedHero.xpForNextLevel() - 1 &&
                pacedLevelCapStatus.levelText == "Lv.3/3" &&
                pacedLevelCapStatus.statusText == "已达上限" &&
                pacedLevelCapStatus.nextLevelXPRemaining == 0 &&
                pacedLevelCapStatus.xpSpaceText == "升级停止" &&
                pacedLevelCapStatus.isAtLevelCap &&
                !pacedLevelCapStatus.canLevelUp &&
                !pacedLevelCapStatus.needsNormalization,
            "hero level cap status exposes the current save state against the local cap"
        )
        let staleLevelCapHero = Hero()
        staleLevelCapHero.level = 999
        staleLevelCapHero.currentXP = -5
        let staleLevelCapStatus = HeroLevelPacing.levelCapStatus(for: staleLevelCapHero, progress: pacedProgress)
        expect(
            staleLevelCapStatus.heroLevel == 999 &&
                staleLevelCapStatus.maxLevel == 3 &&
                staleLevelCapStatus.statusText == "需修正" &&
                staleLevelCapStatus.xpSpaceText == "修正后重算" &&
                staleLevelCapStatus.needsNormalization,
            "hero level cap status flags stale or test save values before normalization"
        )
        let lowXPCheckHero = Hero()
        let lowAppliedXP = HeroLevelPacing.grantXP(100, to: lowXPCheckHero, maxLevel: 10)
        expect(
            lowAppliedXP == 35 &&
                GamePacing.pacedXP(from: 1) == 1 &&
                lowXPCheckHero.currentXP == 35 &&
                lowXPCheckHero.level == 1,
            "hero XP gain applies the local runtime pacing multiplier before leveling"
        )
        let previewHero = Hero()
        let previewXP = HeroLevelPacing.previewGrantedXP(100, for: previewHero, maxLevel: 10)
        expect(
            previewXP == 35 &&
                previewHero.currentXP == 0 &&
                previewHero.level == 1,
            "hero XP preview uses the runtime pacing multiplier without mutating hero state"
        )
        let firstRuntimeXP = StageDefinition.stage(act: .forest, number: 1).runtimeData(for: .normal).xpReward
        expect(
            firstRuntimeXP == 155 &&
                GamePacing.pacedXP(from: firstRuntimeXP) == 54,
            "settings stage source rows can preview applied XP from raw mined XP"
        )

        var newGamePlusProgress = ProgressTracker()
        newGamePlusProgress.currentDifficultyIndex = Difficulty.allCases.count - 1
        newGamePlusProgress.currentChapterIndex = Chapter.allCases.count - 1
        newGamePlusProgress.currentStageIndex = StageDefinition.stagesPerAct - 1
        newGamePlusProgress.playthrough = 3
        let newGamePlusCapBreakdown = HeroLevelPacing.levelCapBreakdown(for: newGamePlusProgress)
        expect(
            newGamePlusCapBreakdown.stageLevel == 95 &&
                newGamePlusCapBreakdown.stageLevelBuffer == 2 &&
                newGamePlusCapBreakdown.completedPlaythroughCycles == 2 &&
                newGamePlusCapBreakdown.playthroughBonusPerCycle == 15 &&
                newGamePlusCapBreakdown.playthroughBonus == 30 &&
                newGamePlusCapBreakdown.maxLevel == 127 &&
                HeroLevelPacing.maxHeroLevel(for: newGamePlusProgress) == 127,
            "hero level cap keeps bounded new-game-plus headroom"
        )
    }

    private static func settingsFidelityBoundaries() {
        print("[OriginalFidelityBoundary]")

        let hardGapRows = Dictionary(
            uniqueKeysWithValues: OriginalFidelityBoundaryMetrics.hardGapRows.map {
                ($0.key, $0)
            }
        )

        expect(
            OriginalFidelityBoundaryMetrics.runtimeSkillCoverageText == "46/106" &&
                OriginalFidelityBoundaryMetrics.runtimeModeledSourceSkillCount == 46 &&
                OriginalFidelityBoundaryMetrics.totalSourceSkillCount == 106 &&
                OriginalFidelityBoundaryMetrics.pendingSourceSkillCount == 60 &&
                OriginalFidelityBoundaryMetrics.sourceRuneCoverageText == "197/197",
            "settings fidelity boundary summary exposes runtime skill coverage without hiding source Rune coverage"
        )
        expect(
            OriginalFidelityBoundaryMetrics.hardGapRowCount == 7 &&
                Set(hardGapRows.keys) == Set([
                    "skill-runtime-evidence",
                    "rune-cost-economy",
                    "original-pacing-xp-curve",
                    "exact-item-records",
                    "source-monster-runtime-art",
                    "original-action-frames",
                    "isolated-original-sfx"
                ]),
            "settings fidelity boundary exposes the current hard blockers as a compact review queue"
        )
        expect(
            hardGapRows["skill-runtime-evidence"]?.currentEvidence.contains("60 个源技能") == true &&
                hardGapRows["skill-runtime-evidence"]?.currentEvidence.contains("0 个达到最小证据候选") == true &&
                hardGapRows["rune-cost-economy"]?.currentEvidence.contains("194 个节点待核价") == true &&
                hardGapRows["rune-cost-economy"]?.currentEvidence.contains("7 个成本队列") == true &&
                hardGapRows["original-pacing-xp-curve"]?.currentEvidence.contains("原作 Tick 1.0s") == true &&
                hardGapRows["original-pacing-xp-curve"]?.currentEvidence.contains("战斗推进 1.0s") == true &&
                hardGapRows["original-pacing-xp-curve"]?.currentEvidence.contains("XP 35%") == true &&
                hardGapRows["exact-item-records"]?.currentEvidence.contains("0/5760") == true,
            "settings fidelity boundary hard blocker queue preserves skill, Rune, pacing and exact-item gap counts"
        )
        expect(
            hardGapRows["source-monster-runtime-art"]?.currentEvidence.contains("3 个源表怪物") == true &&
                hardGapRows["source-monster-runtime-art"]?.currentEvidence.contains("剧毒领主") == true &&
                hardGapRows["source-monster-runtime-art"]?.currentEvidence.contains("扁虱") == true &&
                hardGapRows["source-monster-runtime-art"]?.currentEvidence.contains("雪山法师") == true &&
                hardGapRows["original-action-frames"]?.currentEvidence.contains("0 组") == true &&
                hardGapRows["isolated-original-sfx"]?.currentEvidence.contains("0 条") == true,
            "settings fidelity boundary hard blocker queue preserves monster, animation and SFX gap counts"
        )
        expect(
            hardGapRows.values.allSatisfy {
                $0.requiredProof.count > 12 &&
                    $0.boundary.contains("不")
            } &&
                hardGapRows["skill-runtime-evidence"]?.boundary.contains("不按 value") == true &&
                hardGapRows["rune-cost-economy"]?.boundary.contains("不按图标组") == true &&
                hardGapRows["original-pacing-xp-curve"]?.boundary.contains("GamePacing") == true &&
                hardGapRows["source-monster-runtime-art"]?.boundary.contains("不按单张 sprite") == true &&
                hardGapRows["original-action-frames"]?.boundary.contains("不按本地替代动效") == true &&
                hardGapRows["isolated-original-sfx"]?.boundary.contains("generated_substitute") == true,
            "settings fidelity boundary hard blocker queue keeps evidence boundaries from fabricating original parity"
        )
        expect(
            OriginalFidelityBoundaryMetrics.skillEffectBoundaryText.contains("60 个源技能") &&
                OriginalFidelityBoundaryMetrics.skillEffectBoundaryText.contains("动作帧") &&
                OriginalFidelityBoundaryMetrics.skillEffectBoundaryText.contains("触发时序") &&
                OriginalFidelityBoundaryMetrics.skillEffectBoundaryText.contains("原声音效"),
            "settings fidelity boundary keeps local skill VFX and SFX separate from original per-skill parity"
        )
        expect(
            OriginalFidelityBoundaryMetrics.pendingSkillReadinessText == "15 value / 15 未命名 / 15 空形态" &&
                OriginalFidelityBoundaryMetrics.pendingSkillRuntimeBoundaryText.contains("60 个源技能") &&
                OriginalFidelityBoundaryMetrics.pendingSkillRuntimeBoundaryText.contains("数据态") &&
                OriginalFidelityBoundaryMetrics.pendingSkillRuntimeBoundaryText.contains("Skill ID"),
            "settings fidelity boundary exposes value-checked pending skills without promoting them to runtime"
        )
        expect(
            OriginalFidelityBoundaryMetrics.pendingSkillRuntimeBoundaryText.contains("不证明本地化名称") &&
                OriginalFidelityBoundaryMetrics.pendingSkillRuntimeBoundaryText.contains("delivery") &&
                OriginalFidelityBoundaryMetrics.pendingSkillRuntimeBoundaryText.contains("目标") &&
                OriginalFidelityBoundaryMetrics.pendingSkillRuntimeBoundaryText.contains("持续时间"),
            "settings fidelity boundary keeps pending source skill value pages from implying combat semantics"
        )
        expect(
            OriginalFidelityBoundaryMetrics.exactItemRecordCoverageText == "0/5760" &&
                OriginalFidelityBoundaryMetrics.sourceGearProgressionCoverageText == "396/396",
            "settings fidelity boundary distinguishes exact item-record gaps from source gear progression icons"
        )
        expect(
            OriginalFidelityBoundaryMetrics.passiveSkillSourceCoverageText == "108/108" &&
                OriginalFidelityBoundaryMetrics.passiveSkillSourceIconCoverageText == "104/108" &&
                OriginalFidelityBoundaryMetrics.passiveSkillBoundaryText.contains("IncreaseProjectileDamage") &&
                OriginalFidelityBoundaryMetrics.passiveSkillBoundaryText.contains("SkillHealIncrease") &&
                OriginalFidelityBoundaryMetrics.passiveSkillBoundaryText.contains("原版解锁路径"),
            "settings fidelity boundary exposes passive source and icon coverage without hiding unlock gaps"
        )
        expect(
            OriginalFidelityBoundaryMetrics.battleHeroSpriteCoverageText == "6/6" &&
                OriginalFidelityBoundaryMetrics.battleHeroSourceSpriteCoverageText == "6/6",
            "settings fidelity boundary exposes battle hero sprite coverage without hiding animation gaps"
        )
        expect(
            OriginalFidelityBoundaryMetrics.battleHeroSpriteBoundaryText.contains("动作帧仍待核对"),
            "settings fidelity boundary keeps battle hero sprite provenance separate from original animation parity"
        )
        expect(
            OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseCoverageText == "61/61" &&
                OriginalFidelityBoundaryMetrics.sourceMonsterStageCompositionCoverageText == "49/49",
            "settings fidelity boundary exposes source monster stat rows separately from monster art coverage"
        )
        expect(
            OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseBoundaryText.contains("基础 ATK/攻速标量") &&
                OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseBoundaryText.contains("HP/金币/经验仍以关卡表为准") &&
                OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseBoundaryText.contains("3 个源怪物") &&
                OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseBoundaryText.contains("未进入当前关卡组成/美术映射") &&
                OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseBoundaryText.contains("剧毒领主") &&
                OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseBoundaryText.contains("扁虱") &&
                OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseBoundaryText.contains("雪山法师") &&
                OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseBoundaryText.contains("怪物技能") &&
                OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseBoundaryText.contains("动作帧") &&
                OriginalFidelityBoundaryMetrics.sourceMonsterDatabaseBoundaryText.contains("不绘制新怪物图"),
            "settings fidelity boundary keeps monster stat data from implying full monster art or skill parity"
        )
        expect(
            OriginalFidelityBoundaryMetrics.stageMonsterArtCoverageText == "49/52" &&
                OriginalFidelityBoundaryMetrics.stageMonsterSourceRosterArtGapCount == 3,
            "settings fidelity boundary exposes checked monster art coverage without hiding the source roster art gap"
        )
        expect(
            OriginalFidelityBoundaryMetrics.stageMonsterArtBoundaryText.contains("源表去重怪物名") &&
                OriginalFidelityBoundaryMetrics.stageMonsterArtBoundaryText.contains("Steam 50+ 下限") &&
                OriginalFidelityBoundaryMetrics.stageMonsterArtBoundaryText.contains("源表未映射怪物") &&
                OriginalFidelityBoundaryMetrics.stageMonsterArtBoundaryText.contains("动作帧"),
            "settings fidelity boundary keeps monster art mappings separate from full original roster parity"
        )
        expect(
            OriginalFidelityBoundaryMetrics.verifiedRuneCostCount == 2 &&
                OriginalFidelityBoundaryMetrics.approximateRuneCostCount == 1 &&
                OriginalFidelityBoundaryMetrics.unverifiedRuneCostCount == 195,
            "settings fidelity boundary keeps verified, approximate and unverified Rune costs visible"
        )
        expect(
            OriginalFidelityBoundaryMetrics.inventoryExpansionCoverageText == "26/26" &&
                OriginalFidelityBoundaryMetrics.runeInventoryExpansionSlotBonusText == "+10" &&
                OriginalFidelityBoundaryMetrics.directInventoryExpansionSlotBonusText == "+10" &&
                OriginalFidelityBoundaryMetrics.directInventoryExpansionBaseCostText == "50,000G" &&
                OriginalFidelityBoundaryMetrics.directInventoryExpansionSecondCostText == "100,000G",
            "settings fidelity boundary exposes source-backed and direct backpack expansion scaffolds"
        )
        expect(
            OriginalFidelityBoundaryMetrics.inventoryExpansionBoundaryText.contains("成本") &&
                OriginalFidelityBoundaryMetrics.inventoryExpansionBoundaryText.contains("上限") &&
                OriginalFidelityBoundaryMetrics.inventoryExpansionBoundaryText.contains("叠加") &&
                OriginalFidelityBoundaryMetrics.inventoryExpansionBoundaryText.contains("背包布局仍待核对"),
            "settings fidelity boundary keeps original backpack expansion limits and layout unverified"
        )
        expect(
            OriginalFidelityBoundaryMetrics.stashPageCoverageText == "3/3" &&
                OriginalFidelityBoundaryMetrics.stashPageSlotBonusText == "+20" &&
                OriginalFidelityBoundaryMetrics.stashPageBoundaryText.contains("UnlockStashPageCount") &&
                OriginalFidelityBoundaryMetrics.stashPageBoundaryText.contains("同一背包容量"),
            "settings fidelity boundary exposes source-backed storage page capacity scaffolds"
        )
        expect(
            OriginalFidelityBoundaryMetrics.stashPageBoundaryText.contains("独立仓库页布局") &&
                OriginalFidelityBoundaryMetrics.stashPageBoundaryText.contains("分页上限") &&
                OriginalFidelityBoundaryMetrics.stashPageBoundaryText.contains("路径成本") &&
                OriginalFidelityBoundaryMetrics.stashPageBoundaryText.contains("重置经济"),
            "settings fidelity boundary keeps original storage-page layout and economy unverified"
        )
    }

    private static func settingsBattleAnimationEvidenceReview() {
        print("[SourceBattleAnimationEvidenceReviewView]")

        expect(
            SourceBattleAnimationEvidenceReviewMetrics.rowCount == 7 &&
                SourceBattleAnimationEvidenceReviewMetrics.actionFrameGateCount == 8 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialVideoWidth == 776 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialVideoHeight == 180 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialFPS == 30 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialFrameCount == 184,
            "settings battle animation review preserves official Steam battle media baseline"
        )
        expect(
            SourceBattleAnimationEvidenceReviewMetrics.officialDurationMilliseconds == 6_133 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialMotionSampleStartFrame == 0 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialMotionSampleEndFrame == 8 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialMotionSampleMilliseconds == 267 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialMotionPixels == 26_623 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialPlatformMotionPixels == 11_920 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialNonPlatformMotionPixels == 14_703 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialMotionPercentX10000 == 1_906 &&
                SourceBattleAnimationEvidenceReviewMetrics.officialMotionSampleFramePairText == "frame 0->8" &&
                SourceBattleAnimationEvidenceReviewMetrics.officialPlatformMotionShareText == "44.8%" &&
                SourceBattleAnimationEvidenceReviewMetrics.officialNonPlatformMotionShareText == "55.2%",
            "settings battle animation review preserves official Steam sampled-motion metrics"
        )
        expect(
            SourceBattleAnimationEvidenceReviewMetrics.localRenderWidthPixels == 1_232 &&
            SourceBattleAnimationEvidenceReviewMetrics.localRenderHeightPixels == 600 &&
                SourceBattleAnimationEvidenceReviewMetrics.localBattleTabRenderWidthPixels == 1_280 &&
                SourceBattleAnimationEvidenceReviewMetrics.localBattleTabRenderHeightPixels == 1_200 &&
                SourceBattleAnimationEvidenceReviewMetrics.localConfiguredRatioX100 == 205,
            "settings battle animation review keeps local deterministic render separate from original keyframe parity"
        )
        expect(
            SourceBattleAnimationEvidenceReviewMetrics.localPopoverWidthPoints == 640 &&
                SourceBattleAnimationEvidenceReviewMetrics.localPopoverHeightPoints == 600 &&
                SourceBattleAnimationEvidenceReviewMetrics.localContentHeightPoints == 488 &&
                SourceBattleAnimationEvidenceReviewMetrics.localBattleSceneHeightPoints == 300 &&
                SourceBattleAnimationEvidenceReviewMetrics.localBottomTabHeightPoints == 46 &&
                SourceBattleAnimationEvidenceReviewMetrics.localLayoutFootprintText.contains("content 488pt") &&
                SourceBattleAnimationEvidenceReviewMetrics.localLayoutFootprintText.contains("scene 300pt") &&
                SourceBattleAnimationEvidenceReviewMetrics.localLayoutFootprintText.contains("tab 46pt"),
            "settings battle animation review keeps local Battle tab layout footprint guarded without treating it as original layout proof"
        )
        expect(
            SourceBattleAnimationEvidenceReviewMetrics.rows.map(\.key) == [
                "official-media-baseline",
                "official-motion-sample",
                "local-deterministic-render",
                "fixture-coverage",
                "battle-tab-layout",
                "layout-translation",
                "exact-keyframe-gap"
            ],
            "settings battle animation review keeps evidence rows in a stable review order"
        )
        expect(
            SourceBattleAnimationEvidenceReviewMetrics.motionSampleRowCount == 4 &&
                SourceBattleAnimationEvidenceReviewMetrics.motionSampleRows.map(\.key) == [
                    "frame-pair",
                    "full-frame-delta",
                    "platform-delta",
                    "non-platform-delta"
                ] &&
                SourceBattleAnimationEvidenceReviewMetrics.motionSampleRows.first?.value == "frame 0->8 · 0.267s · 30fps" &&
                SourceBattleAnimationEvidenceReviewMetrics.motionSampleRows[1].value == "26,623 px · coverage 0.1906" &&
                SourceBattleAnimationEvidenceReviewMetrics.motionSampleRows[2].value == "11,920 px · 44.8% of changed pixels" &&
                SourceBattleAnimationEvidenceReviewMetrics.motionSampleRows[3].value == "14,703 px · 55.2% of changed pixels",
            "settings battle animation review exposes official frame-pair motion sample details"
        )
        expect(
            SourceBattleAnimationEvidenceReviewMetrics.motionSampleRows.allSatisfy {
                $0.boundary.contains("不") &&
                    ($0.boundary.contains("动作") || $0.boundary.contains("帧"))
            },
            "settings battle animation motion sample rows remain evidence-only"
        )
        expect(
            SourceBattleAnimationEvidenceReviewMetrics.actionFrameGateRows.map(\.key) == [
                "hero-idle-move",
                "hero-attack-cast",
                "hero-hit-death",
                "support-party",
                "monster-idle-move",
                "monster-attack-hit-death",
                "projectile-impact-status",
                "timing-audio-sync"
            ] &&
                SourceBattleAnimationEvidenceReviewMetrics.actionFrameGateMissingCount == 8 &&
                SourceBattleAnimationEvidenceReviewMetrics.actionFrameGateRows.allSatisfy {
                    $0.boundary.contains("不按本地速度线") &&
                        $0.requiredProof.contains("帧")
                },
            "settings battle animation review exposes action-frame evidence gates without promoting local effects"
        )
        expect(
            SourceBattleAnimationEvidenceReviewMetrics.rows.contains {
                $0.key == "official-motion-sample" &&
                    $0.currentEvidence.contains("frame 0->8") &&
                    $0.currentEvidence.contains("26,623") &&
                    $0.currentEvidence.contains("0.1906") &&
                    $0.boundary.contains("不证明攻击")
            },
            "settings battle animation review keeps official motion sampling limited to broad media evidence"
        )
        expect(
            SourceBattleAnimationEvidenceReviewMetrics.sourceBoundaryText.contains("不证明原版逐动作关键帧") &&
                SourceBattleAnimationEvidenceReviewMetrics.localBoundaryText.contains("不能替代原版逐帧动画") &&
                SourceBattleAnimationEvidenceReviewMetrics.keyframeGapBoundaryText.contains("不得按当前本地动效声明原版动画还原") &&
                SourceBattleAnimationEvidenceReviewMetrics.actionFrameGateBoundaryText.contains("不按本地速度线") &&
                SourceBattleAnimationEvidenceReviewMetrics.exactOriginalActionFrameCount == 0,
            "settings battle animation review keeps exact original action-frame gaps explicit"
        )
    }

    private static func settingsAudioSFXEvidenceReview() {
        print("[SourceAudioSFXEvidenceReviewView]")

        expect(
            SourceAudioSFXEvidenceReviewMetrics.rowCount == 6 &&
                SourceAudioSFXEvidenceReviewMetrics.eventGateCount == 7 &&
                SourceAudioSFXEvidenceReviewMetrics.localSFXEventCount == 11 &&
                SourceAudioSFXEvidenceReviewMetrics.localSFXResourceCount == 11 &&
                SourceAudioSFXEvidenceReviewMetrics.originalIsolatedSFXCount == 0,
            "settings audio SFX review exposes Steam baseline, local manifest and isolated-original gap counts"
        )
        expect(
            SourceAudioSFXEvidenceReviewMetrics.steamTrailerDurationSeconds == 47 &&
                SourceAudioSFXEvidenceReviewMetrics.steamTrailerSampleRateHz == 48_000 &&
                SourceAudioSFXEvidenceReviewMetrics.steamTrailerChannels == 2 &&
                SourceAudioSFXEvidenceReviewMetrics.steamTrailerIntegratedLoudnessLUFS == "-15.3 LUFS" &&
                SourceAudioSFXEvidenceReviewMetrics.steamTrailerLoudnessRangeLU == "4.6 LU" &&
                SourceAudioSFXEvidenceReviewMetrics.steamTrailerTruePeakDBFS == "0.0 dBFS",
            "settings audio SFX review preserves the current Steam Trailer broad audio baseline"
        )
        expect(
            SourceAudioSFXEvidenceReviewMetrics.localSFXSampleRateHz == 22_050 &&
                SourceAudioSFXEvidenceReviewMetrics.localSFXChannels == 1 &&
                SourceAudioSFXEvidenceReviewMetrics.localSFXBitDepth == 16 &&
                SourceAudioSFXEvidenceReviewMetrics.localSFXProvenance == "generated_substitute" &&
                SourceAudioSFXEvidenceReviewMetrics.localSFXOfficialAudio == false,
            "settings audio SFX review keeps generated substitute manifest format explicit"
        )
        expect(
            SourceAudioSFXEvidenceReviewMetrics.rows.map(\.key) == [
                "steam-trailer-baseline",
                "steam-loudness-envelope",
                "local-sfx-manifest",
                "runtime-routing",
                "package-audit",
                "isolated-original-gap"
            ],
            "settings audio SFX review keeps evidence rows in a stable review order"
        )
        expect(
            SourceAudioSFXEvidenceReviewMetrics.eventGateRows.map(\.key) == [
                "basic-combat-hit",
                "skill-cast-release",
                "projectile-impact",
                "buff-status-loop",
                "loot-inventory-ui",
                "mix-throttle-randomization",
                "package-provenance"
            ] &&
                SourceAudioSFXEvidenceReviewMetrics.eventGateMissingCount == 7 &&
                SourceAudioSFXEvidenceReviewMetrics.eventGateRows.allSatisfy {
                    $0.requiredProof.contains("原版") &&
                        $0.boundary.contains("不按本地 WAV")
                },
            "settings audio SFX review exposes per-event evidence gates without promoting substitutes"
        )
        expect(
            SourceAudioSFXEvidenceReviewMetrics.rows.contains {
                $0.key == "local-sfx-manifest" &&
                    $0.currentEvidence.contains("11 事件") &&
                    $0.currentEvidence.contains("22,050 Hz") &&
                    $0.boundary.contains("generated_substitute") &&
                    $0.boundary.contains("officialAudio=false")
            },
            "settings audio SFX review keeps local WAV cues separate from original SFX claims"
        )
        expect(
            SourceAudioSFXEvidenceReviewMetrics.sourceBoundaryText.contains("不证明任何单个") &&
                SourceAudioSFXEvidenceReviewMetrics.localBoundaryText.contains("不得声明原声音效还原") &&
                SourceAudioSFXEvidenceReviewMetrics.eventGateBoundaryText.contains("不按本地 WAV") &&
                SourceAudioSFXEvidenceReviewMetrics.rows.last?.nextEvidence.contains("原版音频资源") == true,
            "settings audio SFX review keeps Steam trailer and local substitute evidence boundaries explicit"
        )
    }

    private static func settingsLocalRuneCostReview() {
        print("[LocalRuneCostReviewView]")

        let verifiedNodeIDs = Set(
            LocalRuneCostReviewMetrics.rows
                .filter { $0.status == .verified }
                .map { $0.node.rawValue }
        )

        expect(
            LocalRuneCostReviewMetrics.rowCount == RuneTreeNode.allCases.count &&
                LocalRuneCostReviewMetrics.rowCount == 197,
            "settings local Rune cost review exposes every runtime Rune node"
        )
        expect(
            LocalRuneCostReviewMetrics.sourceBackedCount == 197,
            "settings local Rune cost review keeps every runtime Rune row source-backed"
        )
        expect(
            LocalRuneCostReviewMetrics.verifiedCount == 2 &&
                LocalRuneCostReviewMetrics.verifiedGoldTotal == 200_000 &&
                verifiedNodeIDs == Set([RuneTreeNode.partySlot2.rawValue, RuneTreeNode.partySlot3.rawValue]),
            "settings local Rune cost review preserves the two checked Rune of Command costs"
        )
        expect(
            LocalRuneCostReviewMetrics.approximateCount == 1 &&
                LocalRuneCostReviewMetrics.approximateGoldTotal == 50_000 &&
                LocalRuneCostReviewMetrics.approximateSourceBackedCount == 1 &&
                LocalRuneCostReviewMetrics.row(node: .activeSkillSlot2)?.status == .approximate &&
                LocalRuneCostReviewMetrics.row(node: .activeSkillSlot2)?.approximateSourceText == "官方符文分支：2nd Active Skill Slot (~50,000g)",
            "settings local Rune cost review keeps Rune of Awakening as official-branch approximate cost only"
        )
        expect(
            LocalRuneCostReviewMetrics.approximateSourceEvidenceText == "官方符文分支：2nd Active Skill Slot (~50,000g)",
            "settings local Rune cost review exposes official approximate Rune cost evidence without marking it verified"
        )
        let activeSkillApproximateEvidence = LocalRuneCostReviewMetrics.approximateEvidenceRow(node: .activeSkillSlot2)
        expect(
            LocalRuneCostReviewMetrics.approximateEvidenceRowCount == LocalRuneCostReviewMetrics.approximateCount &&
                LocalRuneCostReviewMetrics.approximateEvidenceRowCount == 1 &&
                activeSkillApproximateEvidence?.sourceIDText == "#27" &&
                activeSkillApproximateEvidence?.sourceNameText.contains("觉醒符文") == true &&
                activeSkillApproximateEvidence?.sourceNameText.contains("Rune of Awakening") == true &&
                activeSkillApproximateEvidence?.currentEvidence.contains("约 50,000 G") == true &&
                activeSkillApproximateEvidence?.currentEvidence.contains("2nd Active Skill Slot") == true,
            "settings local Rune cost review exposes a dedicated approximate-cost evidence row for Rune of Awakening"
        )
        expect(
            LocalRuneCostReviewMetrics.approximateEvidenceBoundaryText.contains("页面/指南层") &&
                LocalRuneCostReviewMetrics.approximateEvidenceBoundaryText.contains("游戏内扣费") &&
                LocalRuneCostReviewMetrics.approximateEvidenceBoundaryText.contains("路径成本") &&
                LocalRuneCostReviewMetrics.approximateEvidenceBoundaryText.contains("重置退款") &&
                LocalRuneCostReviewMetrics.approximateEvidenceBoundaryText.contains("点数经济") &&
                activeSkillApproximateEvidence?.missingEvidence.contains("游戏内扣费") == true &&
                activeSkillApproximateEvidence?.missingEvidence.contains("路径总价") == true &&
                activeSkillApproximateEvidence?.requiredProof.contains("Rune ID") == true &&
                activeSkillApproximateEvidence?.requiredProof.contains("退款日志") == true &&
                activeSkillApproximateEvidence?.boundary.contains("不把") == true &&
                activeSkillApproximateEvidence?.boundary.contains("运行时扣费") == true &&
                activeSkillApproximateEvidence?.boundary.contains("路径成本") == true &&
                activeSkillApproximateEvidence?.boundary.contains("重置退款") == true &&
                activeSkillApproximateEvidence?.boundary.contains("点数经济") == true,
            "settings local Rune cost review keeps approximate-cost evidence from entering runtime economy"
        )
        expect(
            LocalRuneCostReviewMetrics.pendingCount == 194 &&
                LocalRuneCostReviewMetrics.row(node: .offlineRewards)?.costText == "成本待核对" &&
                LocalRuneCostReviewMetrics.row(node: .inventoryExpansion1)?.costText == "成本待核对",
            "settings local Rune cost review keeps unknown Rune costs explicit"
        )
        let pendingGroupTotal = LocalRuneCostReviewMetrics.pendingGroups.reduce(0) { $0 + $1.pendingCount }
        let pendingBranchTotal = LocalRuneCostReviewMetrics.pendingBranchRows.reduce(0) { $0 + $1.pendingCount }
        let pendingBranchGroupTotal = LocalRuneCostReviewMetrics.pendingBranchRows.reduce(0) { $0 + $1.groupCount }
        let pendingCostEvidenceQueueRows = LocalRuneCostReviewMetrics.pendingCostEvidenceQueueRows
        let pendingCostEvidenceQueueTotal = pendingCostEvidenceQueueRows.reduce(0) { $0 + $1.branch.pendingCount }
        let pendingCostEvidenceQueueGroupTotal = pendingCostEvidenceQueueRows.reduce(0) { $0 + $1.branch.groupCount }
        let pendingCostBranchEvidenceRows = LocalRuneCostReviewMetrics.pendingCostBranchEvidenceRows
        let pendingCostBranchEvidenceTotal = pendingCostBranchEvidenceRows.reduce(0) { $0 + $1.group.pendingCount }
        let pendingCostMaxLevelEvidenceRows = LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceRows
        let pendingCostMaxLevelEvidenceTotal = pendingCostMaxLevelEvidenceRows.reduce(0) { $0 + $1.pendingCount }
        let pendingCostMaxLevelIconBucketTotal = pendingCostMaxLevelEvidenceRows.reduce(0) { $0 + $1.iconGroupCount }
        expect(
            LocalRuneCostReviewMetrics.pendingGroupCount == 37 &&
                pendingGroupTotal == LocalRuneCostReviewMetrics.pendingCount &&
                LocalRuneCostReviewMetrics.pendingGroup(iconName: "MaxInventorySlot")?.pendingCount == 26 &&
                LocalRuneCostReviewMetrics.pendingGroup(iconName: "DropChanceNormalChest")?.pendingCount == 15 &&
                LocalRuneCostReviewMetrics.pendingGroup(iconName: "UnlockArrangeSlotCount") == nil &&
                LocalRuneCostReviewMetrics.pendingGroup(iconName: "UnlockSkillSlotCount") == nil,
            "settings local Rune cost review groups pending costs by source icon family without promoting verified or approximate nodes"
        )
        expect(
            LocalRuneCostReviewMetrics.pendingBranchCount == 7 &&
                pendingBranchTotal == LocalRuneCostReviewMetrics.pendingCount &&
                pendingBranchGroupTotal == LocalRuneCostReviewMetrics.pendingGroupCount &&
                LocalRuneCostReviewMetrics.pendingBranch(key: "chest")?.pendingCount == 82 &&
                LocalRuneCostReviewMetrics.pendingBranch(key: "chest")?.groupCount == 13 &&
                LocalRuneCostReviewMetrics.pendingBranch(key: "inventory-storage")?.pendingCount == 29 &&
                LocalRuneCostReviewMetrics.pendingBranch(key: "combat-reward")?.pendingCount == 43 &&
                LocalRuneCostReviewMetrics.pendingBranch(key: "hero-stat")?.pendingCount == 20 &&
                LocalRuneCostReviewMetrics.pendingBranch(key: "cube-alchemy")?.pendingCount == 8 &&
                LocalRuneCostReviewMetrics.pendingBranch(key: "offline")?.pendingCount == 11 &&
                LocalRuneCostReviewMetrics.pendingBranch(key: "stage-pacing")?.pendingCount == 1,
            "settings local Rune cost review groups pending costs by gameplay branch without inventing prices"
        )
        expect(
            LocalRuneCostReviewMetrics.pendingCostEvidenceQueueCount == 7 &&
                LocalRuneCostReviewMetrics.pendingCostEvidenceQueueCoverage == LocalRuneCostReviewMetrics.pendingCount &&
                LocalRuneCostReviewMetrics.pendingCostEvidenceQueueGroupCoverage == LocalRuneCostReviewMetrics.pendingGroupCount &&
                pendingCostEvidenceQueueTotal == LocalRuneCostReviewMetrics.pendingCount &&
                pendingCostEvidenceQueueGroupTotal == LocalRuneCostReviewMetrics.pendingGroupCount &&
                pendingCostEvidenceQueueRows.map(\.branch.key) == [
                    "chest",
                    "inventory-storage",
                    "combat-reward",
                    "hero-stat",
                    "cube-alchemy",
                    "offline",
                    "stage-pacing"
                ] &&
                pendingCostEvidenceQueueRows.first?.branch.pendingCount == 82 &&
                pendingCostEvidenceQueueRows.last?.branch.pendingCount == 1,
            "settings local Rune cost review groups pending costs into evidence queues"
        )
        expect(
            LocalRuneCostReviewMetrics.pendingCostBranchEvidenceRowCount == 37 &&
                LocalRuneCostReviewMetrics.pendingCostBranchEvidenceCoverage == LocalRuneCostReviewMetrics.pendingCount &&
                LocalRuneCostReviewMetrics.pendingCostBranchEvidenceCoverageText == "194/194" &&
                pendingCostBranchEvidenceRows.map(\.id).count == Set(pendingCostBranchEvidenceRows.map(\.id)).count &&
                pendingCostBranchEvidenceTotal == LocalRuneCostReviewMetrics.pendingCount &&
                pendingCostBranchEvidenceRows.first?.id == "chest-DropChanceNormalChest" &&
                pendingCostBranchEvidenceRows.first?.group.pendingCount == 15 &&
                pendingCostBranchEvidenceRows.contains {
                    $0.id == "inventory-storage-MaxInventorySlot" &&
                        $0.group.pendingCount == 26
                } &&
                pendingCostBranchEvidenceRows.last?.id == "stage-pacing-WaveCountReduction" &&
                pendingCostBranchEvidenceRows.last?.group.pendingCount == 1,
            "settings local Rune cost review expands pending branch icon groups into evidence rows"
        )
        expect(
            pendingCostBranchEvidenceRows.allSatisfy {
                $0.currentEvidence.contains("节点") &&
                    $0.missingEvidence.contains("逐节点费用") &&
                    $0.requiredProof.contains("Rune ID") &&
                    $0.boundary.contains("不按") &&
                    $0.boundary.contains("符文价格") &&
                    $0.boundary.contains("路径成本") &&
                    $0.boundary.contains("重置退款") &&
                    $0.boundary.contains("点数经济")
            },
            "settings local Rune cost review keeps branch evidence rows from fabricating Rune prices"
        )
        expect(
            LocalRuneCostReviewMetrics.pendingCostEvidenceQueueBoundaryText.contains("互斥") &&
                LocalRuneCostReviewMetrics.pendingCostEvidenceQueueBoundaryText.contains("不按玩法分支") &&
                LocalRuneCostReviewMetrics.pendingCostEvidenceQueueBoundaryText.contains("源表图标") &&
                LocalRuneCostReviewMetrics.pendingCostEvidenceQueueBoundaryText.contains("不生成符文价格") &&
                pendingCostEvidenceQueueRows.allSatisfy { $0.currentEvidence.contains("节点") } &&
                pendingCostEvidenceQueueRows.allSatisfy { $0.nextEvidence.contains("费用") } &&
                pendingCostEvidenceQueueRows.allSatisfy { $0.boundary.contains("不按") && $0.boundary.contains("推断") },
            "settings local Rune cost review keeps evidence queues from fabricating Rune costs"
        )
        expect(
            LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceCount == 5 &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceCoverage == LocalRuneCostReviewMetrics.pendingCount &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceIconBucketTotal == 62 &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceSummaryText == "1:59,2:1,3:43,5:89,10:2" &&
                pendingCostMaxLevelEvidenceTotal == LocalRuneCostReviewMetrics.pendingCount &&
                pendingCostMaxLevelIconBucketTotal == 62 &&
                pendingCostMaxLevelEvidenceRows.map(\.maxLevel) == [1, 2, 3, 5, 10] &&
                pendingCostMaxLevelEvidenceRows.map(\.pendingCount) == [59, 1, 43, 89, 2] &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceRow(maxLevel: 1)?.iconGroupCount == 19 &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceRow(maxLevel: 2)?.sampleSourceIDText == "#2151" &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceRow(maxLevel: 5)?.iconGroupCount == 23 &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceRow(maxLevel: 10)?.sampleSourceIDText == "#403 #405",
            "settings local Rune cost review groups pending costs by source maxLevel without inventing prices"
        )
        expect(
            LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceBoundaryText.contains("maxLevel 队列") &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceBoundaryText.contains("源表等级上限") &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceBoundaryText.contains("不按 maxLevel") &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceBoundaryText.contains("逐级价格") &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceBoundaryText.contains("成本梯度") &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceBoundaryText.contains("路径成本") &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceBoundaryText.contains("重置退款") &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceBoundaryText.contains("点数经济") &&
                pendingCostMaxLevelEvidenceRows.allSatisfy { $0.currentEvidence.contains("节点") && $0.currentEvidence.contains("图标组") } &&
                pendingCostMaxLevelEvidenceRows.allSatisfy { $0.nextEvidence.contains("逐级费用") && $0.nextEvidence.contains("重置退款") } &&
                pendingCostMaxLevelEvidenceRows.allSatisfy {
                    $0.boundary.contains("源表等级上限") &&
                        $0.boundary.contains("不按") &&
                        $0.boundary.contains("逐级价格") &&
                        $0.boundary.contains("成本梯度") &&
                        $0.boundary.contains("路径成本") &&
                        $0.boundary.contains("重置退款") &&
                        $0.boundary.contains("点数经济")
                },
            "settings local Rune cost review keeps maxLevel evidence queues from fabricating Rune costs"
        )
        let costEvidenceGateKeys = Set(LocalRuneCostReviewMetrics.costEvidenceGateRows.map(\.key))
        expect(
            LocalRuneCostReviewMetrics.costEvidenceGateCount == 6 &&
                costEvidenceGateKeys == Set([
                    "per-node-cost",
                    "branch-path-cost",
                    "reset-refund",
                    "candidate-cross-source",
                    "currency-point",
                    "stacking-cap"
                ]) &&
                LocalRuneCostReviewMetrics.costEvidenceGateRows.allSatisfy { $0.affectedNodeCount > 0 },
            "settings local Rune cost review exposes cost evidence gates before pending costs enter runtime"
        )
        expect(
            LocalRuneCostReviewMetrics.costEvidenceGateRows.contains {
                $0.currentEvidence == "2 已验证 / 1 近似 / 194 待核对"
            } &&
                LocalRuneCostReviewMetrics.costEvidenceGateRows.contains {
                    $0.currentEvidence.contains("37 图标组 / 7 玩法分支")
                } &&
                LocalRuneCostReviewMetrics.costEvidenceGateRows.contains {
                    $0.currentEvidence.contains("13 tbh.city 候选成本")
                },
            "settings local Rune cost review ties cost gates to current verified, pending and candidate evidence"
        )
        expect(
            LocalRuneCostReviewMetrics.approximateBoundaryText.contains("不参与") &&
                LocalRuneCostReviewMetrics.pendingBoundaryText.contains("不伪造") &&
                LocalRuneCostReviewMetrics.resetRefundBoundaryText.contains("重置") &&
                LocalRuneCostReviewMetrics.pendingGroupBoundaryText.contains("不推断成本梯度") &&
                LocalRuneCostReviewMetrics.pendingBranchBoundaryText.contains("不推断分支价格") &&
                LocalRuneCostReviewMetrics.costEvidenceGateBoundaryText.contains("不生成符文价格") &&
                LocalRuneCostReviewMetrics.pendingCostEvidenceQueueBoundaryText.contains("不生成符文价格") &&
                LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceBoundaryText.contains("不按 maxLevel") &&
                LocalRuneCostReviewMetrics.costEvidenceGateBoundaryText.contains("路径成本") &&
                LocalRuneCostReviewMetrics.costEvidenceGateBoundaryText.contains("重置退款") &&
                LocalRuneCostReviewMetrics.costEvidenceGateBoundaryText.contains("点数经济"),
            "settings local Rune cost review keeps reset refund, unknown-cost and grouped-gap boundaries explicit"
        )
    }

    private static func settingsSourceRuneEvidenceReview() {
        print("[SourceRuneEvidenceReviewView]")

        expect(
            SourceRuneEvidenceReviewMetrics.rowCount == 9 &&
                SourceRuneEvidenceReviewMetrics.wikiLocaleCount == 2 &&
                SourceRuneEvidenceReviewMetrics.independentSourceCount == 6 &&
                SourceRuneEvidenceReviewMetrics.singleSourceCandidateMirrorCount == 1,
            "settings Rune evidence review exposes Wiki locales, independent sources and candidate mirror count"
        )
        expect(
            SourceRuneEvidenceReviewMetrics.verifiedCostRows == 2 &&
                SourceRuneEvidenceReviewMetrics.approximateCostRows == 1 &&
                SourceRuneEvidenceReviewMetrics.candidateCostRows == 13 &&
                SourceRuneEvidenceReviewMetrics.candidateCostGoldTotal == 383_790_000 &&
                SourceRuneEvidenceReviewMetrics.unresolvedPendingCostNodes == LocalRuneCostReviewMetrics.pendingCount &&
                SourceRuneEvidenceReviewMetrics.unresolvedPendingCostNodes == 194,
            "settings Rune evidence review keeps verified, approximate, candidate and pending costs separated"
        )
        expect(
            SourceRuneEvidenceReviewMetrics.rows.contains {
                $0.title == "编队成本" &&
                    $0.evidence.contains("50,000G") &&
                    $0.evidence.contains("150,000G") &&
                    $0.confidence == "高"
            },
            "settings Rune evidence review upgrades formation costs to cross-source evidence"
        )
        expect(
            SourceRuneEvidenceReviewMetrics.rows.contains {
                $0.title == "自动开箱" &&
                    $0.evidence.contains("300s") &&
                    $0.evidence.contains("600s") &&
                    $0.evidence.contains("60s") &&
                    $0.boundary.contains("已接入已核对冷却值")
            },
            "settings Rune evidence review exposes source-backed auto-open cooldown runtime evidence"
        )
        expect(
            SourceRuneEvidenceReviewMetrics.rows.contains {
                $0.title == "自动开箱成本候选" &&
                    $0.evidence.contains("13 节点") &&
                    $0.evidence.contains("382.58M") &&
                    $0.boundary.contains("不参与本地扣费") &&
                    $0.confidence == "低"
            } &&
                SourceRuneEvidenceReviewMetrics.candidateCostSourceText.contains("不计入已核对成本或退款"),
            "settings Rune evidence review exposes tbh.city candidate auto-open costs without promoting them to verified costs"
        )
        expect(
            SourceRuneEvidenceReviewMetrics.tbhCityCandidateCostTableRows == SourceRuneCatalog.expectedNodeCount &&
                SourceRuneEvidenceReviewMetrics.tbhCityCandidateCostTableCoverageText == "197/197" &&
                SourceRuneEvidenceReviewMetrics.tbhCityCandidateCostTableGoldTotal == 10_040_515_050 &&
                SourceRuneEvidenceReviewMetrics.tbhCityCandidateCostTableGoldText == "10,040,515,050G" &&
                SourceRuneEvidenceReviewMetrics.tbhCityCandidateCostSampleText.contains("#1 100G") &&
                SourceRuneEvidenceReviewMetrics.tbhCityCandidateCostSampleText.contains("#24 150,000G") &&
                SourceRuneEvidenceReviewMetrics.tbhCityCandidateCostSampleText.contains("#13002 10,000G") &&
                SourceRuneEvidenceReviewMetrics.rows.contains {
                    $0.title == "完整候选成本表" &&
                        $0.evidence.contains("197/197") &&
                        $0.evidence.contains("10,040,515,050G") &&
                        $0.boundary.contains("单源候选") &&
                        $0.confidence == "低"
                },
            "settings Rune evidence review exposes complete tbh.city candidate cost-table coverage without promoting it to verified runtime costs"
        )
        expect(
            SourceRuneEvidenceReviewMetrics.candidateCostQueueCount == 4 &&
                SourceRuneEvidenceReviewMetrics.candidateCostQueueCoverageCount == 13 &&
                SourceRuneEvidenceReviewMetrics.candidateCostQueueGoldTotal == SourceRuneEvidenceReviewMetrics.candidateCostGoldTotal &&
                SourceRuneEvidenceReviewMetrics.candidateCostQueueRows.map(\.key) == [
                    "candidate-10k",
                    "candidate-200k",
                    "candidate-1m",
                    "candidate-lubrication-aggregate"
                ],
            "settings Rune evidence review splits single-source candidate costs into review-only buckets"
        )
        expect(
            SourceRuneEvidenceReviewMetrics.candidateCostQueueRows.first?.candidateGold == 10_000 &&
                SourceRuneEvidenceReviewMetrics.candidateCostQueueRows.last?.affectedCandidateCount == 10 &&
                SourceRuneEvidenceReviewMetrics.candidateCostQueueRows.last?.candidateGold == 382_580_000 &&
                SourceRuneEvidenceReviewMetrics.candidateCostQueueRows.last?.sourceEvidence.contains("382.58M") == true,
            "settings Rune evidence review keeps tbh.city candidate bucket totals visible without per-node binding"
        )
        expect(
            SourceRuneEvidenceReviewMetrics.candidateCostQueueBoundaryText.contains("不按候选金额") &&
                SourceRuneEvidenceReviewMetrics.candidateCostQueueBoundaryText.contains("符文价格") &&
                SourceRuneEvidenceReviewMetrics.candidateCostQueueBoundaryText.contains("路径成本") &&
                SourceRuneEvidenceReviewMetrics.candidateCostQueueBoundaryText.contains("重置退款") &&
                SourceRuneEvidenceReviewMetrics.candidateCostQueueBoundaryText.contains("点数经济") &&
                SourceRuneEvidenceReviewMetrics.candidateCostQueueRows.allSatisfy {
                    $0.boundary.contains("扣费") ||
                        $0.boundary.contains("退款")
                } &&
                SourceRuneEvidenceReviewMetrics.fullCandidateCostBoundaryText.contains("不写入运行时扣费") &&
                SourceRuneEvidenceReviewMetrics.fullCandidateCostBoundaryText.contains("退款") &&
                SourceRuneEvidenceReviewMetrics.fullCandidateCostBoundaryText.contains("点数经济"),
            "settings Rune evidence review keeps candidate cost queues from entering runtime cost or refund math"
        )
        expect(
            SourceRuneEvidenceReviewMetrics.fullCostTableBoundaryText.contains("完整可验证 197 节点成本/路径表仍缺") &&
                SourceRuneEvidenceReviewMetrics.resetEconomyBoundaryText.contains("重置价格") &&
                SourceRuneEvidenceReviewMetrics.runtimeTimerBoundaryText.contains("完整成本、路径、重置经济与点数规则仍缺"),
            "settings Rune evidence review keeps full-cost, reset-economy and path gaps explicit"
        )
    }

    private static func settingsSupportFormulaReview() {
        print("[SupportFormulaReviewView]")

        let sample = SupportFormulaReviewMetrics.sampleMember
        let lockedSample = SupportFormulaReviewMetrics.lockedSampleMember
        let heroLevel = SupportFormulaReviewMetrics.sampleHeroLevel
        let expectedAttack = max(
            1,
            Int((
                Double(
                    sample.heroClass.baseStats.atk +
                        max(heroLevel - 1, 0) * SupportFormulaReviewMetrics.attackLevelBonusPerHeroLevel
                ) * SupportFormulaReviewMetrics.supportAttackScalar
            ).rounded())
        )
        let expectedHP = max(
            1,
            sample.heroClass.baseStats.hp +
                max(heroLevel - 1, 0) * SupportFormulaReviewMetrics.hpLevelBonusPerHeroLevel
        )
        let expectedDefense = max(
            0,
            sample.heroClass.baseStats.def +
                max(heroLevel - 1, 0) * SupportFormulaReviewMetrics.defenseLevelBonusPerHeroLevel
        )
        let expectedSpeed = sample.heroClass.baseStats.spd +
            SupportFormulaReviewMetrics.speedLevelBonusPerHeroLevel

        expect(
            SupportFormulaReviewMetrics.rowCount == 4 &&
                SupportFormulaReviewMetrics.rows.map(\.title) == ["攻击", "生命", "护甲", "速度"],
            "settings support formula review exposes attack, HP, armor and speed formula rows"
        )
        expect(
            SupportFormulaReviewMetrics.sampleAttack == expectedAttack &&
                SupportFormulaReviewMetrics.sampleHP == expectedHP &&
                SupportFormulaReviewMetrics.sampleDefense == expectedDefense &&
                SupportFormulaReviewMetrics.sampleSpeed == expectedSpeed,
            "settings support formula review mirrors the current PartyMember support formulas"
        )
        expect(
            lockedSample.supportAttackPower(heroLevel: heroLevel) == 0 &&
                lockedSample.supportMaxHP(heroLevel: heroLevel) == 0 &&
                lockedSample.supportDefense(heroLevel: heroLevel) == 0 &&
                lockedSample.supportSpeed() == 0,
            "settings support formula review preserves locked support slot zero-contribution boundaries"
        )
        expect(
            SupportFormulaReviewMetrics.supportAttackScalar == 0.35 &&
                SupportFormulaReviewMetrics.attackLevelBonusPerHeroLevel == 2 &&
                SupportFormulaReviewMetrics.hpLevelBonusPerHeroLevel == 10 &&
                SupportFormulaReviewMetrics.defenseLevelBonusPerHeroLevel == 1 &&
                SupportFormulaReviewMetrics.speedLevelBonusPerHeroLevel == 0,
            "settings support formula review keeps the local support scaling constants explicit"
        )
        expect(
            SupportFormulaReviewMetrics.localFormulaBoundaryText.contains("主角等级") &&
                SupportFormulaReviewMetrics.runeBoundaryText.contains("全英雄") &&
                SupportFormulaReviewMetrics.independentLevelBoundaryText.contains("待核对") &&
                SupportFormulaReviewMetrics.runtimeScopeBoundaryText.contains("脚手架"),
            "settings support formula review keeps independent support level and equipment gaps explicit"
        )
    }

    private static func settingsSourceMonsterDatabase() {
        print("[SourceMonsterDatabaseView]")

        let rows = SourceMonsterDatabaseMetrics.rows
        let slime = SourceMonsterDatabase.entry(id: 10011)
        let tick = SourceMonsterDatabase.entry(id: 20121)
        let fallenHelm = SourceMonsterDatabase.entry(id: 30013)
        let chaosPriest = SourceMonsterDatabase.entry(id: 30104)
        let archon = SourceMonsterDatabase.entry(id: 30904)

        expect(
            SourceMonsterDatabase.rowCount == 61 &&
                SourceMonsterDatabaseMetrics.rowCount == 61 &&
                SourceMonsterDatabase.idsAreUnique &&
                SourceMonsterDatabaseMetrics.uniqueIDCount == 61 &&
                SourceMonsterDatabase.uniqueNameCount == 52 &&
                SourceMonsterDatabaseMetrics.uniqueNameCount == 52 &&
                Set(rows.map(\.id)).count == 61,
            "settings source monster database preserves all 61 Wiki monster rows with unique IDs"
        )
        expect(
            SourceMonsterDatabaseMetrics.officialSteamMinimumMonsterTypeCount == 50 &&
                SourceMonsterDatabaseMetrics.steamRosterIdentityCoverageText == "52/50+" &&
                SourceMonsterDatabaseMetrics.steamRosterIdentityGapCount == 0,
            "settings source monster database separates source roster identity from stage art coverage"
        )
        expect(
            slime?.zhName == "史莱姆" &&
                slime?.enName == "Slime" &&
                slime?.hp == 50 &&
                slime?.attack == 10 &&
                nearlyEqual(slime?.attackSpeed ?? 0, 0.4) &&
                slime?.gold == 10 &&
                slime?.xp == 10 &&
                slime?.bestFarm.contains("4101") == true,
            "settings source monster database preserves the checked Slime source row"
        )
        expect(
            tick?.zhName == "扁虱" &&
                tick?.enName == "Tick" &&
                tick?.hp == 55 &&
                tick?.attack == 10 &&
                nearlyEqual(tick?.attackSpeed ?? 0, 1.4) &&
                tick?.gold == 7 &&
                tick?.xp == 7 &&
                tick?.bestFarm == "—" &&
                SourceMonsterDatabaseMetrics.missingBestFarmCount == 1 &&
                SourceMonsterDatabaseMetrics.sourceAbsentBestFarmBoundaryText.contains("源表空值") &&
                SourceMonsterDatabaseMetrics.sourceAbsentBestFarmBoundaryText.contains("不当作待补刷取地") &&
                SourceMonsterDatabaseMetrics.sourceAbsentBestFarmBoundaryText.contains("不反推关卡出场"),
            "settings source monster database preserves the checked source-absent best-farm Tick row"
        )
        expect(
            fallenHelm?.zhName == "堕落天使的头盔" &&
                fallenHelm?.enName == "Fallen Angel's Helm" &&
                fallenHelm?.hp == 40 &&
                fallenHelm?.attack == 25 &&
                nearlyEqual(fallenHelm?.attackSpeed ?? 0, 1.1),
            "settings source monster database preserves the checked Fallen Angel helm row"
        )
        expect(
            chaosPriest?.zhName == "混沌的地狱祭司" &&
                chaosPriest?.enName == "Chaos Hell Priest" &&
                chaosPriest?.hp == 75 &&
                chaosPriest?.attack == 30 &&
                nearlyEqual(chaosPriest?.attackSpeed ?? 0, 1.0),
            "settings source monster database preserves the checked Chaos Hell Priest row"
        )
        expect(
            archon?.zhName == "执政官莫尔卡" &&
                archon?.enName == "Archon Morkar" &&
                archon?.hp == 3_550 &&
                archon?.attack == 100 &&
                nearlyEqual(archon?.attackSpeed ?? 0, 1.5) &&
                archon?.gold == 500 &&
                archon?.xp == 1 &&
                archon?.bestFarm.contains("4310") == true,
            "settings source monster database preserves the checked Archon Morkar torment row"
        )
        expect(
            SourceMonsterDatabase.entry(zhName: "骷髅王", stageCode: "1110")?.id == 10901 &&
                SourceMonsterDatabase.entry(zhName: "骷髅王", stageCode: "4110")?.id == 10904 &&
                SourceMonsterDatabase.entry(zhName: "沙漠的支配者", stageCode: "2210")?.id == 20902 &&
                SourceMonsterDatabase.entry(zhName: "执政官莫尔卡", stageCode: "4310")?.id == 30904,
            "settings source monster database resolves duplicate boss rows by source stage code"
        )
        expect(
            SourceMonsterDatabase.runtimeSpeed(fromAttackSpeed: 0.4) == 4 &&
                SourceMonsterDatabase.runtimeSpeed(fromAttackSpeed: 1.5) == 15 &&
                SourceMonsterDatabase.runtimeSpeed(fromAttackSpeed: 1.8) == 18,
            "settings source monster database converts source attack-speed values into runtime speed scalars"
        )
        expect(
            SourceMonsterDatabaseMetrics.sourceCooldownRangeText == "0.6s-2.5s" &&
                SourceMonsterDatabaseMetrics.localLoopCooldownRangeText == "1s-3s" &&
                SourceMonsterDatabaseMetrics.attackSpeedQuantizationText.contains("来源冷却") &&
                SourceMonsterDatabaseMetrics.attackSpeedQuantizationText.contains("本地循环"),
            "settings source monster database exposes attack-speed quantization by the local timer loop"
        )
        expect(
            SourceMonsterDatabase.stageCompositionNameCoverageCount == SourceMonsterArtMappingMetrics.sourceNameCount &&
                SourceMonsterDatabaseMetrics.stageCompositionCoverageText == "49/49" &&
                SourceMonsterDatabase.stageCompositionMissingNames.isEmpty &&
                SourceMonsterDatabaseMetrics.missingStageCompositionNamesText == "无",
            "settings source monster database covers every checked stage-composition monster name"
        )
        expect(
            SourceMonsterDatabaseMetrics.stageCompositionUnmappedCount == 3 &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedNamesText == "剧毒领主 / 扁虱 / 雪山法师" &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedDetailText == "20042:剧毒领主,20121:扁虱,30044:雪山法师" &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedRows.map(\.id) == [20042, 20121, 30044],
            "settings source monster database exposes source rows missing from current stage-composition art mapping"
        )
        expect(
            SourceMonsterDatabase.sourceOnlySpriteResourceNames == [
                "source_monster_20042",
                "source_monster_20121",
                "source_monster_30044"
            ] &&
                SourceMonsterDatabaseMetrics.sourceOnlySpriteCount == 3 &&
                SourceMonsterDatabaseMetrics.sourceOnlySpriteCoverageText == "3/3" &&
                SourceMonsterDatabaseMetrics.sourceOnlySpriteNamesText == "剧毒领主 / 扁虱 / 雪山法师",
            "settings source monster database exposes source-only sprite evidence without adding runtime encounters"
        )
        expect(
            SourceMonsterDatabaseMetrics.sourceOnlySpritePreviewCount == 3 &&
                SourceMonsterDatabaseMetrics.sourceOnlySpritePreviewRows.map(\.monster.id) == [20042, 20121, 30044] &&
                SourceMonsterDatabaseMetrics.sourceOnlySpritePreviewRows.map(\.resourceName) == [
                    "source_monster_20042",
                    "source_monster_20121",
                    "source_monster_30044"
                ] &&
                SourceMonsterDatabaseMetrics.sourceOnlySpritePreviewRows.first?.title == "20042:剧毒领主" &&
                SourceMonsterDatabaseMetrics.sourceOnlySpritePreviewRows[1].subtitle == "Tick · source_monster_20121" &&
                SourceMonsterDatabaseMetrics.sourceOnlySpritePreviewRows.allSatisfy {
                    $0.boundaryText.contains("只作素材证据") &&
                    $0.boundaryText.contains("不接入战斗生成") &&
                    $0.boundaryText.contains("动作帧")
                },
            "settings source monster database previews source-only sprites as review-only artwork evidence"
        )
        let sourceOnlyProofRows = SourceMonsterDatabaseMetrics.sourceOnlyProofRows
        expect(
            SourceMonsterDatabaseMetrics.sourceOnlyProofRowCount == 3 &&
                SourceMonsterDatabaseMetrics.sourceOnlyProofCoverageText == "3/3" &&
                sourceOnlyProofRows.map(\.monster.id) == [20042, 20121, 30044] &&
                sourceOnlyProofRows.first?.title == "20042:剧毒领主" &&
                sourceOnlyProofRows.map(\.hasSourceRowProof) == [true, true, true] &&
                sourceOnlyProofRows.map(\.hasSourceOnlySpriteProof) == [true, true, true],
            "settings source monster database exposes source-only proof rows for every unmapped source monster"
        )
        let sourcePageFieldRows = SourceMonsterDatabaseMetrics.sourceOnlyPageFieldEvidenceRows
        expect(
            SourceMonsterDatabaseMetrics.sourceOnlyPageFieldEvidenceRowCount == 3 &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldSpritePathCount == 3 &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldMoveKnownCount == 3 &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldDamageKnownCount == 1 &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldRangeKnownCount == 1 &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldUnknownDamageRangeCount == 2 &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldSummaryText == "页面字段 3/3 / sprite URL 3 / Move 3 / Damage 1 / Range 1",
            "settings source monster database exposes source-page field evidence for source-only monsters"
        )
        expect(
            sourcePageFieldRows.count == 3 &&
                sourcePageFieldRows.map(\.monster.id) == [20042, 20121, 30044] &&
                sourcePageFieldRows.first?.sourceFieldText == "Move 220 / Damage — / Range —" &&
                sourcePageFieldRows[1].sourceFieldText == "Move 400 / Damage Physical / Range 130" &&
                sourcePageFieldRows[1].spritePath.contains("GiantTick") &&
                sourcePageFieldRows.last?.spritePath.contains("FrozenWizard") == true &&
                sourcePageFieldRows.allSatisfy(\.hasSpritePathProof) &&
                sourcePageFieldRows.allSatisfy(\.hasMoveProof),
            "settings source monster database records source-page sprite, Move, Damage and Range fields without runtime mapping"
        )
        expect(
            SourceMonsterDatabaseMetrics.sourceOnlyPageFieldBoundaryText.contains("sprite URL") &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldBoundaryText.contains("Move") &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldBoundaryText.contains("Damage") &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldBoundaryText.contains("Range") &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldBoundaryText.contains("不证明") &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldBoundaryText.contains("技能归属") &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldBoundaryText.contains("动作帧") &&
                SourceMonsterDatabaseMetrics.sourceOnlyPageFieldBoundaryText.contains("SFX") &&
                sourceOnlyProofRows.map(\.hasSourcePageFieldProof) == [true, true, true] &&
                sourceOnlyProofRows.first?.sourcePageFieldText == "Move 220 / Damage — / Range —" &&
                sourceOnlyProofRows[1].sourcePageFieldText == "Move 400 / Damage Physical / Range 130" &&
                sourceOnlyProofRows.last?.sourcePageFieldText == "Move 220 / Damage — / Range —",
            "settings source monster database keeps source-page fields from becoming runtime movement or skill proof"
        )
        let sourceStageAppearanceRows = SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceEvidenceRows
        expect(
            SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceEvidenceRowCount == 3 &&
                SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceConfirmedCount == 2 &&
                SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceAbsentCount == 1 &&
                SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceTotalStageRows == 14 &&
                SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceCrossCheckPageCount == 4 &&
                SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceCoverageText == "2/3" &&
                sourceStageAppearanceRows.map(\.monster.id) == [20042, 20121, 30044],
            "settings source monster database exposes source-page stage appearance evidence for source-only monsters"
        )
        expect(
            sourceStageAppearanceRows.first?.sourceEvidenceText == "怪物页 5 stage rows；关卡页 4207=74、3204=39" &&
                sourceStageAppearanceRows.first?.localRuntimeEvidenceText.contains("runtime 仍阻断") == true &&
                sourceStageAppearanceRows[1].sourceEvidenceText.contains("stage appearances 空") &&
                sourceStageAppearanceRows[1].hasSourceStageAppearance == false &&
                sourceStageAppearanceRows.last?.sourceEvidenceText == "怪物页 9 stage rows；关卡页 4303=70、2303=30" &&
                sourceStageAppearanceRows.last?.hasSourceStageAppearance == true,
            "settings source monster database records confirmed and absent source stage appearances without runtime mapping"
        )
        expect(
            SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceSummaryText == "来源出场 2/3 / monster rows 14 / stage页 4" &&
                SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceBoundaryText.contains("taskbarhero.org") &&
                SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceBoundaryText.contains("不是独立来源") &&
                SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceBoundaryText.contains("不解锁本地关卡组成") &&
                SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceBoundaryText.contains("技能归属") &&
                SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceBoundaryText.contains("动作帧") &&
                SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceBoundaryText.contains("SFX"),
            "settings source monster database keeps same-source stage appearance evidence from becoming runtime proof"
        )
        expect(
            SourceMonsterDatabaseMetrics.sourceOnlyStageProofMissingCount == 3 &&
                SourceMonsterDatabaseMetrics.sourceOnlyRuntimeBlockedCount == 3 &&
                SourceMonsterDatabaseMetrics.sourceOnlySkillOwnershipUnprovenCount == 3 &&
                SourceMonsterDatabaseMetrics.sourceOnlyAnimationFrameMissingCount == 3 &&
                SourceMonsterDatabaseMetrics.sourceOnlyOriginalSFXMissingCount == 3 &&
                sourceOnlyProofRows.allSatisfy(\.isRuntimeBlocked) &&
                sourceOnlyProofRows.allSatisfy { !$0.hasRuntimeEncounterProof } &&
                sourceOnlyProofRows.allSatisfy { !$0.hasSkillOwnershipProof } &&
                sourceOnlyProofRows.allSatisfy { !$0.hasAnimationFrameProof } &&
                sourceOnlyProofRows.allSatisfy { !$0.hasOriginalSFXProof },
            "settings source monster database keeps source-only proof rows blocked from runtime until stage, skill, animation and SFX proof exists"
        )
        expect(
            sourceOnlyProofRows.first?.verifiedEvidenceText == "源表行 + 源表 sprite source_monster_20042" &&
                sourceOnlyProofRows.first?.sourceStageAppearanceText == "怪物页 5 stage rows；关卡页 4207=74、3204=39" &&
                sourceOnlyProofRows.first?.hasSourceStageAppearanceProof == true &&
                sourceOnlyProofRows[1].sourceStageAppearanceText.contains("stage appearances 空") &&
                sourceOnlyProofRows[1].hasSourceStageAppearanceProof == false &&
                sourceOnlyProofRows.last?.sourceStageAppearanceText == "怪物页 9 stage rows；关卡页 4303=70、2303=30" &&
                sourceOnlyProofRows[1].stageProofText.contains("best-farm 无 stage code") &&
                sourceOnlyProofRows.last?.stageProofText.contains("未列出雪山法师") == true &&
                sourceOnlyProofRows.first?.skillOwnershipText.contains("#200421") == true &&
                sourceOnlyProofRows.first?.skillOwnershipText.contains("归属未证明") == true &&
                sourceOnlyProofRows.allSatisfy {
                    $0.runtimeProofText.contains("无 StageMonsterSpawn") &&
                    $0.animationProofText.contains("无 idle/attack/hit/death") &&
                    $0.missingProofText.contains("缺关卡槽位") &&
                    $0.missingProofText.contains("SFX")
                },
            "settings source monster database separates positive source-only proof from missing runtime, skill and animation proof"
        )
        expect(
            SourceMonsterDatabaseMetrics.sourceOnlyPositiveProofText == "3 源表行 / sprite 3/3" &&
                SourceMonsterDatabaseMetrics.sourceOnlyBlockedProofText == "关卡 3 / 运行时 3 / 技能 3 / 动作帧 3 / SFX 3" &&
                SourceMonsterDatabaseMetrics.sourceOnlyProofMatrixBoundaryText.contains("source-only 证明矩阵") &&
                SourceMonsterDatabaseMetrics.sourceOnlyProofMatrixBoundaryText.contains("不接入运行时") &&
                SourceMonsterDatabaseMetrics.sourceOnlyProofMatrixBoundaryText.contains("不生成怪物图") &&
                SourceMonsterDatabaseMetrics.sourceOnlyProofMatrixBoundaryText.contains("动作帧") &&
                SourceMonsterDatabaseMetrics.sourceOnlyProofMatrixBoundaryText.contains("SFX"),
            "settings source monster database keeps source-only proof matrix from fabricating runtime encounters or art"
        )
        expect(
            SourceMonsterDatabaseMetrics.stageCompositionUnmappedBoundaryText.contains("只证明源表存在") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedBoundaryText.contains("没有关卡组成") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedBoundaryText.contains("运行时遭遇") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedBoundaryText.contains("源表单张 sprite") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedBoundaryText.contains("不接入战斗生成") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedBoundaryText.contains("不复用或绘制新图"),
            "settings source monster database keeps unmapped source rows data-only"
        )
        let unmappedGateRows = Dictionary(
            uniqueKeysWithValues: SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateRows.map {
                ($0.key, $0)
            }
        )
        expect(
            SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateCount == 5 &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateRows.map(\.key) == [
                    "stage-slot",
                    "battle-art",
                    "runtime-encounter",
                    "attack-skill",
                    "animation-sfx"
                ] &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateRows.allSatisfy {
                    $0.affectedMonsterCount == SourceMonsterDatabaseMetrics.stageCompositionUnmappedCount
                },
            "settings source monster database exposes evidence gates before unmapped monsters can enter runtime"
        )
        expect(
            unmappedGateRows["stage-slot"]?.currentEvidence.contains("best-farm") == true &&
                unmappedGateRows["battle-art"]?.currentEvidence.contains("3/3") == true &&
                unmappedGateRows["battle-art"]?.currentEvidence.contains("source_monster") == true &&
                unmappedGateRows["runtime-encounter"]?.currentEvidence.contains("StageMonsterSpawn") == true &&
                unmappedGateRows["attack-skill"]?.missingEvidence.contains("技能 ID") == true &&
                unmappedGateRows["animation-sfx"]?.missingEvidence.contains("音频") == true,
            "settings source monster database keeps unmapped monster gates tied to current evidence gaps"
        )
        expect(
            SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateBoundaryText.contains("不生成关卡遭遇") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateBoundaryText.contains("源表单张 sprite") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateBoundaryText.contains("技能") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateBoundaryText.contains("掉落") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceGateBoundaryText.contains("动作帧"),
            "settings source monster database keeps unmapped monster gates from fabricating encounters or art"
        )
        let unmappedQueueRows = SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueRows
        expect(
            SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueCount == 3 &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueCoverage == SourceMonsterDatabaseMetrics.stageCompositionUnmappedCount &&
                unmappedQueueRows.map(\.monster.id) == [20042, 20121, 30044] &&
                unmappedQueueRows.first?.title == "20042:剧毒领主" &&
                unmappedQueueRows[1].currentEvidence.contains("best —") &&
                unmappedQueueRows.map(\.sourceOnlySpriteEvidence) == [
                    "源表 sprite source_monster_20042",
                    "源表 sprite source_monster_20121",
                    "源表 sprite source_monster_30044"
                ] &&
                unmappedQueueRows.first?.bestFarmStageCode == "4207" &&
                unmappedQueueRows.first?.bestFarmStageCompositionContainsMonster == false &&
                unmappedQueueRows.first?.bestFarmStageCompositionEvidence.contains("未列出剧毒领主") == true &&
                unmappedQueueRows.first?.bestFarmStageCompositionEvidence.contains("人造人:148") == true &&
                unmappedQueueRows[1].bestFarmStageCode == nil &&
                unmappedQueueRows[1].bestFarmStageCompositionEvidence.contains("best-farm 无 stage code") &&
                unmappedQueueRows.last?.bestFarmStageCode == "4303" &&
                unmappedQueueRows.last?.bestFarmStageCompositionContainsMonster == false &&
                unmappedQueueRows.last?.bestFarmStageCompositionEvidence.contains("未列出雪山法师") == true &&
                unmappedQueueRows.last?.bestFarmStageCompositionEvidence.contains("冰冻的地狱祭司:141") == true &&
                unmappedQueueRows.map(\.sourceSkillCandidateIDs) == [
                    ["200421"],
                    ["201211"],
                    ["300441"]
                ] &&
                unmappedQueueRows.first?.sourceSkillCandidateEvidence == "同前缀候选技能 #200421 Chaos BASEATTACK r800 value 1000 delivery 空" &&
                unmappedQueueRows[1].sourceSkillCandidateEvidence == "同前缀候选技能 #201211 Physical BASEATTACK r130 value 1000 delivery 空" &&
                unmappedQueueRows.last?.sourceSkillCandidateEvidence == "同前缀候选技能 #300441 Cold BASEATTACK r800 value 1000 delivery 空" &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedCandidateSkillCount == 3 &&
                unmappedQueueRows.last?.nextEvidence.contains("是否证明出场") == true,
            "settings source monster database groups unmapped rows into evidence queues"
        )
        expect(
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueBoundaryText.contains("互斥") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueBoundaryText.contains("不按源表数值") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueBoundaryText.contains("best-farm") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueBoundaryText.contains("现有单张 sprite") &&
                SourceMonsterDatabaseMetrics.stageCompositionUnmappedEvidenceQueueBoundaryText.contains("不生成关卡遭遇") &&
                unmappedQueueRows.allSatisfy { $0.nextEvidence.contains("补") || $0.nextEvidence.contains("核对") } &&
                unmappedQueueRows.allSatisfy {
                    $0.boundary.contains("不从源表数值") &&
                    $0.boundary.contains("单张 sprite") &&
                    $0.boundary.contains("ID 前缀") &&
                    $0.boundary.contains("不证明怪物技能归属") &&
                    $0.sourceSkillCandidateBoundary.contains("不证明") &&
                    $0.sourceSkillCandidateBoundary.contains("动作帧")
                },
            "settings source monster database keeps unmapped evidence queues from fabricating monsters"
        )
        expect(
            SourceMonsterDatabaseMetrics.sourceBoundaryText.contains("datamined") &&
                SourceMonsterDatabaseMetrics.sourceBoundaryText.contains("61") &&
                SourceMonsterDatabaseMetrics.runtimeBoundaryText.contains("基础 ATK/攻速标量") &&
                SourceMonsterDatabaseMetrics.runtimeBoundaryText.contains("战斗步进量化") &&
                SourceMonsterDatabaseMetrics.runtimeBoundaryText.contains("源表单张 sprite") &&
                SourceMonsterDatabaseMetrics.runtimeBoundaryText.contains("不绘制新怪物图"),
            "settings source monster database keeps data-only and art-animation boundaries explicit"
        )
    }

    private static func settingsSourceMonsterArtMapping() {
        print("[SourceMonsterArtMappingView]")

        let mappings = SourceMonsterArtMappingMetrics.mappings
        let mappingNames = Set(mappings.map(\.sourceName))
        let spriteNames = Set(mappings.map { GameArt.battleMonsterSpriteName(for: $0.runtimeMonsterID) })

        expect(
            SourceMonsterArtMappingMetrics.sourceNameCount == 49 &&
                mappingNames.count == 49 &&
                mappings.contains { $0.sourceName == "哥布林盗贼" && $0.runtimeMonsterID == "assassin_goblin" } &&
                mappings.contains { $0.sourceName == "执政官莫尔卡" && $0.runtimeMonsterID == "boss_3-10" },
            "settings monster art review exposes all 49 checked stage composition monster names"
        )
        expect(
            SourceMonsterArtMappingMetrics.officialSteamMinimumMonsterTypeCount == 50 &&
                SourceMonsterArtMappingMetrics.steamRosterIdentityCoverageText == "52/50+" &&
                SourceMonsterArtMappingMetrics.steamRosterIdentityGapCount == 0 &&
                SourceMonsterArtMappingMetrics.artMappingCoverageText == "49/52" &&
                SourceMonsterArtMappingMetrics.sourceRosterArtGapCount == 3 &&
                SourceMonsterArtMappingMetrics.sourceRosterArtGapNamesText == "剧毒领主 / 扁虱 / 雪山法师" &&
                SourceMonsterDatabaseMetrics.sourceOnlySpriteCoverageText == "3/3" &&
                SourceMonsterArtMappingMetrics.rosterBoundaryText.contains("50+") &&
                SourceMonsterArtMappingMetrics.rosterBoundaryText.contains("52/50+") &&
                SourceMonsterArtMappingMetrics.rosterBoundaryText.contains("49/52") &&
                SourceMonsterArtMappingMetrics.rosterBoundaryText.contains("单张 sprite") &&
                SourceMonsterArtMappingMetrics.rosterBoundaryText.contains("源表去重") &&
                SourceMonsterArtMappingMetrics.rosterBoundaryText.contains("关卡出场"),
            "settings monster art review separates Steam roster identity from source art coverage"
        )
        expect(
            SourceMonsterArtMappingMetrics.extractedStageSpriteCount > 0 &&
                SourceMonsterArtMappingMetrics.genericOfficialSpriteCount > 0 &&
                SourceMonsterArtMappingMetrics.typeNearApproximationCount > 0 &&
                SourceMonsterArtMappingMetrics.extractedStageSpriteCount +
                    SourceMonsterArtMappingMetrics.genericOfficialSpriteCount +
                    SourceMonsterArtMappingMetrics.typeNearApproximationCount == SourceMonsterArtMappingMetrics.sourceNameCount,
            "settings monster art review distinguishes extracted, generic and type-near sprite mappings"
        )
        expect(
            SourceMonsterArtMappingMetrics.spriteFamilyCount == spriteNames.count &&
                SourceMonsterArtMappingMetrics.slimeFallbackMappings.isEmpty &&
                SourceMonsterArtMappingMetrics.legacyUICropMappings.isEmpty,
            "settings monster art review keeps non-slime fallback and legacy crop regressions visible"
        )
        expect(
            mappings
                .filter { $0.fidelity == .typeNearApproximation }
                .contains { $0.sourceName == "燃烧的地狱祭司" && GameArt.battleMonsterSpriteName(for: $0.runtimeMonsterID) == "stage_monster_voidcaller" },
            "settings monster art review keeps approximate monster sprite reuse explicit"
        )
        let artEvidenceGateRows = Dictionary(
            uniqueKeysWithValues: SourceMonsterArtMappingMetrics.artEvidenceGateRows.map {
                ($0.key, $0)
            }
        )
        expect(
            SourceMonsterArtMappingMetrics.artEvidenceGateCount == 5 &&
                SourceMonsterArtMappingMetrics.artEvidenceGateRows.map(\.key) == [
                    "full-roster-identity",
                    "dedicated-sprite",
                    "animation-frame-set",
                    "scale-anchor",
                    "provenance-audit"
                ] &&
                SourceMonsterArtMappingMetrics.artEvidenceGateRows.allSatisfy { $0.affectedMappingCount > 0 },
            "settings monster art review exposes evidence gates before replacing approximate art"
        )
        expect(
            artEvidenceGateRows["full-roster-identity"]?.currentEvidence.contains("52/50+") == true &&
                artEvidenceGateRows["full-roster-identity"]?.currentEvidence.contains("49/52") == true &&
                artEvidenceGateRows["full-roster-identity"]?.currentEvidence.contains("3/3") == true &&
                artEvidenceGateRows["full-roster-identity"]?.missingEvidence.contains("源表未进关卡怪物") == true &&
                artEvidenceGateRows["dedicated-sprite"]?.currentEvidence.contains("近似") == true &&
                artEvidenceGateRows["animation-frame-set"]?.missingEvidence.contains("死亡") == true &&
                artEvidenceGateRows["scale-anchor"]?.missingEvidence.contains("脚底锚点") == true &&
                artEvidenceGateRows["provenance-audit"]?.currentEvidence.contains("旧裁图 0") == true,
            "settings monster art review keeps art gates tied to current roster, sprite and crop evidence"
        )
        expect(
            SourceMonsterArtMappingMetrics.artEvidenceGateBoundaryText.contains("不生成怪物图") &&
                SourceMonsterArtMappingMetrics.artEvidenceGateBoundaryText.contains("动作帧") &&
                SourceMonsterArtMappingMetrics.artEvidenceGateBoundaryText.contains("缩放") &&
                SourceMonsterArtMappingMetrics.artEvidenceGateBoundaryText.contains("音效") &&
                SourceMonsterArtMappingMetrics.artEvidenceGateBoundaryText.contains("完整图鉴"),
            "settings monster art review keeps art gates from fabricating monster assets"
        )
        let artEvidenceQueueRows = Dictionary(
            uniqueKeysWithValues: SourceMonsterArtMappingMetrics.artEvidenceQueueRows.map {
                ($0.key, $0)
            }
        )
        expect(
            SourceMonsterArtMappingMetrics.artEvidenceQueueCount == 4 &&
                SourceMonsterArtMappingMetrics.artEvidenceQueueCoverage == SourceMonsterArtMappingMetrics.sourceNameCount &&
                SourceMonsterArtMappingMetrics.artEvidenceQueueSourceRosterArtGapCoverage == SourceMonsterArtMappingMetrics.sourceRosterArtGapCount &&
                SourceMonsterArtMappingMetrics.artEvidenceQueueRows.map(\.key) == [
                    "type-near-approximation",
                    "generic-official",
                    "extracted-stage",
                    "source-roster-art-gap"
                ] &&
                artEvidenceQueueRows["type-near-approximation"]?.mappingCount == SourceMonsterArtMappingMetrics.typeNearApproximationCount &&
                artEvidenceQueueRows["generic-official"]?.mappingCount == SourceMonsterArtMappingMetrics.genericOfficialSpriteCount &&
                artEvidenceQueueRows["extracted-stage"]?.mappingCount == SourceMonsterArtMappingMetrics.extractedStageSpriteCount &&
                artEvidenceQueueRows["source-roster-art-gap"]?.mappingCount == SourceMonsterArtMappingMetrics.sourceRosterArtGapCount &&
                artEvidenceQueueRows["source-roster-art-gap"]?.currentEvidence.contains("3/3") == true &&
                artEvidenceQueueRows["source-roster-art-gap"]?.currentEvidence.contains("剧毒领主 / 扁虱 / 雪山法师") == true,
            "settings monster art review groups current art mappings into evidence queues"
        )
        expect(
            SourceMonsterArtMappingMetrics.artEvidenceQueueBoundaryText.contains("接入队列") &&
                SourceMonsterArtMappingMetrics.artEvidenceQueueBoundaryText.contains("不按近似同族") &&
                SourceMonsterArtMappingMetrics.artEvidenceQueueBoundaryText.contains("通用官方图") &&
                SourceMonsterArtMappingMetrics.artEvidenceQueueBoundaryText.contains("现有单张 sprite") &&
                SourceMonsterArtMappingMetrics.artEvidenceQueueBoundaryText.contains("不生成怪物图") &&
                SourceMonsterArtMappingMetrics.artEvidenceQueueBoundaryText.contains("动作帧") &&
                SourceMonsterArtMappingMetrics.artEvidenceQueueBoundaryText.contains("完整图鉴") &&
                SourceMonsterArtMappingMetrics.artEvidenceQueueRows.allSatisfy { $0.mappingCount > 0 } &&
                SourceMonsterArtMappingMetrics.artEvidenceQueueRows.allSatisfy {
                    $0.boundary.contains("不生成") || $0.boundary.contains("不按")
                },
            "settings monster art review keeps art evidence queues from fabricating monster assets"
        )
    }

    private static func settingsLocalSkillRuntimeCoverage() {
        print("[LocalSkillRuntimeCoverageView]")

        let sourceCountsByActivation = Dictionary(
            uniqueKeysWithValues: LocalSkillRuntimeCoverageMetrics.activationRows.map {
                ($0.activation, $0.sourceCount)
            }
        )
        let runtimeCountsByActivation = Dictionary(
            uniqueKeysWithValues: LocalSkillRuntimeCoverageMetrics.activationRows.map {
                ($0.activation, $0.runtimeCount)
            }
        )

        expect(
            LocalSkillRuntimeCoverageMetrics.sourceCount == 106 &&
                LocalSkillRuntimeCoverageMetrics.runtimeModeledCount == 46 &&
                LocalSkillRuntimeCoverageMetrics.pendingCount == 60,
            "settings local skill runtime coverage distinguishes source rows from runtime-modeled rows"
        )
        expect(
            LocalSkillRuntimeCoverageMetrics.heroNamedCount == 36 &&
                LocalSkillRuntimeCoverageMetrics.heroBaseAttackCount == 6 &&
                LocalSkillRuntimeCoverageMetrics.monsterAttackCount == 4 &&
                LocalSkillRuntimeCoverageMetrics.heroNamedCount +
                    LocalSkillRuntimeCoverageMetrics.heroBaseAttackCount +
                    LocalSkillRuntimeCoverageMetrics.monsterAttackCount ==
                    LocalSkillRuntimeCoverageMetrics.runtimeModeledCount,
            "settings local skill runtime coverage keeps named, base-attack and monster buckets explicit"
        )
        expect(
            sourceCountsByActivation[.baseAttack] == 58 &&
                sourceCountsByActivation[.baseAttackCount] == 11 &&
                sourceCountsByActivation[.cooldown] == 35 &&
                sourceCountsByActivation[.continuous] == 2,
            "settings local skill runtime coverage preserves source activation distribution"
        )
        expect(
            runtimeCountsByActivation[.baseAttack] == 10 &&
                runtimeCountsByActivation[.baseAttackCount] == 9 &&
                runtimeCountsByActivation[.cooldown] == 25 &&
                runtimeCountsByActivation[.continuous] == 2,
            "settings local skill runtime coverage preserves runtime activation distribution"
        )
        expect(
            LocalSkillRuntimeCoverageMetrics.pendingSkillIDs.count == 60 &&
                LocalSkillRuntimeCoverageMetrics.pendingPreviewText.hasPrefix("100111") &&
                LocalSkillRuntimeCoverageMetrics.activationRows.first { $0.activation == .continuous }?.pendingCount == 0,
            "settings local skill runtime coverage keeps pending source skill rows visible"
        )
        expect(
            LocalSkillRuntimeCoverageMetrics.sourceCatalogBoundaryText.contains("不等于") &&
                LocalSkillRuntimeCoverageMetrics.pendingRuntimeBoundaryText.contains("不伪造") &&
                LocalSkillRuntimeCoverageMetrics.monsterBoundaryText.contains("待核对"),
            "settings local skill runtime coverage keeps source-data and unknown-runtime boundaries explicit"
        )
    }

    private static func settingsPendingSourceSkillReview() {
        print("[PendingSourceSkillReviewView]")

        let activationCounts = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.activationRows.map {
                ($0.key, $0.count)
            }
        )
        let damageCounts = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.damageRows.map {
                ($0.key, $0.count)
            }
        )
        let activationDamageQueueRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.activationDamageQueueRows.map {
                ($0.id, $0)
            }
        )
        let rangeEvidenceQueueRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.rangeEvidenceQueueRows.map {
                ($0.id, $0)
            }
        )
        let sourcePrefixCounts = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.sourcePrefixRows.map {
                ($0.key, $0.count)
            }
        )
        let responsibilityCounts = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.responsibilityRows.map {
                ($0.key, $0.count)
            }
        )
        let baseAttackManifestRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.pendingBaseAttackCandidatePrefixRows.map {
                ($0.key, $0)
            }
        )
        let rangeCounts = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.rangeRows.map {
                ($0.key, $0.count)
            }
        )
        let readinessRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.readinessRows.map {
                ($0.key, $0)
            }
        )
        let runtimeGateRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.runtimeGateRows.map {
                ($0.key, $0)
            }
        )
        let runtimeProofRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.runtimeProofRows.map {
                ($0.key, $0)
            }
        )
        let evidenceQueueRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.evidenceQueueRows.map {
                ($0.key, $0)
            }
        )
        let prefixEvidenceQueueRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.prefixEvidenceQueueRows.map {
                ($0.id, $0)
            }
        )
        let valueEvidenceQueueRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.valueEvidenceQueueRows.map {
                ($0.id, $0)
            }
        )
        let visualPriorityRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.visualPriorityRows.map {
                ($0.id, $0)
            }
        )
        let visualPriorityUnqueuedQueueRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.visualPriorityUnqueuedQueueRows.map {
                ($0.key, $0)
            }
        )
        let visualPriorityUnqueuedActivationRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.visualPriorityUnqueuedActivationRows.map {
                ($0.key, $0)
            }
        )
        let visualPriorityUnqueuedDamageRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.visualPriorityUnqueuedDamageRows.map {
                ($0.key, $0)
            }
        )
        let visualPriorityUnqueuedRangeRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.visualPriorityUnqueuedRangeRows.map {
                ($0.key, $0)
            }
        )
        let unmappedMonsterCandidateRows = PendingSourceSkillReviewMetrics.unmappedMonsterCandidateRows
        let cooldownChaosPageRows = Dictionary(
            uniqueKeysWithValues: PendingSourceSkillReviewMetrics.cooldownChaosPageEvidenceRows.map {
                ($0.id, $0)
            }
        )

        expect(
            PendingSourceSkillReviewMetrics.pendingCount == 60 &&
                PendingSourceSkillReviewMetrics.emptyDeliveryCount == 60 &&
                PendingSourceSkillReviewMetrics.pendingPreviewText.hasPrefix("100111"),
            "settings pending source skill review keeps the data-only pending rows visible"
        )
        expect(
            activationCounts["BASEATTACK"] == 48 &&
                activationCounts["BASEATTACK_COUNT"] == 2 &&
                activationCounts["COOLDOWN"] == 10 &&
                activationCounts["CONTINUOUS"] == nil,
            "settings pending source skill review preserves pending activation buckets"
        )
        expect(
            damageCounts["Physical"] == 46 &&
                damageCounts["Fire"] == 6 &&
                damageCounts["Cold"] == 1 &&
                damageCounts["Chaos"] == 7 &&
                damageCounts["Lightning"] == nil,
            "settings pending source skill review preserves pending damage buckets"
        )
        expect(
            PendingSourceSkillReviewMetrics.activationDamageQueueCount == 7 &&
                PendingSourceSkillReviewMetrics.activationDamageQueueCoverageCount == PendingSourceSkillReviewMetrics.pendingCount &&
                PendingSourceSkillReviewMetrics.activationDamageValueCoverageCount == 15 &&
                PendingSourceSkillReviewMetrics.activationDamageEmptyDeliveryCount == PendingSourceSkillReviewMetrics.pendingCount &&
                PendingSourceSkillReviewMetrics.activationDamageQueueRows.map(\.id) == [
                    "BASEATTACK-Physical",
                    "BASEATTACK-Fire",
                    "BASEATTACK-Cold",
                    "BASEATTACK-Chaos",
                    "BASEATTACK_COUNT-Physical",
                    "COOLDOWN-Physical",
                    "COOLDOWN-Chaos"
                ] &&
                activationDamageQueueRows["BASEATTACK-Physical"]?.count == 37 &&
                activationDamageQueueRows["BASEATTACK-Fire"]?.count == 6 &&
                activationDamageQueueRows["BASEATTACK-Cold"]?.count == 1 &&
                activationDamageQueueRows["BASEATTACK-Chaos"]?.count == 4 &&
                activationDamageQueueRows["BASEATTACK_COUNT-Physical"]?.count == 2 &&
                activationDamageQueueRows["COOLDOWN-Physical"]?.count == 7 &&
                activationDamageQueueRows["COOLDOWN-Chaos"]?.count == 3 &&
                activationDamageQueueRows["COOLDOWN-Chaos"]?.valueCount == 3 &&
                activationDamageQueueRows["BASEATTACK-Physical"]?.sampleIDs.prefix(3) == ["100111", "100211", "100221"] &&
                PendingSourceSkillReviewMetrics.activationDamageQueueBoundaryText.contains("activation × damage") &&
                PendingSourceSkillReviewMetrics.activationDamageQueueBoundaryText.contains("不按触发类型") &&
                PendingSourceSkillReviewMetrics.activationDamageQueueBoundaryText.contains("伤害类型") &&
                PendingSourceSkillReviewMetrics.activationDamageQueueBoundaryText.contains("value"),
            "settings pending source skill review groups pending skills by activation and damage without runtime semantics"
        )
        expect(
            PendingSourceSkillReviewMetrics.rangeEvidenceQueueCount == 13 &&
                PendingSourceSkillReviewMetrics.rangeEvidenceQueueCoverageCount == PendingSourceSkillReviewMetrics.pendingCount &&
                PendingSourceSkillReviewMetrics.rangeEvidenceQueueValueCoverageCount == 15 &&
                PendingSourceSkillReviewMetrics.rangeEvidenceQueueEmptyDeliveryCount == PendingSourceSkillReviewMetrics.pendingCount &&
                PendingSourceSkillReviewMetrics.rangeEvidenceQueueRows.first?.id == "range-130" &&
                PendingSourceSkillReviewMetrics.rangeEvidenceQueueRows.last?.id == "range-900" &&
                rangeEvidenceQueueRows["range-130"]?.currentEvidence == "5 行 / 1 value / 5 空 delivery / BASEATTACK 5 / Physical 5" &&
                rangeEvidenceQueueRows["range-600"]?.currentEvidence == "3 行 / 3 value / 3 空 delivery / BASEATTACK_COUNT 1 / COOLDOWN 2 / Physical 2 / Chaos 1" &&
                rangeEvidenceQueueRows["range-800"]?.currentEvidence == "8 行 / 3 value / 8 空 delivery / BASEATTACK 7 / COOLDOWN 1 / Physical 1 / Fire 4 / Cold 1 / Chaos 2" &&
                rangeEvidenceQueueRows["range-800"]?.sampleIDs.prefix(3) == ["100231", "200421", "200911"] &&
                PendingSourceSkillReviewMetrics.rangeEvidenceQueueBoundaryText.contains("range 队列") &&
                PendingSourceSkillReviewMetrics.rangeEvidenceQueueBoundaryText.contains("不按 range 数值"),
            "settings pending source skill review groups pending skills by source range without runtime semantics"
        )
        expect(
            PendingSourceSkillReviewMetrics.valueEvidenceQueueCount == 8 &&
                PendingSourceSkillReviewMetrics.valueEvidenceQueueCoverageCount == 15 &&
                PendingSourceSkillReviewMetrics.valueEvidenceQueueEmptyDeliveryCount == 15 &&
                PendingSourceSkillReviewMetrics.valueEvidenceQueueRows.map(\.id) == [
                    "value-800",
                    "value-1000",
                    "value-1350",
                    "value-1500",
                    "value-1700",
                    "value-1800",
                    "value-2000",
                    "value-2300"
                ] &&
                valueEvidenceQueueRows["value-800"]?.sampleIDs == ["309021"] &&
                valueEvidenceQueueRows["value-1000"]?.sampleIDs == ["200421", "201211", "300441"] &&
                valueEvidenceQueueRows["value-1000"]?.currentEvidence == "3 行 / 3 空 delivery / r130 1 / r800 2 / BASEATTACK 3 / Physical 1 / Cold 1 / Chaos 1" &&
                valueEvidenceQueueRows["value-1500"]?.count == 5 &&
                valueEvidenceQueueRows["value-1500"]?.sampleIDs == ["109021", "109031", "109041", "109051", "309031"] &&
                valueEvidenceQueueRows["value-2300"]?.count == 2 &&
                valueEvidenceQueueRows["value-2300"]?.sampleIDs == ["209041", "309051"] &&
                valueEvidenceQueueRows["value-1500"]?.currentEvidence == "5 行 / 5 空 delivery / r300 1 / r450 1 / r700 2 / r800 1 / BASEATTACK_COUNT 1 / COOLDOWN 4 / Physical 5" &&
                valueEvidenceQueueRows["value-2300"]?.currentEvidence == "2 行 / 2 空 delivery / r270 1 / r600 1 / COOLDOWN 2 / Physical 1 / Chaos 1" &&
                PendingSourceSkillReviewMetrics.valueEvidenceQueueBoundaryText.contains("value 队列") &&
                PendingSourceSkillReviewMetrics.valueEvidenceQueueBoundaryText.contains("不按 value"),
            "settings pending source skill review groups value-checked skills by source value without runtime formulas"
        )
        expect(
            sourcePrefixCounts["1"] == 16 &&
                sourcePrefixCounts["2"] == 21 &&
                sourcePrefixCounts["3"] == 23 &&
                PendingSourceSkillReviewMetrics.sourcePrefixRows.count == 3,
            "settings pending source skill review preserves pending source ID ranges"
        )
        expect(
            PendingSourceSkillReviewMetrics.prefixEvidenceQueueCount == 3 &&
                PendingSourceSkillReviewMetrics.prefixEvidenceQueueCoverageCount == PendingSourceSkillReviewMetrics.pendingCount &&
                PendingSourceSkillReviewMetrics.prefixEvidenceQueueValueCoverageCount == 15 &&
                PendingSourceSkillReviewMetrics.prefixEvidenceQueueEmptyDeliveryCount == PendingSourceSkillReviewMetrics.pendingCount &&
                PendingSourceSkillReviewMetrics.prefixEvidenceQueueRows.map(\.id) == [
                    "prefix-1",
                    "prefix-2",
                    "prefix-3"
                ] &&
                prefixEvidenceQueueRows["prefix-1"]?.count == 16 &&
                prefixEvidenceQueueRows["prefix-2"]?.count == 21 &&
                prefixEvidenceQueueRows["prefix-3"]?.count == 23 &&
                prefixEvidenceQueueRows["prefix-1"]?.currentEvidence == "16 行 / 4 value / 16 空 delivery / BASEATTACK 12 / BASEATTACK_COUNT 1 / COOLDOWN 3 / Physical 15 / Fire 1" &&
                prefixEvidenceQueueRows["prefix-2"]?.currentEvidence == "21 行 / 6 value / 21 空 delivery / BASEATTACK 17 / BASEATTACK_COUNT 1 / COOLDOWN 3 / Physical 18 / Fire 1 / Chaos 2" &&
                prefixEvidenceQueueRows["prefix-3"]?.currentEvidence == "23 行 / 5 value / 23 空 delivery / BASEATTACK 19 / COOLDOWN 4 / Physical 13 / Fire 4 / Cold 1 / Chaos 5" &&
                prefixEvidenceQueueRows["prefix-1"]?.sampleIDs.prefix(3) == ["100111", "100211", "100221"] &&
                prefixEvidenceQueueRows["prefix-3"]?.sampleIDs.suffix(3) == ["309031", "309041", "309051"] &&
                PendingSourceSkillReviewMetrics.prefixEvidenceQueueBoundaryText.contains("ID 前缀队列") &&
                PendingSourceSkillReviewMetrics.prefixEvidenceQueueBoundaryText.contains("源表命名空间") &&
                PendingSourceSkillReviewMetrics.prefixEvidenceQueueBoundaryText.contains("不按前缀"),
            "settings pending source skill review groups pending skills by source ID prefix without runtime semantics"
        )
        expect(
            PendingSourceSkillReviewMetrics.activationRows.first { $0.key == "BASEATTACK" }?.sampleIDs.prefix(2) == ["100111", "100211"] &&
                PendingSourceSkillReviewMetrics.damageRows.first { $0.key == "Chaos" }?.sampleIDs.first == "200411",
            "settings pending source skill review keeps source-order samples visible"
        )
        expect(
            PendingSourceSkillReviewMetrics.pendingDamageCandidateSkills("Physical").map(\.id) == [
                "100111", "100211", "100221", "100311",
                "100411", "100421", "100431", "100511",
                "100521", "100531", "109011", "109021",
                "109031", "109041", "109051", "200111",
                "200211", "200221", "200231", "200241",
                "200311", "200511", "200611", "200621",
                "200711", "200811", "201111", "201211",
                "209011", "209021", "209031", "209041",
                "209051", "300111", "300121", "300131",
                "300211", "300411", "300421", "300431",
                "300511", "300811", "300831", "300841",
                "301111", "309031"
            ] &&
            PendingSourceSkillReviewMetrics.pendingChaosDamageCandidateSkills.count == 7 &&
                PendingSourceSkillReviewMetrics.pendingChaosDamageCandidateIDs == [
                    "200411", "200421", "300711", "309011",
                    "309021", "309041", "309051"
                ] &&
                PendingSourceSkillReviewMetrics.pendingDamageCandidateSkills("Fire").map(\.id) == [
                    "100231", "200911", "300311", "300611", "300821", "300911"
                ] &&
                PendingSourceSkillReviewMetrics.pendingDamageCandidateSkills("Cold").map(\.id) == ["300441"] &&
                PendingSourceSkillReviewMetrics.pendingDamageCandidateRows.count == 4 &&
                PendingSourceSkillReviewMetrics.pendingDamageCandidateRows.map(\.count).reduce(0, +) == 60 &&
                PendingSourceSkillReviewMetrics.pendingDamageCandidateSummaryText == "Physical 46 / Fire 6 / Cold 1 / Chaos 7" &&
                PendingSourceSkillReviewMetrics.pendingDamageCandidateIDText.contains("Physical:100111,100211,100221,100311") &&
                PendingSourceSkillReviewMetrics.pendingDamageCandidateIDText.contains("309031") &&
                PendingSourceSkillReviewMetrics.pendingElementalDamageCandidateRows.count == 3 &&
                PendingSourceSkillReviewMetrics.pendingElementalDamageCandidateRows.map(\.count).reduce(0, +) == 14 &&
                PendingSourceSkillReviewMetrics.pendingElementalDamageCandidateSummaryText == "Fire 6 / Cold 1 / Chaos 7" &&
                PendingSourceSkillReviewMetrics.pendingElementalDamageCandidateIDText.contains("Fire:100231,200911,300311,300611,300821,300911") &&
                PendingSourceSkillReviewMetrics.pendingChaosDamageCandidateIDText == "200411, 200421, 300711, 309011, 309021, 309041, 309051" &&
                PendingSourceSkillReviewMetrics.pendingChaosDamageCandidateRow.count == 7 &&
                PendingSourceSkillReviewMetrics.pendingChaosDamageCandidateRow.sampleIDs.last == "309051",
            "settings pending source skill review exposes complete pending damage source manifests"
        )
        expect(
            PendingSourceSkillReviewMetrics.visualPriorityQueueCount == 4 &&
                PendingSourceSkillReviewMetrics.visualPriorityTotalEntries == 22 &&
                PendingSourceSkillReviewMetrics.visualPriorityUniqueSkillCount == 16 &&
                PendingSourceSkillReviewMetrics.visualPriorityOverlapCount == 6 &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedPendingCount == 44 &&
                PendingSourceSkillReviewMetrics.visualPriorityCoverageText == "16/60" &&
                PendingSourceSkillReviewMetrics.visualPriorityUniqueSkillIDs == [
                    "100231", "200411", "200421", "200911",
                    "201211", "209041", "300311", "300441",
                    "300611", "300711", "300821", "300911",
                    "309011", "309021", "309041", "309051"
                ] &&
                PendingSourceSkillReviewMetrics.visualPriorityRows.map(\.id) == [
                    "elemental-vfx",
                    "cooldown-chaos",
                    "unmapped-monster-prefix",
                    "highest-value-pages"
                ] &&
                PendingSourceSkillReviewMetrics.pendingElementalDamageCandidateSkills.map(\.id).first == "100231" &&
                PendingSourceSkillReviewMetrics.pendingElementalDamageCandidateSkills.map(\.id).last == "309051" &&
                PendingSourceSkillReviewMetrics.pendingElementalValueCount == 5 &&
                PendingSourceSkillReviewMetrics.pendingElementalEmptyDeliveryCount == 14 &&
                PendingSourceSkillReviewMetrics.highestPendingValueSkillsForReview.map(\.id) == ["209041", "309051"],
            "settings pending source skill review exposes visual-priority evidence queues for art and effect review"
        )
        expect(
            PendingSourceSkillReviewMetrics.visualReviewTotalQueueCount == 6 &&
                PendingSourceSkillReviewMetrics.visualReviewTotalCoverageCount == PendingSourceSkillReviewMetrics.pendingCount &&
                PendingSourceSkillReviewMetrics.visualReviewTotalCoverageText == "60/60" &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedQueueCoverageCount == PendingSourceSkillReviewMetrics.visualPriorityUnqueuedPendingCount &&
                PendingSourceSkillReviewMetrics.visualReviewTotalCoverageBoundaryText.contains("优先队列") &&
                PendingSourceSkillReviewMetrics.visualReviewTotalCoverageBoundaryText.contains("低优先 backlog") &&
                PendingSourceSkillReviewMetrics.visualReviewTotalCoverageBoundaryText.contains("不按覆盖状态生成"),
            "settings pending source skill review covers every pending skill with either a priority or backlog visual-review queue"
        )
        expect(
            visualPriorityRows["elemental-vfx"]?.count == 14 &&
                visualPriorityRows["elemental-vfx"]?.valueCount == 5 &&
                visualPriorityRows["elemental-vfx"]?.currentEvidence == "Fire 6 / Cold 1 / Chaos 7；5 value；14 空 delivery" &&
                visualPriorityRows["cooldown-chaos"]?.sampleIDs == ["309021", "309041", "309051"] &&
                visualPriorityRows["cooldown-chaos"]?.valueCount == 3 &&
                visualPriorityRows["unmapped-monster-prefix"]?.sampleIDs == ["200421", "201211", "300441"] &&
                visualPriorityRows["highest-value-pages"]?.sampleIDs == ["209041", "309051"],
            "settings pending source skill review keeps visual-priority queues tied to current source evidence"
        )
        expect(
            PendingSourceSkillReviewMetrics.visualPriorityUnqueuedSkillIDs == [
                "100111", "100211", "100221", "100311",
                "100411", "100421", "100431", "100511",
                "100521", "100531", "109011", "109021",
                "109031", "109041", "109051", "200111",
                "200211", "200221", "200231", "200241",
                "200311", "200511", "200611", "200621",
                "200711", "200811", "201111", "209011",
                "209021", "209031", "209051", "300111",
                "300121", "300131", "300211", "300411",
                "300421", "300431", "300511", "300811",
                "300831", "300841", "301111", "309031"
            ] &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedSkills.count == 44 &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedQueueCount == 2 &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedQueueCoverageCount == 44 &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedValueCount == 8 &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedEmptyDeliveryCount == 44,
            "settings pending source skill review exposes the complete visual-priority unqueued diff"
        )
        expect(
            PendingSourceSkillReviewMetrics.visualPriorityUnqueuedQueueRows.map(\.key) == [
                "unqueued-physical-value-pages",
                "unqueued-physical-baseattack-catalog"
            ] &&
                visualPriorityUnqueuedQueueRows["unqueued-physical-value-pages"]?.count == 8 &&
                visualPriorityUnqueuedQueueRows["unqueued-physical-value-pages"]?.sampleIDs == [
                    "109021", "109031", "109041", "109051",
                    "209021", "209031", "209051", "309031"
                ] &&
                visualPriorityUnqueuedQueueRows["unqueued-physical-baseattack-catalog"]?.count == 36 &&
                visualPriorityUnqueuedQueueRows["unqueued-physical-baseattack-catalog"]?.sampleIDs.first == "100111" &&
                visualPriorityUnqueuedQueueRows["unqueued-physical-baseattack-catalog"]?.sampleIDs.last == "301111",
            "settings pending source skill review groups visual-priority unqueued skills into explicit review queues"
        )
        expect(
            PendingSourceSkillReviewMetrics.visualPriorityUnqueuedActivationRows.map(\.key) == [
                "unqueued-activation-BASEATTACK",
                "unqueued-activation-BASEATTACK_COUNT",
                "unqueued-activation-COOLDOWN"
            ] &&
                visualPriorityUnqueuedActivationRows["unqueued-activation-BASEATTACK"]?.count == 36 &&
                visualPriorityUnqueuedActivationRows["unqueued-activation-BASEATTACK_COUNT"]?.count == 2 &&
                visualPriorityUnqueuedActivationRows["unqueued-activation-COOLDOWN"]?.count == 6 &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedDamageRows.count == 1 &&
                visualPriorityUnqueuedDamageRows["unqueued-damage-Physical"]?.count == 44 &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedRangeRows.count == 12 &&
                visualPriorityUnqueuedRangeRows["unqueued-range-150"]?.count == 9 &&
                visualPriorityUnqueuedRangeRows["unqueued-range-170"]?.count == 7 &&
                visualPriorityUnqueuedRangeRows["unqueued-range-200"]?.count == 6 &&
                visualPriorityUnqueuedRangeRows["unqueued-range-800"]?.count == 1,
            "settings pending source skill review breaks visual-priority unqueued skills down by activation, damage and range"
        )
        expect(
            PendingSourceSkillReviewMetrics.visualPriorityUnqueuedBoundaryText.contains("视觉复核差集") &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedBoundaryText.contains("Physical 源行") &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedBoundaryText.contains("不按未入队状态") &&
                PendingSourceSkillReviewMetrics.visualPriorityUnqueuedQueueRows.allSatisfy {
                    $0.nextEvidence.contains("动作帧") &&
                        $0.boundary.contains("不")
                },
            "settings pending source skill review keeps visual-priority unqueued queues from fabricating effects"
        )
        expect(
            PendingSourceSkillReviewMetrics.visualPriorityBoundaryText.contains("可重叠") &&
                PendingSourceSkillReviewMetrics.visualPriorityBoundaryText.contains("原版画面") &&
                PendingSourceSkillReviewMetrics.visualPriorityBoundaryText.contains("不按元素") &&
                PendingSourceSkillReviewMetrics.visualPriorityBoundaryText.contains("不") &&
                PendingSourceSkillReviewMetrics.visualPriorityBoundaryText.contains("生成素材") &&
                PendingSourceSkillReviewMetrics.visualPriorityRows.allSatisfy {
                    $0.nextEvidence.contains("动作帧") &&
                        $0.boundary.contains("不")
                },
            "settings pending source skill review keeps visual-priority queues from fabricating art or effects"
        )
        expect(
            PendingSourceSkillReviewMetrics.noRuntimeSemanticsBoundaryText.contains("不生成") &&
                PendingSourceSkillReviewMetrics.emptyDeliveryBoundaryText.contains("不伪造") &&
                PendingSourceSkillReviewMetrics.monsterOwnershipBoundaryText.contains("待核对"),
            "settings pending source skill review keeps no-runtime and unknown-ownership boundaries explicit"
        )
        expect(
            responsibilityCounts["sixDigitUnnamed"] == 60 &&
                responsibilityCounts["pendingBaseAttack"] == 48 &&
                responsibilityCounts["pendingTriggered"] == 12 &&
                responsibilityCounts["checkedMonsterAttack"] == 4 &&
                PendingSourceSkillReviewMetrics.responsibilityRows.count == 4,
            "settings pending source skill review preserves pending responsibility buckets"
        )
        expect(
            PendingSourceSkillReviewMetrics.pendingBaseAttackCandidatePrefixRows.count == 3 &&
                baseAttackManifestRows["baseAttack-1"]?.count == 12 &&
                baseAttackManifestRows["baseAttack-1"]?.sampleIDs.first == "100111" &&
                baseAttackManifestRows["baseAttack-1"]?.sampleIDs.last == "109011" &&
                baseAttackManifestRows["baseAttack-2"]?.count == 17 &&
                baseAttackManifestRows["baseAttack-2"]?.sampleIDs.first == "200111" &&
                baseAttackManifestRows["baseAttack-2"]?.sampleIDs.last == "209011" &&
                baseAttackManifestRows["baseAttack-3"]?.count == 19 &&
                baseAttackManifestRows["baseAttack-3"]?.sampleIDs.first == "300111" &&
                baseAttackManifestRows["baseAttack-3"]?.sampleIDs.last == "309011",
            "settings pending source skill review exposes complete base-attack candidate manifests by source prefix"
        )
        expect(
            PendingSourceSkillReviewMetrics.sixDigitUnnamedPendingSkills.first?.id == "100111" &&
                PendingSourceSkillReviewMetrics.pendingTriggeredCandidateSkills.map(\.id).prefix(3) == ["109021", "109031", "109041"] &&
                PendingSourceSkillReviewMetrics.pendingTriggeredCandidateIDs == [
                    "109021", "109031", "109041", "109051",
                    "209021", "209031", "209041", "209051",
                    "309021", "309031", "309041", "309051"
                ] &&
                PendingSourceSkillReviewMetrics.pendingTriggeredCandidateIDText.contains("309051") &&
                PendingSourceSkillReviewMetrics.checkedMonsterAttackSkills.map(\.id) == ["301015", "301025", "301035", "301045"],
            "settings pending source skill review distinguishes data-only candidates from checked monster attacks"
        )
        expect(
            PendingSourceSkillReviewMetrics.pendingTriggeredValueSkills.map(\.id) == [
                "109021", "109031", "109041", "109051",
                "209021", "209031", "209041", "209051",
                "309021", "309031", "309041", "309051"
            ] &&
                PendingSourceSkillReviewMetrics.pendingTriggeredValueSkills.compactMap(\.sourceValue) == [
                    1500, 1500, 1500, 1500,
                    1800, 1350, 2300, 2000,
                    800, 1500, 1700, 2300
                ] &&
                PendingSourceSkillReviewMetrics.pendingTriggeredValueText == "109021=1500/r450; 109031=1500/r700; 109041=1500/r300; 109051=1500/r700; 209021=1800/r250; 209031=1350/r600; 209041=2300/r270; 209051=2000/r600; 309021=800/r700; 309031=1500/r800; 309041=1700/r700; 309051=2300/r600" &&
                PendingSourceSkillReviewMetrics.pendingTriggeredValueCount == 12 &&
                PendingSourceSkillReviewMetrics.triggeredValueBoundaryText.contains("不推导"),
            "settings pending source skill review exposes checked triggered source values without runtime semantics"
        )
        expect(
            PendingSourceSkillReviewMetrics.pendingValuedCandidateCount == 15 &&
                PendingSourceSkillReviewMetrics.pendingValuedEmptyDeliveryCount == 15 &&
                PendingSourceSkillReviewMetrics.pendingValuedUnnamedCount == 15 &&
                PendingSourceSkillReviewMetrics.highestPendingValueText == "209041=2300/r270; 309051=2300/r600" &&
                PendingSourceSkillReviewMetrics.highestPendingValueDetailPathText == "209041=/zh/skills/active/id-209041/; 309051=/zh/skills/active/id-309051/" &&
                PendingSourceSkillReviewMetrics.highestPendingValueDetailEvidenceText == "2 页 / Skill ID / 无说明 / 空 delivery" &&
                PendingSourceSkillReviewMetrics.pendingValueDetailLocalePageCount == 30 &&
                PendingSourceSkillReviewMetrics.pendingValueDetailSnapshotText == "30 中英页 / v1.00.13 / Skill ID / 无说明 / delivery — / 命中类型 —" &&
                PendingSourceSkillReviewMetrics.highestPendingValueLocalePageCount == 4 &&
                PendingSourceSkillReviewMetrics.highestPendingValueSnapshotText == "4 中英页 / v1.00.13 / Skill ID / 无说明 / delivery —" &&
                PendingSourceSkillReviewMetrics.pendingValueReadinessText == "15 value / 15 未命名 / 15 空形态" &&
                PendingSourceSkillReviewMetrics.pendingValueDetailSkills.map(\.id) == [
                    "109021", "109031", "109041", "109051",
                    "200421", "201211",
                    "209021", "209031", "209041", "209051",
                    "300441",
                    "309021", "309031", "309041", "309051"
                ] &&
                PendingSourceSkillReviewMetrics.pendingValueDetailEvidenceText == "15 页 / Skill ID / 无说明 / 空 delivery / 命中类型 —" &&
                PendingSourceSkillReviewMetrics.pendingValueDetailPathText.hasPrefix("109021=/zh/skills/active/id-109021/") &&
                PendingSourceSkillReviewMetrics.pendingValueDetailPathText.hasSuffix("309051=/zh/skills/active/id-309051/") &&
                PendingSourceSkillReviewMetrics.sourcePageSnapshotBoundaryText.contains("v1.00.13") &&
                PendingSourceSkillReviewMetrics.sourcePageSnapshotBoundaryText.contains("不是第二独立来源") &&
                PendingSourceSkillReviewMetrics.sourceValueReadinessBoundaryText.contains("才可接入 runtime") &&
                PendingSourceSkillReviewMetrics.valueDetailBoundaryText.contains("只证明数值/范围") &&
                PendingSourceSkillReviewMetrics.highestValueDetailBoundaryText.contains("无本地化说明"),
            "settings pending source skill review verifies all value-checked detail pages without marking them runtime-ready"
        )
        expect(
            PendingSourceSkillReviewMetrics.valueEvidenceRowCount == 15 &&
                PendingSourceSkillReviewMetrics.valueEvidenceCoverageText == "15/15" &&
                PendingSourceSkillReviewMetrics.valueEvidenceRows.map(\.id) == [
                    "109021", "109031", "109041", "109051",
                    "200421", "201211",
                    "209021", "209031", "209041", "209051",
                    "300441",
                    "309021", "309031", "309041", "309051"
                ] &&
                PendingSourceSkillReviewMetrics.valueEvidenceRows.first?.currentEvidence == "Physical · range 450 · value 1500 · delivery 空" &&
                PendingSourceSkillReviewMetrics.valueEvidenceRows.first?.detailPath == "/zh/skills/active/id-109021/" &&
                PendingSourceSkillReviewMetrics.valueEvidenceRows.last?.currentEvidence == "Chaos · range 600 · value 2300 · delivery 空",
            "settings pending source skill review expands value-checked candidates into per-skill evidence rows"
        )
        expect(
            PendingSourceSkillReviewMetrics.valueEvidenceRows.allSatisfy {
                $0.missingEvidence.contains("本地化名称") &&
                    $0.missingEvidence.contains("动作帧") &&
                    $0.boundary.contains("不以单页 value/range") &&
                    $0.boundary.contains("不") &&
                    $0.boundary.contains("音效")
            },
            "settings pending source skill review keeps value evidence rows from fabricating runtime effects"
        )
        expect(
            PendingSourceSkillReviewMetrics.catalogOnlyPendingCount == 45 &&
                PendingSourceSkillReviewMetrics.valueRangeOnlyPendingCount == 15 &&
                PendingSourceSkillReviewMetrics.minimumEvidencePendingCount == 0 &&
                PendingSourceSkillReviewMetrics.readinessRows.count == 3 &&
                PendingSourceSkillReviewMetrics.readinessRows.map(\.count).reduce(0, +) == PendingSourceSkillReviewMetrics.pendingCount &&
                readinessRows["catalogOnly"]?.sampleIDs.prefix(2) == ["100111", "100211"] &&
                readinessRows["valueRangeOnly"]?.sampleIDs.first == "109021" &&
                readinessRows["minimumEvidence"]?.sampleText == "无" &&
                PendingSourceSkillReviewMetrics.readinessBoundaryText.contains("互斥") &&
                PendingSourceSkillReviewMetrics.readinessBoundaryText.contains("动作帧"),
            "settings pending source skill review separates catalog-only, value-range-only and minimum-evidence readiness without promoting skills to runtime"
        )
        expect(
            PendingSourceSkillReviewMetrics.runtimeProofRowCount == 7 &&
                PendingSourceSkillReviewMetrics.runtimeProofCoverageCount == PendingSourceSkillReviewMetrics.pendingCount &&
                PendingSourceSkillReviewMetrics.runtimeProofCoverageText == "60/60" &&
                PendingSourceSkillReviewMetrics.runtimeProofCatalogCount == 60 &&
                PendingSourceSkillReviewMetrics.runtimeProofValueRangeCount == 15 &&
                PendingSourceSkillReviewMetrics.runtimeProofMinimumReadyCount == 0 &&
                PendingSourceSkillReviewMetrics.runtimeProofRows.map(\.key) == [
                    "source-catalog",
                    "value-range-detail",
                    "localized-identity",
                    "delivery-hit-shape",
                    "ownership-target-formula",
                    "animation-vfx",
                    "audio-sfx"
                ],
            "settings pending source skill review exposes a runtime proof matrix for every pending source skill"
        )
        expect(
            runtimeProofRows["source-catalog"]?.provedCount == 60 &&
                runtimeProofRows["source-catalog"]?.missingCount == 0 &&
                runtimeProofRows["source-catalog"]?.currentEvidence.contains("SourceSkillCatalog") == true &&
                runtimeProofRows["value-range-detail"]?.provedCount == 15 &&
                runtimeProofRows["value-range-detail"]?.missingCount == 45 &&
                runtimeProofRows["value-range-detail"]?.currentEvidence.contains("15 页") == true &&
                runtimeProofRows["localized-identity"]?.provedCount == 0 &&
                runtimeProofRows["localized-identity"]?.missingCount == 60 &&
                runtimeProofRows["delivery-hit-shape"]?.provedCount == 0 &&
                runtimeProofRows["delivery-hit-shape"]?.missingCount == 60 &&
                runtimeProofRows["ownership-target-formula"]?.missingCount == 60,
            "settings pending source skill review separates existing catalog and value proof from missing identity, delivery and formula proof"
        )
        expect(
            PendingSourceSkillReviewMetrics.runtimeProofLocalizedMissingCount == 60 &&
                PendingSourceSkillReviewMetrics.runtimeProofDeliveryMissingCount == 60 &&
                PendingSourceSkillReviewMetrics.runtimeProofOwnershipFormulaMissingCount == 60 &&
                PendingSourceSkillReviewMetrics.runtimeProofAnimationMissingCount == 60 &&
                PendingSourceSkillReviewMetrics.runtimeProofSFXMissingCount == 60 &&
                runtimeProofRows["animation-vfx"]?.provedCount == 0 &&
                runtimeProofRows["animation-vfx"]?.missingCount == 60 &&
                runtimeProofRows["audio-sfx"]?.provedCount == 0 &&
                runtimeProofRows["audio-sfx"]?.missingCount == 60 &&
                PendingSourceSkillReviewMetrics.runtimeProofPositiveText == "目录 60 / value 15 / 可接入 0" &&
                PendingSourceSkillReviewMetrics.runtimeProofMissingText == "名称 60 / delivery 60 / 归属公式 60 / 动作帧 60 / SFX 60",
            "settings pending source skill review keeps pending source skills blocked by missing identity, delivery, ownership, animation and SFX proof"
        )
        expect(
            PendingSourceSkillReviewMetrics.runtimeProofMatrixBoundaryText.contains("runtime 证明矩阵") &&
                PendingSourceSkillReviewMetrics.runtimeProofMatrixBoundaryText.contains("不生成技能归属") &&
                PendingSourceSkillReviewMetrics.runtimeProofMatrixBoundaryText.contains("公式") &&
                PendingSourceSkillReviewMetrics.runtimeProofMatrixBoundaryText.contains("delivery") &&
                PendingSourceSkillReviewMetrics.runtimeProofMatrixBoundaryText.contains("动作帧") &&
                PendingSourceSkillReviewMetrics.runtimeProofMatrixBoundaryText.contains("SFX") &&
                PendingSourceSkillReviewMetrics.runtimeProofRows.allSatisfy {
                    $0.boundary.contains("不") || $0.boundary.contains("不能")
                },
            "settings pending source skill review keeps runtime proof matrix from fabricating skill effects"
        )
        expect(
            PendingSourceSkillReviewMetrics.runtimeGateCount == 7 &&
                PendingSourceSkillReviewMetrics.runtimeGateRows.map(\.key) == [
                    "localized-identity",
                    "ownership-target",
                    "delivery-hit-shape",
                    "formula-scaling",
                    "trigger-cadence",
                    "animation-vfx",
                    "audio-sfx"
                ] &&
                PendingSourceSkillReviewMetrics.runtimeGateRows.allSatisfy { $0.affectedSkillCount > 0 },
            "settings pending source skill review exposes runtime evidence gates before implementation"
        )
        expect(
            runtimeGateRows["localized-identity"]?.currentEvidence.contains("Skill ID") == true &&
                runtimeGateRows["localized-identity"]?.affectedSkillCount == 60 &&
                runtimeGateRows["delivery-hit-shape"]?.currentEvidence == "60/60 空 delivery" &&
                runtimeGateRows["formula-scaling"]?.currentEvidence == "15 有 sourceValue/range" &&
                runtimeGateRows["animation-vfx"]?.missingEvidence.contains("关键帧") == true &&
                runtimeGateRows["audio-sfx"]?.missingEvidence.contains("音频") == true,
            "settings pending source skill review keeps runtime gates tied to current pending evidence"
        )
        expect(
            PendingSourceSkillReviewMetrics.runtimeGateBoundaryText.contains("不生成技能效果") &&
                PendingSourceSkillReviewMetrics.runtimeGateBoundaryText.contains("公式") &&
                PendingSourceSkillReviewMetrics.runtimeGateBoundaryText.contains("弹道") &&
                PendingSourceSkillReviewMetrics.runtimeGateBoundaryText.contains("动作帧") &&
                PendingSourceSkillReviewMetrics.runtimeGateBoundaryText.contains("音效"),
            "settings pending source skill review keeps runtime gates from fabricating skill effects"
        )
        expect(
            PendingSourceSkillReviewMetrics.evidenceQueueCount == 3 &&
                PendingSourceSkillReviewMetrics.evidenceQueueCoverageCount == PendingSourceSkillReviewMetrics.pendingCount &&
                PendingSourceSkillReviewMetrics.valueRangeEvidenceQueueSkills.count == 15 &&
                PendingSourceSkillReviewMetrics.nonPhysicalBaseAttackCatalogQueueSkills.count == 9 &&
                PendingSourceSkillReviewMetrics.physicalBaseAttackCatalogQueueSkills.count == 36,
            "settings pending source skill review groups all pending skills into evidence queues"
        )
        expect(
            evidenceQueueRows["value-range-pages"]?.sampleIDs == [
                "109021", "109031", "109041", "109051",
                "200421", "201211",
                "209021", "209031", "209041", "209051",
                "300441",
                "309021", "309031", "309041", "309051"
            ] &&
                evidenceQueueRows["value-range-pages"]?.currentEvidence == "15 页有 sourceValue/range；15 空 delivery" &&
                evidenceQueueRows["nonphysical-baseattack-catalog"]?.count == 9 &&
                evidenceQueueRows["nonphysical-baseattack-catalog"]?.currentEvidence == "Fire 6 / Chaos 3；目录行无 sourceValue" &&
                evidenceQueueRows["nonphysical-baseattack-catalog"]?.sampleIDs.first == "100231" &&
                evidenceQueueRows["nonphysical-baseattack-catalog"]?.sampleIDs.last == "309011" &&
                evidenceQueueRows["physical-baseattack-catalog"]?.count == 36 &&
                evidenceQueueRows["physical-baseattack-catalog"]?.sampleIDs.first == "100111" &&
                evidenceQueueRows["physical-baseattack-catalog"]?.sampleIDs.last == "301111",
            "settings pending source skill review keeps evidence queues tied to source data"
        )
        expect(
            PendingSourceSkillReviewMetrics.baseAttackEvidenceRowCount == 45 &&
                PendingSourceSkillReviewMetrics.nonPhysicalBaseAttackEvidenceRowCount == 9 &&
                PendingSourceSkillReviewMetrics.physicalBaseAttackEvidenceRowCount == 36 &&
                PendingSourceSkillReviewMetrics.baseAttackEvidenceCoverageText == "45/48" &&
                PendingSourceSkillReviewMetrics.nonPhysicalBaseAttackEvidenceRows.map(\.id) ==
                PendingSourceSkillReviewMetrics.nonPhysicalBaseAttackCatalogQueueSkills.map(\.id) &&
                PendingSourceSkillReviewMetrics.physicalBaseAttackEvidenceRows.map(\.id) ==
                PendingSourceSkillReviewMetrics.physicalBaseAttackCatalogQueueSkills.map(\.id) &&
                PendingSourceSkillReviewMetrics.nonPhysicalBaseAttackEvidenceRows.first?.currentEvidence == "BASEATTACK · Fire · range 800 · value 未核对 · delivery 空" &&
                PendingSourceSkillReviewMetrics.nonPhysicalBaseAttackEvidenceRows.first?.catalogState == "Skill 100231 · 目录行 · 单技能 value/range 未核对" &&
                PendingSourceSkillReviewMetrics.nonPhysicalBaseAttackEvidenceRows.last?.id == "309011" &&
                PendingSourceSkillReviewMetrics.physicalBaseAttackEvidenceRows.first?.id == "100111" &&
                PendingSourceSkillReviewMetrics.physicalBaseAttackEvidenceRows.last?.currentEvidence == "BASEATTACK · Physical · range 150 · value 未核对 · delivery 空",
            "settings pending source skill review expands base-attack catalog candidates into per-skill evidence rows"
        )
        expect(
            PendingSourceSkillReviewMetrics.baseAttackEvidenceRows.allSatisfy {
                $0.missingEvidence.contains("本地化名称") &&
                    $0.missingEvidence.contains("归属") &&
                    $0.boundary.contains("不以 damage") &&
                    $0.boundary.contains("ID 段") &&
                    $0.boundary.contains("动作帧") &&
                    $0.boundary.contains("音效")
            },
            "settings pending source skill review keeps base-attack evidence rows from fabricating runtime effects"
        )
        expect(
            PendingSourceSkillReviewMetrics.unmappedMonsterCandidateIDs == ["200421", "201211", "300441"] &&
                PendingSourceSkillReviewMetrics.unmappedMonsterCandidateCount == 3 &&
                PendingSourceSkillReviewMetrics.unmappedMonsterCandidateEmptyDeliveryCount == 3 &&
                PendingSourceSkillReviewMetrics.unmappedMonsterCandidateCoverageText == "3/3" &&
                PendingSourceSkillReviewMetrics.unmappedMonsterCandidateIDText == "200421, 201211, 300441" &&
                unmappedMonsterCandidateRows.map { $0.monsterRow.monster.zhName } == ["剧毒领主", "扁虱", "雪山法师"] &&
                unmappedMonsterCandidateRows.map(\.skill.damageType) == ["Chaos", "Physical", "Cold"] &&
                unmappedMonsterCandidateRows.allSatisfy { !$0.skill.isRuntimeModeled },
            "settings pending source skill review exposes unmapped monster same-prefix candidates as review-only rows"
        )
        expect(
            unmappedMonsterCandidateRows.first?.currentEvidence == "20042:剧毒领主 · Chaos BASEATTACK r800 · value 1000 · delivery 空" &&
                unmappedMonsterCandidateRows[1].stageEvidence == "best-farm 无 stage code，不能证明出场" &&
                unmappedMonsterCandidateRows.last?.stageEvidence.contains("best 4303 组成未列出雪山法师") == true &&
                unmappedMonsterCandidateRows.allSatisfy {
                    $0.missingEvidence.contains("关卡出场证明") &&
                        $0.missingEvidence.contains("怪物技能归属") &&
                        $0.boundary.contains("复核入口") &&
                        $0.boundary.contains("不证明怪物技能归属") &&
                        $0.boundary.contains("动作帧") &&
                        $0.boundary.contains("音效")
                } &&
                PendingSourceSkillReviewMetrics.unmappedMonsterCandidateBoundaryText.contains("交叉复核索引") &&
                PendingSourceSkillReviewMetrics.unmappedMonsterCandidateBoundaryText.contains("不证明怪物出场") &&
                PendingSourceSkillReviewMetrics.unmappedMonsterCandidateBoundaryText.contains("不改变互斥接入队列"),
            "settings pending source skill review keeps unmapped monster candidate prefixes from becoming runtime semantics"
        )
        expect(
            PendingSourceSkillReviewMetrics.evidenceQueueBoundaryText.contains("互斥") &&
                PendingSourceSkillReviewMetrics.evidenceQueueBoundaryText.contains("不按 value") &&
                PendingSourceSkillReviewMetrics.evidenceQueueBoundaryText.contains("damage") &&
                PendingSourceSkillReviewMetrics.evidenceQueueBoundaryText.contains("ID 段") &&
                PendingSourceSkillReviewMetrics.evidenceQueueBoundaryText.contains("弹道") &&
                PendingSourceSkillReviewMetrics.evidenceQueueRows.allSatisfy {
                    $0.boundary.contains("不")
                },
            "settings pending source skill review keeps evidence queues from fabricating runtime semantics"
        )
        expect(
            PendingSourceSkillReviewMetrics.pendingCooldownChaosValueSkills.map(\.id) == ["309021", "309041", "309051"] &&
                PendingSourceSkillReviewMetrics.pendingCooldownChaosValueSkills.compactMap(\.sourceValue) == [800, 1700, 2300] &&
                PendingSourceSkillReviewMetrics.pendingCooldownChaosValueText == "309021=800/r700; 309041=1700/r700; 309051=2300/r600" &&
                PendingSourceSkillReviewMetrics.pendingCooldownChaosValueCount == 3 &&
                PendingSourceSkillReviewMetrics.cooldownChaosValueBoundaryText.contains("不推导"),
            "settings pending source skill review exposes checked cooldown Chaos source values without runtime semantics"
        )
        expect(
            PendingSourceSkillReviewMetrics.cooldownChaosPageEvidenceRowCount == 3 &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageLocaleCount == 6 &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageEmptyDeliveryCount == 3 &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageUnnamedCount == 3 &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageSnapshotText == "6 中英页 / v1.00.13 / Skill ID / 无说明 / delivery — / Lv —" &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageEvidenceRows.map(\.id) == ["309021", "309041", "309051"] &&
                cooldownChaosPageRows["309021"]?.currentEvidence == "value 800 · range 700 · Skill ID · delivery — · Lv —" &&
                cooldownChaosPageRows["309041"]?.currentEvidence == "value 1700 · range 700 · Skill ID · delivery — · Lv —" &&
                cooldownChaosPageRows["309051"]?.currentEvidence == "value 2300 · range 600 · Skill ID · delivery — · Lv —" &&
                cooldownChaosPageRows["309051"]?.localePathText.contains("/en/skills/active/id-309051/") == true,
            "settings pending source skill review exposes dedicated COOLDOWN/Chaos page evidence rows"
        )
        expect(
            PendingSourceSkillReviewMetrics.cooldownChaosPageBoundaryText.contains("taskbarhero.org v1.00.13") &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageBoundaryText.contains("不是第二独立来源") &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageBoundaryText.contains("目标") &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageBoundaryText.contains("持续时间") &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageBoundaryText.contains("命中形态") &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageBoundaryText.contains("动画") &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageBoundaryText.contains("SFX") &&
                PendingSourceSkillReviewMetrics.cooldownChaosPageEvidenceRows.allSatisfy {
                    $0.boundary.contains("不以 COOLDOWN") &&
                        $0.boundary.contains("Chaos") &&
                        $0.boundary.contains("value") &&
                        $0.boundary.contains("range") &&
                        $0.boundary.contains("运行时技能")
                },
            "settings pending source skill review keeps COOLDOWN/Chaos page evidence from becoming runtime semantics"
        )
        expect(
            PendingSourceSkillReviewMetrics.sixDigitUnnamedBoundaryText.contains("数据态") &&
                PendingSourceSkillReviewMetrics.checkedMonsterAttackBoundaryText.contains("四条") &&
                PendingSourceSkillReviewMetrics.triggeredPendingBoundaryText.contains("不伪造"),
            "settings pending source skill review keeps monster responsibility boundaries explicit"
        )
        expect(
            PendingSourceSkillReviewMetrics.rangeRows.count == 13 &&
                rangeCounts["130"] == 5 &&
                rangeCounts["150"] == 10 &&
                rangeCounts["700"] == 5 &&
                rangeCounts["800"] == 8 &&
                rangeCounts["900"] == 4,
            "settings pending source skill review preserves source range buckets"
        )
        expect(
            PendingSourceSkillReviewMetrics.rangeRows.first?.key == "130" &&
                PendingSourceSkillReviewMetrics.rangeRows.last?.key == "900" &&
                PendingSourceSkillReviewMetrics.mostCommonRangeText == "150 x10",
            "settings pending source skill review keeps source range ordering visible"
        )
        expect(
            PendingSourceSkillReviewMetrics.rangeBoundaryText.contains("源表距离字段") &&
                PendingSourceSkillReviewMetrics.rangeBoundaryText.contains("不推导") &&
                PendingSourceSkillReviewMetrics.rangeBoundaryText.contains("弹道"),
            "settings pending source skill review keeps range semantics unfabricated"
        )
        expect(
            PendingSourceSkillReviewMetrics.rangeEvidenceQueueRows.allSatisfy {
                $0.nextEvidence.contains("目标距离") &&
                    $0.nextEvidence.contains("动作帧") &&
                    $0.boundary.contains("range 只作为源表字段") &&
                    $0.boundary.contains("不按数值生成") &&
                    $0.boundary.contains("弹道")
            },
            "settings pending source skill review keeps range evidence queues from fabricating hit shapes"
        )
        expect(
            PendingSourceSkillReviewMetrics.valueEvidenceQueueRows.allSatisfy {
                $0.nextEvidence.contains("等级表") &&
                    $0.nextEvidence.contains("倍率公式") &&
                    $0.nextEvidence.contains("目标规则") &&
                    $0.nextEvidence.contains("持续时间") &&
                    $0.boundary.contains("value 只作为单技能页数值字段") &&
                    $0.boundary.contains("不按 value 推断") &&
                    $0.boundary.contains("倍率公式") &&
                    $0.boundary.contains("伤害") &&
                    $0.boundary.contains("目标") &&
                    $0.boundary.contains("持续时间") &&
                    $0.boundary.contains("弹道") &&
                    $0.boundary.contains("动作帧") &&
                    $0.boundary.contains("音效")
            },
            "settings pending source skill review keeps value queues from fabricating combat semantics"
        )
        expect(
            PendingSourceSkillReviewMetrics.prefixEvidenceQueueRows.allSatisfy {
                $0.nextEvidence.contains("本地化名称") &&
                    $0.nextEvidence.contains("英雄/怪物归属") &&
                    $0.nextEvidence.contains("公式") &&
                    $0.boundary.contains("ID 前缀只作为源表命名空间") &&
                    $0.boundary.contains("不按前缀推断") &&
                    $0.boundary.contains("职业") &&
                    $0.boundary.contains("怪物") &&
                    $0.boundary.contains("关卡") &&
                    $0.boundary.contains("技能归属") &&
                    $0.boundary.contains("公式") &&
                    $0.boundary.contains("弹道") &&
                    $0.boundary.contains("动作帧") &&
                    $0.boundary.contains("音效")
            },
            "settings pending source skill review keeps prefix evidence queues from fabricating ownership"
        )
    }

    private static func settingsSourceSkillDeliveryReview() {
        print("[SourceSkillDeliveryReviewView]")

        let deliveryCounts = Dictionary(
            uniqueKeysWithValues: SourceSkillDeliveryReviewMetrics.rows.map {
                ($0.delivery, $0.sourceCount)
            }
        )
        let runtimeCounts = Dictionary(
            uniqueKeysWithValues: SourceSkillDeliveryReviewMetrics.rows.map {
                ($0.delivery, $0.runtimeCount)
            }
        )

        expect(
            SourceSkillDeliveryReviewMetrics.deliveryBucketCount == 8 &&
                SourceSkillDeliveryReviewMetrics.emptyDeliveryCount == 71 &&
                SourceSkillDeliveryReviewMetrics.nonEmptyDeliveryCount == 35,
            "settings source skill delivery review exposes all source delivery buckets"
        )
        expect(
            deliveryCounts[""] == 71 &&
                deliveryCounts["AOE"] == 10 &&
                deliveryCounts["Projectile"] == 10 &&
                deliveryCounts["Melee"] == 6 &&
                deliveryCounts["Melee, AOE"] == 4 &&
                deliveryCounts["Projectile, AOE"] == 2 &&
                deliveryCounts["Projectile, Summon"] == 2 &&
                deliveryCounts["Trap"] == 1,
            "settings source skill delivery review preserves checked delivery distribution"
        )
        expect(
            runtimeCounts[""] == 11 &&
                runtimeCounts["Projectile"] == 10 &&
                runtimeCounts["Trap"] == 1 &&
                SourceSkillDeliveryReviewMetrics.nonEmptyRuntimeCount == 35,
            "settings source skill delivery review distinguishes runtime-mapped and pending delivery rows"
        )
        expect(
            SourceSkillDeliveryReviewMetrics.rows.first?.delivery == "" &&
                SourceSkillDeliveryReviewMetrics.rows.first?.sampleIDs.prefix(3) == ["10501", "10601", "20401"] &&
                SourceSkillDeliveryReviewMetrics.rows.last?.delivery == "Trap" &&
                SourceSkillDeliveryReviewMetrics.rows.last?.sampleIDs == ["50401"] &&
                SourceSkillDeliveryReviewMetrics.mostCommonDeliveryText == "空 delivery x71",
            "settings source skill delivery review keeps source-order samples and most common bucket visible"
        )
        expect(
            SourceSkillDeliveryReviewMetrics.deliveryBoundaryText.contains("源表形态字段") &&
                SourceSkillDeliveryReviewMetrics.deliveryBoundaryText.contains("不推导") &&
                SourceSkillDeliveryReviewMetrics.deliveryBoundaryText.contains("施法帧") &&
                SourceSkillDeliveryReviewMetrics.emptyDeliveryBoundaryText.contains("不伪造") &&
                SourceSkillDeliveryReviewMetrics.runtimeBoundaryText.contains("不代表原版"),
            "settings source skill delivery review keeps delivery semantics unfabricated"
        )
    }

    private static func settingsSourceSkillDamageReview() {
        print("[SourceSkillDamageReviewView]")

        let damageCounts = Dictionary(
            uniqueKeysWithValues: SourceSkillDamageReviewMetrics.rows.map {
                ($0.damageType, $0.sourceCount)
            }
        )
        let runtimeCounts = Dictionary(
            uniqueKeysWithValues: SourceSkillDamageReviewMetrics.rows.map {
                ($0.damageType, $0.runtimeCount)
            }
        )

        expect(
            SourceSkillDamageReviewMetrics.damageBucketCount == 5 &&
                SourceSkillDamageReviewMetrics.sourceCount == 106 &&
                SourceSkillDamageReviewMetrics.runtimeMappedCount == 46,
            "settings source skill damage review exposes all source damage buckets"
        )
        expect(
            damageCounts["Physical"] == 77 &&
                damageCounts["Fire"] == 12 &&
                damageCounts["Cold"] == 5 &&
                damageCounts["Lightning"] == 4 &&
                damageCounts["Chaos"] == 8,
            "settings source skill damage review preserves checked damage distribution"
        )
        expect(
            runtimeCounts["Physical"] == 31 &&
                runtimeCounts["Fire"] == 6 &&
                runtimeCounts["Cold"] == 4 &&
                runtimeCounts["Lightning"] == 4 &&
                runtimeCounts["Chaos"] == 1 &&
                SourceSkillDamageReviewMetrics.nonPhysicalRuntimeCount == 15 &&
                SourceSkillDamageReviewMetrics.chaosRuntimeCount == 1,
            "settings source skill damage review distinguishes runtime-mapped elemental rows"
        )
        expect(
            SourceSkillDamageReviewMetrics.rows.first?.damageType == "Physical" &&
                SourceSkillDamageReviewMetrics.rows.first?.sampleIDs.prefix(3) == ["10001", "10101", "10201"] &&
                SourceSkillDamageReviewMetrics.rows.last?.damageType == "Chaos" &&
                SourceSkillDamageReviewMetrics.rows.last?.sampleIDs.prefix(2) == ["200411", "200421"] &&
                SourceSkillDamageReviewMetrics.mostCommonDamageText == "Physical x77",
            "settings source skill damage review keeps source-order samples and most common bucket visible"
        )
        expect(
            SourceSkillDamageReviewMetrics.damageBoundaryText.contains("源表伤害类型字段") &&
                SourceSkillDamageReviewMetrics.damageBoundaryText.contains("抗性") &&
                SourceSkillDamageReviewMetrics.damageBoundaryText.contains("异常状态") &&
                SourceSkillDamageReviewMetrics.visualBoundaryText.contains("VFX/SFX") &&
                SourceSkillDamageReviewMetrics.runtimeBoundaryText.contains("不代表原版元素规则完整"),
            "settings source skill damage review keeps damage semantics unfabricated"
        )
    }

    private static func settingsSourceSkillActivationDamageReview() {
        print("[SourceSkillActivationDamageReviewView]")

        let rowsByActivation = Dictionary(
            uniqueKeysWithValues: SourceSkillActivationDamageReviewMetrics.rows.map {
                ($0.activation, $0)
            }
        )
        let baseAttackCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.baseAttack]?.damageCells.map {
                ($0.damageType, $0)
            } ?? []
        )
        let baseAttackCountCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.baseAttackCount]?.damageCells.map {
                ($0.damageType, $0)
            } ?? []
        )
        let cooldownCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.cooldown]?.damageCells.map {
                ($0.damageType, $0)
            } ?? []
        )
        let continuousCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.continuous]?.damageCells.map {
                ($0.damageType, $0)
            } ?? []
        )

        expect(
            SourceSkillActivationDamageReviewMetrics.rows.count == 4 &&
                SourceSkillActivationDamageReviewMetrics.pairCount == 14 &&
                SourceSkillActivationDamageReviewMetrics.runtimePairCount == 13 &&
                SourceSkillActivationDamageReviewMetrics.sourceCount == 106 &&
                SourceSkillActivationDamageReviewMetrics.runtimeMappedCount == 46,
            "settings source skill activation-damage review exposes all checked cross-tab buckets"
        )
        expect(
            rowsByActivation[.baseAttack]?.sourceCount == 58 &&
                rowsByActivation[.baseAttack]?.runtimeCount == 10 &&
                rowsByActivation[.baseAttackCount]?.sourceCount == 11 &&
                rowsByActivation[.baseAttackCount]?.runtimeCount == 9 &&
                rowsByActivation[.cooldown]?.sourceCount == 35 &&
                rowsByActivation[.cooldown]?.runtimeCount == 25 &&
                rowsByActivation[.continuous]?.sourceCount == 2 &&
                rowsByActivation[.continuous]?.runtimeCount == 2,
            "settings source skill activation-damage review preserves activation runtime counts"
        )
        expect(
            baseAttackCells["Physical"]?.sourceCount == 42 &&
                baseAttackCells["Physical"]?.runtimeCount == 5 &&
                baseAttackCells["Fire"]?.sourceCount == 8 &&
                baseAttackCells["Fire"]?.runtimeCount == 2 &&
                baseAttackCells["Chaos"]?.sourceCount == 5 &&
                baseAttackCells["Chaos"]?.runtimeCount == 1 &&
                baseAttackCountCells["Physical"]?.sourceCount == 9 &&
                baseAttackCountCells["Physical"]?.runtimeCount == 7,
            "settings source skill activation-damage review preserves base attack cross-tab counts"
        )
        expect(
            cooldownCells["Physical"]?.sourceCount == 24 &&
                cooldownCells["Physical"]?.runtimeCount == 17 &&
                cooldownCells["Chaos"]?.sourceCount == 3 &&
                cooldownCells["Chaos"]?.runtimeCount == 0 &&
                continuousCells["Physical"]?.sourceCount == 2 &&
                continuousCells["Physical"]?.runtimeCount == 2 &&
                SourceSkillActivationDamageReviewMetrics.cooldownChaosRuntimeCount == 0 &&
                SourceSkillActivationDamageReviewMetrics.cooldownChaosPendingIDs == ["309021", "309041", "309051"] &&
                SourceSkillActivationDamageReviewMetrics.cooldownChaosPendingIDText == "309021, 309041, 309051",
            "settings source skill activation-damage review keeps unmodeled cooldown chaos rows explicit"
        )
        expect(
            SourceSkillActivationDamageReviewMetrics.rows.first?.activation == .baseAttack &&
                SourceSkillActivationDamageReviewMetrics.rows.first?.sampleIDs.prefix(5) == ["10001", "20001", "30001", "40001", "50001"] &&
                SourceSkillActivationDamageReviewMetrics.baseAttackRuntimeText == "10/58" &&
                SourceSkillActivationDamageReviewMetrics.largestPendingPairText == "BASEATTACK/Physical 37",
            "settings source skill activation-damage review keeps ordering, samples and largest pending pair visible"
        )
        expect(
            SourceSkillActivationDamageReviewMetrics.activationBoundaryText.contains("源表触发字段") &&
                SourceSkillActivationDamageReviewMetrics.activationBoundaryText.contains("不等于完整施法") &&
                SourceSkillActivationDamageReviewMetrics.crossTabBoundaryText.contains("不推导技能归属") &&
                SourceSkillActivationDamageReviewMetrics.crossTabBoundaryText.contains("触发频率") &&
                SourceSkillActivationDamageReviewMetrics.runtimeBoundaryText.contains("不代表原版运行时语义完整"),
            "settings source skill activation-damage review keeps cross-tab semantics unfabricated"
        )
    }

    private static func settingsSourceSkillActivationDeliveryReview() {
        print("[SourceSkillActivationDeliveryReviewView]")

        let rowsByActivation = Dictionary(
            uniqueKeysWithValues: SourceSkillActivationDeliveryReviewMetrics.rows.map {
                ($0.activation, $0)
            }
        )
        let baseAttackCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.baseAttack]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )
        let baseAttackCountCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.baseAttackCount]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )
        let cooldownCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.cooldown]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )
        let continuousCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.continuous]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )

        expect(
            SourceSkillActivationDeliveryReviewMetrics.rows.count == 4 &&
                SourceSkillActivationDeliveryReviewMetrics.pairCount == 16 &&
                SourceSkillActivationDeliveryReviewMetrics.runtimePairCount == 15 &&
                SourceSkillActivationDeliveryReviewMetrics.sourceCount == 106 &&
                SourceSkillActivationDeliveryReviewMetrics.runtimeMappedCount == 46,
            "settings source skill activation-delivery review exposes all checked cross-tab buckets"
        )
        expect(
            rowsByActivation[.baseAttack]?.sourceCount == 58 &&
                rowsByActivation[.baseAttack]?.runtimeCount == 10 &&
                rowsByActivation[.baseAttackCount]?.sourceCount == 11 &&
                rowsByActivation[.baseAttackCount]?.runtimeCount == 9 &&
                rowsByActivation[.cooldown]?.sourceCount == 35 &&
                rowsByActivation[.cooldown]?.runtimeCount == 25 &&
                rowsByActivation[.continuous]?.sourceCount == 2 &&
                rowsByActivation[.continuous]?.runtimeCount == 2,
            "settings source skill activation-delivery review preserves activation runtime counts"
        )
        expect(
            baseAttackCells[""]?.sourceCount == 52 &&
                baseAttackCells[""]?.runtimeCount == 4 &&
                baseAttackCells["Melee"]?.sourceCount == 3 &&
                baseAttackCells["Melee"]?.runtimeCount == 3 &&
                baseAttackCells["Projectile"]?.sourceCount == 3 &&
                baseAttackCells["Projectile"]?.runtimeCount == 3 &&
                baseAttackCountCells[""]?.sourceCount == 2 &&
                baseAttackCountCells[""]?.runtimeCount == 0,
            "settings source skill activation-delivery review preserves base attack delivery gaps"
        )
        expect(
            cooldownCells[""]?.sourceCount == 17 &&
                cooldownCells[""]?.runtimeCount == 7 &&
                cooldownCells["AOE"]?.sourceCount == 8 &&
                cooldownCells["AOE"]?.runtimeCount == 8 &&
                cooldownCells["Projectile, Summon"]?.sourceCount == 2 &&
                cooldownCells["Projectile, Summon"]?.runtimeCount == 2 &&
                cooldownCells["Trap"]?.sourceCount == 1 &&
                cooldownCells["Trap"]?.runtimeCount == 1 &&
                continuousCells["AOE"]?.sourceCount == 2 &&
                continuousCells["AOE"]?.runtimeCount == 2,
            "settings source skill activation-delivery review preserves cooldown and continuous delivery buckets"
        )
        expect(
            SourceSkillActivationDeliveryReviewMetrics.rows.first?.activation == .baseAttack &&
                SourceSkillActivationDeliveryReviewMetrics.rows.first?.sampleIDs.prefix(5) == ["10001", "20001", "30001", "40001", "50001"] &&
                SourceSkillActivationDeliveryReviewMetrics.emptyDeliveryRuntimeText == "11/71" &&
                SourceSkillActivationDeliveryReviewMetrics.baseAttackEmptyRuntimeText == "4/52" &&
                SourceSkillActivationDeliveryReviewMetrics.baseAttackCountEmptyRuntimeText == "0/2" &&
                SourceSkillActivationDeliveryReviewMetrics.largestPendingPairText == "BASEATTACK/空 delivery 48",
            "settings source skill activation-delivery review keeps ordering, empty-delivery summaries and largest pending pair visible"
        )
        expect(
            SourceSkillActivationDeliveryReviewMetrics.crossTabBoundaryText.contains("源表字段组合") &&
                SourceSkillActivationDeliveryReviewMetrics.crossTabBoundaryText.contains("完整触发时序") &&
                SourceSkillActivationDeliveryReviewMetrics.emptyDeliveryBoundaryText.contains("attack-count") &&
                SourceSkillActivationDeliveryReviewMetrics.emptyDeliveryBoundaryText.contains("待核对") &&
                SourceSkillActivationDeliveryReviewMetrics.runtimeBoundaryText.contains("施法帧") &&
                SourceSkillActivationDeliveryReviewMetrics.runtimeBoundaryText.contains("动画完整"),
            "settings source skill activation-delivery review keeps trigger visual semantics unfabricated"
        )
    }

    private static func settingsSourceSkillDamageDeliveryReview() {
        print("[SourceSkillDamageDeliveryReviewView]")

        let rowsByDamage = Dictionary(
            uniqueKeysWithValues: SourceSkillDamageDeliveryReviewMetrics.rows.map {
                ($0.damageType, $0)
            }
        )
        let physicalCells = Dictionary(
            uniqueKeysWithValues: rowsByDamage["Physical"]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )
        let fireCells = Dictionary(
            uniqueKeysWithValues: rowsByDamage["Fire"]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )
        let coldCells = Dictionary(
            uniqueKeysWithValues: rowsByDamage["Cold"]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )
        let lightningCells = Dictionary(
            uniqueKeysWithValues: rowsByDamage["Lightning"]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )
        let chaosCells = Dictionary(
            uniqueKeysWithValues: rowsByDamage["Chaos"]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )

        expect(
            SourceSkillDamageDeliveryReviewMetrics.rows.count == 5 &&
                SourceSkillDamageDeliveryReviewMetrics.pairCount == 20 &&
                SourceSkillDamageDeliveryReviewMetrics.runtimePairCount == 20 &&
                SourceSkillDamageDeliveryReviewMetrics.sourceCount == 106 &&
                SourceSkillDamageDeliveryReviewMetrics.runtimeMappedCount == 46,
            "settings source skill damage-delivery review exposes all checked cross-tab buckets"
        )
        expect(
            rowsByDamage["Physical"]?.sourceCount == 77 &&
                rowsByDamage["Physical"]?.runtimeCount == 31 &&
                rowsByDamage["Fire"]?.sourceCount == 12 &&
                rowsByDamage["Fire"]?.runtimeCount == 6 &&
                rowsByDamage["Cold"]?.sourceCount == 5 &&
                rowsByDamage["Cold"]?.runtimeCount == 4 &&
                rowsByDamage["Lightning"]?.sourceCount == 4 &&
                rowsByDamage["Lightning"]?.runtimeCount == 4 &&
                rowsByDamage["Chaos"]?.sourceCount == 8 &&
                rowsByDamage["Chaos"]?.runtimeCount == 1,
            "settings source skill damage-delivery review preserves damage runtime counts"
        )
        expect(
            physicalCells[""]?.sourceCount == 53 &&
                physicalCells[""]?.runtimeCount == 7 &&
                physicalCells["AOE"]?.sourceCount == 6 &&
                physicalCells["AOE"]?.runtimeCount == 6 &&
                physicalCells["Melee"]?.sourceCount == 6 &&
                physicalCells["Melee"]?.runtimeCount == 6 &&
                physicalCells["Projectile"]?.sourceCount == 6 &&
                physicalCells["Projectile"]?.runtimeCount == 6 &&
                physicalCells["Trap"]?.sourceCount == 1 &&
                physicalCells["Trap"]?.runtimeCount == 1,
            "settings source skill damage-delivery review preserves physical delivery buckets"
        )
        expect(
            fireCells[""]?.sourceCount == 7 &&
                fireCells[""]?.runtimeCount == 1 &&
                fireCells["Projectile"]?.sourceCount == 2 &&
                fireCells["Projectile"]?.runtimeCount == 2 &&
                coldCells[""]?.sourceCount == 2 &&
                coldCells[""]?.runtimeCount == 1 &&
                lightningCells[""]?.sourceCount == 1 &&
                lightningCells[""]?.runtimeCount == 1 &&
                chaosCells[""]?.sourceCount == 8 &&
                chaosCells[""]?.runtimeCount == 1,
            "settings source skill damage-delivery review keeps empty delivery elemental gaps explicit"
        )
        expect(
            SourceSkillDamageDeliveryReviewMetrics.rows.first?.damageType == "Physical" &&
                SourceSkillDamageDeliveryReviewMetrics.rows.first?.sampleIDs.prefix(5) == ["10001", "10101", "10201", "10301", "10401"] &&
                SourceSkillDamageDeliveryReviewMetrics.emptyDeliveryRuntimeText == "11/71" &&
                SourceSkillDamageDeliveryReviewMetrics.physicalEmptyRuntimeText == "7/53" &&
                SourceSkillDamageDeliveryReviewMetrics.largestPendingPairText == "Physical/空 delivery 46",
            "settings source skill damage-delivery review keeps ordering, empty-delivery summary and largest pending pair visible"
        )
        expect(
            SourceSkillDamageDeliveryReviewMetrics.crossTabBoundaryText.contains("源表字段组合") &&
                SourceSkillDamageDeliveryReviewMetrics.crossTabBoundaryText.contains("原版特效") &&
                SourceSkillDamageDeliveryReviewMetrics.emptyDeliveryBoundaryText.contains("不推导无弹道") &&
                SourceSkillDamageDeliveryReviewMetrics.emptyDeliveryBoundaryText.contains("无范围") &&
                SourceSkillDamageDeliveryReviewMetrics.runtimeBoundaryText.contains("不代表命中几何") &&
                SourceSkillDamageDeliveryReviewMetrics.runtimeBoundaryText.contains("动画完整"),
            "settings source skill damage-delivery review keeps visual semantics unfabricated"
        )
    }

    private static func settingsSourceSkillRangeReview() {
        print("[SourceSkillRangeReviewView]")

        let rangeCounts = Dictionary(
            uniqueKeysWithValues: SourceSkillRangeReviewMetrics.rows.map {
                ($0.range, $0.sourceCount)
            }
        )
        let runtimeCounts = Dictionary(
            uniqueKeysWithValues: SourceSkillRangeReviewMetrics.rows.map {
                ($0.range, $0.runtimeCount)
            }
        )

        expect(
            SourceSkillRangeReviewMetrics.rangeBucketCount == 24 &&
                SourceSkillRangeReviewMetrics.sourceCount == 106 &&
                SourceSkillRangeReviewMetrics.runtimeMappedCount == 46,
            "settings source skill range review exposes all source range buckets"
        )
        expect(
            rangeCounts[120] == 1 &&
                rangeCounts[130] == 5 &&
                rangeCounts[140] == 1 &&
                rangeCounts[150] == 16 &&
                rangeCounts[170] == 9 &&
                rangeCounts[200] == 8 &&
                rangeCounts[230] == 1 &&
                rangeCounts[250] == 4 &&
                rangeCounts[270] == 1 &&
                rangeCounts[300] == 5 &&
                rangeCounts[450] == 1 &&
                rangeCounts[600] == 3 &&
                rangeCounts[700] == 5 &&
                rangeCounts[800] == 12 &&
                rangeCounts[850] == 1 &&
                rangeCounts[900] == 7 &&
                rangeCounts[950] == 4 &&
                rangeCounts[1000] == 1 &&
                rangeCounts[1050] == 3 &&
                rangeCounts[1100] == 11 &&
                rangeCounts[1150] == 2 &&
                rangeCounts[1200] == 3 &&
                rangeCounts[1300] == 1 &&
                rangeCounts[1650] == 1,
            "settings source skill range review preserves checked range distribution"
        )
        expect(
            runtimeCounts[1100] == 11 &&
                runtimeCounts[150] == 6 &&
                runtimeCounts[800] == 4 &&
                runtimeCounts[130] == 0 &&
                SourceSkillRangeReviewMetrics.runtimeMappedCount == SourceSkillCatalog.runtimeModeledSkillIDs.count,
            "settings source skill range review distinguishes runtime-mapped and pending range rows"
        )
        expect(
            SourceSkillRangeReviewMetrics.rows.first?.range == 120 &&
                SourceSkillRangeReviewMetrics.rows.first?.sampleIDs == ["60001"] &&
                SourceSkillRangeReviewMetrics.rows.last?.range == 1650 &&
                SourceSkillRangeReviewMetrics.rows.last?.sampleIDs == ["20201"] &&
                SourceSkillRangeReviewMetrics.minMaxRangeText == "120-1650" &&
                SourceSkillRangeReviewMetrics.mostCommonRangeText == "150 x16",
            "settings source skill range review keeps range ordering and extremes visible"
        )
        expect(
            SourceSkillRangeReviewMetrics.rangeBoundaryText.contains("源表距离字段") &&
                SourceSkillRangeReviewMetrics.rangeBoundaryText.contains("不推导") &&
                SourceSkillRangeReviewMetrics.rangeBoundaryText.contains("弹道") &&
                SourceSkillRangeReviewMetrics.runtimeBoundaryText.contains("不代表原版射程") &&
                SourceSkillRangeReviewMetrics.scaleBoundaryText.contains("不当作屏幕像素比例"),
            "settings source skill range review keeps range semantics unfabricated"
        )
    }

    private static func settingsSourceMonsterAttackMappings() {
        print("[SourceMonsterAttackReviewView]")

        let mappings = SourceMonsterAttackReviewMetrics.mappings
        let mappedSkillIDs = Set(mappings.map(\.sourceSkillID))
        let mappedElements = Set(mappings.map { $0.runtimeElement.rawValue })

        expect(
            SourceMonsterAttackReviewMetrics.mappingCount == 4 &&
                mappedSkillIDs == Set(["301015", "301025", "301035", "301045"]),
            "settings monster attack review exposes all four checked source attack rows"
        )
        expect(
            mappedElements == Set([
                SkillDamageElement.fire.rawValue,
                SkillDamageElement.cold.rawValue,
                SkillDamageElement.lightning.rawValue,
                SkillDamageElement.chaos.rawValue
            ]) &&
                SourceMonsterAttackReviewMetrics.runtimeElementCount == 4,
            "settings monster attack review exposes distinct runtime elements for checked priest attacks"
        )
        expect(
            mappings.allSatisfy { row in
                row.activation == .baseAttack &&
                    row.range == 800 &&
                    row.sourceDelivery.isEmpty &&
                    row.runtimeDelivery == .none
            } &&
                SourceMonsterAttackReviewMetrics.baseAttackCount == 4 &&
                SourceMonsterAttackReviewMetrics.emptySourceDeliveryCount == 4 &&
                SourceMonsterAttackReviewMetrics.sourceRangeText == "800",
            "settings monster attack review preserves source activation, range and empty delivery boundaries"
        )
        expect(
            SourceMonsterAttackReviewMetrics.deliveryBoundaryText.contains("不伪造") &&
                SourceMonsterAttackReviewMetrics.fullMonsterSkillBoundaryText.contains("待核对"),
            "settings monster attack review keeps full monster skill and delivery boundaries explicit"
        )
        let attackGateRows = Dictionary(
            uniqueKeysWithValues: SourceMonsterAttackReviewMetrics.attackEvidenceGateRows.map {
                ($0.key, $0)
            }
        )
        expect(
            SourceMonsterAttackReviewMetrics.attackEvidenceGateCount == 5 &&
                SourceMonsterAttackReviewMetrics.attackEvidenceGateRows.map(\.key) == [
                    "skill-roster",
                    "delivery-hit-shape",
                    "trigger-cadence",
                    "target-formula",
                    "animation-sfx"
                ] &&
                SourceMonsterAttackReviewMetrics.attackEvidenceGateRows.allSatisfy { $0.affectedRowCount > 0 },
            "settings monster attack review exposes evidence gates before expanding monster skills"
        )
        expect(
            attackGateRows["skill-roster"]?.currentEvidence.contains("4 已接入") == true &&
                attackGateRows["skill-roster"]?.currentEvidence.contains("61 源怪物行") == true &&
                attackGateRows["delivery-hit-shape"]?.currentEvidence == "4/4 已接入行来源 delivery 为空" &&
                attackGateRows["trigger-cadence"]?.missingEvidence.contains("施法前摇") == true &&
                attackGateRows["target-formula"]?.missingEvidence.contains("结算顺序") == true &&
                attackGateRows["animation-sfx"]?.missingEvidence.contains("原版音频") == true,
            "settings monster attack review keeps attack gates tied to current source evidence"
        )
        expect(
            SourceMonsterAttackReviewMetrics.attackEvidenceGateBoundaryText.contains("不生成怪物技能") &&
                SourceMonsterAttackReviewMetrics.attackEvidenceGateBoundaryText.contains("投射物") &&
                SourceMonsterAttackReviewMetrics.attackEvidenceGateBoundaryText.contains("公式") &&
                SourceMonsterAttackReviewMetrics.attackEvidenceGateBoundaryText.contains("动作帧") &&
                SourceMonsterAttackReviewMetrics.attackEvidenceGateBoundaryText.contains("音效"),
            "settings monster attack review keeps attack gates from fabricating skill semantics"
        )
    }

    private static func settingsSourceItemDatabase() {
        print("[SourceItemDatabaseView]")

        let sourceChestIconFamilies = Set(SourceItemCatalog.allStageChests.map(\.iconName))
        expect(
            SourceItemCatalog.allGearTypes.count == 20 &&
                SourceItemCatalog.totalGearEntryCount == 5_760 &&
                SourceItemCatalog.totalGearLevelProgressionCount == 396,
            "settings item source review can summarize checked gear types, aggregate entries and base progressions"
        )
        expect(
            SourceItemCatalog.allMaterials.count == 115 &&
                SourceItemCatalog.materialCountsByCategory.count == 6 &&
                SourceItemCatalog.allStageChests.count == 59 &&
                sourceChestIconFamilies == Set(["source_stage_chest_910011", "source_stage_chest_920011", "source_stage_chest_930011"]),
            "settings item source review can summarize checked material and stage chest source rows"
        )
        expect(
            OriginalFidelityBoundaryMetrics.exactItemRecordCoverageText == "0/5760" &&
                SourceItemCatalog.allGearTypes.allSatisfy { $0.progressions.allSatisfy { $0.iconName.hasPrefix("source_gear_") } } &&
                SourceItemCatalog.allMaterials.allSatisfy { GameArt.itemIconName(for: $0).hasPrefix("source_material_") },
            "settings item source review keeps exact item-record gaps separate from source-backed item art"
        )
    }

    private static func settingsExactItemRecordGap() {
        print("[ExactItemRecordGapView]")

        let weaponRow = ExactItemRecordGapMetrics.row(category: .weapon)
        let offhandRow = ExactItemRecordGapMetrics.row(category: .offhand)
        let armorRow = ExactItemRecordGapMetrics.row(category: .armor)
        let accessoryRow = ExactItemRecordGapMetrics.row(category: .accessory)
        let swordTypeRow = ExactItemRecordGapMetrics.row(equipmentType: .sword)
        let amuletTypeRow = ExactItemRecordGapMetrics.row(equipmentType: .amulet)
        let missingEvidenceRows = ExactItemRecordGapMetrics.missingEvidenceRows
        let categoryQueueRows = ExactItemRecordGapMetrics.categoryEvidenceQueueRows
        let rarityQueueRows = ExactItemRecordGapMetrics.rarityEvidenceQueueRows
        let categoryRarityQueueRows = ExactItemRecordGapMetrics.categoryRarityEvidenceQueueRows
        let typeQueueRows = ExactItemRecordGapMetrics.typeEvidenceQueueRows
        let progressionQueueRows = ExactItemRecordGapMetrics.progressionEvidenceQueueRows
        let largestMissingTypeRows = ExactItemRecordGapMetrics.largestMissingTypeEvidenceRows
        let swordQueueRow = typeQueueRows.first { $0.row.gearType.equipmentType == .sword }
        let amuletQueueRow = typeQueueRows.first { $0.row.gearType.equipmentType == .amulet }
        let swordProgressionQueueRow = progressionQueueRows.first {
            $0.gearType.equipmentType == .sword && $0.progression.id == "300001"
        }
        let bracerProgressionQueueRow = progressionQueueRows.first {
            $0.gearType.equipmentType == .bracer && $0.progression.id == "631191"
        }
        let rarityQueueByRarity = Dictionary(
            uniqueKeysWithValues: rarityQueueRows.map { ($0.rarity, $0) }
        )
        let categoryRarityQueueByID = Dictionary(
            uniqueKeysWithValues: categoryRarityQueueRows.map { ($0.id, $0) }
        )

        expect(
            ExactItemRecordGapMetrics.aggregateEntryCount == 5_760 &&
                ExactItemRecordGapMetrics.baseProgressionCount == 396 &&
                ExactItemRecordGapMetrics.sourceGearTypeCount == 20 &&
                ExactItemRecordGapMetrics.coverageText == "0/5760" &&
                ExactItemRecordGapMetrics.missingRecordCount == 5_760,
            "settings exact item record gap review keeps aggregate, progression and exact-record counts explicit"
        )
        expect(
            ExactItemRecordGapMetrics.categoryRows.count == 4 &&
                weaponRow?.typeCount == 6 &&
                weaponRow?.aggregateEntryCount == 1_752 &&
                weaponRow?.baseProgressionCount == 120 &&
                offhandRow?.typeCount == 6 &&
                offhandRow?.aggregateEntryCount == 1_752 &&
                offhandRow?.baseProgressionCount == 120,
            "settings exact item record gap review preserves weapon and offhand source buckets"
        )
        expect(
            armorRow?.typeCount == 4 &&
                armorRow?.aggregateEntryCount == 1_168 &&
                armorRow?.baseProgressionCount == 80 &&
                accessoryRow?.typeCount == 4 &&
                accessoryRow?.aggregateEntryCount == 1_088 &&
                accessoryRow?.baseProgressionCount == 76,
            "settings exact item record gap review preserves armor and accessory source buckets"
        )
        expect(
            ExactItemRecordGapMetrics.categoryRows.allSatisfy { $0.exactRecordCount == 0 && $0.missingRecordCount == $0.aggregateEntryCount },
            "settings exact item record gap review keeps every category marked as exact-record missing"
        )
        expect(
            ExactItemRecordGapMetrics.typeRows.count == 20 &&
                ExactItemRecordGapMetrics.typeRows.allSatisfy { $0.exactRecordCount == 0 && $0.missingRecordCount == $0.aggregateEntryCount },
            "settings exact item record gap review exposes all source gear type rows as exact-record gaps"
        )
        expect(
            swordTypeRow?.aggregateEntryCount == 292 &&
                swordTypeRow?.baseProgressionCount == 20 &&
                swordTypeRow?.rarityDistributionText == "C:20 U:38 R:38 L:38 I:38 A:32 B:28 Ce:24 D:20 Co:16" &&
                amuletTypeRow?.aggregateEntryCount == 272 &&
                amuletTypeRow?.baseProgressionCount == 19 &&
                amuletTypeRow?.rarityDistributionText == "C:0 U:38 R:38 L:38 I:38 A:32 B:28 Ce:24 D:20 Co:16",
            "settings exact item record gap review preserves per-type rarity distributions without creating exact variants"
        )
        expect(
            ExactItemRecordGapMetrics.categoryEvidenceQueueCount == 4 &&
                ExactItemRecordGapMetrics.rarityEvidenceQueueCount == 10 &&
                ExactItemRecordGapMetrics.categoryRarityEvidenceQueueCount == 40 &&
                ExactItemRecordGapMetrics.progressionEvidenceQueueCount == 396 &&
                ExactItemRecordGapMetrics.typeEvidenceQueueCount == 20 &&
                ExactItemRecordGapMetrics.largestMissingTypeEvidenceCount == 16 &&
                ExactItemRecordGapMetrics.evidenceQueueCoverageCount == ExactItemRecordGapMetrics.missingRecordCount &&
                ExactItemRecordGapMetrics.rarityEvidenceQueueCoverageCount == ExactItemRecordGapMetrics.missingRecordCount &&
                ExactItemRecordGapMetrics.categoryRarityEvidenceQueueCoverageCount == ExactItemRecordGapMetrics.missingRecordCount &&
                ExactItemRecordGapMetrics.progressionEvidenceQueueCoverageCount == ExactItemRecordGapMetrics.baseProgressionCount &&
                ExactItemRecordGapMetrics.largestMissingTypeEvidenceCoverageCount == 4_672 &&
                categoryQueueRows.map { $0.row.aggregateEntryCount }.reduce(0, +) == 5_760 &&
                rarityQueueRows.map(\.aggregateEntryCount).reduce(0, +) == 5_760 &&
                categoryRarityQueueRows.map(\.aggregateEntryCount).reduce(0, +) == 5_760 &&
                progressionQueueRows.count == 396 &&
                typeQueueRows.map { $0.row.aggregateEntryCount }.reduce(0, +) == 5_760,
            "settings exact item record gap review groups missing records into evidence queues"
        )
        expect(
            rarityQueueRows.map(\.rarity) == Rarity.allCases &&
                rarityQueueByRarity[.common]?.aggregateEntryCount == 320 &&
                rarityQueueByRarity[.common]?.typeCount == 16 &&
                rarityQueueByRarity[.uncommon]?.aggregateEntryCount == 760 &&
                rarityQueueByRarity[.rare]?.aggregateEntryCount == 760 &&
                rarityQueueByRarity[.legendary]?.aggregateEntryCount == 760 &&
                rarityQueueByRarity[.immortal]?.aggregateEntryCount == 760 &&
                rarityQueueByRarity[.arcana]?.aggregateEntryCount == 640 &&
                rarityQueueByRarity[.beyond]?.aggregateEntryCount == 560 &&
                rarityQueueByRarity[.celestial]?.aggregateEntryCount == 480 &&
                rarityQueueByRarity[.divine]?.aggregateEntryCount == 400 &&
                rarityQueueByRarity[.cosmic]?.aggregateEntryCount == 320 &&
                rarityQueueByRarity[.cosmic]?.typeCount == 20 &&
                rarityQueueRows.allSatisfy { $0.exactRecordCount == 0 && $0.missingRecordCount == $0.aggregateEntryCount },
            "settings exact item record gap review preserves aggregate rarity queues without creating exact variants"
        )
        expect(
            categoryRarityQueueRows.count == EquipmentCategory.allCases.count * Rarity.allCases.count &&
                categoryRarityQueueRows.first?.category == .weapon &&
                categoryRarityQueueRows.first?.rarity == .common &&
                categoryRarityQueueRows.last?.category == .accessory &&
                categoryRarityQueueRows.last?.rarity == .cosmic &&
                categoryRarityQueueByID["武器-普通"]?.aggregateEntryCount == 120 &&
                categoryRarityQueueByID["武器-普通"]?.typeCount == 6 &&
                categoryRarityQueueByID["副手-神圣"]?.aggregateEntryCount == 120 &&
                categoryRarityQueueByID["护甲-宇宙"]?.aggregateEntryCount == 64 &&
                categoryRarityQueueByID["饰品-普通"]?.aggregateEntryCount == 0 &&
                categoryRarityQueueByID["饰品-普通"]?.typeCount == 0 &&
                categoryRarityQueueByID["饰品-优秀"]?.aggregateEntryCount == 152 &&
                categoryRarityQueueRows.allSatisfy { $0.exactRecordCount == 0 && $0.missingRecordCount == $0.aggregateEntryCount },
            "settings exact item record gap review preserves category-rarity matrix queues without creating exact variants"
        )
        expect(
            categoryQueueRows.first?.row.category == .weapon &&
                categoryQueueRows.first?.currentEvidence == "6 类型 / 1752 聚合项 / 120 基础进度" &&
                categoryQueueRows.last?.row.category == .accessory &&
                categoryQueueRows.last?.currentEvidence == "4 类型 / 1088 聚合项 / 76 基础进度" &&
                rarityQueueRows.first?.currentEvidence == "16 类型含该稀有度 / 320 聚合项 / 0 精确记录" &&
                rarityQueueRows.last?.currentEvidence == "20 类型含该稀有度 / 320 聚合项 / 0 精确记录" &&
                categoryRarityQueueRows.first?.currentEvidence == "6 类型 / 120 聚合项 / 0 精确记录" &&
                categoryRarityQueueRows.last?.currentEvidence == "4 类型 / 64 聚合项 / 0 精确记录" &&
                swordQueueRow?.progressionSpanText == "300001 L1 -> 300020 L100" &&
                swordQueueRow?.currentEvidence == "聚合 292 / 基础 20 / 300001 L1 -> 300020 L100" &&
                amuletQueueRow?.progressionSpanText == "601011 L1 -> 601191 L90" &&
                amuletQueueRow?.currentEvidence == "聚合 272 / 基础 19 / 601011 L1 -> 601191 L90" &&
                progressionQueueRows.first?.gearType.equipmentType == .sword &&
                progressionQueueRows.first?.progression.id == "300001" &&
                progressionQueueRows.last?.gearType.equipmentType == .bracer &&
                progressionQueueRows.last?.progression.id == "631191" &&
                swordProgressionQueueRow?.currentEvidence == "#300001 / L1 / Sword / 0 精确记录" &&
                bracerProgressionQueueRow?.currentEvidence == "#631191 / L90 / Bracer / 0 精确记录",
            "settings exact item record gap review keeps evidence queues tied to source gear progressions"
        )
        expect(
            largestMissingTypeRows.count == 16 &&
                largestMissingTypeRows.first?.row.gearType.equipmentType == .sword &&
                largestMissingTypeRows.last?.row.gearType.equipmentType == .boots &&
                largestMissingTypeRows.allSatisfy { $0.row.missingRecordCount == 292 } &&
                largestMissingTypeRows.map { $0.row.missingRecordCount }.reduce(0, +) == 4_672 &&
                ExactItemRecordGapMetrics.largestMissingTypeMissingRecordCount == 292 &&
                ExactItemRecordGapMetrics.largestMissingTypeCategorySummaryText == "武器 6 / 副手 6 / 护甲 4",
            "settings exact item record gap review exposes the largest missing type queues without creating variants"
        )
        expect(
            ExactItemRecordGapMetrics.evidenceQueueBoundaryText.contains("接入队列") &&
                ExactItemRecordGapMetrics.evidenceQueueBoundaryText.contains("不按类别") &&
                ExactItemRecordGapMetrics.evidenceQueueBoundaryText.contains("基础图标") &&
                ExactItemRecordGapMetrics.evidenceQueueBoundaryText.contains("不生成装备记录") &&
                ExactItemRecordGapMetrics.largestMissingTypeBoundaryText.contains("最大类型缺口") &&
                ExactItemRecordGapMetrics.largestMissingTypeBoundaryText.contains("不按最大缺口") &&
                ExactItemRecordGapMetrics.largestMissingTypeBoundaryText.contains("不生成装备记录") &&
                categoryQueueRows.allSatisfy { $0.boundary.contains("不按聚合项") } &&
                rarityQueueRows.allSatisfy {
                    $0.boundary.contains("不从") &&
                        $0.boundary.contains("稀有度聚合项") &&
                        $0.boundary.contains("不生成")
                } &&
                categoryRarityQueueRows.allSatisfy {
                    $0.boundary.contains("矩阵") &&
                        $0.boundary.contains("不生成装备记录") &&
                        $0.boundary.contains("新图标")
                } &&
                progressionQueueRows.allSatisfy {
                    $0.boundary.contains("基础进度只证明") &&
                        $0.boundary.contains("不扩展为装备记录") &&
                        $0.boundary.contains("新图标")
                } &&
                typeQueueRows.allSatisfy { $0.boundary.contains("不从") },
            "settings exact item record gap review keeps evidence queues from fabricating item records"
        )
        expect(
            missingEvidenceRows.count == 5 &&
                missingEvidenceRows.map(\.key) == ["variant-id", "affix-roll", "drop-weight", "icon-variant", "provenance"] &&
                missingEvidenceRows.allSatisfy { $0.affectedRecordCount == ExactItemRecordGapMetrics.missingRecordCount } &&
                missingEvidenceRows.first?.currentEvidence.contains("396") == true &&
                missingEvidenceRows.first { $0.key == "icon-variant" }?.requiredProof.contains("5,760") == true &&
                missingEvidenceRows.last?.requiredProof.contains("独立证据") == true,
            "settings exact item record gap review exposes missing evidence gates before exact item records can be modeled"
        )
        expect(
            ExactItemRecordGapMetrics.noExactRecordBoundaryText.contains("未取得") &&
                ExactItemRecordGapMetrics.progressionBoundaryText.contains("不等于") &&
                ExactItemRecordGapMetrics.typePageBoundaryText.contains("聚合数量") &&
                ExactItemRecordGapMetrics.statRollBoundaryText.contains("待核对") &&
                ExactItemRecordGapMetrics.missingEvidenceBoundaryText.contains("不生成") &&
                ExactItemRecordGapMetrics.missingEvidenceBoundaryText.contains("新图标"),
            "settings exact item record gap review keeps variant and stat-roll boundaries explicit"
        )
    }

    private static func settingsSourceCraftingRules() {
        print("[SourceCraftingRuleReviewView]")

        let skipExamples = SourceCraftingRuleMetrics.synthesisSkipExamples
        expect(
            SourceCraftingRuleMetrics.rarityCount == 10 &&
                SourceCraftingRuleMetrics.synthesisInputCount == 9 &&
                SourceCraftingRuleMetrics.synthesisModeledTransitionCount == 9,
            "settings crafting source review summarizes rarity count, input count and modeled next-rarity transitions"
        )
        expect(
            Rarity.common.synthesisOutputRarity == .uncommon &&
                Rarity.divine.synthesisOutputRarity == .cosmic &&
                Rarity.cosmic.synthesisOutputRarity == nil,
            "settings crafting source review keeps Cosmic output unfabricated"
        )
        expect(
            SourceCraftingRuleMetrics.cubeXPTableCount == 10 &&
                SourceCraftingRuleMetrics.alchemyGoldTableCount == 10 &&
                SourceCraftingRuleMetrics.tableCoverageText == "10/10",
            "settings crafting source review exposes checked Cube XP and Alchemy gold table coverage"
        )
        expect(
            SourceCraftingRuleMetrics.cubeRewardRuneCoverageText == "4/4" &&
                SourceCraftingRuleMetrics.cubeRewardBonusPerNodeText == "10%" &&
                SourceCraftingRuleMetrics.cubeRewardMaximumSideBonusText == "40%" &&
                SourceCraftingRuleMetrics.cubeRewardRuneBoundaryText.contains("成本") &&
                SourceCraftingRuleMetrics.cubeRewardRuneBoundaryText.contains("Cube 等级奖励") &&
                SourceCraftingRuleMetrics.cubeRewardRuneBoundaryText.contains("炼金经济曲线"),
            "settings crafting source review exposes local Cube and Alchemy reward Rune scaffolds without hiding economy gaps"
        )
        expect(
            skipExamples.count == 4 &&
                skipExamples.contains(SourceSynthesisSkipExample(from: .common, to: .rare, chanceText: "~60%")) &&
                skipExamples.contains(SourceSynthesisSkipExample(from: .uncommon, to: .legendary, chanceText: "~40%")) &&
                skipExamples.contains(SourceSynthesisSkipExample(from: .rare, to: .legendary, chanceText: "~20%")) &&
                skipExamples.contains(SourceSynthesisSkipExample(from: .legendary, to: .immortal, chanceText: "~5%")),
            "settings crafting source review keeps approximate Synthesis skip-tier examples visible"
        )
        expect(
            SourceCraftingRuleMetrics.unknownSynthesisProbabilityText.contains("待核对") &&
                SourceCraftingRuleMetrics.unknownItemLevelDowngradeText.contains("待核对") &&
                SourceCraftingRuleMetrics.unknownSynthesisLevelCostText.contains("待核对") &&
                SourceCraftingRuleMetrics.unknownCubeLevelRewardText.contains("待核对"),
            "settings crafting source review keeps Synthesis/Cube unknown boundaries explicit"
        )
    }

    private static func settingsModeledActiveSkillValueTables() {
        print("[ModeledActiveSkillValueTableView]")

        let rows = ModeledActiveSkillValueTableMetrics.rows
        let rowIDs = Set(rows.map(\.skillID))

        expect(
            ModeledActiveSkillValueTableMetrics.rowCount == 36 &&
                rowIDs.count == 36,
            "settings modeled active skill value review exposes all 36 runtime named skills"
        )
        expect(
            ModeledActiveSkillValueTableMetrics.fullTenLevelTableCount == 36 &&
                rows.allSatisfy { $0.levelCount == 10 && !$0.valuesText.isEmpty },
            "settings modeled active skill value review keeps complete ten-level tables visible"
        )
        expect(
            ModeledActiveSkillValueTableMetrics.heroClassCount == HeroClass.allCases.count &&
                ModeledActiveSkillValueTableMetrics.heroClassRowCounts.values.allSatisfy { $0 == 6 },
            "settings modeled active skill value review keeps six visible skills per hero class"
        )
        expect(
            ModeledActiveSkillValueTableMetrics.sourceBackedCount == 36 &&
                rows.allSatisfy { $0.sourceSkill != nil },
            "settings modeled active skill value review keeps every runtime row source-backed"
        )

        let expectedSamples: [String: (levelOne: Int, levelTen: Int)] = [
            "10101": (2_500, 4_300),
            "20101": (1_320, 2_400),
            "50101": (4_840, 9_430),
            "60201": (6_200, 9_800)
        ]
        expect(
            expectedSamples.allSatisfy { entry in
                guard let row = ModeledActiveSkillValueTableMetrics.row(skillID: entry.key) else { return false }
                return row.levelOneValue == entry.value.levelOne &&
                    row.levelTenValue == entry.value.levelTen &&
                    row.sourceSkill != nil
            },
            "settings modeled active skill value review keeps source-backed sample values aligned"
        )
        expect(
            ModeledActiveSkillValueTableMetrics.modeledOnlyBoundaryText.contains("36") &&
                ModeledActiveSkillValueTableMetrics.fullRuntimeBoundaryText.contains("待核对"),
            "settings modeled active skill value review keeps unmodeled source skill boundaries explicit"
        )
    }

    private static func settingsSourcePassiveSkillDatabase() {
        print("[SourcePassiveSkillDatabaseView]")

        expect(
            SourcePassiveSkillDatabaseMetrics.sourceRowCount == 108 &&
                SourcePassiveSkillDatabaseMetrics.statCount == 30 &&
                SourcePassiveSkillDatabaseMetrics.valueTypeCount == 2,
            "settings passive source review can summarize checked passive rows, stats and value types"
        )
        expect(
            SourcePassiveSkillDatabaseMetrics.sourceIconCoverageText == "104/108" &&
                SourcePassiveSkillDatabaseMetrics.sourceIconFamilyCount == 27,
            "settings passive source review exposes current source icon coverage"
        )
        expect(
            SourcePassiveSkillDatabaseMetrics.currentMissingSourceIconStats == ["IncreaseProjectileDamage", "SkillHealIncrease"] &&
                SourcePassiveSkillDatabaseMetrics.currentMissingSourceIconStats == SourcePassiveSkillDatabaseMetrics.missingSourceIconStats,
            "settings passive source review keeps missing source-icon stats explicit"
        )
        expect(
            SourcePassiveSkillDatabaseMetrics.heroClassRowCounts.values.allSatisfy { $0 == 18 } &&
                SourcePassiveSkillDatabaseMetrics.heroClassRowCounts.count == HeroClass.allCases.count,
            "settings passive source review keeps 18 passive rows per hero class visible"
        )
    }

    private static func partyAndSupport() {
        print("[HeroParty]")
        var party = HeroParty(primaryClass: .knight)
        expect(party.members.count == HeroParty.maxSlots, "party exposes three deployment slots")
        expect(party.members.map(\.heroClass) == [.knight, .priest, .ranger], "default party keeps starter lineup candidates")
        expect(party.activeMembers.map(\.heroClass) == [.knight], "new party starts with only primary slot deployed")
        expect(party.supportAttackPower(heroLevel: 1) == 0, "locked support slots do not contribute attack power")
        party.setUnlockedSlotCount(3)
        expect(party.activeMembers.map(\.heroClass) == [.knight, .priest, .ranger], "unlocked party deploys starter lineup")
        expect(party.supportAttackPower(heroLevel: 1) > 0, "unlocked support members contribute attack power")

        party.setHeroClass(.priest, atSlot: 0)
        expect(party.member(at: 0)?.heroClass == .priest, "primary party slot can change class")
        expect(Set(party.members.map(\.heroClass)).count == party.members.count, "party class changes keep slots unique")

        let hero = Hero()
        let trainingMonster = Monster(
            id: "training",
            name: "训练木桩",
            hp: 100_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battleParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 3)
        let battle = Battle(hero: hero, monster: trainingMonster, party: battleParty)
        battle.update(deltaTime: 1)
        expect(battle.log.contains { entry in
            if case .support = entry.attacker { return true }
            return false
        }, "party support attack appears in battle log")
        expect(
            battle.log.filter {
                if case .support = $0.attacker { return $0.skillName == nil }
                return false
            }.count >= 2,
            "unlocked support members each make visible support attacks"
        )
        expect(
            battle.log.contains { entry in
                entry.attacker == .support(.priest) && entry.skillName == "治愈"
            } && battle.log.contains { entry in
                entry.attacker == .support(.ranger) && entry.skillName == "散弹射击" && entry.kind == .damage
            },
            "support members execute their class cooldown skills"
        )

        let slowHero = Hero()
        slowHero.changeClass(to: .sorcerer)
        var independentParty = HeroParty(primaryClass: .sorcerer, unlockedSlotCount: 2)
        independentParty.setHeroClass(.ranger, atSlot: 1)
        let independentBattle = Battle(
            hero: slowHero,
            monster: trainingMonster,
            party: independentParty,
            activeSkillSlotCount: 1
        )
        for _ in 0..<9 {
            independentBattle.update(deltaTime: GamePacing.combatSimulationStep)
        }
        let independentHeroBaseAttacks = independentBattle.log.filter {
            $0.attacker == .hero &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        let independentSupportBaseAttacks = independentBattle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        expect(
            independentSupportBaseAttacks > independentHeroBaseAttacks,
            "support members attack on independent support-speed cooldowns instead of waiting for main hero attacks"
        )
    }

    private static func battleSkills() {
        print("[BattleSkills]")
        let allNamedSkills = HeroClass.allCases.flatMap { HeroSkills.named(for: $0) }
        let piercingThrust = allNamedSkills.first { $0.id == "10101" }
        let shieldCharge = allNamedSkills.first { $0.id == "10201" }
        let retributionStrike = allNamedSkills.first { $0.id == "10301" }
        let aegisField = allNamedSkills.first { $0.id == "10401" }
        let unyieldingWill = allNamedSkills.first { $0.id == "10601" }
        let rapidFire = allNamedSkills.first { $0.id == "20101" }
        let scatterShot = allNamedSkills.first { $0.id == "20201" }
        let arrowRain = allNamedSkills.first { $0.id == "20301" }
        let swiftSurge = allNamedSkills.first { $0.id == "20401" }
        let piercingArrow = allNamedSkills.first { $0.id == "20501" }
        let skewerShot = allNamedSkills.first { $0.id == "20601" }
        let fireball = allNamedSkills.first { $0.id == "30101" }
        let iceOrb = allNamedSkills.first { $0.id == "30201" }
        let lightning = allNamedSkills.first { $0.id == "30301" }
        let flameHydra = allNamedSkills.first { $0.id == "30401" }
        let snowstorm = allNamedSkills.first { $0.id == "30501" }
        let meteorStrike = allNamedSkills.first { $0.id == "30601" }
        let explosiveBolt = allNamedSkills.first { $0.id == "50101" }
        let frostBolt = allNamedSkills.first { $0.id == "50201" }
        let chargedTrap = allNamedSkills.first { $0.id == "50401" }
        let crossbowTurret = allNamedSkills.first { $0.id == "50501" }
        let shockBolt = allNamedSkills.first { $0.id == "50601" }
        let heal = allNamedSkills.first { $0.id == "40101" }
        let blessingOfMight = allNamedSkills.first { $0.id == "40201" }
        let wrathOfHeaven = allNamedSkills.first { $0.id == "40301" }
        let sanctuary = allNamedSkills.first { $0.id == "40401" }
        let resurrection = allNamedSkills.first { $0.id == "40601" }
        let slamJump = allNamedSkills.first { $0.id == "60101" }
        let crushingBlow = allNamedSkills.first { $0.id == "60201" }
        let generalsRoar = allNamedSkills.first { $0.id == "60301" }
        let groundSlam = allNamedSkills.first { $0.id == "60401" }
        let axeSpin = allNamedSkills.first { $0.id == "60501" }
        let bloodlust = allNamedSkills.first { $0.id == "60601" }
        expect(allNamedSkills.count == 36, "six hero classes expose 36 named active skills")
        expect(allNamedSkills.allSatisfy { $0.levelValues.count == 10 }, "named active skills include ten-level source value tables")
        expect(piercingThrust?.levelOneValue == 2_500 && piercingThrust?.value(at: 10) == 4_300 && piercingThrust?.damageMultiplier == 25.0, "Piercing Thrust uses source level values and Lv1 damage percent")
        expect(shieldCharge?.levelOneValue == 3_000 && shieldCharge?.value(at: 10) == 5_700 && shieldCharge?.damageMultiplier == 30.0, "Shield Charge uses source collision damage table")
        expect(retributionStrike?.levelOneValue == 1_500 && retributionStrike?.value(at: 10) == 3_300 && retributionStrike?.damageMultiplier == 15.0, "Retribution Strike uses source per-hit damage table")
        expect(aegisField?.levelOneValue == 500 && aegisField?.value(at: 10) == 1_850, "Aegis Field uses source damage-block value table")
        expect(unyieldingWill?.levelOneValue == 300 && unyieldingWill?.value(at: 10) == 1_200, "Unyielding Will uses source revive value table")
        expect(rapidFire?.levelOneValue == 1_320 && rapidFire?.value(at: 10) == 2_400 && rapidFire?.damageMultiplier == 13.2, "Rapid Fire uses source physical projectile damage table")
        expect(scatterShot?.levelOneValue == 1_620 && scatterShot?.value(at: 10) == 3_060 && scatterShot?.damageMultiplier == 16.2, "Scatter Shot uses source physical tracking projectile damage table")
        expect(arrowRain?.levelOneValue == 2_150 && arrowRain?.value(at: 10) == 4_490 && arrowRain?.damageMultiplier == 21.5, "Arrow Rain uses source physical range damage table")
        expect(swiftSurge?.levelOneValue == 500 && swiftSurge?.value(at: 10) == 1_400, "Swift Surge uses source attack-speed value table")
        expect(piercingArrow?.levelOneValue == 2_440 && piercingArrow?.value(at: 10) == 3_880 && piercingArrow?.damageMultiplier == 24.4, "Piercing Arrow uses source physical projectile damage table")
        expect(skewerShot?.levelOneValue == 1_000 && skewerShot?.value(at: 10) == 3_700 && skewerShot?.damageMultiplier == 10.0, "Skewer Shot uses source lodged-arrow damage table")
        expect(fireball?.levelOneValue == 2_700 && fireball?.value(at: 10) == 4_950 && fireball?.damageMultiplier == 27.0, "Fireball uses source fire range damage table")
        expect(iceOrb?.levelOneValue == 1_500 && iceOrb?.value(at: 10) == 2_580 && iceOrb?.damageMultiplier == 15.0, "Ice Orb uses source cold multi-hit value table")
        expect(lightning?.levelOneValue == 2_550 && lightning?.value(at: 10) == 4_980 && lightning?.damageMultiplier == 25.5, "Lightning uses source AOE lightning damage table")
        expect(flameHydra?.levelOneValue == 2_300 && flameHydra?.value(at: 10) == 3_650 && flameHydra?.damageMultiplier == 23.0, "Flame Hydra uses source summon fire projectile damage table")
        expect(snowstorm?.levelOneValue == 500 && snowstorm?.value(at: 10) == 1_940 && snowstorm?.damageMultiplier == 5.0, "Snowstorm uses source cold range damage-per-second table")
        expect(meteorStrike?.levelOneValue == 5_500 && meteorStrike?.value(at: 10) == 9_550 && meteorStrike?.damageMultiplier == 55.0, "Meteor Strike uses source fire range damage table")
        expect(explosiveBolt?.levelOneValue == 4_840 && explosiveBolt?.value(at: 10) == 9_430 && explosiveBolt?.damageMultiplier == 48.4, "Explosive Bolt uses source fire projectile explosion damage table")
        expect(frostBolt?.levelOneValue == 2_100 && frostBolt?.value(at: 10) == 3_450 && frostBolt?.damageMultiplier == 21.0, "Frost Bolt uses source cold projectile explosion damage table")
        expect(chargedTrap?.levelOneValue == 1_000 && chargedTrap?.value(at: 10) == 5_500, "Charge Trap uses source trap value table")
        expect(crossbowTurret?.levelOneValue == 1_750 && crossbowTurret?.value(at: 10) == 3_190 && crossbowTurret?.damageMultiplier == 17.5, "Crossbow Turret uses source physical projectile summon damage table")
        expect(shockBolt?.levelOneValue == 2_700 && shockBolt?.value(at: 10) == 4_500 && shockBolt?.damageMultiplier == 27.0, "Shock Bolt uses source lightning projectile damage table")
        expect(wrathOfHeaven?.levelOneValue == 4_300 && wrathOfHeaven?.value(at: 10) == 7_900, "Wrath of Heaven uses source lightning attack value table")
        expect(sanctuary?.levelOneValue == 300 && sanctuary?.value(at: 10) == 1_920, "Sanctuary uses source healing-over-time value table")
        expect(resurrection?.levelOneValue == 300 && resurrection?.value(at: 10) == 750, "Resurrection uses source revive value table")
        expect(
                heal?.levelOneValue == 100 &&
                blessingOfMight?.levelOneValue == 500 &&
                slamJump?.levelOneValue == 3_100 &&
                slamJump?.value(at: 10) == 5_350 &&
                slamJump?.damageMultiplier == 31.0 &&
                crushingBlow?.damageMultiplier == 62.0 &&
                generalsRoar?.levelOneValue == 500 &&
                generalsRoar?.value(at: 10) == 950 &&
                groundSlam?.levelOneValue == 3_700 &&
                groundSlam?.value(at: 10) == 5_950 &&
                groundSlam?.damageMultiplier == 37.0 &&
                axeSpin?.levelOneValue == 1_000 &&
                axeSpin?.value(at: 10) == 1_720 &&
                axeSpin?.damageMultiplier == 10.0 &&
                bloodlust?.levelOneValue == 4_000 &&
                bloodlust?.value(at: 10) == 6_700,
            "Priest utility and Slayer burst skills use source Lv1 values"
        )
        expect(
            allNamedSkills
                .filter { $0.damageMultiplier > 0 }
                .allSatisfy { $0.damageElement != .none && $0.delivery != .none },
            "damaging skills carry structured element and delivery metadata"
        )
        expect(
            Set(allNamedSkills.map(\.damageElement)).isSuperset(of: [.physical, .fire, .cold, .lightning]),
            "modeled skills cover physical, fire, cold and lightning damage elements"
        )
        expect(
            fireball?.damageElement == .fire &&
                iceOrb?.damageElement == .cold &&
                lightning?.damageElement == .lightning &&
                explosiveBolt?.delivery == .projectileAOE &&
                chargedTrap?.delivery == .trap &&
                chargedTrap?.damageElement.isElemental == false &&
                crossbowTurret?.delivery == .summonProjectile &&
                resurrection?.delivery == .resurrection,
            "skill metadata preserves checked source element and delivery categories"
        )
        expect(
            HeroSkills.skill(forLogSkillName: "充能陷阱爆炸")?.id == "50401" &&
                HeroSkills.skill(forLogSkillName: "电击弩箭电流")?.id == "50601",
            "derived battle log skill names resolve to their source skill metadata"
        )
        let fireDamageLog = BattleLogEntry(attacker: .hero, damage: 1, isCrit: false, skillName: "火球术")
        let coldDamageLog = BattleLogEntry(attacker: .hero, damage: 1, isCrit: false, skillName: "寒霜弩箭")
        let trapExplosionLog = BattleLogEntry(attacker: .hero, damage: 1, isCrit: false, skillName: "充能陷阱爆炸")
        expect(
            fireDamageLog.damageElement == .fire &&
                fireDamageLog.delivery == .rangeAOE &&
                fireDamageLog.sourceRange == 950 &&
                coldDamageLog.damageElement == .cold &&
                coldDamageLog.delivery == .projectileAOE &&
                coldDamageLog.sourceRange == 1_100 &&
                trapExplosionLog.damageElement == .physical &&
                trapExplosionLog.delivery == .trap &&
                trapExplosionLog.sourceRange == 1_150,
            "battle log entries infer element, delivery and source range metadata for visual combat feedback"
        )
        let sourceMonsterLog = BattleLogEntry(
            attacker: .monster,
            damage: 1,
            isCrit: false,
            damageElement: .fire,
            attackerName: "燃烧的地狱祭司"
        )
        expect(
            sourceMonsterLog.sourceRange == 800,
            "source-backed monster battle logs infer checked source attack range"
        )

        func mainHeroSkillLog(
            heroClass: HeroClass,
            skillID: String,
            skillName: String,
            updateCount: Int = 1
        ) -> BattleLogEntry? {
            let hero = Hero()
            hero.changeClass(to: heroClass)
            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkill(skillID, for: heroClass, slotIndex: 0)
            let metadataMonster = Monster(
                id: "main-skill-metadata-\(skillID)",
                name: "主英雄技能元数据训练木桩",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
            let battle = Battle(
                hero: hero,
                monster: metadataMonster,
                party: HeroParty(primaryClass: heroClass),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            for _ in 0..<updateCount {
                battle.update(deltaTime: 10)
            }
            return battle.log.first {
                $0.attacker == .hero &&
                    $0.kind == .damage &&
                    $0.skillName == skillName
            }
        }

        let liveFireballLog = mainHeroSkillLog(heroClass: .sorcerer, skillID: "30101", skillName: "火球术")
        let liveFrostBoltLog = mainHeroSkillLog(heroClass: .hunter, skillID: "50201", skillName: "寒霜弩箭")
        let liveRapidFireLog = mainHeroSkillLog(
            heroClass: .ranger,
            skillID: "20101",
            skillName: "快速射击",
            updateCount: 3
        )
        expect(
            liveFireballLog?.damageElement == .fire &&
                liveFireballLog?.delivery == .rangeAOE &&
                liveFrostBoltLog?.damageElement == .cold &&
                liveFrostBoltLog?.delivery == .projectileAOE &&
                liveRapidFireLog?.damageElement == .physical &&
                liveRapidFireLog?.delivery == .projectile,
            "main hero damage skill logs preserve source element and delivery metadata in live battle logs"
        )

        let sourceBaseAttackSorcerer = Hero()
        sourceBaseAttackSorcerer.changeClass(to: .sorcerer)
        let baseAttackMonster = Monster(
            id: "base-attack-metadata",
            name: "基础攻击元数据训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let sorcererBattle = Battle(
            hero: sourceBaseAttackSorcerer,
            monster: baseAttackMonster,
            party: HeroParty(primaryClass: .sorcerer),
            activeSkillSlotCount: 1
        )
        sorcererBattle.update(deltaTime: 1)
        let sorcererBaseAttack = sorcererBattle.log.first {
            $0.attacker == .hero && $0.skillName == nil && $0.kind == .damage
        }
        expect(
            sorcererBaseAttack?.damageElement == .fire &&
                sorcererBaseAttack?.delivery == .projectile &&
                BattleImpactCue.visible(for: sorcererBaseAttack) == .fireBurst &&
                BattleTrajectoryCue.visible(for: sorcererBaseAttack) == .projectile,
            "source-backed Sorcerer base attacks expose fire projectile visual metadata"
        )

        let knightSupportHost = Hero()
        var rangerSupportParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        rangerSupportParty.setHeroClass(.ranger, atSlot: 1)
        let rangerSupportBattle = Battle(
            hero: knightSupportHost,
            monster: baseAttackMonster,
            party: rangerSupportParty,
            activeSkillSlotCount: 1
        )
        rangerSupportBattle.update(deltaTime: 1)
        let rangerBaseAttack = rangerSupportBattle.log.first {
            $0.attacker == .support(.ranger) && $0.skillName == nil && $0.kind == .damage
        }
        expect(
            rangerBaseAttack?.damageElement == .physical &&
                rangerBaseAttack?.delivery == .projectile &&
                BattleTrajectoryCue.visible(for: rangerBaseAttack) == .projectile,
            "source-backed support Ranger base attacks expose physical projectile visual metadata"
        )

        let knight = Hero()
        let trainingMonster = Monster(
            id: "training-skill",
            name: "技能训练木桩",
            hp: 1_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        expect(
            HeroSkills.activeLoadout(for: .knight, heroLevel: 1, slotCount: 1).map(\.id) == ["10101"] &&
                HeroSkills.activeLoadout(for: .knight, heroLevel: 1, slotCount: 2).map(\.id) == ["10101", "10201"],
            "active skill loadout follows the modeled slot count"
        )
        expect(
            HeroSkills.activeLoadout(
                for: .knight,
                heroLevel: 1,
                slotCount: 2,
                preferredSkillIDs: ["invalid", "10201", "10201"]
            ).map(\.id) == ["10201", "10101"],
            "active skill loadout honors valid selected skill IDs and fills missing slots"
        )
        var selectedLoadouts = ActiveSkillLoadouts()
        selectedLoadouts.setSkill("10201", for: .knight, slotIndex: 0)
        expect(
            selectedLoadouts.activeSkills(for: .knight, heroLevel: 1, slotCount: 1).map(\.id) == ["10201"],
            "active skill loadout can replace the first modeled slot"
        )
        let oneSlotBattle = Battle(
            hero: Hero(),
            monster: trainingMonster,
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1
        )
        oneSlotBattle.update(deltaTime: 1)
        expect(
            oneSlotBattle.activeSkillSlotCount == 1 &&
                !oneSlotBattle.log.contains { $0.skillName == "盾牌冲锋" },
            "one active skill slot keeps the second Knight skill inactive"
        )
        let selectedSlotBattle = Battle(
            hero: Hero(),
            monster: trainingMonster,
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: selectedLoadouts
        )
        selectedSlotBattle.update(deltaTime: 1)
        expect(
            selectedSlotBattle.log.contains { $0.skillName == "盾牌冲锋" && $0.kind == .damage } &&
                !selectedSlotBattle.log.contains { $0.skillName == "穿透突刺" },
            "selected active skill loadout controls the battle slot instead of always using first-N skills"
        )
        let twoSlotBattle = Battle(
            hero: Hero(),
            monster: trainingMonster,
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 2
        )
        twoSlotBattle.update(deltaTime: 1)
        expect(
            twoSlotBattle.activeSkillSlotCount == 2 &&
                twoSlotBattle.log.contains { $0.skillName == "盾牌冲锋" && $0.kind == .damage },
            "second active skill slot enables the second Knight skill"
        )
        let skillBattle = Battle(hero: knight, monster: trainingMonster, party: HeroParty(primaryClass: .knight))
        skillBattle.update(deltaTime: 1)
        expect(skillBattle.log.contains { $0.skillName == "盾牌冲锋" && $0.kind == .damage }, "hero cooldown skill executes in battle")
        expect(skillBattle.monsterHP < trainingMonster.hp, "hero skill deals visible damage")

        let shieldChargeHero = Hero()
        let shieldChargeMonsters = (1...3).map { index in
            Monster(
                id: "shield-charge-\(index)",
                name: "盾牌冲锋训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let shieldChargeBattle = Battle(hero: shieldChargeHero, monsters: shieldChargeMonsters, party: HeroParty(primaryClass: .knight))
        shieldChargeBattle.update(deltaTime: 1)
        let shieldChargeLogs = shieldChargeBattle.log.filter { $0.skillName == "盾牌冲锋" && $0.kind == .damage }
        expect(
            shieldChargeLogs.count == 1 &&
                shieldChargeLogs.allSatisfy { $0.damageElement == .physical && $0.delivery == .melee } &&
                (shieldChargeBattle.enemyStates.first?.hp ?? 0) < (shieldChargeBattle.enemyStates.first?.maxHP ?? 0) &&
                shieldChargeBattle.enemyStates.dropFirst().allSatisfy { $0.hp == $0.maxHP },
            "Shield Charge keeps source Melee delivery focused on the collision target instead of widening into AOE"
        )

        let piercingThrustHero = Hero()
        let piercingThrustMonsters = (1...3).map { index in
            Monster(
                id: "piercing-thrust-\(index)",
                name: "穿透突刺训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let piercingThrustBattle = Battle(hero: piercingThrustHero, monsters: piercingThrustMonsters, party: HeroParty(primaryClass: .knight))
        for _ in 0..<5 {
            piercingThrustBattle.update(deltaTime: 1)
            if piercingThrustBattle.log.filter({ $0.skillName == "穿透突刺" && $0.kind == .damage }).count >= 3 {
                break
            }
        }
        expect(
            piercingThrustBattle.log.filter { $0.skillName == "穿透突刺" && $0.kind == .damage }.count >= 3,
            "Piercing Thrust applies checked melee range damage across the live wave scaffold"
        )

        for _ in 0..<4 {
            skillBattle.update(deltaTime: 1)
        }
        expect(skillBattle.log.contains { $0.skillName == "穿透突刺" && $0.kind == .damage }, "attack-count skill executes after base attacks")

        let retributionTrainingMonster = Monster(
            id: "retribution-training",
            name: "报应打击训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let healthyRetributionHero = Hero()
        let healthyRetributionBattle = Battle(hero: healthyRetributionHero, monster: retributionTrainingMonster, party: HeroParty(primaryClass: .knight))
        for _ in 0..<14 {
            healthyRetributionBattle.update(deltaTime: 1)
            if healthyRetributionBattle.log.contains(where: { $0.skillName == "报应打击" && $0.kind == .damage }) {
                break
            }
        }
        let healthyRetributionHits = healthyRetributionBattle.log.filter { $0.skillName == "报应打击" && $0.kind == .damage }.count

        let woundedRetributionHero = Hero()
        let retributionLowHP = max(1, woundedRetributionHero.maxHP / 13)
        woundedRetributionHero.takeDamage(max(0, woundedRetributionHero.currentHP - retributionLowHP))
        let woundedRetributionBattle = Battle(hero: woundedRetributionHero, monster: retributionTrainingMonster, party: HeroParty(primaryClass: .knight))
        for _ in 0..<14 {
            woundedRetributionHero.takeDamage(max(0, woundedRetributionHero.currentHP - retributionLowHP))
            woundedRetributionBattle.heroHP = woundedRetributionHero.currentHP
            woundedRetributionBattle.update(deltaTime: 1)
            if woundedRetributionBattle.log.contains(where: { $0.skillName == "报应打击" && $0.kind == .damage }) {
                break
            }
        }
        let woundedRetributionHits = woundedRetributionBattle.log.filter { $0.skillName == "报应打击" && $0.kind == .damage }.count
        expect(healthyRetributionHits >= 2, "Retribution Strike applies multiple checked melee hits")
        expect(woundedRetributionHits > healthyRetributionHits && woundedRetributionHits >= 5, "Retribution Strike increases hit count when hero HP is low")

        func makeSkillRangeMonsters() -> [Monster] {
            (1...3).map { index in
                Monster(
                    id: "skill-range-\(index)",
                    name: "技能范围训练 \(index)",
                    hp: 1_000_000,
                    atk: 0,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                )
            }
        }
        var retributionLoadout = ActiveSkillLoadouts()
        retributionLoadout.setSkills(["10301"], for: .knight)
        let baselineRangeBattle = Battle(
            hero: Hero(),
            monsters: makeSkillRangeMonsters(),
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: retributionLoadout
        )
        for _ in 0..<14 {
            baselineRangeBattle.update(deltaTime: 1)
            if baselineRangeBattle.log.contains(where: { $0.skillName == "报应打击" && $0.kind == .damage }) {
                break
            }
        }

        let skillRangeHero = Hero()
        skillRangeHero.unlockedPassiveSkillIDs = ["101081"]
        let expandedRangeBattle = Battle(
            hero: skillRangeHero,
            monsters: makeSkillRangeMonsters(),
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: retributionLoadout
        )
        for _ in 0..<14 {
            expandedRangeBattle.update(deltaTime: 1)
            if expandedRangeBattle.log.contains(where: { $0.skillName == "报应打击" && $0.kind == .damage }) {
                break
            }
        }

        expect(
            baselineRangeBattle.enemyStates.filter { $0.hp < $0.maxHP }.count == 1 &&
                expandedRangeBattle.enemyStates.filter { $0.hp < $0.maxHP }.count >= 2 &&
                expandedRangeBattle.log.filter { $0.skillName == "报应打击" && $0.kind == .damage }.count >
                baselineRangeBattle.log.filter { $0.skillName == "报应打击" && $0.kind == .damage }.count,
            "Skill Range Expansion extends focused melee skill hits to an additional live enemy"
        )

        let aegisKnight = Hero()
        let aegisMonster = Monster(
            id: "aegis-training",
            name: "神盾领域训练木桩",
            hp: 10_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let aegisBattle = Battle(hero: aegisKnight, monster: aegisMonster, party: HeroParty(primaryClass: .knight))
        aegisBattle.update(deltaTime: 1)
        let hpBeforeAegisBlock = aegisKnight.currentHP
        aegisBattle.update(deltaTime: 1)
        expect(
            aegisBattle.activeBuffNames.contains("神盾领域") &&
                aegisBattle.activeHeroDamageShieldRemaining > 0 &&
                aegisBattle.activeHeroDamageShieldRemaining < 500,
            "Aegis Field applies a source-value damage shield"
        )
        expect(
            aegisKnight.currentHP == hpBeforeAegisBlock &&
                aegisBattle.log.last { $0.attacker == .monster }?.damage == 0,
            "Aegis Field blocks incoming monster damage"
        )

        let partyAegisKnight = Hero()
        let partyAegisBattle = Battle(
            hero: partyAegisKnight,
            monster: aegisMonster,
            party: HeroParty(primaryClass: .knight, unlockedSlotCount: 3)
        )
        partyAegisBattle.update(deltaTime: 1)
        let shieldedSupportSlot = 1
        let supportHPBeforeAegisBlock = partyAegisBattle.supportStates.first { $0.slotIndex == shieldedSupportSlot }?.hp ?? 0
        partyAegisBattle.update(deltaTime: 1)
        let supportHPAfterAegisBlock = partyAegisBattle.supportStates.first { $0.slotIndex == shieldedSupportSlot }?.hp ?? 0
        expect(
            partyAegisBattle.activeBuffNames.contains("神盾领域") &&
                partyAegisBattle.activeHeroDamageShieldRemaining > 0 &&
                partyAegisBattle.activeHeroDamageShieldRemaining < 500 &&
                supportHPAfterAegisBlock == supportHPBeforeAegisBlock &&
                partyAegisBattle.log.last { $0.attacker == .monster }?.damage == 0,
            "Aegis Field blocks incoming damage for living support allies"
        )

        let supportAegisHero = Hero()
        supportAegisHero.changeClass(to: .ranger)
        var supportAegisParty = HeroParty(primaryClass: .ranger, unlockedSlotCount: 2)
        supportAegisParty.setHeroClass(.knight, atSlot: 1)
        var supportAegisLoadouts = ActiveSkillLoadouts()
        supportAegisLoadouts.setSkills(["10401"], for: .knight)
        let supportAegisBattle = Battle(
            hero: supportAegisHero,
            monster: aegisMonster,
            party: supportAegisParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportAegisLoadouts
        )
        supportAegisBattle.update(deltaTime: 1)
        let supportAegisHeroHPAfterFirstBlock = supportAegisHero.currentHP
        let supportAegisSlot = 1
        let supportAegisAllyHPBeforeBlock = supportAegisBattle.supportStates.first { $0.slotIndex == supportAegisSlot }?.hp ?? 0
        supportAegisBattle.update(deltaTime: 1)
        let supportAegisAllyHPAfterBlock = supportAegisBattle.supportStates.first { $0.slotIndex == supportAegisSlot }?.hp ?? 0
        expect(
            supportAegisBattle.activeBuffNames.contains("神盾领域") &&
                supportAegisBattle.log.contains {
                    $0.attacker == .support(.knight) &&
                        $0.skillName == "神盾领域" &&
                        $0.kind == .buff
                } &&
                supportAegisBattle.activeHeroDamageShieldRemaining > 0 &&
                supportAegisBattle.activeHeroDamageShieldRemaining < 500,
            "support Knight Aegis Field applies a source-value party damage shield"
        )
        expect(
            supportAegisHero.currentHP == supportAegisHeroHPAfterFirstBlock &&
                supportAegisAllyHPAfterBlock == supportAegisAllyHPBeforeBlock &&
                supportAegisBattle.log.filter { $0.attacker == .monster }.suffix(2).allSatisfy { $0.damage == 0 },
            "support Knight Aegis Field blocks incoming monster damage for the living party"
        )

        let unyieldingKnight = Hero()
        unyieldingKnight.takeDamage(unyieldingKnight.currentHP - 10)
        let unyieldingMonster = Monster(
            id: "unyielding-training",
            name: "不屈意志训练木桩",
            hp: 100_000,
            atk: 2_000,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let unyieldingBattle = Battle(hero: unyieldingKnight, monster: unyieldingMonster, party: HeroParty(primaryClass: .knight))
        unyieldingBattle.update(deltaTime: 1)
        expect(
            !unyieldingBattle.isOver &&
                unyieldingBattle.unyieldingWillWasUsed &&
                unyieldingKnight.currentHP == unyieldingKnight.maxHP * 3 &&
                unyieldingBattle.log.contains { $0.skillName == "不屈意志" && $0.kind == .heal },
            "Unyielding Will revives from lethal monster damage with source 300% HP"
        )
        unyieldingKnight.takeDamage(unyieldingKnight.currentHP - 10)
        unyieldingBattle.heroHP = unyieldingKnight.currentHP
        unyieldingBattle.update(deltaTime: 1)
        expect(unyieldingBattle.isOver, "Unyielding Will is consumed after one trigger")

        let supportUnyieldingHero = Hero()
        supportUnyieldingHero.changeClass(to: .ranger)
        var supportUnyieldingLoadouts = ActiveSkillLoadouts()
        supportUnyieldingLoadouts.setSkills(["10601"], for: .knight)
        let supportUnyieldingParty = HeroParty(primaryClass: .ranger, unlockedSlotCount: 2)
        let supportUnyieldingMonsters = [
            Monster(
                id: "support-unyielding-low",
                name: "不屈意志轻击木桩",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            ),
            Monster(
                id: "support-unyielding-heavy",
                name: "不屈意志重击木桩",
                hp: 100_000,
                atk: 10_000,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        ]
        let supportUnyieldingBattle = Battle(
            hero: supportUnyieldingHero,
            monsters: supportUnyieldingMonsters,
            party: supportUnyieldingParty,
            activeSkillLoadouts: supportUnyieldingLoadouts
        )
        let supportUnyieldingSlot = 1
        let supportUnyieldingMaxHP = supportUnyieldingBattle.supportStates.first { $0.slotIndex == supportUnyieldingSlot }?.maxHP ?? 0
        supportUnyieldingBattle.update(deltaTime: 1)
        let supportUnyieldingRevived = supportUnyieldingBattle.supportStates.first { $0.slotIndex == supportUnyieldingSlot }
        expect(
            supportUnyieldingRevived?.isDefeated == false &&
                supportUnyieldingRevived?.unyieldingWillWasUsed == true &&
                supportUnyieldingRevived?.hp == supportUnyieldingMaxHP * 3 &&
                supportUnyieldingBattle.log.contains {
                    $0.attacker == .support(.knight) &&
                        $0.skillName == "不屈意志" &&
                        $0.kind == .heal &&
                        $0.damage == supportUnyieldingMaxHP * 3
                },
            "support Knight Unyielding Will revives that support member with source 300% HP"
        )
        supportUnyieldingBattle.update(deltaTime: 1)
        let supportUnyieldingDefeated = supportUnyieldingBattle.supportStates.first { $0.slotIndex == supportUnyieldingSlot }
        expect(
            supportUnyieldingDefeated?.isDefeated == true &&
                supportUnyieldingDefeated?.unyieldingWillWasUsed == true &&
                supportUnyieldingBattle.log.filter {
                    $0.attacker == .support(.knight) &&
                        $0.skillName == "不屈意志" &&
                        $0.kind == .heal
                }.count == 1,
            "support Knight Unyielding Will is consumed after one support trigger"
        )

        let sacredBladeKnight = Hero()
        sacredBladeKnight.takeDamage(60)
        let sacredBladeMonster = Monster(
            id: "sacred-blade-training",
            name: "神圣之刃训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let sacredBladeBattle = Battle(hero: sacredBladeKnight, monster: sacredBladeMonster, party: HeroParty(primaryClass: .knight))
        sacredBladeBattle.update(deltaTime: 1)
        sacredBladeBattle.update(deltaTime: 1)
        let hpBeforeSacredBladeAttack = sacredBladeKnight.currentHP
        sacredBladeBattle.update(deltaTime: 1)
        expect(
            sacredBladeBattle.activeBuffNames.contains("神圣之刃") &&
                sacredBladeBattle.activeHeroAttackMultiplier == 1.5,
            "Sacred Blade applies its +50% attack buff"
        )
        expect(
            sacredBladeBattle.log.contains { $0.skillName == "神圣之刃" && $0.kind == .heal && $0.damage > 0 } &&
                sacredBladeKnight.currentHP > hpBeforeSacredBladeAttack,
            "Sacred Blade heals on hero attacks instead of as an instant heal"
        )

        let supportSacredBladeHero = Hero()
        supportSacredBladeHero.changeClass(to: .ranger)
        var supportSacredBladeParty = HeroParty(primaryClass: .ranger, unlockedSlotCount: 2)
        supportSacredBladeParty.setHeroClass(.knight, atSlot: 1)
        var supportSacredBladeLoadouts = ActiveSkillLoadouts()
        supportSacredBladeLoadouts.setSkills(["10501"], for: .knight)
        let supportSacredBladeBattle = Battle(
            hero: supportSacredBladeHero,
            monster: sacredBladeMonster,
            party: supportSacredBladeParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportSacredBladeLoadouts
        )
        let supportSacredBladeSlot = 1
        _ = supportSacredBladeBattle.damageSupportMember(slotIndex: supportSacredBladeSlot, amount: 40)
        let supportHPBeforeSacredBladeAttack = supportSacredBladeBattle.supportStates.first {
            $0.slotIndex == supportSacredBladeSlot
        }?.hp ?? 0
        supportSacredBladeBattle.update(deltaTime: 1)
        let supportHPAfterSacredBladeAttack = supportSacredBladeBattle.supportStates.first {
            $0.slotIndex == supportSacredBladeSlot
        }?.hp ?? 0
        expect(
            supportSacredBladeBattle.activeBuffNames.contains("神圣之刃") &&
                supportSacredBladeBattle.activeSupportAttackMultiplier(slotIndex: supportSacredBladeSlot) == 1.5 &&
                supportSacredBladeBattle.log.contains {
                    $0.attacker == .support(.knight) &&
                        $0.skillName == "神圣之刃" &&
                        $0.kind == .buff
                },
            "support Knight Sacred Blade applies its source-backed attack buff to that support member"
        )
        expect(
            supportHPAfterSacredBladeAttack > supportHPBeforeSacredBladeAttack &&
                supportSacredBladeBattle.log.contains {
                    $0.attacker == .support(.knight) &&
                        $0.skillName == "神圣之刃" &&
                        $0.kind == .heal &&
                        $0.damage > 0
            },
            "support Knight Sacred Blade heals that support member on support attacks"
        )

        var supportQuickLoaderParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportQuickLoaderParty.setHeroClass(.hunter, atSlot: 1)
        var supportQuickLoaderLoadouts = ActiveSkillLoadouts()
        supportQuickLoaderLoadouts.setSkills(["10601"], for: .knight)
        supportQuickLoaderLoadouts.setSkills(["50301"], for: .hunter)
        let supportQuickLoaderMonster = Monster(
            id: "support-quick-loader-training",
            name: "支援快速装填训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let supportQuickLoaderBattle = Battle(
            hero: Hero(),
            monster: supportQuickLoaderMonster,
            party: supportQuickLoaderParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportQuickLoaderLoadouts
        )
        let supportQuickLoaderSlot = 1
        supportQuickLoaderBattle.update(deltaTime: GamePacing.combatSimulationStep)
        let supportQuickLoaderBaseAttacksAfterFirstTick = supportQuickLoaderBattle.log.filter {
            $0.attacker == .support(.hunter) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        expect(
            supportQuickLoaderBattle.activeBuffNames.contains("快速装填") &&
                supportQuickLoaderBattle.activeSupportAttackSpeedMultiplier(slotIndex: supportQuickLoaderSlot) == 1.5 &&
                supportQuickLoaderBattle.log.contains {
            $0.attacker == .support(.hunter) &&
                $0.skillName == "快速装填" &&
                $0.kind == .buff
                } &&
                supportQuickLoaderBaseAttacksAfterFirstTick == 1,
            "support Hunter Quick Loader applies its checked attack-speed buff to that support member"
        )
        for _ in 0..<16 {
            supportQuickLoaderBattle.update(deltaTime: GamePacing.combatSimulationStep)
        }
        let supportQuickLoaderBaseAttacksAfterWindow = supportQuickLoaderBattle.log.filter {
            $0.attacker == .support(.hunter) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count

        var baselineSupportQuickLoaderLoadouts = ActiveSkillLoadouts()
        baselineSupportQuickLoaderLoadouts.setSkills(["10601"], for: .knight)
        baselineSupportQuickLoaderLoadouts.setSkills(["50101"], for: .hunter)
        let baselineSupportQuickLoaderBattle = Battle(
            hero: Hero(),
            monster: supportQuickLoaderMonster,
            party: supportQuickLoaderParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: baselineSupportQuickLoaderLoadouts
        )
        for _ in 0..<17 {
            baselineSupportQuickLoaderBattle.update(deltaTime: GamePacing.combatSimulationStep)
        }
        let baselineSupportQuickLoaderBaseAttacks = baselineSupportQuickLoaderBattle.log.filter {
            $0.attacker == .support(.hunter) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        expect(
            baselineSupportQuickLoaderBaseAttacks > 0 &&
                supportQuickLoaderBaseAttacksAfterWindow >= 3 &&
                supportQuickLoaderBaseAttacksAfterWindow <= 17,
            "support Hunter Quick Loader applies attack-speed charges without exceeding the one-second tick floor"
        )

        expect(
            supportQuickLoaderBaseAttacksAfterWindow >= 3 &&
                supportQuickLoaderBattle.activeSupportAttackSpeedMultiplier(slotIndex: supportQuickLoaderSlot) == 1.0 &&
                !supportQuickLoaderBattle.activeBuffNames.contains("快速装填"),
            "support Hunter Quick Loader consumes its checked three support-attack charges under the one-second tick floor"
        )

        let ranger = Hero()
        ranger.changeClass(to: .ranger)
        let swiftSurgeMonster = Monster(
            id: "swift-surge-training",
            name: "迅捷觉醒训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        var swiftSurgeLoadouts = ActiveSkillLoadouts()
        swiftSurgeLoadouts.setSkills(["20401"], for: .ranger)
        let swiftSurgeBattle = Battle(
            hero: ranger,
            monster: swiftSurgeMonster,
            party: HeroParty(primaryClass: .ranger),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: swiftSurgeLoadouts
        )
        let baselineRanger = Hero()
        baselineRanger.changeClass(to: .ranger)
        var baselineRangerLoadouts = ActiveSkillLoadouts()
        baselineRangerLoadouts.setSkills(["20101"], for: .ranger)
        let baselineSwiftSurgeBattle = Battle(
            hero: baselineRanger,
            monster: swiftSurgeMonster,
            party: HeroParty(primaryClass: .ranger),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: baselineRangerLoadouts
        )
        for _ in 0..<6 {
            swiftSurgeBattle.update(deltaTime: GamePacing.combatSimulationStep)
            baselineSwiftSurgeBattle.update(deltaTime: GamePacing.combatSimulationStep)
        }
        let swiftSurgeHeroBaseAttacks = swiftSurgeBattle.log.filter {
            $0.attacker == .hero &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        let baselineSwiftSurgeHeroBaseAttacks = baselineSwiftSurgeBattle.log.filter {
            $0.attacker == .hero &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        expect(
            swiftSurgeBattle.activeBuffNames.contains("迅捷觉醒") &&
                swiftSurgeBattle.activeHeroAttackSpeedMultiplier == 6.0 &&
                swiftSurgeHeroBaseAttacks == baselineSwiftSurgeHeroBaseAttacks &&
                swiftSurgeHeroBaseAttacks <= 6,
            "Swift Surge applies its checked +500% attack-speed buff without exceeding the one-second tick floor"
        )

        var supportSwiftSurgeParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportSwiftSurgeParty.setHeroClass(.ranger, atSlot: 1)
        var supportSwiftSurgeLoadouts = ActiveSkillLoadouts()
        supportSwiftSurgeLoadouts.setSkills(["10601"], for: .knight)
        supportSwiftSurgeLoadouts.setSkills(["20401"], for: .ranger)
        let supportSwiftSurgeBattle = Battle(
            hero: Hero(),
            monster: swiftSurgeMonster,
            party: supportSwiftSurgeParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportSwiftSurgeLoadouts
        )
        let supportSwiftSurgeSlot = 1
        var baselineSupportSwiftSurgeLoadouts = ActiveSkillLoadouts()
        baselineSupportSwiftSurgeLoadouts.setSkills(["10601"], for: .knight)
        baselineSupportSwiftSurgeLoadouts.setSkills(["20101"], for: .ranger)
        let baselineSupportSwiftSurgeBattle = Battle(
            hero: Hero(),
            monster: swiftSurgeMonster,
            party: supportSwiftSurgeParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: baselineSupportSwiftSurgeLoadouts
        )
        for _ in 0..<6 {
            supportSwiftSurgeBattle.update(deltaTime: GamePacing.combatSimulationStep)
            baselineSupportSwiftSurgeBattle.update(deltaTime: GamePacing.combatSimulationStep)
        }
        let supportSwiftSurgeBaseAttacks = supportSwiftSurgeBattle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        let baselineSupportSwiftSurgeBaseAttacks = baselineSupportSwiftSurgeBattle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        expect(
            supportSwiftSurgeBattle.activeBuffNames.contains("迅捷觉醒") &&
                supportSwiftSurgeBattle.activeSupportAttackSpeedMultiplier(slotIndex: supportSwiftSurgeSlot) == 6.0 &&
                supportSwiftSurgeBattle.log.contains {
                    $0.attacker == .support(.ranger) &&
                        $0.skillName == "迅捷觉醒" &&
                        $0.kind == .buff
                } &&
                supportSwiftSurgeBaseAttacks == baselineSupportSwiftSurgeBaseAttacks &&
                supportSwiftSurgeBaseAttacks <= 6,
            "support Ranger Swift Surge applies its checked attack-speed buff without exceeding the one-second tick floor"
        )

        let rapidFireHero = Hero()
        rapidFireHero.changeClass(to: .ranger)
        let rapidFireMonster = Monster(
            id: "rapid-fire-training",
            name: "快速射击训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let rapidFireBattle = Battle(hero: rapidFireHero, monster: rapidFireMonster, party: HeroParty(primaryClass: .ranger))
        for _ in 0..<3 {
            rapidFireBattle.update(deltaTime: 1)
        }
        expect(
            rapidFireBattle.log.filter { $0.skillName == "快速射击" && $0.kind == .damage }.count >= 2 &&
                rapidFireBattle.monsterHP < rapidFireMonster.hp,
            "Rapid Fire applies checked physical projectile damage as multiple hits"
        )

        let piercingArrowHero = Hero()
        piercingArrowHero.changeClass(to: .ranger)
        let piercingArrowMonsters = (1...3).map { index in
            Monster(
                id: "piercing-arrow-\(index)",
                name: "穿透之箭训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let piercingArrowBattle = Battle(hero: piercingArrowHero, monsters: piercingArrowMonsters, party: HeroParty(primaryClass: .ranger))
        for _ in 0..<8 {
            piercingArrowBattle.update(deltaTime: 1)
            if piercingArrowBattle.log.contains(where: { $0.skillName == "穿透之箭" && $0.kind == .damage }) {
                break
            }
        }
        expect(
            piercingArrowBattle.log.filter { $0.skillName == "穿透之箭" && $0.kind == .damage }.count >= 3 &&
                piercingArrowBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "Piercing Arrow applies checked projectile pierce damage across the live wave"
        )

        let skewerShotHero = Hero()
        skewerShotHero.changeClass(to: .ranger)
        let skewerShotMonster = Monster(
            id: "skewer-shot-training",
            name: "穿刺射击训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let skewerShotBattle = Battle(hero: skewerShotHero, monster: skewerShotMonster, party: HeroParty(primaryClass: .ranger))
        for _ in 0..<30 {
            skewerShotBattle.update(deltaTime: 1)
            if skewerShotBattle.log.filter({ $0.skillName == "穿刺射击" && $0.kind == .damage }).count >= 3 {
                break
            }
        }
        let skewerShotDamageEntries = skewerShotBattle.log.filter {
            $0.skillName == "穿刺射击" && $0.kind == .damage
        }
        let skewerShotNormalizedDamages = skewerShotDamageEntries.map { entry in
            entry.isCrit ? Double(entry.damage) / skewerShotHero.critDamage : Double(entry.damage)
        }
        let skewerShotStatusBadges = skewerShotBattle.enemyStates.first.map {
            EnemyStatusBadge.visible(for: $0)
        } ?? []
        expect(
            skewerShotBattle.enemyStates.first?.lodgedSkewerArrows == 3 &&
                skewerShotBattle.enemyStates.first?.isBleeding == true &&
                skewerShotBattle.log.contains { $0.skillName == "穿刺射击出血" && $0.kind == .buff } &&
                skewerShotStatusBadges == [.bleeding],
            "Skewer Shot marks bleeding after three lodged arrows and exposes a battle status badge"
        )
        expect(
            skewerShotNormalizedDamages.count >= 3 &&
                skewerShotNormalizedDamages[1] > skewerShotNormalizedDamages[0] &&
                skewerShotNormalizedDamages[2] > skewerShotNormalizedDamages[1],
            "Skewer Shot increases base physical damage per lodged arrow"
        )

        let scatterHero = Hero()
        scatterHero.changeClass(to: .ranger)
        let scatterMonsters = (1...3).map { index in
            Monster(
                id: "scatter-\(index)",
                name: "散弹射击训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let scatterBattle = Battle(hero: scatterHero, monsters: scatterMonsters, party: HeroParty(primaryClass: .ranger))
        scatterBattle.update(deltaTime: 1)
        expect(
            scatterBattle.log.filter { $0.skillName == "散弹射击" && $0.kind == .damage }.count >= 3 &&
                scatterBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "Scatter Shot applies checked tracking projectile damage across the live wave"
        )

        func makeProjectileDamageHero(passiveIDs: Set<String> = []) -> Hero {
            let hero = Hero()
            hero.changeClass(to: .ranger)
            hero.unlockedPassiveSkillIDs = passiveIDs
            _ = hero.equipment.equip(Item(
                id: "ranger-projectile-damage-crit-suppression",
                name: "投射物伤害测试护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusCritRate: -1.0),
                description: "测试用"
            ))
            return hero
        }

        func firstScatterShotDamage(for hero: Hero) -> Int {
            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkills(["20201"], for: .ranger)
            let monsters = (1...3).map { index in
                Monster(
                    id: "scatter-projectile-damage-\(index)",
                    name: "散弹射击投射物伤害训练 \(index)",
                    hp: 1_000_000,
                    atk: 1,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                )
            }
            let battle = Battle(
                hero: hero,
                monsters: monsters,
                party: HeroParty(primaryClass: .ranger),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            battle.update(deltaTime: 1)
            return battle.log.first { $0.skillName == "散弹射击" && $0.kind == .damage }?.damage ?? 0
        }

        let baselineScatterDamage = firstScatterShotDamage(for: makeProjectileDamageHero())
        let boostedScatterDamage = firstScatterShotDamage(for: makeProjectileDamageHero(passiveIDs: ["201022"]))
        expect(
            baselineScatterDamage > 0 && boostedScatterDamage > baselineScatterDamage,
            "Increase Projectile Damage passive increases Scatter Shot's checked projectile skill damage"
        )

        let arrowRainHero = Hero()
        arrowRainHero.changeClass(to: .ranger)
        let arrowRainMonsters = (1...3).map { index in
            Monster(
                id: "arrow-rain-\(index)",
                name: "箭雨训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let arrowRainBattle = Battle(hero: arrowRainHero, monsters: arrowRainMonsters, party: HeroParty(primaryClass: .ranger))
        arrowRainBattle.update(deltaTime: 1)
        let hpBeforeArrowRain = arrowRainBattle.enemyStates.map(\.hp)
        arrowRainBattle.update(deltaTime: 1)
        let hpAfterArrowRain = arrowRainBattle.enemyStates.map(\.hp)
        expect(
            arrowRainBattle.log.filter { $0.skillName == "箭雨" && $0.kind == .damage }.count >= 3 &&
                zip(hpBeforeArrowRain, hpAfterArrowRain).allSatisfy { before, after in after < before },
            "Arrow Rain applies checked physical range damage across the live wave"
        )

        let sorcerer = Hero()
        sorcerer.changeClass(to: .sorcerer)
        let fireballMonsters = (1...3).map { index in
            Monster(
                id: "fireball-\(index)",
                name: "火球术训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let fireballBattle = Battle(hero: sorcerer, monsters: fireballMonsters, party: HeroParty(primaryClass: .sorcerer))
        fireballBattle.update(deltaTime: 1)
        expect(
            fireballBattle.log.filter { $0.skillName == "火球术" && $0.kind == .damage }.count >= 3 &&
                fireballBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "Fireball applies checked fire range damage across the live wave"
        )

        let iceOrbHero = Hero()
        iceOrbHero.changeClass(to: .sorcerer)
        let iceOrbMonsters = (1...3).map { index in
            Monster(
                id: "ice-orb-\(index)",
                name: "冰球术训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let iceOrbBattle = Battle(hero: iceOrbHero, monsters: iceOrbMonsters, party: HeroParty(primaryClass: .sorcerer))
        iceOrbBattle.update(deltaTime: 1)
        let hpBeforeIceOrb = iceOrbBattle.enemyStates.map(\.hp)
        let monsterAttacksBeforeIceOrb = iceOrbBattle.log.filter { $0.attacker == .monster }.count
        iceOrbBattle.update(deltaTime: 1)
        let hpAfterIceOrb = iceOrbBattle.enemyStates.map(\.hp)
        expect(
            iceOrbBattle.log.filter { $0.skillName == "冰球术" && $0.kind == .damage }.count >= 6 &&
                zip(hpBeforeIceOrb, hpAfterIceOrb).allSatisfy { before, after in after < before },
            "Ice Orb applies checked cold multi-hit range damage across the live wave"
        )
        expect(
            iceOrbBattle.log.filter { $0.attacker == .monster }.count == monsterAttacksBeforeIceOrb,
            "Ice Orb slows hit enemies enough to delay their next attack tick"
        )
        expect(
            iceOrbBattle.enemyStates.allSatisfy {
                $0.coldStatus == .chilled &&
                    EnemyStatusBadge.visible(for: $0).contains(.chilled)
            },
            "Ice Orb exposes chilled enemy status badges for the current cold-delay scaffold"
        )

        let lightningHero = Hero()
        lightningHero.changeClass(to: .sorcerer)
        let lightningMonsters = (1...3).map { index in
            Monster(
                id: "lightning-\(index)",
                name: "闪电术训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let lightningBattle = Battle(hero: lightningHero, monsters: lightningMonsters, party: HeroParty(primaryClass: .sorcerer))
        lightningBattle.update(deltaTime: 1)
        lightningBattle.update(deltaTime: 1)
        lightningBattle.update(deltaTime: 1)
        expect(
            lightningBattle.log.filter { $0.skillName == "闪电术" && $0.kind == .damage }.count >= 3 &&
                lightningBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "Lightning applies checked AOE damage across the live wave"
        )

        let flameHydraHero = Hero()
        flameHydraHero.changeClass(to: .sorcerer)
        let flameHydraMonsters = (1...3).map { index in
            Monster(
                id: "flame-hydra-\(index)",
                name: "烈焰九头蛇训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let flameHydraBattle = Battle(hero: flameHydraHero, monsters: flameHydraMonsters, party: HeroParty(primaryClass: .sorcerer))
        for _ in 0..<4 {
            flameHydraBattle.update(deltaTime: 1)
        }
        let hpBeforeFlameHydra = flameHydraBattle.enemyStates.map(\.hp)
        flameHydraBattle.update(deltaTime: 1)
        let hpAfterFlameHydra = flameHydraBattle.enemyStates.map(\.hp)
        expect(
            flameHydraBattle.activeBuffNames.contains("烈焰九头蛇") &&
                flameHydraBattle.log.contains { $0.skillName == "烈焰九头蛇" && $0.kind == .damage } &&
                zip(hpBeforeFlameHydra, hpAfterFlameHydra).contains { before, after in after < before },
            "Flame Hydra summons a checked fire projectile damage source"
        )

        var supportHydraParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportHydraParty.setHeroClass(.sorcerer, atSlot: 1)
        var supportHydraLoadouts = ActiveSkillLoadouts()
        supportHydraLoadouts.setSkills(["30401"], for: .sorcerer)
        let supportHydraHero = Hero()
        let supportHydraMonsters = (1...3).map { index in
            Monster(
                id: "support-flame-hydra-\(index)",
                name: "支援烈焰九头蛇训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let supportHydraBattle = Battle(
            hero: supportHydraHero,
            monsters: supportHydraMonsters,
            party: supportHydraParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportHydraLoadouts
        )
        supportHydraBattle.update(deltaTime: 1)
        let hpBeforeSupportHydra = supportHydraBattle.enemyStates.map(\.hp)
        supportHydraBattle.update(deltaTime: 1)
        let hpAfterSupportHydra = supportHydraBattle.enemyStates.map(\.hp)
        expect(
            supportHydraBattle.activeBuffNames.contains("烈焰九头蛇") &&
                PlayerBattleStatusBadge.visible(for: supportHydraBattle).contains(.flameHydra) &&
                PlayerBattleDeployable.visible(for: supportHydraBattle).contains(.flameHydra) &&
                supportHydraBattle.log.contains {
                    $0.attacker == .support(.sorcerer) &&
                        $0.skillName == "烈焰九头蛇" &&
                        $0.kind == .buff
                } &&
                supportHydraBattle.log.contains {
                    $0.attacker == .support(.sorcerer) &&
                        $0.skillName == "烈焰九头蛇" &&
                        $0.kind == .damage
                } &&
                zip(hpBeforeSupportHydra, hpAfterSupportHydra).contains { before, after in after < before },
            "support Flame Hydra keeps its own sustained summon damage and visible deployable state"
        )

        var supportRapidFireParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportRapidFireParty.setHeroClass(.ranger, atSlot: 1)
        var supportRapidFireLoadouts = ActiveSkillLoadouts()
        supportRapidFireLoadouts.setSkills(["20101"], for: .ranger)
        let supportRapidFireMonster = Monster(
            id: "support-rapid-fire-training",
            name: "支援快速射击训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let supportRapidFireBattle = Battle(
            hero: Hero(),
            monster: supportRapidFireMonster,
            party: supportRapidFireParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportRapidFireLoadouts
        )
        let supportRapidFireTriggerEvery = max(
            1,
            HeroSkills.named(for: .ranger).first { $0.id == "20101" }?.triggerEvery ?? 3
        )
        while supportRapidFireBattle.log.filter({
            $0.attacker == .support(.ranger) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }).count < supportRapidFireTriggerEvery - 1 {
            supportRapidFireBattle.update(deltaTime: 1)
        }
        let rapidFireCountBeforeTrigger = supportRapidFireBattle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "快速射击" &&
                $0.kind == .damage
        }.count
        while supportRapidFireBattle.log.filter({
            $0.attacker == .support(.ranger) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }).count < supportRapidFireTriggerEvery {
            supportRapidFireBattle.update(deltaTime: 1)
        }
        let rapidFireCountAfterTrigger = supportRapidFireBattle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "快速射击" &&
                $0.kind == .damage
        }.count
        for _ in 0..<20 {
            supportRapidFireBattle.update(deltaTime: 1)
            if supportRapidFireBattle.log.filter({
                $0.attacker == .support(.ranger) &&
                    $0.skillName == "快速射击" &&
                    $0.kind == .damage
            }).count >= 2 {
                break
            }
        }
        expect(
            rapidFireCountBeforeTrigger == 0 &&
                rapidFireCountAfterTrigger > rapidFireCountBeforeTrigger &&
                supportRapidFireBattle.log.filter {
                $0.attacker == .support(.ranger) &&
                    $0.skillName == "快速射击" &&
                    $0.kind == .damage
            }.count >= 2 &&
                !supportRapidFireBattle.log.contains {
                    $0.attacker == .hero &&
                        $0.skillName == "快速射击"
                },
            "support attack-count skills trigger from support attacks at the checked cadence instead of the main hero skill path"
        )

        var supportScatterParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportScatterParty.setHeroClass(.ranger, atSlot: 1)
        var supportScatterLoadouts = ActiveSkillLoadouts()
        supportScatterLoadouts.setSkills(["20201"], for: .ranger)
        let supportScatterMonsters = (1...3).map { index in
            Monster(
                id: "support-scatter-\(index)",
                name: "支援散弹射击训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let supportScatterBattle = Battle(
            hero: Hero(),
            monsters: supportScatterMonsters,
            party: supportScatterParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportScatterLoadouts
        )
        supportScatterBattle.update(deltaTime: 1)
        let supportScatterLogs = supportScatterBattle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "散弹射击" &&
                $0.kind == .damage
        }
        expect(
            supportScatterLogs.count >= 3 &&
                supportScatterLogs.allSatisfy { $0.damageElement == .physical && $0.delivery == .projectile } &&
                supportScatterBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP } &&
                !supportScatterBattle.log.contains { $0.attacker == .hero && $0.skillName == "散弹射击" },
            "support Ranger Scatter Shot applies support-attributed checked tracking projectile damage across the live wave"
        )

        var supportArrowRainParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportArrowRainParty.setHeroClass(.ranger, atSlot: 1)
        var supportArrowRainLoadouts = ActiveSkillLoadouts()
        supportArrowRainLoadouts.setSkills(["20301"], for: .ranger)
        let supportArrowRainMonsters = (1...3).map { index in
            Monster(
                id: "support-arrow-rain-\(index)",
                name: "支援箭雨训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let supportArrowRainBattle = Battle(
            hero: Hero(),
            monsters: supportArrowRainMonsters,
            party: supportArrowRainParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportArrowRainLoadouts
        )
        supportArrowRainBattle.update(deltaTime: 1)
        let supportArrowRainLogs = supportArrowRainBattle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "箭雨" &&
                $0.kind == .damage
        }
        expect(
            supportArrowRainLogs.count >= 3 &&
                supportArrowRainLogs.allSatisfy { $0.damageElement == .physical && $0.delivery == .rangeAOE } &&
                supportArrowRainBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP } &&
                !supportArrowRainBattle.log.contains { $0.attacker == .hero && $0.skillName == "箭雨" },
            "support Ranger Arrow Rain applies support-attributed checked physical range damage across the live wave"
        )

        var supportPiercingParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportPiercingParty.setHeroClass(.ranger, atSlot: 1)
        var supportPiercingLoadouts = ActiveSkillLoadouts()
        supportPiercingLoadouts.setSkills(["20501"], for: .ranger)
        let supportPiercingMonsters = (1...3).map { index in
            Monster(
                id: "support-piercing-arrow-\(index)",
                name: "支援穿透之箭训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let supportPiercingBattle = Battle(
            hero: Hero(),
            monsters: supportPiercingMonsters,
            party: supportPiercingParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportPiercingLoadouts
        )
        for _ in 0..<30 {
            supportPiercingBattle.update(deltaTime: 1)
            if supportPiercingBattle.log.contains(where: {
                $0.attacker == .support(.ranger) &&
                    $0.skillName == "穿透之箭" &&
                    $0.kind == .damage
            }) {
                break
            }
        }
        let supportPiercingLogs = supportPiercingBattle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "穿透之箭" &&
                $0.kind == .damage
        }
        expect(
            supportPiercingLogs.count >= 3 &&
                supportPiercingLogs.allSatisfy { $0.damageElement == .physical && $0.delivery == .projectile } &&
                supportPiercingLogs.allSatisfy { BattleTrajectoryCue.visible(for: $0) == .piercingArrow } &&
                supportPiercingBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP } &&
                !supportPiercingBattle.log.contains { $0.attacker == .hero && $0.skillName == "穿透之箭" },
            "support Ranger Piercing Arrow keeps source physical projectile metadata and piercing trajectory"
        )

        var supportShieldChargeParty = HeroParty(primaryClass: .ranger, unlockedSlotCount: 2)
        supportShieldChargeParty.setHeroClass(.knight, atSlot: 1)
        var supportShieldChargeLoadouts = ActiveSkillLoadouts()
        supportShieldChargeLoadouts.setSkills(["10201"], for: .knight)
        let supportShieldChargeMonsters = (1...3).map { index in
            Monster(
                id: "support-shield-charge-\(index)",
                name: "支援盾牌冲锋训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let supportShieldChargeHero = Hero()
        supportShieldChargeHero.heroClass = .ranger
        supportShieldChargeHero.currentHP = supportShieldChargeHero.maxHP
        let supportShieldChargeBattle = Battle(
            hero: supportShieldChargeHero,
            monsters: supportShieldChargeMonsters,
            party: supportShieldChargeParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportShieldChargeLoadouts
        )
        supportShieldChargeBattle.update(deltaTime: 1)
        let supportShieldChargeLogs = supportShieldChargeBattle.log.filter {
            $0.attacker == .support(.knight) &&
                $0.skillName == "盾牌冲锋" &&
                $0.kind == .damage
        }
        expect(
            supportShieldChargeLogs.count == 1 &&
                supportShieldChargeLogs.allSatisfy { $0.damageElement == .physical && $0.delivery == .melee } &&
                supportShieldChargeLogs.allSatisfy { BattleTrajectoryCue.visible(for: $0) == .chargeDash } &&
                (supportShieldChargeBattle.enemyStates.first?.hp ?? 0) < (supportShieldChargeBattle.enemyStates.first?.maxHP ?? 0) &&
                supportShieldChargeBattle.enemyStates.dropFirst().allSatisfy { $0.hp == $0.maxHP } &&
                !supportShieldChargeBattle.log.contains { $0.attacker == .hero && $0.skillName == "盾牌冲锋" },
            "support Knight Shield Charge keeps source Melee delivery focused on the collision target"
        )

        var supportSkewerParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportSkewerParty.setHeroClass(.ranger, atSlot: 1)
        var supportSkewerLoadouts = ActiveSkillLoadouts()
        supportSkewerLoadouts.setSkills(["20601"], for: .ranger)
        let supportSkewerMonster = Monster(
            id: "support-skewer-shot-training",
            name: "支援穿刺射击训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let supportSkewerBattle = Battle(
            hero: Hero(),
            monster: supportSkewerMonster,
            party: supportSkewerParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportSkewerLoadouts
        )
        for _ in 0..<40 {
            supportSkewerBattle.update(deltaTime: 1)
            if supportSkewerBattle.log.filter({
                $0.attacker == .support(.ranger) &&
                    $0.skillName == "穿刺射击" &&
                    $0.kind == .damage
            }).count >= 3 {
                break
            }
        }
        let supportSkewerLogs = supportSkewerBattle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "穿刺射击" &&
                $0.kind == .damage
        }
        expect(
            supportSkewerLogs.count >= 3 &&
                supportSkewerLogs.allSatisfy { $0.damageElement == .physical && $0.delivery == .projectile } &&
                supportSkewerLogs.allSatisfy { BattleTrajectoryCue.visible(for: $0) == .lodgedArrow } &&
                supportSkewerBattle.enemyStates.first?.lodgedSkewerArrows == 3 &&
                supportSkewerBattle.enemyStates.first?.isBleeding == true &&
                supportSkewerBattle.log.contains {
                    $0.attacker == .support(.ranger) &&
                        $0.skillName == "穿刺射击出血" &&
                        $0.kind == .buff
                } &&
                !supportSkewerBattle.log.contains { $0.attacker == .hero && $0.skillName == "穿刺射击" },
            "support Ranger Skewer Shot keeps source projectile metadata, lodged-arrow trajectory and bleeding marker"
        )

        var supportMeteorParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportMeteorParty.setHeroClass(.sorcerer, atSlot: 1)
        var supportMeteorLoadouts = ActiveSkillLoadouts()
        supportMeteorLoadouts.setSkills(["30601"], for: .sorcerer)
        let supportMeteorMonsters = (1...3).map { index in
            Monster(
                id: "support-meteor-\(index)",
                name: "支援陨石打击训练 \(index)",
                hp: 10_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let supportMeteorBattle = Battle(
            hero: Hero(),
            monsters: supportMeteorMonsters,
            party: supportMeteorParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportMeteorLoadouts
        )
        supportMeteorBattle.update(deltaTime: 1)
        let supportMeteorLogs = supportMeteorBattle.log.filter {
            $0.attacker == .support(.sorcerer) &&
                $0.skillName == "陨石打击" &&
                $0.kind == .damage
        }
        expect(
            supportMeteorLogs.count >= 3 &&
                supportMeteorLogs.allSatisfy { $0.damageElement == .fire && $0.delivery == .rangeAOE } &&
                supportMeteorBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP } &&
                !supportMeteorBattle.log.contains { $0.attacker == .hero && $0.skillName == "陨石打击" },
            "support Sorcerer Meteor Strike applies support-attributed checked fire range damage across the live wave"
        )

        let snowstormHero = Hero()
        snowstormHero.changeClass(to: .sorcerer)
        let snowstormMonsters = (1...3).map { index in
            Monster(
                id: "snowstorm-\(index)",
                name: "暴风雪训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let snowstormBattle = Battle(hero: snowstormHero, monsters: snowstormMonsters, party: HeroParty(primaryClass: .sorcerer))
        for _ in 0..<5 {
            snowstormBattle.update(deltaTime: 1)
        }
        let hpBeforeSnowstorm = snowstormBattle.enemyStates.map(\.hp)
        let monsterAttacksBeforeSnowstorm = snowstormBattle.log.filter { $0.attacker == .monster }.count
        snowstormBattle.update(deltaTime: 1)
        let hpAfterSnowstorm = snowstormBattle.enemyStates.map(\.hp)
        expect(
            snowstormBattle.activeBuffNames.contains("暴风雪") &&
                snowstormBattle.log.filter { $0.skillName == "暴风雪" && $0.kind == .damage }.count >= 3 &&
                zip(hpBeforeSnowstorm, hpAfterSnowstorm).allSatisfy { before, after in after < before },
            "Snowstorm applies checked cold range damage per second across the live wave"
        )
        expect(
            snowstormBattle.log.filter { $0.attacker == .monster }.count == monsterAttacksBeforeSnowstorm,
            "Snowstorm cools hit enemies enough to delay their next attack tick"
        )
        expect(
            snowstormBattle.enemyStates.allSatisfy {
                $0.coldStatus == .chilled &&
                    EnemyStatusBadge.visible(for: $0).contains(.chilled)
            },
            "Snowstorm exposes chilled enemy status badges for the current cooling-delay scaffold"
        )

        let meteorHero = Hero()
        meteorHero.changeClass(to: .sorcerer)
        let meteorMonsters = (1...3).map { index in
            Monster(
                id: "meteor-\(index)",
                name: "陨石打击训练 \(index)",
                hp: 10_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let meteorBattle = Battle(hero: meteorHero, monsters: meteorMonsters, party: HeroParty(primaryClass: .sorcerer))
        for _ in 0..<5 {
            meteorBattle.update(deltaTime: 1)
        }
        let hpBeforeMeteor = meteorBattle.enemyStates.map(\.hp)
        meteorBattle.update(deltaTime: 1)
        let hpAfterMeteor = meteorBattle.enemyStates.map(\.hp)
        expect(
            meteorBattle.log.filter { $0.skillName == "陨石打击" && $0.kind == .damage }.count >= 3 &&
                zip(hpBeforeMeteor, hpAfterMeteor).allSatisfy { before, after in after < before },
            "Meteor Strike applies checked fire range damage across the live wave"
        )

        let sanctuaryPriest = Hero()
        sanctuaryPriest.changeClass(to: .priest)
        let sanctuaryMonster = Monster(
            id: "sanctuary-training",
            name: "圣域训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let sanctuaryBattle = Battle(
            hero: sanctuaryPriest,
            monster: sanctuaryMonster,
            party: HeroParty(primaryClass: .priest, unlockedSlotCount: 3)
        )
        for _ in 0..<8 {
            sanctuaryBattle.update(deltaTime: 1)
            if sanctuaryBattle.activeBuffNames.contains("圣域") { break }
        }
        sanctuaryPriest.takeDamage(80)
        sanctuaryBattle.heroHP = sanctuaryPriest.currentHP
        let sanctuarySupportSlot = 1
        let sanctuarySupportMaxHP = sanctuaryBattle.supportStates.first { $0.slotIndex == sanctuarySupportSlot }?.maxHP ?? 0
        _ = sanctuaryBattle.damageSupportMember(slotIndex: sanctuarySupportSlot, amount: max(1, sanctuarySupportMaxHP / 2))
        let hpBeforeSanctuaryTick = sanctuaryPriest.currentHP
        let supportHPBeforeSanctuaryTick = sanctuaryBattle.supportStates.first { $0.slotIndex == sanctuarySupportSlot }?.hp ?? 0
        sanctuaryBattle.update(deltaTime: 1)
        expect(sanctuaryBattle.activeBuffNames.contains("圣域"), "Sanctuary applies an active over-time healing buff")
        let supportHPAfterSanctuaryTick = sanctuaryBattle.supportStates.first { $0.slotIndex == sanctuarySupportSlot }?.hp ?? 0
        expect(
            sanctuaryBattle.log.contains { $0.skillName == "圣域" && $0.kind == .heal && $0.damage > 0 } &&
                sanctuaryPriest.currentHP > hpBeforeSanctuaryTick &&
                supportHPAfterSanctuaryTick > supportHPBeforeSanctuaryTick &&
                sanctuaryBattle.heroHP == sanctuaryPriest.currentHP,
            "Sanctuary heals the living party after activation on battle ticks"
        )

        let supportSanctuaryHero = Hero()
        var supportSanctuaryParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportSanctuaryParty.setHeroClass(.priest, atSlot: 1)
        var supportSanctuaryLoadouts = ActiveSkillLoadouts()
        supportSanctuaryLoadouts.setSkills(["40401"], for: .priest)
        let supportSanctuaryMonster = Monster(
            id: "support-sanctuary-training",
            name: "支援圣域训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let supportSanctuaryBattle = Battle(
            hero: supportSanctuaryHero,
            monster: supportSanctuaryMonster,
            party: supportSanctuaryParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportSanctuaryLoadouts
        )
        for _ in 0..<3 {
            supportSanctuaryBattle.update(deltaTime: 1)
            if supportSanctuaryBattle.activeBuffNames.contains("圣域") { break }
        }
        supportSanctuaryHero.takeDamage(80)
        supportSanctuaryBattle.heroHP = supportSanctuaryHero.currentHP
        let supportSanctuarySlot = 1
        let supportSanctuaryMaxHP = supportSanctuaryBattle.supportStates.first { $0.slotIndex == supportSanctuarySlot }?.maxHP ?? 0
        _ = supportSanctuaryBattle.damageSupportMember(slotIndex: supportSanctuarySlot, amount: max(1, supportSanctuaryMaxHP / 2))
        let hpBeforeSupportSanctuaryTick = supportSanctuaryHero.currentHP
        let supportHPBeforeSupportSanctuaryTick = supportSanctuaryBattle.supportStates.first { $0.slotIndex == supportSanctuarySlot }?.hp ?? 0
        supportSanctuaryBattle.update(deltaTime: 1)
        let supportHPAfterSupportSanctuaryTick = supportSanctuaryBattle.supportStates.first { $0.slotIndex == supportSanctuarySlot }?.hp ?? 0
        expect(
            supportSanctuaryBattle.activeBuffNames.contains("圣域") &&
                supportSanctuaryBattle.log.contains {
                    $0.attacker == .support(.priest) &&
                        $0.skillName == "圣域" &&
                        $0.kind == .buff
                },
            "support Priest Sanctuary applies an active over-time healing field"
        )
        expect(
            supportSanctuaryBattle.log.contains {
                $0.attacker == .support(.priest) &&
                    $0.skillName == "圣域" &&
                    $0.kind == .heal &&
                    $0.damage > 0
            } &&
                supportSanctuaryHero.currentHP > hpBeforeSupportSanctuaryTick &&
                supportHPAfterSupportSanctuaryTick > supportHPBeforeSupportSanctuaryTick &&
                supportSanctuaryBattle.heroHP == supportSanctuaryHero.currentHP,
            "support Priest Sanctuary heals the living party after activation on battle ticks"
        )

        func makeSkillHealHero(passiveIDs: Set<String> = []) -> Hero {
            let hero = Hero()
            hero.changeClass(to: .priest)
            hero.unlockedPassiveSkillIDs = passiveIDs
            _ = hero.equipment.equip(Item(
                id: "priest-skill-heal-test-armor",
                name: "治疗增强测试护甲",
                rarity: .common,
                slot: .armor,
                stats: ItemStats(bonusHP: 1_000),
                description: "测试用"
            ))
            _ = hero.heal(hero.maxHP)
            return hero
        }

        func firstSanctuaryHeal(for hero: Hero) -> Int {
            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkills(["40401"], for: .priest)
            let monster = Monster(
                id: "skill-heal-sanctuary-training",
                name: "治疗增强圣域训练木桩",
                hp: 10_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
            let battle = Battle(
                hero: hero,
                monster: monster,
                party: HeroParty(primaryClass: .priest),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            for _ in 0..<8 {
                battle.update(deltaTime: 1)
                if battle.activeBuffNames.contains("圣域") { break }
            }
            hero.takeDamage(800)
            battle.heroHP = hero.currentHP
            let logStart = battle.log.count
            battle.update(deltaTime: 1)
            return battle.log.dropFirst(logStart).first {
                $0.attacker == .hero &&
                    $0.skillName == "圣域" &&
                    $0.kind == .heal &&
                    $0.damage > 0
            }?.damage ?? 0
        }

        let baselineSanctuaryHeal = firstSanctuaryHeal(for: makeSkillHealHero())
        let boostedSanctuaryHeal = firstSanctuaryHeal(for: makeSkillHealHero(passiveIDs: ["401022"]))
        expect(
            baselineSanctuaryHeal > 0 && boostedSanctuaryHeal > baselineSanctuaryHeal,
            "Skill Heal Increase passive increases Sanctuary's checked healing-over-time logs"
        )

        let priest = Hero()
        priest.changeClass(to: .priest)
        priest.takeDamage(40)
        let woundedHP = priest.currentHP
        let healBattle = Battle(hero: priest, monster: trainingMonster, party: HeroParty(primaryClass: .priest))
        healBattle.update(deltaTime: 1)
        expect(healBattle.log.contains { $0.skillName == "治愈" && $0.kind == .heal }, "utility skill records healing")
        expect(priest.currentHP > woundedHP && healBattle.heroHP == priest.currentHP, "healing skill restores hero HP")

        let supportHealPriest = Hero()
        supportHealPriest.changeClass(to: .priest)
        let supportHealBattle = Battle(
            hero: supportHealPriest,
            monster: trainingMonster,
            party: HeroParty(primaryClass: .priest, unlockedSlotCount: 3)
        )
        let woundedSupportSlot = 1
        let supportMaxHP = supportHealBattle.supportStates.first { $0.slotIndex == woundedSupportSlot }?.maxHP ?? 0
        _ = supportHealBattle.damageSupportMember(slotIndex: woundedSupportSlot, amount: max(1, supportMaxHP / 2))
        let woundedSupportHP = supportHealBattle.supportStates.first { $0.slotIndex == woundedSupportSlot }?.hp ?? 0
        supportHealBattle.update(deltaTime: 1)
        let healedSupportHP = supportHealBattle.supportStates.first { $0.slotIndex == woundedSupportSlot }?.hp ?? 0
        expect(
            supportHealBattle.log.contains { $0.skillName == "治愈" && $0.kind == .heal } &&
                healedSupportHP > woundedSupportHP,
            "Heal restores a wounded living support ally"
        )

        let resurrectionPriest = Hero()
        resurrectionPriest.changeClass(to: .priest)
        let resurrectionMonster = Monster(
            id: "resurrection-training",
            name: "复活训练木桩",
            hp: 100_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let resurrectionBattle = Battle(
            hero: resurrectionPriest,
            monster: resurrectionMonster,
            party: HeroParty(primaryClass: .priest, unlockedSlotCount: 3)
        )
        let defeatedSupportSlot = 2
        let defeatedSupportMaxHP = resurrectionBattle.supportStates.first { $0.slotIndex == defeatedSupportSlot }?.maxHP ?? 0
        let supportDefeated = resurrectionBattle.damageSupportMember(slotIndex: defeatedSupportSlot, amount: defeatedSupportMaxHP + 1)
        expect(supportDefeated, "support party member can fall in battle state")
        for _ in 0..<6 {
            resurrectionBattle.update(deltaTime: 1)
            if resurrectionBattle.log.contains(where: { $0.skillName == "复活" && $0.kind == .heal }) {
                break
            }
        }
        let revivedSupport = resurrectionBattle.supportStates.first { $0.slotIndex == defeatedSupportSlot }
        expect(
            revivedSupport?.isDefeated == false &&
                revivedSupport?.hp == defeatedSupportMaxHP * 3 &&
                resurrectionBattle.log.contains { $0.skillName == "复活" && $0.kind == .heal && $0.damage == defeatedSupportMaxHP * 3 },
            "Resurrection revives a fallen support member with source 300% max HP"
        )

        var supportResurrectionParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 3)
        supportResurrectionParty.setHeroClass(.priest, atSlot: 1)
        supportResurrectionParty.setHeroClass(.ranger, atSlot: 2)
        var supportResurrectionLoadouts = ActiveSkillLoadouts()
        supportResurrectionLoadouts.setSkills(["40601"], for: .priest)
        let supportResurrectionBattle = Battle(
            hero: Hero(),
            monster: resurrectionMonster,
            party: supportResurrectionParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportResurrectionLoadouts
        )
        let supportResurrectionTargetSlot = 2
        let supportResurrectionTargetMaxHP = supportResurrectionBattle.supportStates.first {
            $0.slotIndex == supportResurrectionTargetSlot
        }?.maxHP ?? 0
        let supportResurrectionTargetDefeated = supportResurrectionBattle.damageSupportMember(
            slotIndex: supportResurrectionTargetSlot,
            amount: supportResurrectionTargetMaxHP + 1
        )
        expect(supportResurrectionTargetDefeated, "support Resurrection test target can fall before support Priest casts")
        supportResurrectionBattle.update(deltaTime: 1)
        let supportRevivedTarget = supportResurrectionBattle.supportStates.first {
            $0.slotIndex == supportResurrectionTargetSlot
        }
        expect(
            supportRevivedTarget?.isDefeated == false &&
                supportRevivedTarget?.hp == supportResurrectionTargetMaxHP * 3 &&
                supportResurrectionBattle.log.contains {
                    $0.attacker == .support(.priest) &&
                        $0.skillName == "复活" &&
                        $0.kind == .heal &&
                        $0.damage == supportResurrectionTargetMaxHP * 3
                } &&
                !supportResurrectionBattle.log.contains { $0.attacker == .hero && $0.skillName == "复活" },
            "support Priest Resurrection revives another fallen support member with source 300% max HP"
        )

        let blessingPriest = Hero()
        blessingPriest.changeClass(to: .priest)
        let blessingMonster = Monster(
            id: "blessing-training",
            name: "祝福训练木桩",
            hp: 10_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let blessingBattle = Battle(hero: blessingPriest, monster: blessingMonster, party: HeroParty(primaryClass: .priest))
        expect(
            blessingBattle.continuousSkillNames == ["力量祝福", "守护祝福"] &&
                blessingBattle.continuousAttackMultiplier == 6.0 &&
                blessingBattle.continuousIncomingDamageMultiplier == 0.9,
            "continuous priest blessings provide source-value battle modifiers"
        )
        expect(
            Battle.modifiedIncomingDamage(
                100,
                continuousIncomingDamageMultiplier: blessingBattle.continuousIncomingDamageMultiplier,
                passiveDamageReduction: 0,
                passiveDamageAbsorption: 0,
                damageElement: .fire
            ) == 90 &&
                Battle.modifiedIncomingDamage(
                    100,
                    continuousIncomingDamageMultiplier: blessingBattle.continuousIncomingDamageMultiplier,
                    passiveDamageReduction: 0,
                    passiveDamageAbsorption: 0,
                    damageElement: .physical
                ) == 100,
            "Warding Blessing reduces source elemental incoming damage without reducing physical attacks"
        )

        let supportBlessingHero = Hero()
        let supportBlessingParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        let supportBlessingMonster = Monster(
            id: "support-blessing-training",
            name: "支援祝福训练木桩",
            hp: 10_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let oneSlotSupportBlessingBattle = Battle(
            hero: supportBlessingHero,
            monster: supportBlessingMonster,
            party: supportBlessingParty,
            activeSkillSlotCount: HeroSkills.defaultActiveSkillSlotCount
        )
        expect(
            oneSlotSupportBlessingBattle.continuousSkillNames.isEmpty &&
                oneSlotSupportBlessingBattle.continuousAttackMultiplier == 1.0 &&
                oneSlotSupportBlessingBattle.continuousIncomingDamageMultiplier == 1.0,
            "support priest continuous blessings are not enabled before enough active skill slots are equipped"
        )
        let fullSlotSupportBlessingBattle = Battle(
            hero: supportBlessingHero,
            monster: supportBlessingMonster,
            party: supportBlessingParty,
            activeSkillSlotCount: HeroSkills.maximumModeledActiveSkillSlots
        )
        expect(
            fullSlotSupportBlessingBattle.party.supportMembers.map(\.heroClass) == [.priest] &&
                fullSlotSupportBlessingBattle.continuousSkillNames == ["力量祝福", "守护祝福"] &&
                fullSlotSupportBlessingBattle.continuousAttackMultiplier == 6.0 &&
                fullSlotSupportBlessingBattle.continuousIncomingDamageMultiplier == 0.9,
            "equipped support priest continuous blessings provide source-value party modifiers"
        )

        let wrathBuffPriest = Hero()
        wrathBuffPriest.changeClass(to: .priest)
        let wrathBuffMonster = Monster(
            id: "wrath-buff-training",
            name: "天堂之怒训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let wrathBuffBattle = Battle(hero: wrathBuffPriest, monster: wrathBuffMonster, party: HeroParty(primaryClass: .priest))
        wrathBuffBattle.update(deltaTime: 1)
        wrathBuffBattle.update(deltaTime: 1)
        let wrathDamageBeforeAttack = wrathBuffBattle.log.filter { $0.skillName == "天堂之怒" && $0.kind == .damage }.count
        expect(wrathBuffBattle.activeBuffNames.contains("天堂之怒"), "Wrath of Heaven applies an active attack-damage buff")
        for _ in 0..<4 {
            if wrathBuffBattle.log.filter({ $0.skillName == "天堂之怒" && $0.kind == .damage }).count > wrathDamageBeforeAttack {
                break
            }
            wrathBuffBattle.update(deltaTime: 1)
        }
        expect(
            wrathBuffBattle.log.filter { $0.skillName == "天堂之怒" && $0.kind == .damage }.count > wrathDamageBeforeAttack,
            "Wrath of Heaven adds lightning damage to later hero attacks"
        )

        let wrathWaveHero = Hero()
        wrathWaveHero.changeClass(to: .priest)
        let wrathWaveMonsters = (1...3).map { index in
            Monster(
                id: "wrath-wave-\(index)",
                name: "天堂之怒范围训练 \(index)",
                hp: 10_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let wrathWaveBattle = Battle(hero: wrathWaveHero, monsters: wrathWaveMonsters, party: HeroParty(primaryClass: .priest))
        wrathWaveBattle.update(deltaTime: 1)
        wrathWaveBattle.update(deltaTime: 1)
        wrathWaveBattle.update(deltaTime: 1)
        expect(
            wrathWaveBattle.log.filter { $0.skillName == "天堂之怒" && $0.kind == .damage }.count >= 3 &&
                wrathWaveBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "Wrath of Heaven applies range damage across the live wave"
        )

        var supportWrathParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportWrathParty.setHeroClass(.priest, atSlot: 1)
        var supportWrathLoadouts = ActiveSkillLoadouts()
        supportWrathLoadouts.setSkills(["40301"], for: .priest)
        let supportWrathMonsters = (1...3).map { index in
            Monster(
                id: "support-wrath-wave-\(index)",
                name: "支援天堂之怒范围训练 \(index)",
                hp: 10_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let supportWrathBattle = Battle(
            hero: Hero(),
            monsters: supportWrathMonsters,
            party: supportWrathParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportWrathLoadouts
        )
        supportWrathBattle.update(deltaTime: 1)
        let supportWrathBuffIndex = supportWrathBattle.log.firstIndex {
            $0.attacker == .support(.priest) && $0.skillName == "天堂之怒" && $0.kind == .buff
        }
        let supportWrathBaseAttackIndex = supportWrathBattle.log.firstIndex {
            $0.attacker == .support(.priest) && $0.skillName == nil && $0.kind == .damage
        }
        let supportWrathDamageIndex = supportWrathBattle.log.firstIndex {
            $0.attacker == .support(.priest) && $0.skillName == "天堂之怒" && $0.kind == .damage
        }
        let supportWrathDamageLogs = supportWrathBattle.log.filter {
            $0.attacker == .support(.priest) && $0.skillName == "天堂之怒" && $0.kind == .damage
        }
        expect(
            supportWrathBattle.activeBuffNames.contains("天堂之怒") &&
                supportWrathBuffIndex != nil &&
                supportWrathBaseAttackIndex != nil &&
                supportWrathDamageIndex != nil &&
                supportWrathBuffIndex! < supportWrathBaseAttackIndex! &&
                supportWrathBaseAttackIndex! < supportWrathDamageIndex! &&
                supportWrathDamageLogs.count >= 3 &&
                supportWrathDamageLogs.allSatisfy { $0.damageElement == .lightning && $0.delivery == .rangeAOE } &&
                supportWrathBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "support Priest Wrath of Heaven adds checked lightning range damage to later support attacks"
        )

        let slayer = Hero()
        slayer.changeClass(to: .slayer)
        _ = slayer.equipment.equip(Item(
            id: "slayer-attack-count-speed-boots",
            name: "杀手攻击次数测试靴",
            rarity: .common,
            slot: .boots,
            stats: ItemStats(bonusSPD: 100),
            description: "测试用"
        ))
        let slayerTrainingMonster = Monster(
            id: "slayer-training-skill",
            name: "杀手技能训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let slayerBattle = Battle(hero: slayer, monster: slayerTrainingMonster, party: HeroParty(primaryClass: .slayer))
        for _ in 0..<20 {
            slayerBattle.update(deltaTime: 1)
            if slayerBattle.log.contains(where: { $0.skillName == "粉碎强击" && $0.kind == .damage }) {
                break
            }
        }
        expect(slayerBattle.log.contains { $0.skillName == "粉碎强击" && $0.kind == .damage }, "Slayer attack-count skill executes after base attacks")

        let slamJumpHero = Hero()
        slamJumpHero.changeClass(to: .slayer)
        let slamJumpMonsters = (1...3).map { index in
            Monster(
                id: "slam-jump-\(index)",
                name: "猛击跳跃训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let slamJumpBattle = Battle(hero: slamJumpHero, monsters: slamJumpMonsters, party: HeroParty(primaryClass: .slayer))
        for _ in 0..<8 {
            slamJumpBattle.update(deltaTime: 1)
            if slamJumpBattle.log.contains(where: { $0.skillName == "猛击跳跃" && $0.kind == .damage }) {
                break
            }
        }
        expect(
            slamJumpBattle.log.filter { $0.skillName == "猛击跳跃" && $0.kind == .damage }.count >= 3 &&
                slamJumpBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "Slam Jump applies checked melee range damage across the live wave"
        )

        func makeAreaDamageHero(passiveIDs: Set<String> = []) -> Hero {
            let hero = Hero()
            hero.changeClass(to: .slayer)
            hero.unlockedPassiveSkillIDs = passiveIDs
            _ = hero.equipment.equip(Item(
                id: "slayer-area-damage-crit-suppression",
                name: "范围伤害测试护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusCritRate: -1.0),
                description: "测试用"
            ))
            return hero
        }

        func firstSlamJumpDamage(for hero: Hero) -> Int {
            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkills(["60101"], for: .slayer)
            let monsters = (1...3).map { index in
                Monster(
                    id: "slam-jump-area-damage-\(index)",
                    name: "猛击跳跃范围伤害训练 \(index)",
                    hp: 1_000_000,
                    atk: 1,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                )
            }
            let battle = Battle(
                hero: hero,
                monsters: monsters,
                party: HeroParty(primaryClass: .slayer),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            for _ in 0..<8 {
                battle.update(deltaTime: 1)
                if battle.log.contains(where: { $0.skillName == "猛击跳跃" && $0.kind == .damage }) {
                    break
                }
            }
            return battle.log.first { $0.skillName == "猛击跳跃" && $0.kind == .damage }?.damage ?? 0
        }

        let baselineSlamJumpDamage = firstSlamJumpDamage(for: makeAreaDamageHero())
        let boostedSlamJumpDamage = firstSlamJumpDamage(for: makeAreaDamageHero(passiveIDs: ["601051"]))
        expect(
            baselineSlamJumpDamage > 0 && boostedSlamJumpDamage > baselineSlamJumpDamage,
            "Increase Area of Effect Damage passive increases Slam Jump's checked AOE skill damage"
        )

        let generalsRoarHero = Hero()
        generalsRoarHero.changeClass(to: .slayer)
        let generalsRoarMonster = Monster(
            id: "generals-roar-training",
            name: "将军怒吼训练木桩",
            hp: 100_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let generalsRoarBattle = Battle(hero: generalsRoarHero, monster: generalsRoarMonster, party: HeroParty(primaryClass: .slayer))
        generalsRoarBattle.update(deltaTime: 1)
        let monsterAttackCountBeforeRoar = generalsRoarBattle.log.filter { $0.attacker == .monster }.count
        generalsRoarBattle.update(deltaTime: 1)
        expect(
            generalsRoarBattle.activeBuffNames.contains("将军怒吼") &&
                generalsRoarBattle.activeHeroCritRateMultiplier == 6.0,
            "General's Cry applies its checked +500% crit coefficient buff"
        )
        expect(
            generalsRoarBattle.log.contains { $0.skillName == "将军怒吼" && $0.kind == .buff } &&
                generalsRoarBattle.log.filter { $0.attacker == .monster }.count == monsterAttackCountBeforeRoar,
            "General's Cry stuns live enemies for the activation tick"
        )
        expect(
            generalsRoarBattle.enemyStates.allSatisfy {
                $0.isStunned &&
                    EnemyStatusBadge.visible(for: $0).contains(.stunned)
            },
            "General's Cry exposes stunned enemy status badges for the current stun-delay scaffold"
        )

        let supportGeneralsRoarHero = Hero()
        supportGeneralsRoarHero.changeClass(to: .ranger)
        var supportGeneralsRoarParty = HeroParty(primaryClass: .ranger, unlockedSlotCount: 2)
        supportGeneralsRoarParty.setHeroClass(.slayer, atSlot: 1)
        var supportGeneralsRoarLoadouts = ActiveSkillLoadouts()
        supportGeneralsRoarLoadouts.setSkills(["60301"], for: .slayer)
        let supportGeneralsRoarBattle = Battle(
            hero: supportGeneralsRoarHero,
            monster: generalsRoarMonster,
            party: supportGeneralsRoarParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportGeneralsRoarLoadouts
        )
        supportGeneralsRoarBattle.update(deltaTime: 1)
        expect(
            supportGeneralsRoarBattle.activeBuffNames.contains("将军怒吼") &&
                supportGeneralsRoarBattle.activeHeroCritRateMultiplier == 6.0 &&
                supportGeneralsRoarBattle.log.contains {
                    $0.attacker == .support(.slayer) &&
                        $0.skillName == "将军怒吼" &&
                        $0.kind == .buff
                },
            "support Slayer General's Cry applies its source-value party crit coefficient buff"
        )
        expect(
            supportGeneralsRoarBattle.enemyStates.allSatisfy {
                $0.isStunned &&
                    EnemyStatusBadge.visible(for: $0).contains(.stunned)
            },
            "support Slayer General's Cry stuns live enemies through the current scaffold"
        )

        let groundSlamHero = Hero()
        groundSlamHero.changeClass(to: .slayer)
        _ = groundSlamHero.equipment.equip(Item(
            id: "ground-slam-speed-boots",
            name: "大地强击测试靴",
            rarity: .common,
            slot: .boots,
            stats: ItemStats(bonusSPD: 100),
            description: "测试用"
        ))
        let groundSlamMonsters = (1...3).map { index in
            Monster(
                id: "ground-slam-\(index)",
                name: "大地强击训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let groundSlamBattle = Battle(hero: groundSlamHero, monsters: groundSlamMonsters, party: HeroParty(primaryClass: .slayer))
        for _ in 0..<20 {
            groundSlamBattle.update(deltaTime: 1)
            if groundSlamBattle.log.contains(where: { $0.skillName == "大地强击" && $0.kind == .damage }) {
                break
            }
        }
        expect(
            groundSlamBattle.log.filter { $0.skillName == "大地强击" && $0.kind == .damage }.count >= 3 &&
                groundSlamBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "Ground Slam applies checked range damage across the live wave"
        )

        var rockExplosionLoadouts = ActiveSkillLoadouts()
        rockExplosionLoadouts.setSkills(["60401", "60501"], for: .slayer)
        let rockExplosionHero = Hero()
        rockExplosionHero.changeClass(to: .slayer)
        _ = rockExplosionHero.equipment.equip(Item(
            id: "ground-slam-rock-speed-boots",
            name: "大地强击岩石测试靴",
            rarity: .common,
            slot: .boots,
            stats: ItemStats(bonusSPD: 100),
            description: "测试用"
        ))
        let rockExplosionMonsters = (1...3).map { index in
            Monster(
                id: "ground-slam-rock-\(index)",
                name: "大地强击岩石训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let rockExplosionBattle = Battle(
            hero: rockExplosionHero,
            monsters: rockExplosionMonsters,
            party: HeroParty(primaryClass: .slayer),
            activeSkillSlotCount: 2,
            activeSkillLoadouts: rockExplosionLoadouts
        )
        var rockChargesWereArmed = false
        var maxRockCharges = 0
        var enemyHPAfterRockArm = rockExplosionBattle.enemyStates.map(\.hp).reduce(0, +)
        for _ in 0..<80 {
            rockExplosionBattle.update(deltaTime: 0.25)
            maxRockCharges = max(maxRockCharges, rockExplosionBattle.groundSlamRockCharges)
            if !rockChargesWereArmed, rockExplosionBattle.groundSlamRockCharges > 0 {
                rockChargesWereArmed = true
                enemyHPAfterRockArm = rockExplosionBattle.enemyStates.map(\.hp).reduce(0, +)
            }
            if rockChargesWereArmed &&
                rockExplosionBattle.log.contains(where: { $0.skillName == "大地强击岩石爆炸" && $0.kind == .damage }) {
                break
            }
        }
        let enemyHPAfterRockExplosion = rockExplosionBattle.enemyStates.map(\.hp).reduce(0, +)
        expect(
            rockChargesWereArmed &&
                maxRockCharges > 0 &&
                rockExplosionBattle.groundSlamRockCharges == 0 &&
                rockExplosionBattle.log.filter { $0.skillName == "大地强击岩石爆炸" && $0.kind == .damage }.count >= 3 &&
                enemyHPAfterRockExplosion < enemyHPAfterRockArm,
            "Ground Slam rock charges are consumed by later physical AOE and damage the live wave"
        )

        let axeSpinHero = Hero()
        axeSpinHero.changeClass(to: .slayer)
        let axeSpinMonsters = (1...3).map { index in
            Monster(
                id: "axe-spin-\(index)",
                name: "旋转斧训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let axeSpinBattle = Battle(hero: axeSpinHero, monsters: axeSpinMonsters, party: HeroParty(primaryClass: .slayer))
        for _ in 0..<5 {
            axeSpinBattle.update(deltaTime: 1)
            if axeSpinBattle.activeBuffNames.contains("旋转斧") {
                break
            }
        }
        axeSpinBattle.update(deltaTime: 1)
        expect(
            axeSpinBattle.activeBuffNames.contains("旋转斧") &&
                axeSpinBattle.log.filter { $0.skillName == "旋转斧" && $0.kind == .damage }.count >= 3 &&
                axeSpinBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "Axe Spin applies checked per-second range damage across the live wave"
        )
        expect(
            axeSpinBattle.enemyStates.allSatisfy(\.isBleeding),
            "Axe Spin marks all hit live enemies bleeding"
        )
        expect(
            axeSpinBattle.enemyStates.allSatisfy { EnemyStatusBadge.visible(for: $0).contains(.bleeding) },
            "Axe Spin bleeding is exposed through battle status badges"
        )
        let axeSpinBleedLogCount = axeSpinBattle.log.filter {
            $0.skillName == "旋转斧出血" && $0.kind == .buff
        }.count
        expect(
            axeSpinBleedLogCount >= 3,
            "Axe Spin records bleeding buff logs for hit live enemies"
        )
        let enemyHPAfterAxeSpinBleed = axeSpinBattle.enemyStates.map(\.hp).reduce(0, +)
        axeSpinBattle.update(deltaTime: 1)
        let axeSpinBleedFollowUpLogCount = axeSpinBattle.log.filter {
            $0.skillName == "旋转斧流血追击" && $0.kind == .damage
        }.count
        expect(
            axeSpinBleedFollowUpLogCount >= 3 &&
                axeSpinBattle.enemyStates.map(\.hp).reduce(0, +) < enemyHPAfterAxeSpinBleed,
            "Axe Spin deals follow-up physical damage to already bleeding enemies"
        )

        var supportAxeSpinParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportAxeSpinParty.setHeroClass(.slayer, atSlot: 1)
        var supportAxeSpinLoadouts = ActiveSkillLoadouts()
        supportAxeSpinLoadouts.setSkills(["60501"], for: .slayer)
        let supportAxeSpinBattle = Battle(
            hero: Hero(),
            monsters: (1...3).map { index in
                Monster(
                    id: "support-axe-spin-\(index)",
                    name: "支援旋转斧训练 \(index)",
                    hp: 100_000,
                    atk: 1,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                )
            },
            party: supportAxeSpinParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportAxeSpinLoadouts
        )
        for _ in 0..<40 {
            supportAxeSpinBattle.update(deltaTime: 1)
            if supportAxeSpinBattle.log.filter({ $0.skillName == "旋转斧流血追击" && $0.kind == .damage }).count >= 3 {
                break
            }
        }
        expect(
            supportAxeSpinBattle.log.contains { entry in
                if case .support(.slayer) = entry.attacker {
                    return entry.skillName == "旋转斧流血追击" && entry.kind == .damage
                }
                return false
            },
            "support Axe Spin keeps source-backed bleeding follow-up damage"
        )

        let bloodlustHero = Hero()
        bloodlustHero.changeClass(to: .slayer)
        let bloodlustMonster = Monster(
            id: "bloodlust-training",
            name: "嗜血训练木桩",
            hp: 100_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let bloodlustBattle = Battle(hero: bloodlustHero, monster: bloodlustMonster, party: HeroParty(primaryClass: .slayer))
        var hpBeforeBloodlust = bloodlustHero.currentHP
        for _ in 0..<8 {
            hpBeforeBloodlust = bloodlustHero.currentHP
            bloodlustBattle.update(deltaTime: 1)
            if bloodlustBattle.activeBuffNames.contains("嗜血") { break }
        }
        expect(
            bloodlustBattle.activeBuffNames.contains("嗜血") &&
                bloodlustBattle.activeHeroAttackMultiplier == 41.0,
            "Bloodlust applies its checked +4000% attack-damage buff"
        )
        expect(
            bloodlustHero.currentHP == hpBeforeBloodlust - hpBeforeBloodlust / 2 &&
                bloodlustBattle.heroHP == bloodlustHero.currentHP,
            "Bloodlust consumes half of current HP on activation"
        )

        var supportBloodlustParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportBloodlustParty.setHeroClass(.slayer, atSlot: 1)
        var supportBloodlustLoadouts = ActiveSkillLoadouts()
        supportBloodlustLoadouts.setSkills(["60601"], for: .slayer)
        let supportBloodlustBattle = Battle(
            hero: Hero(),
            monster: bloodlustMonster,
            party: supportBloodlustParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportBloodlustLoadouts
        )
        let supportBloodlustSlot = 1
        let supportBloodlustHPBefore = supportBloodlustBattle.supportStates.first {
            $0.slotIndex == supportBloodlustSlot
        }?.hp ?? 0
        supportBloodlustBattle.update(deltaTime: 1)
        let supportBloodlustHPAfter = supportBloodlustBattle.supportStates.first {
            $0.slotIndex == supportBloodlustSlot
        }?.hp ?? 0
        expect(
            supportBloodlustBattle.activeBuffNames.contains("嗜血") &&
                supportBloodlustBattle.activeSupportAttackMultiplier(slotIndex: supportBloodlustSlot) == 41.0 &&
                supportBloodlustHPAfter == supportBloodlustHPBefore - supportBloodlustHPBefore / 2 &&
                supportBloodlustBattle.log.contains {
                    $0.attacker == .support(.slayer) &&
                        $0.skillName == "嗜血" &&
                        $0.kind == .buff &&
                        $0.damage == supportBloodlustHPBefore / 2
                },
            "support Slayer Bloodlust consumes support HP and applies its checked attack-damage buff"
        )

        func makeSkillDurationHero(passiveIDs: Set<String> = []) -> Hero {
            let hero = Hero()
            hero.changeClass(to: .slayer)
            hero.unlockedPassiveSkillIDs = passiveIDs
            return hero
        }

        func bloodlustRemainingDuration(for hero: Hero) -> TimeInterval {
            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkills(["60601"], for: .slayer)
            let monster = Monster(
                id: "skill-duration-bloodlust-training",
                name: "持续增强嗜血训练木桩",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
            let battle = Battle(
                hero: hero,
                monster: monster,
                party: HeroParty(primaryClass: .slayer),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            battle.update(deltaTime: 1)
            return battle.activeHeroBuffRemainingDuration(named: "嗜血") ?? 0
        }

        let baselineBloodlustDuration = bloodlustRemainingDuration(for: makeSkillDurationHero())
        let boostedBloodlustDuration = bloodlustRemainingDuration(for: makeSkillDurationHero(passiveIDs: ["601072"]))
        expect(
            abs(baselineBloodlustDuration - 18.0) < 0.0001 &&
                boostedBloodlustDuration > baselineBloodlustDuration &&
                abs(boostedBloodlustDuration - 32.4) < 0.0001,
            "Skill Duration Increase passive extends Bloodlust's active battle buff duration"
        )

        let crushingBlowHero = Hero()
        crushingBlowHero.changeClass(to: .slayer)
        _ = crushingBlowHero.equipment.equip(Item(
            id: "crushing-blow-speed-boots",
            name: "粉碎强击测试靴",
            rarity: .common,
            slot: .boots,
            stats: ItemStats(bonusSPD: 100),
            description: "测试用"
        ))
        let crushingBlowMonsters = [
            Monster(
                id: "crushing-blow-primary",
                name: "粉碎强击主目标",
                hp: 1_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 1,
                goldReward: 1,
                lootTableID: "none"
            ),
            Monster(
                id: "crushing-blow-near-1",
                name: "冲击波邻近目标 1",
                hp: 10_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 1,
                goldReward: 1,
                lootTableID: "none"
            ),
            Monster(
                id: "crushing-blow-near-2",
                name: "冲击波邻近目标 2",
                hp: 10_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 1,
                goldReward: 1,
                lootTableID: "none"
            )
        ]
        let crushingBlowBattle = Battle(hero: crushingBlowHero, monsters: crushingBlowMonsters, party: HeroParty(primaryClass: .slayer))
        for _ in 0..<6 {
            crushingBlowBattle.update(deltaTime: 1)
            if crushingBlowBattle.log.contains(where: { $0.skillName == "粉碎强击冲击波" && $0.kind == .damage }) {
                break
            }
        }
        expect(crushingBlowBattle.log.contains { $0.skillName == "粉碎强击冲击波" && $0.kind == .damage }, "Crushing Blow kill emits shockwave damage")
        expect(
            crushingBlowBattle.log.filter { $0.skillName == "粉碎强击冲击波" && $0.kind == .damage }.count >= 2 &&
                crushingBlowBattle.enemyStates[0].isDefeated &&
                crushingBlowBattle.enemyStates.dropFirst().allSatisfy { !$0.isDefeated && $0.hp < $0.maxHP },
            "Crushing Blow shockwave damages surviving nearby wave enemies"
        )
        expect(
            crushingBlowBattle.log
                .filter { $0.skillName == "粉碎强击冲击波" && $0.kind == .damage }
                .allSatisfy { $0.damageElement == .physical && $0.delivery == .meleeAOE },
            "Crushing Blow shockwave damage logs carry explicit physical AOE metadata"
        )

        let hunter = Hero()
        hunter.changeClass(to: .hunter)
        let quickLoaderMonster = Monster(
            id: "quick-loader-training",
            name: "装填训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let quickLoaderBattle = Battle(hero: hunter, monster: quickLoaderMonster, party: HeroParty(primaryClass: .hunter))
        quickLoaderBattle.update(deltaTime: 1)
        quickLoaderBattle.update(deltaTime: 1)
        expect(
            quickLoaderBattle.activeBuffNames.contains("快速装填") &&
                quickLoaderBattle.activeHeroAttackSpeedMultiplier == 1.5,
            "Quick Loader applies a temporary attack-speed buff"
        )

        let frostBoltHero = Hero()
        frostBoltHero.changeClass(to: .hunter)
        let frostBoltMonsters = (1...3).map { index in
            Monster(
                id: "frost-bolt-\(index)",
                name: "寒霜弩箭训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let frostBoltBattle = Battle(hero: frostBoltHero, monsters: frostBoltMonsters, party: HeroParty(primaryClass: .hunter))
        frostBoltBattle.update(deltaTime: 1)
        expect(
            frostBoltBattle.log.filter { $0.skillName == "寒霜弩箭" && $0.kind == .damage }.count >= 3 &&
                frostBoltBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "Frost Bolt applies checked cold projectile explosion damage across the live wave"
        )
        expect(
            frostBoltBattle.log.filter { $0.attacker == .monster }.isEmpty,
            "Frost Bolt freezes hit enemies enough to delay their next attack tick"
        )
        expect(
            frostBoltBattle.enemyStates.allSatisfy {
                $0.coldStatus == .frozen &&
                    EnemyStatusBadge.visible(for: $0).contains(.frozen)
            },
            "Frost Bolt exposes frozen enemy status badges for the current freeze-delay scaffold"
        )

        var supportFrostBoltParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportFrostBoltParty.setHeroClass(.hunter, atSlot: 1)
        var supportFrostBoltLoadouts = ActiveSkillLoadouts()
        supportFrostBoltLoadouts.setSkills(["50201"], for: .hunter)
        let supportFrostBoltMonsters = (1...3).map { index in
            Monster(
                id: "support-frost-bolt-\(index)",
                name: "支援寒霜弩箭训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let supportFrostBoltBattle = Battle(
            hero: Hero(),
            monsters: supportFrostBoltMonsters,
            party: supportFrostBoltParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportFrostBoltLoadouts
        )
        supportFrostBoltBattle.update(deltaTime: 1)
        expect(
            supportFrostBoltBattle.log.filter {
                $0.attacker == .support(.hunter) &&
                    $0.skillName == "寒霜弩箭" &&
                    $0.kind == .damage
            }.count >= 3 &&
                supportFrostBoltBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "support Hunter Frost Bolt applies checked cold projectile explosion damage across the live wave"
        )
        expect(
            supportFrostBoltBattle.log.filter { $0.attacker == .monster }.isEmpty,
            "support Hunter Frost Bolt freezes hit enemies enough to delay their next attack tick"
        )
        expect(
            supportFrostBoltBattle.enemyStates.allSatisfy {
                $0.coldStatus == .frozen &&
                    EnemyStatusBadge.visible(for: $0).contains(.frozen)
            },
            "support Hunter Frost Bolt exposes frozen enemy status badges for the current freeze-delay scaffold"
        )

        let explosiveBoltHero = Hero()
        explosiveBoltHero.changeClass(to: .hunter)
        let explosiveBoltMonsters = (1...3).map { index in
            Monster(
                id: "explosive-bolt-\(index)",
                name: "爆炸弩箭训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let explosiveBoltBattle = Battle(hero: explosiveBoltHero, monsters: explosiveBoltMonsters, party: HeroParty(primaryClass: .hunter))
        for _ in 0..<8 {
            explosiveBoltBattle.update(deltaTime: 1)
            if explosiveBoltBattle.log.contains(where: { $0.skillName == "爆炸弩箭" && $0.kind == .damage }) {
                break
            }
        }
        expect(
            explosiveBoltBattle.log.filter { $0.skillName == "爆炸弩箭" && $0.kind == .damage }.count >= 3 &&
                explosiveBoltBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "Explosive Bolt applies checked fire projectile explosion damage across the live wave"
        )

        let chargedTrapHero = Hero()
        chargedTrapHero.changeClass(to: .hunter)
        let chargedTrapMonsters = (1...3).map { index in
            Monster(
                id: "charged-trap-\(index)",
                name: "充能陷阱训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let chargedTrapBattle = Battle(hero: chargedTrapHero, monsters: chargedTrapMonsters, party: HeroParty(primaryClass: .hunter))
        for _ in 0..<8 {
            chargedTrapBattle.update(deltaTime: 1)
            if chargedTrapBattle.log.contains(where: { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage }) {
                break
            }
        }
        expect(
            chargedTrapBattle.log.contains { $0.skillName == "充能陷阱" && $0.kind == .buff } &&
                chargedTrapBattle.log.filter { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage }.count >= 3 &&
                chargedTrapBattle.activeChargedTrapChargesRemaining == 0,
            "Charge Trap arms a trap and detonates it from later elemental damage"
        )
        expect(
            chargedTrapBattle.log
                .filter { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage }
                .allSatisfy { $0.damageElement == .physical && $0.delivery == .trap },
            "Charge Trap explosion damage logs carry explicit trap metadata"
        )

        let physicalTrapHero = Hero()
        physicalTrapHero.changeClass(to: .hunter)
        var physicalTrapLoadouts = ActiveSkillLoadouts()
        physicalTrapLoadouts.setSkills(["50501"], for: .hunter)
        let physicalTrapMonster = Monster(
            id: "charged-trap-physical-log",
            name: "充能陷阱物理日志木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let physicalTrapBattle = Battle(
            hero: physicalTrapHero,
            monsters: [physicalTrapMonster],
            party: HeroParty(primaryClass: .hunter),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: physicalTrapLoadouts
        )
        physicalTrapBattle.activateBattleStatusSnapshotBuffs()
        for _ in 0..<4 {
            physicalTrapBattle.update(deltaTime: 2)
        }
        let physicalTurretDamageLogs = physicalTrapBattle.log.filter {
            $0.skillName == "弩炮塔" && $0.kind == .damage
        }
        expect(
            !physicalTurretDamageLogs.isEmpty &&
                physicalTurretDamageLogs.allSatisfy {
                    $0.damageElement == .physical &&
                        $0.delivery == .summonProjectile &&
                        $0.attacker.isHeroSide
                } &&
                !physicalTrapBattle.log.contains { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage } &&
                physicalTrapBattle.activeChargedTrapChargesRemaining == 1,
            "Charge Trap ignores actual physical damage logs instead of consuming a charge"
        )

        let elementalDotTrapHero = Hero()
        elementalDotTrapHero.changeClass(to: .sorcerer)
        var elementalDotTrapLoadouts = ActiveSkillLoadouts()
        elementalDotTrapLoadouts.setSkills(["30501"], for: .sorcerer)
        let elementalDotTrapMonsters = (1...3).map { index in
            Monster(
                id: "charged-trap-dot-\(index)",
                name: "充能陷阱持续伤害训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let elementalDotTrapBattle = Battle(
            hero: elementalDotTrapHero,
            monsters: elementalDotTrapMonsters,
            party: HeroParty(primaryClass: .sorcerer),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: elementalDotTrapLoadouts
        )
        elementalDotTrapBattle.activateBattleStatusSnapshotBuffs()
        for _ in 0..<6 {
            elementalDotTrapBattle.update(deltaTime: 2)
            if elementalDotTrapBattle.log.contains(where: { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage }) {
                break
            }
        }
        let elementalDotLogs = elementalDotTrapBattle.log.filter {
            $0.skillName == "暴风雪" && $0.kind == .damage
        }
        expect(
            elementalDotLogs.count >= 3 &&
                elementalDotLogs.allSatisfy {
                    $0.damageElement == .cold &&
                        $0.attacker.isHeroSide
                } &&
                elementalDotTrapBattle.log.filter { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage }.count >= 3 &&
                elementalDotTrapBattle.activeChargedTrapChargesRemaining == 0,
            "Charge Trap detonates only from actual elemental damage logs, including damage-over-time"
        )

        var supportChargedTrapParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportChargedTrapParty.setHeroClass(.hunter, atSlot: 1)
        var supportChargedTrapLoadouts = ActiveSkillLoadouts()
        supportChargedTrapLoadouts.setSkills(["10601"], for: .knight)
        supportChargedTrapLoadouts.setSkills(["50401", "50101"], for: .hunter)
        let supportChargedTrapMonsters = (1...3).map { index in
            Monster(
                id: "support-charged-trap-\(index)",
                name: "支援充能陷阱训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let supportChargedTrapBattle = Battle(
            hero: Hero(),
            monsters: supportChargedTrapMonsters,
            party: supportChargedTrapParty,
            activeSkillSlotCount: 2,
            activeSkillLoadouts: supportChargedTrapLoadouts
        )
        supportChargedTrapBattle.update(deltaTime: 2)
        expect(
            supportChargedTrapBattle.log.contains {
                $0.attacker == .support(.hunter) &&
                    $0.skillName == "充能陷阱" &&
                    $0.kind == .buff
            } &&
                supportChargedTrapBattle.activeChargedTrapChargesRemaining == 1 &&
                PlayerBattleDeployable.visible(for: supportChargedTrapBattle).contains(.chargedTrap),
            "support Hunter Charge Trap arms a visible player-side trap"
        )
        for _ in 0..<8 {
            supportChargedTrapBattle.update(deltaTime: 2)
            if supportChargedTrapBattle.log.contains(where: {
                $0.attacker == .support(.hunter) &&
                    $0.skillName == "充能陷阱爆炸" &&
                    $0.kind == .damage
            }) {
                break
            }
        }
        expect(
            supportChargedTrapBattle.log.filter {
                $0.attacker == .support(.hunter) &&
                    $0.skillName == "充能陷阱爆炸" &&
                    $0.kind == .damage
            }.count >= 3 &&
                supportChargedTrapBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP } &&
                supportChargedTrapBattle.activeChargedTrapChargesRemaining == 0,
            "support Hunter Charge Trap detonates from later support elemental damage"
        )
        expect(
            supportChargedTrapBattle.log
                .filter {
                    $0.attacker == .support(.hunter) &&
                        $0.skillName == "充能陷阱爆炸" &&
                        $0.kind == .damage
                }
                .allSatisfy { $0.damageElement == .physical && $0.delivery == .trap },
            "support Hunter Charge Trap explosion logs carry explicit trap metadata"
        )

        let crossbowTurretHero = Hero()
        crossbowTurretHero.changeClass(to: .hunter)
        let crossbowTurretMonster = Monster(
            id: "crossbow-turret-training",
            name: "弩炮塔训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let crossbowTurretBattle = Battle(hero: crossbowTurretHero, monster: crossbowTurretMonster, party: HeroParty(primaryClass: .hunter))
        for _ in 0..<10 {
            crossbowTurretBattle.update(deltaTime: 1)
            if crossbowTurretBattle.log.contains(where: { $0.skillName == "弩炮塔" && $0.kind == .damage }) {
                break
            }
        }
        expect(
            crossbowTurretBattle.activeBuffNames.contains("弩炮塔") &&
                crossbowTurretBattle.log.contains { $0.skillName == "弩炮塔" && $0.kind == .buff } &&
                crossbowTurretBattle.log.contains { $0.skillName == "弩炮塔" && $0.kind == .damage },
            "Crossbow Turret deploys a summon and fires physical projectile damage over time"
        )
        expect(
            crossbowTurretBattle.log
                .filter { $0.skillName == "弩炮塔" && $0.kind == .damage }
                .allSatisfy { $0.damageElement == .physical && $0.delivery == .summonProjectile },
            "Crossbow Turret damage logs carry explicit summon projectile metadata"
        )

        let shockBoltHero = Hero()
        shockBoltHero.changeClass(to: .hunter)
        let shockBoltMonsters = (1...3).map { index in
            Monster(
                id: "shock-bolt-\(index)",
                name: "电击弩箭训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let shockBoltBattle = Battle(hero: shockBoltHero, monsters: shockBoltMonsters, party: HeroParty(primaryClass: .hunter))
        for _ in 0..<20 {
            shockBoltBattle.update(deltaTime: 1)
            if shockBoltBattle.log.contains(where: { $0.skillName == "电击弩箭电流" && $0.kind == .damage }) {
                break
            }
        }
        expect(
            shockBoltBattle.log.contains { $0.skillName == "电击弩箭" && $0.kind == .damage } &&
                shockBoltBattle.activeBuffNames.contains("电击弩箭电流") &&
                shockBoltBattle.log.filter { $0.skillName == "电击弩箭电流" && $0.kind == .damage }.count >= 3,
            "Shock Bolt lodges a bolt and emits checked lightning current damage over time"
        )
        expect(
            shockBoltBattle.log
                .filter { $0.skillName == "电击弩箭电流" && $0.kind == .damage }
                .allSatisfy { $0.damageElement == .lightning && $0.delivery == .projectile },
            "Shock Bolt current damage logs carry explicit lightning projectile metadata"
        )

        var supportShockBoltParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        supportShockBoltParty.setHeroClass(.hunter, atSlot: 1)
        var supportShockBoltLoadouts = ActiveSkillLoadouts()
        supportShockBoltLoadouts.setSkills(["50601"], for: .hunter)
        let supportShockBoltMonsters = (1...3).map { index in
            Monster(
                id: "support-shock-bolt-\(index)",
                name: "支援电击弩箭训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let supportShockBoltBattle = Battle(
            hero: Hero(),
            monsters: supportShockBoltMonsters,
            party: supportShockBoltParty,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: supportShockBoltLoadouts
        )
        for _ in 0..<30 {
            supportShockBoltBattle.update(deltaTime: 1)
            if supportShockBoltBattle.log.contains(where: {
                $0.attacker == .support(.hunter) &&
                    $0.skillName == "电击弩箭电流" &&
                    $0.kind == .damage
            }) {
                break
            }
        }
        expect(
            supportShockBoltBattle.activeBuffNames.contains("电击弩箭电流") &&
                PlayerBattleStatusBadge.visible(for: supportShockBoltBattle).contains(.shockCurrent) &&
                supportShockBoltBattle.log.contains {
                    $0.attacker == .support(.hunter) &&
                        $0.skillName == "电击弩箭" &&
                        $0.kind == .damage
                } &&
                supportShockBoltBattle.log.filter {
                    $0.attacker == .support(.hunter) &&
                        $0.skillName == "电击弩箭电流" &&
                        $0.kind == .damage
                }.count >= 3,
            "support Shock Bolt keeps support-attributed lodged hit and lightning current damage"
        )
        expect(
            supportShockBoltBattle.log
                .filter {
                    $0.attacker == .support(.hunter) &&
                        $0.skillName == "电击弩箭电流" &&
                        $0.kind == .damage
                }
                .allSatisfy { $0.damageElement == .lightning && $0.delivery == .projectile },
            "support Shock Bolt current damage logs carry explicit lightning projectile metadata"
        )

        let waveHero = Hero()
        let waveMonsters = (1...3).map { index in
            Monster(
                id: "wave-\(index)",
                name: "波次训练 \(index)",
                hp: 1,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: index * 10,
                goldReward: index * 5,
                lootTableID: "none"
            )
        }
        let waveBattle = Battle(hero: waveHero, monsters: waveMonsters, party: HeroParty(primaryClass: .knight))
        expect(
            waveBattle.waveMonsters.map(\.id) == ["wave-1", "wave-2", "wave-3"] &&
                waveBattle.remainingWaveMonsters.map(\.id) == ["wave-1", "wave-2", "wave-3"] &&
                waveBattle.upcomingWaveMonsters.map(\.id) == ["wave-2", "wave-3"],
            "wave battle exposes enemy queue for UI"
        )
        expect(
            waveBattle.enemyStates.count == 3 &&
                waveBattle.enemyStates.allSatisfy { !$0.isDefeated && $0.hp == $0.maxHP },
            "wave battle tracks simultaneous enemy HP states"
        )

        let groupHero = Hero()
        let groupMonsters = (1...3).map { index in
            Monster(
                id: "group-\(index)",
                name: "群体训练 \(index)",
                hp: 10_000,
                atk: 12,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let groupBattle = Battle(hero: groupHero, monsters: groupMonsters, party: HeroParty(primaryClass: .knight))
        groupBattle.update(deltaTime: 1)
        expect(
            groupBattle.log.filter { $0.attacker == .monster }.count == 3 &&
                groupBattle.heroHP < groupHero.maxHP,
            "all alive wave enemies can attack during the same battle tick"
        )

        let splitHero = Hero()
        let splitMonsters = [
            Monster(id: "split-1", name: "脆弱敌人", hp: 1, atk: 1, def: 0, spd: 1, critRate: 0, xpReward: 1, goldReward: 1, lootTableID: "none"),
            Monster(id: "split-2", name: "坚韧敌人 2", hp: 10_000, atk: 1, def: 0, spd: 1, critRate: 0, xpReward: 2, goldReward: 2, lootTableID: "none"),
            Monster(id: "split-3", name: "坚韧敌人 3", hp: 10_000, atk: 1, def: 0, spd: 1, critRate: 0, xpReward: 3, goldReward: 3, lootTableID: "none")
        ]
        let splitBattle = Battle(hero: splitHero, monsters: splitMonsters, party: HeroParty(primaryClass: .knight))
        splitBattle.update(deltaTime: 1)
        expect(
            splitBattle.enemyStates[0].isDefeated &&
                splitBattle.remainingWaveMonsters.map(\.id) == ["split-2", "split-3"] &&
                splitBattle.activeEnemyState?.monster.id == "split-2" &&
                !splitBattle.isOver,
            "defeating one enemy keeps the rest of the wave active"
        )

        for _ in 0..<12 {
            waveBattle.update(deltaTime: 1)
            if waveBattle.isOver { break }
        }
        if case .victory(let rewards) = waveBattle.result {
            expect(rewards.encountersCleared == 3, "wave battle clears multiple encounters")
            expect(rewards.xp == 60 && rewards.gold == 30, "wave battle aggregates rewards")
            expect(waveBattle.currentMonsterNumber == 3 && waveBattle.monsterCount == 3, "wave battle exposes current monster position")
        } else {
            expect(false, "wave battle finishes with victory")
        }
    }

    private static func sourceSkillCatalog() {
        print("[SourceSkillCatalog]")

        let activationCounts = Dictionary(grouping: SourceSkillCatalog.all, by: \.activation)
            .mapValues(\.count)

        expect(SourceSkillCatalog.all.count == 106, "source skill catalog covers all checked active/base/monster skill rows")
        expect(
            SourceSkillCatalog.all.count == SourceSkillCatalog.expectedSourceCount,
            "source skill catalog matches the checked source count"
        )
        expect(
            Set(SourceSkillCatalog.all.map(\.id)).count == SourceSkillCatalog.all.count,
            "source skill catalog IDs are unique"
        )
        expect(
            activationCounts == [
                .baseAttack: 58,
                .baseAttackCount: 11,
                .continuous: 2,
                .cooldown: 35
            ],
            "source skill catalog preserves checked activation distribution"
        )
        expect(
            SourceSkillCatalog.damageTypes == ["Chaos", "Cold", "Fire", "Lightning", "Physical"],
            "source skill catalog preserves checked damage type set"
        )
        expect(
            SourceSkillCatalog.deliveries.count == 8 &&
                SourceSkillCatalog.deliveries.contains("") &&
                SourceSkillCatalog.deliveries.contains("Projectile, Summon") &&
                SourceSkillCatalog.deliveries.contains("Trap"),
            "source skill catalog preserves checked delivery categories including empty source values"
        )
        expect(
            SourceSkillCatalog.skill(id: "10001") == SourceSkill(
                id: "10001",
                name: "Skill 10001",
                activation: .baseAttack,
                damageType: "Physical",
                delivery: "Melee",
                range: 140
            ),
            "source skill catalog keeps the checked Knight base attack row"
        )
        expect(
            SourceSkillCatalog.skill(id: "60301") == SourceSkill(
                id: "60301",
                name: "Commander’s Cry",
                activation: .cooldown,
                damageType: "Physical",
                delivery: "AOE",
                range: 150
            ),
            "source skill catalog keeps the checked Slayer shout row"
        )
        expect(
            SourceSkillCatalog.skill(id: "309021") == SourceSkill(
                id: "309021",
                name: "Skill 309021",
                activation: .cooldown,
                damageType: "Chaos",
                delivery: "",
                range: 700,
                sourceValue: 800
            ),
            "source skill catalog keeps checked monster chaos skill rows"
        )
        expect(
            SourceSkillCatalog.skill(id: "309021")?.runtimeDamageElement == .chaos &&
                SourceSkillCatalog.skill(id: "309021")?.runtimeDelivery == SkillDelivery.none,
            "source chaos skill rows map to runtime chaos metadata without fabricating delivery"
        )
        expect(
            SourceSkillCatalog.skill(id: "309021")?.sourceValue == 800 &&
                SourceSkillCatalog.skill(id: "309041")?.sourceValue == 1700 &&
                SourceSkillCatalog.skill(id: "309051")?.sourceValue == 2300 &&
                SourceSkillCatalog.skill(id: "109021")?.sourceValue == 1500 &&
                SourceSkillCatalog.skill(id: "209031")?.sourceValue == 1350 &&
                SourceSkillCatalog.skill(id: "209041")?.sourceValue == 2300 &&
                SourceSkillCatalog.skill(id: "200421")?.sourceValue == 1000 &&
                SourceSkillCatalog.skill(id: "201211")?.sourceValue == 1000 &&
                SourceSkillCatalog.skill(id: "300441")?.sourceValue == 1000 &&
                SourceSkillCatalog.skill(id: "309031")?.sourceValue == 1500 &&
                SourceSkillCatalog.skill(id: "10001")?.sourceValue == nil,
            "source skill catalog preserves checked single-page values only where verified"
        )
        expect(
            SourceSkillCatalog.runtimeNamedHeroSkillIDs.count == 36 &&
                SourceSkillCatalog.runtimeHeroBaseAttackSkillIDs.count == 6 &&
                SourceSkillCatalog.runtimeHeroSkillIDs.count == 42 &&
                SourceSkillCatalog.runtimeMonsterAttackSkillIDs.count == 4 &&
                SourceSkillCatalog.runtimeModeledSkillIDs.count == 46 &&
                SourceSkillCatalog.runtimeModeledSkillIDs.allSatisfy { SourceSkillCatalog.skill(id: $0) != nil },
            "all runtime-modeled hero and checked monster attack skills are present in the source catalog"
        )
        expect(
            SourceSkillCatalog.runtimeModeledSkills.count == 46 &&
                SourceSkillCatalog.runtimeHeroBaseAttackSkillIDs.allSatisfy { SourceSkillCatalog.skill(id: $0)?.activation == .baseAttack } &&
                SourceSkillCatalog.runtimeMonsterAttackSkillIDs.allSatisfy { SourceSkillCatalog.skill(id: $0)?.activation == .baseAttack },
            "source skill catalog distinguishes runtime-modeled skills from unimplemented source rows"
        )
        let expectedBaseAttacks: [(HeroClass, String, SkillDamageElement, SkillDelivery)] = [
            (.knight, "10001", .physical, .melee),
            (.ranger, "20001", .physical, .projectile),
            (.sorcerer, "30001", .fire, .projectile),
            (.priest, "40001", .physical, .melee),
            (.hunter, "50001", .physical, .projectile),
            (.slayer, "60001", .physical, .melee)
        ]
        expect(
            expectedBaseAttacks.allSatisfy { heroClass, sourceID, damageElement, delivery in
                HeroSkills.baseAttackSourceSkill(for: heroClass)?.id == sourceID &&
                    HeroSkills.baseAttackDamageElement(for: heroClass) == damageElement &&
                    HeroSkills.baseAttackDelivery(for: heroClass) == delivery
            },
            "source base attack rows resolve to runtime element and delivery metadata"
        )
        let expectedMonsterAttacks: [(String, String, SkillDamageElement)] = [
            ("燃烧的地狱祭司", "301015", .fire),
            ("冰冻的地狱祭司", "301025", .cold),
            ("电流的地狱祭司", "301035", .lightning),
            ("混沌的地狱祭司", "301045", .chaos)
        ]
        expect(
            expectedMonsterAttacks.allSatisfy { name, sourceID, damageElement in
                guard SourceSkillCatalog.sourceSkillID(forMonsterNamed: name) == sourceID else { return false }
                for stage in StageDefinition.all {
                    for difficulty in Difficulty.allCases {
                        for encounterIndex in 0..<stage.clearTarget(for: difficulty) {
                            let monster = stage.spawnMonster(
                                difficulty: difficulty,
                                encounterIndex: encounterIndex
                            )
                            if monster.name == name {
                                return monster.sourceSkillID == sourceID &&
                                    monster.sourceSkill?.activation == .baseAttack &&
                                    monster.sourceDamageElement == damageElement
                            }
                        }
                    }
                }
                return false
            },
            "stage elemental hell priests resolve to checked source monster attack metadata"
        )
        let sourceNamedMonster = Monster(
            id: "source-named-priest",
            name: "燃烧的地狱祭司",
            hp: 100_000,
            atk: 400,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 1,
            goldReward: 1,
            lootTableID: "none",
            sourceSkillID: "301015"
        )
        let sourceNamedBattle = Battle(
            hero: Hero(),
            monster: sourceNamedMonster,
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1
        )
        sourceNamedBattle.update(deltaTime: 0.01)
        let sourceNamedMonsterHit = sourceNamedBattle.log.last { $0.attacker == .monster }
        expect(
            sourceNamedMonsterHit?.attackerName == "燃烧的地狱祭司" &&
                sourceNamedMonsterHit?.attackerDisplayName == "燃烧的地狱祭司" &&
                sourceNamedMonsterHit?.damageElement == .fire,
            "source-backed monster attacks keep the actual stage monster name in combat logs"
        )
        let firstStageMonster = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal)
        expect(
            firstStageMonster.name == "哥布林盗贼" &&
                firstStageMonster.sourceSkillID == nil &&
                firstStageMonster.sourceDamageElement == .none,
            "unmapped stage monsters stay generic instead of fabricating source attack metadata"
        )
        expect(SourceSkillCatalog.skill(id: "999999") == nil, "unknown source skill IDs do not resolve")
    }

    private static func passiveSkills() {
        print("[PassiveSkills]")

        expect(PassiveSkills.all.count == 108, "passive skill catalog covers all checked passive nodes")
        expect(
            Set(PassiveSkills.all.map(\.id)).count == PassiveSkills.all.count,
            "passive skill catalog IDs are unique"
        )
        expect(
            HeroClass.allCases.allSatisfy { PassiveSkills.skills(for: $0).count == 18 },
            "passive skill catalog keeps 18 passive nodes per hero class"
        )
        expect(
            Set(PassiveSkills.all.map(\.valueType)) == Set(PassiveSkillValueType.allCases),
            "passive skill catalog preserves checked passive value types"
        )
        expect(
            Set(PassiveSkills.all.map(\.stat)).count == 30,
            "passive skill catalog preserves checked stat variety"
        )
        let passiveSkillIconNames = PassiveSkills.all.compactMap { GameArt.passiveSkillIconName(for: $0) }
        let missingPassiveIconStats = Set(
            PassiveSkills.all
                .filter { GameArt.passiveSkillIconName(for: $0) == nil }
                .map(\.stat)
        )
        expect(
            passiveSkillIconNames.count == 104 &&
                Set(passiveSkillIconNames).count == GameArt.passiveSkillIconNames.count &&
                GameArt.passiveSkillIconNames.count == 27,
            "passive skill catalog maps current source-backed rows to 27 bundled source icons"
        )
        expect(
            missingPassiveIconStats == ["IncreaseProjectileDamage", "SkillHealIncrease"],
            "passive skill icon mapping keeps current source-page missing icon stats explicit"
        )
        expect(
            GameArt.passiveSkillIconName(forStat: "SkillDurationIncrease") == "source_passive_Duration" &&
                GameArt.passiveSkillIconName(forStat: "ElementalDodgeChance") == "source_passive_DodgeChance" &&
                GameArt.passiveSkillIconName(forStat: "IncreaseAreaOfEffectDamage") == "source_passive_AreaOfEffectDamage",
            "passive skill icon mapping preserves non-mechanical source icon families"
        )
        expect(
            PassiveSkills.skill(id: "101001") == PassiveSkill(
                id: "101001",
                name: "Attack Damage Enhancement",
                stat: "AttackDamage",
                valueType: .flat,
                value: 1
            ),
            "Knight passive 101001 matches checked source row"
        )
        expect(
            PassiveSkills.skill(id: "201011") == PassiveSkill(
                id: "201011",
                name: "Critical Chance Enhancement",
                stat: "CriticalChance",
                valueType: .additive,
                value: 200
            ),
            "Ranger passive 201011 matches checked source row"
        )
        expect(
            PassiveSkills.skill(id: "501021") == PassiveSkill(
                id: "501021",
                name: "Fire Damage Enhancement",
                stat: "FireDamagePercent",
                valueType: .flat,
                value: 150
            ),
            "Hunter passive 501021 matches checked source row"
        )
        expect(
            PassiveSkills.skill(id: "601072") == PassiveSkill(
                id: "601072",
                name: "Duration Enhancement",
                stat: "SkillDurationIncrease",
                valueType: .additive,
                value: 80
            ),
            "Slayer passive 601072 matches checked source row"
        )
        expect(
            PassiveSkills.skill(id: "501021")?.heroClass == .hunter &&
                PassiveSkills.skill(id: "601072")?.heroClass == .slayer,
            "passive skill catalog derives hero class from checked ID prefixes"
        )
        expect(
            PassiveSkills.skill(id: "999999") == nil &&
                PassiveSkills.heroClass(for: "999999") == nil,
            "unknown passive skill IDs do not resolve to fabricated source rows"
        )

        let knight = Hero()
        knight.unlockedPassiveSkillIDs = [
            "101001", // passiveAttackDamage
            "101002", // passiveMaxHp
            "101011", // passiveArmor
            "101061", // passiveAttackSpeed
            "101071", // passiveDamageReduction
            "201011"  // different class, must be ignored
        ]
        expect(knight.maxHP == 145, "unlocked Knight passive MaxHp changes runtime max HP")
        expect(knight.attack == 19, "unlocked Knight passive AttackDamage changes runtime attack")
        expect(knight.defense == 55, "unlocked Knight passive Armor changes runtime defense")
        expect(knight.speed == 13, "unlocked Knight passive AttackSpeed changes runtime speed")
        expect(
            abs(knight.passiveRuntimeEffects.passiveDamageReduction - 0.20) < 0.0001,
            "unlocked Knight passive DamageReduction is exposed to battle damage mitigation"
        )
        expect(
            abs(knight.critRate - knight.baseStats.critRate) < 0.0001,
            "passive runtime effects ignore unlocked IDs from another hero class"
        )

        func knightBaseAttackSummary(passiveIDs: Set<String> = [], seconds: Int = 120) -> (count: Int, totalDamage: Int) {
            let hero = Hero()
            hero.unlockedPassiveSkillIDs = passiveIDs
            _ = hero.equipment.equip(Item(
                id: "core-passive-base-attack-crit-suppression",
                name: "基础攻击测试护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusCritRate: -1.0),
                description: "测试用"
            ))

            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkill("10601", for: .knight, slotIndex: 0)

            let battle = Battle(
                hero: hero,
                monster: Monster(
                    id: "core-passive-base-attack-training",
                    name: "基础属性训练木桩",
                    hp: 100_000_000,
                    atk: 0,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                ),
                party: HeroParty(primaryClass: .knight),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )

            for _ in 0..<(seconds * 10) {
                battle.update(deltaTime: 0.1)
            }

            let baseAttackLogs = battle.log.filter {
                $0.attacker == .hero && $0.kind == .damage && $0.skillName == nil
            }
            return (
                count: baseAttackLogs.count,
                totalDamage: baseAttackLogs.map(\.damage).reduce(0, +)
            )
        }

        let baselineKnightBaseAttacks = knightBaseAttackSummary()
        let attackDamageKnightBaseAttacks = knightBaseAttackSummary(passiveIDs: ["101001", "101072"])
        let attackSpeedKnightBaseAttacks = knightBaseAttackSummary(passiveIDs: ["101061"])
        expect(
            baselineKnightBaseAttacks.count > 0 &&
                attackDamageKnightBaseAttacks.totalDamage > baselineKnightBaseAttacks.totalDamage &&
                attackSpeedKnightBaseAttacks.count > baselineKnightBaseAttacks.count,
            "Attack Damage and Attack Speed passives change live Knight base-attack damage and cadence"
        )

        func incomingMonsterDamageSummary(
            heroClass: HeroClass,
            passiveIDs: Set<String> = [],
            sourceSkillID: String? = nil,
            seconds: Int = 180
        ) -> (count: Int, totalDamage: Int) {
            let hero = Hero()
            hero.changeClass(to: heroClass)
            hero.unlockedPassiveSkillIDs = passiveIDs
            _ = hero.equipment.equip(Item(
                id: "defensive-passive-runtime-vitality",
                name: "防御被动测试生命护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusHP: 1_000_000),
                description: "测试用"
            ))
            _ = hero.heal(hero.maxHP)

            var loadouts = ActiveSkillLoadouts()
            switch heroClass {
            case .knight:
                loadouts.setSkill("10601", for: .knight, slotIndex: 0)
            case .priest:
                loadouts.setSkill("40601", for: .priest, slotIndex: 0)
            case .ranger, .sorcerer, .hunter, .slayer:
                break
            }

            let battle = Battle(
                hero: hero,
                monster: Monster(
                    id: "defensive-passive-runtime-attacker",
                    name: "防御被动训练攻击者",
                    hp: 100_000_000,
                    atk: 160,
                    def: 0,
                    spd: 20,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none",
                    sourceSkillID: sourceSkillID
                ),
                party: HeroParty(primaryClass: heroClass),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts,
                incomingDodgeRollProvider: { 1.0 },
                incomingBlockRollProvider: { 1.0 }
            )

            for _ in 0..<(seconds * 10) {
                battle.update(deltaTime: 0.1)
            }

            let monsterDamageLogs = battle.log.filter {
                $0.attacker == .monster && $0.kind == .damage && $0.damage > 0
            }
            return (
                count: monsterDamageLogs.count,
                totalDamage: monsterDamageLogs.map(\.damage).reduce(0, +)
            )
        }

        let baselineKnightIncoming = incomingMonsterDamageSummary(heroClass: .knight)
        let reducedKnightIncoming = incomingMonsterDamageSummary(heroClass: .knight, passiveIDs: ["101071"])
        let baselineKnightFireIncoming = incomingMonsterDamageSummary(heroClass: .knight, sourceSkillID: "301015")
        let resistedKnightFireIncoming = incomingMonsterDamageSummary(heroClass: .knight, passiveIDs: ["101062"], sourceSkillID: "301015")
        let baselinePriestIncoming = incomingMonsterDamageSummary(heroClass: .priest)
        let absorbedPriestIncoming = incomingMonsterDamageSummary(heroClass: .priest, passiveIDs: ["401012", "401032"])
        expect(
            baselineKnightIncoming.count > 0 &&
                reducedKnightIncoming.count == baselineKnightIncoming.count &&
                reducedKnightIncoming.totalDamage < baselineKnightIncoming.totalDamage &&
                baselineKnightFireIncoming.count > 0 &&
                resistedKnightFireIncoming.count == baselineKnightFireIncoming.count &&
                resistedKnightFireIncoming.totalDamage < baselineKnightFireIncoming.totalDamage &&
                baselinePriestIncoming.count > 0 &&
                absorbedPriestIncoming.count == baselinePriestIncoming.count &&
                absorbedPriestIncoming.totalDamage < baselinePriestIncoming.totalDamage,
            "Damage Reduction, All Elemental Resistance and Damage Absorption passives reduce live monster-hit damage"
        )

        func firstMonsterIncomingLog(monsterCritRate: Double) -> BattleLogEntry? {
            let hero = Hero()
            hero.changeClass(to: .ranger)
            _ = hero.equipment.equip(Item(
                id: "monster-crit-runtime-vitality",
                name: "怪物暴击测试护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusHP: 1_000_000),
                description: "测试用"
            ))
            _ = hero.heal(hero.maxHP)

            let battle = Battle(
                hero: hero,
                monster: Monster(
                    id: "monster-crit-runtime-attacker",
                    name: "怪物暴击训练攻击者",
                    hp: 100_000_000,
                    atk: 160,
                    def: 0,
                    spd: 20,
                    critRate: monsterCritRate,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                ),
                party: HeroParty(primaryClass: .ranger),
                incomingDodgeRollProvider: { 1.0 },
                incomingBlockRollProvider: { 1.0 }
            )
            battle.update(deltaTime: 1)
            return battle.log.first {
                $0.attacker == .monster && $0.kind == .damage && $0.damage > 0
            }
        }

        let guaranteedMonsterCrit = firstMonsterIncomingLog(monsterCritRate: 1.0)
        let zeroMonsterCrit = firstMonsterIncomingLog(monsterCritRate: 0)
        expect(
            guaranteedMonsterCrit?.isCrit == true &&
                zeroMonsterCrit?.isCrit == false &&
                (guaranteedMonsterCrit?.damage ?? 0) > (zeroMonsterCrit?.damage ?? Int.max),
            "monster attacks use stored monster crit rate in live damage logs while zero monster crit rate keeps live incoming hits non-critical"
        )

        let blockEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["101022", "101052"],
            heroClass: .knight
        )
        expect(
            abs(blockEffects.passiveBlockChance - 0.006) < 0.0001,
            "unlocked Knight passives expose block chance runtime hooks"
        )

        let elementalResistanceEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["101062"],
            heroClass: .knight
        )
        expect(
            abs(elementalResistanceEffects.passiveAllElementalResistance - 0.30) < 0.0001,
            "unlocked Knight passives expose all-elemental-resistance runtime hooks"
        )

        let skillRangeEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["101081"],
            heroClass: .knight
        )
        expect(
            abs(skillRangeEffects.passiveSkillRangeExpansion - 0.30) < 0.0001,
            "unlocked Knight passives expose skill-range expansion runtime hooks"
        )

        let areaEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["101082"],
            heroClass: .knight
        )
        expect(
            abs(areaEffects.passiveAreaOfEffect - 0.50) < 0.0001,
            "unlocked Knight passives expose area-of-effect runtime hooks"
        )

        let ranger = Hero()
        ranger.changeClass(to: .ranger)
        ranger.unlockedPassiveSkillIDs = [
            "201011", // passiveCriticalChance
            "201012"  // passiveCriticalDamage
        ]
        expect(
            abs(ranger.critRate - 0.06) < 0.0001,
            "unlocked Ranger passive CriticalChance changes runtime crit rate"
        )
        expect(
            abs(ranger.critDamage - 2.8) < 0.0001,
            "unlocked Ranger passive CriticalDamage changes runtime crit damage"
        )

        let sustainEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["101012", "101021", "101051"],
            heroClass: .knight
        )
        expect(
            sustainEffects.passiveHpRegenPerSec == 100 &&
                sustainEffects.passiveAddHpPerKill == 8 &&
                sustainEffects.passiveAddHpPerHit == 0,
            "unlocked Knight sustain passives expose regen and kill-heal runtime hooks"
        )

        let dodgeEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["201021", "201031", "201041", "201081"],
            heroClass: .ranger
        )
        expect(
            abs(dodgeEffects.passiveDodgeChance - 0.006) < 0.0001 &&
                abs(dodgeEffects.passiveElementalDodgeChance - 0.003) < 0.0001 &&
                abs(dodgeEffects.passiveMaxDodgeChance - 0.001) < 0.0001,
            "unlocked Ranger passives expose dodge chance, elemental dodge chance and max dodge cap runtime hooks"
        )

        let sorcererEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["301002", "301021", "301022", "301031", "301041"],
            heroClass: .sorcerer
        )
        expect(
            abs(sorcererEffects.passiveCooldownReduction - 0.30) < 0.0001 &&
                abs(sorcererEffects.passiveFireDamagePercent - 1.0) < 0.0001 &&
                abs(sorcererEffects.passiveColdDamagePercent - 1.0) < 0.0001 &&
                abs(sorcererEffects.passiveLightningDamagePercent - 1.0) < 0.0001,
            "unlocked Sorcerer passives expose cooldown and elemental damage runtime hooks"
        )

        let castSpeedEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["301051", "301082"],
            heroClass: .sorcerer
        )
        expect(
            abs(castSpeedEffects.passiveCastSpeed - 1.40) < 0.0001,
            "unlocked Sorcerer passives expose cast-speed runtime hooks"
        )

        let rangerEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["201022", "201052", "201061"],
            heroClass: .ranger
        )
        expect(
            abs(rangerEffects.passiveIncreaseProjectileDamage - 1.5) < 0.0001 &&
                abs(rangerEffects.passiveHpLeech - 0.05) < 0.0001 &&
                abs(rangerEffects.passiveIncreaseAreaOfEffectDamage - 1.5) < 0.0001,
            "unlocked Ranger passives expose projectile, life-leech and area-damage runtime hooks"
        )

        let priestEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["401012", "401022", "401032", "401061"],
            heroClass: .priest
        )
        expect(
            priestEffects.passiveDamageAbsorption == 10 &&
                abs(priestEffects.passiveSkillHealIncrease - 0.7) < 0.0001 &&
                abs(priestEffects.passiveCooldownReduction - 0.2) < 0.0001,
            "unlocked Priest passives expose damage absorption, healing and cooldown runtime hooks"
        )

        let priestCastEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["401041", "401072"],
            heroClass: .priest
        )
        expect(
            abs(priestCastEffects.passiveCastSpeed - 1.40) < 0.0001,
            "unlocked Priest passives expose cast-speed runtime hooks"
        )

        let slayerEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["601051", "601072"],
            heroClass: .slayer
        )
        expect(
            abs(slayerEffects.passiveIncreaseAreaOfEffectDamage - 1.5) < 0.0001 &&
                abs(slayerEffects.passiveSkillDurationIncrease - 0.8) < 0.0001,
            "unlocked Slayer passives expose area-damage and duration runtime hooks"
        )

        let movementEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["201042", "201082"],
            heroClass: .ranger
        )
        let movementHero = Hero()
        movementHero.changeClass(to: .ranger)
        movementHero.unlockedPassiveSkillIDs = ["201042", "201082"]
        expect(
            movementEffects.passiveMovementSpeed == 40 &&
                abs(movementEffects.passiveMovementSpeedMultiplier - 1.0) < 0.0001 &&
                movementHero.speed == 50,
            "unlocked Ranger flat movement-speed passives feed the runtime speed scalar"
        )

        let slayerMovementEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["601062"],
            heroClass: .slayer
        )
        let slayerMovementHero = Hero()
        slayerMovementHero.changeClass(to: .slayer)
        slayerMovementHero.unlockedPassiveSkillIDs = ["601062"]
        expect(
            slayerMovementEffects.passiveMovementSpeed == 0 &&
                abs(slayerMovementEffects.passiveMovementSpeedMultiplier - 1.20) < 0.0001 &&
                slayerMovementHero.speed == 9,
            "unlocked Slayer additive movement-speed passive feeds the runtime speed multiplier"
        )

        let leechHero = Hero()
        leechHero.changeClass(to: .ranger)
        leechHero.unlockedPassiveSkillIDs = ["201052"]
        _ = leechHero.equipment.equip(Item(
            id: "leech-bow",
            name: "吸血测试弓",
            rarity: .common,
            slot: .weapon,
            stats: ItemStats(bonusATK: 1_000),
            description: "",
            equipmentType: .bow
        ))
        leechHero.takeDamage(80)
        let woundedHP = leechHero.currentHP
        let leechBattle = Battle(
            hero: leechHero,
            monster: Monster(
                id: "leech-dummy",
                name: "吸血测试目标",
                hp: 10_000,
                atk: 0,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            ),
            party: HeroParty(primaryClass: .ranger),
            activeSkillSlotCount: 1
        )
        leechBattle.update(deltaTime: 1)
        expect(
            leechHero.currentHP > woundedHP && leechBattle.heroHP == leechHero.currentHP,
            "unlocked HpLeech passive heals the main hero from actual hero damage dealt"
        )
        expect(
            leechBattle.log.contains {
                $0.attacker == .hero &&
                    $0.skillName == "生命汲取" &&
                    $0.kind == .heal &&
                    $0.damage > 0
            },
            "unlocked HpLeech passive records visible live battle healing"
        )

        let regenHero = Hero()
        regenHero.unlockedPassiveSkillIDs = ["101012"]
        regenHero.takeDamage(80)
        var regenLoadouts = ActiveSkillLoadouts()
        regenLoadouts.setSkill("10601", for: .knight, slotIndex: 0)
        let regenBattle = Battle(
            hero: regenHero,
            monster: Monster(
                id: "passive-regen-dummy",
                name: "生命恢复测试目标",
                hp: 10_000,
                atk: 0,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            ),
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: regenLoadouts
        )
        regenBattle.update(deltaTime: 0.2)

        let hitHealHero = Hero()
        hitHealHero.changeClass(to: .hunter)
        hitHealHero.unlockedPassiveSkillIDs = ["501072"]
        hitHealHero.takeDamage(20)
        var hitHealLoadouts = ActiveSkillLoadouts()
        hitHealLoadouts.setSkill("50301", for: .hunter, slotIndex: 0)
        let hitHealBattle = Battle(
            hero: hitHealHero,
            monster: Monster(
                id: "passive-hit-heal-dummy",
                name: "击中回复测试目标",
                hp: 10_000,
                atk: 0,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            ),
            party: HeroParty(primaryClass: .hunter),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: hitHealLoadouts
        )
        hitHealBattle.update(deltaTime: 1)

        let killHealHero = Hero()
        killHealHero.unlockedPassiveSkillIDs = ["101021", "101051"]
        killHealHero.takeDamage(20)
        let killHealBattle = Battle(
            hero: killHealHero,
            monster: Monster(
                id: "passive-kill-heal-dummy",
                name: "击杀回复测试目标",
                hp: 1,
                atk: 0,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            ),
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: regenLoadouts
        )
        killHealBattle.update(deltaTime: 1)

        expect(
            regenBattle.log.contains {
                $0.attacker == .hero &&
                    $0.skillName == "生命恢复" &&
                    $0.kind == .heal &&
                    $0.damage > 0
            } &&
                hitHealBattle.log.contains {
                    $0.attacker == .hero &&
                        $0.skillName == "击中回复" &&
                        $0.kind == .heal &&
                        $0.damage > 0
                } &&
                killHealBattle.log.contains {
                    $0.attacker == .hero &&
                        $0.skillName == "击杀回复" &&
                        $0.kind == .heal &&
                        $0.damage > 0
                } &&
                regenBattle.heroHP == regenHero.currentHP &&
                hitHealBattle.heroHP == hitHealHero.currentHP &&
                killHealBattle.heroHP == killHealHero.currentHP,
            "HpRegenPerSec, AddHpPerHit and AddHpPerKill passives record visible live battle healing"
        )

        expect(
            Battle.modifiedIncomingDamage(
                200,
                continuousIncomingDamageMultiplier: 1.0,
                passiveDamageReduction: 0.25,
                passiveDamageAbsorption: 10
            ) == 140,
            "unlocked DamageAbsorption passive reduces incoming damage after percent mitigation"
        )

        expect(
            Battle.modifiedIncomingDamage(
                200,
                continuousIncomingDamageMultiplier: 1.0,
                passiveDamageReduction: 0.25,
                passiveDamageAbsorption: 10,
                passiveAllElementalResistance: 0.20,
                damageElement: .fire
            ) == 110 &&
                Battle.modifiedIncomingDamage(
                    200,
                    continuousIncomingDamageMultiplier: 1.0,
                    passiveDamageReduction: 0.25,
                    passiveDamageAbsorption: 10,
                    passiveAllElementalResistance: 0.20,
                    damageElement: .cold
                ) == 110 &&
                Battle.modifiedIncomingDamage(
                    200,
                    continuousIncomingDamageMultiplier: 1.0,
                    passiveDamageReduction: 0.25,
                    passiveDamageAbsorption: 10,
                    passiveAllElementalResistance: 0.20,
                    damageElement: .lightning
                ) == 110 &&
                Battle.modifiedIncomingDamage(
                    200,
                    continuousIncomingDamageMultiplier: 1.0,
                    passiveDamageReduction: 0.25,
                    passiveDamageAbsorption: 10,
                    passiveAllElementalResistance: 0.20,
                    damageElement: .physical
                ) == 140 &&
                Battle.modifiedIncomingDamage(
                    200,
                    continuousIncomingDamageMultiplier: 1.0,
                    passiveDamageReduction: 0.25,
                    passiveDamageAbsorption: 10,
                    passiveAllElementalResistance: 0.20,
                    damageElement: .chaos
                ) == 140 &&
                Battle.modifiedIncomingDamage(
                    200,
                    continuousIncomingDamageMultiplier: 0.9,
                    passiveDamageReduction: 0.25,
                    passiveDamageAbsorption: 10,
                    passiveAllElementalResistance: 0.20,
                    damageElement: .fire
                ) == 98 &&
                Battle.modifiedIncomingDamage(
                    200,
                    continuousIncomingDamageMultiplier: 0.9,
                    passiveDamageReduction: 0.25,
                    passiveDamageAbsorption: 10,
                    passiveAllElementalResistance: 0.20,
                    damageElement: .physical
                ) == 140,
            "unlocked AllElementalResistance and Warding Blessing reduce only fire, cold and lightning incoming damage"
        )

        func monsterHit(sourceSkillID: String) -> BattleLogEntry? {
            let hero = Hero()
            hero.unlockedPassiveSkillIDs = ["101062"]
            let monster = Monster(
                id: "source-\(sourceSkillID)",
                name: sourceSkillID == "301015" ? "燃烧的地狱祭司" : "混沌的地狱祭司",
                hp: 100_000,
                atk: 400,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 1,
                goldReward: 1,
                lootTableID: "none",
                sourceSkillID: sourceSkillID
            )
            let battle = Battle(
                hero: hero,
                monster: monster,
                party: HeroParty(primaryClass: .knight),
                activeSkillSlotCount: 1
            )
            battle.update(deltaTime: 0.01)
            return battle.log.last { $0.attacker == .monster }
        }

        let fireMonsterHit = monsterHit(sourceSkillID: "301015")
        let chaosMonsterHit = monsterHit(sourceSkillID: "301045")
        expect(
            fireMonsterHit?.damageElement == .fire &&
                chaosMonsterHit?.damageElement == .chaos &&
                fireMonsterHit?.attackerName == "燃烧的地狱祭司" &&
                fireMonsterHit?.attackerDisplayName == "燃烧的地狱祭司" &&
                chaosMonsterHit?.attackerName == "混沌的地狱祭司" &&
                (fireMonsterHit?.damage ?? 0) > 0 &&
                (chaosMonsterHit?.damage ?? 0) > 0 &&
                (fireMonsterHit?.damage ?? Int.max) < (chaosMonsterHit?.damage ?? 0),
            "monster source attack elements feed battle log names, metadata and incoming elemental resistance"
        )

        expect(
            Battle.incomingAttackWasDodged(roll: 0.005, passiveDodgeChance: 0.006) &&
                !Battle.incomingAttackWasDodged(roll: 0.006, passiveDodgeChance: 0.006) &&
                Battle.incomingAttackWasDodged(roll: 0.79, passiveDodgeChance: 2.0) &&
                !Battle.incomingAttackWasDodged(roll: 0.81, passiveDodgeChance: 2.0) &&
                Battle.incomingAttackWasDodged(
                    roll: 0.8005,
                    passiveDodgeChance: 2.0,
                    passiveMaxDodgeChance: 0.001
                ) &&
                !Battle.incomingAttackWasDodged(
                    roll: 0.8015,
                    passiveDodgeChance: 2.0,
                    passiveMaxDodgeChance: 0.001
                ) &&
                Battle.incomingAttackWasDodged(
                    roll: 0.008,
                    passiveDodgeChance: 0.006,
                    passiveElementalDodgeChance: 0.003,
                    damageElement: .fire
                ) &&
                Battle.incomingAttackWasDodged(
                    roll: 0.008,
                    passiveDodgeChance: 0.006,
                    passiveElementalDodgeChance: 0.003,
                    damageElement: .cold
                ) &&
                Battle.incomingAttackWasDodged(
                    roll: 0.008,
                    passiveDodgeChance: 0.006,
                    passiveElementalDodgeChance: 0.003,
                    damageElement: .lightning
                ) &&
                !Battle.incomingAttackWasDodged(
                    roll: 0.008,
                    passiveDodgeChance: 0.006,
                    passiveElementalDodgeChance: 0.003,
                    damageElement: .physical
                ) &&
                !Battle.incomingAttackWasDodged(
                    roll: 0.008,
                    passiveDodgeChance: 0.006,
                    passiveElementalDodgeChance: 0.003,
                    damageElement: .chaos
                ),
            "unlocked DodgeChance passive can avoid incoming attacks before damage calculation, ElementalDodgeChance applies only to elemental damage and MaxDodgeChance raises its cap"
        )

        expect(
            Battle.incomingAttackWasBlocked(roll: 0.005, passiveBlockChance: 0.006) &&
                !Battle.incomingAttackWasBlocked(roll: 0.006, passiveBlockChance: 0.006) &&
                Battle.incomingAttackWasBlocked(roll: 0.79, passiveBlockChance: 2.0) &&
                !Battle.incomingAttackWasBlocked(roll: 0.81, passiveBlockChance: 2.0),
            "unlocked BlockChance passive can block incoming attacks before damage calculation"
        )

        func avoidedMonsterAttack(
            heroClass: HeroClass,
            passiveIDs: Set<String>,
            dodgeRoll: Double,
            blockRoll: Double,
            sourceSkillID: String? = nil
        ) -> (heroHP: Int, entry: BattleLogEntry?) {
            let hero = Hero()
            hero.changeClass(to: heroClass)
            hero.unlockedPassiveSkillIDs = passiveIDs
            let battle = Battle(
                hero: hero,
                monster: Monster(
                    id: "avoidance-runtime-attacker",
                    name: "规避测试攻击者",
                    hp: 100_000,
                    atk: 1_000,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none",
                    sourceSkillID: sourceSkillID
                ),
                party: HeroParty(primaryClass: heroClass),
                activeSkillSlotCount: 1,
                incomingDodgeRollProvider: { dodgeRoll },
                incomingBlockRollProvider: { blockRoll }
            )
            battle.update(deltaTime: 0.01)
            return (
                heroHP: battle.heroHP,
                entry: battle.log.last { $0.attacker == .monster }
            )
        }

        let dodgedAttack = avoidedMonsterAttack(
            heroClass: .ranger,
            passiveIDs: ["201021", "201031", "201041"],
            dodgeRoll: 0.008,
            blockRoll: 0.99,
            sourceSkillID: "301015"
        )
        let blockedAttack = avoidedMonsterAttack(
            heroClass: .knight,
            passiveIDs: ["101022", "101052"],
            dodgeRoll: 0.99,
            blockRoll: 0.005
        )
        expect(
            dodgedAttack.heroHP == HeroClass.ranger.baseStats.hp &&
                dodgedAttack.entry?.kind == .dodge &&
                dodgedAttack.entry?.damage == 0 &&
                dodgedAttack.entry?.damageElement == .fire &&
                dodgedAttack.entry?.attackerName == "规避测试攻击者" &&
                blockedAttack.heroHP == HeroClass.knight.baseStats.hp &&
                blockedAttack.entry?.kind == .block &&
                blockedAttack.entry?.damage == 0,
            "DodgeChance and BlockChance passives record visible live battle avoidance logs"
        )

        expect(
            abs(Battle.modifiedSkillCooldown(
                baseCooldown: 10,
                passiveCooldownReduction: 0.20,
                passiveCastSpeed: 0
            ) - 8.0) < 0.0001 &&
                abs(Battle.modifiedSkillCooldown(
                    baseCooldown: 10,
                    passiveCooldownReduction: 0.20,
                    passiveCastSpeed: 1.0
                ) - 4.0) < 0.0001 &&
                abs(Battle.modifiedSkillCooldown(
                    baseCooldown: 10,
                    passiveCooldownReduction: -0.20,
                    passiveCastSpeed: -1.0
                ) - 10.0) < 0.0001 &&
                Battle.modifiedSkillCooldown(
                    baseCooldown: 2,
                    passiveCooldownReduction: 0.80,
                    passiveCastSpeed: 2.0
                ) == 1,
            "unlocked CastSpeed passive shortens cooldown skill intervals within the current cooldown scaffold"
        )

        func fireballCastCount(passiveIDs: Set<String> = []) -> Int {
            let hero = Hero()
            hero.changeClass(to: .sorcerer)
            hero.unlockedPassiveSkillIDs = passiveIDs

            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkills(["30101"], for: .sorcerer)

            let battle = Battle(
                hero: hero,
                monster: Monster(
                    id: "cooldown-cast-speed-fireball-training",
                    name: "冷却施法训练木桩",
                    hp: 100_000_000,
                    atk: 0,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                ),
                party: HeroParty(primaryClass: .sorcerer),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            for _ in 0..<12 {
                battle.update(deltaTime: 1)
            }
            return battle.log.filter { $0.skillName == "火球术" && $0.kind == .damage }.count
        }

        let baselineFireballCastCount = fireballCastCount()
        let boostedFireballCastCount = fireballCastCount(passiveIDs: ["301002", "301041", "301051"])
        expect(
            baselineFireballCastCount > 0 && boostedFireballCastCount > baselineFireballCastCount,
            "Cooldown Reduction and Cast Speed passives increase Fireball's live cooldown cast count"
        )

        func typedSkillDamage(
            heroClass: HeroClass,
            skillID: String,
            skillName: String,
            passiveIDs: Set<String> = []
        ) -> Int {
            let hero = Hero()
            hero.changeClass(to: heroClass)
            hero.unlockedPassiveSkillIDs = passiveIDs
            _ = hero.equipment.equip(Item(
                id: "typed-damage-passive-crit-suppression-\(skillID)",
                name: "伤害类型测试护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusCritRate: -1.0),
                description: "测试用"
            ))

            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkill(skillID, for: heroClass, slotIndex: 0)

            let battle = Battle(
                hero: hero,
                monster: Monster(
                    id: "typed-damage-passive-training-\(skillID)",
                    name: "伤害类型训练木桩",
                    hp: 100_000_000,
                    atk: 0,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                ),
                party: HeroParty(primaryClass: heroClass),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )

            for _ in 0..<8 {
                battle.update(deltaTime: 1)
            }

            return battle.log
                .filter { $0.skillName == skillName && $0.kind == .damage }
                .map(\.damage)
                .reduce(0, +)
        }

        let baselineExplosiveBoltDamage = typedSkillDamage(heroClass: .hunter, skillID: "50101", skillName: "爆炸弩箭")
        let boostedExplosiveBoltDamage = typedSkillDamage(heroClass: .hunter, skillID: "50101", skillName: "爆炸弩箭", passiveIDs: ["501021"])
        let baselineFrostBoltDamage = typedSkillDamage(heroClass: .hunter, skillID: "50201", skillName: "寒霜弩箭")
        let boostedFrostBoltDamage = typedSkillDamage(heroClass: .hunter, skillID: "50201", skillName: "寒霜弩箭", passiveIDs: ["501022"])
        let baselineShockBoltDamage = typedSkillDamage(heroClass: .hunter, skillID: "50601", skillName: "电击弩箭")
        let boostedShockBoltDamage = typedSkillDamage(heroClass: .hunter, skillID: "50601", skillName: "电击弩箭", passiveIDs: ["501061"])
        let baselineSlamJumpDamage = typedSkillDamage(heroClass: .slayer, skillID: "60101", skillName: "猛击跳跃")
        let boostedSlamJumpDamage = typedSkillDamage(heroClass: .slayer, skillID: "60101", skillName: "猛击跳跃", passiveIDs: ["601021"])
        expect(
            baselineExplosiveBoltDamage > 0 &&
                boostedExplosiveBoltDamage > baselineExplosiveBoltDamage &&
                baselineFrostBoltDamage > 0 &&
                boostedFrostBoltDamage > baselineFrostBoltDamage &&
                baselineShockBoltDamage > 0 &&
                boostedShockBoltDamage > baselineShockBoltDamage &&
                baselineSlamJumpDamage > 0 &&
                boostedSlamJumpDamage > baselineSlamJumpDamage,
            "Physical, Fire, Cold and Lightning damage passives increase matching live skill damage logs"
        )
    }

    private static func runeTree() {
        print("[RuneTree]")
        var tree = RuneTree()
        expect(tree.unlockedPartySlotCount == 1, "Rune Tree starts with one party slot")
        expect(RuneTree.requiredHeroLevel == 3, "Rune Tree follows source level 3 unlock gate")
        expect(SourceRuneCatalog.all.count == 197, "source Rune Tree catalog preserves all checked 197 nodes")
        expect(SourceRuneCatalog.connectionCount == 195, "source Rune Tree catalog preserves all checked 195 next connections")
        expect(
            SourceRuneCatalog.nextOutDegreeDistribution == SourceRuneCatalog.expectedNextOutDegreeDistribution,
            "source Rune Tree catalog preserves the checked Next out-degree distribution"
        )
        expect(SourceRuneCatalog.previousReferenceCount == 11, "source Rune Tree catalog preserves the checked previous-node references")
        expect(
            SourceRuneCatalog.previousReferenceMap == SourceRuneCatalog.expectedPreviousReferenceMap,
            "source Rune Tree catalog preserves the checked sparse previous-node reference map"
        )
        expect(
            SourceRuneCatalog.maxLevelDistribution == SourceRuneCatalog.expectedMaxLevelDistribution,
            "source Rune Tree catalog preserves the checked max-level distribution"
        )
        expect(SourceRuneCatalog.duplicateIDs.isEmpty, "source Rune Tree catalog has no duplicate IDs")
        expect(SourceRuneCatalog.danglingNextIDs.isEmpty, "source Rune Tree catalog has no dangling next-node IDs")
        expect(SourceRuneCatalog.danglingPreviousIDs.isEmpty, "source Rune Tree catalog has no dangling previous-node IDs")
        expect(SourceRuneCatalog.iconNames.count == 39, "source Rune Tree catalog preserves the checked 39 rune icon families")
        expect(
            SourceRuneCatalog.iconDistribution == SourceRuneCatalog.expectedIconDistribution,
            "source Rune Tree catalog preserves the checked rune icon-family distribution"
        )
        expect(
            RuneTreeNode.allCases.allSatisfy { SourceRuneCatalog.byID[$0.sourceRuneID] != nil },
            "runtime Rune Tree nodes map back to checked source catalog IDs"
        )
        expect(
            SourceRuneCatalog.runtimeModeledNodes.count == RuneTreeNode.allCases.count &&
                SourceRuneCatalog.runtimeModeledNodes.count == 197,
            "Rune Tree runtime coverage remains explicit at all 197 checked source nodes"
        )
        expect(
            SourceRuneCatalog.runtimeUnmodeledNodes.count == SourceRuneCatalog.expectedNodeCount - RuneTreeNode.allCases.count,
            "Rune Tree keeps the currently data-only source nodes explicit"
        )
        expect(
                SourceRuneCatalog.runtimeModeledIconNames.count == 39 &&
                SourceRuneCatalog.runtimeUnmodeledOnlyIconNames.isEmpty &&
                SourceRuneCatalog.runtimeSharedModeledAndUnmodeledIconNames.isEmpty,
            "Rune Tree runtime coverage distinguishes modeled, data-only and shared source icon families"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamage1.sourceRuneID]?.enName == "Rune of War" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamage1.sourceRuneID]?.iconName == "AllHeroAttackDamage",
            "Rune of War runtime attack scaffold resolves to a checked source row"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamage4.sourceRuneID]?.enName == "Rune of War" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamage4.sourceRuneID]?.iconName == "AllHeroAttackDamage",
            "fourth Rune of War attack scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroArmor1.sourceRuneID]?.enName == "Rune of the Shield" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroArmor1.sourceRuneID]?.iconName == "AllHeroArmor",
            "Rune of the Shield runtime armor scaffold resolves to a checked source row"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroArmor3.sourceRuneID]?.enName == "Rune of the Shield" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroArmor3.sourceRuneID]?.iconName == "AllHeroArmor",
            "third Rune of the Shield armor scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroMoveSpeed1.sourceRuneID]?.enName == "Rune of the Gale" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroMoveSpeed1.sourceRuneID]?.iconName == "AllHeroMoveSpeed",
            "Rune of the Gale move-speed scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroMoveSpeed2.sourceRuneID]?.enName == "Rune of the Gale" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroMoveSpeed2.sourceRuneID]?.iconName == "AllHeroMoveSpeed",
            "second Rune of the Gale move-speed scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroMoveSpeed3.sourceRuneID]?.enName == "Rune of the Gale" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroMoveSpeed3.sourceRuneID]?.iconName == "AllHeroMoveSpeed",
            "third Rune of the Gale move-speed scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroMoveSpeed4.sourceRuneID]?.enName == "Rune of the Gale" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroMoveSpeed4.sourceRuneID]?.iconName == "AllHeroMoveSpeed",
            "fourth Rune of the Gale move-speed scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroMoveSpeed5.sourceRuneID]?.enName == "Rune of the Gale" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroMoveSpeed5.sourceRuneID]?.iconName == "AllHeroMoveSpeed",
            "fifth Rune of the Gale move-speed scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamagePercent1.sourceRuneID]?.enName == "Rune of War" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamagePercent1.sourceRuneID]?.iconName == "AllHeroAttackDamagePercent",
            "Rune of War percent attack scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroArmorPercent1.sourceRuneID]?.enName == "Rune of the Shield" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroArmorPercent1.sourceRuneID]?.iconName == "AllHeroArmorPercent",
            "Rune of the Shield percent armor scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamagePercent2.sourceRuneID]?.enName == "Rune of War" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamagePercent2.sourceRuneID]?.iconName == "AllHeroAttackDamagePercent",
            "second Rune of War percent attack scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamagePercent3.sourceRuneID]?.enName == "Rune of War" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamagePercent3.sourceRuneID]?.iconName == "AllHeroAttackDamagePercent",
            "third Rune of War percent attack scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.partySlot2.sourceRuneID]?.enName == "Rune of Command" &&
                SourceRuneCatalog.byID[RuneTreeNode.partySlot3.sourceRuneID]?.enName == "Rune of Command" &&
                SourceRuneCatalog.byID[RuneTreeNode.activeSkillSlot2.sourceRuneID]?.enName == "Rune of Awakening",
            "formation and active-skill runtime runes resolve to checked source rows"
        )
        expect(
            RuneTree.combatGoldBoostNodes.allSatisfy {
                SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Wealth" &&
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "IncreaseGoldAmount"
            } &&
                RuneTree.combatXPBoostNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Growth" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "IncreaseExpAmount"
                } &&
                RuneTree.additionalGoldBoostNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Wealth" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "AdditionalGold"
                } &&
                RuneTree.additionalGoldNormalMonsterNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Wealth" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "AdditionalGoldNormalMonster"
                } &&
                RuneTree.additionalGoldStageBossNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Wealth" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "AdditionalGoldStageBoss"
                } &&
                RuneTree.additionalGoldActBossNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Wealth" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "AdditionalGoldActBoss"
                } &&
                RuneTree.additionalXPBoostNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Growth" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "AdditionalExp"
                } &&
                RuneTree.additionalXPNormalMonsterNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Growth" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "AdditionalExpNormalMonster"
                } &&
                RuneTree.additionalXPStageBossNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Growth" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "AdditionalExpStageBoss"
                } &&
                RuneTree.additionalXPActBossNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Growth" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "AdditionalExpActBoss"
                },
            "combat reward runtime runes resolve to checked Wealth and Growth source rows"
        )
        expect(
            RuneTree.cubeXPBoostNodes.allSatisfy {
                SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Forging" &&
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "CubeExpPercent"
            } &&
                RuneTree.alchemyGoldBoostNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Alchemy" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "CubeAlchemyGoldPercent"
                },
            "Cube reward runtime runes resolve to all checked Forging and Alchemy source rows"
        )
        expect(
            RuneTree.inventoryExpansionNodes.allSatisfy {
                SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Expansion" &&
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "MaxInventorySlot"
            },
            "inventory expansion runtime runes resolve to all checked MaxInventorySlot source rows"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.stashPage1.sourceRuneID]?.enName == "Rune of Storage" &&
                SourceRuneCatalog.byID[RuneTreeNode.stashPage2.sourceRuneID]?.enName == "Rune of Storage" &&
                SourceRuneCatalog.byID[RuneTreeNode.stashPage3.sourceRuneID]?.enName == "Rune of Storage" &&
                SourceRuneCatalog.byID[RuneTreeNode.stashPage1.sourceRuneID]?.iconName == "UnlockStashPageCount" &&
                SourceRuneCatalog.byID[RuneTreeNode.stashPage2.sourceRuneID]?.iconName == "UnlockStashPageCount" &&
                SourceRuneCatalog.byID[RuneTreeNode.stashPage3.sourceRuneID]?.iconName == "UnlockStashPageCount",
            "storage page runtime runes resolve to checked UnlockStashPageCount source rows"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.waveCountReduction1.sourceRuneID]?.enName == "Rune of Brevity" &&
                SourceRuneCatalog.byID[RuneTreeNode.waveCountReduction1.sourceRuneID]?.iconName == "WaveCountReduction",
            "brevity runtime rune resolves to a checked WaveCountReduction source row"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.offlineRewards.sourceRuneID]?.iconName == "UnlockOfflineReward" &&
                RuneTree.offlineGoldBoostNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Hoarding" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "OfflineRewardGoldPercent"
                } &&
                RuneTree.offlineXPBoostNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Training" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "OfflineRewardExpPercent"
                },
            "offline runtime runes resolve to all checked Repose, Hoarding and Training source rows"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.openOneChestType.sourceRuneID]?.iconName == "OpenOneTypeChestAllAtOnce" &&
                SourceRuneCatalog.byID[RuneTreeNode.openAllChestTypes.sourceRuneID]?.iconName == "OpenAllTypeChestAllAtOnce" &&
                SourceRuneCatalog.byID[RuneTreeNode.autoOpenNormalChests.sourceRuneID]?.iconName == "UnlockAutoOpenNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.autoOpenStageBossChests.sourceRuneID]?.iconName == "UnlockAutoOpenStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.autoOpenActBossChests.sourceRuneID]?.iconName == "UnlockAutoOpenActBossChest",
            "chest-opening runtime runes resolve to checked source rows and icon families"
        )
        expect(
            RuneTree.normalChestDropChanceNodes.allSatisfy {
                SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Exploration" &&
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "DropChanceNormalChest"
            } &&
                RuneTree.stageBossChestDropChanceNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Conquest" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "DropChanceStageBossChest"
                },
            "chest drop chance runtime runes resolve to checked Exploration and Conquest source rows"
        )
        expect(
            RuneTree.normalChestAutoOpenSpeedNodes.allSatisfy {
                SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Lubrication" &&
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "ReduceAutoOpenNormalChestTime"
            } &&
                RuneTree.stageBossChestAutoOpenSpeedNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Lubrication" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "ReduceAutoOpenStageBossChestTime"
                } &&
                RuneTree.actBossChestAutoOpenSpeedNodes.allSatisfy {
                    SourceRuneCatalog.byID[$0.sourceRuneID]?.enName == "Rune of Lubrication" &&
                        SourceRuneCatalog.byID[$0.sourceRuneID]?.iconName == "ReduceAutoOpenActBossChestTime"
                },
            "auto-open speed runtime runes resolve to checked Lubrication source rows"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage2.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage3.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage4.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage5.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage6.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage7.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage8.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage9.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage10.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage11.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage12.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage13.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage14.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxNormalChestStorage15.sourceRuneID]?.iconName == "MaxAmountNormalChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage2.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage3.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage4.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage5.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage6.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage7.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage8.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage9.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage10.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage11.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage12.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxStageBossChestStorage13.sourceRuneID]?.iconName == "MaxAmountStageBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxActBossChestStorage.sourceRuneID]?.iconName == "MaxAmountActBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxActBossChestStorage2.sourceRuneID]?.iconName == "MaxAmountActBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxActBossChestStorage3.sourceRuneID]?.iconName == "MaxAmountActBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxActBossChestStorage4.sourceRuneID]?.iconName == "MaxAmountActBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxActBossChestStorage5.sourceRuneID]?.iconName == "MaxAmountActBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxActBossChestStorage6.sourceRuneID]?.iconName == "MaxAmountActBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxActBossChestStorage7.sourceRuneID]?.iconName == "MaxAmountActBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxActBossChestStorage8.sourceRuneID]?.iconName == "MaxAmountActBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxActBossChestStorage9.sourceRuneID]?.iconName == "MaxAmountActBossChest" &&
                SourceRuneCatalog.byID[RuneTreeNode.maxActBossChestStorage10.sourceRuneID]?.iconName == "MaxAmountActBossChest",
            "chest-capacity runtime runes resolve to checked source rows and icon families"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackSpeed1.sourceRuneID]?.enName == "Rune of Frenzy" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackSpeed1.sourceRuneID]?.iconName == "AllHeroAttackSpeed",
            "Rune of Frenzy attack-speed scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackSpeed2.sourceRuneID]?.enName == "Rune of Frenzy" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackSpeed2.sourceRuneID]?.iconName == "AllHeroAttackSpeed",
            "second Rune of Frenzy attack-speed scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackSpeed3.sourceRuneID]?.enName == "Rune of Frenzy" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackSpeed3.sourceRuneID]?.iconName == "AllHeroAttackSpeed",
            "third Rune of Frenzy attack-speed scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroArmor2.sourceRuneID]?.enName == "Rune of the Shield" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroArmor2.sourceRuneID]?.iconName == "AllHeroArmor",
            "second Rune of the Shield armor scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamage2.sourceRuneID]?.enName == "Rune of War" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamage2.sourceRuneID]?.iconName == "AllHeroAttackDamage",
            "second Rune of War attack scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamage3.sourceRuneID]?.enName == "Rune of War" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroAttackDamage3.sourceRuneID]?.iconName == "AllHeroAttackDamage",
            "third Rune of War attack scaffold resolves to a checked source row and icon family"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.allHeroArmorPercent2.sourceRuneID]?.enName == "Rune of the Shield" &&
                SourceRuneCatalog.byID[RuneTreeNode.allHeroArmorPercent2.sourceRuneID]?.iconName == "AllHeroArmorPercent",
            "second Rune of the Shield percent armor scaffold resolves to a checked source row and icon family"
        )
        expect(
            RuneTreeNode.partySlot2.goldCost == 50_000 &&
                RuneTreeNode.partySlot3.goldCost == 150_000,
            "Rune of Command party slots use checked gold costs"
        )
        expect(!RuneTreeNode.allHeroAttackDamage1.hasVerifiedGoldCost && RuneTreeNode.allHeroAttackDamage1.costText == "成本待核对", "Rune of War attack scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroAttackDamage1, heroLevel: 3, availableGold: 0) &&
                tree.allHeroAttackDamage == RuneTree.allHeroAttackDamageBonus,
            "Rune of War unlocks a checked all-hero attack scaffold"
        )
        expect(!RuneTreeNode.allHeroArmor1.hasVerifiedGoldCost && RuneTreeNode.allHeroArmor1.costText == "成本待核对", "Rune of the Shield armor scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroArmor1, heroLevel: 3, availableGold: 0) &&
                tree.allHeroArmor == RuneTree.allHeroArmorBonus,
            "Rune of the Shield unlocks a checked all-hero armor scaffold"
        )
        expect(!RuneTreeNode.allHeroMoveSpeed1.hasVerifiedGoldCost && RuneTreeNode.allHeroMoveSpeed1.costText == "成本待核对", "Rune of the Gale move-speed scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroMoveSpeed1, heroLevel: 3, availableGold: 0) &&
                tree.allHeroMoveSpeed == RuneTree.allHeroMoveSpeedBonus,
            "Rune of the Gale unlocks a checked all-hero move-speed scaffold"
        )
        expect(!RuneTreeNode.allHeroArmor3.hasVerifiedGoldCost && RuneTreeNode.allHeroArmor3.costText == "成本待核对", "third Rune of the Shield armor scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroArmor3, heroLevel: 3, availableGold: 0) &&
                tree.allHeroArmor == RuneTree.allHeroArmorBonus * 2,
            "third Rune of the Shield unlocks another checked all-hero armor scaffold"
        )
        expect(!RuneTreeNode.allHeroAttackDamage4.hasVerifiedGoldCost && RuneTreeNode.allHeroAttackDamage4.costText == "成本待核对", "fourth Rune of War attack scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroAttackDamage4, heroLevel: 3, availableGold: 0) &&
                tree.allHeroAttackDamage == RuneTree.allHeroAttackDamageBonus * 2,
            "fourth Rune of War unlocks another checked all-hero attack scaffold"
        )
        expect(
            !tree.unlock(.allHeroAttackDamagePercent1, heroLevel: 3, availableGold: 0),
            "Rune of War percent attack scaffold stays locked behind the checked fourth Rune of the Gale source edge"
        )
        expect(!RuneTreeNode.allHeroMoveSpeed4.hasVerifiedGoldCost && RuneTreeNode.allHeroMoveSpeed4.costText == "成本待核对", "fourth Rune of the Gale move-speed scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroMoveSpeed4, heroLevel: 3, availableGold: 0) &&
                tree.allHeroMoveSpeed == RuneTree.allHeroMoveSpeedBonus * 2,
            "fourth Rune of the Gale unlocks another checked all-hero move-speed scaffold"
        )
        expect(!RuneTreeNode.allHeroMoveSpeed2.hasVerifiedGoldCost && RuneTreeNode.allHeroMoveSpeed2.costText == "成本待核对", "second Rune of the Gale move-speed scaffold cost remains explicitly unverified")
        expect(!RuneTreeNode.allHeroMoveSpeed3.hasVerifiedGoldCost && RuneTreeNode.allHeroMoveSpeed3.costText == "成本待核对", "third Rune of the Gale move-speed scaffold cost remains explicitly unverified")
        expect(!RuneTreeNode.allHeroAttackDamagePercent1.hasVerifiedGoldCost && RuneTreeNode.allHeroAttackDamagePercent1.costText == "成本待核对", "Rune of War percent attack scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroAttackDamagePercent1, heroLevel: 3, availableGold: 0) &&
                tree.allHeroAttackDamageMultiplier == 1.0 + RuneTree.allHeroAttackDamageMultiplierBonus,
            "Rune of War unlocks a checked all-hero percent attack scaffold"
        )
        expect(
            !tree.unlock(.allHeroArmorPercent1, heroLevel: 3, availableGold: 0) &&
                !tree.unlock(.allHeroAttackSpeed1, heroLevel: 3, availableGold: 0),
            "Rune of the Shield percent and Rune of Frenzy stay locked behind the checked fifth Rune of the Gale source edge"
        )
        expect(!RuneTreeNode.allHeroMoveSpeed5.hasVerifiedGoldCost && RuneTreeNode.allHeroMoveSpeed5.costText == "成本待核对", "fifth Rune of the Gale move-speed scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroMoveSpeed5, heroLevel: 3, availableGold: 0) &&
                tree.allHeroMoveSpeed == RuneTree.allHeroMoveSpeedBonus * 3,
            "fifth Rune of the Gale unlocks another checked all-hero move-speed scaffold"
        )
        expect(!RuneTreeNode.allHeroArmorPercent1.hasVerifiedGoldCost && RuneTreeNode.allHeroArmorPercent1.costText == "成本待核对", "Rune of the Shield percent armor scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroArmorPercent1, heroLevel: 3, availableGold: 0) &&
                tree.allHeroArmorMultiplier == 1.0 + RuneTree.allHeroArmorMultiplierBonus,
            "Rune of the Shield unlocks a checked all-hero percent armor scaffold"
        )
        expect(!RuneTreeNode.allHeroAttackDamagePercent2.hasVerifiedGoldCost && RuneTreeNode.allHeroAttackDamagePercent2.costText == "成本待核对", "second Rune of War percent attack scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroAttackDamagePercent2, heroLevel: 3, availableGold: 0) &&
                tree.allHeroAttackDamageMultiplier == 1.0 + RuneTree.allHeroAttackDamageMultiplierBonus * 2.0,
            "second Rune of War unlocks another checked all-hero percent attack scaffold"
        )
        expect(!RuneTreeNode.allHeroAttackSpeed1.hasVerifiedGoldCost && RuneTreeNode.allHeroAttackSpeed1.costText == "成本待核对", "Rune of Frenzy attack-speed scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroAttackSpeed1, heroLevel: 3, availableGold: 0) &&
                tree.allHeroAttackSpeedMultiplier == 1.0 + RuneTree.allHeroAttackSpeedMultiplierBonus,
            "Rune of Frenzy unlocks a checked all-hero attack-speed scaffold"
        )
        expect(!RuneTreeNode.allHeroAttackSpeed2.hasVerifiedGoldCost && RuneTreeNode.allHeroAttackSpeed2.costText == "成本待核对", "second Rune of Frenzy attack-speed scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroAttackSpeed2, heroLevel: 3, availableGold: 0) &&
                tree.allHeroAttackSpeedMultiplier == 1.0 + RuneTree.allHeroAttackSpeedMultiplierBonus * 2.0,
            "second Rune of Frenzy unlocks another checked all-hero attack-speed scaffold"
        )
        expect(!RuneTreeNode.allHeroArmor2.hasVerifiedGoldCost && RuneTreeNode.allHeroArmor2.costText == "成本待核对", "second Rune of the Shield armor scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroArmor2, heroLevel: 3, availableGold: 0) &&
                tree.allHeroArmor == RuneTree.allHeroArmorBonus * 3,
            "second Rune of the Shield unlocks another checked all-hero armor scaffold"
        )
        expect(!RuneTreeNode.allHeroAttackDamage2.hasVerifiedGoldCost && RuneTreeNode.allHeroAttackDamage2.costText == "成本待核对", "second Rune of War attack scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroAttackDamage2, heroLevel: 3, availableGold: 0) &&
                tree.allHeroAttackDamage == RuneTree.allHeroAttackDamageBonus * 3,
            "second Rune of War unlocks another checked all-hero attack scaffold"
        )
        expect(!RuneTreeNode.allHeroAttackDamage3.hasVerifiedGoldCost && RuneTreeNode.allHeroAttackDamage3.costText == "成本待核对", "third Rune of War attack scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroAttackDamage3, heroLevel: 3, availableGold: 0) &&
                tree.allHeroAttackDamage == RuneTree.allHeroAttackDamageBonus * 4,
            "third Rune of War unlocks another checked all-hero attack scaffold"
        )
        expect(
            tree.unlock(.allHeroMoveSpeed2, heroLevel: 3, availableGold: 0) &&
                tree.allHeroMoveSpeed == RuneTree.allHeroMoveSpeedBonus * 4,
            "second Rune of the Gale unlocks another checked all-hero move-speed scaffold"
        )
        expect(
            tree.unlock(.allHeroMoveSpeed3, heroLevel: 3, availableGold: 0) &&
                tree.allHeroMoveSpeed == RuneTree.allHeroMoveSpeedBonus * 5,
            "third Rune of the Gale unlocks another checked all-hero move-speed scaffold"
        )
        expect(!RuneTreeNode.allHeroArmorPercent2.hasVerifiedGoldCost && RuneTreeNode.allHeroArmorPercent2.costText == "成本待核对", "second Rune of the Shield percent armor scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroArmorPercent2, heroLevel: 3, availableGold: 0) &&
                tree.allHeroArmorMultiplier == 1.0 + RuneTree.allHeroArmorMultiplierBonus * 2.0,
            "second Rune of the Shield unlocks another checked all-hero percent armor scaffold"
        )
        expect(!RuneTreeNode.allHeroAttackDamagePercent3.hasVerifiedGoldCost && RuneTreeNode.allHeroAttackDamagePercent3.costText == "成本待核对", "third Rune of War percent attack scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroAttackDamagePercent3, heroLevel: 3, availableGold: 0) &&
                tree.allHeroAttackDamageMultiplier == 1.0 + RuneTree.allHeroAttackDamageMultiplierBonus * 3.0,
            "third Rune of War unlocks another checked all-hero percent attack scaffold"
        )
        expect(!RuneTreeNode.allHeroAttackSpeed3.hasVerifiedGoldCost && RuneTreeNode.allHeroAttackSpeed3.costText == "成本待核对", "third Rune of Frenzy attack-speed scaffold cost remains explicitly unverified")
        expect(
            tree.unlock(.allHeroAttackSpeed3, heroLevel: 3, availableGold: 0) &&
                tree.allHeroAttackSpeedMultiplier == 1.0 + RuneTree.allHeroAttackSpeedMultiplierBonus * 3.0,
            "third Rune of Frenzy unlocks another checked all-hero attack-speed scaffold"
        )
        expect(RuneTree.cubeXPBoostNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" }, "Rune of Forging Cube XP scaffold costs remain explicitly unverified")
        expect(
            tree.unlock(.cubeXPBoost1, heroLevel: 3, availableGold: 0) &&
                tree.cubeExperienceMultiplier == 1.0 + RuneTree.cubeRewardMultiplierBonus,
            "Rune of Forging unlocks a checked Cube XP scaffold"
        )
        expect(RuneTree.alchemyGoldBoostNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" }, "Rune of Alchemy gold scaffold costs remain explicitly unverified")
        expect(
            tree.unlock(.alchemyGoldBoost1, heroLevel: 3, availableGold: 0) &&
                tree.alchemyGoldMultiplier == 1.0 + RuneTree.cubeRewardMultiplierBonus,
            "Rune of Alchemy unlocks a checked alchemy-gold scaffold"
        )
        expect(!tree.unlock(.cubeXPBoost2, heroLevel: 3, availableGold: 0), "second Rune of Forging stays locked behind its checked Alchemy source edge")
        expect(
            tree.unlock(.alchemyGoldBoost2, heroLevel: 3, availableGold: 0) &&
                tree.alchemyGoldMultiplier == 1.0 + RuneTree.cubeRewardMultiplierBonus * 2.0,
            "second Rune of Alchemy unlocks another checked alchemy-gold scaffold"
        )
        expect(!tree.unlock(.alchemyGoldBoost4, heroLevel: 3, availableGold: 0), "fourth Rune of Alchemy stays locked behind its checked Forging source edge")
        expect(
            tree.unlock(.cubeXPBoost2, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.cubeXPBoost3, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.cubeXPBoost4, heroLevel: 3, availableGold: 0) &&
                tree.cubeExperienceMultiplier == 1.0 + RuneTree.cubeRewardMultiplierBonus * 4.0,
            "all checked Rune of Forging rows stack Cube XP scaffolds"
        )
        expect(
            tree.unlock(.alchemyGoldBoost3, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.alchemyGoldBoost4, heroLevel: 3, availableGold: 0) &&
                tree.alchemyGoldMultiplier == 1.0 + RuneTree.cubeRewardMultiplierBonus * 4.0,
            "all checked Rune of Alchemy rows stack alchemy-gold scaffolds"
        )
        expect(!tree.canUnlock(.partySlot2, heroLevel: 2, availableGold: 50_000), "second party slot requires hero level 3")
        expect(!tree.canUnlock(.partySlot2, heroLevel: 3, availableGold: 49_999), "second party slot requires 50,000 gold")
        expect(tree.unlock(.partySlot2, heroLevel: 3, availableGold: 50_000) && tree.unlockedPartySlotCount == 2, "second party slot unlocks through Rune of Command")
        expect(!tree.canUnlock(.partySlot3, heroLevel: 3, availableGold: 149_999), "third party slot requires 150,000 gold")
        expect(tree.unlock(.partySlot3, heroLevel: 3, availableGold: 150_000) && tree.unlockedPartySlotCount == 3, "third party slot unlocks after prerequisite")

        var directPartyTree = RuneTree()
        expect(directPartyTree.directPartySlotUnlockCost(for: 1) == 50_000, "direct party slot unlock exposes the checked slot-2 cost")
        expect(directPartyTree.directPartySlotUnlockCost(for: 2) == 200_000, "direct party slot 3 unlock includes locked prerequisite slot cost")
        expect(!directPartyTree.canDirectlyUnlockPartySlot(2, availableGold: 199_999), "direct party slot unlock still requires enough checked formation gold")
        expect(
            directPartyTree.directlyUnlockPartySlot(2, availableGold: 200_000) == 200_000 &&
                directPartyTree.unlockedPartySlotCount == 3,
            "direct party slot unlock can open positions 2 and 3 without the Rune Tree level gate"
        )

        expect(tree.activeSkillSlotCount == 1, "Rune Tree starts with one active skill slot")
        expect(
            !RuneTreeNode.activeSkillSlot2.hasVerifiedGoldCost &&
                RuneTreeNode.activeSkillSlot2.approximateGoldCost == 50_000 &&
                RuneTreeNode.activeSkillSlot2.approximateGoldCostSourceText == "官方符文分支：2nd Active Skill Slot (~50,000g)" &&
                RuneTreeNode.activeSkillSlot2.costText == "约 50,000 G（待核对）",
            "Rune of Awakening active skill slot keeps approximate cost separate from verified costs"
        )
        expect(!tree.canUnlock(.activeSkillSlot2, heroLevel: 2, availableGold: 0), "Rune of Awakening follows the level 3 Rune Tree gate")
        expect(tree.unlock(.activeSkillSlot2, heroLevel: 3, availableGold: 0) && tree.activeSkillSlotCount == 2, "Rune of Awakening unlocks the second active skill slot")
        expect(!tree.canUnlock(.openAllChestTypes, heroLevel: 3, availableGold: 0), "open-all chest rune requires the modeled open-one prerequisite")
        expect(
            tree.unlock(.openOneChestType, heroLevel: 3, availableGold: 0) &&
                tree.canOpenOneChestTypeAtOnce,
            "Rune of Opening unlocks one-type batch chest opening without inventing a gold cost"
        )
        expect(
            tree.unlock(.openAllChestTypes, heroLevel: 3, availableGold: 0) &&
                tree.canOpenAllChestTypesAtOnce,
            "Rune of Opening unlocks all-type batch chest opening after the modeled prerequisite"
        )
        expect(
            tree.unlock(.autoOpenNormalChests, heroLevel: 3, availableGold: 0) &&
                tree.canAutoOpenNormalChests,
            "Rune of the Mainspring unlocks source-backed automatic Normal Monster chest cooldown"
        )
        expect(
            tree.unlock(.autoOpenStageBossChests, heroLevel: 3, availableGold: 0) &&
                tree.canAutoOpenStageBossChests,
            "Rune of the Mainspring unlocks source-backed automatic Stage Boss chest cooldown"
        )
        expect(
            tree.unlock(.autoOpenActBossChests, heroLevel: 3, availableGold: 0) &&
                tree.canAutoOpenActBossChests,
            "Rune of the Mainspring unlocks source-backed automatic Act Boss chest cooldown"
        )
        expect(
            RuneTree.normalChestDropChanceNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" } &&
                RuneTree.stageBossChestDropChanceNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" },
            "chest drop chance rune costs remain explicitly unverified"
        )
        var chestDropTree = RuneTree()
        for node in RuneTree.normalChestDropChanceNodes + RuneTree.stageBossChestDropChanceNodes {
            _ = chestDropTree.unlock(node, heroLevel: 3, availableGold: 0)
        }
        expect(
            chestDropTree.chestDropBonuses.normalMonsterChance == RuneTree.chestDropChanceBonus * Double(RuneTree.normalChestDropChanceNodes.count) &&
                chestDropTree.chestDropBonuses.stageBossChance == RuneTree.chestDropChanceBonus * Double(RuneTree.stageBossChestDropChanceNodes.count),
            "checked Exploration and Conquest rows stack local chest drop chance scaffolds"
        )
        expect(
            RuneTree.normalChestAutoOpenSpeedNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" } &&
                RuneTree.stageBossChestAutoOpenSpeedNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" } &&
                RuneTree.actBossChestAutoOpenSpeedNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" },
            "auto-open speed rune costs remain explicitly unverified"
        )
        var autoOpenSpeedTree = RuneTree()
        for node in RuneTree.normalChestAutoOpenSpeedNodes + RuneTree.stageBossChestAutoOpenSpeedNodes + RuneTree.actBossChestAutoOpenSpeedNodes {
            _ = autoOpenSpeedTree.unlock(node, heroLevel: 3, availableGold: 0)
        }
        let expectedNormalAutoOpenCooldown = RuneTree.normalChestAutoOpenBaseCooldown -
            RuneTree.normalChestAutoOpenCooldownReductionByNode.values.reduce(0, +)
        let expectedStageBossAutoOpenCooldown = RuneTree.stageBossChestAutoOpenBaseCooldown -
            RuneTree.stageBossChestAutoOpenCooldownReductionByNode.values.reduce(0, +)
        let expectedActBossAutoOpenCooldown = RuneTree.actBossChestAutoOpenBaseCooldown -
            RuneTree.actBossChestAutoOpenCooldownReductionByNode.values.reduce(0, +)
        expect(
            autoOpenSpeedTree.normalChestAutoOpenCooldown == expectedNormalAutoOpenCooldown &&
                autoOpenSpeedTree.stageBossChestAutoOpenCooldown == expectedStageBossAutoOpenCooldown &&
                autoOpenSpeedTree.actBossChestAutoOpenCooldown == expectedActBossAutoOpenCooldown,
            "checked Lubrication rows reduce source auto-open cooldown timers"
        )
        expect(
            tree.unlock(.maxNormalChestStorage, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage2, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage3, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage4, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage5, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage6, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage7, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage8, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage9, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage10, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage11, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage12, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage13, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage14, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxNormalChestStorage15, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage2, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage3, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage4, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage5, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage6, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage7, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage8, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage9, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage10, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage11, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage12, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxStageBossChestStorage13, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxActBossChestStorage, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxActBossChestStorage2, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxActBossChestStorage3, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxActBossChestStorage4, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxActBossChestStorage5, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxActBossChestStorage6, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxActBossChestStorage7, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxActBossChestStorage8, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxActBossChestStorage9, heroLevel: 3, availableGold: 0) &&
                tree.unlock(.maxActBossChestStorage10, heroLevel: 3, availableGold: 0) &&
                tree.chestStorageLimits.normalMonster == ChestStorageLimits.base.normalMonster + RuneTree.chestStorageCapacityBonus * 15 &&
                tree.chestStorageLimits.stageBoss == ChestStorageLimits.base.stageBoss + RuneTree.chestStorageCapacityBonus * 13 &&
                tree.chestStorageLimits.actBoss == ChestStorageLimits.base.actBoss + RuneTree.chestStorageCapacityBonus * 10,
            "source-backed chest-capacity runes raise local box family caps by the conservative scaffold increment"
        )
        expect(!RuneTreeNode.inventoryExpansion1.hasVerifiedGoldCost && RuneTreeNode.inventoryExpansion1.costText == "成本待核对", "Rune of Expansion inventory cost remains explicitly unverified")
        expect(
            RuneTree.inventoryExpansionNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" },
            "all Rune of Expansion inventory costs remain explicitly unverified"
        )
        expect(!RuneTreeNode.stashPage1.hasVerifiedGoldCost && RuneTreeNode.stashPage1.costText == "成本待核对", "Rune of Storage stash page cost remains explicitly unverified")
        expect(!RuneTreeNode.stashPage2.hasVerifiedGoldCost && RuneTreeNode.stashPage2.costText == "成本待核对", "second Rune of Storage stash page cost remains explicitly unverified")
        expect(!RuneTreeNode.stashPage3.hasVerifiedGoldCost && RuneTreeNode.stashPage3.costText == "成本待核对", "third Rune of Storage stash page cost remains explicitly unverified")
        expect(!RuneTreeNode.waveCountReduction1.hasVerifiedGoldCost && RuneTreeNode.waveCountReduction1.costText == "成本待核对", "Rune of Brevity wave-count cost remains explicitly unverified")
        var combatRewardTree = RuneTree()
        expect(!combatRewardTree.canUnlock(.combatXPBoost1, heroLevel: 3, availableGold: 0), "Rune of Growth combat XP boost requires the modeled Wealth prerequisite")
        expect(
            combatRewardTree.unlock(.combatGoldBoost1, heroLevel: 3, availableGold: 0) &&
                combatRewardTree.combatGoldMultiplier == 1.0 + RuneTree.combatRewardMultiplierBonus,
            "Rune of Wealth unlocks a checked source combat-gold reward scaffold"
        )
        expect(
            combatRewardTree.unlock(.combatXPBoost1, heroLevel: 3, availableGold: 0) &&
                combatRewardTree.combatXPMultiplier == 1.0 + RuneTree.combatRewardMultiplierBonus,
            "Rune of Growth unlocks a checked source combat-XP reward scaffold"
        )
        var unlockedRemainingCombatGoldRunes = true
        for node in RuneTree.combatGoldBoostNodes.dropFirst() {
            unlockedRemainingCombatGoldRunes = combatRewardTree.unlock(node, heroLevel: 3, availableGold: 0) && unlockedRemainingCombatGoldRunes
        }
        var unlockedRemainingCombatXPRunes = true
        for node in RuneTree.combatXPBoostNodes.dropFirst() {
            unlockedRemainingCombatXPRunes = combatRewardTree.unlock(node, heroLevel: 3, availableGold: 0) && unlockedRemainingCombatXPRunes
        }
        expect(
            unlockedRemainingCombatGoldRunes &&
                combatRewardTree.combatGoldMultiplier == 1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatGoldBoostNodes.count),
            "all checked Rune of Wealth IncreaseGoldAmount rows stack combat-gold reward scaffolds"
        )
        expect(
            unlockedRemainingCombatXPRunes &&
                combatRewardTree.combatXPMultiplier == 1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatXPBoostNodes.count),
            "all checked Rune of Growth IncreaseExpAmount rows stack combat-XP reward scaffolds"
        )
        for node in RuneTree.additionalGoldBoostNodes
            + RuneTree.additionalGoldNormalMonsterNodes
            + RuneTree.additionalGoldStageBossNodes
            + RuneTree.additionalGoldActBossNodes
            + RuneTree.additionalXPBoostNodes
            + RuneTree.additionalXPNormalMonsterNodes
            + RuneTree.additionalXPStageBossNodes
            + RuneTree.additionalXPActBossNodes {
            _ = combatRewardTree.unlock(node, heroLevel: 3, availableGold: 0)
        }
        expect(
            combatRewardTree.combatGoldMultiplier(for: .normalMonster) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatGoldBoostNodes.count + RuneTree.additionalGoldBoostNodes.count + RuneTree.additionalGoldNormalMonsterNodes.count) &&
                combatRewardTree.combatGoldMultiplier(for: .stageBoss) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatGoldBoostNodes.count + RuneTree.additionalGoldBoostNodes.count + RuneTree.additionalGoldStageBossNodes.count) &&
                combatRewardTree.combatGoldMultiplier(for: .actBoss) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatGoldBoostNodes.count + RuneTree.additionalGoldBoostNodes.count + RuneTree.additionalGoldActBossNodes.count),
            "checked AdditionalGold source rows stack by combat encounter family"
        )
        expect(
            combatRewardTree.combatXPMultiplier(for: .normalMonster) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatXPBoostNodes.count + RuneTree.additionalXPBoostNodes.count + RuneTree.additionalXPNormalMonsterNodes.count) &&
                combatRewardTree.combatXPMultiplier(for: .stageBoss) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatXPBoostNodes.count + RuneTree.additionalXPBoostNodes.count + RuneTree.additionalXPStageBossNodes.count) &&
                combatRewardTree.combatXPMultiplier(for: .actBoss) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatXPBoostNodes.count + RuneTree.additionalXPBoostNodes.count + RuneTree.additionalXPActBossNodes.count),
            "checked AdditionalExp source rows stack by combat encounter family"
        )
        var inventoryTree = RuneTree()
        expect(!inventoryTree.canUnlock(.inventoryExpansion1, heroLevel: 3, availableGold: 0), "Rune of Expansion inventory capacity requires the modeled party-slot prerequisite")
        expect(inventoryTree.unlock(.partySlot2, heroLevel: 3, availableGold: 50_000), "Rune of Expansion prerequisite can be unlocked first")
        expect(
            inventoryTree.unlock(.inventoryExpansion1, heroLevel: 3, availableGold: 0) &&
                inventoryTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus,
            "Rune of Expansion inventory scaffold increases backpack capacity"
        )
        expect(
            inventoryTree.unlock(.inventoryExpansion2, heroLevel: 3, availableGold: 0) &&
                inventoryTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * 2,
            "second Rune of Expansion inventory scaffold stacks another checked MaxInventorySlot source row"
        )
        var unlockedRemainingInventoryExpansions = true
        for node in RuneTree.inventoryExpansionNodes.dropFirst(2) {
            unlockedRemainingInventoryExpansions = inventoryTree.unlock(node, heroLevel: 3, availableGold: 0) && unlockedRemainingInventoryExpansions
        }
        expect(
            unlockedRemainingInventoryExpansions &&
                inventoryTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * RuneTree.inventoryExpansionNodes.count,
            "twenty-six Rune of Expansion inventory scaffolds cover the checked MaxInventorySlot source family"
        )
        expect(
            inventoryTree.unlock(.stashPage1, heroLevel: 3, availableGold: 0) &&
                inventoryTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * RuneTree.inventoryExpansionNodes.count + RuneTree.stashPageSlotBonus,
            "Rune of Storage unlocks a checked source stash-page capacity scaffold"
        )
        expect(
            inventoryTree.unlock(.stashPage2, heroLevel: 3, availableGold: 0) &&
                inventoryTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * RuneTree.inventoryExpansionNodes.count + RuneTree.stashPageSlotBonus * 2,
            "second Rune of Storage stacks another checked stash-page capacity scaffold"
        )
        expect(
            inventoryTree.unlock(.stashPage3, heroLevel: 3, availableGold: 0) &&
                inventoryTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * RuneTree.inventoryExpansionNodes.count + RuneTree.stashPageSlotBonus * 3,
            "third Rune of Storage completes the checked UnlockStashPageCount source-row scaffold"
        )
        var brevityTree = RuneTree()
        expect(
            brevityTree.unlock(.waveCountReduction1, heroLevel: 3, availableGold: 0) &&
                brevityTree.stageClearTargetReduction == RuneTree.stageClearTargetReductionBonus,
            "Rune of Brevity unlocks a checked source stage-clear target reduction scaffold"
        )
        expect(!RuneTreeNode.offlineRewards.hasVerifiedGoldCost && RuneTreeNode.offlineRewards.costText == "成本待核对", "Rune of Repose cost remains explicitly unverified")
        expect(!tree.canUnlock(.offlineRewards, heroLevel: 2, availableGold: 0), "Rune of Repose follows the level 3 Rune Tree gate")
        expect(tree.unlock(.offlineRewards, heroLevel: 3, availableGold: 0) && tree.offlineRewardsUnlocked, "Rune of Repose unlocks offline rewards without inventing a gold cost")
        expect(
            RuneTree.offlineGoldBoostNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" } &&
                RuneTree.offlineXPBoostNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" },
            "offline reward boost rune costs remain explicitly unverified"
        )
        var offlineBoostTree = RuneTree()
        expect(
            !offlineBoostTree.canUnlock(.offlineGoldBoost, heroLevel: 3, availableGold: 0) &&
                !offlineBoostTree.canUnlock(.offlineXPBoost, heroLevel: 3, availableGold: 0),
            "offline reward boost runes require Rune of Repose first"
        )
        expect(offlineBoostTree.unlock(.offlineRewards, heroLevel: 3, availableGold: 0), "Rune of Repose unlocks before boost runes")
        expect(offlineBoostTree.unlock(.offlineGoldBoost, heroLevel: 3, availableGold: 0), "Rune of Hoarding offline gold boost unlocks after Rune of Repose")
        expect(offlineBoostTree.unlock(.offlineXPBoost, heroLevel: 3, availableGold: 0), "Rune of Training offline XP boost unlocks after Rune of Repose")
        expect(!offlineBoostTree.unlock(.offlineXPBoost2, heroLevel: 3, availableGold: 0), "second Rune of Training stays locked behind its checked Hoarding source edge")
        expect(
            offlineBoostTree.unlock(.offlineGoldBoost2, heroLevel: 3, availableGold: 0) &&
                offlineBoostTree.unlock(.offlineGoldBoost3, heroLevel: 3, availableGold: 0) &&
                offlineBoostTree.unlock(.offlineGoldBoost4, heroLevel: 3, availableGold: 0) &&
                offlineBoostTree.unlock(.offlineGoldBoost5, heroLevel: 3, availableGold: 0),
            "all checked Rune of Hoarding offline-gold rows unlock after Rune of Repose"
        )
        expect(
            offlineBoostTree.unlock(.offlineXPBoost2, heroLevel: 3, availableGold: 0) &&
                offlineBoostTree.unlock(.offlineXPBoost3, heroLevel: 3, availableGold: 0) &&
                offlineBoostTree.unlock(.offlineXPBoost4, heroLevel: 3, availableGold: 0) &&
                offlineBoostTree.unlock(.offlineXPBoost5, heroLevel: 3, availableGold: 0),
            "all checked Rune of Training offline-XP rows unlock after their local gates"
        )
        expect(
            offlineBoostTree.offlineGoldMultiplier == 1.0 + 0.10 * 5.0 &&
                offlineBoostTree.offlineXPMultiplier == 1.0 + 0.10 * 5.0,
            "offline boost runes apply stacked checked +10% reward multipliers"
        )

        var resetTree = RuneTree(unlockedNodes: Set(RuneTreeNode.allCases))
        expect(resetTree.verifiedResetRefundGold == 200_000, "Rune Tree reset refund only includes checked gold costs")
        let resetRefund = resetTree.resetUnlockedNodes()
        expect(
            resetRefund == 200_000 &&
                resetTree.unlockedNodes.isEmpty &&
                resetTree.unlockedPartySlotCount == 1 &&
                resetTree.activeSkillSlotCount == 1 &&
                resetTree.allHeroAttackDamage == 0 &&
                resetTree.allHeroArmor == 0 &&
                resetTree.allHeroMoveSpeed == 0 &&
                resetTree.allHeroAttackDamageMultiplier == 1.0 &&
                resetTree.allHeroArmorMultiplier == 1.0 &&
                resetTree.allHeroAttackSpeedMultiplier == 1.0 &&
                resetTree.cubeExperienceMultiplier == 1.0 &&
                resetTree.alchemyGoldMultiplier == 1.0 &&
                resetTree.inventoryCapacity == Inventory.baseCapacity &&
                !resetTree.canAutoOpenNormalChests &&
                !resetTree.canAutoOpenStageBossChests &&
                !resetTree.canAutoOpenActBossChests &&
                resetTree.chestDropBonuses == .none &&
                resetTree.normalChestAutoOpenCooldown == RuneTree.normalChestAutoOpenBaseCooldown &&
                resetTree.stageBossChestAutoOpenCooldown == RuneTree.stageBossChestAutoOpenBaseCooldown &&
                resetTree.actBossChestAutoOpenCooldown == RuneTree.actBossChestAutoOpenBaseCooldown &&
                resetTree.chestStorageLimits == ChestStorageLimits.base &&
                !resetTree.offlineRewardsUnlocked,
            "Rune Tree reset clears unlocked nodes and returns checked formation gold"
        )
    }

    private static func damageCalculator() {
        print("[DamageCalculator]")
        let crit = DamageCalculator.calculateResult(attackerATK: 100, defenderDEF: 0, critRate: 1.0, critDamage: 2.0)
        expect(crit.isCrit, "critRate=1 always crits")
        expect(crit.amount >= 180 && crit.amount <= 220, "crit damage in ±10% range, got \(crit.amount)")

        let normal = DamageCalculator.calculateResult(attackerATK: 100, defenderDEF: 0, critRate: 0, critDamage: 2.0)
        expect(!normal.isCrit, "critRate=0 never crits")
        expect(normal.amount >= 90 && normal.amount <= 110, "normal damage in ±10% range, got \(normal.amount)")

        let floor = DamageCalculator.calculate(attackerATK: 1, defenderDEF: 9999, critRate: 0, critDamage: 1.5)
        expect(floor >= 1, "minimum damage is 1")
    }

    private static func progressTracker() {
        print("[ProgressTracker]")
        expect(StageDefinition.runtimeDataCount == 120, "stage runtime table covers 120 difficulty stages")
        expect(StageDefinition.stage(act: .forest, number: 2).clearTarget(for: .normal) == 22, "stage 1-2 uses mined kill count")
        expect(StageDefinition.stage(act: .forest, number: 1).clearTarget(for: .nightmare) == 200, "nightmare stage 1-1 uses mined kill count")
        let firstStageRuntime = StageDefinition.stage(act: .forest, number: 1).runtimeData(for: .normal)
        expect(
            firstStageRuntime.monsterComposition == [
                StageMonsterSpawn(name: "哥布林盗贼", count: 1, isStageLeader: true),
                StageMonsterSpawn(name: "史莱姆", count: 5, isStageLeader: false),
                StageMonsterSpawn(name: "哥布林", count: 5, isStageLeader: false)
            ],
            "stage 1101 monster composition matches drops tool"
        )
        let firstMonster = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal)
        expect(firstMonster.name == "哥布林盗贼" && firstMonster.hp == 470 && firstMonster.goldReward == 140 && firstMonster.xpReward == 155, "stage spawn uses mined monster HP and reward data")
        expect(firstMonster.atk == 10 && firstMonster.spd == 11, "stage spawn uses source monster ATK and attack-speed scalars")
        expect(firstMonster.id == "assassin_goblin" && GameArt.battleMonsterSpriteName(for: firstMonster.id) == "stage_monster_assassin_goblin", "stage monster uses exact bundled art")
        let firstStageSecondEncounter = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal, encounterIndex: 1)
        let firstStageSeventhEncounter = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal, encounterIndex: 6)
        let firstStageOverflowEncounter = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal, encounterIndex: 99)
        let firstStageOpeningState = StageDefinition.stage(act: .forest, number: 1).encounterState(for: .normal, encounterIndex: 0)
        let firstStageFinalState = StageDefinition.stage(act: .forest, number: 1).encounterState(for: .normal, encounterIndex: 9)
        expect(
            firstStageSecondEncounter.name == "史莱姆" &&
                firstStageSeventhEncounter.name == "哥布林" &&
                firstStageOverflowEncounter.name == "哥布林",
            "stage 1101 spawn selection follows monster composition by encounter index"
        )
        expect(
            firstStageSecondEncounter.atk == 10 &&
                firstStageSecondEncounter.spd == 4 &&
                firstStageSeventhEncounter.atk == 15 &&
                firstStageSeventhEncounter.spd == 5,
            "stage 1101 non-leader encounters use source monster ATK and attack-speed scalars"
        )
        expect(
            GameArt.battleMonsterSpriteName(for: firstStageSecondEncounter.id) == "official_monster_slime",
            "slime encounters use the clean transparent official slime sprite instead of the legacy battle UI crop"
        )
        expect(
            firstStageOpeningState.wave == 1 &&
                firstStageOpeningState.waveCount == 10 &&
                firstStageOpeningState.encounterNumber == 1 &&
                firstStageOpeningState.waveEncounterNumber == 1 &&
                firstStageOpeningState.waveEncounterTarget == 1 &&
                firstStageFinalState.wave == 10 &&
                firstStageFinalState.encounterNumber == 10 &&
                firstStageFinalState.waveEncounterNumber == 1,
            "stage encounter state maps mined waves and clear target"
        )
        expect(firstMonster.itemLevelCap == 1 && LootTable.itemLevel(for: firstMonster) == 1, "stage 1-1 monster drops use level 1 item cap")
        expect(SoulStoneKind.normal.materialID == 190_001 && SoulStoneKind.torment.rarity == .celestial, "Soul Stone material IDs and rarities match item database")

        let graveyardRuntime = StageDefinition.stage(act: .forest, number: 8).runtimeData(for: .normal)
        expect(
            graveyardRuntime.monsterComposition.map(\.name) == ["蝙蝠", "骷髅", "骷髅弓箭手", "骷髅战士"] &&
                graveyardRuntime.monsterComposition.map(\.count) == [24, 24, 17, 12],
            "stage 1108 monster composition matches drops tool"
        )
        let graveyardMonster = StageDefinition.stage(act: .forest, number: 8).spawnMonster(difficulty: .normal)
        expect(graveyardMonster.name == "蝙蝠" && graveyardMonster.hp == 3_235, "normal stage 1-8 uses mined HP and composition-selected monster")
        expect(graveyardMonster.itemLevelCap == 10 && LootTable.itemLevel(for: graveyardMonster) == 10, "normal stage 1-8 monster drops use level 10 item cap")
        let graveyardPlan = StageDefinition.stage(act: .forest, number: 8).encounterPlan(for: .normal)
        expect(
            graveyardPlan.clearTarget == 78 &&
                graveyardPlan.waveCount == 13 &&
                graveyardPlan.encounters.count == 78 &&
                graveyardPlan.encounters(inWave: 13).count == 6,
            "stage encounter plan exposes mined wave boundaries"
        )
        let curseStageScaledEncounter = StageDefinition.stage(act: .forest, number: 9).encounterState(for: .normal, encounterIndex: 70)
        expect(
            curseStageScaledEncounter.clearTarget == 91 &&
                curseStageScaledEncounter.compositionTotal == 70 &&
                curseStageScaledEncounter.wave == 11 &&
                curseStageScaledEncounter.waveEncounterNumber == 1 &&
                curseStageScaledEncounter.waveEncounterTarget == 7 &&
                curseStageScaledEncounter.monsterSpawn.name == "骷髅",
            "stage composition counts are weighted across mined kill target instead of repeating the last monster early"
        )

        let nightmareMonster = StageDefinition.stage(act: .volcano, number: 9).spawnMonster(difficulty: .nightmare)
        expect(nightmareMonster.itemLevelCap == 50 && LootTable.itemLevel(for: nightmareMonster) == 50, "nightmare stage 3-9 monster drops use level 50 item cap")

        let tormentMonster = StageDefinition.stage(act: .volcano, number: 9).spawnMonster(difficulty: .torment)
        expect(tormentMonster.hp == 53_215, "torment stage 3-9 uses mined HP")
        expect(tormentMonster.xpReward / 35 > 1_000_000 && LootTable.itemLevel(for: tormentMonster) == 50, "high-XP torment drops are capped by stage item level, not XP reward")

        let finalBossRuntime = StageDefinition.stage(act: .volcano, number: 10).runtimeData(for: .torment)
        expect(finalBossRuntime.monsterComposition == [StageMonsterSpawn(name: "执政官莫尔卡", count: 1, isStageLeader: true)], "stage 4310 boss composition matches drops tool")
        let finalBossMonster = StageDefinition.stage(act: .volcano, number: 10).spawnMonster(difficulty: .torment)
        expect(finalBossMonster.atk == 6_177 && finalBossMonster.spd == 15, "stage 4310 boss uses the matching source boss ATK and attack-speed row before local scaling")
        var sampledCompositionNames = Set<String>()
        var slimeFallbacks: [String] = []
        var legacyUICropMappings: [String] = []
        for stage in StageDefinition.all {
            for difficulty in Difficulty.allCases {
                let target = stage.clearTarget(for: difficulty)
                for encounterIndex in 0..<target {
                    let monster = stage.spawnMonster(difficulty: difficulty, encounterIndex: encounterIndex)
                    let spriteName = GameArt.battleMonsterSpriteName(for: monster.id)
                    sampledCompositionNames.insert(monster.name)
                    if monster.name != "史莱姆" && (monster.id == "slime_green" || spriteName == "monster_slime_red" || spriteName == "official_monster_slime") {
                        slimeFallbacks.append("\(stage.displayCode) \(difficulty.name) \(monster.name)")
                    }
                    if ["monster_slime_red", "monster_skeleton_boss", "boss_golden", "boss_demon"].contains(spriteName) {
                        legacyUICropMappings.append("\(stage.displayCode) \(difficulty.name) \(monster.name) -> \(spriteName)")
                    }
                }
            }
        }
        expect(sampledCompositionNames.count == 49, "all 49 stage composition monster names are sampled")
        expect(slimeFallbacks.isEmpty, "all non-slime stage composition monsters avoid slime art fallback: \(slimeFallbacks.sorted().joined(separator: ", "))")
        expect(legacyUICropMappings.isEmpty, "stage battle monster art avoids legacy full-screenshot UI crops: \(legacyUICropMappings.sorted().joined(separator: ", "))")

        var tracker = ProgressTracker()
        tracker.advance()
        expect(tracker.killsInChapter == 1 && tracker.currentStage.displayCode == "1-1", "single kill does not advance stage")

        tracker = ProgressTracker()
        for _ in 0..<ProgressTracker.killsToAdvance { tracker.advance() }
        expect(tracker.currentStage.displayCode == "1-2", "stage advances after \(ProgressTracker.killsToAdvance) clears")
        expect(tracker.killsInChapter == 0, "stage clear counter resets on advance")
        expect(tracker.stagesCleared.contains("1-1-1"), "cleared stage recorded")
        expect(
            tracker.highestUnlockedStage.displayCode == "1-2" &&
                tracker.unlockedStageSelections.map(\.id) == ["1-1-1", "1-1-2"],
            "stage selector exposes current high-water and previously cleared stages"
        )
        let checkedChestDropStage = StageDefinition.stage(act: .forest, number: 1)
        let missedChestDropRewards = checkedChestDropStage.chestRewards(
            for: .normal,
            chestDropBonuses: ChestDropBonuses(normalMonsterChance: 0.10, stageBossChance: 0.10),
            roll: { 0.99 }
        )
        let hitChestDropRewards = checkedChestDropStage.chestRewards(
            for: .normal,
            chestDropBonuses: ChestDropBonuses(normalMonsterChance: 1.10, stageBossChance: 1.10),
            roll: { 0.05 }
        )
        expect(
            missedChestDropRewards.map(\.family) == [.normalMonster, .stageBoss] &&
                hitChestDropRewards.map(\.family) == [.normalMonster, .stageBoss, .normalMonster, .normalMonster, .stageBoss, .stageBoss],
            "checked Exploration and Conquest drop-chance scaffolds add source-family chests through deterministic rolls"
        )
        expect(
            tracker.selectStage(difficulty: .normal, chapter: .forest, stageNumber: 1) &&
                tracker.currentStage.displayCode == "1-1" &&
                tracker.highestUnlockedStage.displayCode == "1-2",
            "stage selector can revisit unlocked earlier stages without losing high-water progress"
        )
        expect(
            tracker.canSelectStage(difficulty: .normal, chapter: .forest, stageNumber: 2) &&
                !tracker.selectStage(difficulty: .normal, chapter: .forest, stageNumber: 3),
            "stage selector rejects stages beyond the current high-water unlock"
        )
        tracker.killsInChapter = 4
        tracker.restartCurrentStage()
        expect(tracker.killsInChapter == 0 && tracker.currentStage.displayCode == "1-1", "restart current stage resets encounter progress")

        tracker = ProgressTracker()
        for _ in 0..<(ProgressTracker.killsToAdvance - RuneTree.stageClearTargetReductionBonus) {
            tracker.advance(clearTargetReduction: RuneTree.stageClearTargetReductionBonus)
        }
        expect(
            tracker.currentStage.displayCode == "1-2" &&
                tracker.stageProgressText(clearTargetReduction: RuneTree.stageClearTargetReductionBonus) == "0/21" &&
                StageDefinition.stage(act: .forest, number: 1).clearTarget(for: .normal) == ProgressTracker.killsToAdvance,
            "Rune of Brevity reduces runtime stage-clear targets without mutating checked source clear counts"
        )

        tracker = ProgressTracker()
        for _ in 0..<StageDefinition.stagesPerAct { clearCurrentStage(&tracker) }
        expect(tracker.currentChapter == .dungeon && tracker.currentStage.displayCode == "2-1", "act advances after ten stages")
        expect(tracker.chaptersCleared.contains(Chapter.forest.rawValue), "boss clear records completed act")

        tracker = ProgressTracker()
        tracker.currentStageIndex = 8
        for _ in 0..<tracker.currentStage.clearTarget(for: tracker.currentDifficulty) { tracker.advance() }
        expect(tracker.currentStage.displayCode == "1-10" && tracker.chests.count(for: .normal) == 2, "pre-boss stage grants Normal and Stage Boss source chests")
        expect(tracker.soulStones.count(for: .normal) == 0, "stage clear does not grant Soul Stone directly")
        let targetedStageBossID = tracker.chests.chests.first { $0.family == .stageBoss }?.id
        let targetedStageBossChest = targetedStageBossID.flatMap { tracker.openChest(id: $0) }
        expect(
            targetedStageBossChest?.displayName == "Stage Boss Box 6" &&
                targetedStageBossChest?.databaseID == 920_022 &&
                targetedStageBossChest?.rarity == .rare &&
                tracker.soulStones.count(for: .normal) == 1,
            "specific chest opening keeps Stage Boss Box distinct from Normal Monster Box"
        )
        let chest = tracker.openChest(kind: .normal)
        expect(chest?.soulStoneDrop == .normal && tracker.soulStones.count(for: .normal) == 2, "opening chest grants Soul Stone")
        expect(chest?.displayName == "Normal Monster Box 3" && chest?.databaseID == 910_101 && chest?.rarity == .common, "stage chest uses Normal Monster Box catalog metadata")
        let highLevelNormalChest = LootChest(kind: .normal, itemLevel: 50, sourceStageCode: "test", sourceDifficulty: .normal)
        let highLevelNightmareChest = LootChest(kind: .nightmare, itemLevel: 50, sourceStageCode: "test", sourceDifficulty: .nightmare)
        expect(highLevelNormalChest.soulStoneDrop == .normal && highLevelNightmareChest.soulStoneDrop == .nightmare, "chest Soul Stone type follows chest difficulty, not item level")
        let actBossChest = LootChest(kind: .normal, itemLevel: 30, sourceStageCode: "3-10", sourceDifficulty: .normal, family: .actBoss, catalogLevel: 30)
        expect(actBossChest.displayName == "Act Boss Box Lv30" && actBossChest.databaseID == 930_301 && actBossChest.rarity == .legendary, "Act Boss Box catalog metadata is available for boss reward mapping")
        let stageBossLevel10 = LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-8", sourceDifficulty: .normal, family: .stageBoss)
        expect(stageBossLevel10.displayName == "Stage Boss Box 6" && stageBossLevel10.databaseID == 920_022, "Stage Boss level 10 source uses explicit table, not formula-generated 920101")
        let itemPageOnlyStageBossIDs = [920_004, 920_005, 920_006, 920_032, 920_042, 920_051, 920_052, 920_101]
        expect(
            ChestCatalog.entryCount == 59 && itemPageOnlyStageBossIDs.allSatisfy(ChestCatalog.contains(databaseID:)),
            "chest catalog covers all 59 Wiki stage box rows without changing verified stage reward mappings"
        )

        let firstStageSources = StageDefinition.stage(act: .forest, number: 1)
            .chestSources(for: .normal)
            .map { "\($0.displayName) #\($0.databaseID)" }
        expect(firstStageSources == ["Normal Monster Box 1 #910011", "Stage Boss Box 1 #920001"], "stage 1101 chest sources match drops tool mapping")

        let preBossSources = StageDefinition.stage(act: .forest, number: 9)
            .chestSources(for: .normal)
            .map { "\($0.displayName) #\($0.databaseID)" }
        expect(preBossSources == ["Normal Monster Box 3 #910101", "Stage Boss Box 6 #920022"], "stage 1109 chest sources match drops tool mapping")

        let actBossSources = StageDefinition.stage(act: .forest, number: 10)
            .chestSources(for: .normal)
            .map { "\($0.displayName) #\($0.databaseID)" }
        expect(actBossSources == ["Normal Monster Box 3 #910101", "Act Boss Box 1 #930101"], "stage 1110 chest sources match drops tool mapping")

        let finalBossSources = StageDefinition.stage(act: .volcano, number: 10)
            .chestSources(for: .torment)
            .map { "\($0.displayName) #\($0.databaseID)" }
        expect(finalBossSources == ["Normal Monster Box Lv90 #910901", "Act Boss Box Lv90 #930901"], "stage 4310 chest sources match drops tool mapping")

        tracker = ProgressTracker()
        tracker.currentStageIndex = 7
        tracker.killsInChapter = 72
        let clearedByWave = tracker.advance(by: 6)
        expect(clearedByWave && tracker.currentStage.displayCode == "1-9" && tracker.killsInChapter == 0, "wave-sized progress advance clears the stage at the mined target")

        tracker = ProgressTracker()
        tracker.currentStageIndex = 9
        expect(!tracker.canChallengeCurrentStage && tracker.stageLockReason?.contains("灵魂石") == true, "boss requires Soul Stone")
        tracker.soulStones.grant(.normal)
        let bossCleared = tracker.advance()
        expect(
            bossCleared &&
                tracker.soulStones.count(for: .normal) == 0 &&
                tracker.currentStage.displayCode == "2-1" &&
                tracker.chests.count(for: .normal) == 2,
            "boss clear consumes Soul Stone and grants Normal plus Act Boss source chests"
        )
        let bossNormalChest = tracker.openChest(kind: .normal)
        let bossActChest = tracker.openChest(kind: .normal)
        expect(
            bossNormalChest?.displayName == "Normal Monster Box 3" &&
                bossActChest?.displayName == "Act Boss Box 1" &&
                bossActChest?.databaseID == 930_101,
            "Act Boss clear rewards use mapped Act Boss Box metadata"
        )

        var limitedChests = ChestInventory()
        limitedChests.add(
            LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal, family: .normalMonster),
            limits: .base
        )
        limitedChests.add(
            LootChest(kind: .normal, itemLevel: 2, sourceStageCode: "1-2", sourceDifficulty: .normal, family: .normalMonster),
            limits: .base
        )
        expect(
            limitedChests.totalCount == 1 &&
                limitedChests.chests.first?.sourceStageCode == "1-2",
            "base chest family storage keeps the newest source Normal Monster box within the local cap"
        )

        var expandedChests = ChestInventory()
        let expandedChestLimits = RuneTree(unlockedNodes: [.maxNormalChestStorage]).chestStorageLimits
        expandedChests.add(
            LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal, family: .normalMonster),
            limits: expandedChestLimits
        )
        expandedChests.add(
            LootChest(kind: .normal, itemLevel: 2, sourceStageCode: "1-2", sourceDifficulty: .normal, family: .normalMonster),
            limits: expandedChestLimits
        )
        expect(
            expandedChests.totalCount == 2,
            "Rune of Containment chest-capacity scaffold preserves an additional Normal Monster box"
        )
        var doubleExpandedChests = ChestInventory()
        let doubleExpandedChestLimits = RuneTree(unlockedNodes: [.maxNormalChestStorage, .maxNormalChestStorage2]).chestStorageLimits
        for index in 1...3 {
            doubleExpandedChests.add(
                LootChest(kind: .normal, itemLevel: index, sourceStageCode: "1-\(index)", sourceDifficulty: .normal, family: .normalMonster),
                limits: doubleExpandedChestLimits
            )
        }
        expect(
            doubleExpandedChests.totalCount == 3,
            "second Rune of Containment chest-capacity scaffold stacks another Normal Monster box slot"
        )
        var tripleExpandedChests = ChestInventory()
        let tripleExpandedChestLimits = RuneTree(unlockedNodes: [.maxNormalChestStorage, .maxNormalChestStorage2, .maxNormalChestStorage3]).chestStorageLimits
        for index in 1...4 {
            tripleExpandedChests.add(
                LootChest(kind: .normal, itemLevel: index, sourceStageCode: "1-\(index)", sourceDifficulty: .normal, family: .normalMonster),
                limits: tripleExpandedChestLimits
            )
        }
        expect(
            tripleExpandedChests.totalCount == 4,
            "third Rune of Containment chest-capacity scaffold stacks another Normal Monster box slot"
        )
        var quadrupleExpandedChests = ChestInventory()
        let quadrupleExpandedChestLimits = RuneTree(unlockedNodes: [.maxNormalChestStorage, .maxNormalChestStorage2, .maxNormalChestStorage3, .maxNormalChestStorage4]).chestStorageLimits
        for index in 1...5 {
            quadrupleExpandedChests.add(
                LootChest(kind: .normal, itemLevel: index, sourceStageCode: "1-\(index)", sourceDifficulty: .normal, family: .normalMonster),
                limits: quadrupleExpandedChestLimits
            )
        }
        expect(
            quadrupleExpandedChests.totalCount == 5,
            "fourth Rune of Containment chest-capacity scaffold stacks another Normal Monster box slot"
        )
        var fullyExpandedNormalChests = ChestInventory()
        let fullyExpandedNormalChestLimits = RuneTree(unlockedNodes: [
            .maxNormalChestStorage,
            .maxNormalChestStorage2,
            .maxNormalChestStorage3,
            .maxNormalChestStorage4,
            .maxNormalChestStorage5,
            .maxNormalChestStorage6,
            .maxNormalChestStorage7,
            .maxNormalChestStorage8,
            .maxNormalChestStorage9,
            .maxNormalChestStorage10,
            .maxNormalChestStorage11,
            .maxNormalChestStorage12,
            .maxNormalChestStorage13,
            .maxNormalChestStorage14,
            .maxNormalChestStorage15,
        ]).chestStorageLimits
        for index in 1...16 {
            fullyExpandedNormalChests.add(
                LootChest(kind: .normal, itemLevel: index, sourceStageCode: "1-\(min(index, 10))", sourceDifficulty: .normal, family: .normalMonster),
                limits: fullyExpandedNormalChestLimits
            )
        }
        expect(
            fullyExpandedNormalChests.totalCount == 16,
            "fifteenth Rune of Containment chest-capacity scaffold completes the checked Normal Monster box slot family"
        )
        var doubleExpandedStageBossChests = ChestInventory()
        let doubleExpandedStageBossChestLimits = RuneTree(unlockedNodes: [.maxStageBossChestStorage, .maxStageBossChestStorage2]).chestStorageLimits
        for index in 1...3 {
            doubleExpandedStageBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 10, sourceStageCode: "1-\(index + 7)", sourceDifficulty: .normal, family: .stageBoss),
                limits: doubleExpandedStageBossChestLimits
            )
        }
        expect(
            doubleExpandedStageBossChests.totalCount == 3,
            "second Rune of the Vault chest-capacity scaffold stacks another Stage Boss box slot"
        )
        var tripleExpandedStageBossChests = ChestInventory()
        let tripleExpandedStageBossChestLimits = RuneTree(unlockedNodes: [.maxStageBossChestStorage, .maxStageBossChestStorage2, .maxStageBossChestStorage3]).chestStorageLimits
        for index in 1...4 {
            tripleExpandedStageBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 10, sourceStageCode: "1-\(index + 6)", sourceDifficulty: .normal, family: .stageBoss),
                limits: tripleExpandedStageBossChestLimits
            )
        }
        expect(
            tripleExpandedStageBossChests.totalCount == 4,
            "third Rune of the Vault chest-capacity scaffold stacks another Stage Boss box slot"
        )
        var quadrupleExpandedStageBossChests = ChestInventory()
        let quadrupleExpandedStageBossChestLimits = RuneTree(unlockedNodes: [.maxStageBossChestStorage, .maxStageBossChestStorage2, .maxStageBossChestStorage3, .maxStageBossChestStorage4]).chestStorageLimits
        for index in 1...5 {
            quadrupleExpandedStageBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 10, sourceStageCode: "1-\(index + 5)", sourceDifficulty: .normal, family: .stageBoss),
                limits: quadrupleExpandedStageBossChestLimits
            )
        }
        expect(
            quadrupleExpandedStageBossChests.totalCount == 5,
            "fourth Rune of the Vault chest-capacity scaffold stacks another Stage Boss box slot"
        )
        var quintupleExpandedStageBossChests = ChestInventory()
        let quintupleExpandedStageBossChestLimits = RuneTree(unlockedNodes: [.maxStageBossChestStorage, .maxStageBossChestStorage2, .maxStageBossChestStorage3, .maxStageBossChestStorage4, .maxStageBossChestStorage5]).chestStorageLimits
        for index in 1...6 {
            quintupleExpandedStageBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 10, sourceStageCode: "1-\(index + 4)", sourceDifficulty: .normal, family: .stageBoss),
                limits: quintupleExpandedStageBossChestLimits
            )
        }
        expect(
            quintupleExpandedStageBossChests.totalCount == 6,
            "fifth Rune of the Vault chest-capacity scaffold stacks another Stage Boss box slot"
        )
        var fullyExpandedStageBossChests = ChestInventory()
        let fullyExpandedStageBossChestLimits = RuneTree(unlockedNodes: [
            .maxStageBossChestStorage,
            .maxStageBossChestStorage2,
            .maxStageBossChestStorage3,
            .maxStageBossChestStorage4,
            .maxStageBossChestStorage5,
            .maxStageBossChestStorage6,
            .maxStageBossChestStorage7,
            .maxStageBossChestStorage8,
            .maxStageBossChestStorage9,
            .maxStageBossChestStorage10,
            .maxStageBossChestStorage11,
            .maxStageBossChestStorage12,
            .maxStageBossChestStorage13,
        ]).chestStorageLimits
        for index in 1...14 {
            fullyExpandedStageBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 10, sourceStageCode: "1-\(min(index, 10))", sourceDifficulty: .normal, family: .stageBoss),
                limits: fullyExpandedStageBossChestLimits
            )
        }
        expect(
            fullyExpandedStageBossChests.totalCount == 14,
            "thirteenth Rune of the Vault chest-capacity scaffold completes the checked Stage Boss box slot family"
        )
        var doubleExpandedActBossChests = ChestInventory()
        let doubleExpandedActBossChestLimits = RuneTree(unlockedNodes: [.maxActBossChestStorage, .maxActBossChestStorage2]).chestStorageLimits
        for index in 1...3 {
            doubleExpandedActBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 20, sourceStageCode: "1-10", sourceDifficulty: .normal, family: .actBoss),
                limits: doubleExpandedActBossChestLimits
            )
        }
        expect(
            doubleExpandedActBossChests.totalCount == 3,
            "second Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot"
        )
        var tripleExpandedActBossChests = ChestInventory()
        let tripleExpandedActBossChestLimits = RuneTree(unlockedNodes: [.maxActBossChestStorage, .maxActBossChestStorage2, .maxActBossChestStorage3]).chestStorageLimits
        for index in 1...4 {
            tripleExpandedActBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 20, sourceStageCode: "1-10", sourceDifficulty: .normal, family: .actBoss),
                limits: tripleExpandedActBossChestLimits
            )
        }
        expect(
            tripleExpandedActBossChests.totalCount == 4,
            "third Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot"
        )
        var quadrupleExpandedActBossChests = ChestInventory()
        let quadrupleExpandedActBossChestLimits = RuneTree(unlockedNodes: [.maxActBossChestStorage, .maxActBossChestStorage2, .maxActBossChestStorage3, .maxActBossChestStorage4]).chestStorageLimits
        for index in 1...5 {
            quadrupleExpandedActBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 20, sourceStageCode: "1-10", sourceDifficulty: .normal, family: .actBoss),
                limits: quadrupleExpandedActBossChestLimits
            )
        }
        expect(
            quadrupleExpandedActBossChests.totalCount == 5,
            "fourth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot"
        )
        var quintupleExpandedActBossChests = ChestInventory()
        let quintupleExpandedActBossChestLimits = RuneTree(unlockedNodes: [.maxActBossChestStorage, .maxActBossChestStorage2, .maxActBossChestStorage3, .maxActBossChestStorage4, .maxActBossChestStorage5]).chestStorageLimits
        for index in 1...6 {
            quintupleExpandedActBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 20, sourceStageCode: "1-10", sourceDifficulty: .normal, family: .actBoss),
                limits: quintupleExpandedActBossChestLimits
            )
        }
        expect(
            quintupleExpandedActBossChests.totalCount == 6,
            "fifth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot"
        )
        var sextupleExpandedActBossChests = ChestInventory()
        let sextupleExpandedActBossChestLimits = RuneTree(unlockedNodes: [.maxActBossChestStorage, .maxActBossChestStorage2, .maxActBossChestStorage3, .maxActBossChestStorage4, .maxActBossChestStorage5, .maxActBossChestStorage6]).chestStorageLimits
        for index in 1...7 {
            sextupleExpandedActBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 20, sourceStageCode: "1-10", sourceDifficulty: .normal, family: .actBoss),
                limits: sextupleExpandedActBossChestLimits
            )
        }
        expect(
            sextupleExpandedActBossChests.totalCount == 7,
            "sixth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot"
        )
        var septupleExpandedActBossChests = ChestInventory()
        let septupleExpandedActBossChestLimits = RuneTree(unlockedNodes: [.maxActBossChestStorage, .maxActBossChestStorage2, .maxActBossChestStorage3, .maxActBossChestStorage4, .maxActBossChestStorage5, .maxActBossChestStorage6, .maxActBossChestStorage7]).chestStorageLimits
        for index in 1...8 {
            septupleExpandedActBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 20, sourceStageCode: "1-10", sourceDifficulty: .normal, family: .actBoss),
                limits: septupleExpandedActBossChestLimits
            )
        }
        expect(
            septupleExpandedActBossChests.totalCount == 8,
            "seventh Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot"
        )
        var octupleExpandedActBossChests = ChestInventory()
        let octupleExpandedActBossChestLimits = RuneTree(unlockedNodes: [.maxActBossChestStorage, .maxActBossChestStorage2, .maxActBossChestStorage3, .maxActBossChestStorage4, .maxActBossChestStorage5, .maxActBossChestStorage6, .maxActBossChestStorage7, .maxActBossChestStorage8]).chestStorageLimits
        for index in 1...9 {
            octupleExpandedActBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 20, sourceStageCode: "1-10", sourceDifficulty: .normal, family: .actBoss),
                limits: octupleExpandedActBossChestLimits
            )
        }
        expect(
            octupleExpandedActBossChests.totalCount == 9,
            "eighth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot"
        )
        var nonupleExpandedActBossChests = ChestInventory()
        let nonupleExpandedActBossChestLimits = RuneTree(unlockedNodes: [.maxActBossChestStorage, .maxActBossChestStorage2, .maxActBossChestStorage3, .maxActBossChestStorage4, .maxActBossChestStorage5, .maxActBossChestStorage6, .maxActBossChestStorage7, .maxActBossChestStorage8, .maxActBossChestStorage9]).chestStorageLimits
        for index in 1...10 {
            nonupleExpandedActBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 20, sourceStageCode: "1-10", sourceDifficulty: .normal, family: .actBoss),
                limits: nonupleExpandedActBossChestLimits
            )
        }
        expect(
            nonupleExpandedActBossChests.totalCount == 10,
            "ninth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot"
        )
        var decupleExpandedActBossChests = ChestInventory()
        let decupleExpandedActBossChestLimits = RuneTree(unlockedNodes: [.maxActBossChestStorage, .maxActBossChestStorage2, .maxActBossChestStorage3, .maxActBossChestStorage4, .maxActBossChestStorage5, .maxActBossChestStorage6, .maxActBossChestStorage7, .maxActBossChestStorage8, .maxActBossChestStorage9, .maxActBossChestStorage10]).chestStorageLimits
        for index in 1...11 {
            decupleExpandedActBossChests.add(
                LootChest(kind: .normal, itemLevel: index * 20, sourceStageCode: "1-10", sourceDifficulty: .normal, family: .actBoss),
                limits: decupleExpandedActBossChestLimits
            )
        }
        expect(
            decupleExpandedActBossChests.totalCount == 11,
            "tenth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot"
        )

        tracker = ProgressTracker()
        for _ in 0..<StageDefinition.all.count { clearCurrentStage(&tracker) }
        expect(tracker.currentDifficulty == .nightmare && tracker.currentStage.displayCode == "1-1", "difficulty advances after all stages")

        tracker = ProgressTracker()
        for _ in 0..<(StageDefinition.all.count * Difficulty.allCases.count * 2) {
            clearCurrentStage(&tracker)
        }
        expect(
            tracker.currentDifficulty == .torment &&
                tracker.currentStage.displayCode == "3-10" &&
                tracker.isAwaitingNewGamePlus &&
                tracker.completedPlaythroughs == 1,
            "progress caps at torment 3-10 and opens the completion settlement"
        )
        let finalKillsBeforeExtraAdvance = tracker.killsInChapter
        expect(!tracker.advance() && tracker.killsInChapter == finalKillsBeforeExtraAdvance, "completion settlement blocks further automatic progress")
        let secondPlaythroughStarted = tracker.startNextPlaythrough()
        expect(
            secondPlaythroughStarted &&
                tracker.playthrough == 2 &&
                !tracker.isAwaitingNewGamePlus &&
                tracker.currentDifficulty == .normal &&
                tracker.currentStage.displayCode == "1-1" &&
                tracker.highestUnlockedStage.displayCode == "1-1",
            "starting next playthrough resets campaign progression while preserving owned state"
        )
        let firstPlaythroughMonster = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal)
        let secondPlaythroughMonster = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal, playthrough: 2)
        expect(
            NewGamePlusTuning.enemyStatMultiplier(for: 2) > 1.0 &&
                NewGamePlusTuning.rewardMultiplier(for: 2) > 1.0 &&
                secondPlaythroughMonster.hp > firstPlaythroughMonster.hp &&
                secondPlaythroughMonster.goldReward > firstPlaythroughMonster.goldReward,
            "new game plus scales enemy stats and stage rewards"
        )

        let legacyJSON = #"{"currentChapterIndex":1,"currentDifficultyIndex":0,"chaptersCleared":[1]}"#
        let decoded = try? JSONDecoder().decode(ProgressTracker.self, from: Data(legacyJSON.utf8))
        expect(decoded?.currentChapter == .dungeon && decoded?.currentStage.displayCode == "2-1" && decoded?.killsInChapter == 0, "legacy save without stage fields decodes")
    }

    private static func clearCurrentStage(_ tracker: inout ProgressTracker) {
        let difficulty = tracker.currentDifficulty
        let target = tracker.currentStage.clearTarget(for: difficulty)
        for _ in 0..<target {
            tracker.advance()
        }
        while tracker.openChest(kind: ChestKind(difficulty: difficulty)) != nil {}
    }

    private static func offlineProgress() {
        print("[OfflineProgress]")
        let hero = Hero()
        let oneHour = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: 3_600
        )
        expect(oneHour.xp > 0 && oneHour.gold > 0, "offline rewards grant XP and gold")

        let goldBoosted = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: 3_600,
            offlineGoldMultiplier: 1.10
        )
        let xpBoosted = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: 3_600,
            offlineXPMultiplier: 1.10
        )
        expect(
            goldBoosted.gold > oneHour.gold && goldBoosted.xp == oneHour.xp,
            "offline gold boost increases only offline gold"
        )
        expect(
            xpBoosted.xp > oneHour.xp && xpBoosted.gold == oneHour.gold,
            "offline XP boost increases only offline XP"
        )

        let capped = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: OfflineProgress.maxOfflineSeconds
        )
        let longer = OfflineProgress.calculate(
            hero: hero,
            chapter: .forest,
            difficulty: .normal,
            offlineSeconds: 86_400
        )
        expect(capped.xp == longer.xp && capped.gold == longer.gold, "offline rewards cap at 8 hours")
    }

    private static func offlineRuneGate() {
        print("[OfflineRuneGate]")

        func makeManager(
            name: String,
            hero: Hero = Hero(),
            runeTree: RuneTree
        ) -> SaveManager {
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("TBHSelfTest-\(name)-\(UUID().uuidString)", isDirectory: true)
            let manager = SaveManager(directory: tempDir)
            manager.save(SaveData(
                hero: hero,
                runeTree: runeTree,
                inventory: Inventory(),
                progress: ProgressTracker(),
                statistics: GameStatistics(),
                timestamp: Date().addingTimeInterval(-3_600)
            ))
            return manager
        }

        let lockedEngine = GameEngine(
            saveManager: makeManager(name: "offline-locked", runeTree: RuneTree()),
            audio: SilentAudio()
        )
        lockedEngine.start()
        lockedEngine.stop()
        expect(
            lockedEngine.statistics.offlineXP == 0 &&
                lockedEngine.statistics.offlineGold == 0 &&
                lockedEngine.hero.gold == 0,
            "offline rewards stay locked before Rune of Repose"
        )

        let unlockedEngine = GameEngine(
            saveManager: makeManager(name: "offline-unlocked", runeTree: RuneTree(unlockedNodes: [.offlineRewards])),
            audio: SilentAudio()
        )
        unlockedEngine.start()
        unlockedEngine.stop()
        expect(
            unlockedEngine.statistics.offlineXP > 0 &&
                unlockedEngine.statistics.offlineGold > 0 &&
                unlockedEngine.hero.gold > 0,
            "Rune of Repose enables offline XP and gold rewards"
        )

        let boostedEngine = GameEngine(
            saveManager: makeManager(
                name: "offline-boosted",
                runeTree: RuneTree(unlockedNodes: Set([.offlineRewards] + RuneTree.offlineGoldBoostNodes + RuneTree.offlineXPBoostNodes))
            ),
            audio: SilentAudio()
        )
        boostedEngine.start()
        boostedEngine.stop()
        expect(
            boostedEngine.statistics.offlineXP >= unlockedEngine.statistics.offlineXP &&
                boostedEngine.statistics.offlineGold > unlockedEngine.statistics.offlineGold,
            "offline reward boost runes respect applied XP pacing while still increasing offline gold"
        )

        let cappedHero = Hero()
        cappedHero.level = HeroLevelPacing.maxHeroLevel(for: ProgressTracker())
        cappedHero.currentXP = cappedHero.xpForNextLevel() - 1
        let cappedEngine = GameEngine(
            saveManager: makeManager(
                name: "offline-xp-capped",
                hero: cappedHero,
                runeTree: RuneTree(unlockedNodes: Set([.offlineRewards] + RuneTree.offlineXPBoostNodes))
            ),
            audio: SilentAudio()
        )
        cappedEngine.start()
        cappedEngine.stop()
        expect(
            cappedEngine.statistics.offlineXP == 0 &&
                cappedEngine.statistics.offlineGold > 0 &&
                cappedEngine.hero.currentXP == cappedHero.xpForNextLevel() - 1,
            "offline XP statistics record only XP actually applied after pacing and level-cap checks"
        )
    }

    private static func gameStatistics() {
        print("[GameStatistics]")
        var stats = GameStatistics()
        stats.recordVictory(rewards: BattleResult.Rewards(xp: 10, gold: 25, lootItem: nil), lootStored: false, chapter: .dungeon, difficulty: .nightmare, stage: StageDefinition.stage(act: .dungeon, number: 3))
        expect(stats.monstersKilled == 1 && stats.totalGoldEarned == 25, "victory accumulates kills and gold")
        expect(stats.highestChapter == Chapter.dungeon.rawValue && stats.highestDifficulty == Difficulty.nightmare.rawValue && stats.highestStageCode == "2-3", "high-water marks recorded")

        stats.recordVictory(rewards: BattleResult.Rewards(xp: 1, gold: 1, lootItem: nil), lootStored: false, chapter: .forest, difficulty: .normal, stage: StageDefinition.stage(act: .forest, number: 1))
        expect(stats.highestChapter == Chapter.dungeon.rawValue, "high-water marks never decrease")

        let item = Item(id: "i1", name: "测试", rarity: .common, slot: .weapon, stats: ItemStats(), description: "")
        let lootRewards = BattleResult.Rewards(xp: 1, gold: 1, lootItem: item)
        stats.recordVictory(rewards: lootRewards, lootStored: true, chapter: .forest, difficulty: .normal)
        stats.recordVictory(rewards: lootRewards, lootStored: false, chapter: .forest, difficulty: .normal)
        expect(stats.itemsFound == 1, "only loot actually stored counts")

        let secondItem = Item(id: "i2", name: "测试 2", rarity: .common, slot: .armor, stats: ItemStats(), description: "")
        let waveRewards = BattleResult.Rewards(xp: 3, gold: 7, lootItems: [item, secondItem], encountersCleared: 3)
        stats.recordVictory(rewards: waveRewards, lootStoredCount: 2, chapter: .forest, difficulty: .normal)
        expect(stats.monstersKilled == 7 && stats.itemsFound == 3, "wave victory records all cleared encounters and stored loot")

        stats.recordDefeat()
        expect(stats.deaths == 1, "defeat counts a death")
    }

    private static func itemContract() {
        print("[Item Hashable contract]")
        expect(Rarity.allCases.count == 10, "ten original item rarity tiers are available")
        expect(Rarity.allCases.first == .common && Rarity.allCases.last == .cosmic, "rarity ladder runs from common to cosmic")
        expect(
            Rarity.arcana.color == "#B40CFC" &&
                Rarity.cosmic.cubeExperience == 71_089 &&
                Rarity.cosmic.alchemyGoldValue == 355_607,
            "rarity metadata includes original colors, Cube XP and Alchemy gold"
        )
        expect(Rarity.immortal > .legendary && Rarity.cosmic > .divine, "high rarity comparison follows ladder order")
        expect(
            Rarity.synthesisInputCount == 9 &&
                Rarity.common.synthesisOutputRarity == .uncommon &&
                Rarity.divine.synthesisOutputRarity == .cosmic &&
                Rarity.cosmic.synthesisOutputRarity == nil,
            "Synthesis follows the checked 9 same-rarity items into the next rarity tier"
        )
        expect(
            Rarity.sourceSynthesisSkipExamples == [
                SourceSynthesisSkipExample(from: .common, to: .rare, chanceText: "~60%"),
                SourceSynthesisSkipExample(from: .uncommon, to: .legendary, chanceText: "~40%"),
                SourceSynthesisSkipExample(from: .rare, to: .legendary, chanceText: "~20%"),
                SourceSynthesisSkipExample(from: .legendary, to: .immortal, chanceText: "~5%")
            ],
            "Synthesis preserves checked approximate source result examples without treating them as a complete probability table"
        )
        let previewInputs = (0..<9).map {
            Item(
                id: "preview-\($0)",
                name: "预览材料 \($0)",
                rarity: .common,
                slot: .weapon,
                stats: ItemStats(),
                description: "",
                itemLevel: $0 == 8 ? 12 : 3
            )
        } + [
            Item(
                id: "preview-locked",
                name: "锁定预览材料",
                rarity: .common,
                slot: .weapon,
                stats: ItemStats(),
                description: "",
                itemLevel: 90,
                isLocked: true
            )
        ]
        let synthesisPreview = SynthesisPreview.make(for: .common, in: previewInputs)
        expect(
            synthesisPreview.outputRarity == .uncommon &&
                synthesisPreview.unlockedInputCount == 9 &&
                synthesisPreview.lockedInputCount == 1 &&
                synthesisPreview.selectedInputCount == 9 &&
                synthesisPreview.outputItemLevel == 12 &&
                synthesisPreview.outputSourceProgression == SourceGearLevelProgression(id: "300003", itemLevel: 10, name: "Rapier") &&
                synthesisPreview.sourceResultExample == SourceSynthesisSkipExample(from: .common, to: .rare, chanceText: "~60%") &&
                synthesisPreview.sourceResultExample?.displayText == "普通 -> 稀有 ~60%" &&
                synthesisPreview.sourceVariantBoundary == "跳阶/降级概率未核实",
            "Synthesis preview exposes unlocked inputs, locked exclusions, checked output level, source base gear identity and source result examples"
        )
        let cosmicPreview = SynthesisPreview.make(for: .cosmic, in: previewInputs)
        expect(
            !cosmicPreview.isReady &&
                cosmicPreview.outputRarity == nil &&
                cosmicPreview.outputSourceProgression == nil &&
                cosmicPreview.sourceResultExample == nil &&
                cosmicPreview.sourceVariantBoundary == nil,
            "Synthesis preview does not fabricate a Cosmic output"
        )

        expect(EquipmentType.allCases.count == 20, "twenty original equipment types are modeled")
        let typeCounts = Dictionary(grouping: EquipmentType.allCases, by: \.category).mapValues(\.count)
        expect(typeCounts[.weapon] == 6 && typeCounts[.offhand] == 6 && typeCounts[.armor] == 4 && typeCounts[.accessory] == 4, "equipment category counts match source taxonomy")
        expect(Set(EquipmentType.allCases.map(\.equipSlot)).isSuperset(of: Set(EquipSlot.allCases)), "equipment types cover all active equip slots")
        expect(
            SourceItemCatalog.allGearTypes.count == SourceItemCatalog.expectedGearTypeCount &&
                SourceItemCatalog.missingEquipmentTypes.isEmpty,
            "source item catalog covers all checked gear type pages"
        )
        expect(
            SourceItemCatalog.totalGearEntryCount == SourceItemCatalog.expectedGearEntryCount &&
                SourceItemCatalog.totalRarityDistributionCount == SourceItemCatalog.expectedGearEntryCount,
            "source item catalog preserves checked 5,760 aggregate gear entries"
        )
        expect(
            SourceItemCatalog.totalGearLevelProgressionCount == SourceItemCatalog.expectedGearLevelProgressionCount &&
                SourceItemCatalog.duplicateProgressionIDs.isEmpty,
            "source item catalog preserves checked 396 base level progressions"
        )
        expect(
            SourceItemCatalog.aggregateRarityCounts[.common] == 320 &&
                SourceItemCatalog.aggregateRarityCounts[.cosmic] == 320 &&
                SourceItemCatalog.aggregateRarityCounts[.uncommon] == 760,
            "source item catalog preserves checked rarity distribution totals"
        )
        expect(
            SourceItemCatalog.byType[.sword]?.progressions.first == SourceGearLevelProgression(id: "300001", itemLevel: 1, name: "Long Sword") &&
                SourceItemCatalog.byType[.sword]?.progressions.last == SourceGearLevelProgression(id: "300020", itemLevel: 100, name: "Radiant Sword"),
            "source item catalog preserves checked Sword level IDs"
        )
        expect(
            SourceItemCatalog.progression(for: .scepter, itemLevel: 12) == SourceGearLevelProgression(id: "330003", itemLevel: 10, name: "Blessed Scepter") &&
                SourceItemCatalog.progression(for: .amulet, itemLevel: 100) == SourceGearLevelProgression(id: "601191", itemLevel: 90, name: "Abyss Amulet"),
            "source item catalog selects the closest checked base gear progression at or below item level"
        )
        let sourceGearIconNames = SourceItemCatalog.allGearTypes.flatMap { gearType in
            gearType.progressions.map(\.iconName)
        }
        expect(
            sourceGearIconNames.count == SourceItemCatalog.expectedGearLevelProgressionCount &&
                sourceGearIconNames.allSatisfy { $0.hasPrefix("source_gear_") } &&
                SourceItemCatalog.progression(for: .scepter, itemLevel: 12)?.iconName == "source_gear_330003" &&
                SourceItemCatalog.progression(for: .amulet, itemLevel: 100)?.iconName == "source_gear_601191",
            "source item catalog maps checked base gear progressions to source gear icons"
        )
        expect(
            SourceItemCatalog.byType[.amulet]?.gearEntryCount == 272 &&
                SourceItemCatalog.byType[.amulet]?.rarityCount(for: .common) == 0 &&
                SourceItemCatalog.byType[.earring]?.sourceTitle == "Earing",
            "source item catalog preserves accessory-type aggregate counts and source spelling"
        )
        expect(
            SourceItemCatalog.allMaterials.count == SourceItemCatalog.expectedMaterialCount &&
                SourceItemCatalog.duplicateMaterialIDs.isEmpty,
            "source item catalog preserves checked 115 material rows"
        )
        expect(
            SourceItemCatalog.materialCountsByCategory[.decoration] == 36 &&
                SourceItemCatalog.materialCountsByCategory[.engraving] == 33 &&
                SourceItemCatalog.materialCountsByCategory[.inscription] == 10 &&
                SourceItemCatalog.materialCountsByCategory[.crafting] == 22 &&
                SourceItemCatalog.materialCountsByCategory[.offering] == 10 &&
                SourceItemCatalog.materialCountsByCategory[.soulStone] == 4,
            "source item catalog preserves checked material category counts"
        )
        expect(
            SourceItemCatalog.materialByID["110001"] == SourceMaterialEntry(id: "110001", name: "Minor Ruby", rarity: .common, category: .decoration) &&
                SourceItemCatalog.materialByID["129001"] == SourceMaterialEntry(id: "129001", name: "Chaso Dice", rarity: .cosmic, category: .engraving) &&
                SourceItemCatalog.materialByID["190004"] == SourceMaterialEntry(id: "190004", name: "Soulstone - Torment", rarity: .celestial, category: .soulStone),
            "source item catalog preserves checked material examples and source spellings"
        )
        expect(
            SourceItemCatalog.materialByID["110001"]?.iconName == "source_material_110001" &&
                GameArt.soulStoneIconName(for: .normal) == "source_material_190001" &&
                GameArt.soulStoneIconName(for: .torment) == "source_material_190004",
            "source item catalog maps checked materials and Soul Stones to source item icons"
        )
        expect(
            SoulStoneKind.allCases.allSatisfy { SourceItemCatalog.materialByID[String($0.materialID)]?.rarity == $0.rarity },
            "runtime Soul Stone kinds are backed by checked source material rows"
        )
        expect(
            SourceItemCatalog.allStageChests.count == SourceItemCatalog.expectedStageChestCount &&
                SourceItemCatalog.duplicateStageChestIDs.isEmpty,
            "source item catalog preserves checked 59 stage chest rows"
        )
        expect(
            SourceItemCatalog.stageChestCountsByRarity[.common] == 19 &&
                SourceItemCatalog.stageChestCountsByRarity[.rare] == 29 &&
                SourceItemCatalog.stageChestCountsByRarity[.legendary] == 11,
            "source item catalog preserves checked stage chest rarity distribution"
        )
        expect(
            SourceItemCatalog.stageChestByID["920022"] == SourceStageChestEntry(id: "920022", name: "Stage Boss Box 6", rarity: .rare) &&
                SourceItemCatalog.stageChestByID["930901"] == SourceStageChestEntry(id: "930901", name: "Act Boss Box Lv90", rarity: .legendary) &&
                SourceItemCatalog.allStageChests.allSatisfy { ChestCatalog.contains(databaseID: Int($0.id) ?? -1) } &&
                ChestCatalog.entryCount == SourceItemCatalog.expectedStageChestCount,
            "source item catalog stage chest rows align with the runtime chest catalog"
        )
        let normalChestFixture = LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .normalMonster)
        let stageBossChestFixture = LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss)
        let actBossChestFixture = LootChest(kind: .normal, itemLevel: 30, sourceStageCode: "3-10", sourceDifficulty: .normal, family: .actBoss, catalogLevel: 30)
        expect(
            Set(SourceItemCatalog.allStageChests.map(\.iconName)) == ["source_stage_chest_910011", "source_stage_chest_920011", "source_stage_chest_930011"] &&
                SourceItemCatalog.stageChestByID["920022"]?.iconName == "source_stage_chest_920011" &&
                GameArt.chestIconName(for: normalChestFixture) == "source_stage_chest_910011" &&
                GameArt.chestIconName(for: stageBossChestFixture) == "source_stage_chest_920011" &&
                GameArt.chestIconName(for: actBossChestFixture) == "source_stage_chest_930011",
            "source item catalog maps checked stage chests to source family box icons"
        )
        let equipmentTypeIcons = EquipmentType.allCases.map { GameArt.itemIconName(for: $0) }
        let slotIcons = EquipSlot.allCases.map { GameArt.itemIconName(for: $0) }
        expect(equipmentTypeIcons.allSatisfy { $0.hasPrefix("item_") }, "equipment types use pinned source gear icons instead of generic slot icons")
        expect(Set(equipmentTypeIcons).count == EquipmentType.allCases.count && Set(equipmentTypeIcons).count > Set(slotIcons).count, "each equipment type has its own source-backed icon")

        let a = Item(id: "same", name: "甲", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 1), description: "x")
        let b = Item(id: "same", name: "乙", rarity: .rare, slot: .armor, stats: ItemStats(bonusDEF: 9), description: "y")
        expect(a == b && a.hashValue == b.hashValue, "equal items have equal hashes")
        var set: Set<Item> = [a]
        set.insert(b)
        expect(set.count == 1 && set.contains(b), "Set treats equal-id items as one member")

        let legacyJSON = #"{"id":"old-ring","name":"旧饰品","rarity":"普通","slot":"饰品","stats":{"bonusHP":0,"bonusATK":1,"bonusDEF":0,"bonusSPD":0,"bonusCritRate":0,"bonusCritDamage":0},"description":"legacy"}"#
        let legacyItem = try? JSONDecoder().decode(Item.self, from: Data(legacyJSON.utf8))
        expect(legacyItem?.slot == .ring && legacyItem?.equipmentType == .ring && legacyItem?.isLocked == false, "legacy accessory item migrates to ring slot")
        let legacySourceJSON = #"{"id":"old-source","name":"旧权杖","rarity":"稀有","slot":"武器","equipmentType":"Scepter","itemLevel":12,"stats":{"bonusHP":0,"bonusATK":1,"bonusDEF":0,"bonusSPD":0,"bonusCritRate":0,"bonusCritDamage":0},"description":"Lv.12 稀有品质的Scepter · 来源装备 330003"}"#
        let legacySourceItem = try? JSONDecoder().decode(Item.self, from: Data(legacySourceJSON.utf8))
        expect(
            legacySourceItem?.sourceGearID == "330003" &&
                legacySourceItem?.sourceGearProgression == SourceGearLevelProgression(id: "330003", itemLevel: 10, name: "Blessed Scepter") &&
                legacySourceItem.map { GameArt.itemIconName(for: $0) } == "source_gear_330003",
            "legacy item descriptions migrate source gear IDs into structured source identity"
        )
        let legacyNameFixtures: [(id: String, name: String, slot: String, expectedType: EquipmentType, expectedSlot: EquipSlot)] = [
            ("old-bow", "旧猎弓", "武器", .bow, .weapon),
            ("old-crossbow", "旧弩", "武器", .crossbow, .weapon),
            ("old-scepter", "旧权杖", "武器", .scepter, .weapon),
            ("old-shield", "旧木盾", "副手", .shield, .offhand),
            ("old-orb", "旧宝珠", "副手", .orb, .offhand),
            ("old-amulet", "旧项链", "饰品", .amulet, .amulet),
            ("old-earring", "旧耳环", "饰品", .earring, .earring),
            ("old-bracer", "旧护腕", "饰品", .bracer, .bracer)
        ]
        let legacyNameMigrationPassed = legacyNameFixtures.allSatisfy { fixture in
            let json = """
            {"id":"\(fixture.id)","name":"\(fixture.name)","rarity":"普通","slot":"\(fixture.slot)","stats":{"bonusHP":0,"bonusATK":1,"bonusDEF":0,"bonusSPD":0,"bonusCritRate":0,"bonusCritDamage":0},"description":"legacy"}
            """
            guard let item = try? JSONDecoder().decode(Item.self, from: Data(json.utf8)) else {
                return false
            }
            return item.equipmentType == fixture.expectedType &&
                item.slot == fixture.expectedSlot &&
                GameArt.itemIconName(for: item) == SourceItemCatalog.progression(
                    for: fixture.expectedType,
                    itemLevel: 1
                )?.iconName
        }
        expect(legacyNameMigrationPassed, "legacy item names infer concrete equipment types for source gear icons")
        let explicitTypedItem = Item(id: "explicit", name: "旧弓", rarity: .common, slot: .weapon, stats: ItemStats(), description: "legacy", equipmentType: .sword)
        expect(explicitTypedItem.equipmentType == .sword, "explicit equipment type wins over legacy item name inference")
        let explicitSourceItem = Item(
            id: "explicit-source",
            name: "错级剑",
            rarity: .common,
            slot: .weapon,
            stats: ItemStats(),
            description: "",
            itemLevel: 1,
            equipmentType: .sword,
            sourceGearID: "300003"
        )
        expect(
            explicitSourceItem.sourceGearProgression == SourceGearLevelProgression(id: "300003", itemLevel: 10, name: "Rapier") &&
                GameArt.itemIconName(for: explicitSourceItem) == "source_gear_300003",
            "explicit source gear ID wins over item-level fallback icon resolution"
        )

        var loadout = EquipmentLoadout()
        let offhand = Item(id: "off1", name: "木盾", rarity: .common, slot: .offhand, stats: ItemStats(bonusDEF: 3), description: "", equipmentType: .shield)
        let gloves = Item(id: "glv1", name: "布手套", rarity: .common, slot: .gloves, stats: ItemStats(bonusATK: 2), description: "", equipmentType: .gloves)
        let ring = Item(id: "rng1", name: "铜戒指", rarity: .common, slot: .ring, stats: ItemStats(bonusHP: 7), description: "", equipmentType: .ring)
        _ = loadout.equip(offhand)
        _ = loadout.equip(gloves)
        _ = loadout.equip(ring)
        expect(loadout.offhand?.id == "off1" && loadout.gloves?.id == "glv1" && loadout.ring?.id == "rng1", "expanded equipment loadout equips offhand, gloves and ring")
        expect(loadout.bonusDEF == 3 && loadout.bonusATK == 2 && loadout.bonusHP == 7, "expanded equipment stats are included in totals")

        let generated = LootTable.makeItem(type: .scepter, rarity: .rare, itemLevel: 12)
        expect(
            generated.equipmentType == .scepter &&
                generated.slot == .weapon &&
                generated.itemLevel == 12 &&
                generated.name == "Blessed Scepter" &&
                generated.sourceGearID == "330003" &&
                generated.sourceGearProgression == SourceGearLevelProgression(id: "330003", itemLevel: 10, name: "Blessed Scepter") &&
                generated.description.contains("Scepter") &&
                generated.description.contains("来源装备 330003"),
            "loot generation preserves concrete equipment type, item level and structured checked source base gear identity"
        )
        expect(GameArt.itemIconName(for: generated) == "source_gear_330003", "loot item icon follows checked source base gear progression icon")
    }

    private static func inventoryCapacity() {
        print("[Inventory]")
        let inventory = Inventory()
        var allAdded = true
        for i in 0..<inventory.maxCapacity {
            if !inventory.add(Item(id: "i\(i)", name: "x", rarity: .common, slot: nil, stats: ItemStats(), description: "")) {
                allAdded = false
            }
        }
        expect(allAdded, "adding within capacity succeeds")
        let overflow = inventory.add(Item(id: "of", name: "x", rarity: .common, slot: nil, stats: ItemStats(), description: ""))
        expect(!overflow && inventory.items.count == inventory.maxCapacity, "adding to full inventory fails")
        inventory.setMaxCapacity(Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus)
        let expandedAdd = inventory.add(Item(id: "expanded", name: "x", rarity: .common, slot: nil, stats: ItemStats(), description: ""))
        expect(
            expandedAdd &&
                inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus &&
                inventory.items.count == Inventory.baseCapacity + 1,
            "expanded inventory capacity accepts additional items"
        )

        let lockInventory = Inventory()
        let lockItem = Item(id: "lock1", name: "保留", rarity: .rare, slot: .weapon, stats: ItemStats(), description: "")
        lockInventory.add(lockItem)
        let locked = lockInventory.toggleLock(lockItem)
        expect(locked?.isLocked == true, "item lock can be toggled on")
        let discarded = lockInventory.discard(locked ?? lockItem)
        expect(!discarded && lockInventory.items.count == 1, "locked item cannot be discarded")
        let unlocked = lockInventory.toggleLock(locked ?? lockItem)
        let discardedUnlocked = lockInventory.discard(unlocked ?? lockItem)
        expect(discardedUnlocked && lockInventory.items.isEmpty, "unlocked item can be discarded")
    }

    private static func inventoryInteractions() {
        print("[InventoryInteractions]")

        expect(
            InventoryInteraction.actionForItemClick(isSelected: false, modifierFlags: []) == .selectExclusive,
            "plain item click selects the clicked inventory item"
        )
        expect(
            InventoryInteraction.actionForItemClick(isSelected: true, modifierFlags: []) == .deselect,
            "plain item click deselects an already selected inventory item"
        )
        expect(
            InventoryInteraction.actionForItemClick(isSelected: false, modifierFlags: [.option]) == .toggleLock,
            "Option-click maps to the source Alt+click item lock interaction"
        )
        expect(
            InventoryInteraction.actionForItemClick(isSelected: true, modifierFlags: [.option, .shift]) == .toggleLock,
            "Option-click keeps lock toggling ahead of selection state"
        )
    }

    private static func gameEngineEquip() {
        print("[GameEngine equip/reset]")
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHSelfTest-\(UUID().uuidString)", isDirectory: true)
        let saveManager = SaveManager(directory: tempDir)
        let engine = GameEngine(saveManager: saveManager, audio: SilentAudio())

        let sword1 = Item(id: "s1", name: "铁剑", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 5), description: "")
        let sword2 = Item(id: "s2", name: "钢剑", rarity: .rare, slot: .weapon, stats: ItemStats(bonusATK: 10), description: "")
        engine.inventory.add(sword1)
        engine.inventory.add(sword2)

        engine.equipItem(sword1)
        expect(engine.hero.equipment.weapon?.id == "s1" && engine.inventory.items.count == 1, "equip removes item from inventory")

        engine.equipItem(sword2)
        expect(engine.hero.equipment.weapon?.id == "s2", "new weapon equipped")
        expect(engine.inventory.items.map(\.id) == ["s1"], "old weapon returns to inventory")

        let junk = Item(id: "j1", name: "杂物", rarity: .common, slot: nil, stats: ItemStats(), description: "")
        engine.inventory.add(junk)
        engine.equipItem(junk)
        expect(engine.inventory.items.count == 2, "non-equippable equip is a no-op")

        let lockedCubeItem = Item(id: "cube-locked", name: "锁定碎片", rarity: .arcana, slot: nil, stats: ItemStats(), description: "", isLocked: true)
        engine.inventory.add(lockedCubeItem)
        let deniedCubeExperience = engine.infuseItemIntoCube(lockedCubeItem)
        expect(
            deniedCubeExperience == nil &&
                engine.cubeProgress.totalExperience == 0 &&
                engine.inventory.items.contains(lockedCubeItem),
            "locked item cannot be infused into Cube"
        )

        let gainedCubeExperience = engine.infuseItemIntoCube(junk)
        expect(
            gainedCubeExperience == Rarity.common.cubeExperience &&
                engine.cubeProgress.totalExperience == Rarity.common.cubeExperience &&
                engine.cubeProgress.infusedItemCount == 1 &&
                !engine.inventory.items.contains(junk),
            "Cube infusion consumes an unlocked item and grants checked rarity Cube XP"
        )
        let boostedCubeItem = Item(id: "cube-boosted", name: "强化 Cube 材料", rarity: .rare, slot: nil, stats: ItemStats(), description: "")
        engine.inventory.add(boostedCubeItem)
        engine.hero.gainXP(1_000)
        let boostedCubeExperience = Int(Double(Rarity.rare.cubeExperience) * (1.0 + RuneTree.cubeRewardMultiplierBonus * 4.0))
        expect(
            engine.unlockRuneTreeNode(.cubeXPBoost1) &&
                engine.unlockRuneTreeNode(.alchemyGoldBoost2) &&
                engine.unlockRuneTreeNode(.cubeXPBoost2) &&
                engine.unlockRuneTreeNode(.cubeXPBoost3) &&
                engine.unlockRuneTreeNode(.cubeXPBoost4) &&
                engine.infuseItemIntoCube(boostedCubeItem) == boostedCubeExperience &&
                engine.cubeProgress.totalExperience == Rarity.common.cubeExperience + boostedCubeExperience,
            "all checked Rune of Forging rows increase Cube infusion XP"
        )

        let alchemyEngine = GameEngine(
            saveManager: SaveManager(directory: tempDir.appendingPathComponent("Alchemy", isDirectory: true)),
            audio: SilentAudio()
        )
        let lockedAlchemyItem = Item(id: "alchemy-locked", name: "锁定炼金材料", rarity: .cosmic, slot: nil, stats: ItemStats(), description: "", isLocked: true)
        let unlockedAlchemyItem = Item(id: "alchemy-open", name: "炼金材料", rarity: .rare, slot: nil, stats: ItemStats(), description: "")
        alchemyEngine.inventory.add(lockedAlchemyItem)
        alchemyEngine.inventory.add(unlockedAlchemyItem)
        let goldBeforeAlchemy = alchemyEngine.hero.gold
        expect(
            alchemyEngine.alchemizeItem(lockedAlchemyItem) == nil &&
                alchemyEngine.hero.gold == goldBeforeAlchemy &&
                alchemyEngine.inventory.items.contains(lockedAlchemyItem),
            "locked item cannot be alchemized"
        )
        expect(
            alchemyEngine.alchemizeItem(unlockedAlchemyItem) == Rarity.rare.alchemyGoldValue &&
                alchemyEngine.hero.gold == goldBeforeAlchemy + Rarity.rare.alchemyGoldValue &&
                !alchemyEngine.inventory.items.contains(unlockedAlchemyItem),
            "Alchemy consumes an unlocked item and grants checked rarity gold"
        )
        let boostedAlchemyItem = Item(id: "alchemy-boosted", name: "强化炼金材料", rarity: .rare, slot: nil, stats: ItemStats(), description: "")
        alchemyEngine.inventory.add(boostedAlchemyItem)
        alchemyEngine.hero.gainXP(1_000)
        let boostedAlchemyGold = Int(Double(Rarity.rare.alchemyGoldValue) * (1.0 + RuneTree.cubeRewardMultiplierBonus * 4.0))
        expect(
            alchemyEngine.unlockRuneTreeNode(.cubeXPBoost1) &&
                alchemyEngine.unlockRuneTreeNode(.alchemyGoldBoost1) &&
                alchemyEngine.unlockRuneTreeNode(.alchemyGoldBoost2) &&
                alchemyEngine.unlockRuneTreeNode(.alchemyGoldBoost3) &&
                alchemyEngine.unlockRuneTreeNode(.cubeXPBoost4) &&
                alchemyEngine.unlockRuneTreeNode(.alchemyGoldBoost4) &&
                alchemyEngine.alchemizeItem(boostedAlchemyItem) == boostedAlchemyGold &&
                alchemyEngine.hero.gold == goldBeforeAlchemy + Rarity.rare.alchemyGoldValue + boostedAlchemyGold,
            "all checked Rune of Alchemy rows increase manual alchemy gold"
        )

        let synthesisEngine = GameEngine(
            saveManager: SaveManager(directory: tempDir.appendingPathComponent("Synthesis", isDirectory: true)),
            audio: SilentAudio()
        )
        for index in 0..<9 {
            synthesisEngine.inventory.add(
                Item(
                    id: "synthesis-\(index)",
                    name: "合成材料 \(index)",
                    rarity: .common,
                    slot: .weapon,
                    stats: ItemStats(bonusATK: index + 1),
                    description: "",
                    itemLevel: 12,
                    equipmentType: .sword
                )
            )
        }
        synthesisEngine.inventory.add(
            Item(
                id: "synthesis-locked",
                name: "锁定合成材料",
                rarity: .common,
                slot: .weapon,
                stats: ItemStats(bonusATK: 99),
                description: "",
                itemLevel: 90,
                isLocked: true,
                equipmentType: .sword
            )
        )
        let synthesized = synthesisEngine.synthesizeItems(rarity: .common)
        expect(
                synthesized?.rarity == .uncommon &&
                synthesized?.equipmentType == .sword &&
                synthesized?.itemLevel == 12 &&
                synthesized?.name == "Rapier" &&
                synthesized?.sourceGearID == "300003" &&
                synthesized?.sourceGearProgression == SourceGearLevelProgression(id: "300003", itemLevel: 10, name: "Rapier") &&
                synthesized?.description.contains("来源装备 300003") == true &&
                synthesisEngine.inventory.items.count == 2 &&
                synthesisEngine.inventory.items.contains { $0.id == "synthesis-locked" },
            "Synthesis consumes nine unlocked same-rarity items and creates the next rarity tier with structured checked source base gear identity"
        )
        expect(
            synthesisEngine.synthesizeItems(rarity: .cosmic) == nil,
            "Cosmic items cannot be synthesized into a fabricated higher rarity"
        )

        let weakArmor = Item(id: "a1", name: "布甲", rarity: .common, slot: .armor, stats: ItemStats(bonusDEF: 2), description: "")
        let strongArmor = Item(id: "a2", name: "钢甲", rarity: .rare, slot: .armor, stats: ItemStats(bonusDEF: 8), description: "")
        let weakRing = Item(id: "r1", name: "铜戒指", rarity: .common, slot: .ring, stats: ItemStats(bonusHP: 3), description: "", equipmentType: .ring)
        let strongRing = Item(id: "r2", name: "银戒指", rarity: .rare, slot: .ring, stats: ItemStats(bonusHP: 15), description: "", equipmentType: .ring)
        engine.inventory.add(weakArmor)
        engine.inventory.add(strongArmor)
        engine.inventory.add(weakRing)
        engine.inventory.add(strongRing)
        engine.setAutoEquipBestItems(true)
        expect(engine.autoEquipBestItems, "auto equip toggle is enabled")
        expect(engine.hero.equipment.armor?.id == "a2", "auto equip picks strongest item per slot")
        expect(engine.hero.equipment.ring?.id == "r2", "auto equip includes expanded accessory slots")
        expect(engine.inventory.items.contains(weakArmor), "weaker item stays in inventory")
        engine.setWorseEquipmentHandling(.alchemize)
        engine.hero.gainXP(1_000)
        _ = engine.unlockRuneTreeNode(.cubeXPBoost1)
        _ = engine.unlockRuneTreeNode(.alchemyGoldBoost1)
        _ = engine.unlockRuneTreeNode(.alchemyGoldBoost2)
        _ = engine.unlockRuneTreeNode(.alchemyGoldBoost3)
        _ = engine.unlockRuneTreeNode(.cubeXPBoost4)
        _ = engine.unlockRuneTreeNode(.alchemyGoldBoost4)
        let weakerRingLoot = Item(id: "r3", name: "旧戒指", rarity: .uncommon, slot: .ring, stats: ItemStats(bonusHP: 1), description: "", equipmentType: .ring)
        let goldBeforeWeakLoot = engine.hero.gold
        expect(engine.retainLootForTesting(weakerRingLoot), "worse-equipment handling accepts handled loot")
        expect(
            !engine.inventory.items.contains(weakerRingLoot) &&
                engine.hero.gold == goldBeforeWeakLoot + Int(Double(Rarity.uncommon.alchemyGoldValue) * (1.0 + RuneTree.cubeRewardMultiplierBonus * 4.0)),
            "worse-equipment alchemy consumes weaker same-slot loot before it enters the backpack"
        )
        engine.setWorseEquipmentHandling(.discard)
        let goldBeforeDiscardedLoot = engine.hero.gold
        expect(engine.retainLootForTesting(weakerRingLoot), "worse-equipment discard handles weaker same-slot loot")
        expect(
            !engine.inventory.items.contains(weakerRingLoot) &&
                engine.hero.gold == goldBeforeDiscardedLoot,
            "worse-equipment discard removes weaker same-slot loot without granting gold"
        )
        engine.setWorseEquipmentHandling(.keep)

        engine.setSoundEffectsEnabled(false)
        expect(!engine.soundEffectsEnabled, "sound effects toggle can be disabled")

        let stageSelectEngine = GameEngine(
            saveManager: SaveManager(
                directory: tempDir.appendingPathComponent("stage-select", isDirectory: true)
            ),
            audio: SilentAudio()
        )
        for _ in 0..<ProgressTracker.killsToAdvance {
            stageSelectEngine.progress.advance()
        }
        let firstStageSelection = stageSelectEngine.progress.unlockedStageSelections.first { $0.id == "1-1-1" }
        let didSelectFirstStage = firstStageSelection.map { stageSelectEngine.selectStage($0) } ?? false
        expect(
            didSelectFirstStage &&
                stageSelectEngine.progress.currentStage.displayCode == "1-1" &&
                stageSelectEngine.currentBattle?.monster.name == "哥布林盗贼",
            "stage selection refreshes the active battle"
        )
        stageSelectEngine.progress.killsInChapter = 3
        stageSelectEngine.restartCurrentStage()
        expect(
            stageSelectEngine.progress.killsInChapter == 0 &&
                stageSelectEngine.currentBattle?.monster.name == "哥布林盗贼",
            "restart current stage refreshes the active battle"
        )

        let chestEngine = GameEngine(
            saveManager: SaveManager(
                directory: tempDir.appendingPathComponent("specific-chest", isDirectory: true)
            ),
            audio: SilentAudio()
        )
        let normalChest = LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .normalMonster)
        let stageBossChest = LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss)
        chestEngine.progress.chests.add(normalChest)
        chestEngine.progress.chests.add(stageBossChest)
        expect(
            chestEngine.openChest(id: stageBossChest.id) &&
                chestEngine.openChest(kind: .normal) &&
                chestEngine.progress.chests.count(for: .normal) == 0 &&
                chestEngine.progress.soulStones.count(for: .normal) == 2 &&
                chestEngine.statistics.itemsFound == 2,
            "specific chest opening and legacy kind opening share loot retention behavior"
        )

        let batchChestEngine = GameEngine(
            saveManager: SaveManager(
                directory: tempDir.appendingPathComponent("all-chests", isDirectory: true)
            ),
            audio: SilentAudio()
        )
        batchChestEngine.progress.chests.add(LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal))
        batchChestEngine.progress.chests.add(LootChest(kind: .normal, itemLevel: 5, sourceStageCode: "1-2", sourceDifficulty: .normal))
        batchChestEngine.progress.chests.add(LootChest(kind: .nightmare, itemLevel: 20, sourceStageCode: "2-1", sourceDifficulty: .nightmare))
        batchChestEngine.progress.chests.add(LootChest(kind: .hell, itemLevel: 40, sourceStageCode: "3-1", sourceDifficulty: .hell))
        expect(
            batchChestEngine.openAllChests() == 0 &&
                batchChestEngine.openChests(kind: .normal) == 0 &&
                batchChestEngine.progress.chests.totalCount == 4,
            "batch chest opening stays locked before the checked Rune of Opening effects"
        )
        batchChestEngine.hero.gainXP(1_000)
        expect(batchChestEngine.unlockRuneTreeNode(.openOneChestType), "Rune of Opening unlocks one-type batch chest opening in the engine")
        expect(
            batchChestEngine.openChests(kind: .normal) == 2 &&
                batchChestEngine.progress.chests.totalCount == 2 &&
                batchChestEngine.progress.soulStones.count(for: .normal) == 2,
            "one-type chest opening consumes only the selected chest kind snapshot"
        )
        expect(batchChestEngine.unlockRuneTreeNode(.openAllChestTypes), "second Rune of Opening unlocks all-type batch chest opening in the engine")
        expect(
            batchChestEngine.openAllChests() == 2 &&
                batchChestEngine.progress.chests.totalCount == 0 &&
                batchChestEngine.progress.soulStones.count(for: .nightmare) == 1 &&
                batchChestEngine.progress.soulStones.count(for: .hell) == 1 &&
                batchChestEngine.inventory.items.count == 4 &&
                batchChestEngine.statistics.itemsFound == 4,
            "all-type chest opening consumes the remaining chest snapshot and keeps all rewards"
        )

        let autoChestEngine = GameEngine(
            saveManager: SaveManager(
                directory: tempDir.appendingPathComponent("auto-normal-chests", isDirectory: true)
            ),
            audio: SilentAudio()
        )
        autoChestEngine.hero.gainXP(1_000)
        autoChestEngine.progress.chests.add(LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal, family: .normalMonster))
        autoChestEngine.progress.chests.add(LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss))
        expect(autoChestEngine.unlockRuneTreeNode(.autoOpenNormalChests), "Rune of the Mainspring starts automatic Normal Monster chest cooldown in the engine")
        expect(
            autoChestEngine.runeTree.canAutoOpenNormalChests &&
                autoChestEngine.autoOpenChestCooldowns.remaining(for: .normalMonster) == RuneTree.normalChestAutoOpenBaseCooldown &&
                autoChestEngine.progress.chests.totalCount == 2 &&
                autoChestEngine.progress.soulStones.count(for: .normal) == 0,
            "Rune of the Mainspring starts the source Normal Monster auto-open cooldown without opening immediately"
        )
        expect(
            autoChestEngine.runSelfTestAutoOpenCooldown(seconds: RuneTree.normalChestAutoOpenBaseCooldown) == 1 &&
                autoChestEngine.progress.chests.totalCount == 1 &&
                autoChestEngine.progress.chests.chests.first?.family == .stageBoss &&
                autoChestEngine.progress.soulStones.count(for: .normal) == 1 &&
                autoChestEngine.inventory.items.count == 1 &&
                autoChestEngine.statistics.itemsFound == 1,
            "automatic Normal Monster chest cooldown consumes only source Normal Monster boxes"
        )

        let lubricatedAutoChestEngine = GameEngine(
            saveManager: SaveManager(
                directory: tempDir.appendingPathComponent("auto-normal-chest-speed", isDirectory: true)
            ),
            audio: SilentAudio()
        )
        lubricatedAutoChestEngine.hero.gainXP(1_000)
        for index in 1...3 {
            lubricatedAutoChestEngine.progress.chests.add(
                LootChest(kind: .normal, itemLevel: index, sourceStageCode: "1-\(index)", sourceDifficulty: .normal, family: .normalMonster)
            )
        }
        lubricatedAutoChestEngine.progress.chests.add(
            LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss)
        )
        for node in RuneTree.normalChestAutoOpenSpeedNodes {
            expect(lubricatedAutoChestEngine.unlockRuneTreeNode(node), "Rune of Lubrication normal auto-open speed node unlocks")
        }
        expect(lubricatedAutoChestEngine.unlockRuneTreeNode(.autoOpenNormalChests), "Rune of the Mainspring starts automatic Normal Monster chest cooldown after lubrication")
        let lubricatedNormalCooldown = lubricatedAutoChestEngine.runeTree.normalChestAutoOpenCooldown
        expect(
            lubricatedNormalCooldown == RuneTree.normalChestAutoOpenBaseCooldown - RuneTree.normalChestAutoOpenCooldownReductionByNode.values.reduce(0, +) &&
                lubricatedAutoChestEngine.autoOpenChestCooldowns.remaining(for: .normalMonster) == lubricatedNormalCooldown &&
                lubricatedAutoChestEngine.runSelfTestAutoOpenCooldown(seconds: max(0, lubricatedNormalCooldown - 1)) == 0 &&
                lubricatedAutoChestEngine.progress.chests.totalCount == 4 &&
                lubricatedAutoChestEngine.runSelfTestAutoOpenCooldown(seconds: 1) == 1 &&
                lubricatedAutoChestEngine.runSelfTestAutoOpenCooldown(seconds: lubricatedNormalCooldown) == 1 &&
                lubricatedAutoChestEngine.runSelfTestAutoOpenCooldown(seconds: lubricatedNormalCooldown) == 1 &&
                lubricatedAutoChestEngine.progress.chests.totalCount == 1 &&
                lubricatedAutoChestEngine.progress.chests.chests.first?.family == .stageBoss &&
                lubricatedAutoChestEngine.progress.soulStones.count(for: .normal) == 3,
            "checked Lubrication normal auto-open rows shorten the cooldown and still open one box per cycle"
        )

        let autoStageBossChestEngine = GameEngine(
            saveManager: SaveManager(
                directory: tempDir.appendingPathComponent("auto-stage-boss-chests", isDirectory: true)
            ),
            audio: SilentAudio()
        )
        autoStageBossChestEngine.hero.gainXP(1_000)
        autoStageBossChestEngine.progress.chests.add(LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal, family: .normalMonster))
        autoStageBossChestEngine.progress.chests.add(LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss))
        autoStageBossChestEngine.progress.chests.add(LootChest(kind: .normal, itemLevel: 30, sourceStageCode: "3-10", sourceDifficulty: .normal, family: .actBoss))
        expect(autoStageBossChestEngine.unlockRuneTreeNode(.autoOpenStageBossChests), "Rune of the Mainspring starts automatic Stage Boss chest cooldown in the engine")
        expect(
            autoStageBossChestEngine.runeTree.canAutoOpenStageBossChests &&
                autoStageBossChestEngine.autoOpenChestCooldowns.remaining(for: .stageBoss) == RuneTree.stageBossChestAutoOpenBaseCooldown &&
                autoStageBossChestEngine.progress.chests.totalCount == 3,
            "Rune of the Mainspring starts the source Stage Boss auto-open cooldown without opening immediately"
        )
        expect(
            autoStageBossChestEngine.runSelfTestAutoOpenCooldown(seconds: RuneTree.stageBossChestAutoOpenBaseCooldown) == 1 &&
                autoStageBossChestEngine.progress.chests.totalCount == 2 &&
                autoStageBossChestEngine.progress.chests.chests.filter { $0.family == .normalMonster }.count == 1 &&
                autoStageBossChestEngine.progress.chests.chests.filter { $0.family == .stageBoss }.isEmpty &&
                autoStageBossChestEngine.progress.chests.chests.filter { $0.family == .actBoss }.count == 1 &&
                autoStageBossChestEngine.progress.soulStones.count(for: .normal) == 1 &&
                autoStageBossChestEngine.inventory.items.count == 1 &&
                autoStageBossChestEngine.statistics.itemsFound == 1,
            "automatic Stage Boss chest cooldown consumes only source Stage Boss boxes"
        )

        let autoActBossChestEngine = GameEngine(
            saveManager: SaveManager(
                directory: tempDir.appendingPathComponent("auto-act-boss-chests", isDirectory: true)
            ),
            audio: SilentAudio()
        )
        autoActBossChestEngine.hero.gainXP(1_000)
        autoActBossChestEngine.progress.chests.add(LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal, family: .normalMonster))
        autoActBossChestEngine.progress.chests.add(LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss))
        autoActBossChestEngine.progress.chests.add(LootChest(kind: .normal, itemLevel: 30, sourceStageCode: "3-10", sourceDifficulty: .normal, family: .actBoss))
        expect(autoActBossChestEngine.unlockRuneTreeNode(.autoOpenActBossChests), "Rune of the Mainspring starts automatic Act Boss chest cooldown in the engine")
        expect(
            autoActBossChestEngine.runeTree.canAutoOpenActBossChests &&
                autoActBossChestEngine.autoOpenChestCooldowns.remaining(for: .actBoss) == RuneTree.actBossChestAutoOpenBaseCooldown &&
                autoActBossChestEngine.progress.chests.totalCount == 3,
            "Rune of the Mainspring starts the source Act Boss auto-open cooldown without opening immediately"
        )
        expect(
            autoActBossChestEngine.runSelfTestAutoOpenCooldown(seconds: RuneTree.actBossChestAutoOpenBaseCooldown) == 1 &&
                autoActBossChestEngine.progress.chests.totalCount == 2 &&
                autoActBossChestEngine.progress.chests.chests.filter { $0.family == .normalMonster }.count == 1 &&
                autoActBossChestEngine.progress.chests.chests.filter { $0.family == .stageBoss }.count == 1 &&
                autoActBossChestEngine.progress.chests.chests.filter { $0.family == .actBoss }.isEmpty &&
                autoActBossChestEngine.progress.soulStones.count(for: .normal) == 1 &&
                autoActBossChestEngine.inventory.items.count == 1 &&
                autoActBossChestEngine.statistics.itemsFound == 1,
            "automatic Act Boss chest cooldown consumes only source Act Boss boxes"
        )

        let formationEngine = GameEngine(
            saveManager: SaveManager(
                directory: tempDir.appendingPathComponent("formation-direct-unlock", isDirectory: true)
            ),
            audio: SilentAudio()
        )
        formationEngine.setPartyMember(slotIndex: 1, heroClass: .sorcerer)
        expect(formationEngine.party.member(at: 1)?.heroClass == .priest, "locked support party slot ignores class change")
        formationEngine.hero.gainGold(200_000)
        expect(!formationEngine.unlockRuneTreeNode(.partySlot2), "Rune Tree formation slot stays locked below hero level 3")
        expect(formationEngine.directPartySlotUnlockCost(slotIndex: 2) == 200_000, "direct party slot 3 unlock reports combined checked cost while both support slots are locked")
        expect(formationEngine.directlyUnlockPartySlot(slotIndex: 2), "direct party slot unlock opens positions 2 and 3 from the party panel path")
        expect(
            formationEngine.hero.gold == 0 &&
                formationEngine.runeTree.unlockedPartySlotCount == 3 &&
                formationEngine.party.activeCount == 3 &&
                formationEngine.currentBattle?.party.activeCount == 3,
            "direct party slot unlock spends checked formation gold and refreshes active battle party slots"
        )
        formationEngine.resetRuneTree()
        expect(formationEngine.hero.gold == 200_000 && formationEngine.party.activeCount == 1, "Rune Tree reset refunds directly spent checked formation gold and relocks party slots")

        let oneClickRuneEngine = GameEngine(
            saveManager: SaveManager(
                directory: tempDir.appendingPathComponent("one-click-rune-unlock", isDirectory: true)
            ),
            audio: SilentAudio()
        )
        oneClickRuneEngine.hero.gainXP(1_000)
        oneClickRuneEngine.hero.gainGold(200_000)
        let oneClickAvailableCount = oneClickRuneEngine.unlockableRuneTreeNodeCount
        let oneClickGoldCost = oneClickRuneEngine.unlockableRuneTreeGoldCost
        let oneClickUnlockedCount = oneClickRuneEngine.unlockAllAvailableRuneTreeNodes()
        let oneClickRepeatCount = oneClickRuneEngine.unlockAllAvailableRuneTreeNodes()
        expect(
            oneClickAvailableCount > 0 &&
                oneClickGoldCost == 200_000 &&
                oneClickUnlockedCount >= oneClickAvailableCount &&
                oneClickRepeatCount == 0 &&
                oneClickRuneEngine.hero.gold == 0 &&
                oneClickRuneEngine.runeTree.unlockedPartySlotCount == 3 &&
                oneClickRuneEngine.runeTree.activeSkillSlotCount == 2 &&
                oneClickRuneEngine.party.activeCount == 3 &&
                oneClickRuneEngine.currentBattle?.party.activeCount == 3 &&
                oneClickRuneEngine.unlockableRuneTreeNodeCount == 0 &&
                oneClickRuneEngine.unlockableRuneTreeGoldCost == 0,
            "one-click Rune Tree unlock previews and consumes only available checked gold once while refreshing battle state"
        )

        engine.hero.gold = 200_000
        expect(engine.unlockRuneTreeNode(.partySlot2) && engine.hero.gold == 150_000, "second party slot spends checked 50,000 gold")
        expect(engine.unlockRuneTreeNode(.partySlot3) && engine.hero.gold == 0, "third party slot spends checked 150,000 gold")
        expect(engine.currentBattle?.activeSkillSlotCount == 1, "engine battle starts with one active skill slot before Rune of Awakening")
        expect(
            engine.unlockRuneTreeNode(.activeSkillSlot2) &&
                engine.runeTree.activeSkillSlotCount == 2 &&
                engine.currentBattle?.activeSkillSlotCount == 2,
            "Rune of Awakening refreshes engine battle active skill slot count"
        )
        let attackBeforeWarRune = engine.hero.attack
        let supportAttackBeforeWarRune = engine.party.supportAttackPower(heroLevel: engine.hero.level)
        expect(
            engine.unlockRuneTreeNode(.allHeroAttackDamage1) &&
                engine.hero.attack == attackBeforeWarRune + RuneTree.allHeroAttackDamageBonus &&
                engine.party.supportAttackPower(heroLevel: engine.hero.level, allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage) >= supportAttackBeforeWarRune,
            "Rune of War refreshes main and support attack scaffolds"
        )
        let defenseBeforeShieldRune = engine.hero.defense
        let supportDefenseBeforeShieldRune = engine.party.supportMembers.first?.supportDefense(heroLevel: engine.hero.level) ?? 0
        expect(
            engine.unlockRuneTreeNode(.allHeroArmor1) &&
                engine.hero.defense == defenseBeforeShieldRune + RuneTree.allHeroArmorBonus &&
                (engine.party.supportMembers.first?.supportDefense(heroLevel: engine.hero.level, allHeroArmorBonus: engine.runeTree.allHeroArmor) ?? 0) == supportDefenseBeforeShieldRune + RuneTree.allHeroArmorBonus,
            "Rune of the Shield refreshes main and support armor scaffolds"
        )
        let speedBeforeGaleRune = engine.hero.speed
        let supportSpeedBeforeGaleRune = engine.party.supportMembers.first?.supportSpeed() ?? 0
        expect(
            engine.unlockRuneTreeNode(.allHeroMoveSpeed1) &&
                engine.hero.speed == speedBeforeGaleRune + RuneTree.allHeroMoveSpeedBonus &&
                (engine.party.supportMembers.first?.supportSpeed(allHeroMoveSpeedBonus: engine.runeTree.allHeroMoveSpeed) ?? 0) == supportSpeedBeforeGaleRune + RuneTree.allHeroMoveSpeedBonus,
            "Rune of the Gale refreshes main and support move-speed scaffolds"
        )
        let defenseBeforeThirdShieldRune = engine.hero.defense
        let supportDefenseBeforeThirdShieldRune = engine.party.supportMembers.first?.supportDefense(
            heroLevel: engine.hero.level,
            allHeroArmorBonus: engine.runeTree.allHeroArmor,
            allHeroArmorMultiplier: engine.runeTree.allHeroArmorMultiplier
        ) ?? 0
        expect(
            engine.unlockRuneTreeNode(.allHeroArmor3) &&
                engine.runeTree.allHeroArmor == RuneTree.allHeroArmorBonus * 2 &&
                engine.hero.defense > defenseBeforeThirdShieldRune &&
                (engine.party.supportMembers.first?.supportDefense(
                    heroLevel: engine.hero.level,
                    allHeroArmorBonus: engine.runeTree.allHeroArmor,
                    allHeroArmorMultiplier: engine.runeTree.allHeroArmorMultiplier
                ) ?? 0) >= supportDefenseBeforeThirdShieldRune &&
                engine.currentBattle?.allHeroArmorBonus == engine.runeTree.allHeroArmor,
            "third Rune of the Shield refreshes main, support and active battle armor scaffolds"
        )
        let speedBeforeFourthGaleRune = engine.hero.speed
        let supportSpeedBeforeFourthGaleRune = engine.party.supportMembers.first?.supportSpeed(
            allHeroMoveSpeedBonus: engine.runeTree.allHeroMoveSpeed
        ) ?? 0
        expect(
            engine.unlockRuneTreeNode(.allHeroMoveSpeed4) &&
                engine.hero.speed == speedBeforeFourthGaleRune + RuneTree.allHeroMoveSpeedBonus &&
                (engine.party.supportMembers.first?.supportSpeed(allHeroMoveSpeedBonus: engine.runeTree.allHeroMoveSpeed) ?? 0) == supportSpeedBeforeFourthGaleRune + RuneTree.allHeroMoveSpeedBonus,
            "fourth Rune of the Gale refreshes main and support move-speed scaffolds"
        )
        let attackBeforeWarPercentRune = engine.hero.attack
        let supportAttackBeforeWarPercentRune = engine.party.supportAttackPower(
            heroLevel: engine.hero.level,
            allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage
        )
        expect(
            engine.unlockRuneTreeNode(.allHeroAttackDamagePercent1) &&
                engine.hero.attack == Int(ceil(Double(attackBeforeWarPercentRune) * (1.0 + RuneTree.allHeroAttackDamageMultiplierBonus))) &&
                engine.party.supportAttackPower(
                    heroLevel: engine.hero.level,
                    allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage,
                    allHeroAttackDamageMultiplier: engine.runeTree.allHeroAttackDamageMultiplier
                ) >= supportAttackBeforeWarPercentRune &&
                engine.currentBattle?.allHeroAttackDamageMultiplier == engine.runeTree.allHeroAttackDamageMultiplier,
            "Rune of War percent scaffold refreshes main, support and active battle attack multipliers"
        )
        let speedBeforeFifthGaleRune = engine.hero.speed
        let supportSpeedBeforeFifthGaleRune = engine.party.supportMembers.first?.supportSpeed(
            allHeroMoveSpeedBonus: engine.runeTree.allHeroMoveSpeed
        ) ?? 0
        expect(
            engine.unlockRuneTreeNode(.allHeroMoveSpeed5) &&
                engine.hero.speed == speedBeforeFifthGaleRune + RuneTree.allHeroMoveSpeedBonus &&
                (engine.party.supportMembers.first?.supportSpeed(allHeroMoveSpeedBonus: engine.runeTree.allHeroMoveSpeed) ?? 0) == supportSpeedBeforeFifthGaleRune + RuneTree.allHeroMoveSpeedBonus,
            "fifth Rune of the Gale refreshes main and support move-speed scaffolds"
        )
        let defenseBeforeShieldPercentRune = engine.hero.defense
        let supportDefenseBeforeShieldPercentRune = engine.party.supportMembers.first?.supportDefense(
            heroLevel: engine.hero.level,
            allHeroArmorBonus: engine.runeTree.allHeroArmor
        ) ?? 0
        expect(
            engine.unlockRuneTreeNode(.allHeroArmorPercent1) &&
                engine.hero.defense == Int(ceil(Double(defenseBeforeShieldPercentRune) * (1.0 + RuneTree.allHeroArmorMultiplierBonus))) &&
                (engine.party.supportMembers.first?.supportDefense(
                    heroLevel: engine.hero.level,
                    allHeroArmorBonus: engine.runeTree.allHeroArmor,
                    allHeroArmorMultiplier: engine.runeTree.allHeroArmorMultiplier
                ) ?? 0) >= supportDefenseBeforeShieldPercentRune &&
                engine.currentBattle?.allHeroArmorMultiplier == engine.runeTree.allHeroArmorMultiplier,
            "Rune of the Shield percent scaffold refreshes main, support and active battle armor multipliers"
        )
        let attackBeforeSecondWarPercentRune = engine.hero.attack
        let supportAttackBeforeSecondWarPercentRune = engine.party.supportAttackPower(
            heroLevel: engine.hero.level,
            allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage,
            allHeroAttackDamageMultiplier: engine.runeTree.allHeroAttackDamageMultiplier
        )
        expect(
            engine.unlockRuneTreeNode(.allHeroAttackDamagePercent2) &&
                engine.runeTree.allHeroAttackDamageMultiplier == 1.0 + RuneTree.allHeroAttackDamageMultiplierBonus * 2.0 &&
                engine.hero.attack > attackBeforeSecondWarPercentRune &&
                engine.party.supportAttackPower(
                    heroLevel: engine.hero.level,
                    allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage,
                    allHeroAttackDamageMultiplier: engine.runeTree.allHeroAttackDamageMultiplier
                ) >= supportAttackBeforeSecondWarPercentRune &&
                engine.currentBattle?.allHeroAttackDamageMultiplier == engine.runeTree.allHeroAttackDamageMultiplier,
            "second Rune of War percent scaffold refreshes main, support and active battle attack multipliers"
        )
        expect(
            engine.unlockRuneTreeNode(.allHeroAttackSpeed1) &&
                engine.runeTree.allHeroAttackSpeedMultiplier == 1.0 + RuneTree.allHeroAttackSpeedMultiplierBonus &&
                engine.currentBattle?.allHeroAttackSpeedMultiplier == engine.runeTree.allHeroAttackSpeedMultiplier,
            "Rune of Frenzy refreshes the active battle attack-speed scaffold"
        )
        expect(
            engine.unlockRuneTreeNode(.allHeroAttackSpeed2) &&
                engine.runeTree.allHeroAttackSpeedMultiplier == 1.0 + RuneTree.allHeroAttackSpeedMultiplierBonus * 2.0 &&
                engine.currentBattle?.allHeroAttackSpeedMultiplier == engine.runeTree.allHeroAttackSpeedMultiplier,
            "second Rune of Frenzy refreshes the active battle attack-speed scaffold"
        )
        let defenseBeforeSecondShieldRune = engine.hero.defense
        let supportDefenseBeforeSecondShieldRune = engine.party.supportMembers.first?.supportDefense(
            heroLevel: engine.hero.level,
            allHeroArmorBonus: engine.runeTree.allHeroArmor,
            allHeroArmorMultiplier: engine.runeTree.allHeroArmorMultiplier
        ) ?? 0
        expect(
            engine.unlockRuneTreeNode(.allHeroArmor2) &&
                engine.runeTree.allHeroArmor == RuneTree.allHeroArmorBonus * 3 &&
                engine.hero.defense > defenseBeforeSecondShieldRune &&
                (engine.party.supportMembers.first?.supportDefense(
                    heroLevel: engine.hero.level,
                    allHeroArmorBonus: engine.runeTree.allHeroArmor,
                    allHeroArmorMultiplier: engine.runeTree.allHeroArmorMultiplier
                ) ?? 0) >= supportDefenseBeforeSecondShieldRune &&
                engine.currentBattle?.allHeroArmorBonus == engine.runeTree.allHeroArmor,
            "second Rune of the Shield refreshes main, support and active battle armor scaffolds"
        )
        let attackBeforeFourthWarRune = engine.hero.attack
        let supportAttackBeforeFourthWarRune = engine.party.supportAttackPower(
            heroLevel: engine.hero.level,
            allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage,
            allHeroAttackDamageMultiplier: engine.runeTree.allHeroAttackDamageMultiplier
        )
        expect(
            engine.unlockRuneTreeNode(.allHeroAttackDamage4) &&
                engine.runeTree.allHeroAttackDamage == RuneTree.allHeroAttackDamageBonus * 2 &&
                engine.hero.attack > attackBeforeFourthWarRune &&
                engine.party.supportAttackPower(
                    heroLevel: engine.hero.level,
                    allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage,
                    allHeroAttackDamageMultiplier: engine.runeTree.allHeroAttackDamageMultiplier
                ) >= supportAttackBeforeFourthWarRune &&
                engine.currentBattle?.allHeroAttackDamageBonus == engine.runeTree.allHeroAttackDamage,
            "fourth Rune of War refreshes main, support and active battle attack scaffolds"
        )
        let attackBeforeSecondWarRune = engine.hero.attack
        let supportAttackBeforeSecondWarRune = engine.party.supportAttackPower(
            heroLevel: engine.hero.level,
            allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage,
            allHeroAttackDamageMultiplier: engine.runeTree.allHeroAttackDamageMultiplier
        )
        expect(
            engine.unlockRuneTreeNode(.allHeroAttackDamage2) &&
                engine.runeTree.allHeroAttackDamage == RuneTree.allHeroAttackDamageBonus * 3 &&
                engine.hero.attack > attackBeforeSecondWarRune &&
                engine.party.supportAttackPower(
                    heroLevel: engine.hero.level,
                    allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage,
                    allHeroAttackDamageMultiplier: engine.runeTree.allHeroAttackDamageMultiplier
                ) >= supportAttackBeforeSecondWarRune &&
                engine.currentBattle?.allHeroAttackDamageBonus == engine.runeTree.allHeroAttackDamage,
            "second Rune of War refreshes main, support and active battle attack scaffolds"
        )
        let attackBeforeThirdWarRune = engine.hero.attack
        let supportAttackBeforeThirdWarRune = engine.party.supportAttackPower(
            heroLevel: engine.hero.level,
            allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage,
            allHeroAttackDamageMultiplier: engine.runeTree.allHeroAttackDamageMultiplier
        )
        expect(
            engine.unlockRuneTreeNode(.allHeroAttackDamage3) &&
                engine.runeTree.allHeroAttackDamage == RuneTree.allHeroAttackDamageBonus * 4 &&
                engine.hero.attack > attackBeforeThirdWarRune &&
                engine.party.supportAttackPower(
                    heroLevel: engine.hero.level,
                    allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage,
                    allHeroAttackDamageMultiplier: engine.runeTree.allHeroAttackDamageMultiplier
                ) >= supportAttackBeforeThirdWarRune &&
                engine.currentBattle?.allHeroAttackDamageBonus == engine.runeTree.allHeroAttackDamage,
            "third Rune of War refreshes main, support and active battle attack scaffolds"
        )
        let speedBeforeSecondGaleRune = engine.hero.speed
        let supportSpeedBeforeSecondGaleRune = engine.party.supportMembers.first?.supportSpeed(
            allHeroMoveSpeedBonus: engine.runeTree.allHeroMoveSpeed
        ) ?? 0
        expect(
            engine.unlockRuneTreeNode(.allHeroMoveSpeed2) &&
                engine.hero.speed == speedBeforeSecondGaleRune + RuneTree.allHeroMoveSpeedBonus &&
                (engine.party.supportMembers.first?.supportSpeed(allHeroMoveSpeedBonus: engine.runeTree.allHeroMoveSpeed) ?? 0) == supportSpeedBeforeSecondGaleRune + RuneTree.allHeroMoveSpeedBonus,
            "second Rune of the Gale refreshes main and support move-speed scaffolds"
        )
        let speedBeforeThirdGaleRune = engine.hero.speed
        let supportSpeedBeforeThirdGaleRune = engine.party.supportMembers.first?.supportSpeed(
            allHeroMoveSpeedBonus: engine.runeTree.allHeroMoveSpeed
        ) ?? 0
        expect(
            engine.unlockRuneTreeNode(.allHeroMoveSpeed3) &&
                engine.hero.speed == speedBeforeThirdGaleRune + RuneTree.allHeroMoveSpeedBonus &&
                (engine.party.supportMembers.first?.supportSpeed(allHeroMoveSpeedBonus: engine.runeTree.allHeroMoveSpeed) ?? 0) == supportSpeedBeforeThirdGaleRune + RuneTree.allHeroMoveSpeedBonus,
            "third Rune of the Gale refreshes main and support move-speed scaffolds"
        )
        let defenseBeforeSecondShieldPercentRune = engine.hero.defense
        let supportDefenseBeforeSecondShieldPercentRune = engine.party.supportMembers.first?.supportDefense(
            heroLevel: engine.hero.level,
            allHeroArmorBonus: engine.runeTree.allHeroArmor,
            allHeroArmorMultiplier: engine.runeTree.allHeroArmorMultiplier
        ) ?? 0
        expect(
            engine.unlockRuneTreeNode(.allHeroArmorPercent2) &&
                engine.runeTree.allHeroArmorMultiplier == 1.0 + RuneTree.allHeroArmorMultiplierBonus * 2.0 &&
                engine.hero.defense > defenseBeforeSecondShieldPercentRune &&
                (engine.party.supportMembers.first?.supportDefense(
                    heroLevel: engine.hero.level,
                    allHeroArmorBonus: engine.runeTree.allHeroArmor,
                    allHeroArmorMultiplier: engine.runeTree.allHeroArmorMultiplier
                ) ?? 0) >= supportDefenseBeforeSecondShieldPercentRune &&
                engine.currentBattle?.allHeroArmorMultiplier == engine.runeTree.allHeroArmorMultiplier,
            "second Rune of the Shield percent refreshes main, support and active battle armor multipliers"
        )
        let attackBeforeThirdWarPercentRune = engine.hero.attack
        let supportAttackBeforeThirdWarPercentRune = engine.party.supportAttackPower(
            heroLevel: engine.hero.level,
            allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage,
            allHeroAttackDamageMultiplier: engine.runeTree.allHeroAttackDamageMultiplier
        )
        expect(
            engine.unlockRuneTreeNode(.allHeroAttackDamagePercent3) &&
                engine.runeTree.allHeroAttackDamageMultiplier == 1.0 + RuneTree.allHeroAttackDamageMultiplierBonus * 3.0 &&
                engine.hero.attack > attackBeforeThirdWarPercentRune &&
                engine.party.supportAttackPower(
                    heroLevel: engine.hero.level,
                    allHeroAttackDamageBonus: engine.runeTree.allHeroAttackDamage,
                    allHeroAttackDamageMultiplier: engine.runeTree.allHeroAttackDamageMultiplier
                ) >= supportAttackBeforeThirdWarPercentRune &&
                engine.currentBattle?.allHeroAttackDamageMultiplier == engine.runeTree.allHeroAttackDamageMultiplier,
            "third Rune of War percent refreshes main, support and active battle attack multipliers"
        )
        expect(
            engine.unlockRuneTreeNode(.allHeroAttackSpeed3) &&
                engine.runeTree.allHeroAttackSpeedMultiplier == 1.0 + RuneTree.allHeroAttackSpeedMultiplierBonus * 3.0 &&
                engine.currentBattle?.allHeroAttackSpeedMultiplier == engine.runeTree.allHeroAttackSpeedMultiplier,
            "third Rune of Frenzy refreshes the active battle attack-speed scaffold"
        )
        expect(engine.inventory.maxCapacity == Inventory.baseCapacity, "engine inventory starts at the base capacity before expansion runes")
        expect(
            engine.unlockRuneTreeNode(.inventoryExpansion1) &&
                engine.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus,
            "Rune of Expansion refreshes engine inventory capacity"
        )
        expect(
            engine.unlockRuneTreeNode(.inventoryExpansion2) &&
                engine.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * 2,
            "second Rune of Expansion refreshes engine inventory capacity from the next checked source row"
        )
        var unlockedRemainingEngineInventoryExpansions = true
        for node in RuneTree.inventoryExpansionNodes.dropFirst(2) {
            unlockedRemainingEngineInventoryExpansions = engine.unlockRuneTreeNode(node) && unlockedRemainingEngineInventoryExpansions
        }
        expect(
            unlockedRemainingEngineInventoryExpansions &&
                engine.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * RuneTree.inventoryExpansionNodes.count,
            "all checked Rune of Expansion MaxInventorySlot rows refresh engine inventory capacity"
        )
        expect(
            engine.unlockRuneTreeNode(.stashPage1) &&
                engine.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * RuneTree.inventoryExpansionNodes.count + RuneTree.stashPageSlotBonus,
            "Rune of Storage refreshes engine inventory capacity with a source stash-page scaffold"
        )
        expect(
            engine.unlockRuneTreeNode(.stashPage2) &&
                engine.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * RuneTree.inventoryExpansionNodes.count + RuneTree.stashPageSlotBonus * 2,
            "second Rune of Storage refreshes engine inventory capacity from another checked stash-page row"
        )
        expect(
            engine.unlockRuneTreeNode(.stashPage3) &&
                engine.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * RuneTree.inventoryExpansionNodes.count + RuneTree.stashPageSlotBonus * 3,
            "third Rune of Storage refreshes engine inventory capacity from the final checked stash-page row"
        )
        engine.progress.restartCurrentStage()
        let battleBeforeBrevity = engine.currentBattle
        let baseClearTargetBeforeBrevity = engine.progress.currentStage.clearTarget(for: engine.progress.currentDifficulty)
        expect(
            engine.unlockRuneTreeNode(.waveCountReduction1) &&
                engine.runeTree.stageClearTargetReduction == RuneTree.stageClearTargetReductionBonus &&
                engine.progress.currentEncounterPlan(clearTargetReduction: engine.runeTree.stageClearTargetReduction).clearTarget == baseClearTargetBeforeBrevity - RuneTree.stageClearTargetReductionBonus &&
                (battleBeforeBrevity.map { before in engine.currentBattle.map { before !== $0 } ?? false } ?? false),
            "Rune of Brevity refreshes the active battle with a reduced runtime clear target"
        )
        engine.setPartyMember(slotIndex: 1, heroClass: .sorcerer)
        expect(engine.party.member(at: 1)?.heroClass == .sorcerer, "support party slot can change class")
        expect(engine.currentBattle?.party.member(at: 1)?.heroClass == .sorcerer, "party change refreshes active battle")
        engine.setPartyMember(slotIndex: 0, heroClass: .hunter)
        expect(engine.hero.heroClass == .hunter && engine.party.member(at: 0)?.heroClass == .hunter, "primary party slot stays synced with hero class")
        expect(engine.currentBattle?.primaryHeroClass == .hunter, "battle tab main hero art follows the synced primary hero class")

        engine.resetRuneTree()
        expect(
            engine.hero.gold == 200_000 &&
                engine.runeTree.unlockedNodes.isEmpty &&
                engine.runeTree.unlockedPartySlotCount == 1 &&
                engine.runeTree.activeSkillSlotCount == 1 &&
                engine.hero.runeAttackDamageBonus == 0 &&
                engine.hero.runeAttackDamageMultiplier == 1.0 &&
                engine.hero.runeArmorBonus == 0 &&
                engine.hero.runeArmorMultiplier == 1.0 &&
                engine.hero.runeMoveSpeedBonus == 0 &&
                engine.inventory.maxCapacity == Inventory.baseCapacity &&
                engine.party.activeCount == 1,
            "Rune Tree reset clears nodes, re-locks party, skill and inventory expansion state, and refunds checked formation gold"
        )
        expect(engine.nextInventoryExpansionGoldCost == 50_000, "first direct backpack expansion costs 50,000 gold")
        expect(engine.purchaseInventoryExpansion(), "direct backpack expansion can be purchased repeatedly from the inventory path")
        expect(
            engine.purchasedInventoryExpansionCount == 1 &&
                engine.hero.gold == 150_000 &&
                engine.inventory.maxCapacity == Inventory.baseCapacity + InventoryExpansion.slotBonus &&
                engine.nextInventoryExpansionGoldCost == 100_000,
            "first direct backpack expansion spends gold and adds capacity"
        )
        expect(engine.purchaseInventoryExpansion(), "second direct backpack expansion can be purchased")
        expect(
            engine.purchasedInventoryExpansionCount == 2 &&
                engine.hero.gold == 50_000 &&
                engine.inventory.maxCapacity == Inventory.baseCapacity + InventoryExpansion.slotBonus * 2 &&
                engine.nextInventoryExpansionGoldCost == 150_000 &&
                !engine.purchaseInventoryExpansion(),
            "direct backpack expansion has no one-time cap but still enforces escalating gold cost"
        )

        engine.progress.currentStageIndex = 7
        engine.progress.killsInChapter = 72
        engine.setHeroClass(.knight)
        expect(engine.currentBattle?.monsterCount == 6 && engine.currentBattle?.monster.name == "骷髅战士", "battle starts with remaining encounters in the current wave")

        engine.progress.currentStageIndex = 9
        engine.setHeroClass(.priest)
        expect(engine.currentBattle == nil && engine.battleLockReason?.contains("灵魂石") == true, "boss battle locks without Soul Stone")
        engine.progress.soulStones.grant(.normal)
        engine.setHeroClass(.ranger)
        expect(engine.currentBattle?.monster.name == "骷髅王" && engine.battleLockReason == nil, "boss battle starts with Soul Stone")

        engine.hero.gainGold(999)
        let didReset = engine.resetGame()
        expect(engine.hero.gold == 0 && engine.hero.level == 1 && engine.inventory.items.isEmpty, "resetGame clears state")
        expect(engine.cubeProgress.totalExperience == 0 && engine.cubeProgress.infusedItemCount == 0, "resetGame clears Cube progress")
        expect(
                engine.runeTree.unlockedPartySlotCount == 1 &&
                engine.runeTree.activeSkillSlotCount == 1 &&
                engine.hero.runeAttackDamageBonus == 0 &&
                engine.hero.runeArmorBonus == 0 &&
                engine.purchasedInventoryExpansionCount == 0 &&
                engine.inventory.maxCapacity == Inventory.baseCapacity &&
                engine.worseEquipmentHandling == .keep &&
                engine.party.activeCount == 1,
            "resetGame restores Rune Tree party, active skill and direct inventory expansion locks"
        )
        expect(engine.soundEffectsEnabled, "resetGame restores default sound effects setting")
        expect(
            engine.activeSkillLoadouts.activeSkills(for: .knight, heroLevel: 1, slotCount: 1).map(\.id) == ["10101"],
            "resetGame clears selected active skill loadouts"
        )

        let reloadedAfterReset = GameEngine(saveManager: saveManager, audio: SilentAudio())
        reloadedAfterReset.start()
        reloadedAfterReset.stop()
        expect(didReset && saveManager.saveFileExists, "resetGame deletes the old save and writes a clean replacement save")
        expect(
            reloadedAfterReset.hero.level == 1 &&
                reloadedAfterReset.hero.gold == 0 &&
                reloadedAfterReset.statistics.monstersKilled == 0 &&
                reloadedAfterReset.inventory.items.isEmpty,
            "resetGame clean save reloads without stale high-level data"
        )
    }

    private static func gameEngineRuntimeLoop() {
        print("[GameEngine runtime]")

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHSelfTest-Runtime-\(UUID().uuidString)", isDirectory: true)
        let audio = SilentAudio()
        let engine = GameEngine(saveManager: SaveManager(directory: tempDir), audio: audio)
        engine.setInterfaceAudioActive(true)
        let trainingSword = Item(
            id: "runtime-training-sword",
            name: "运行链路训练剑",
            rarity: .common,
            slot: .weapon,
            stats: ItemStats(bonusATK: 2_000, bonusSPD: 20),
            description: "",
            equipmentType: .sword
        )
        _ = engine.hero.equipment.equip(trainingSword)

        engine.setHeroClass(.knight)
        guard let firstBattle = engine.currentBattle else {
            expect(false, "runtime tick starts an active battle")
            return
        }

        let startStage = engine.progress.currentStage.displayCode
        let startKills = engine.progress.killsInChapter
        let startGold = engine.hero.gold
        let startLevel = engine.hero.level
        let startXP = engine.hero.currentXP
        let startPlayTime = engine.statistics.totalPlayTime
        let expectedPacedRuntimeXP = GamePacing.pacedXP(
            from: firstBattle.waveMonsters.map(\.xpReward).reduce(0, +)
        )
        audio.clearEvents()
        let displayedRewards = engine.previewVictoryRewards(
            BattleResult.Rewards(xp: 100, gold: 100, lootItem: nil)
        )
        expect(
            displayedRewards.xp == 35 &&
                displayedRewards.gold == 100 &&
                engine.hero.currentXP == startXP,
            "battle victory reward preview displays XP after pacing without applying it early"
        )

        var ticks = 0
        while engine.statistics.monstersKilled == 0 && ticks < 5 {
            engine.runSelfTestTick()
            ticks += 1
        }

        let battleRestarted = engine.currentBattle.map { $0 !== firstBattle } ?? false
        let gainedProgress = engine.progress.killsInChapter > startKills ||
            engine.progress.currentStage.displayCode != startStage
        let lootFound = engine.statistics.itemsFound > 0
        let lootSoundPlayed = audio.events.contains(.lootFound)
        let combatSoundPlayed = audio.events.contains { event in
            event == .heroAttack || event == .heroCriticalHit || event == .skillCast
        }
        let retainedDamageLog = engine.recentBattleLog.contains { entry in
            entry.kind == .damage && entry.damage > 0
        }

        expect(ticks > 0 && ticks <= 5, "runtime tick loop reaches a terminal battle state")
        expect(engine.statistics.monstersKilled == 1, "runtime victory records the cleared encounter")
        expect(gainedProgress, "runtime victory advances stage encounter progress")
        expect(engine.hero.gold > startGold && engine.statistics.totalGoldEarned > 0, "runtime victory applies mined gold rewards")
        expect(
            engine.hero.level == startLevel &&
                engine.hero.currentXP - startXP == expectedPacedRuntimeXP &&
                expectedPacedRuntimeXP < firstBattle.waveMonsters.map(\.xpReward).reduce(0, +),
            "runtime victory applies mined XP through GamePacing before hero leveling"
        )
        expect(engine.statistics.totalPlayTime > startPlayTime, "runtime tick accumulates play time")
        expect(battleRestarted, "runtime victory starts the next battle after settlement")
        expect(audio.events.contains(.battleWon), "runtime battle victory emits the battle-won sound event")
        expect(combatSoundPlayed, "runtime battle tick emits combat sound events before settlement")
        expect(retainedDamageLog, "runtime retains recent damage log entries after battle refresh for UI animation and log scrolling")
        expect(lootFound == lootSoundPlayed, "runtime loot-found sound matches retained battle loot")

        let rewardTempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHSelfTest-RewardRunes-\(UUID().uuidString)", isDirectory: true)
        let rewardEngine = GameEngine(saveManager: SaveManager(directory: rewardTempDir), audio: SilentAudio())
        rewardEngine.setInterfaceAudioActive(true)
        rewardEngine.hero.gainXP(400)
        _ = rewardEngine.hero.equipment.equip(trainingSword)
        rewardEngine.setHeroClass(.knight)
        expect(
            rewardEngine.unlockRuneTreeNode(.combatGoldBoost1) &&
                rewardEngine.unlockRuneTreeNode(.combatXPBoost1) &&
                rewardEngine.unlockRuneTreeNode(.additionalGoldStageBoss1) &&
                rewardEngine.unlockRuneTreeNode(.additionalXPStageBoss1),
            "combat reward source runes unlock in the engine"
        )
        let rewardStartXP = rewardEngine.hero.currentXP
        var rewardTicks = 0
        while rewardEngine.statistics.monstersKilled == 0 && rewardTicks < 5 {
            rewardEngine.runSelfTestTick()
            rewardTicks += 1
        }
        expect(
            rewardEngine.hero.gold == 168 &&
                rewardEngine.statistics.totalGoldEarned == 168,
            "Rune of Wealth and AdditionalGold combat reward scaffolds increase stage-leader victory gold"
        )
        expect(
            rewardEngine.hero.currentXP > rewardStartXP,
            "Rune of Growth and AdditionalExp combat reward scaffolds increase stage-leader victory XP before level-cap pacing"
        )
    }

    private static func gameAudioRoutes() {
        print("[GameAudio]")

        let battleRoutes: [(BattleEvent, GameAudioEvent)] = [
            (.heroAttack(isCrit: false), .heroAttack),
            (.heroAttack(isCrit: true), .heroCriticalHit),
            (.heroSkill(skillName: "测试技能", isCrit: false), .skillCast),
            (.heroSkill(skillName: "测试技能", isCrit: true), .heroCriticalHit),
            (.supportAttack(isCrit: false), .heroAttack),
            (.supportAttack(isCrit: true), .heroCriticalHit),
            (.supportSkill(heroClass: .priest, skillName: "治愈", isCrit: false), .skillCast),
            (.supportSkill(heroClass: .priest, skillName: "治愈", isCrit: true), .heroCriticalHit),
            (.heroDamaged(isCrit: false), .heroDamaged),
            (.heroDamaged(isCrit: true), .heroDamaged),
            (.battleWon(hasLoot: false), .battleWon),
            (.battleWon(hasLoot: true), .battleWon),
            (.battleLost, .battleLost)
        ]

        expect(
            battleRoutes.allSatisfy { GameEngine.audioEvent(for: $0.0) == $0.1 },
            "battle events route to the expected sound-effect events"
        )
        expect(
            Set(GameAudioEvent.bundledResourceNames).count == GameAudioEvent.allCases.count,
            "each sound-effect event owns a unique bundled WAV resource name"
        )

        let volumeProfiles: [GameAudioEvent: ClosedRange<Float>] = [
            .heroAttack: 0.32...0.50,
            .heroCriticalHit: 0.32...0.50,
            .skillCast: 0.32...0.50,
            .heroDamaged: 0.32...0.50,
            .battleWon: 0.36...0.55,
            .lootFound: 0.28...0.44,
            .battleLost: 0.36...0.55,
            .levelUp: 0.36...0.55,
            .itemEquipped: 0.28...0.44,
            .itemConsumed: 0.28...0.44,
            .preview: 0.28...0.44
        ]
        expect(
            Set(volumeProfiles.keys) == Set(GameAudioEvent.allCases),
            "each sound-effect event has a local playback volume profile"
        )
        expect(
            GameAudioEvent.allCases.allSatisfy { event in
                volumeProfiles[event]?.contains(event.volume) == true
            },
            "sound-effect playback volumes stay within local SFX profile ranges"
        )

        let minimumIntervalProfiles: [GameAudioEvent: ClosedRange<TimeInterval>] = [
            .heroAttack: 0.12...0.25,
            .heroCriticalHit: 0.12...0.25,
            .skillCast: 0.12...0.28,
            .heroDamaged: 0.12...0.25,
            .battleWon: 0.40...0.80,
            .lootFound: 0.18...0.35,
            .battleLost: 0.40...0.80,
            .levelUp: 0.40...0.80,
            .itemEquipped: 0.18...0.35,
            .itemConsumed: 0.18...0.35,
            .preview: 0.18...0.35
        ]
        expect(
            Set(minimumIntervalProfiles.keys) == Set(GameAudioEvent.allCases),
            "each sound-effect event has a local minimum playback interval profile"
        )
        expect(
            GameAudioEvent.allCases.allSatisfy { event in
                minimumIntervalProfiles[event]?.contains(event.minimumInterval) == true
            },
            "sound-effect minimum playback intervals stay within local SFX profile ranges"
        )

        let repeatableCombatIntervals = [
            GameAudioEvent.heroAttack.minimumInterval,
            GameAudioEvent.heroCriticalHit.minimumInterval,
            GameAudioEvent.skillCast.minimumInterval,
            GameAudioEvent.heroDamaged.minimumInterval
        ]
        let terminalIntervals = [
            GameAudioEvent.battleWon.minimumInterval,
            GameAudioEvent.battleLost.minimumInterval,
            GameAudioEvent.levelUp.minimumInterval
        ]
        expect(
            (terminalIntervals.min() ?? 0) > (repeatableCombatIntervals.max() ?? 0),
            "terminal and progression sound effects are throttled longer than repeatable combat effects"
        )

        let inventoryAndPreviewVolumes = [
            GameAudioEvent.lootFound.volume,
            GameAudioEvent.itemEquipped.volume,
            GameAudioEvent.itemConsumed.volume,
            GameAudioEvent.preview.volume
        ]
        let terminalVolumes = [
            GameAudioEvent.battleWon.volume,
            GameAudioEvent.battleLost.volume,
            GameAudioEvent.levelUp.volume
        ]
        expect(
            (terminalVolumes.min() ?? 0) >= (inventoryAndPreviewVolumes.max() ?? 0),
            "terminal and progression sound effects are not quieter than inventory and preview cues"
        )

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHSelfTest-Audio-\(UUID().uuidString)", isDirectory: true)
        let audio = SilentAudio()
        let engine = GameEngine(saveManager: SaveManager(directory: tempDir), audio: audio)

        engine.previewSoundEffect()
        expect(audio.events.isEmpty, "closed menu-bar interface suppresses sound-effect playback")
        expect(audio.isEnabled, "interface mute does not overwrite the persisted sound-effect toggle")
        engine.setInterfaceAudioActive(true)
        engine.previewSoundEffect()
        expect(audio.events == [.preview], "open menu-bar interface allows the settings preview sound event")
        audio.clearEvents()

        let sword = Item(
            id: "audio-sword",
            name: "音效测试剑",
            rarity: .common,
            slot: .weapon,
            stats: ItemStats(bonusATK: 1),
            description: "",
            equipmentType: .sword
        )
        engine.inventory.add(sword)
        engine.equipItem(sword)
        expect(audio.events == [.itemEquipped], "manual equipment changes emit the item-equipped sound event")
        audio.clearEvents()

        let cubeItem = Item(
            id: "audio-cube-item",
            name: "音效 Cube 材料",
            rarity: .rare,
            slot: nil,
            stats: ItemStats(),
            description: ""
        )
        engine.inventory.add(cubeItem)
        let cubeXP = engine.infuseItemIntoCube(cubeItem)
        expect(
            cubeXP == Rarity.rare.cubeExperience && audio.events == [.itemConsumed],
            "Cube infusion emits the item-consumed sound event"
        )
        audio.clearEvents()

        let alchemyItem = Item(
            id: "audio-alchemy-item",
            name: "音效炼金材料",
            rarity: .rare,
            slot: nil,
            stats: ItemStats(),
            description: ""
        )
        engine.inventory.add(alchemyItem)
        let alchemyGold = engine.alchemizeItem(alchemyItem)
        expect(
            alchemyGold == Rarity.rare.alchemyGoldValue && audio.events == [.itemConsumed],
            "Alchemy emits the item-consumed sound event"
        )
        audio.clearEvents()

        engine.progress.chests.add(LootChest(
            kind: .normal,
            itemLevel: 1,
            sourceStageCode: "1-1",
            sourceDifficulty: .normal
        ))
        expect(engine.openChest(kind: .normal), "test chest can be opened")
        expect(audio.events == [.lootFound], "opening a chest emits the loot-found sound event")
        audio.clearEvents()

        for index in 0..<Rarity.synthesisInputCount {
            engine.inventory.add(Item(
                id: "audio-synthesis-\(index)",
                name: "音效合成材料 \(index)",
                rarity: .common,
                slot: .weapon,
                stats: ItemStats(bonusATK: index + 1),
                description: "",
                itemLevel: 1,
                equipmentType: .sword
            ))
        }
        let synthesized = engine.synthesizeItems(rarity: .common)
        expect(
            synthesized != nil && audio.events == [.lootFound],
            "successful Synthesis emits the loot-found sound event"
        )
        audio.clearEvents()

        engine.setSoundEffectsEnabled(false)
        engine.previewSoundEffect()
        let mutedSword = Item(
            id: "audio-muted-sword",
            name: "静音测试剑",
            rarity: .rare,
            slot: .weapon,
            stats: ItemStats(bonusATK: 2),
            description: "",
            equipmentType: .sword
        )
        engine.inventory.add(mutedSword)
        engine.equipItem(mutedSword)
        expect(
            !audio.isEnabled && audio.events.isEmpty,
            "disabled sound effects suppress preview and inventory sound events"
        )

        engine.setSoundEffectsEnabled(true)
        engine.previewSoundEffect()
        expect(audio.isEnabled && audio.events == [.preview], "re-enabled sound effects resume event playback")
        audio.clearEvents()
        engine.setInterfaceAudioActive(false)
        engine.previewSoundEffect()
        expect(audio.isEnabled && audio.events.isEmpty, "closing the menu-bar interface mutes playback without disabling sound effects")

        let levelAudio = SilentAudio()
        let levelManager = SaveManager(directory: tempDir.appendingPathComponent("LevelUp", isDirectory: true))
        levelManager.save(SaveData(
            hero: Hero(),
            runeTree: RuneTree(unlockedNodes: [.offlineRewards]),
            inventory: Inventory(),
            progress: ProgressTracker(),
            statistics: GameStatistics(),
            timestamp: Date().addingTimeInterval(-OfflineProgress.maxOfflineSeconds - 120)
        ))
        let levelEngine = GameEngine(saveManager: levelManager, audio: levelAudio)
        levelEngine.setInterfaceAudioActive(true)
        levelEngine.start()
        levelEngine.stop()
        expect(
            levelEngine.hero.level > 1 && levelAudio.events.contains(.levelUp),
            "offline level gain emits the level-up sound event"
        )
    }

    private static func saveRoundTrip() {
        print("[SaveManager]")
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHSelfTest-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)
        let hero = Hero()
        hero.gainGold(123)
        hero.unlockedPassiveSkillIDs = ["101001", "101002"]
        var runeTree = RuneTree(unlockedPartySlotCount: 2)
        runeTree.unlockedNodes.insert(.activeSkillSlot2)
        runeTree.unlockedNodes.insert(.inventoryExpansion1)
        var party = HeroParty(primaryClass: .priest)
        party.setHeroClass(.sorcerer, atSlot: 1)
        var progress = ProgressTracker()
        progress.soulStones.grant(.normal)
        progress.chests.add(LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal))
        progress.playthrough = 2
        progress.completedPlaythroughs = 1
        progress.isAwaitingNewGamePlus = true
        let inventory = Inventory()
        inventory.add(Item(id: "locked", name: "锁定剑", rarity: .arcana, slot: .weapon, stats: ItemStats(bonusATK: 1), description: "", isLocked: true))
        var cubeProgress = CubeProgress()
        _ = cubeProgress.infuse(Item(id: "cube", name: "Cube 材料", rarity: .rare, slot: nil, stats: ItemStats(), description: ""))
        var activeSkillLoadouts = ActiveSkillLoadouts()
        activeSkillLoadouts.setSkill("40301", for: .priest, slotIndex: 0)
        let autoOpenCooldowns = AutoOpenChestCooldowns(
            normalMonsterRemaining: 123,
            stageBossRemaining: 456,
            actBossRemaining: 12
        )
        manager.save(SaveData(hero: hero, party: party, runeTree: runeTree, cubeProgress: cubeProgress, purchasedInventoryExpansionCount: 2, activeSkillLoadouts: activeSkillLoadouts, inventory: inventory, progress: progress, statistics: GameStatistics(), autoOpenChestCooldowns: autoOpenCooldowns, autoEquipBestItems: true, worseEquipmentHandling: .alchemize, soundEffectsEnabled: false, unyieldingWillConsumedStageKey: "4:3-9", timestamp: Date()))
        let loaded = manager.load()
        expect(loaded?.hero.gold == 123, "save/load round trip preserves data")
        expect(loaded?.hero.unlockedPassiveSkillIDs == ["101001", "101002"], "save/load round trip preserves unlocked passive skill IDs")
        expect(loaded?.party.member(at: 0)?.heroClass == .priest && loaded?.party.member(at: 1)?.heroClass == .sorcerer, "save/load round trip preserves party")
        expect(loaded?.runeTree.unlockedPartySlotCount == 2 && loaded?.party.activeCount == 2, "save/load round trip preserves Rune Tree party unlocks")
        expect(loaded?.runeTree.activeSkillSlotCount == 2, "save/load round trip preserves Rune Tree active skill slot unlocks")
        expect(
            loaded?.runeTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus &&
                loaded?.purchasedInventoryExpansionCount == 2 &&
                loaded?.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus + InventoryExpansion.slotBonus * 2,
            "save/load round trip derives inventory capacity from Rune Tree and purchased backpack expansions"
        )
        expect(loaded?.cubeProgress.totalExperience == Rarity.rare.cubeExperience, "save/load round trip preserves Cube progress")
        expect(loaded?.activeSkillLoadouts.activeSkills(for: .priest, heroLevel: 1, slotCount: 1).map(\.id) == ["40301"], "save/load round trip preserves active skill loadout")
        expect(loaded?.inventory.items.first?.isLocked == true, "save/load round trip preserves item lock state")
        expect(loaded?.autoOpenChestCooldowns == autoOpenCooldowns, "save/load round trip preserves auto-open chest cooldowns")
        expect(loaded?.autoEquipBestItems == true, "save/load round trip preserves auto equip toggle")
        expect(loaded?.worseEquipmentHandling == .alchemize, "save/load round trip preserves worse equipment handling")
        expect(loaded?.soundEffectsEnabled == false, "save/load round trip preserves sound effects toggle")
        expect(loaded?.unyieldingWillConsumedStageKey == "4:3-9", "save/load round trip preserves Unyielding Will stage consumption")
        expect(loaded?.progress.soulStones.count(for: .normal) == 1, "save/load round trip preserves Soul Stones")
        expect(loaded?.progress.chests.count(for: .normal) == 1, "save/load round trip preserves chests")
        expect(
            loaded?.progress.playthrough == 2 &&
                loaded?.progress.completedPlaythroughs == 1 &&
                loaded?.progress.isAwaitingNewGamePlus == true,
            "save/load round trip preserves playthrough settlement state"
        )

        let engine = GameEngine(saveManager: manager, audio: SilentAudio())
        engine.start()
        engine.stop()
        expect(
            engine.purchasedInventoryExpansionCount == 2 &&
                engine.worseEquipmentHandling == .alchemize &&
                engine.autoOpenChestCooldowns == autoOpenCooldowns &&
                engine.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus + InventoryExpansion.slotBonus * 2 &&
                engine.progress.isAwaitingNewGamePlus &&
                engine.currentBattle == nil,
            "GameEngine load derives inventory capacity, preserves settings and keeps completion settlement paused"
        )

        let staleTempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHSelfTest-StaleLevel-\(UUID().uuidString)", isDirectory: true)
        let staleManager = SaveManager(directory: staleTempDir)
        let staleHero = Hero()
        staleHero.level = 999
        staleHero.currentXP = -50
        staleHero.currentHP = 999_999
        staleManager.save(SaveData(
            hero: staleHero,
            inventory: Inventory(),
            progress: ProgressTracker(),
            statistics: GameStatistics(),
            timestamp: Date().addingTimeInterval(-120)
        ))
        let staleEngine = GameEngine(saveManager: staleManager, audio: SilentAudio())
        staleEngine.start()
        let normalizedStaleSave = staleManager.load()
        staleEngine.stop()
        let staleCap = HeroLevelPacing.maxHeroLevel(for: ProgressTracker())
        expect(
            staleEngine.hero.level == staleCap &&
                staleEngine.hero.currentXP == 0 &&
                staleEngine.hero.currentHP == staleEngine.hero.maxHP &&
                normalizedStaleSave?.hero.level == staleCap &&
                normalizedStaleSave?.hero.currentXP == 0 &&
                normalizedStaleSave?.hero.currentHP == staleEngine.hero.maxHP,
            "GameEngine startup clamps and persists stale over-cap hero saves after offline timestamp checks"
        )
    }
}
#endif
