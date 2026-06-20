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
            return "official_monster_slime"
        default:
            return monsterSpriteName(for: monsterID)
        }
    }

    static func itemIconName(for item: Item) -> String {
        if let progression = item.sourceGearProgression {
            return progression.iconName
        }

        if let equipmentType = item.equipmentType {
            return SourceItemCatalog.progression(
                for: equipmentType,
                itemLevel: item.itemLevel
            )?.iconName ?? itemIconName(for: equipmentType)
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
            return "item_0_0"
        case .bow:
            return "item_0_1"
        case .staff:
            return "item_0_2"
        case .scepter:
            return "item_0_3"
        case .crossbow:
            return "item_0_4"
        case .axe:
            return "item_1_0"
        case .shield:
            return "item_1_1"
        case .arrow:
            return "item_1_2"
        case .orb:
            return "item_1_3"
        case .tome:
            return "item_1_4"
        case .bolt:
            return "item_2_0"
        case .hatchet:
            return "item_2_1"
        case .helmet:
            return "item_2_2"
        case .armor:
            return "item_2_3"
        case .gloves:
            return "item_2_4"
        case .boots:
            return "item_3_0"
        case .amulet:
            return "item_3_1"
        case .earring:
            return "item_3_2"
        case .ring:
            return "item_3_3"
        case .bracer:
            return "item_3_4"
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

    static func passiveSkillIconName(for passiveSkill: PassiveSkill) -> String? {
        passiveSkillIconName(forStat: passiveSkill.stat)
    }

    static func passiveSkillIconName(forStat stat: String) -> String? {
        switch stat {
        case "AddHpPerHit":
            return "source_passive_AddHpPerHit"
        case "AddHpPerKill":
            return "source_passive_AddHpPerKill"
        case "AllElementalResistance":
            return "source_passive_AllElementalResistance"
        case "AreaOfEffect":
            return "source_passive_AreaOfEffect"
        case "Armor":
            return "source_passive_Armor"
        case "AttackDamage":
            return "source_passive_AttackDamage"
        case "AttackSpeed":
            return "source_passive_AttackSpeed"
        case "BlockChance":
            return "source_passive_BlockChance"
        case "CastSpeed":
            return "source_passive_CastSpeed"
        case "ColdDamagePercent":
            return "source_passive_ColdDamagePercent"
        case "CooldownReduction":
            return "source_passive_CooldownReduction"
        case "CriticalChance":
            return "source_passive_CriticalChance"
        case "CriticalDamage":
            return "source_passive_CriticalDamage"
        case "DamageAbsorption":
            return "source_passive_DamageAbsorption"
        case "DamageReduction":
            return "source_passive_DamageReduction"
        case "DodgeChance", "ElementalDodgeChance":
            return "source_passive_DodgeChance"
        case "FireDamagePercent":
            return "source_passive_FireDamagePercent"
        case "HpLeech":
            return "source_passive_HpLeech"
        case "HpRegenPerSec":
            return "source_passive_HpRegenPerSec"
        case "IncreaseAreaOfEffectDamage":
            return "source_passive_AreaOfEffectDamage"
        case "LightningDamagePercent":
            return "source_passive_LightningDamagePercent"
        case "MaxDodgeChance":
            return "source_passive_MaxDodgeChance"
        case "MaxHp":
            return "source_passive_MaxHp"
        case "MovementSpeed":
            return "source_passive_MovementSpeed"
        case "PhysicalDamagePercent":
            return "source_passive_PhysicalDamagePercent"
        case "SkillDurationIncrease":
            return "source_passive_Duration"
        case "SkillRangeExpansion":
            return "source_passive_SkillRangeExpansion"
        default:
            return nil
        }
    }

    static var passiveSkillIconNames: [String] {
        [
            "source_passive_AddHpPerHit",
            "source_passive_AddHpPerKill",
            "source_passive_AllElementalResistance",
            "source_passive_AreaOfEffect",
            "source_passive_AreaOfEffectDamage",
            "source_passive_Armor",
            "source_passive_AttackDamage",
            "source_passive_AttackSpeed",
            "source_passive_BlockChance",
            "source_passive_CastSpeed",
            "source_passive_ColdDamagePercent",
            "source_passive_CooldownReduction",
            "source_passive_CriticalChance",
            "source_passive_CriticalDamage",
            "source_passive_DamageAbsorption",
            "source_passive_DamageReduction",
            "source_passive_DodgeChance",
            "source_passive_Duration",
            "source_passive_FireDamagePercent",
            "source_passive_HpLeech",
            "source_passive_HpRegenPerSec",
            "source_passive_LightningDamagePercent",
            "source_passive_MaxDodgeChance",
            "source_passive_MaxHp",
            "source_passive_MovementSpeed",
            "source_passive_PhysicalDamagePercent",
            "source_passive_SkillRangeExpansion"
        ]
    }

    static func runeTreeIconName(for node: RuneTreeNode) -> String {
        guard let sourceNode = SourceRuneCatalog.byID[node.sourceRuneID] else {
            return "source_rune_UnlockArrangeSlotCount"
        }
        return sourceRuneIconName(for: sourceNode)
    }

    static func sourceRuneIconName(for sourceNode: SourceRuneNode) -> String {
        sourceRuneIconName(forIconFamily: sourceNode.iconName)
    }

    static func sourceRuneIconName(forIconFamily iconName: String) -> String {
        "source_rune_\(iconName)"
    }

    static var runeTreeIconNames: [String] {
        SourceRuneCatalog.iconNames
            .sorted()
            .map { sourceRuneIconName(forIconFamily: $0) }
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
        case .chaos:
            return fallback
        case .physical:
            return fallback
        case .none:
            return fallback
        }
    }
}
