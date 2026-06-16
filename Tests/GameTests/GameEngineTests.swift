import Testing
import Foundation
@testable import TBH

private final class SaveRoundTripRecordingAudio: GameAudioPlaying {
    var isEnabled = true

    func play(_ event: GameAudioEvent) {}
}

@Suite struct ItemContractTests {
    @Test func equalItemsHaveEqualHashes() {
        // == 只比较 id，hash 必须遵守同样的契约
        let a = Item(id: "same", name: "甲", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 1), description: "x")
        let b = Item(id: "same", name: "乙", rarity: .rare, slot: .armor, stats: ItemStats(bonusDEF: 9), description: "y")
        #expect(a == b)
        #expect(a.hashValue == b.hashValue, "Equal items must have equal hashes")
    }

    @Test func setMembershipFollowsIdentity() {
        let a = Item(id: "same", name: "甲", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 1), description: "x")
        let b = Item(id: "same", name: "乙", rarity: .rare, slot: .armor, stats: ItemStats(bonusDEF: 9), description: "y")
        var set: Set<Item> = [a]
        #expect(set.contains(b), "Set must treat equal-id items as the same member")
        set.insert(b)
        #expect(set.count == 1)
    }
}

@Suite struct InventoryCapacityTests {
    @Test func addReportsSuccessAndFailure() {
        let inventory = Inventory()
        for i in 0..<inventory.maxCapacity {
            let added = inventory.add(Item(id: "i\(i)", name: "x", rarity: .common, slot: nil, stats: ItemStats(), description: ""))
            #expect(added, "Adding within capacity should succeed")
        }
        let overflow = inventory.add(Item(id: "overflow", name: "x", rarity: .common, slot: nil, stats: ItemStats(), description: ""))
        #expect(!overflow, "Adding to a full inventory should fail")
        #expect(inventory.items.count == inventory.maxCapacity)
        inventory.setMaxCapacity(Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus)
        let expandedAdd = inventory.add(Item(id: "expanded", name: "x", rarity: .common, slot: nil, stats: ItemStats(), description: ""))
        #expect(expandedAdd, "Expanded inventory capacity should accept additional items")
        #expect(inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus)
    }
}

@Suite struct GameEngineEquipTests {
    private final class RecordingAudio: GameAudioPlaying {
        var isEnabled = true
        var events: [GameAudioEvent] = []

        func play(_ event: GameAudioEvent) {
            guard isEnabled else { return }
            events.append(event)
        }
    }

    private func makeEngine() -> GameEngine {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-\(UUID().uuidString)", isDirectory: true)
        return GameEngine(saveManager: SaveManager(directory: tempDir), audio: RecordingAudio())
    }

    @Test func equipFromInventoryReturnsOldItemToInventory() {
        let engine = makeEngine()
        let sword1 = Item(id: "s1", name: "铁剑", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 5), description: "")
        let sword2 = Item(id: "s2", name: "钢剑", rarity: .rare, slot: .weapon, stats: ItemStats(bonusATK: 10), description: "")
        engine.inventory.add(sword1)
        engine.inventory.add(sword2)

        engine.equipItem(sword1)
        #expect(engine.hero.equipment.weapon?.id == "s1")
        #expect(engine.inventory.items.count == 1, "Equipped item leaves the inventory")

