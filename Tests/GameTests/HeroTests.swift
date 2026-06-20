import Foundation
import Testing
@testable import TBH

@Suite struct HeroTests {
    @Test func originalHeroClassesAvailable() {
        #expect(HeroClass.allCases.count == 6)
        #expect(HeroClass.allCases.map(\.rawValue) == ["骑士", "游侠", "法师", "牧师", "猎人", "杀手"])
        #expect(HeroClass.knight.baseStats.hp == 130)
        #expect(HeroClass.ranger.baseStats.critRate == 0.04)
    }

    @Test func legacyWarriorClassDecodesAsKnight() throws {
        let decoded = try JSONDecoder().decode(HeroClass.self, from: Data(#""战士""#.utf8))
        #expect(decoded == .knight)
    }

    @Test func classSwitchUpdatesBaseStats() {
        let hero = Hero()
        #expect(hero.heroClass == .knight)
        #expect(hero.maxHP == 130)

        hero.changeClass(to: .sorcerer)

        #expect(hero.heroClass == .sorcerer)
        #expect(hero.maxHP == 50)
        #expect(hero.attack == 11)
        #expect(hero.currentHP == 50)
    }

    @Test func levelUp() {
        let hero = Hero()
        let xpNeeded = hero.xpForNextLevel()
        hero.gainXP(xpNeeded)
        #expect(hero.level == 2, "Hero should level up")
    }

    @Test func levelPacingCapsXPByCurrentProgress() {
        let hero = Hero()
        let progress = ProgressTracker()
        let maxLevel = HeroLevelPacing.maxHeroLevel(for: progress)

        #expect(maxLevel == 3)

        let appliedXP = HeroLevelPacing.grantXP(1_000_000, to: hero, maxLevel: maxLevel)

        #expect(appliedXP < 1_000_000)
        #expect(hero.level == maxLevel)
        #expect(hero.currentXP == hero.xpForNextLevel() - 1)
    }

    @Test func levelPacingAppliesRuntimeXPMultiplier() {
        let hero = Hero()

        let appliedXP = HeroLevelPacing.grantXP(100, to: hero, maxLevel: 10)

        #expect(GamePacing.appliedXPMultiplier == 0.35)
        #expect(GamePacing.pacedXP(from: 1) == 1)
        #expect(appliedXP == 35)
        #expect(hero.currentXP == 35)
        #expect(hero.level == 1)
    }

    @Test func combatPacingUsesOneSecondOriginalTick() {
        #expect(GamePacing.runtimeTickInterval == 1.0)
        #expect(GamePacing.combatSimulationStep == 1.0)
        #expect(GamePacing.combatDeltaMultiplier == 1.0)
        #expect(GamePacing.minimumHastedAttackInterval == 1.0)
        #expect(abs(GamePacing.simulatedCombatDelta(for: GamePacing.runtimeTickInterval) - 1.0) < 0.0001)
        #expect(GamePacing.simulatedCombatDelta(for: -1) == 0)
    }

    @Test func levelPacingPreviewDoesNotMutateHero() {
        let hero = Hero()

        let previewXP = HeroLevelPacing.previewGrantedXP(100, for: hero, maxLevel: 10)

        #expect(previewXP == 35)
        #expect(hero.currentXP == 0)
        #expect(hero.level == 1)
    }

    @Test func levelPacingAllowsNewGamePlusHeadroomWithoutUnboundedGrowth() {
        var progress = ProgressTracker()
        progress.currentDifficultyIndex = Difficulty.allCases.count - 1
        progress.currentChapterIndex = Chapter.allCases.count - 1
        progress.currentStageIndex = StageDefinition.stagesPerAct - 1
        progress.playthrough = 3

        #expect(HeroLevelPacing.maxHeroLevel(for: progress) == 127)
    }

    @Test func takeDamage() {
        let hero = Hero()
        let initialHP = hero.currentHP
        hero.takeDamage(10)
        #expect(hero.currentHP == initialHP - 10)
    }

    @Test func healDoesNotExceedMaxHP() {
        let hero = Hero()
        hero.takeDamage(30)
        let healed = hero.heal(20)
        #expect(healed == 20)
        #expect(hero.currentHP == hero.maxHP - 10)

        let capped = hero.heal(999)
        #expect(capped == 10)
        #expect(hero.currentHP == hero.maxHP)
    }

    @Test func reviveCanRestoreAboveMaxHPWithoutHealClampingDown() {
        let hero = Hero()
        hero.takeDamage(hero.currentHP + 100)

        let restored = hero.revive(withHP: hero.maxHP * 3)
        let healed = hero.heal(999)

        #expect(restored == hero.maxHP * 3)
        #expect(hero.currentHP == hero.maxHP * 3)
        #expect(healed == 0)
    }

    @Test func deathCheck() {
        let hero = Hero()
        hero.takeDamage(hero.currentHP + 100)
        #expect(!hero.isAlive)
        #expect(hero.currentHP == 0)
    }

    @Test func respawn() {
        let hero = Hero()
        hero.takeDamage(hero.currentHP + 100)
        hero.respawn()
        #expect(hero.isAlive)
        #expect(hero.currentHP > 0)
    }
}

@Suite struct HeroPartyTests {
    @Test func defaultPartyKeepsStarterLineupButDeploysOneSlot() {
        let party = HeroParty(primaryClass: .knight)

        #expect(party.members.count == HeroParty.maxSlots)
        #expect(party.members.map(\.heroClass) == [.knight, .priest, .ranger])
        #expect(party.activeMembers.map(\.heroClass) == [.knight])
        #expect(party.supportAttackPower(heroLevel: 1) == 0)
    }

    @Test func unlockedPartyDeploysSupportSlots() {
        var party = HeroParty(primaryClass: .knight)

        party.setUnlockedSlotCount(3)

        #expect(party.activeMembers.map(\.heroClass) == [.knight, .priest, .ranger])
        #expect(party.supportAttackPower(heroLevel: 1) > 0)
    }

    @Test func changingSlotsKeepsClassesUnique() {
        var party = HeroParty(primaryClass: .knight)
        party.setUnlockedSlotCount(3)

        party.setHeroClass(.priest, atSlot: 0)

        #expect(party.member(at: 0)?.heroClass == .priest)
        #expect(Set(party.members.map(\.heroClass)).count == party.members.count)
    }
}

@Suite struct RuneTreeTests {
    @Test func sourceRuneCatalogMatchesCheckedRuneTreeDatabase() {
        #expect(SourceRuneCatalog.all.count == SourceRuneCatalog.expectedNodeCount)
        #expect(SourceRuneCatalog.expectedNodeCount == 197)
        #expect(SourceRuneCatalog.connectionCount == SourceRuneCatalog.expectedConnectionCount)
        #expect(SourceRuneCatalog.expectedConnectionCount == 195)
        #expect(SourceRuneCatalog.nextOutDegreeDistribution == SourceRuneCatalog.expectedNextOutDegreeDistribution)
        #expect(SourceRuneCatalog.expectedNextOutDegreeDistribution == [0: 79, 1: 63, 2: 35, 3: 18, 4: 2])
        #expect(SourceRuneCatalog.previousReferenceCount == SourceRuneCatalog.expectedPreviousReferenceCount)
        #expect(SourceRuneCatalog.expectedPreviousReferenceCount == 11)
        #expect(SourceRuneCatalog.previousReferenceMap == SourceRuneCatalog.expectedPreviousReferenceMap)
        #expect(SourceRuneCatalog.expectedPreviousReferenceMap.count == 7)
        #expect(SourceRuneCatalog.expectedPreviousReferenceMap["21"] == ["23", "24", "26", "27"])
        #expect(SourceRuneCatalog.maxLevelDistribution == SourceRuneCatalog.expectedMaxLevelDistribution)
        #expect(SourceRuneCatalog.expectedMaxLevelDistribution == [1: 62, 2: 1, 3: 43, 5: 89, 10: 2])
        #expect(SourceRuneCatalog.duplicateIDs.isEmpty)
        #expect(SourceRuneCatalog.danglingNextIDs.isEmpty)
        #expect(SourceRuneCatalog.danglingPreviousIDs.isEmpty)
        #expect(SourceRuneCatalog.iconNames.count == 39)
        #expect(SourceRuneCatalog.iconDistribution == SourceRuneCatalog.expectedIconDistribution)
        #expect(SourceRuneCatalog.expectedIconDistribution.count == 39)
        #expect(SourceRuneCatalog.expectedIconDistribution["MaxInventorySlot"] == 26)
        #expect(SourceRuneCatalog.expectedIconDistribution["DropChanceNormalChest"] == 15)
        #expect(SourceRuneCatalog.expectedIconDistribution["UnlockArrangeSlotCount"] == 2)
        #expect(SourceRuneCatalog.byID["1"]?.enName == "Rune of War")
        #expect(SourceRuneCatalog.byID["1"]?.zhName == "战争符文")
        #expect(SourceRuneCatalog.byID["1"]?.nextIDs == ["10", "20"])
        #expect(SourceRuneCatalog.byID["27"]?.enName == "Rune of Awakening")
        #expect(SourceRuneCatalog.byID["27"]?.iconName == "UnlockSkillSlotCount")
        #expect(SourceRuneCatalog.byID["22"]?.enName == "Rune of Expansion")
        #expect(SourceRuneCatalog.byID["22"]?.iconName == "MaxInventorySlot")
        #expect(SourceRuneCatalog.byID["11001"]?.enName == "Rune of Repose")
        #expect(SourceRuneCatalog.byID["11001"]?.nextIDs == ["110011", "110012"])
        #expect(SourceRuneCatalog.byID["110012"]?.iconName == "OfflineRewardExpPercent")
        #expect(SourceRuneCatalog.byID["1021"]?.iconName == "OpenOneTypeChestAllAtOnce")
        #expect(SourceRuneCatalog.byID["1055"]?.iconName == "OpenAllTypeChestAllAtOnce")
        #expect(SourceRuneCatalog.byID["13002"]?.iconName == "UnlockAutoOpenNormalChest")
        #expect(SourceRuneCatalog.byID["15001"]?.iconName == "UnlockAutoOpenStageBossChest")
        #expect(SourceRuneCatalog.byID["1902001"]?.iconName == "UnlockAutoOpenActBossChest")
        #expect(RuneTreeNode.allCases.allSatisfy { SourceRuneCatalog.byID[$0.sourceRuneID] != nil })
    }

    @Test func runeTreeNodesResolveToBundledIcons() {
        let mappedIcons = RuneTreeNode.allCases.map { GameArt.runeTreeIconName(for: $0) }

        #expect(mappedIcons.allSatisfy { $0.hasPrefix("source_rune_") })
        #expect(Set(mappedIcons).isSubset(of: Set(GameArt.runeTreeIconNames)))
        #expect(GameArt.runeTreeIconNames.count == SourceRuneCatalog.iconNames.count)
        #expect(Set(mappedIcons).count == 39)
        #expect(SourceRuneCatalog.runtimeModeledNodes.count == RuneTreeNode.allCases.count)
        #expect(SourceRuneCatalog.runtimeModeledNodes.count == 197)
        #expect(SourceRuneCatalog.runtimeUnmodeledNodes.isEmpty)
        #expect(SourceRuneCatalog.runtimeModeledIconNames.count == 39)
        #expect(SourceRuneCatalog.runtimeUnmodeledOnlyIconNames.isEmpty)
        #expect(SourceRuneCatalog.runtimeSharedModeledAndUnmodeledIconNames.isEmpty)
        #expect(GameArt.runeTreeIconName(for: .allHeroAttackDamage1) == "source_rune_AllHeroAttackDamage")
        #expect(GameArt.runeTreeIconName(for: .allHeroAttackDamage4) == "source_rune_AllHeroAttackDamage")
        #expect(GameArt.runeTreeIconName(for: .allHeroArmor1) == "source_rune_AllHeroArmor")
        #expect(GameArt.runeTreeIconName(for: .allHeroMoveSpeed1) == "source_rune_AllHeroMoveSpeed")
        #expect(GameArt.runeTreeIconName(for: .allHeroMoveSpeed2) == "source_rune_AllHeroMoveSpeed")
        #expect(GameArt.runeTreeIconName(for: .allHeroMoveSpeed3) == "source_rune_AllHeroMoveSpeed")
        #expect(GameArt.runeTreeIconName(for: .allHeroMoveSpeed4) == "source_rune_AllHeroMoveSpeed")
        #expect(GameArt.runeTreeIconName(for: .allHeroMoveSpeed5) == "source_rune_AllHeroMoveSpeed")
        #expect(GameArt.runeTreeIconName(for: .allHeroAttackDamagePercent1) == "source_rune_AllHeroAttackDamagePercent")
        #expect(GameArt.runeTreeIconName(for: .allHeroArmorPercent1) == "source_rune_AllHeroArmorPercent")
        #expect(GameArt.runeTreeIconName(for: .allHeroAttackDamagePercent2) == "source_rune_AllHeroAttackDamagePercent")
        #expect(GameArt.runeTreeIconName(for: .allHeroAttackDamagePercent3) == "source_rune_AllHeroAttackDamagePercent")
        #expect(GameArt.runeTreeIconName(for: .partySlot2) == "source_rune_UnlockArrangeSlotCount")
        #expect(GameArt.runeTreeIconName(for: .partySlot3) == "source_rune_UnlockArrangeSlotCount")
        #expect(GameArt.runeTreeIconName(for: .activeSkillSlot2) == "source_rune_UnlockSkillSlotCount")
        #expect(RuneTree.combatGoldBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_IncreaseGoldAmount" })
        #expect(RuneTree.combatXPBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_IncreaseExpAmount" })
        #expect(RuneTree.additionalGoldBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalGold" })
        #expect(RuneTree.additionalGoldNormalMonsterNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalGoldNormalMonster" })
        #expect(RuneTree.additionalGoldStageBossNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalGoldStageBoss" })
        #expect(RuneTree.additionalGoldActBossNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalGoldActBoss" })
        #expect(RuneTree.additionalXPBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalExp" })
        #expect(RuneTree.additionalXPNormalMonsterNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalExpNormalMonster" })
        #expect(RuneTree.additionalXPStageBossNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalExpStageBoss" })
        #expect(RuneTree.additionalXPActBossNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_AdditionalExpActBoss" })
        #expect(RuneTree.cubeXPBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_CubeExpPercent" })
        #expect(RuneTree.alchemyGoldBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_CubeAlchemyGoldPercent" })
        #expect(RuneTree.inventoryExpansionNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_MaxInventorySlot" })
        #expect(GameArt.runeTreeIconName(for: .openOneChestType) == "source_rune_OpenOneTypeChestAllAtOnce")
        #expect(GameArt.runeTreeIconName(for: .openAllChestTypes) == "source_rune_OpenAllTypeChestAllAtOnce")
        #expect(GameArt.runeTreeIconName(for: .autoOpenNormalChests) == "source_rune_UnlockAutoOpenNormalChest")
        #expect(GameArt.runeTreeIconName(for: .autoOpenStageBossChests) == "source_rune_UnlockAutoOpenStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .autoOpenActBossChests) == "source_rune_UnlockAutoOpenActBossChest")
        #expect(RuneTree.normalChestDropChanceNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_DropChanceNormalChest" })
        #expect(RuneTree.stageBossChestDropChanceNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_DropChanceStageBossChest" })
        #expect(RuneTree.normalChestAutoOpenSpeedNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_ReduceAutoOpenNormalChestTime" })
        #expect(RuneTree.stageBossChestAutoOpenSpeedNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_ReduceAutoOpenStageBossChestTime" })
        #expect(RuneTree.actBossChestAutoOpenSpeedNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_ReduceAutoOpenActBossChestTime" })
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage2) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage3) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage4) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage5) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage6) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage7) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage8) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage9) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage10) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage11) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage12) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage13) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage14) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage15) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage2) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage3) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage4) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage5) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage6) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage7) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage8) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage9) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage10) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage11) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage12) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage13) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxActBossChestStorage) == "source_rune_MaxAmountActBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxActBossChestStorage2) == "source_rune_MaxAmountActBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxActBossChestStorage3) == "source_rune_MaxAmountActBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxActBossChestStorage4) == "source_rune_MaxAmountActBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxActBossChestStorage5) == "source_rune_MaxAmountActBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxActBossChestStorage6) == "source_rune_MaxAmountActBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxActBossChestStorage7) == "source_rune_MaxAmountActBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxActBossChestStorage8) == "source_rune_MaxAmountActBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxActBossChestStorage9) == "source_rune_MaxAmountActBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxActBossChestStorage10) == "source_rune_MaxAmountActBossChest")
        #expect(GameArt.runeTreeIconName(for: .offlineRewards) == "source_rune_UnlockOfflineReward")
        #expect(RuneTree.offlineGoldBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_OfflineRewardGoldPercent" })
        #expect(RuneTree.offlineXPBoostNodes.allSatisfy { GameArt.runeTreeIconName(for: $0) == "source_rune_OfflineRewardExpPercent" })
        #expect(GameArt.runeTreeIconName(for: .stashPage1) == "source_rune_UnlockStashPageCount")
        #expect(GameArt.runeTreeIconName(for: .stashPage2) == "source_rune_UnlockStashPageCount")
        #expect(GameArt.runeTreeIconName(for: .stashPage3) == "source_rune_UnlockStashPageCount")
        #expect(GameArt.runeTreeIconName(for: .waveCountReduction1) == "source_rune_WaveCountReduction")
        #expect(GameArt.runeTreeIconName(for: .allHeroAttackSpeed1) == "source_rune_AllHeroAttackSpeed")
        #expect(GameArt.runeTreeIconName(for: .allHeroAttackSpeed2) == "source_rune_AllHeroAttackSpeed")
        #expect(GameArt.runeTreeIconName(for: .allHeroAttackSpeed3) == "source_rune_AllHeroAttackSpeed")
        #expect(GameArt.runeTreeIconName(for: .allHeroArmor2) == "source_rune_AllHeroArmor")
        #expect(GameArt.runeTreeIconName(for: .allHeroArmor3) == "source_rune_AllHeroArmor")
        #expect(GameArt.runeTreeIconName(for: .allHeroAttackDamage2) == "source_rune_AllHeroAttackDamage")
        #expect(GameArt.runeTreeIconName(for: .allHeroAttackDamage3) == "source_rune_AllHeroAttackDamage")
        #expect(GameArt.runeTreeIconName(for: .allHeroArmorPercent2) == "source_rune_AllHeroArmorPercent")
    }

    @Test func partySlotsUnlockInOrder() {
        var tree = RuneTree()

        #expect(tree.unlockedPartySlotCount == 1)
        #expect(!RuneTreeNode.allHeroAttackDamage1.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroAttackDamage1.costText == "成本待核对")
        #expect(tree.unlock(.allHeroAttackDamage1, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroAttackDamage == RuneTree.allHeroAttackDamageBonus)
        #expect(!RuneTreeNode.allHeroArmor1.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroArmor1.costText == "成本待核对")
        #expect(tree.unlock(.allHeroArmor1, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroArmor == RuneTree.allHeroArmorBonus)
        #expect(!RuneTreeNode.allHeroMoveSpeed1.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroMoveSpeed1.costText == "成本待核对")
        #expect(tree.unlock(.allHeroMoveSpeed1, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroMoveSpeed == RuneTree.allHeroMoveSpeedBonus)
        #expect(!RuneTreeNode.allHeroArmor3.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroArmor3.costText == "成本待核对")
        #expect(tree.unlock(.allHeroArmor3, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroArmor == RuneTree.allHeroArmorBonus * 2)
        #expect(!RuneTreeNode.allHeroAttackDamage4.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroAttackDamage4.costText == "成本待核对")
        #expect(tree.unlock(.allHeroAttackDamage4, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroAttackDamage == RuneTree.allHeroAttackDamageBonus * 2)
        #expect(!tree.unlock(.allHeroAttackDamagePercent1, heroLevel: 3, availableGold: 0))
        #expect(!RuneTreeNode.allHeroMoveSpeed4.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroMoveSpeed4.costText == "成本待核对")
        #expect(tree.unlock(.allHeroMoveSpeed4, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroMoveSpeed == RuneTree.allHeroMoveSpeedBonus * 2)
        #expect(!RuneTreeNode.allHeroMoveSpeed2.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroMoveSpeed2.costText == "成本待核对")
        #expect(!RuneTreeNode.allHeroMoveSpeed3.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroMoveSpeed3.costText == "成本待核对")
        #expect(!RuneTreeNode.allHeroAttackDamagePercent1.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroAttackDamagePercent1.costText == "成本待核对")
        #expect(tree.unlock(.allHeroAttackDamagePercent1, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroAttackDamageMultiplier == 1.0 + RuneTree.allHeroAttackDamageMultiplierBonus)
        #expect(!tree.unlock(.allHeroArmorPercent1, heroLevel: 3, availableGold: 0))
        #expect(!tree.unlock(.allHeroAttackSpeed1, heroLevel: 3, availableGold: 0))
        #expect(!RuneTreeNode.allHeroMoveSpeed5.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroMoveSpeed5.costText == "成本待核对")
        #expect(tree.unlock(.allHeroMoveSpeed5, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroMoveSpeed == RuneTree.allHeroMoveSpeedBonus * 3)
        #expect(!RuneTreeNode.allHeroArmorPercent1.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroArmorPercent1.costText == "成本待核对")
        #expect(tree.unlock(.allHeroArmorPercent1, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroArmorMultiplier == 1.0 + RuneTree.allHeroArmorMultiplierBonus)
        #expect(!RuneTreeNode.allHeroAttackDamagePercent2.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroAttackDamagePercent2.costText == "成本待核对")
        #expect(tree.unlock(.allHeroAttackDamagePercent2, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroAttackDamageMultiplier == 1.0 + RuneTree.allHeroAttackDamageMultiplierBonus * 2.0)
        #expect(!RuneTreeNode.allHeroAttackSpeed1.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroAttackSpeed1.costText == "成本待核对")
        #expect(tree.unlock(.allHeroAttackSpeed1, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroAttackSpeedMultiplier == 1.0 + RuneTree.allHeroAttackSpeedMultiplierBonus)
        #expect(!RuneTreeNode.allHeroAttackSpeed2.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroAttackSpeed2.costText == "成本待核对")
        #expect(tree.unlock(.allHeroAttackSpeed2, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroAttackSpeedMultiplier == 1.0 + RuneTree.allHeroAttackSpeedMultiplierBonus * 2.0)
        #expect(!RuneTreeNode.allHeroArmor2.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroArmor2.costText == "成本待核对")
        #expect(tree.unlock(.allHeroArmor2, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroArmor == RuneTree.allHeroArmorBonus * 3)
        #expect(!RuneTreeNode.allHeroAttackDamage2.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroAttackDamage2.costText == "成本待核对")
        #expect(tree.unlock(.allHeroAttackDamage2, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroAttackDamage == RuneTree.allHeroAttackDamageBonus * 3)
        #expect(!RuneTreeNode.allHeroAttackDamage3.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroAttackDamage3.costText == "成本待核对")
        #expect(tree.unlock(.allHeroAttackDamage3, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroAttackDamage == RuneTree.allHeroAttackDamageBonus * 4)
        #expect(tree.unlock(.allHeroMoveSpeed2, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroMoveSpeed == RuneTree.allHeroMoveSpeedBonus * 4)
        #expect(tree.unlock(.allHeroMoveSpeed3, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroMoveSpeed == RuneTree.allHeroMoveSpeedBonus * 5)
        #expect(!RuneTreeNode.allHeroArmorPercent2.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroArmorPercent2.costText == "成本待核对")
        #expect(tree.unlock(.allHeroArmorPercent2, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroArmorMultiplier == 1.0 + RuneTree.allHeroArmorMultiplierBonus * 2.0)
        #expect(!RuneTreeNode.allHeroAttackDamagePercent3.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroAttackDamagePercent3.costText == "成本待核对")
        #expect(tree.unlock(.allHeroAttackDamagePercent3, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroAttackDamageMultiplier == 1.0 + RuneTree.allHeroAttackDamageMultiplierBonus * 3.0)
        #expect(!RuneTreeNode.allHeroAttackSpeed3.hasVerifiedGoldCost)
        #expect(RuneTreeNode.allHeroAttackSpeed3.costText == "成本待核对")
        #expect(tree.unlock(.allHeroAttackSpeed3, heroLevel: 3, availableGold: 0))
        #expect(tree.allHeroAttackSpeedMultiplier == 1.0 + RuneTree.allHeroAttackSpeedMultiplierBonus * 3.0)
        #expect(RuneTree.cubeXPBoostNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" })
        #expect(tree.unlock(.cubeXPBoost1, heroLevel: 3, availableGold: 0))
        #expect(tree.cubeExperienceMultiplier == 1.0 + RuneTree.cubeRewardMultiplierBonus)
        #expect(RuneTree.alchemyGoldBoostNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" })
        #expect(tree.unlock(.alchemyGoldBoost1, heroLevel: 3, availableGold: 0))
        #expect(tree.alchemyGoldMultiplier == 1.0 + RuneTree.cubeRewardMultiplierBonus)
        #expect(!tree.unlock(.cubeXPBoost2, heroLevel: 3, availableGold: 0))
        #expect(tree.unlock(.alchemyGoldBoost2, heroLevel: 3, availableGold: 0))
        #expect(tree.alchemyGoldMultiplier == 1.0 + RuneTree.cubeRewardMultiplierBonus * 2.0)
        #expect(!tree.unlock(.alchemyGoldBoost4, heroLevel: 3, availableGold: 0))
        #expect(tree.unlock(.cubeXPBoost2, heroLevel: 3, availableGold: 0))
        #expect(tree.unlock(.cubeXPBoost3, heroLevel: 3, availableGold: 0))
        #expect(tree.unlock(.cubeXPBoost4, heroLevel: 3, availableGold: 0))
        #expect(tree.cubeExperienceMultiplier == 1.0 + RuneTree.cubeRewardMultiplierBonus * 4.0)
        #expect(tree.unlock(.alchemyGoldBoost3, heroLevel: 3, availableGold: 0))
        #expect(tree.unlock(.alchemyGoldBoost4, heroLevel: 3, availableGold: 0))
        #expect(tree.alchemyGoldMultiplier == 1.0 + RuneTree.cubeRewardMultiplierBonus * 4.0)
        #expect(RuneTreeNode.partySlot2.goldCost == 50_000)
        #expect(RuneTreeNode.partySlot3.goldCost == 150_000)
        #expect(!tree.canUnlock(.partySlot2, heroLevel: 2, availableGold: 50_000))
        #expect(!tree.canUnlock(.partySlot2, heroLevel: 3, availableGold: 49_999))
        let unlockedPartySlot2 = tree.unlock(.partySlot2, heroLevel: 3, availableGold: 50_000)
        #expect(unlockedPartySlot2)
        #expect(tree.unlockedPartySlotCount == 2)
        #expect(!tree.canUnlock(.partySlot3, heroLevel: 3, availableGold: 149_999))
        let unlockedPartySlot3 = tree.unlock(.partySlot3, heroLevel: 3, availableGold: 150_000)
        #expect(unlockedPartySlot3)
        #expect(tree.unlockedPartySlotCount == 3)

        var directPartyTree = RuneTree()
        #expect(directPartyTree.directPartySlotUnlockCost(for: 1) == 50_000)
        #expect(directPartyTree.directPartySlotUnlockCost(for: 2) == 200_000)
        #expect(!directPartyTree.canDirectlyUnlockPartySlot(2, availableGold: 199_999))
        let directPartySlotSpend = directPartyTree.directlyUnlockPartySlot(2, availableGold: 200_000)
        #expect(directPartySlotSpend == 200_000)
        #expect(directPartyTree.unlockedPartySlotCount == 3)
        #expect(directPartyTree.isUnlocked(.partySlot2))
        #expect(directPartyTree.isUnlocked(.partySlot3))

        #expect(tree.activeSkillSlotCount == 1)
        #expect(!RuneTreeNode.activeSkillSlot2.hasVerifiedGoldCost)
        #expect(RuneTreeNode.activeSkillSlot2.approximateGoldCost == 50_000)
        #expect(RuneTreeNode.activeSkillSlot2.approximateGoldCostSourceText == "官方符文分支：2nd Active Skill Slot (~50,000g)")
        #expect(RuneTreeNode.activeSkillSlot2.costText == "约 50,000 G（待核对）")
        #expect(!tree.canUnlock(.activeSkillSlot2, heroLevel: 2, availableGold: 0))
        let unlockedActiveSkillSlot = tree.unlock(.activeSkillSlot2, heroLevel: 3, availableGold: 0)
        #expect(unlockedActiveSkillSlot)
        #expect(tree.activeSkillSlotCount == 2)
        let unlockedAutoOpenNormal = tree.unlock(.autoOpenNormalChests, heroLevel: 3, availableGold: 0)
        #expect(unlockedAutoOpenNormal)
        #expect(tree.canAutoOpenNormalChests)
        let unlockedAutoOpenStageBoss = tree.unlock(.autoOpenStageBossChests, heroLevel: 3, availableGold: 0)
        #expect(unlockedAutoOpenStageBoss)
        #expect(tree.canAutoOpenStageBossChests)
        let unlockedAutoOpenActBoss = tree.unlock(.autoOpenActBossChests, heroLevel: 3, availableGold: 0)
        #expect(unlockedAutoOpenActBoss)
        #expect(tree.canAutoOpenActBossChests)
        let unlockedNormalChestStorage = tree.unlock(.maxNormalChestStorage, heroLevel: 3, availableGold: 0)
        let unlockedSecondNormalChestStorage = tree.unlock(.maxNormalChestStorage2, heroLevel: 3, availableGold: 0)
        let unlockedThirdNormalChestStorage = tree.unlock(.maxNormalChestStorage3, heroLevel: 3, availableGold: 0)
        let unlockedFourthNormalChestStorage = tree.unlock(.maxNormalChestStorage4, heroLevel: 3, availableGold: 0)
        let unlockedFifthNormalChestStorage = tree.unlock(.maxNormalChestStorage5, heroLevel: 3, availableGold: 0)
        let unlockedSixthNormalChestStorage = tree.unlock(.maxNormalChestStorage6, heroLevel: 3, availableGold: 0)
        let unlockedSeventhNormalChestStorage = tree.unlock(.maxNormalChestStorage7, heroLevel: 3, availableGold: 0)
        let unlockedEighthNormalChestStorage = tree.unlock(.maxNormalChestStorage8, heroLevel: 3, availableGold: 0)
        let unlockedNinthNormalChestStorage = tree.unlock(.maxNormalChestStorage9, heroLevel: 3, availableGold: 0)
        let unlockedTenthNormalChestStorage = tree.unlock(.maxNormalChestStorage10, heroLevel: 3, availableGold: 0)
        let unlockedEleventhNormalChestStorage = tree.unlock(.maxNormalChestStorage11, heroLevel: 3, availableGold: 0)
        let unlockedTwelfthNormalChestStorage = tree.unlock(.maxNormalChestStorage12, heroLevel: 3, availableGold: 0)
        let unlockedThirteenthNormalChestStorage = tree.unlock(.maxNormalChestStorage13, heroLevel: 3, availableGold: 0)
        let unlockedFourteenthNormalChestStorage = tree.unlock(.maxNormalChestStorage14, heroLevel: 3, availableGold: 0)
        let unlockedFifteenthNormalChestStorage = tree.unlock(.maxNormalChestStorage15, heroLevel: 3, availableGold: 0)
        let unlockedStageBossChestStorage = tree.unlock(.maxStageBossChestStorage, heroLevel: 3, availableGold: 0)
        let unlockedSecondStageBossChestStorage = tree.unlock(.maxStageBossChestStorage2, heroLevel: 3, availableGold: 0)
        let unlockedThirdStageBossChestStorage = tree.unlock(.maxStageBossChestStorage3, heroLevel: 3, availableGold: 0)
        let unlockedFourthStageBossChestStorage = tree.unlock(.maxStageBossChestStorage4, heroLevel: 3, availableGold: 0)
        let unlockedFifthStageBossChestStorage = tree.unlock(.maxStageBossChestStorage5, heroLevel: 3, availableGold: 0)
        let unlockedSixthStageBossChestStorage = tree.unlock(.maxStageBossChestStorage6, heroLevel: 3, availableGold: 0)
        let unlockedSeventhStageBossChestStorage = tree.unlock(.maxStageBossChestStorage7, heroLevel: 3, availableGold: 0)
        let unlockedEighthStageBossChestStorage = tree.unlock(.maxStageBossChestStorage8, heroLevel: 3, availableGold: 0)
        let unlockedNinthStageBossChestStorage = tree.unlock(.maxStageBossChestStorage9, heroLevel: 3, availableGold: 0)
        let unlockedTenthStageBossChestStorage = tree.unlock(.maxStageBossChestStorage10, heroLevel: 3, availableGold: 0)
        let unlockedEleventhStageBossChestStorage = tree.unlock(.maxStageBossChestStorage11, heroLevel: 3, availableGold: 0)
        let unlockedTwelfthStageBossChestStorage = tree.unlock(.maxStageBossChestStorage12, heroLevel: 3, availableGold: 0)
        let unlockedThirteenthStageBossChestStorage = tree.unlock(.maxStageBossChestStorage13, heroLevel: 3, availableGold: 0)
        let unlockedActBossChestStorage = tree.unlock(.maxActBossChestStorage, heroLevel: 3, availableGold: 0)
        let unlockedSecondActBossChestStorage = tree.unlock(.maxActBossChestStorage2, heroLevel: 3, availableGold: 0)
        let unlockedThirdActBossChestStorage = tree.unlock(.maxActBossChestStorage3, heroLevel: 3, availableGold: 0)
        let unlockedFourthActBossChestStorage = tree.unlock(.maxActBossChestStorage4, heroLevel: 3, availableGold: 0)
        let unlockedFifthActBossChestStorage = tree.unlock(.maxActBossChestStorage5, heroLevel: 3, availableGold: 0)
        let unlockedSixthActBossChestStorage = tree.unlock(.maxActBossChestStorage6, heroLevel: 3, availableGold: 0)
        let unlockedSeventhActBossChestStorage = tree.unlock(.maxActBossChestStorage7, heroLevel: 3, availableGold: 0)
        let unlockedEighthActBossChestStorage = tree.unlock(.maxActBossChestStorage8, heroLevel: 3, availableGold: 0)
        let unlockedNinthActBossChestStorage = tree.unlock(.maxActBossChestStorage9, heroLevel: 3, availableGold: 0)
        let unlockedTenthActBossChestStorage = tree.unlock(.maxActBossChestStorage10, heroLevel: 3, availableGold: 0)
        #expect(unlockedNormalChestStorage)
        #expect(unlockedSecondNormalChestStorage)
        #expect(unlockedThirdNormalChestStorage)
        #expect(unlockedFourthNormalChestStorage)
        #expect(unlockedFifthNormalChestStorage)
        #expect(unlockedSixthNormalChestStorage)
        #expect(unlockedSeventhNormalChestStorage)
        #expect(unlockedEighthNormalChestStorage)
        #expect(unlockedNinthNormalChestStorage)
        #expect(unlockedTenthNormalChestStorage)
        #expect(unlockedEleventhNormalChestStorage)
        #expect(unlockedTwelfthNormalChestStorage)
        #expect(unlockedThirteenthNormalChestStorage)
        #expect(unlockedFourteenthNormalChestStorage)
        #expect(unlockedFifteenthNormalChestStorage)
        #expect(unlockedStageBossChestStorage)
        #expect(unlockedSecondStageBossChestStorage)
        #expect(unlockedThirdStageBossChestStorage)
        #expect(unlockedFourthStageBossChestStorage)
        #expect(unlockedFifthStageBossChestStorage)
        #expect(unlockedSixthStageBossChestStorage)
        #expect(unlockedSeventhStageBossChestStorage)
        #expect(unlockedEighthStageBossChestStorage)
        #expect(unlockedNinthStageBossChestStorage)
        #expect(unlockedTenthStageBossChestStorage)
        #expect(unlockedEleventhStageBossChestStorage)
        #expect(unlockedTwelfthStageBossChestStorage)
        #expect(unlockedThirteenthStageBossChestStorage)
        #expect(unlockedActBossChestStorage)
        #expect(unlockedSecondActBossChestStorage)
        #expect(unlockedThirdActBossChestStorage)
        #expect(unlockedFourthActBossChestStorage)
        #expect(unlockedFifthActBossChestStorage)
        #expect(unlockedSixthActBossChestStorage)
        #expect(unlockedSeventhActBossChestStorage)
        #expect(unlockedEighthActBossChestStorage)
        #expect(unlockedNinthActBossChestStorage)
        #expect(unlockedTenthActBossChestStorage)
        #expect(tree.chestStorageLimits.normalMonster == ChestStorageLimits.base.normalMonster + RuneTree.chestStorageCapacityBonus * 15)
        #expect(tree.chestStorageLimits.stageBoss == ChestStorageLimits.base.stageBoss + RuneTree.chestStorageCapacityBonus * 13)
        #expect(tree.chestStorageLimits.actBoss == ChestStorageLimits.base.actBoss + RuneTree.chestStorageCapacityBonus * 10)
        #expect(!RuneTreeNode.inventoryExpansion1.hasVerifiedGoldCost)
        #expect(RuneTreeNode.inventoryExpansion1.costText == "成本待核对")
        #expect(RuneTree.inventoryExpansionNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" })
        var combatRewardTree = RuneTree()
        #expect(!combatRewardTree.canUnlock(.combatXPBoost1, heroLevel: 3, availableGold: 0))
        #expect(combatRewardTree.unlock(.combatGoldBoost1, heroLevel: 3, availableGold: 0))
        #expect(combatRewardTree.combatGoldMultiplier == 1.0 + RuneTree.combatRewardMultiplierBonus)
        #expect(combatRewardTree.unlock(.combatXPBoost1, heroLevel: 3, availableGold: 0))
        #expect(combatRewardTree.combatXPMultiplier == 1.0 + RuneTree.combatRewardMultiplierBonus)
        var unlockedRemainingCombatGoldRunes = true
        for node in RuneTree.combatGoldBoostNodes.dropFirst() {
            unlockedRemainingCombatGoldRunes = combatRewardTree.unlock(node, heroLevel: 3, availableGold: 0) && unlockedRemainingCombatGoldRunes
        }
        var unlockedRemainingCombatXPRunes = true
        for node in RuneTree.combatXPBoostNodes.dropFirst() {
            unlockedRemainingCombatXPRunes = combatRewardTree.unlock(node, heroLevel: 3, availableGold: 0) && unlockedRemainingCombatXPRunes
        }
        #expect(unlockedRemainingCombatGoldRunes)
        #expect(unlockedRemainingCombatXPRunes)
        #expect(combatRewardTree.combatGoldMultiplier == 1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatGoldBoostNodes.count))
        #expect(combatRewardTree.combatXPMultiplier == 1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatXPBoostNodes.count))
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
        #expect(
            combatRewardTree.combatGoldMultiplier(for: .normalMonster) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatGoldBoostNodes.count + RuneTree.additionalGoldBoostNodes.count + RuneTree.additionalGoldNormalMonsterNodes.count)
        )
        #expect(
            combatRewardTree.combatGoldMultiplier(for: .stageBoss) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatGoldBoostNodes.count + RuneTree.additionalGoldBoostNodes.count + RuneTree.additionalGoldStageBossNodes.count)
        )
        #expect(
            combatRewardTree.combatGoldMultiplier(for: .actBoss) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatGoldBoostNodes.count + RuneTree.additionalGoldBoostNodes.count + RuneTree.additionalGoldActBossNodes.count)
        )
        #expect(
            combatRewardTree.combatXPMultiplier(for: .normalMonster) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatXPBoostNodes.count + RuneTree.additionalXPBoostNodes.count + RuneTree.additionalXPNormalMonsterNodes.count)
        )
        #expect(
            combatRewardTree.combatXPMultiplier(for: .stageBoss) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatXPBoostNodes.count + RuneTree.additionalXPBoostNodes.count + RuneTree.additionalXPStageBossNodes.count)
        )
        #expect(
            combatRewardTree.combatXPMultiplier(for: .actBoss) ==
                1.0 + RuneTree.combatRewardMultiplierBonus * Double(RuneTree.combatXPBoostNodes.count + RuneTree.additionalXPBoostNodes.count + RuneTree.additionalXPActBossNodes.count)
        )
        var chestDropTree = RuneTree()
        for node in RuneTree.normalChestDropChanceNodes + RuneTree.stageBossChestDropChanceNodes {
            _ = chestDropTree.unlock(node, heroLevel: 3, availableGold: 0)
        }
        #expect(chestDropTree.chestDropBonuses.normalMonsterChance == RuneTree.chestDropChanceBonus * Double(RuneTree.normalChestDropChanceNodes.count))
        #expect(chestDropTree.chestDropBonuses.stageBossChance == RuneTree.chestDropChanceBonus * Double(RuneTree.stageBossChestDropChanceNodes.count))

        var autoOpenSpeedTree = RuneTree()
        for node in RuneTree.normalChestAutoOpenSpeedNodes + RuneTree.stageBossChestAutoOpenSpeedNodes + RuneTree.actBossChestAutoOpenSpeedNodes {
            _ = autoOpenSpeedTree.unlock(node, heroLevel: 3, availableGold: 0)
        }
        #expect(autoOpenSpeedTree.normalChestAutoOpenCooldown == RuneTree.normalChestAutoOpenBaseCooldown - RuneTree.normalChestAutoOpenCooldownReductionByNode.values.reduce(0, +))
        #expect(autoOpenSpeedTree.stageBossChestAutoOpenCooldown == RuneTree.stageBossChestAutoOpenBaseCooldown - RuneTree.stageBossChestAutoOpenCooldownReductionByNode.values.reduce(0, +))
        #expect(autoOpenSpeedTree.actBossChestAutoOpenCooldown == RuneTree.actBossChestAutoOpenBaseCooldown - RuneTree.actBossChestAutoOpenCooldownReductionByNode.values.reduce(0, +))

        var inventoryTree = RuneTree()
        #expect(!inventoryTree.canUnlock(.inventoryExpansion1, heroLevel: 3, availableGold: 0))
        let unlockedInventoryPrerequisite = inventoryTree.unlock(.partySlot2, heroLevel: 3, availableGold: 50_000)
        let unlockedInventoryExpansion = inventoryTree.unlock(.inventoryExpansion1, heroLevel: 3, availableGold: 0)
        let unlockedSecondInventoryExpansion = inventoryTree.unlock(.inventoryExpansion2, heroLevel: 3, availableGold: 0)
        #expect(unlockedInventoryPrerequisite)
        #expect(unlockedInventoryExpansion)
        #expect(unlockedSecondInventoryExpansion)
        #expect(inventoryTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * 2)
        var unlockedRemainingInventoryExpansions = true
        for node in RuneTree.inventoryExpansionNodes.dropFirst(2) {
            unlockedRemainingInventoryExpansions = inventoryTree.unlock(node, heroLevel: 3, availableGold: 0) && unlockedRemainingInventoryExpansions
        }
        #expect(unlockedRemainingInventoryExpansions)
        #expect(inventoryTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * RuneTree.inventoryExpansionNodes.count)
        let unlockedStashPage = inventoryTree.unlock(.stashPage1, heroLevel: 3, availableGold: 0)
        let unlockedSecondStashPage = inventoryTree.unlock(.stashPage2, heroLevel: 3, availableGold: 0)
        let unlockedThirdStashPage = inventoryTree.unlock(.stashPage3, heroLevel: 3, availableGold: 0)
        #expect(unlockedStashPage)
        #expect(unlockedSecondStashPage)
        #expect(unlockedThirdStashPage)
        #expect(inventoryTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus * RuneTree.inventoryExpansionNodes.count + RuneTree.stashPageSlotBonus * 3)
        #expect(!RuneTreeNode.offlineRewards.hasVerifiedGoldCost)
        #expect(RuneTreeNode.offlineRewards.costText == "成本待核对")
        #expect(!tree.canUnlock(.offlineRewards, heroLevel: 2, availableGold: 0))
        let unlockedOfflineRewards = tree.unlock(.offlineRewards, heroLevel: 3, availableGold: 0)
        #expect(unlockedOfflineRewards)
        #expect(tree.offlineRewardsUnlocked)
        #expect(RuneTree.offlineGoldBoostNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" })
        #expect(RuneTree.offlineXPBoostNodes.allSatisfy { !$0.hasVerifiedGoldCost && $0.costText == "成本待核对" })

        var offlineBoostTree = RuneTree()
        #expect(!offlineBoostTree.canUnlock(.offlineGoldBoost, heroLevel: 3, availableGold: 0))
        #expect(!offlineBoostTree.canUnlock(.offlineXPBoost, heroLevel: 3, availableGold: 0))
        let unlockedOfflineBoostPrerequisite = offlineBoostTree.unlock(.offlineRewards, heroLevel: 3, availableGold: 0)
        let unlockedOfflineGoldBoost = offlineBoostTree.unlock(.offlineGoldBoost, heroLevel: 3, availableGold: 0)
        let unlockedOfflineXPBoost = offlineBoostTree.unlock(.offlineXPBoost, heroLevel: 3, availableGold: 0)
        #expect(unlockedOfflineBoostPrerequisite)
        #expect(unlockedOfflineGoldBoost)
        #expect(unlockedOfflineXPBoost)
        #expect(!offlineBoostTree.unlock(.offlineXPBoost2, heroLevel: 3, availableGold: 0))
        #expect(offlineBoostTree.unlock(.offlineGoldBoost2, heroLevel: 3, availableGold: 0))
        #expect(offlineBoostTree.unlock(.offlineGoldBoost3, heroLevel: 3, availableGold: 0))
        #expect(offlineBoostTree.unlock(.offlineGoldBoost4, heroLevel: 3, availableGold: 0))
        #expect(offlineBoostTree.unlock(.offlineGoldBoost5, heroLevel: 3, availableGold: 0))
        #expect(offlineBoostTree.unlock(.offlineXPBoost2, heroLevel: 3, availableGold: 0))
        #expect(offlineBoostTree.unlock(.offlineXPBoost3, heroLevel: 3, availableGold: 0))
        #expect(offlineBoostTree.unlock(.offlineXPBoost4, heroLevel: 3, availableGold: 0))
        #expect(offlineBoostTree.unlock(.offlineXPBoost5, heroLevel: 3, availableGold: 0))
        #expect(offlineBoostTree.offlineGoldMultiplier == 1.0 + 0.10 * 5.0)
        #expect(offlineBoostTree.offlineXPMultiplier == 1.0 + 0.10 * 5.0)

        var resetTree = RuneTree(unlockedNodes: Set(RuneTreeNode.allCases))
        #expect(resetTree.verifiedResetRefundGold == 200_000)
        let resetRefund = resetTree.resetUnlockedNodes()
        #expect(resetRefund == 200_000)
        #expect(resetTree.unlockedNodes.isEmpty)
        #expect(resetTree.unlockedPartySlotCount == 1)
        #expect(resetTree.activeSkillSlotCount == 1)
        #expect(resetTree.allHeroAttackDamage == 0)
        #expect(resetTree.allHeroArmor == 0)
        #expect(resetTree.allHeroMoveSpeed == 0)
        #expect(resetTree.allHeroAttackDamageMultiplier == 1.0)
        #expect(resetTree.allHeroArmorMultiplier == 1.0)
        #expect(resetTree.allHeroAttackSpeedMultiplier == 1.0)
        #expect(resetTree.cubeExperienceMultiplier == 1.0)
        #expect(resetTree.alchemyGoldMultiplier == 1.0)
        #expect(resetTree.inventoryCapacity == Inventory.baseCapacity)
        #expect(!resetTree.canAutoOpenNormalChests)
        #expect(!resetTree.canAutoOpenStageBossChests)
        #expect(!resetTree.canAutoOpenActBossChests)
        #expect(resetTree.chestDropBonuses == .none)
        #expect(resetTree.normalChestAutoOpenCooldown == RuneTree.normalChestAutoOpenBaseCooldown)
        #expect(resetTree.stageBossChestAutoOpenCooldown == RuneTree.stageBossChestAutoOpenBaseCooldown)
        #expect(resetTree.actBossChestAutoOpenCooldown == RuneTree.actBossChestAutoOpenBaseCooldown)
        #expect(resetTree.chestStorageLimits == ChestStorageLimits.base)
        #expect(!resetTree.offlineRewardsUnlocked)
    }
}
