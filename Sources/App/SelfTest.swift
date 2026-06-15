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
        private(set) var events: [GameAudioEvent] = []

        func play(_ event: GameAudioEvent) {
            guard isEnabled else { return }
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

    static func runAll() -> Never {
        print("=== TBH Self Test ===")

        damageCalculator()
        tabBarIcons()
        controlsFidelity()
        heroArtMappings()
        skillArtMappings()
        runeTreeArtMappings()
        battleSceneMetrics()
        battleSceneSnapshot()
        playerBattleStatusBadges()
        playerBattleDeployables()
        battleImpactCues()
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
            MenuBarPopoverLayout.normalizedScale(0.01) == MenuBarPopoverLayout.minimumScale &&
                MenuBarPopoverLayout.normalizedScale(99) == MenuBarPopoverLayout.maximumScale,
            "panel scale clamps to the supported macOS menu-bar translation range"
        )
        expect(
            minimumSize.width < defaultSize.width &&
                maximumSize.width > defaultSize.width &&
                minimumSize.height < defaultSize.height &&
                maximumSize.height > defaultSize.height,
            "panel scale changes preserve proportional popover dimensions"
        )
        expect(
            MenuBarPopoverLayout.scaleStep == 0.05,
            "panel scale uses deterministic five-percent steps"
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
            mappedIcons.allSatisfy { $0.hasPrefix("rune_") },
            "modeled Rune Tree nodes resolve to bundled rune_* artwork"
        )
        expect(
            Set(mappedIcons).count == GameArt.runeTreeIconNames.count,
            "Rune Tree icon mapping covers the current bundled rune art subset"
        )
        expect(
            GameArt.runeTreeIconName(for: .partySlot2) == GameArt.runeTreeIconName(for: .partySlot3) &&
                GameArt.runeTreeIconName(for: .partySlot2) == "rune_party_slot",
            "Rune of Command formation slots share the party-slot icon"
        )
        expect(
            GameArt.runeTreeIconName(for: .activeSkillSlot2) == "rune_active_skill_slot" &&
                GameArt.runeTreeIconName(for: .inventoryExpansion1) == "rune_inventory_capacity" &&
                GameArt.runeTreeIconName(for: .openOneChestType) == "rune_open_one_chest_type" &&
                GameArt.runeTreeIconName(for: .openAllChestTypes) == "rune_open_all_chest_types" &&
                GameArt.runeTreeIconName(for: .offlineRewards) == "rune_offline_rewards" &&
                GameArt.runeTreeIconName(for: .offlineGoldBoost) == "rune_offline_gold" &&
                GameArt.runeTreeIconName(for: .offlineXPBoost) == "rune_offline_xp",
            "modeled active-skill, inventory, chest-opening and offline Rune Tree nodes keep category-specific icons"
        )
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
            popoverRatio >= 4.20 && ratioDelta <= 0.08,
            "popover battle scene stays close to the official horizontal strip ratio"
        )
        expect(
            BattleSceneMetrics.compactHeight <= 76,
            "battle scene keeps a compact taskbar-style height"
        )
        expect(
            BattleSceneMetrics.groundHeightRatio >= 0.20 &&
                BattleSceneMetrics.groundHeightRatio <= 0.30,
            "battle scene reserves most vertical space for dark negative space above the lane"
        )
        expect(
            BattleSceneMetrics.groundPlatformWidthRatio >= 0.68 &&
                BattleSceneMetrics.groundPlatformWidthRatio <= 0.73,
            "battle scene uses the official-style short central ground platform"
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
        let damageFixtures: [BattleSceneSnapshot.Fixture] = [
            .explosiveBolt,
            .meteorStrike,
            .lightningStrike,
            .trapBurst,
            .summonProjectile,
            .shockCurrent,
            .shieldCharge,
            .slamJump,
            .earthquakeImpact,
            .shockwaveImpact
        ]
        let utilityFixtures: [BattleSceneSnapshot.Fixture] = [
            .healUtility,
            .resurrectionUtility,
            .shieldUtility,
            .sacredBladeUtility
        ]
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
        let heroClassOutputURLs = HeroClass.allCases.map { heroClass in
            (
                heroClass,
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("tbh-self-test-battle-scene-\(heroClass)-\(UUID().uuidString).png")
            )
        }

        do {
            try BattleSceneSnapshot.render(to: outputURL, fixedBackdropTime: 0)
            try BattleSceneSnapshot.render(to: motionOutputURL, fixedBackdropTime: 0.25)
            try BattleSceneSnapshot.render(
                to: statusRowOutputURL,
                fixture: .playerStatusRow
            )
            try BattleSceneSnapshot.render(
                to: crowdedStatusRowOutputURL,
                fixture: .playerStatusRowCrowded
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
            let damageData = try damageOutputURLs.map { try Data(contentsOf: $0.1) }
            let utilityData = try utilityOutputURLs.map { try Data(contentsOf: $0.1) }
            let heroClassData = try heroClassOutputURLs.map { try Data(contentsOf: $0.1) }
            let pngSize = pngDimensions(data: data)
            let motionPNGSize = pngDimensions(data: motionData)
            let statusRowPNGSize = pngDimensions(data: statusRowData)
            let crowdedStatusRowPNGSize = pngDimensions(data: crowdedStatusRowData)
            let damagePNGSizes = damageData.map(pngDimensions(data:))
            let utilityPNGSizes = utilityData.map(pngDimensions(data:))
            let heroClassPNGSizes = heroClassData.map(pngDimensions(data:))
            expect(
                pngSize?.width == 620 &&
                    pngSize?.height == 144 &&
                    motionPNGSize?.width == 620 &&
                    motionPNGSize?.height == 144 &&
                    statusRowPNGSize?.width == 620 &&
                    statusRowPNGSize?.height == 56 &&
                    crowdedStatusRowPNGSize?.width == 620 &&
                    crowdedStatusRowPNGSize?.height == 56 &&
                    damagePNGSizes.allSatisfy { $0?.width == 620 && $0?.height == 144 } &&
                    utilityPNGSizes.allSatisfy { $0?.width == 620 && $0?.height == 144 } &&
                    heroClassPNGSizes.allSatisfy { $0?.width == 620 && $0?.height == 144 } &&
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
        } catch {
            expect(false, "battle scene snapshot renderer produces an audit-ready PNG: \(error.localizedDescription)")
        }

        try? FileManager.default.removeItem(at: outputURL)
        try? FileManager.default.removeItem(at: motionOutputURL)
        try? FileManager.default.removeItem(at: statusRowOutputURL)
        try? FileManager.default.removeItem(at: crowdedStatusRowOutputURL)
        for (_, url) in damageOutputURLs {
            try? FileManager.default.removeItem(at: url)
        }
        for (_, url) in utilityOutputURLs {
            try? FileManager.default.removeItem(at: url)
        }
        for (_, url) in heroClassOutputURLs {
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
            ) == nil,
            "ordinary melee damage entries do not render movement trajectory cues"
        )
        expect(
            BattleTrajectoryCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "粉碎强击")
            ) == nil,
            "Crushing Blow's primary melee hit does not render the shockwave trajectory cue"
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
                for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "神圣之刃", kind: .buff)
            ) == .sacredBladeGlow,
            "Sacred Blade exposes a dedicated utility cue"
        )
        expect(
            BattleUtilityCue.visible(
                for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "将军怒吼", kind: .buff)
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
                coldDamageLog.damageElement == .cold &&
                coldDamageLog.delivery == .projectileAOE &&
                trapExplosionLog.damageElement == .physical &&
                trapExplosionLog.delivery == .trap,
            "battle log entries infer element and delivery metadata for visual combat feedback"
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
        expect(
            shieldChargeBattle.log.filter { $0.skillName == "盾牌冲锋" && $0.kind == .damage }.count >= 3 &&
                shieldChargeBattle.enemyStates.allSatisfy { $0.hp < $0.maxHP },
            "Shield Charge applies checked melee collision damage across the live wave scaffold"
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

        let ranger = Hero()
        ranger.changeClass(to: .ranger)
        let swiftSurgeMonster = Monster(
            id: "swift-surge-training",
            name: "迅捷觉醒训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let swiftSurgeBattle = Battle(hero: ranger, monster: swiftSurgeMonster, party: HeroParty(primaryClass: .ranger))
        for _ in 0..<3 {
            swiftSurgeBattle.update(deltaTime: 1)
        }
        expect(
            swiftSurgeBattle.activeBuffNames.contains("迅捷觉醒") &&
                swiftSurgeBattle.activeHeroAttackSpeedMultiplier == 6.0,
            "Swift Surge applies its checked +500% attack-speed buff"
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
            supportRapidFireBattle.log.filter {
                $0.attacker == .support(.ranger) &&
                    $0.skillName == "快速射击" &&
                    $0.kind == .damage
            }.count >= 2 &&
                !supportRapidFireBattle.log.contains {
                    $0.attacker == .hero &&
                        $0.skillName == "快速射击"
                },
            "support attack-count skills trigger from support attacks instead of the main hero skill path"
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
        blessingBattle.update(deltaTime: 1)
        let monsterDamage = blessingBattle.log.last { $0.attacker == .monster }?.damage ?? 999
        expect(monsterDamage <= 76, "guardian blessing reduces incoming monster damage")

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
                range: 700
            ),
            "source skill catalog keeps checked monster chaos skill rows"
        )
        expect(
            SourceSkillCatalog.runtimeModeledSkillIDs.count == 36 &&
                SourceSkillCatalog.runtimeModeledSkillIDs.allSatisfy { SourceSkillCatalog.skill(id: $0) != nil },
            "all runtime-modeled named hero active skills are present in the source catalog"
        )
        expect(
            SourceSkillCatalog.runtimeModeledSkills.count == 36,
            "source skill catalog distinguishes runtime-modeled skills from unimplemented source rows"
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
            SourceRuneCatalog.byID[RuneTreeNode.partySlot2.sourceRuneID]?.enName == "Rune of Command" &&
                SourceRuneCatalog.byID[RuneTreeNode.partySlot3.sourceRuneID]?.enName == "Rune of Command" &&
                SourceRuneCatalog.byID[RuneTreeNode.activeSkillSlot2.sourceRuneID]?.enName == "Rune of Awakening",
            "formation and active-skill runtime runes resolve to checked source rows"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.inventoryExpansion1.sourceRuneID]?.enName == "Rune of Expansion" &&
                SourceRuneCatalog.byID[RuneTreeNode.inventoryExpansion1.sourceRuneID]?.iconName == "MaxInventorySlot",
            "inventory expansion runtime rune resolves to a checked MaxInventorySlot source row"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.offlineRewards.sourceRuneID]?.iconName == "UnlockOfflineReward" &&
                SourceRuneCatalog.byID[RuneTreeNode.offlineGoldBoost.sourceRuneID]?.iconName == "OfflineRewardGoldPercent" &&
                SourceRuneCatalog.byID[RuneTreeNode.offlineXPBoost.sourceRuneID]?.iconName == "OfflineRewardExpPercent",
            "offline runtime runes resolve to checked source rows and icon families"
        )
        expect(
            SourceRuneCatalog.byID[RuneTreeNode.openOneChestType.sourceRuneID]?.iconName == "OpenOneTypeChestAllAtOnce" &&
                SourceRuneCatalog.byID[RuneTreeNode.openAllChestTypes.sourceRuneID]?.iconName == "OpenAllTypeChestAllAtOnce",
            "chest-opening runtime runes resolve to checked source rows and icon families"
        )
        expect(
            RuneTreeNode.partySlot2.goldCost == 50_000 &&
                RuneTreeNode.partySlot3.goldCost == 150_000,
            "Rune of Command party slots use checked gold costs"
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
        expect(!RuneTreeNode.inventoryExpansion1.hasVerifiedGoldCost && RuneTreeNode.inventoryExpansion1.costText == "成本待核对", "Rune of Expansion inventory cost remains explicitly unverified")
        var inventoryTree = RuneTree()
        expect(!inventoryTree.canUnlock(.inventoryExpansion1, heroLevel: 3, availableGold: 0), "Rune of Expansion inventory capacity requires the modeled party-slot prerequisite")
        expect(inventoryTree.unlock(.partySlot2, heroLevel: 3, availableGold: 50_000), "Rune of Expansion prerequisite can be unlocked first")
        expect(
            inventoryTree.unlock(.inventoryExpansion1, heroLevel: 3, availableGold: 0) &&
                inventoryTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus,
            "Rune of Expansion inventory scaffold increases backpack capacity"
        )
        expect(!RuneTreeNode.offlineRewards.hasVerifiedGoldCost && RuneTreeNode.offlineRewards.costText == "成本待核对", "Rune of Repose cost remains explicitly unverified")
        expect(!tree.canUnlock(.offlineRewards, heroLevel: 2, availableGold: 0), "Rune of Repose follows the level 3 Rune Tree gate")
        expect(tree.unlock(.offlineRewards, heroLevel: 3, availableGold: 0) && tree.offlineRewardsUnlocked, "Rune of Repose unlocks offline rewards without inventing a gold cost")
        expect(
            !RuneTreeNode.offlineGoldBoost.hasVerifiedGoldCost &&
                !RuneTreeNode.offlineXPBoost.hasVerifiedGoldCost &&
                RuneTreeNode.offlineGoldBoost.costText == "成本待核对" &&
                RuneTreeNode.offlineXPBoost.costText == "成本待核对",
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
        expect(
            offlineBoostTree.offlineGoldMultiplier == 1.10 &&
                offlineBoostTree.offlineXPMultiplier == 1.10,
            "offline boost runes apply the checked +10% reward multipliers"
        )

        var resetTree = RuneTree(unlockedNodes: [.partySlot2, .partySlot3, .activeSkillSlot2, .inventoryExpansion1, .offlineRewards, .offlineGoldBoost, .offlineXPBoost])
        expect(resetTree.verifiedResetRefundGold == 200_000, "Rune Tree reset refund only includes checked gold costs")
        let resetRefund = resetTree.resetUnlockedNodes()
        expect(
            resetRefund == 200_000 &&
                resetTree.unlockedNodes.isEmpty &&
                resetTree.unlockedPartySlotCount == 1 &&
                resetTree.activeSkillSlotCount == 1 &&
                resetTree.inventoryCapacity == Inventory.baseCapacity &&
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
        var sampledCompositionNames = Set<String>()
        var slimeFallbacks: [String] = []
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
                }
            }
        }
        expect(sampledCompositionNames.count == 49, "all 49 stage composition monster names are sampled")
        expect(slimeFallbacks.isEmpty, "all non-slime stage composition monsters avoid slime art fallback: \(slimeFallbacks.sorted().joined(separator: ", "))")

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

        tracker = ProgressTracker()
        for _ in 0..<StageDefinition.all.count { clearCurrentStage(&tracker) }
        expect(tracker.currentDifficulty == .nightmare && tracker.currentStage.displayCode == "1-1", "difficulty advances after all stages")

        tracker = ProgressTracker()
        for _ in 0..<(StageDefinition.all.count * Difficulty.allCases.count * 2) {
            clearCurrentStage(&tracker)
        }
        expect(tracker.currentDifficulty == .torment && tracker.currentStage.displayCode == "3-10", "progress caps at torment 3-10")

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

        func makeManager(name: String, runeTree: RuneTree) -> SaveManager {
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("TBHSelfTest-\(name)-\(UUID().uuidString)", isDirectory: true)
            let manager = SaveManager(directory: tempDir)
            manager.save(SaveData(
                hero: Hero(),
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
                runeTree: RuneTree(unlockedNodes: [.offlineRewards, .offlineGoldBoost, .offlineXPBoost])
            ),
            audio: SilentAudio()
        )
        boostedEngine.start()
        boostedEngine.stop()
        expect(
            boostedEngine.statistics.offlineXP > unlockedEngine.statistics.offlineXP &&
                boostedEngine.statistics.offlineGold > unlockedEngine.statistics.offlineGold,
            "offline reward boost runes increase granted offline XP and gold"
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
                synthesisPreview.sourceVariantBoundary == "跳阶/降级概率未核实",
            "Synthesis preview exposes unlocked inputs, locked exclusions, checked output level and source base gear identity"
        )
        let cosmicPreview = SynthesisPreview.make(for: .cosmic, in: previewInputs)
        expect(
            !cosmicPreview.isReady &&
                cosmicPreview.outputRarity == nil &&
                cosmicPreview.outputSourceProgression == nil &&
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
        expect(equipmentTypeIcons.allSatisfy { $0.hasPrefix("item_") }, "equipment types use clean item type icons instead of generic slot icons")
        expect(Set(equipmentTypeIcons).count == EquipmentType.allCases.count && Set(equipmentTypeIcons).count > Set(slotIcons).count, "each equipment type has its own clean icon")

        let a = Item(id: "same", name: "甲", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 1), description: "x")
        let b = Item(id: "same", name: "乙", rarity: .rare, slot: .armor, stats: ItemStats(bonusDEF: 9), description: "y")
        expect(a == b && a.hashValue == b.hashValue, "equal items have equal hashes")
        var set: Set<Item> = [a]
        set.insert(b)
        expect(set.count == 1 && set.contains(b), "Set treats equal-id items as one member")

        let legacyJSON = #"{"id":"old-ring","name":"旧饰品","rarity":"普通","slot":"饰品","stats":{"bonusHP":0,"bonusATK":1,"bonusDEF":0,"bonusSPD":0,"bonusCritRate":0,"bonusCritDamage":0},"description":"legacy"}"#
        let legacyItem = try? JSONDecoder().decode(Item.self, from: Data(legacyJSON.utf8))
        expect(legacyItem?.slot == .ring && legacyItem?.equipmentType == .ring && legacyItem?.isLocked == false, "legacy accessory item migrates to ring slot")
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
                GameArt.itemIconName(for: item) == GameArt.itemIconName(for: fixture.expectedType)
        }
        expect(legacyNameMigrationPassed, "legacy item names infer concrete equipment types for cleaner item icons")
        let explicitTypedItem = Item(id: "explicit", name: "旧弓", rarity: .common, slot: .weapon, stats: ItemStats(), description: "legacy", equipmentType: .sword)
        expect(explicitTypedItem.equipmentType == .sword, "explicit equipment type wins over legacy item name inference")

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
                generated.description.contains("Scepter") &&
                generated.description.contains("来源装备 330003"),
            "loot generation preserves concrete equipment type, item level and checked source base gear identity"
        )
        expect(GameArt.itemIconName(for: generated) == GameArt.itemIconName(for: EquipmentType.scepter), "loot item icon follows concrete equipment type")
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
        let engine = GameEngine(saveManager: SaveManager(directory: tempDir), audio: SilentAudio())

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
                synthesized?.description.contains("来源装备 300003") == true &&
                synthesisEngine.inventory.items.count == 2 &&
                synthesisEngine.inventory.items.contains { $0.id == "synthesis-locked" },
            "Synthesis consumes nine unlocked same-rarity items and creates the next rarity tier with checked source base gear identity"
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

        engine.setPartyMember(slotIndex: 1, heroClass: .sorcerer)
        expect(engine.party.member(at: 1)?.heroClass == .priest, "locked support party slot ignores class change")
        engine.hero.gainGold(200_000)
        expect(!engine.unlockRuneTreeNode(.partySlot2), "Rune Tree formation slot stays locked below hero level 3")
        expect(engine.directPartySlotUnlockCost(slotIndex: 2) == 200_000, "direct party slot 3 unlock reports combined checked cost while both support slots are locked")
        expect(engine.directlyUnlockPartySlot(slotIndex: 2), "direct party slot unlock opens positions 2 and 3 from the party panel path")
        expect(
            engine.hero.gold == 0 &&
                engine.runeTree.unlockedPartySlotCount == 3 &&
                engine.party.activeCount == 3 &&
                engine.currentBattle?.party.activeCount == 3,
            "direct party slot unlock spends checked formation gold and refreshes active battle party slots"
        )
        engine.resetRuneTree()
        expect(engine.hero.gold == 200_000 && engine.party.activeCount == 1, "Rune Tree reset refunds directly spent checked formation gold and relocks party slots")
        engine.hero.gainXP(1_000)
        expect(engine.unlockRuneTreeNode(.partySlot2) && engine.hero.gold == 150_000, "second party slot spends checked 50,000 gold")
        expect(engine.unlockRuneTreeNode(.partySlot3) && engine.hero.gold == 0, "third party slot spends checked 150,000 gold")
        expect(engine.currentBattle?.activeSkillSlotCount == 1, "engine battle starts with one active skill slot before Rune of Awakening")
        expect(
            engine.unlockRuneTreeNode(.activeSkillSlot2) &&
                engine.runeTree.activeSkillSlotCount == 2 &&
                engine.currentBattle?.activeSkillSlotCount == 2,
            "Rune of Awakening refreshes engine battle active skill slot count"
        )
        expect(engine.inventory.maxCapacity == Inventory.baseCapacity, "engine inventory starts at the base capacity before expansion runes")
        expect(
            engine.unlockRuneTreeNode(.inventoryExpansion1) &&
                engine.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus,
            "Rune of Expansion refreshes engine inventory capacity"
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
                engine.inventory.maxCapacity == Inventory.baseCapacity &&
                engine.party.activeCount == 1,
            "Rune Tree reset clears nodes, re-locks party, skill and inventory expansion state, and refunds checked formation gold"
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
        engine.resetGame()
        expect(engine.hero.gold == 0 && engine.hero.level == 1 && engine.inventory.items.isEmpty, "resetGame clears state")
        expect(engine.cubeProgress.totalExperience == 0 && engine.cubeProgress.infusedItemCount == 0, "resetGame clears Cube progress")
        expect(
            engine.runeTree.unlockedPartySlotCount == 1 &&
                engine.runeTree.activeSkillSlotCount == 1 &&
                engine.party.activeCount == 1,
            "resetGame restores Rune Tree party and active skill locks"
        )
        expect(engine.soundEffectsEnabled, "resetGame restores default sound effects setting")
        expect(
            engine.activeSkillLoadouts.activeSkills(for: .knight, heroLevel: 1, slotCount: 1).map(\.id) == ["10101"],
            "resetGame clears selected active skill loadouts"
        )
    }

    private static func gameEngineRuntimeLoop() {
        print("[GameEngine runtime]")

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHSelfTest-Runtime-\(UUID().uuidString)", isDirectory: true)
        let audio = SilentAudio()
        let engine = GameEngine(saveManager: SaveManager(directory: tempDir), audio: audio)
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
        audio.clearEvents()

        var ticks = 0
        while engine.statistics.monstersKilled == 0 && ticks < 5 {
            engine.runSelfTestTick()
            ticks += 1
        }

        let battleRestarted = engine.currentBattle.map { $0 !== firstBattle } ?? false
        let gainedProgress = engine.progress.killsInChapter > startKills ||
            engine.progress.currentStage.displayCode != startStage
        let gainedXP = engine.hero.level > startLevel || engine.hero.currentXP > startXP
        let lootFound = engine.statistics.itemsFound > 0
        let lootSoundPlayed = audio.events.contains(.lootFound)
        let combatSoundPlayed = audio.events.contains { event in
            event == .heroAttack || event == .heroCriticalHit || event == .skillCast
        }

        expect(ticks > 0 && ticks <= 5, "runtime tick loop reaches a terminal battle state")
        expect(engine.statistics.monstersKilled == 1, "runtime victory records the cleared encounter")
        expect(gainedProgress, "runtime victory advances stage encounter progress")
        expect(engine.hero.gold > startGold && engine.statistics.totalGoldEarned > 0, "runtime victory applies mined gold rewards")
        expect(gainedXP, "runtime victory applies mined XP rewards")
        expect(engine.statistics.totalPlayTime > startPlayTime, "runtime tick accumulates play time")
        expect(battleRestarted, "runtime victory starts the next battle after settlement")
        expect(audio.events.contains(.battleWon), "runtime battle victory emits the battle-won sound event")
        expect(combatSoundPlayed, "runtime battle tick emits combat sound events before settlement")
        expect(lootFound == lootSoundPlayed, "runtime loot-found sound matches retained battle loot")
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
        expect(audio.events == [.preview], "settings preview emits the preview sound event")
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
        var runeTree = RuneTree(unlockedPartySlotCount: 2)
        runeTree.unlockedNodes.insert(.activeSkillSlot2)
        runeTree.unlockedNodes.insert(.inventoryExpansion1)
        var party = HeroParty(primaryClass: .priest)
        party.setHeroClass(.sorcerer, atSlot: 1)
        var progress = ProgressTracker()
        progress.soulStones.grant(.normal)
        progress.chests.add(LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal))
        let inventory = Inventory()
        inventory.add(Item(id: "locked", name: "锁定剑", rarity: .arcana, slot: .weapon, stats: ItemStats(bonusATK: 1), description: "", isLocked: true))
        var cubeProgress = CubeProgress()
        _ = cubeProgress.infuse(Item(id: "cube", name: "Cube 材料", rarity: .rare, slot: nil, stats: ItemStats(), description: ""))
        var activeSkillLoadouts = ActiveSkillLoadouts()
        activeSkillLoadouts.setSkill("40301", for: .priest, slotIndex: 0)
        manager.save(SaveData(hero: hero, party: party, runeTree: runeTree, cubeProgress: cubeProgress, activeSkillLoadouts: activeSkillLoadouts, inventory: inventory, progress: progress, statistics: GameStatistics(), autoEquipBestItems: true, soundEffectsEnabled: false, unyieldingWillConsumedStageKey: "4:3-9", timestamp: Date()))
        let loaded = manager.load()
        expect(loaded?.hero.gold == 123, "save/load round trip preserves data")
        expect(loaded?.party.member(at: 0)?.heroClass == .priest && loaded?.party.member(at: 1)?.heroClass == .sorcerer, "save/load round trip preserves party")
        expect(loaded?.runeTree.unlockedPartySlotCount == 2 && loaded?.party.activeCount == 2, "save/load round trip preserves Rune Tree party unlocks")
        expect(loaded?.runeTree.activeSkillSlotCount == 2, "save/load round trip preserves Rune Tree active skill slot unlocks")
        expect(
            loaded?.runeTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus &&
                loaded?.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus,
            "save/load round trip derives inventory capacity from Rune Tree unlocks"
        )
        expect(loaded?.cubeProgress.totalExperience == Rarity.rare.cubeExperience, "save/load round trip preserves Cube progress")
        expect(loaded?.activeSkillLoadouts.activeSkills(for: .priest, heroLevel: 1, slotCount: 1).map(\.id) == ["40301"], "save/load round trip preserves active skill loadout")
        expect(loaded?.inventory.items.first?.isLocked == true, "save/load round trip preserves item lock state")
        expect(loaded?.autoEquipBestItems == true, "save/load round trip preserves auto equip toggle")
        expect(loaded?.soundEffectsEnabled == false, "save/load round trip preserves sound effects toggle")
        expect(loaded?.unyieldingWillConsumedStageKey == "4:3-9", "save/load round trip preserves Unyielding Will stage consumption")
        expect(loaded?.progress.soulStones.count(for: .normal) == 1, "save/load round trip preserves Soul Stones")
        expect(loaded?.progress.chests.count(for: .normal) == 1, "save/load round trip preserves chests")

        let engine = GameEngine(saveManager: manager, audio: SilentAudio())
        engine.start()
        engine.stop()
        expect(
            engine.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus,
            "GameEngine load derives inventory capacity from Rune Tree unlocks"
        )
    }
}
#endif