        engine.equipItem(sword2)
        #expect(engine.hero.equipment.weapon?.id == "s2")
        #expect(engine.inventory.items.map(\.id) == ["s1"], "Old weapon must return to inventory, not vanish")
    }

    @Test func equipNonEquippableIsNoOp() {
        let engine = makeEngine()
        let junk = Item(id: "j1", name: "杂物", rarity: .common, slot: nil, stats: ItemStats(), description: "")
        engine.inventory.add(junk)
        engine.equipItem(junk)
        #expect(engine.inventory.items.count == 1, "Non-equippable item stays in inventory")
        #expect(engine.hero.equipment.weapon == nil)
    }

    @Test func autoEquipBestItemsUsesBestItemPerSlot() {
        let engine = makeEngine()
        let weakSword = Item(id: "s1", name: "旧剑", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 3), description: "")
        let strongSword = Item(id: "s2", name: "钢剑", rarity: .rare, slot: .weapon, stats: ItemStats(bonusATK: 12), description: "")
        let helmet = Item(id: "h1", name: "皮帽", rarity: .uncommon, slot: .helmet, stats: ItemStats(bonusHP: 25), description: "")
        let weakRing = Item(id: "r1", name: "铜戒指", rarity: .common, slot: .ring, stats: ItemStats(bonusHP: 3), description: "", equipmentType: .ring)
        let strongRing = Item(id: "r2", name: "银戒指", rarity: .rare, slot: .ring, stats: ItemStats(bonusHP: 15), description: "", equipmentType: .ring)
        engine.inventory.add(weakSword)
        engine.inventory.add(strongSword)
        engine.inventory.add(helmet)
        engine.inventory.add(weakRing)
        engine.inventory.add(strongRing)

        engine.setAutoEquipBestItems(true)

        #expect(engine.autoEquipBestItems)
        #expect(engine.hero.equipment.weapon?.id == "s2")
        #expect(engine.hero.equipment.helmet?.id == "h1")
        #expect(engine.hero.equipment.ring?.id == "r2")
        #expect(engine.inventory.items.contains(weakSword))
        #expect(engine.inventory.items.contains(weakRing))
        #expect(!engine.inventory.items.contains(strongSword))
        #expect(!engine.inventory.items.contains(strongRing))
    }

    @Test func resetGameClearsState() {
        let engine = makeEngine()
        engine.hero.gainGold(999)
        engine.hero.gainXP(engine.hero.xpForNextLevel())
        let cubeItem = Item(id: "x", name: "x", rarity: .common, slot: nil, stats: ItemStats(), description: "")
        engine.inventory.add(cubeItem)
        #expect(engine.infuseItemIntoCube(cubeItem) == Rarity.common.cubeExperience)
        #expect(engine.cubeProgress.totalExperience == Rarity.common.cubeExperience)
        engine.inventory.add(Item(id: "y", name: "y", rarity: .common, slot: nil, stats: ItemStats(), description: ""))
        engine.setSoundEffectsEnabled(false)
        engine.save()

        engine.resetGame()
        #expect(engine.hero.level == 1)
        #expect(engine.hero.gold == 0)
        #expect(engine.inventory.items.isEmpty)
        #expect(engine.purchasedInventoryExpansionCount == 0)
        #expect(engine.inventory.maxCapacity == Inventory.baseCapacity)
        #expect(engine.cubeProgress.totalExperience == 0)
        #expect(engine.cubeProgress.infusedItemCount == 0)
        #expect(engine.progress.killsInChapter == 0)
        #expect(engine.statistics.monstersKilled == 0)
        #expect(engine.soundEffectsEnabled)
    }

    @Test func cubeInfusionConsumesUnlockedItemsAndProtectsLockedItems() {
        let engine = makeEngine()
        let unlocked = Item(id: "cube1", name: "Cube 材料", rarity: .rare, slot: nil, stats: ItemStats(), description: "")
        let locked = Item(id: "cube2", name: "锁定材料", rarity: .cosmic, slot: nil, stats: ItemStats(), description: "", isLocked: true)
        engine.inventory.add(unlocked)
        engine.inventory.add(locked)

        #expect(engine.infuseItemIntoCube(locked) == nil)
        #expect(engine.inventory.items.contains(locked))
        #expect(engine.cubeProgress.totalExperience == 0)

        #expect(engine.infuseItemIntoCube(unlocked) == Rarity.rare.cubeExperience)
        #expect(!engine.inventory.items.contains(unlocked))
        #expect(engine.inventory.items.contains(locked))
        #expect(engine.cubeProgress.totalExperience == Rarity.rare.cubeExperience)
        #expect(engine.cubeProgress.infusedItemCount == 1)
    }

    @Test func alchemyConsumesUnlockedItemsAndProtectsLockedItems() {
        let engine = makeEngine()
        let unlocked = Item(id: "alchemy1", name: "炼金材料", rarity: .rare, slot: nil, stats: ItemStats(), description: "")
        let locked = Item(id: "alchemy2", name: "锁定炼金材料", rarity: .cosmic, slot: nil, stats: ItemStats(), description: "", isLocked: true)
        engine.inventory.add(unlocked)
        engine.inventory.add(locked)

        let goldBeforeAlchemy = engine.hero.gold
        #expect(engine.alchemizeItem(locked) == nil)
        #expect(engine.hero.gold == goldBeforeAlchemy)
        #expect(engine.inventory.items.contains(locked))

        #expect(engine.alchemizeItem(unlocked) == Rarity.rare.alchemyGoldValue)
        #expect(!engine.inventory.items.contains(unlocked))
        #expect(engine.inventory.items.contains(locked))
        #expect(engine.hero.gold == goldBeforeAlchemy + Rarity.rare.alchemyGoldValue)
    }

    @Test func synthesisConsumesNineUnlockedSameRarityItemsAndProtectsLockedItems() throws {
        let engine = makeEngine()
        for index in 0..<9 {
            engine.inventory.add(Item(
                id: "synthesis-\(index)",
                name: "合成材料 \(index)",
                rarity: .common,
                slot: .weapon,
                stats: ItemStats(bonusATK: index + 1),
                description: "",
                itemLevel: 12,
                equipmentType: .sword
            ))
        }
        let locked = Item(
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
        engine.inventory.add(locked)

        let output = try #require(engine.synthesizeItems(rarity: .common))

        #expect(output.rarity == .uncommon)
        #expect(output.equipmentType == .sword)
        #expect(output.itemLevel == 12)
        #expect(output.name == "Rapier")
        #expect(output.description.contains("来源装备 300003"))
        #expect(engine.inventory.items.count == 2)
        #expect(engine.inventory.items.contains(locked))
        #expect(engine.inventory.items.contains(output))
        #expect(engine.synthesizeItems(rarity: .cosmic) == nil)
    }

    @Test func soundEffectsSettingPersists() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)
        let audio = RecordingAudio()
        let engine = GameEngine(saveManager: manager, audio: audio)

        engine.setSoundEffectsEnabled(false)

        let reloaded = GameEngine(saveManager: manager, audio: RecordingAudio())
        reloaded.start()
        reloaded.stop()
        #expect(!reloaded.soundEffectsEnabled)
    }

    @Test func purchasedInventoryExpansionCanRepeatAndPersist() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)
        let engine = GameEngine(saveManager: manager, audio: RecordingAudio())
        engine.start()

        #expect(engine.inventory.maxCapacity == Inventory.baseCapacity)
        #expect(engine.nextInventoryExpansionGoldCost == 50_000)
        #expect(!engine.canPurchaseInventoryExpansion())

        engine.hero.gainGold(150_000)
        #expect(engine.purchaseInventoryExpansion())
        #expect(engine.purchasedInventoryExpansionCount == 1)
        #expect(engine.hero.gold == 100_000)
        #expect(engine.inventory.maxCapacity == Inventory.baseCapacity + InventoryExpansion.slotBonus)
        #expect(engine.nextInventoryExpansionGoldCost == 100_000)

        #expect(engine.purchaseInventoryExpansion())
        #expect(engine.purchasedInventoryExpansionCount == 2)
        #expect(engine.hero.gold == 0)
        #expect(engine.inventory.maxCapacity == Inventory.baseCapacity + InventoryExpansion.slotBonus * 2)
        #expect(engine.nextInventoryExpansionGoldCost == 150_000)
        #expect(!engine.purchaseInventoryExpansion())
        engine.stop()

        let reloaded = GameEngine(saveManager: manager, audio: RecordingAudio())
        reloaded.start()
        reloaded.stop()
        #expect(reloaded.purchasedInventoryExpansionCount == 2)
        #expect(reloaded.inventory.maxCapacity == Inventory.baseCapacity + InventoryExpansion.slotBonus * 2)
        #expect(reloaded.nextInventoryExpansionGoldCost == 150_000)
    }

    @Test func worseEquipmentHandlingCanKeepAlchemizeOrDiscardNewLoot() {
        let engine = makeEngine()
        let equipped = Item(
            id: "equipped-weapon",
            name: "强剑",
            rarity: .rare,
            slot: .weapon,
            stats: ItemStats(bonusATK: 50),
            description: "",
            equipmentType: .sword
        )
        let weakLoot = Item(
            id: "weak-loot",
            name: "弱剑",
            rarity: .uncommon,
            slot: .weapon,
            stats: ItemStats(bonusATK: 1),
            description: "",
            equipmentType: .sword
        )
        engine.inventory.add(equipped)
        engine.equipItem(equipped)

        #expect(engine.retainLootForTesting(weakLoot))
        #expect(engine.inventory.items.contains(weakLoot))

        engine.inventory.remove(weakLoot)
        engine.setWorseEquipmentHandling(.alchemize)
        let goldBeforeAlchemy = engine.hero.gold
        #expect(engine.retainLootForTesting(weakLoot))
        #expect(!engine.inventory.items.contains(weakLoot))
        #expect(engine.hero.gold == goldBeforeAlchemy + Rarity.uncommon.alchemyGoldValue)

        engine.setWorseEquipmentHandling(.discard)
        let goldBeforeDiscard = engine.hero.gold
        #expect(engine.retainLootForTesting(weakLoot))
        #expect(!engine.inventory.items.contains(weakLoot))
        #expect(engine.hero.gold == goldBeforeDiscard)

        let strongerLoot = Item(
            id: "stronger-loot",
            name: "更强剑",
            rarity: .legendary,
            slot: .weapon,
            stats: ItemStats(bonusATK: 500),
            description: "",
            equipmentType: .sword
        )
        #expect(engine.retainLootForTesting(strongerLoot))
        #expect(engine.inventory.items.contains(strongerLoot))
    }

    @Test func offlineRewardsRequireRuneOfRepose() {
        func makeManager(name: String, runeTree: RuneTree) -> SaveManager {
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("TBHTests-\(name)-\(UUID().uuidString)", isDirectory: true)
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

        let locked = GameEngine(
            saveManager: makeManager(name: "offline-locked", runeTree: RuneTree()),
            audio: RecordingAudio()
        )
        locked.start()
        locked.stop()
        #expect(locked.statistics.offlineXP == 0)
        #expect(locked.statistics.offlineGold == 0)
        #expect(locked.hero.gold == 0)

        let unlocked = GameEngine(
            saveManager: makeManager(name: "offline-unlocked", runeTree: RuneTree(unlockedNodes: [.offlineRewards])),
            audio: RecordingAudio()
        )
        unlocked.start()
        unlocked.stop()
        #expect(unlocked.statistics.offlineXP > 0)
        #expect(unlocked.statistics.offlineGold > 0)
        #expect(unlocked.hero.gold > 0)

        let boosted = GameEngine(
            saveManager: makeManager(
                name: "offline-boosted",
                runeTree: RuneTree(unlockedNodes: [.offlineRewards, .offlineGoldBoost, .offlineXPBoost])
            ),
            audio: RecordingAudio()
        )
        boosted.start()
        boosted.stop()
        #expect(boosted.statistics.offlineXP > unlocked.statistics.offlineXP)
        #expect(boosted.statistics.offlineGold > unlocked.statistics.offlineGold)
    }

    @Test func completionSettlementPausesOfflineRewardsUntilNextPlaythrough() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-completion-offline-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)
        var progress = ProgressTracker()
        progress.currentDifficultyIndex = Difficulty.allCases.count - 1
        progress.currentChapterIndex = Chapter.allCases.count - 1
        progress.currentStageIndex = StageDefinition.stagesPerAct - 1
        progress.highestUnlockedDifficultyIndex = Difficulty.allCases.count - 1
        progress.highestUnlockedChapterIndex = Chapter.allCases.count - 1
        progress.highestUnlockedStageIndex = StageDefinition.stagesPerAct - 1
        progress.killsInChapter = 1
        progress.completedPlaythroughs = 1
        progress.isAwaitingNewGamePlus = true

        manager.save(SaveData(
            hero: Hero(),
            runeTree: RuneTree(unlockedNodes: [.offlineRewards]),
            inventory: Inventory(),
            progress: progress,
            statistics: GameStatistics(),
            timestamp: Date().addingTimeInterval(-3_600)
        ))

        let engine = GameEngine(saveManager: manager, audio: RecordingAudio())
        engine.start()
        engine.stop()

        #expect(engine.progress.isAwaitingNewGamePlus)
        #expect(engine.currentBattle == nil)
        #expect(engine.statistics.offlineXP == 0)
        #expect(engine.statistics.offlineGold == 0)
        #expect(engine.hero.gold == 0)
    }

    @Test func heroClassSettingPersistsAndRefreshesBattle() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)
        let engine = GameEngine(saveManager: manager, audio: SaveRoundTripRecordingAudio())
        engine.start()

        engine.setHeroClass(.priest)
        engine.stop()

        #expect(engine.hero.heroClass == .priest)
        #expect(engine.currentBattle?.hero.heroClass == .priest)

        let reloaded = GameEngine(saveManager: manager, audio: RecordingAudio())
        reloaded.start()
        reloaded.stop()
        #expect(reloaded.hero.heroClass == .priest)
    }

    @Test func partySettingPersistsAndRefreshesBattle() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)
        let engine = GameEngine(saveManager: manager, audio: SaveRoundTripRecordingAudio())
        engine.start()

        engine.setPartyMember(slotIndex: 1, heroClass: .sorcerer)
        #expect(engine.party.member(at: 1)?.heroClass == .priest)
        engine.hero.gainXP(1_000)
        engine.hero.gainGold(200_000)
        #expect(engine.unlockRuneTreeNode(.partySlot2))
        #expect(engine.hero.gold == 150_000)
        #expect(engine.unlockRuneTreeNode(.partySlot3))
        #expect(engine.hero.gold == 0)
        engine.setPartyMember(slotIndex: 1, heroClass: .sorcerer)
        engine.setPartyMember(slotIndex: 0, heroClass: .hunter)
        engine.stop()

        #expect(engine.hero.heroClass == .hunter)
        #expect(engine.runeTree.unlockedPartySlotCount == 3)
        #expect(engine.party.member(at: 0)?.heroClass == .hunter)
        #expect(engine.party.member(at: 1)?.heroClass == .sorcerer)
        #expect(engine.currentBattle?.party.member(at: 1)?.heroClass == .sorcerer)

        let reloaded = GameEngine(saveManager: manager, audio: RecordingAudio())
        reloaded.start()
        reloaded.stop()
        #expect(reloaded.hero.heroClass == .hunter)
        #expect(reloaded.runeTree.unlockedPartySlotCount == 3)
        #expect(reloaded.party.member(at: 1)?.heroClass == .sorcerer)
    }

    @Test func directPartySlotUnlockOpensSupportSlotsFromPartyPanelPath() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)
        let engine = GameEngine(saveManager: manager, audio: SaveRoundTripRecordingAudio())
        engine.start()

        engine.hero.gainGold(200_000)
        #expect(!engine.unlockRuneTreeNode(.partySlot2))
        #expect(engine.directPartySlotUnlockCost(slotIndex: 1) == 50_000)
        #expect(engine.directPartySlotUnlockCost(slotIndex: 2) == 200_000)
        #expect(engine.canDirectlyUnlockPartySlot(slotIndex: 2))
        #expect(engine.directlyUnlockPartySlot(slotIndex: 2))
        engine.setPartyMember(slotIndex: 2, heroClass: .slayer)
        engine.stop()

        #expect(engine.hero.gold == 0)
        #expect(engine.runeTree.unlockedPartySlotCount == 3)
        #expect(engine.party.activeCount == 3)
        #expect(engine.party.member(at: 2)?.heroClass == .slayer)
        #expect(engine.currentBattle?.party.activeCount == 3)

        let reloaded = GameEngine(saveManager: manager, audio: RecordingAudio())
        reloaded.start()
        reloaded.stop()
        #expect(reloaded.hero.gold == 0)
        #expect(reloaded.runeTree.unlockedPartySlotCount == 3)
        #expect(reloaded.party.member(at: 2)?.heroClass == .slayer)
    }

    @Test func activeSkillLoadoutPersistsAndRefreshesBattle() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)
        let engine = GameEngine(saveManager: manager, audio: RecordingAudio())
        engine.start()

        engine.setActiveSkill("10201", for: .knight, slotIndex: 0)
        #expect(engine.activeSkillLoadouts.activeSkills(for: .knight, heroLevel: 1, slotCount: 1).map(\.id) == ["10201"])

        let refreshedBattle = try #require(engine.currentBattle)
        refreshedBattle.update(deltaTime: 1)
        #expect(refreshedBattle.log.contains { $0.skillName == "盾牌冲锋" && $0.kind == .damage })
        #expect(!refreshedBattle.log.contains { $0.skillName == "穿透突刺" })
        engine.stop()

        let reloaded = GameEngine(saveManager: manager, audio: RecordingAudio())
        reloaded.start()
        reloaded.stop()
        #expect(reloaded.activeSkillLoadouts.activeSkills(for: .knight, heroLevel: 1, slotCount: 1).map(\.id) == ["10201"])
    }

    @Test func runeTreeResetRelocksPartyAndRefundsVerifiedGold() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)
        let engine = GameEngine(saveManager: manager, audio: RecordingAudio())
        engine.start()

        engine.hero.gainXP(1_000)
        engine.hero.gainGold(200_000)
        #expect(engine.unlockRuneTreeNode(.partySlot2))
        #expect(engine.unlockRuneTreeNode(.partySlot3))
        #expect(engine.hero.gold == 0)
        #expect(engine.currentBattle?.activeSkillSlotCount == 1)
        #expect(engine.unlockRuneTreeNode(.activeSkillSlot2))
        #expect(engine.runeTree.activeSkillSlotCount == 2)
        #expect(engine.currentBattle?.activeSkillSlotCount == 2)
        #expect(engine.inventory.maxCapacity == Inventory.baseCapacity)
        #expect(engine.unlockRuneTreeNode(.inventoryExpansion1))
        #expect(engine.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus)
        engine.setPartyMember(slotIndex: 1, heroClass: .sorcerer)
        engine.resetRuneTree()
        engine.stop()

        #expect(engine.hero.gold == 200_000)
        #expect(engine.runeTree.unlockedNodes.isEmpty)
        #expect(engine.runeTree.unlockedPartySlotCount == 1)
        #expect(engine.runeTree.activeSkillSlotCount == 1)
        #expect(engine.inventory.maxCapacity == Inventory.baseCapacity)
        #expect(engine.party.activeCount == 1)
        #expect(engine.currentBattle?.party.activeCount == 1)

        let reloaded = GameEngine(saveManager: manager, audio: RecordingAudio())
        reloaded.start()
        reloaded.stop()
        #expect(reloaded.hero.gold == 200_000)
        #expect(reloaded.runeTree.unlockedNodes.isEmpty)
        #expect(reloaded.runeTree.activeSkillSlotCount == 1)
        #expect(reloaded.party.activeCount == 1)
    }

    @Test func battleStartsWithRemainingEncountersInCurrentWave() {
        let engine = makeEngine()
        engine.progress.currentStageIndex = 7
        engine.progress.killsInChapter = 72

        engine.setHeroClass(.knight)

        #expect(engine.currentBattle?.monsterCount == 6)
        #expect(engine.currentBattle?.monster.name == "骷髅战士")
    }

    @Test func selectingUnlockedStageRefreshesBattle() {
        let engine = makeEngine()
        for _ in 0..<ProgressTracker.killsToAdvance {
            engine.progress.advance()
        }

        let firstStage = engine.progress.unlockedStageSelections.first { $0.id == "1-1-1" }
        let selected = firstStage.map { engine.selectStage($0) } ?? false

        #expect(selected)
        #expect(engine.progress.currentStage.displayCode == "1-1")
        #expect(engine.currentBattle?.monster.name == "哥布林盗贼")
    }

    @Test func restartingCurrentStageRefreshesBattle() {
        let engine = makeEngine()
        engine.progress.advance()

        engine.restartCurrentStage()

        #expect(engine.progress.killsInChapter == 0)
        #expect(engine.currentBattle?.monster.name == "哥布林盗贼")
    }

    @Test func unyieldingWillIsConsumedAcrossRestartedBattlesInSameStage() throws {
        let engine = makeEngine()
        engine.progress.currentStageIndex = 9
        engine.progress.soulStones.grant(.normal)
        engine.activeSkillLoadouts.setSkills(["10601"], for: .knight)
        engine.setHeroClass(.knight)

        let firstBattle = try #require(engine.currentBattle)
        #expect(firstBattle.monsterCount == 1)
        let firstBattleSkillIDs = firstBattle.activeSkillLoadouts
            .activeSkills(for: .knight, heroLevel: engine.hero.level, slotCount: 1)
            .map(\.id)
        #expect(firstBattleSkillIDs == ["10601"])
        engine.hero.takeDamage(engine.hero.currentHP - 1)
        firstBattle.heroHP = engine.hero.currentHP
        firstBattle.update(deltaTime: 1)

        #expect(firstBattle.unyieldingWillWasUsed)
        #expect(engine.hero.currentHP == engine.hero.maxHP * 3)

        engine.setHeroClass(.priest)
        engine.setHeroClass(.knight)
        let secondBattle = try #require(engine.currentBattle)
        engine.hero.takeDamage(engine.hero.currentHP - 1)
        secondBattle.heroHP = engine.hero.currentHP
        secondBattle.update(deltaTime: 1)

        #expect(!secondBattle.unyieldingWillWasUsed)
        #expect(secondBattle.isOver)
    }

    @Test func bossBattleLocksWithoutSoulStone() {
        let engine = makeEngine()
        engine.progress.currentStageIndex = 9

        engine.setHeroClass(.priest)
        #expect(engine.currentBattle == nil)
        #expect(engine.battleLockReason?.contains("灵魂石") == true)

        engine.progress.soulStones.grant(.normal)
        engine.setHeroClass(.ranger)
        #expect(engine.currentBattle != nil)
        #expect(engine.currentBattle?.monster.name == "骷髅王")
        #expect(engine.battleLockReason == nil)
    }

    @Test func openChestAddsSoulStoneAndLoot() {
        let engine = makeEngine()
        let normalChest = LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .normalMonster)
        let stageBossChest = LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss)
        engine.progress.chests.add(normalChest)
        engine.progress.chests.add(stageBossChest)

        let openedStageBoss = engine.openChest(id: stageBossChest.id)
        let openedNormal = engine.openChest(kind: .normal)

        #expect(openedStageBoss)
        #expect(openedNormal)
        #expect(engine.progress.chests.count(for: .normal) == 0)
        #expect(engine.progress.soulStones.count(for: .normal) == 2)
        #expect(engine.inventory.items.count == 2)
        #expect(engine.statistics.itemsFound == 2)
    }

    @Test func openAllChestsConsumesSnapshotAndKeepsRewards() {
        let engine = makeEngine()
        engine.progress.chests.add(LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal))
        engine.progress.chests.add(LootChest(kind: .normal, itemLevel: 5, sourceStageCode: "1-2", sourceDifficulty: .normal))
        engine.progress.chests.add(LootChest(kind: .nightmare, itemLevel: 20, sourceStageCode: "2-1", sourceDifficulty: .nightmare))
        engine.progress.chests.add(LootChest(kind: .hell, itemLevel: 40, sourceStageCode: "3-1", sourceDifficulty: .hell))

        #expect(engine.openAllChests() == 0)
        #expect(engine.openChests(kind: .normal) == 0)
        #expect(engine.progress.chests.totalCount == 4)

        engine.hero.gainXP(1_000)
        #expect(engine.unlockRuneTreeNode(.openOneChestType))
        #expect(engine.openChests(kind: .normal) == 2)
        #expect(engine.progress.chests.totalCount == 2)
        #expect(engine.progress.soulStones.count(for: .normal) == 2)

        #expect(engine.unlockRuneTreeNode(.openAllChestTypes))
        let openedCount = engine.openAllChests()

        #expect(openedCount == 2)
        #expect(engine.progress.chests.totalCount == 0)
        #expect(engine.progress.soulStones.count(for: .nightmare) == 1)
        #expect(engine.progress.soulStones.count(for: .hell) == 1)
        #expect(engine.inventory.items.count == 4)
        #expect(engine.statistics.itemsFound == 4)
    }

    @Test func autoOpenNormalChestRuneConsumesOnlyNormalMonsterBoxes() {
        let engine = makeEngine()
        engine.hero.gainXP(1_000)
        engine.progress.chests.add(LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal, family: .normalMonster))
        engine.progress.chests.add(LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss))

        #expect(engine.unlockRuneTreeNode(.autoOpenNormalChests))
        #expect(engine.runeTree.canAutoOpenNormalChests)
        #expect(engine.progress.chests.totalCount == 1)
        #expect(engine.progress.chests.chests.first?.family == .stageBoss)
        #expect(engine.progress.soulStones.count(for: .normal) == 1)
        #expect(engine.inventory.items.count == 1)
        #expect(engine.statistics.itemsFound == 1)
    }

    @Test func autoOpenStageBossChestRuneConsumesOnlyStageBossBoxes() {
        let engine = makeEngine()
        engine.hero.gainXP(1_000)
        engine.progress.chests.add(LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal, family: .normalMonster))
        engine.progress.chests.add(LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss))
        engine.progress.chests.add(LootChest(kind: .normal, itemLevel: 30, sourceStageCode: "3-10", sourceDifficulty: .normal, family: .actBoss))

        #expect(engine.unlockRuneTreeNode(.autoOpenStageBossChests))
        #expect(engine.runeTree.canAutoOpenStageBossChests)
        #expect(engine.progress.chests.totalCount == 2)
        #expect(engine.progress.chests.chests.filter { $0.family == .normalMonster }.count == 1)
        #expect(engine.progress.chests.chests.filter { $0.family == .stageBoss }.isEmpty)
        #expect(engine.progress.chests.chests.filter { $0.family == .actBoss }.count == 1)
        #expect(engine.progress.soulStones.count(for: .normal) == 1)
        #expect(engine.inventory.items.count == 1)
        #expect(engine.statistics.itemsFound == 1)
    }

    @Test func autoOpenActBossChestRuneConsumesOnlyActBossBoxes() {
        let engine = makeEngine()
        engine.hero.gainXP(1_000)
        engine.progress.chests.add(LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal, family: .normalMonster))
        engine.progress.chests.add(LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss))
        engine.progress.chests.add(LootChest(kind: .normal, itemLevel: 30, sourceStageCode: "3-10", sourceDifficulty: .normal, family: .actBoss))

        #expect(engine.unlockRuneTreeNode(.autoOpenActBossChests))
        #expect(engine.runeTree.canAutoOpenActBossChests)
        #expect(engine.progress.chests.totalCount == 2)
        #expect(engine.progress.chests.chests.filter { $0.family == .normalMonster }.count == 1)
        #expect(engine.progress.chests.chests.filter { $0.family == .stageBoss }.count == 1)
        #expect(engine.progress.chests.chests.filter { $0.family == .actBoss }.isEmpty)
        #expect(engine.progress.soulStones.count(for: .normal) == 1)
        #expect(engine.inventory.items.count == 1)
        #expect(engine.statistics.itemsFound == 1)
    }
}

