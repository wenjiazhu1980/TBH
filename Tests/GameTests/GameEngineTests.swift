import Testing
import Foundation
@testable import TBH

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
    }
}

@Suite struct GameEngineEquipTests {
    private func makeEngine() -> GameEngine {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-\(UUID().uuidString)", isDirectory: true)
        return GameEngine(saveManager: SaveManager(directory: tempDir))
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

    @Test func resetGameClearsState() {
        let engine = makeEngine()
        engine.hero.gainGold(999)
        engine.hero.gainXP(engine.hero.xpForNextLevel())
        engine.inventory.add(Item(id: "x", name: "x", rarity: .common, slot: nil, stats: ItemStats(), description: ""))
        engine.save()

        engine.resetGame()
        #expect(engine.hero.level == 1)
        #expect(engine.hero.gold == 0)
        #expect(engine.inventory.items.isEmpty)
        #expect(engine.progress.killsInChapter == 0)
        #expect(engine.statistics.monstersKilled == 0)
    }
}

@Suite struct SaveManagerTests {
    @Test func saveAndLoadRoundTrip() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("TBHTests-\(UUID().uuidString)", isDirectory: true)
        let manager = SaveManager(directory: tempDir)

        let hero = Hero()
        hero.gainGold(123)
        let data = SaveData(
            hero: hero,
            inventory: Inventory(),
            progress: ProgressTracker(),
            statistics: GameStatistics(),
            timestamp: Date()
        )
        manager.save(data)

        let loaded = try #require(manager.load())
        #expect(loaded.hero.gold == 123)
    }
}
