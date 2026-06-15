import Foundation
import CoreGraphics

/// Central mapping between game models and bundled pixel art.
enum GameArt {
    static let appIconName = "app_icon"

    static func heroSpriteName(for heroClass: HeroClass) -> String {
        switch heroClass {
        case .knight:
            return "official_hero_knight"
        case .ranger:
            return "official_hero_ranger"
        case .sorcerer:
            return "official_hero_sorcerer"
        case .priest:
            return "official_hero_priest"
        case .hunter:
            return "official_hero_hunter"
        case .slayer:
            return "official_hero_slayer"
        }
    }

    static func battleHeroSpriteName(for heroClass: HeroClass) -> String {
        switch heroClass {
        case .knight:
            return "battle_hero_knight"
        case .ranger:
            return "battle_hero_ranger"
        case .sorcerer:
            return "battle_hero_sorcerer"
        case .priest:
            return "battle_hero_priest"
        case .hunter:
            return "battle_hero_hunter"
        case .slayer:
            return "battle_hero_slayer"
        }
    }

    static func battleHeroPixelSize(for heroClass: HeroClass) -> CGSize {
        CGSize(width: 30, height: 44)
    }

    static func battleHeroDisplaySize(for heroClass: HeroClass, scale: CGFloat) -> CGSize {
        let pixelSize = battleHeroPixelSize(for: heroClass)
        return CGSize(
            width: pixelSize.width * scale,
            height: pixelSize.height * scale
        )
    }

