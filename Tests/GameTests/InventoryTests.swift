import Testing
@testable import TBH

@Suite struct InventoryTests {
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
}
