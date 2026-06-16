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

        #expect(maxLevel == 6)

        let appliedXP = HeroLevelPacing.grantXP(1_000_000, to: hero, maxLevel: maxLevel)

        #expect(appliedXP < 1_000_000)
        #expect(hero.level == maxLevel)
        #expect(hero.currentXP == hero.xpForNextLevel() - 1)
    }

    @Test func levelPacingAllowsNewGamePlusHeadroomWithoutUnboundedGrowth() {
        var progress = ProgressTracker()
        progress.currentDifficultyIndex = Difficulty.allCases.count - 1
        progress.currentChapterIndex = Chapter.allCases.count - 1
        progress.currentStageIndex = StageDefinition.stagesPerAct - 1
        progress.playthrough = 3

        #expect(HeroLevelPacing.maxHeroLevel(for: progress) == 140)
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
        #expect(Set(mappedIcons).count == 14)
        #expect(SourceRuneCatalog.runtimeModeledNodes.count == RuneTreeNode.allCases.count)
        #expect(SourceRuneCatalog.runtimeModeledNodes.count == 15)
        #expect(SourceRuneCatalog.runtimeUnmodeledNodes.count == 182)
        #expect(SourceRuneCatalog.runtimeModeledIconNames.count == 14)
        #expect(SourceRuneCatalog.runtimeUnmodeledOnlyIconNames.count == 25)
        #expect(SourceRuneCatalog.runtimeSharedModeledAndUnmodeledIconNames == [
            "MaxInventorySlot",
            "MaxAmountStageBossChest",
            "OfflineRewardGoldPercent",
            "OfflineRewardExpPercent",
            "MaxAmountNormalChest",
            "MaxAmountActBossChest"
        ])
        #expect(GameArt.runeTreeIconName(for: .partySlot2) == "source_rune_UnlockArrangeSlotCount")
        #expect(GameArt.runeTreeIconName(for: .partySlot3) == "source_rune_UnlockArrangeSlotCount")
        #expect(GameArt.runeTreeIconName(for: .activeSkillSlot2) == "source_rune_UnlockSkillSlotCount")
        #expect(GameArt.runeTreeIconName(for: .inventoryExpansion1) == "source_rune_MaxInventorySlot")
        #expect(GameArt.runeTreeIconName(for: .openOneChestType) == "source_rune_OpenOneTypeChestAllAtOnce")
        #expect(GameArt.runeTreeIconName(for: .openAllChestTypes) == "source_rune_OpenAllTypeChestAllAtOnce")
        #expect(GameArt.runeTreeIconName(for: .autoOpenNormalChests) == "source_rune_UnlockAutoOpenNormalChest")
        #expect(GameArt.runeTreeIconName(for: .autoOpenStageBossChests) == "source_rune_UnlockAutoOpenStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .autoOpenActBossChests) == "source_rune_UnlockAutoOpenActBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxNormalChestStorage) == "source_rune_MaxAmountNormalChest")
        #expect(GameArt.runeTreeIconName(for: .maxStageBossChestStorage) == "source_rune_MaxAmountStageBossChest")
        #expect(GameArt.runeTreeIconName(for: .maxActBossChestStorage) == "source_rune_MaxAmountActBossChest")
        #expect(GameArt.runeTreeIconName(for: .offlineRewards) == "source_rune_UnlockOfflineReward")
        #expect(GameArt.runeTreeIconName(for: .offlineGoldBoost) == "source_rune_OfflineRewardGoldPercent")
        #expect(GameArt.runeTreeIconName(for: .offlineXPBoost) == "source_rune_OfflineRewardExpPercent")
    }

    @Test func partySlotsUnlockInOrder() {
        var tree = RuneTree()

        #expect(tree.unlockedPartySlotCount == 1)
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
        let unlockedStageBossChestStorage = tree.unlock(.maxStageBossChestStorage, heroLevel: 3, availableGold: 0)
        let unlockedActBossChestStorage = tree.unlock(.maxActBossChestStorage, heroLevel: 3, availableGold: 0)
        #expect(unlockedNormalChestStorage)
        #expect(unlockedStageBossChestStorage)
        #expect(unlockedActBossChestStorage)
        #expect(tree.chestStorageLimits.normalMonster == ChestStorageLimits.base.normalMonster + RuneTree.chestStorageCapacityBonus)
        #expect(tree.chestStorageLimits.stageBoss == ChestStorageLimits.base.stageBoss + RuneTree.chestStorageCapacityBonus)
        #expect(tree.chestStorageLimits.actBoss == ChestStorageLimits.base.actBoss + RuneTree.chestStorageCapacityBonus)
        #expect(!RuneTreeNode.inventoryExpansion1.hasVerifiedGoldCost)
        #expect(RuneTreeNode.inventoryExpansion1.costText == "成本待核对")
        var inventoryTree = RuneTree()
        #expect(!inventoryTree.canUnlock(.inventoryExpansion1, heroLevel: 3, availableGold: 0))
        let unlockedInventoryPrerequisite = inventoryTree.unlock(.partySlot2, heroLevel: 3, availableGold: 50_000)
        let unlockedInventoryExpansion = inventoryTree.unlock(.inventoryExpansion1, heroLevel: 3, availableGold: 0)
        #expect(unlockedInventoryPrerequisite)
        #expect(unlockedInventoryExpansion)
        #expect(inventoryTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus)
        #expect(!RuneTreeNode.offlineRewards.hasVerifiedGoldCost)
        #expect(RuneTreeNode.offlineRewards.costText == "成本待核对")
        #expect(!tree.canUnlock(.offlineRewards, heroLevel: 2, availableGold: 0))
        let unlockedOfflineRewards = tree.unlock(.offlineRewards, heroLevel: 3, availableGold: 0)
        #expect(unlockedOfflineRewards)
        #expect(tree.offlineRewardsUnlocked)
        #expect(!RuneTreeNode.offlineGoldBoost.hasVerifiedGoldCost)
        #expect(!RuneTreeNode.offlineXPBoost.hasVerifiedGoldCost)
        #expect(RuneTreeNode.offlineGoldBoost.costText == "成本待核对")
        #expect(RuneTreeNode.offlineXPBoost.costText == "成本待核对")

        var offlineBoostTree = RuneTree()
        #expect(!offlineBoostTree.canUnlock(.offlineGoldBoost, heroLevel: 3, availableGold: 0))
        #expect(!offlineBoostTree.canUnlock(.offlineXPBoost, heroLevel: 3, availableGold: 0))
        let unlockedOfflineBoostPrerequisite = offlineBoostTree.unlock(.offlineRewards, heroLevel: 3, availableGold: 0)
        let unlockedOfflineGoldBoost = offlineBoostTree.unlock(.offlineGoldBoost, heroLevel: 3, availableGold: 0)
        let unlockedOfflineXPBoost = offlineBoostTree.unlock(.offlineXPBoost, heroLevel: 3, availableGold: 0)
        #expect(unlockedOfflineBoostPrerequisite)
        #expect(unlockedOfflineGoldBoost)
        #expect(unlockedOfflineXPBoost)
        #expect(offlineBoostTree.offlineGoldMultiplier == 1.10)
        #expect(offlineBoostTree.offlineXPMultiplier == 1.10)

        var resetTree = RuneTree(unlockedNodes: [.partySlot2, .partySlot3, .activeSkillSlot2, .inventoryExpansion1, .autoOpenNormalChests, .autoOpenStageBossChests, .autoOpenActBossChests, .maxNormalChestStorage, .maxStageBossChestStorage, .maxActBossChestStorage, .offlineRewards, .offlineGoldBoost, .offlineXPBoost])
        #expect(resetTree.verifiedResetRefundGold == 200_000)
        let resetRefund = resetTree.resetUnlockedNodes()
        #expect(resetRefund == 200_000)
        #expect(resetTree.unlockedNodes.isEmpty)
        #expect(resetTree.unlockedPartySlotCount == 1)
        #expect(resetTree.activeSkillSlotCount == 1)
        #expect(resetTree.inventoryCapacity == Inventory.baseCapacity)
        #expect(!resetTree.canAutoOpenNormalChests)
        #expect(!resetTree.canAutoOpenStageBossChests)
        #expect(!resetTree.canAutoOpenActBossChests)
        #expect(resetTree.chestStorageLimits == ChestStorageLimits.base)
        #expect(!resetTree.offlineRewardsUnlocked)
    }
}