@Suite struct SaveManagerTests {
    @Test func saveAndLoadRoundTrip() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)

        let hero = Hero()
        hero.gainGold(123)
        hero.unlockedPassiveSkillIDs = ["101001", "101002"]
        var runeTree = RuneTree(unlockedPartySlotCount: 2)
        runeTree.unlockedNodes.insert(.activeSkillSlot2)
        runeTree.unlockedNodes.insert(.inventoryExpansion1)
        var progress = ProgressTracker()
        progress.soulStones.grant(.normal)
        progress.chests.add(LootChest(kind: .normal, itemLevel: 1, sourceStageCode: "1-1", sourceDifficulty: .normal))
        var cubeProgress = CubeProgress()
        _ = cubeProgress.infuse(Item(id: "cube", name: "Cube 材料", rarity: .rare, slot: nil, stats: ItemStats(), description: ""))
        var activeSkillLoadouts = ActiveSkillLoadouts()
        activeSkillLoadouts.setSkill("40301", for: .priest, slotIndex: 0)
        let data = SaveData(
            hero: hero,
            party: HeroParty(primaryClass: .priest),
            runeTree: runeTree,
            cubeProgress: cubeProgress,
            activeSkillLoadouts: activeSkillLoadouts,
            inventory: Inventory(),
            progress: progress,
            statistics: GameStatistics(),
            autoEquipBestItems: true,
            worseEquipmentHandling: .alchemize,
            soundEffectsEnabled: false,
            unyieldingWillConsumedStageKey: "4:3-9",
            timestamp: Date()
        )
        manager.save(data)

        let loaded = try #require(manager.load())
        #expect(loaded.hero.gold == 123)
        #expect(loaded.hero.unlockedPassiveSkillIDs == ["101001", "101002"])
        #expect(loaded.party.member(at: 0)?.heroClass == .priest)
        #expect(loaded.runeTree.unlockedPartySlotCount == 2)
        #expect(loaded.runeTree.activeSkillSlotCount == 2)
        #expect(loaded.runeTree.inventoryCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus)
        #expect(loaded.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus)
        #expect(loaded.party.activeCount == 2)
        #expect(loaded.cubeProgress.totalExperience == Rarity.rare.cubeExperience)
        #expect(loaded.cubeProgress.infusedItemCount == 1)
        #expect(loaded.activeSkillLoadouts.activeSkills(for: .priest, heroLevel: 1, slotCount: 1).map(\.id) == ["40301"])
        #expect(loaded.autoEquipBestItems)
        #expect(loaded.worseEquipmentHandling == .alchemize)
        #expect(!loaded.soundEffectsEnabled)
        #expect(loaded.unyieldingWillConsumedStageKey == "4:3-9")
        #expect(loaded.progress.soulStones.count(for: .normal) == 1)
        #expect(loaded.progress.chests.count(for: .normal) == 1)

        let engine = GameEngine(saveManager: manager, audio: SaveRoundTripRecordingAudio())
        engine.start()
        engine.stop()
        #expect(engine.inventory.maxCapacity == Inventory.baseCapacity + RuneTree.inventoryExpansionSlotBonus)
        #expect(engine.worseEquipmentHandling == .alchemize)
    }
}
