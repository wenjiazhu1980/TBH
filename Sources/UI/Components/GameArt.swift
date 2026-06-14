import Foundation

/// Central mapping between game models and bundled pixel art.
enum GameArt {
    static let appIconName = "app_icon"

    static func heroSpriteName(for heroClass: HeroClass) -> String {
        switch heroClass {
        case .warrior:
            return "official_hero_knight"
        }
    }

    static func monsterSpriteName(for monsterID: String) -> String {
        switch monsterID {
        case "slime_green", "slime_blue":
            return "official_monster_slime"
        case "goblin":
            return "official_monster_goblin"
        case "skeleton":
            return "official_monster_skeleton"
        case "bat":
            return "official_monster_bat"
        case "zombie":
            return "official_monster_ghoul"
        case "spider":
            return "official_monster_insect"
        case "golem", "wolf":
            return "official_monster_golem"
        case "dragon_whelp":
            return "official_monster_dragon"
        default:
            return "official_monster_slime"
        }
    }

    static func itemIconName(for item: Item) -> String {
        if let slot = item.slot {
            return itemIconName(for: slot)
        }

        switch item.rarity {
        case .common:
            return "official_item_material"
        case .uncommon, .rare:
            return "official_item_gem"
        case .legendary:
            return "official_item_box"
        }
    }

    static func itemIconName(for slot: EquipSlot) -> String {
        switch slot {
        case .weapon:
            return "official_item_weapon"
        case .armor:
            return "official_item_armor"
        case .helmet:
            return "official_item_helmet"
        case .boots:
            return "official_item_boots"
        case .accessory:
            return "official_item_accessory"
        }
    }
}