    static func monsterSpriteName(for monsterID: String) -> String {
        switch monsterID {
        case "assassin_goblin":
            return "stage_monster_assassin_goblin"
        case "shaman_goblin":
            return "stage_monster_shaman_goblin"
        case "basic_orc":
            return "stage_monster_basic_orc"
        case "armored_orc":
            return "stage_monster_armored_orc"
        case "elite_orc":
            return "stage_monster_elite_orc"
        case "stage_skeleton":
            return "stage_monster_skeleton"
        case "armored_skeleton":
            return "stage_monster_armored_skeleton"
        case "skeleton_archer":
            return "stage_monster_skeleton_archer"
        case "skeleton_king":
            return "stage_monster_skeleton_king"
        case "berserker_rat":
            return "stage_monster_berserker_rat"
        case "warrior_rat":
            return "stage_monster_warrior_rat"
        case "cobra":
            return "stage_monster_cobra"
        case "poison_insect":
            return "stage_monster_poison_insect"
        case "homunculus":
            return "stage_monster_homunculus"
        case "stage_ghoul":
            return "stage_monster_ghoul"
        case "zombie_rat":
            return "stage_monster_zombie_rat"
        case "spear_kobolt":
            return "stage_monster_spear_kobolt"
        case "small_mummy":
            return "stage_monster_small_mummy"
        case "sibuna":
            return "stage_monster_sibuna"
        case "voidcaller":
            return "stage_monster_voidcaller"
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

    static func battleMonsterSpriteName(for monsterID: String) -> String {
        if monsterID == "boss_1-10" {
            return "stage_monster_skeleton_king"
        }
        if monsterID == "boss_2-10" {
            return "stage_monster_sibuna"
        }
        if monsterID == "boss_3-10" || monsterID.hasPrefix("boss_") {
            return "stage_monster_voidcaller"
        }

        switch monsterID {
        case "slime_green", "slime_blue":
            return "monster_slime_red"
        default:
            return monsterSpriteName(for: monsterID)
        }
    }

    static func itemIconName(for item: Item) -> String {
        if let equipmentType = item.equipmentType {
            return itemIconName(for: equipmentType)
        }

        switch item.rarity {
        case .common:
            return "official_item_material"
        case .uncommon, .rare:
            return "official_item_gem"
        case .legendary, .immortal, .arcana, .beyond, .celestial, .divine, .cosmic:
            return "official_item_box"
        }
    }

    static func itemIconName(for material: SourceMaterialEntry) -> String {
        material.iconName
    }

    static func soulStoneIconName(for kind: SoulStoneKind) -> String {
        SourceItemCatalog.materialByID[String(kind.materialID)]?.iconName ?? "official_item_material"
    }

    static func stageChestIconName(for entry: SourceStageChestEntry) -> String {
        entry.iconName
    }

    static func chestIconName(for chest: LootChest) -> String {
        SourceItemCatalog.stageChestByID[String(chest.databaseID)]?.iconName ?? "official_item_box"
    }

    static func itemIconName(for equipmentType: EquipmentType) -> String {
        switch equipmentType {
        case .sword:
            return "item_2_0"
        case .bow:
            return "item_2_1"
        case .staff:
            return "item_3_4"
        case .scepter:
            return "item_2_2"
        case .crossbow:
            return "item_3_1"
        case .axe:
            return "item_2_2"
        case .shield:
            return "item_1_4"
        case .arrow:
            return "item_3_1"
        case .orb:
            return "item_3_2"
        case .tome:
            return "item_2_4"
        case .bolt:
            return "item_3_1"
        case .hatchet:
            return "item_3_4"
        case .helmet:
            return "item_3_3"
        case .armor:
            return "item_2_3"
        case .gloves:
            return "item_1_0"
        case .boots:
            return "item_1_1"
        case .amulet:
            return "item_0_4"
        case .earring:
            return "item_0_0"
        case .ring:
            return "item_0_3"
        case .bracer:
            return "item_0_1"
        }
    }

    static func itemIconName(for slot: EquipSlot) -> String {
        switch slot {
        case .weapon:
            return "official_item_weapon"
        case .offhand:
            return "official_item_accessory"
        case .armor, .gloves:
            return "official_item_armor"
        case .helmet:
            return "official_item_helmet"
        case .boots:
            return "official_item_boots"
        case .amulet, .earring, .ring, .bracer, .accessory:
            return "official_item_accessory"
        }
    }

    static func skillIconName(for skill: Skill) -> String {
        switch skill.delivery {
        case .heal, .resurrection:
            return "skill_0_3"
        case .buff:
            return skill.id == "50301" ? "skill_1_3" : "skill_2_3"
        case .trap:
            return "skill_1_0"
        case .summonProjectile:
            return skill.damageElement == .fire ? "skill_0_2" : "skill_1_0"
        case .projectile, .projectileAOE:
            return elementalSkillIconName(for: skill.damageElement, fallback: "skill_1_1")
        case .range, .rangeAOE:
            return elementalSkillIconName(for: skill.damageElement, fallback: "skill_0_1")
        case .melee:
            return "skill_1_2"
        case .meleeAOE:
            return "skill_0_0"
        case .none:
            return elementalSkillIconName(for: skill.damageElement, fallback: "skill_0_0")
        }
    }

    static var skillIconNames: [String] {
        [
            "skill_0_0",
            "skill_0_1",
            "skill_0_2",
            "skill_0_3",
            "skill_1_0",
            "skill_1_1",
            "skill_1_2",
            "skill_1_3",
            "skill_2_0",
            "skill_2_1",
            "skill_2_2",
            "skill_2_3"
        ]
    }

    static func runeTreeIconName(for node: RuneTreeNode) -> String {
        switch node {
        case .partySlot2, .partySlot3:
            return "rune_party_slot"
        case .activeSkillSlot2:
            return "rune_active_skill_slot"
        case .inventoryExpansion1:
            return "rune_inventory_capacity"
        case .offlineRewards:
            return "rune_offline_rewards"
        case .offlineGoldBoost:
            return "rune_offline_gold"
        case .offlineXPBoost:
            return "rune_offline_xp"
        }
    }

    static var runeTreeIconNames: [String] {
        [
            "rune_party_slot",
            "rune_active_skill_slot",
            "rune_inventory_capacity",
            "rune_offline_rewards",
            "rune_offline_gold",
            "rune_offline_xp"
        ]
    }

    private static func elementalSkillIconName(
        for element: SkillDamageElement,
        fallback: String
    ) -> String {
        switch element {
        case .fire:
            return "skill_0_2"
        case .cold:
            return "skill_2_1"
        case .lightning:
            return "skill_2_2"
        case .physical:
            return fallback
        case .none:
            return fallback
        }
    }
}
