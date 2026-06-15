import Testing
import Foundation
@testable import TBH

@Suite struct InventoryTests {
    @Test func rarityLadderMatchesOriginalTiers() {
        #expect(Rarity.allCases.map(\.rawValue) == [
            "普通", "优秀", "稀有", "传说", "不朽", "奥秘", "超越", "天界", "神圣", "宇宙"
        ])
        #expect(Rarity.arcana.color == "#B40CFC")
        #expect(Rarity.cosmic.alchemyGoldValue == 355_607)
        #expect(Rarity.beyond.slotSummary == "3/2/2")
        #expect(Rarity.cosmic > .divine)
        #expect(Rarity.synthesisInputCount == 9)
        #expect(Rarity.common.synthesisOutputRarity == .uncommon)
        #expect(Rarity.divine.synthesisOutputRarity == .cosmic)
        #expect(Rarity.cosmic.synthesisOutputRarity == nil)
    }

    @Test func synthesisPreviewShowsEligibleInputsLockedItemsAndOutputLevel() {
        let inputs = (0..<9).map {
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

        let preview = SynthesisPreview.make(for: .common, in: inputs)
        #expect(preview.isReady)
        #expect(preview.outputRarity == .uncommon)
        #expect(preview.unlockedInputCount == 9)
        #expect(preview.lockedInputCount == 1)
        #expect(preview.selectedInputCount == 9)
        #expect(preview.outputItemLevel == 12)
        #expect(preview.sourceVariantBoundary == "跳阶/降级概率未核实")

        let cosmicPreview = SynthesisPreview.make(for: .cosmic, in: inputs)
        #expect(!cosmicPreview.isReady)
        #expect(cosmicPreview.outputRarity == nil)
        #expect(cosmicPreview.sourceVariantBoundary == nil)
    }

    @Test func equipmentTaxonomyMatchesOriginalTypeCounts() {
        #expect(EquipmentType.allCases.count == 20)
        let typeCounts = Dictionary(grouping: EquipmentType.allCases, by: \.category).mapValues(\.count)

        #expect(typeCounts[.weapon] == 6)
        #expect(typeCounts[.offhand] == 6)
        #expect(typeCounts[.armor] == 4)
        #expect(typeCounts[.accessory] == 4)
        #expect(Set(EquipmentType.allCases.map(\.equipSlot)).isSuperset(of: Set(EquipSlot.allCases)))

        let equipmentTypeIcons = EquipmentType.allCases.map { GameArt.itemIconName(for: $0) }
        let slotIcons = EquipSlot.allCases.map { GameArt.itemIconName(for: $0) }
        #expect(equipmentTypeIcons.allSatisfy { $0.hasPrefix("item_") })
        #expect(Set(equipmentTypeIcons).count >= 15)
        #expect(Set(equipmentTypeIcons).count > Set(slotIcons).count)
    }

    @Test func sourceItemCatalogMatchesCheckedGearTypePages() {
        #expect(SourceItemCatalog.allGearTypes.count == SourceItemCatalog.expectedGearTypeCount)
        #expect(SourceItemCatalog.expectedGearTypeCount == 20)
        #expect(SourceItemCatalog.missingEquipmentTypes.isEmpty)
        #expect(SourceItemCatalog.totalGearEntryCount == SourceItemCatalog.expectedGearEntryCount)
        #expect(SourceItemCatalog.expectedGearEntryCount == 5_760)
        #expect(SourceItemCatalog.totalRarityDistributionCount == SourceItemCatalog.expectedGearEntryCount)
        #expect(SourceItemCatalog.totalGearLevelProgressionCount == SourceItemCatalog.expectedGearLevelProgressionCount)
        #expect(SourceItemCatalog.expectedGearLevelProgressionCount == 396)
        #expect(SourceItemCatalog.duplicateProgressionIDs.isEmpty)
        #expect(SourceItemCatalog.aggregateRarityCounts[.common] == 320)
        #expect(SourceItemCatalog.aggregateRarityCounts[.uncommon] == 760)
        #expect(SourceItemCatalog.aggregateRarityCounts[.cosmic] == 320)
        #expect(SourceItemCatalog.byType[.sword]?.gearEntryCount == 292)
        #expect(SourceItemCatalog.byType[.sword]?.progressions.first == SourceGearLevelProgression(id: "300001", itemLevel: 1, name: "Long Sword"))
        #expect(SourceItemCatalog.byType[.sword]?.progressions.last == SourceGearLevelProgression(id: "300020", itemLevel: 100, name: "Radiant Sword"))
        #expect(SourceItemCatalog.byType[.amulet]?.gearEntryCount == 272)
        #expect(SourceItemCatalog.byType[.amulet]?.rarityCount(for: .common) == 0)
        #expect(SourceItemCatalog.byType[.earring]?.sourceTitle == "Earing")
    }

    @Test func sourceItemCatalogMatchesCheckedMaterialsAndStageChests() {
        #expect(SourceItemCatalog.allMaterials.count == SourceItemCatalog.expectedMaterialCount)
        #expect(SourceItemCatalog.expectedMaterialCount == 115)
        #expect(SourceItemCatalog.duplicateMaterialIDs.isEmpty)
        #expect(SourceItemCatalog.materialCountsByCategory.count == SourceItemCatalog.expectedMaterialCategoryCount)
        #expect(SourceItemCatalog.materialCountsByCategory[.decoration] == 36)
        #expect(SourceItemCatalog.materialCountsByCategory[.engraving] == 33)
        #expect(SourceItemCatalog.materialCountsByCategory[.inscription] == 10)
        #expect(SourceItemCatalog.materialCountsByCategory[.crafting] == 22)
        #expect(SourceItemCatalog.materialCountsByCategory[.offering] == 10)
        #expect(SourceItemCatalog.materialCountsByCategory[.soulStone] == 4)
        #expect(SourceItemCatalog.materialByID["110001"] == SourceMaterialEntry(id: "110001", name: "Minor Ruby", rarity: .common, category: .decoration))
        #expect(SourceItemCatalog.materialByID["129001"] == SourceMaterialEntry(id: "129001", name: "Chaso Dice", rarity: .cosmic, category: .engraving))
        #expect(SourceItemCatalog.materialByID["190004"] == SourceMaterialEntry(id: "190004", name: "Soulstone - Torment", rarity: .celestial, category: .soulStone))
        #expect(SourceItemCatalog.materialByID["110001"]?.iconName == "source_material_110001")
        #expect(GameArt.soulStoneIconName(for: .normal) == "source_material_190001")
        #expect(GameArt.soulStoneIconName(for: .torment) == "source_material_190004")
        #expect(SoulStoneKind.allCases.allSatisfy { SourceItemCatalog.materialByID[String($0.materialID)]?.rarity == $0.rarity })

        #expect(SourceItemCatalog.allStageChests.count == SourceItemCatalog.expectedStageChestCount)
        #expect(SourceItemCatalog.expectedStageChestCount == 59)
        #expect(SourceItemCatalog.duplicateStageChestIDs.isEmpty)
        #expect(SourceItemCatalog.stageChestCountsByRarity[.common] == 19)
        #expect(SourceItemCatalog.stageChestCountsByRarity[.rare] == 29)
        #expect(SourceItemCatalog.stageChestCountsByRarity[.legendary] == 11)
        #expect(Set(SourceItemCatalog.allStageChests.map(\.iconName)) == ["source_stage_chest_910011", "source_stage_chest_920011", "source_stage_chest_930011"])
        #expect(SourceItemCatalog.stageChestByID["920022"] == SourceStageChestEntry(id: "920022", name: "Stage Boss Box 6", rarity: .rare))
        #expect(SourceItemCatalog.stageChestByID["930901"] == SourceStageChestEntry(id: "930901", name: "Act Boss Box Lv90", rarity: .legendary))
        #expect(SourceItemCatalog.stageChestByID["920022"]?.iconName == "source_stage_chest_920011")
        #expect(GameArt.chestIconName(for: LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .normalMonster)) == "source_stage_chest_910011")
        #expect(GameArt.chestIconName(for: LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .stageBoss)) == "source_stage_chest_920011")
        #expect(GameArt.chestIconName(for: LootChest(kind: .normal, itemLevel: 30, sourceStageCode: "3-10", sourceDifficulty: .normal, family: .actBoss, catalogLevel: 30)) == "source_stage_chest_930011")
        #expect(SourceItemCatalog.allStageChests.allSatisfy { ChestCatalog.contains(databaseID: Int($0.id) ?? -1) })
        #expect(ChestCatalog.entryCount == SourceItemCatalog.expectedStageChestCount)
    }

    @Test func addItem() {
        let inventory = Inventory()
        let item = Item(id: "test1", name: "测试剑", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 5), description: "测试")
        inventory.add(item)
        #expect(inventory.items.count == 1)
    }

    @Test func removeItem() {
        let inventory = Inventory()
        let item = Item(id: "test2", name: "测试甲", rarity: .common, slot: .armor, stats: ItemStats(bonusDEF: 3), description: "测试")
        inventory.add(item)
        inventory.remove(item)
        #expect(inventory.items.isEmpty)
    }

    @Test func lockedItemCannotBeDiscarded() {
        let inventory = Inventory()
        let item = Item(id: "lock1", name: "保留剑", rarity: .arcana, slot: .weapon, stats: ItemStats(bonusATK: 12), description: "")
        inventory.add(item)

        let locked = try #require(inventory.toggleLock(item))

        #expect(locked.isLocked)
        #expect(!inventory.discard(locked))
        #expect(inventory.items.count == 1)

        let unlocked = try #require(inventory.toggleLock(locked))
        #expect(!unlocked.isLocked)
        #expect(inventory.discard(unlocked))
        #expect(inventory.items.isEmpty)
    }

    @Test func lockStatePersistsThroughCodable() throws {
        let item = Item(id: "lock2", name: "锁定戒指", rarity: .celestial, slot: .accessory, stats: ItemStats(bonusHP: 30), description: "", isLocked: true)
        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(Item.self, from: data)

        #expect(decoded.id == item.id)
        #expect(decoded.slot == .ring)
        #expect(decoded.equipmentType == .ring)
        #expect(decoded.isLocked)
    }

    @Test func legacyItemDecodesAsUnlocked() throws {
        let json = #"{"id":"old","name":"旧剑","rarity":"普通","slot":"武器","stats":{"bonusHP":0,"bonusATK":1,"bonusDEF":0,"bonusSPD":0,"bonusCritRate":0,"bonusCritDamage":0},"description":"legacy"}"#
        let item = try JSONDecoder().decode(Item.self, from: Data(json.utf8))

        #expect(!item.isLocked)
    }

    @Test func legacyAccessoryDecodesToRingEquipmentType() throws {
        let json = #"{"id":"old-ring","name":"旧饰品","rarity":"普通","slot":"饰品","stats":{"bonusHP":0,"bonusATK":1,"bonusDEF":0,"bonusSPD":0,"bonusCritRate":0,"bonusCritDamage":0},"description":"legacy"}"#
        let item = try JSONDecoder().decode(Item.self, from: Data(json.utf8))

        #expect(item.slot == .ring)
        #expect(item.equipmentType == .ring)
        #expect(!item.isLocked)
    }

    @Test func equipItem() {
        var loadout = EquipmentLoadout()
        let sword = Item(id: "sword1", name: "铁剑", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 10), description: "测试")
        let old = loadout.equip(sword)
        #expect(old == nil, "First equip should return nil")
        #expect(loadout.weapon?.id == "sword1")
    }

    @Test func swapEquipment() {
        var loadout = EquipmentLoadout()
        let sword1 = Item(id: "sword1", name: "铁剑", rarity: .common, slot: .weapon, stats: ItemStats(bonusATK: 10), description: "测试")
        let sword2 = Item(id: "sword2", name: "钢剑", rarity: .rare, slot: .weapon, stats: ItemStats(bonusATK: 20), description: "测试")
        _ = loadout.equip(sword1)
        let old = loadout.equip(sword2)
        #expect(old?.id == "sword1", "Should return previously equipped item")
        #expect(loadout.weapon?.id == "sword2")
    }

    @Test func expandedLoadoutEquipsNewSlotsAndTotalsStats() {
        var loadout = EquipmentLoadout()
        let shield = Item(id: "shield", name: "木盾", rarity: .common, slot: .offhand, stats: ItemStats(bonusDEF: 3), description: "", equipmentType: .shield)
        let gloves = Item(id: "gloves", name: "布手套", rarity: .common, slot: .gloves, stats: ItemStats(bonusATK: 2), description: "", equipmentType: .gloves)
        let ring = Item(id: "ring", name: "铜戒指", rarity: .common, slot: .ring, stats: ItemStats(bonusHP: 7), description: "", equipmentType: .ring)

        #expect(loadout.equip(shield) == nil)
        #expect(loadout.equip(gloves) == nil)
        #expect(loadout.equip(ring) == nil)
        #expect(loadout.offhand?.id == "shield")
        #expect(loadout.gloves?.id == "gloves")
        #expect(loadout.ring?.id == "ring")
        #expect(loadout.bonusDEF == 3)
        #expect(loadout.bonusATK == 2)
        #expect(loadout.bonusHP == 7)
    }

    @Test func lootGenerationPreservesConcreteEquipmentType() {
        let item = LootTable.makeItem(type: .scepter, rarity: .rare, itemLevel: 12)

        #expect(item.equipmentType == .scepter)
        #expect(item.slot == .weapon)
        #expect(item.itemLevel == 12)
        #expect(item.description.contains("Scepter"))
        #expect(GameArt.itemIconName(for: item) == GameArt.itemIconName(for: EquipmentType.scepter))
    }
}
