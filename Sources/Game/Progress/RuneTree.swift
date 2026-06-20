import Foundation

enum RuneTreeNode: String, CaseIterable, Codable, Identifiable {
    case allHeroAttackDamage1
    case allHeroArmor1
    case allHeroMoveSpeed1
    case allHeroAttackDamagePercent1
    case allHeroMoveSpeed5
    case allHeroArmorPercent1
    case allHeroAttackDamagePercent2
    case allHeroAttackSpeed1
    case allHeroAttackSpeed2
    case allHeroArmor3
    case allHeroAttackDamage4
    case allHeroMoveSpeed4
    case allHeroArmor2
    case allHeroAttackDamage2
    case allHeroAttackDamage3
    case allHeroMoveSpeed2
    case allHeroMoveSpeed3
    case allHeroArmorPercent2
    case allHeroAttackDamagePercent3
    case allHeroAttackSpeed3
    case partySlot2
    case partySlot3
    case activeSkillSlot2
    case combatGoldBoost1
    case combatGoldBoost2
    case combatGoldBoost3
    case combatGoldBoost4
    case combatGoldBoost5
    case combatGoldBoost6
    case combatGoldBoost7
    case combatXPBoost1
    case combatXPBoost2
    case combatXPBoost3
    case combatXPBoost4
    case combatXPBoost5
    case combatXPBoost6
    case combatXPBoost7
    case additionalGold1
    case additionalGold2
    case additionalGoldNormalMonster1
    case additionalGoldNormalMonster2
    case additionalGoldNormalMonster3
    case additionalGoldStageBoss1
    case additionalGoldStageBoss2
    case additionalGoldStageBoss3
    case additionalGoldStageBoss4
    case additionalGoldStageBoss5
    case additionalGoldStageBoss6
    case additionalGoldStageBoss7
    case additionalGoldActBoss1
    case additionalGoldActBoss2
    case additionalGoldActBoss3
    case additionalXP1
    case additionalXP2
    case additionalXPNormalMonster1
    case additionalXPNormalMonster2
    case additionalXPStageBoss1
    case additionalXPStageBoss2
    case additionalXPStageBoss3
    case additionalXPStageBoss4
    case additionalXPStageBoss5
    case additionalXPStageBoss6
    case additionalXPStageBoss7
    case additionalXPActBoss1
    case additionalXPActBoss2
    case additionalXPActBoss3
    case cubeXPBoost1
    case cubeXPBoost2
    case cubeXPBoost3
    case cubeXPBoost4
    case alchemyGoldBoost1
    case alchemyGoldBoost2
    case alchemyGoldBoost3
    case alchemyGoldBoost4
    case inventoryExpansion1
    case inventoryExpansion2
    case inventoryExpansion3
    case inventoryExpansion4
    case inventoryExpansion5
    case inventoryExpansion6
    case inventoryExpansion7
    case inventoryExpansion8
    case inventoryExpansion9
    case inventoryExpansion10
    case inventoryExpansion11
    case inventoryExpansion12
    case inventoryExpansion13
    case inventoryExpansion14
    case inventoryExpansion15
    case inventoryExpansion16
    case inventoryExpansion17
    case inventoryExpansion18
    case inventoryExpansion19
    case inventoryExpansion20
    case inventoryExpansion21
    case inventoryExpansion22
    case inventoryExpansion23
    case inventoryExpansion24
    case inventoryExpansion25
    case inventoryExpansion26
    case normalChestDropChance1
    case normalChestDropChance2
    case normalChestDropChance3
    case normalChestDropChance4
    case normalChestDropChance5
    case normalChestDropChance6
    case normalChestDropChance7
    case normalChestDropChance8
    case normalChestDropChance9
    case normalChestDropChance10
    case normalChestDropChance11
    case normalChestDropChance12
    case normalChestDropChance13
    case normalChestDropChance14
    case normalChestDropChance15
    case stageBossChestDropChance1
    case stageBossChestDropChance2
    case stageBossChestDropChance3
    case stageBossChestDropChance4
    case stageBossChestDropChance5
    case stageBossChestDropChance6
    case stageBossChestDropChance7
    case stageBossChestDropChance8
    case stageBossChestDropChance9
    case stageBossChestDropChance10
    case stageBossChestDropChance11
    case stageBossChestDropChance12
    case stageBossChestDropChance13
    case stageBossChestDropChance14
    case openOneChestType
    case openAllChestTypes
    case autoOpenNormalChests
    case autoOpenStageBossChests
    case autoOpenActBossChests
    case normalChestAutoOpenSpeed1
    case normalChestAutoOpenSpeed2
    case normalChestAutoOpenSpeed3
    case normalChestAutoOpenSpeed4
    case stageBossChestAutoOpenSpeed1
    case stageBossChestAutoOpenSpeed2
    case stageBossChestAutoOpenSpeed3
    case stageBossChestAutoOpenSpeed4
    case actBossChestAutoOpenSpeed1
    case actBossChestAutoOpenSpeed2
    case maxNormalChestStorage
    case maxNormalChestStorage2
    case maxNormalChestStorage3
    case maxNormalChestStorage4
    case maxNormalChestStorage5
    case maxNormalChestStorage6
    case maxNormalChestStorage7
    case maxNormalChestStorage8
    case maxNormalChestStorage9
    case maxNormalChestStorage10
    case maxNormalChestStorage11
    case maxNormalChestStorage12
    case maxNormalChestStorage13
    case maxNormalChestStorage14
    case maxNormalChestStorage15
    case maxStageBossChestStorage
    case maxStageBossChestStorage2
    case maxStageBossChestStorage3
    case maxStageBossChestStorage4
    case maxStageBossChestStorage5
    case maxStageBossChestStorage6
    case maxStageBossChestStorage7
    case maxStageBossChestStorage8
    case maxStageBossChestStorage9
    case maxStageBossChestStorage10
    case maxStageBossChestStorage11
    case maxStageBossChestStorage12
    case maxStageBossChestStorage13
    case maxActBossChestStorage
    case maxActBossChestStorage2
    case maxActBossChestStorage3
    case maxActBossChestStorage4
    case maxActBossChestStorage5
    case maxActBossChestStorage6
    case maxActBossChestStorage7
    case maxActBossChestStorage8
    case maxActBossChestStorage9
    case maxActBossChestStorage10
    case offlineRewards
    case offlineGoldBoost
    case offlineGoldBoost2
    case offlineGoldBoost3
    case offlineGoldBoost4
    case offlineGoldBoost5
    case offlineXPBoost
    case offlineXPBoost2
    case offlineXPBoost3
    case offlineXPBoost4
    case offlineXPBoost5
    case stashPage1
    case stashPage2
    case stashPage3
    case waveCountReduction1

    var id: String { rawValue }

    var sourceRuneID: String {
        switch self {
        case .allHeroAttackDamage1: return "1"
        case .allHeroArmor1: return "401"
        case .allHeroMoveSpeed1: return "402"
        case .allHeroAttackDamagePercent1: return "405"
        case .allHeroMoveSpeed5: return "406"
        case .allHeroArmorPercent1: return "407"
        case .allHeroAttackDamagePercent2: return "408"
        case .allHeroAttackSpeed1: return "4061"
        case .allHeroAttackSpeed2: return "409"
        case .allHeroArmor3: return "403"
        case .allHeroAttackDamage4: return "4031"
        case .allHeroMoveSpeed4: return "404"
        case .allHeroArmor2: return "410"
        case .allHeroAttackDamage2: return "411"
        case .allHeroAttackDamage3: return "4081"
        case .allHeroMoveSpeed2: return "4082"
        case .allHeroMoveSpeed3: return "4101"
        case .allHeroArmorPercent2: return "412"
        case .allHeroAttackDamagePercent3: return "413"
        case .allHeroAttackSpeed3: return "414"
        case .partySlot2: return "21"
        case .partySlot3: return "24"
        case .activeSkillSlot2: return "27"
        case .combatGoldBoost1: return "25"
        case .combatGoldBoost2: return "202"
        case .combatGoldBoost3: return "206"
        case .combatGoldBoost4: return "208"
        case .combatGoldBoost5: return "210"
        case .combatGoldBoost6: return "212"
        case .combatGoldBoost7: return "214"
        case .combatXPBoost1: return "26"
        case .combatXPBoost2: return "302"
        case .combatXPBoost3: return "306"
        case .combatXPBoost4: return "308"
        case .combatXPBoost5: return "310"
        case .combatXPBoost6: return "312"
        case .combatXPBoost7: return "314"
        case .additionalGold1: return "201"
        case .additionalGold2: return "2111"
        case .additionalGoldNormalMonster1: return "204"
        case .additionalGoldNormalMonster2: return "2071"
        case .additionalGoldNormalMonster3: return "2151"
        case .additionalGoldStageBoss1: return "10"
        case .additionalGoldStageBoss2: return "203"
        case .additionalGoldStageBoss3: return "207"
        case .additionalGoldStageBoss4: return "209"
        case .additionalGoldStageBoss5: return "211"
        case .additionalGoldStageBoss6: return "213"
        case .additionalGoldStageBoss7: return "215"
        case .additionalGoldActBoss1: return "205"
        case .additionalGoldActBoss2: return "2091"
        case .additionalGoldActBoss3: return "2152"
        case .additionalXP1: return "301"
        case .additionalXP2: return "3151"
        case .additionalXPNormalMonster1: return "304"
        case .additionalXPNormalMonster2: return "3091"
        case .additionalXPStageBoss1: return "20"
        case .additionalXPStageBoss2: return "303"
        case .additionalXPStageBoss3: return "307"
        case .additionalXPStageBoss4: return "309"
        case .additionalXPStageBoss5: return "311"
        case .additionalXPStageBoss6: return "313"
        case .additionalXPStageBoss7: return "315"
        case .additionalXPActBoss1: return "305"
        case .additionalXPActBoss2: return "3061"
        case .additionalXPActBoss3: return "3152"
        case .cubeXPBoost1: return "3031"
        case .cubeXPBoost2: return "2032"
        case .cubeXPBoost3: return "2132"
        case .cubeXPBoost4: return "3121"
        case .alchemyGoldBoost1: return "3032"
        case .alchemyGoldBoost2: return "2031"
        case .alchemyGoldBoost3: return "2131"
        case .alchemyGoldBoost4: return "3122"
        case .inventoryExpansion1: return "22"
        case .inventoryExpansion2: return "23"
        case .inventoryExpansion3: return "11"
        case .inventoryExpansion4: return "12"
        case .inventoryExpansion5: return "13"
        case .inventoryExpansion6: return "14"
        case .inventoryExpansion7: return "15"
        case .inventoryExpansion8: return "16"
        case .inventoryExpansion9: return "1051"
        case .inventoryExpansion10: return "1054"
        case .inventoryExpansion11: return "1801"
        case .inventoryExpansion12: return "1802"
        case .inventoryExpansion13: return "1803"
        case .inventoryExpansion14: return "1804"
        case .inventoryExpansion15: return "1805"
        case .inventoryExpansion16: return "1806"
        case .inventoryExpansion17: return "1807"
        case .inventoryExpansion18: return "1808"
        case .inventoryExpansion19: return "1901"
        case .inventoryExpansion20: return "1902"
        case .inventoryExpansion21: return "1903"
        case .inventoryExpansion22: return "1904"
        case .inventoryExpansion23: return "1905"
        case .inventoryExpansion24: return "1906"
        case .inventoryExpansion25: return "1907"
        case .inventoryExpansion26: return "1908"
        case .normalChestDropChance1: return "101"
        case .normalChestDropChance2: return "103"
        case .normalChestDropChance3: return "105"
        case .normalChestDropChance4: return "107"
        case .normalChestDropChance5: return "109"
        case .normalChestDropChance6: return "111"
        case .normalChestDropChance7: return "113"
        case .normalChestDropChance8: return "115"
        case .normalChestDropChance9: return "117"
        case .normalChestDropChance10: return "119"
        case .normalChestDropChance11: return "121"
        case .normalChestDropChance12: return "123"
        case .normalChestDropChance13: return "125"
        case .normalChestDropChance14: return "127"
        case .normalChestDropChance15: return "1053"
        case .stageBossChestDropChance1: return "102"
        case .stageBossChestDropChance2: return "104"
        case .stageBossChestDropChance3: return "106"
        case .stageBossChestDropChance4: return "108"
        case .stageBossChestDropChance5: return "110"
        case .stageBossChestDropChance6: return "112"
        case .stageBossChestDropChance7: return "114"
        case .stageBossChestDropChance8: return "116"
        case .stageBossChestDropChance9: return "118"
        case .stageBossChestDropChance10: return "120"
        case .stageBossChestDropChance11: return "122"
        case .stageBossChestDropChance12: return "124"
        case .stageBossChestDropChance13: return "126"
        case .stageBossChestDropChance14: return "128"
        case .openOneChestType: return "1021"
        case .openAllChestTypes: return "1055"
        case .autoOpenNormalChests: return "13002"
        case .autoOpenStageBossChests: return "15001"
        case .autoOpenActBossChests: return "1902001"
        case .normalChestAutoOpenSpeed1: return "130021"
        case .normalChestAutoOpenSpeed2: return "190301"
        case .normalChestAutoOpenSpeed3: return "190501"
        case .normalChestAutoOpenSpeed4: return "1905011"
        case .stageBossChestAutoOpenSpeed1: return "150011"
        case .stageBossChestAutoOpenSpeed2: return "190302"
        case .stageBossChestAutoOpenSpeed3: return "190502"
        case .stageBossChestAutoOpenSpeed4: return "1905021"
        case .actBossChestAutoOpenSpeed1: return "190401"
        case .actBossChestAutoOpenSpeed2: return "19020011"
        case .maxNormalChestStorage: return "1031"
        case .maxNormalChestStorage2: return "1052"
        case .maxNormalChestStorage3: return "1061"
        case .maxNormalChestStorage4: return "1072"
        case .maxNormalChestStorage5: return "1091"
        case .maxNormalChestStorage6: return "1101"
        case .maxNormalChestStorage7: return "1121"
        case .maxNormalChestStorage8: return "1131"
        case .maxNormalChestStorage9: return "1142"
        case .maxNormalChestStorage10: return "1161"
        case .maxNormalChestStorage11: return "1191"
        case .maxNormalChestStorage12: return "1201"
        case .maxNormalChestStorage13: return "1241"
        case .maxNormalChestStorage14: return "11002"
        case .maxNormalChestStorage15: return "11611"
        case .maxStageBossChestStorage: return "1071"
        case .maxStageBossChestStorage2: return "1102"
        case .maxStageBossChestStorage3: return "11003"
        case .maxStageBossChestStorage4: return "1111"
        case .maxStageBossChestStorage5: return "1132"
        case .maxStageBossChestStorage6: return "1141"
        case .maxStageBossChestStorage7: return "1172"
        case .maxStageBossChestStorage8: return "1181"
        case .maxStageBossChestStorage9: return "1202"
        case .maxStageBossChestStorage10: return "1221"
        case .maxStageBossChestStorage11: return "1251"
        case .maxStageBossChestStorage12: return "1261"
        case .maxStageBossChestStorage13: return "1281"
        case .maxActBossChestStorage: return "1056"
        case .maxActBossChestStorage2: return "1133"
        case .maxActBossChestStorage3: return "1182"
        case .maxActBossChestStorage4: return "1203"
        case .maxActBossChestStorage5: return "1222"
        case .maxActBossChestStorage6: return "1252"
        case .maxActBossChestStorage7: return "1262"
        case .maxActBossChestStorage8: return "1282"
        case .maxActBossChestStorage9: return "11004"
        case .maxActBossChestStorage10: return "12821"
        case .offlineRewards: return "11001"
        case .offlineGoldBoost: return "110011"
        case .offlineGoldBoost2: return "15002"
        case .offlineGoldBoost3: return "180201"
        case .offlineGoldBoost4: return "180401"
        case .offlineGoldBoost5: return "180601"
        case .offlineXPBoost: return "110012"
        case .offlineXPBoost2: return "150021"
        case .offlineXPBoost3: return "180301"
        case .offlineXPBoost4: return "180501"
        case .offlineXPBoost5: return "180701"
        case .stashPage1: return "13001"
        case .stashPage2: return "16001"
        case .stashPage3: return "160011"
        case .waveCountReduction1: return "1171"
        }
    }

    var displayName: String {
        switch self {
        case .allHeroAttackDamage1: return "战争符文：全英雄攻击 +1"
        case .allHeroArmor1: return "盾之符文：全英雄护甲 +1"
        case .allHeroMoveSpeed1: return "疾风符文：全英雄速度 +1"
        case .allHeroAttackDamagePercent1: return "战争符文：全英雄攻击 +10%"
        case .allHeroMoveSpeed5: return "疾风符文：全英雄速度 +1（五）"
        case .allHeroArmorPercent1: return "盾之符文：全英雄护甲 +10%"
        case .allHeroAttackDamagePercent2: return "战争符文：全英雄攻击 +10%（二）"
        case .allHeroAttackSpeed1: return "狂暴符文：全英雄攻速 +10%"
        case .allHeroAttackSpeed2: return "狂暴符文：全英雄攻速 +10%（二）"
        case .allHeroArmor3: return "盾之符文：全英雄护甲 +1（三）"
        case .allHeroAttackDamage4: return "战争符文：全英雄攻击 +1（四）"
        case .allHeroMoveSpeed4: return "疾风符文：全英雄速度 +1（四）"
        case .allHeroArmor2: return "盾之符文：全英雄护甲 +1（二）"
        case .allHeroAttackDamage2: return "战争符文：全英雄攻击 +1（二）"
        case .allHeroAttackDamage3: return "战争符文：全英雄攻击 +1（三）"
        case .allHeroMoveSpeed2: return "疾风符文：全英雄速度 +1（二）"
        case .allHeroMoveSpeed3: return "疾风符文：全英雄速度 +1（三）"
        case .allHeroArmorPercent2: return "盾之符文：全英雄护甲 +10%（二）"
        case .allHeroAttackDamagePercent3: return "战争符文：全英雄攻击 +10%（三）"
        case .allHeroAttackSpeed3: return "狂暴符文：全英雄攻速 +10%（三）"
        case .partySlot2: return "指挥符文：第 2 编队位"
        case .partySlot3: return "指挥符文：第 3 编队位"
        case .activeSkillSlot2: return "觉醒符文：第 2 主动技能槽"
        case .combatGoldBoost1: return "财富符文：战斗金币 +10%"
        case .combatGoldBoost2: return "财富符文：战斗金币 +10%（二）"
        case .combatGoldBoost3: return "财富符文：战斗金币 +10%（三）"
        case .combatGoldBoost4: return "财富符文：战斗金币 +10%（四）"
        case .combatGoldBoost5: return "财富符文：战斗金币 +10%（五）"
        case .combatGoldBoost6: return "财富符文：战斗金币 +10%（六）"
        case .combatGoldBoost7: return "财富符文：战斗金币 +10%（七）"
        case .combatXPBoost1: return "成长符文：战斗经验 +10%"
        case .combatXPBoost2: return "成长符文：战斗经验 +10%（二）"
        case .combatXPBoost3: return "成长符文：战斗经验 +10%（三）"
        case .combatXPBoost4: return "成长符文：战斗经验 +10%（四）"
        case .combatXPBoost5: return "成长符文：战斗经验 +10%（五）"
        case .combatXPBoost6: return "成长符文：战斗经验 +10%（六）"
        case .combatXPBoost7: return "成长符文：战斗经验 +10%（七）"
        case .additionalGold1: return "财富符文：通用金币 +10%"
        case .additionalGold2: return "财富符文：通用金币 +10%（二）"
        case .additionalGoldNormalMonster1: return "财富符文：普通怪金币 +10%"
        case .additionalGoldNormalMonster2: return "财富符文：普通怪金币 +10%（二）"
        case .additionalGoldNormalMonster3: return "财富符文：普通怪金币 +10%（三）"
        case .additionalGoldStageBoss1: return "财富符文：关卡首领金币 +10%"
        case .additionalGoldStageBoss2: return "财富符文：关卡首领金币 +10%（二）"
        case .additionalGoldStageBoss3: return "财富符文：关卡首领金币 +10%（三）"
        case .additionalGoldStageBoss4: return "财富符文：关卡首领金币 +10%（四）"
        case .additionalGoldStageBoss5: return "财富符文：关卡首领金币 +10%（五）"
        case .additionalGoldStageBoss6: return "财富符文：关卡首领金币 +10%（六）"
        case .additionalGoldStageBoss7: return "财富符文：关卡首领金币 +10%（七）"
        case .additionalGoldActBoss1: return "财富符文：Act Boss 金币 +10%"
        case .additionalGoldActBoss2: return "财富符文：Act Boss 金币 +10%（二）"
        case .additionalGoldActBoss3: return "财富符文：Act Boss 金币 +10%（三）"
        case .additionalXP1: return "成长符文：通用经验 +10%"
        case .additionalXP2: return "成长符文：通用经验 +10%（二）"
        case .additionalXPNormalMonster1: return "成长符文：普通怪经验 +10%"
        case .additionalXPNormalMonster2: return "成长符文：普通怪经验 +10%（二）"
        case .additionalXPStageBoss1: return "成长符文：关卡首领经验 +10%"
        case .additionalXPStageBoss2: return "成长符文：关卡首领经验 +10%（二）"
        case .additionalXPStageBoss3: return "成长符文：关卡首领经验 +10%（三）"
        case .additionalXPStageBoss4: return "成长符文：关卡首领经验 +10%（四）"
        case .additionalXPStageBoss5: return "成长符文：关卡首领经验 +10%（五）"
        case .additionalXPStageBoss6: return "成长符文：关卡首领经验 +10%（六）"
        case .additionalXPStageBoss7: return "成长符文：关卡首领经验 +10%（七）"
        case .additionalXPActBoss1: return "成长符文：Act Boss 经验 +10%"
        case .additionalXPActBoss2: return "成长符文：Act Boss 经验 +10%（二）"
        case .additionalXPActBoss3: return "成长符文：Act Boss 经验 +10%（三）"
        case .cubeXPBoost1: return "组合符文：魔方经验 +10%"
        case .cubeXPBoost2: return "组合符文：魔方经验 +10%（二）"
        case .cubeXPBoost3: return "组合符文：魔方经验 +10%（三）"
        case .cubeXPBoost4: return "组合符文：魔方经验 +10%（四）"
        case .alchemyGoldBoost1: return "炼金符文：炼金金币 +10%"
        case .alchemyGoldBoost2: return "炼金符文：炼金金币 +10%（二）"
        case .alchemyGoldBoost3: return "炼金符文：炼金金币 +10%（三）"
        case .alchemyGoldBoost4: return "炼金符文：炼金金币 +10%（四）"
        case .inventoryExpansion1: return "扩张符文：背包容量 +10"
        case .inventoryExpansion2: return "扩张符文：背包容量 +10"
        case .inventoryExpansion3: return "扩张符文：背包容量 +10（三）"
        case .inventoryExpansion4: return "扩张符文：背包容量 +10（四）"
        case .inventoryExpansion5: return "扩张符文：背包容量 +10（五）"
        case .inventoryExpansion6: return "扩张符文：背包容量 +10（六）"
        case .inventoryExpansion7: return "扩张符文：背包容量 +10（七）"
        case .inventoryExpansion8: return "扩张符文：背包容量 +10（八）"
        case .inventoryExpansion9: return "扩张符文：背包容量 +10（九）"
        case .inventoryExpansion10: return "扩张符文：背包容量 +10（十）"
        case .inventoryExpansion11: return "扩张符文：背包容量 +10（十一）"
        case .inventoryExpansion12: return "扩张符文：背包容量 +10（十二）"
        case .inventoryExpansion13: return "扩张符文：背包容量 +10（十三）"
        case .inventoryExpansion14: return "扩张符文：背包容量 +10（十四）"
        case .inventoryExpansion15: return "扩张符文：背包容量 +10（十五）"
        case .inventoryExpansion16: return "扩张符文：背包容量 +10（十六）"
        case .inventoryExpansion17: return "扩张符文：背包容量 +10（十七）"
        case .inventoryExpansion18: return "扩张符文：背包容量 +10（十八）"
        case .inventoryExpansion19: return "扩张符文：背包容量 +10（十九）"
        case .inventoryExpansion20: return "扩张符文：背包容量 +10（二十）"
        case .inventoryExpansion21: return "扩张符文：背包容量 +10（二十一）"
        case .inventoryExpansion22: return "扩张符文：背包容量 +10（二十二）"
        case .inventoryExpansion23: return "扩张符文：背包容量 +10（二十三）"
        case .inventoryExpansion24: return "扩张符文：背包容量 +10（二十四）"
        case .inventoryExpansion25: return "扩张符文：背包容量 +10（二十五）"
        case .inventoryExpansion26: return "扩张符文：背包容量 +10（二十六）"
        case .normalChestDropChance1: return "探索符文：普通箱掉落 +10%"
        case .normalChestDropChance2: return "探索符文：普通箱掉落 +10%（二）"
        case .normalChestDropChance3: return "探索符文：普通箱掉落 +10%（三）"
        case .normalChestDropChance4: return "探索符文：普通箱掉落 +10%（四）"
        case .normalChestDropChance5: return "探索符文：普通箱掉落 +10%（五）"
        case .normalChestDropChance6: return "探索符文：普通箱掉落 +10%（六）"
        case .normalChestDropChance7: return "探索符文：普通箱掉落 +10%（七）"
        case .normalChestDropChance8: return "探索符文：普通箱掉落 +10%（八）"
        case .normalChestDropChance9: return "探索符文：普通箱掉落 +10%（九）"
        case .normalChestDropChance10: return "探索符文：普通箱掉落 +10%（十）"
        case .normalChestDropChance11: return "探索符文：普通箱掉落 +10%（十一）"
        case .normalChestDropChance12: return "探索符文：普通箱掉落 +10%（十二）"
        case .normalChestDropChance13: return "探索符文：普通箱掉落 +10%（十三）"
        case .normalChestDropChance14: return "探索符文：普通箱掉落 +10%（十四）"
        case .normalChestDropChance15: return "探索符文：普通箱掉落 +10%（十五）"
        case .stageBossChestDropChance1: return "征服符文：关卡 Boss 箱掉落 +10%"
        case .stageBossChestDropChance2: return "征服符文：关卡 Boss 箱掉落 +10%（二）"
        case .stageBossChestDropChance3: return "征服符文：关卡 Boss 箱掉落 +10%（三）"
        case .stageBossChestDropChance4: return "征服符文：关卡 Boss 箱掉落 +10%（四）"
        case .stageBossChestDropChance5: return "征服符文：关卡 Boss 箱掉落 +10%（五）"
        case .stageBossChestDropChance6: return "征服符文：关卡 Boss 箱掉落 +10%（六）"
        case .stageBossChestDropChance7: return "征服符文：关卡 Boss 箱掉落 +10%（七）"
        case .stageBossChestDropChance8: return "征服符文：关卡 Boss 箱掉落 +10%（八）"
        case .stageBossChestDropChance9: return "征服符文：关卡 Boss 箱掉落 +10%（九）"
        case .stageBossChestDropChance10: return "征服符文：关卡 Boss 箱掉落 +10%（十）"
        case .stageBossChestDropChance11: return "征服符文：关卡 Boss 箱掉落 +10%（十一）"
        case .stageBossChestDropChance12: return "征服符文：关卡 Boss 箱掉落 +10%（十二）"
        case .stageBossChestDropChance13: return "征服符文：关卡 Boss 箱掉落 +10%（十三）"
        case .stageBossChestDropChance14: return "征服符文：关卡 Boss 箱掉落 +10%（十四）"
        case .openOneChestType: return "开启符文：同类箱子全部开启"
        case .openAllChestTypes: return "开启符文：全部箱子一键开启"
        case .autoOpenNormalChests: return "发条符文：自动开启普通箱子"
        case .autoOpenStageBossChests: return "发条符文：自动开启关卡 Boss 箱"
        case .autoOpenActBossChests: return "发条符文：自动开启 Act Boss 箱"
        case .normalChestAutoOpenSpeed1: return "润滑符文：普通箱自动开启 +1"
        case .normalChestAutoOpenSpeed2: return "润滑符文：普通箱自动开启 +1（二）"
        case .normalChestAutoOpenSpeed3: return "润滑符文：普通箱自动开启 +1（三）"
        case .normalChestAutoOpenSpeed4: return "润滑符文：普通箱自动开启 +1（四）"
        case .stageBossChestAutoOpenSpeed1: return "润滑符文：关卡 Boss 箱自动开启 +1"
        case .stageBossChestAutoOpenSpeed2: return "润滑符文：关卡 Boss 箱自动开启 +1（二）"
        case .stageBossChestAutoOpenSpeed3: return "润滑符文：关卡 Boss 箱自动开启 +1（三）"
        case .stageBossChestAutoOpenSpeed4: return "润滑符文：关卡 Boss 箱自动开启 +1（四）"
        case .actBossChestAutoOpenSpeed1: return "润滑符文：Act Boss 箱自动开启 +1"
        case .actBossChestAutoOpenSpeed2: return "润滑符文：Act Boss 箱自动开启 +1（二）"
        case .maxNormalChestStorage: return "收纳符文：普通箱子上限 +1"
        case .maxNormalChestStorage2: return "收纳符文：普通箱子上限 +1（二）"
        case .maxNormalChestStorage3: return "收纳符文：普通箱子上限 +1（三）"
        case .maxNormalChestStorage4: return "收纳符文：普通箱子上限 +1（四）"
        case .maxNormalChestStorage5: return "收纳符文：普通箱子上限 +1（五）"
        case .maxNormalChestStorage6: return "收纳符文：普通箱子上限 +1（六）"
        case .maxNormalChestStorage7: return "收纳符文：普通箱子上限 +1（七）"
        case .maxNormalChestStorage8: return "收纳符文：普通箱子上限 +1（八）"
        case .maxNormalChestStorage9: return "收纳符文：普通箱子上限 +1（九）"
        case .maxNormalChestStorage10: return "收纳符文：普通箱子上限 +1（十）"
        case .maxNormalChestStorage11: return "收纳符文：普通箱子上限 +1（十一）"
        case .maxNormalChestStorage12: return "收纳符文：普通箱子上限 +1（十二）"
        case .maxNormalChestStorage13: return "收纳符文：普通箱子上限 +1（十三）"
        case .maxNormalChestStorage14: return "收纳符文：普通箱子上限 +1（十四）"
        case .maxNormalChestStorage15: return "收纳符文：普通箱子上限 +1（十五）"
        case .maxStageBossChestStorage: return "金库符文：关卡 Boss 箱上限 +1"
        case .maxStageBossChestStorage2: return "金库符文：关卡 Boss 箱上限 +1（二）"
        case .maxStageBossChestStorage3: return "金库符文：关卡 Boss 箱上限 +1（三）"
        case .maxStageBossChestStorage4: return "金库符文：关卡 Boss 箱上限 +1（四）"
        case .maxStageBossChestStorage5: return "金库符文：关卡 Boss 箱上限 +1（五）"
        case .maxStageBossChestStorage6: return "金库符文：关卡 Boss 箱上限 +1（六）"
        case .maxStageBossChestStorage7: return "金库符文：关卡 Boss 箱上限 +1（七）"
        case .maxStageBossChestStorage8: return "金库符文：关卡 Boss 箱上限 +1（八）"
        case .maxStageBossChestStorage9: return "金库符文：关卡 Boss 箱上限 +1（九）"
        case .maxStageBossChestStorage10: return "金库符文：关卡 Boss 箱上限 +1（十）"
        case .maxStageBossChestStorage11: return "金库符文：关卡 Boss 箱上限 +1（十一）"
        case .maxStageBossChestStorage12: return "金库符文：关卡 Boss 箱上限 +1（十二）"
        case .maxStageBossChestStorage13: return "金库符文：关卡 Boss 箱上限 +1（十三）"
        case .maxActBossChestStorage: return "无限符文：Act Boss 箱上限 +1"
        case .maxActBossChestStorage2: return "无限符文：Act Boss 箱上限 +1（二）"
        case .maxActBossChestStorage3: return "无限符文：Act Boss 箱上限 +1（三）"
        case .maxActBossChestStorage4: return "无限符文：Act Boss 箱上限 +1（四）"
        case .maxActBossChestStorage5: return "无限符文：Act Boss 箱上限 +1（五）"
        case .maxActBossChestStorage6: return "无限符文：Act Boss 箱上限 +1（六）"
        case .maxActBossChestStorage7: return "无限符文：Act Boss 箱上限 +1（七）"
        case .maxActBossChestStorage8: return "无限符文：Act Boss 箱上限 +1（八）"
        case .maxActBossChestStorage9: return "无限符文：Act Boss 箱上限 +1（九）"
        case .maxActBossChestStorage10: return "无限符文：Act Boss 箱上限 +1（十）"
        case .offlineRewards: return "安息符文：离线奖励"
        case .offlineGoldBoost: return "储藏符文：离线金币 +10%"
        case .offlineGoldBoost2: return "储藏符文：离线金币 +10%（二）"
        case .offlineGoldBoost3: return "储藏符文：离线金币 +10%（三）"
        case .offlineGoldBoost4: return "储藏符文：离线金币 +10%（四）"
        case .offlineGoldBoost5: return "储藏符文：离线金币 +10%（五）"
        case .offlineXPBoost: return "训练符文：离线经验 +10%"
        case .offlineXPBoost2: return "训练符文：离线经验 +10%（二）"
        case .offlineXPBoost3: return "训练符文：离线经验 +10%（三）"
        case .offlineXPBoost4: return "训练符文：离线经验 +10%（四）"
        case .offlineXPBoost5: return "训练符文：离线经验 +10%（五）"
        case .stashPage1: return "储存符文：仓库页 +20"
        case .stashPage2: return "储存符文：仓库页 +20"
        case .stashPage3: return "储存符文：仓库页 +20"
        case .waveCountReduction1: return "缩短符文：关卡目标 -1"
        }
    }

    var goldCost: Int {
        switch self {
        case .partySlot2: return 50_000
        case .partySlot3: return 150_000
        default: return 0
        }
    }

    var hasVerifiedGoldCost: Bool {
        self == .partySlot2 || self == .partySlot3
    }

    var approximateGoldCost: Int? {
        switch self {
        case .activeSkillSlot2:
            return 50_000
        default:
            return nil
        }
    }

    var approximateGoldCostSourceText: String? {
        switch self {
        case .activeSkillSlot2:
            return "官方符文分支：2nd Active Skill Slot (~50,000g)"
        default:
            return nil
        }
    }

    var costText: String {
        if hasVerifiedGoldCost {
            return "\(goldCost.formatted()) G"
        }
        if let approximateGoldCost {
            return "约 \(approximateGoldCost.formatted()) G（待核对）"
        }
        return "成本待核对"
    }

    var requiredNode: RuneTreeNode? {
        switch self {
        case .allHeroAttackDamagePercent1: return .allHeroMoveSpeed4
        case .allHeroMoveSpeed5: return .allHeroAttackDamagePercent1
        case .allHeroArmorPercent1: return .allHeroMoveSpeed5
        case .allHeroAttackDamagePercent2: return .allHeroArmorPercent1
        case .allHeroAttackSpeed1: return .allHeroMoveSpeed5
        case .allHeroAttackSpeed2: return .allHeroAttackDamagePercent2
        case .allHeroArmor3: return .allHeroMoveSpeed1
        case .allHeroAttackDamage4: return .allHeroArmor3
        case .allHeroMoveSpeed4: return .allHeroArmor3
        case .allHeroArmor2: return .allHeroAttackSpeed2
        case .allHeroAttackDamage2: return .allHeroArmor2
        case .allHeroAttackDamage3: return .allHeroAttackDamagePercent2
        case .allHeroMoveSpeed2: return .allHeroAttackDamage3
        case .allHeroMoveSpeed3: return .allHeroArmor2
        case .allHeroArmorPercent2: return .allHeroAttackDamage2
        case .allHeroAttackDamagePercent3: return .allHeroArmorPercent2
        case .allHeroAttackSpeed3: return .allHeroAttackDamagePercent3
        case .partySlot3, .inventoryExpansion1: return .partySlot2
        case .combatXPBoost1: return .combatGoldBoost1
        case .alchemyGoldBoost1: return .cubeXPBoost1
        case .cubeXPBoost2: return .alchemyGoldBoost2
        case .alchemyGoldBoost4: return .cubeXPBoost4
        case .inventoryExpansion2: return .inventoryExpansion1
        case .stashPage1: return .inventoryExpansion1
        case .stashPage2: return .stashPage1
        case .stashPage3: return .stashPage2
        case .openAllChestTypes: return .openOneChestType
        case .offlineGoldBoost, .offlineGoldBoost2, .offlineGoldBoost3, .offlineGoldBoost4, .offlineGoldBoost5, .offlineXPBoost, .offlineXPBoost3, .offlineXPBoost4, .offlineXPBoost5: return .offlineRewards
        case .offlineXPBoost2: return .offlineGoldBoost2
        default: return nil
        }
    }
}

struct SourceRuneNode: Equatable, Identifiable {
    let id: String
    let zhName: String
    let enName: String
    let maxLevel: Int
    let previousIDs: [String]
    let nextIDs: [String]
    let iconName: String
}

enum CombatRewardEncounterKind {
    case normalMonster
    case stageBoss
    case actBoss
}

enum SourceRuneCatalog {
    static let expectedNodeCount = 197
    static let expectedConnectionCount = 195
    static let expectedNextOutDegreeDistribution = [
        0: 79,
        1: 63,
        2: 35,
        3: 18,
        4: 2,
    ]
    static let expectedPreviousReferenceCount = 11
    static let expectedPreviousReferenceMap = [
        "10": ["11001", "11002"],
        "11": ["13002"],
        "21": ["23", "24", "26", "27"],
        "101": ["1031"],
        "401": ["4031"],
        "1031": ["1071"],
        "13002": ["15001"],
    ]
    static let expectedMaxLevelDistribution = [
        1: 62,
        2: 1,
        3: 43,
        5: 89,
        10: 2,
    ]
    static let expectedIconDistribution = [
        "AdditionalExp": 2,
        "AdditionalExpActBoss": 3,
        "AdditionalExpNormalMonster": 2,
        "AdditionalExpStageBoss": 7,
        "AdditionalGold": 2,
        "AdditionalGoldActBoss": 3,
        "AdditionalGoldNormalMonster": 3,
        "AdditionalGoldStageBoss": 7,
        "AllHeroArmor": 3,
        "AllHeroArmorPercent": 2,
        "AllHeroAttackDamage": 4,
        "AllHeroAttackDamagePercent": 3,
        "AllHeroAttackSpeed": 3,
        "AllHeroMoveSpeed": 5,
        "CubeAlchemyGoldPercent": 4,
        "CubeExpPercent": 4,
        "DropChanceNormalChest": 15,
        "DropChanceStageBossChest": 14,
        "IncreaseExpAmount": 7,
        "IncreaseGoldAmount": 7,
        "MaxAmountActBossChest": 10,
        "MaxAmountNormalChest": 15,
        "MaxAmountStageBossChest": 13,
        "MaxInventorySlot": 26,
        "OfflineRewardExpPercent": 5,
        "OfflineRewardGoldPercent": 5,
        "OpenAllTypeChestAllAtOnce": 1,
        "OpenOneTypeChestAllAtOnce": 1,
        "ReduceAutoOpenActBossChestTime": 2,
        "ReduceAutoOpenNormalChestTime": 4,
        "ReduceAutoOpenStageBossChestTime": 4,
        "UnlockArrangeSlotCount": 2,
        "UnlockAutoOpenActBossChest": 1,
        "UnlockAutoOpenNormalChest": 1,
        "UnlockAutoOpenStageBossChest": 1,
        "UnlockOfflineReward": 1,
        "UnlockSkillSlotCount": 1,
        "UnlockStashPageCount": 3,
        "WaveCountReduction": 1,
    ]

    static let all: [SourceRuneNode] = parseSourceRuneTSV()

    static let byID: [String: SourceRuneNode] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.id, $0) }
    )

    static var connectionCount: Int {
        all.reduce(0) { total, node in total + node.nextIDs.count }
    }

    static var nextOutDegreeDistribution: [Int: Int] {
        all.reduce(into: [:]) { distribution, node in
            distribution[node.nextIDs.count, default: 0] += 1
        }
    }

    static var previousReferenceCount: Int {
        all.reduce(0) { total, node in total + node.previousIDs.count }
    }

    static var previousReferenceMap: [String: [String]] {
        Dictionary(
            uniqueKeysWithValues: all
                .filter { !$0.previousIDs.isEmpty }
                .map { ($0.id, $0.previousIDs) }
        )
    }

    static var maxLevelDistribution: [Int: Int] {
        all.reduce(into: [:]) { distribution, node in
            distribution[node.maxLevel, default: 0] += 1
        }
    }

    static var iconNames: Set<String> {
        Set(all.map(\.iconName))
    }

    static var iconDistribution: [String: Int] {
        all.reduce(into: [:]) { distribution, node in
            distribution[node.iconName, default: 0] += 1
        }
    }

    static var runtimeModeledSourceIDs: Set<String> {
        Set(RuneTreeNode.allCases.map(\.sourceRuneID))
    }

    static var runtimeModeledNodes: [SourceRuneNode] {
        all.filter { runtimeModeledSourceIDs.contains($0.id) }
    }

    static var runtimeUnmodeledNodes: [SourceRuneNode] {
        all.filter { !runtimeModeledSourceIDs.contains($0.id) }
    }

    static var runtimeModeledIconNames: Set<String> {
        Set(runtimeModeledNodes.map(\.iconName))
    }

    static var runtimeUnmodeledIconNames: Set<String> {
        Set(runtimeUnmodeledNodes.map(\.iconName))
    }

    static var runtimeUnmodeledOnlyIconNames: Set<String> {
        iconNames.subtracting(runtimeModeledIconNames)
    }

    static var runtimeSharedModeledAndUnmodeledIconNames: Set<String> {
        runtimeModeledIconNames.intersection(runtimeUnmodeledIconNames)
    }

    static var danglingNextIDs: [String] {
        let ids = Set(all.map(\.id))
        return all
            .flatMap(\.nextIDs)
            .filter { !ids.contains($0) }
            .sorted()
    }

    static var danglingPreviousIDs: [String] {
        let ids = Set(all.map(\.id))
        return all
            .flatMap(\.previousIDs)
            .filter { !ids.contains($0) }
            .sorted()
    }

    static var duplicateIDs: [String] {
        var seen: Set<String> = []
        var duplicates: Set<String> = []
        for node in all {
            if !seen.insert(node.id).inserted {
                duplicates.insert(node.id)
            }
        }
        return duplicates.sorted()
    }

    private static func parseSourceRuneTSV() -> [SourceRuneNode] {
        sourceRuneTSV
            .split(whereSeparator: \.isNewline)
            .compactMap { line -> SourceRuneNode? in
                let columns = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
                guard columns.count == 7, let maxLevel = Int(columns[3]) else { return nil }
                return SourceRuneNode(
                    id: columns[0],
                    zhName: columns[1],
                    enName: columns[2],
                    maxLevel: maxLevel,
                    previousIDs: splitIDs(columns[4]),
                    nextIDs: splitIDs(columns[5]),
                    iconName: columns[6]
                )
            }
    }

    private static func splitIDs(_ value: String) -> [String] {
        value
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static let sourceRuneTSV = """
1	战争符文	Rune of War	1		10,20	AllHeroAttackDamage
10	财富符文	Rune of Wealth	3	11001,11002	11,101,201	AdditionalGoldStageBoss
11	扩张符文	Rune of Expansion	3	13002	12,11001,11002	MaxInventorySlot
12	扩张符文	Rune of Expansion	3		13	MaxInventorySlot
13	扩张符文	Rune of Expansion	3		14,13001,13002	MaxInventorySlot
14	扩张符文	Rune of Expansion	3		15	MaxInventorySlot
15	扩张符文	Rune of Expansion	3		16,15001,15002	MaxInventorySlot
16	扩张符文	Rune of Expansion	3		1801,1901,16001	MaxInventorySlot
20	成长符文	Rune of Growth	3		21,301,401	AdditionalExpStageBoss
21	指挥符文	Rune of Command	1	23,24,26,27	22,25	UnlockArrangeSlotCount
22	扩张符文	Rune of Expansion	3		23	MaxInventorySlot
23	扩张符文	Rune of Expansion	5		24	MaxInventorySlot
24	指挥符文	Rune of Command	1			UnlockArrangeSlotCount
25	财富符文	Rune of Wealth	3		26	IncreaseGoldAmount
26	成长符文	Rune of Growth	3		27	IncreaseExpAmount
27	觉醒符文	Rune of Awakening	1			UnlockSkillSlotCount
101	探索符文	Rune of Exploration	3	1031	102	DropChanceNormalChest
102	征服符文	Rune of Conquest	3		103,1021	DropChanceStageBossChest
103	探索符文	Rune of Exploration	5		104,1031	DropChanceNormalChest
104	征服符文	Rune of Conquest	5		105	DropChanceStageBossChest
105	探索符文	Rune of Exploration	5		106,1051	DropChanceNormalChest
106	征服符文	Rune of Conquest	5		107,1061	DropChanceStageBossChest
107	探索符文	Rune of Exploration	5		108,1071,1072	DropChanceNormalChest
108	征服符文	Rune of Conquest	5		109	DropChanceStageBossChest
109	探索符文	Rune of Exploration	5		110,1091	DropChanceNormalChest
110	征服符文	Rune of Conquest	5		111,1101,1102	DropChanceStageBossChest
111	探索符文	Rune of Exploration	5		112,1111	DropChanceNormalChest
112	征服符文	Rune of Conquest	5		113,1121	DropChanceStageBossChest
113	探索符文	Rune of Exploration	5		114,1131,1132	DropChanceNormalChest
114	征服符文	Rune of Conquest	5		115,1141,1142	DropChanceStageBossChest
115	探索符文	Rune of Exploration	5		116	DropChanceNormalChest
116	征服符文	Rune of Conquest	5		117,1161	DropChanceStageBossChest
117	探索符文	Rune of Exploration	5		118,1171,1172	DropChanceNormalChest
118	征服符文	Rune of Conquest	5		119,1181,1182	DropChanceStageBossChest
119	探索符文	Rune of Exploration	5		120,1191	DropChanceNormalChest
120	征服符文	Rune of Conquest	5		121,1201,1202,1203	DropChanceStageBossChest
121	探索符文	Rune of Exploration	5		122	DropChanceNormalChest
122	征服符文	Rune of Conquest	5		123,1221,1222	DropChanceStageBossChest
123	探索符文	Rune of Exploration	5		124	DropChanceNormalChest
124	征服符文	Rune of Conquest	5		125,1241	DropChanceStageBossChest
125	探索符文	Rune of Exploration	5		126,1251,1252	DropChanceNormalChest
126	征服符文	Rune of Conquest	5		127,1261,1262	DropChanceStageBossChest
127	探索符文	Rune of Exploration	5		128	DropChanceNormalChest
128	征服符文	Rune of Conquest	5		1281,1282	DropChanceStageBossChest
201	财富符文	Rune of Wealth	1		202	AdditionalGold
202	财富符文	Rune of Wealth	5		203	IncreaseGoldAmount
203	财富符文	Rune of Wealth	5		204,2031	AdditionalGoldStageBoss
204	财富符文	Rune of Wealth	1		205	AdditionalGoldNormalMonster
205	财富符文	Rune of Wealth	5		206	AdditionalGoldActBoss
206	财富符文	Rune of Wealth	5		207	IncreaseGoldAmount
207	财富符文	Rune of Wealth	5		208,2071	AdditionalGoldStageBoss
208	财富符文	Rune of Wealth	5		209	IncreaseGoldAmount
209	财富符文	Rune of Wealth	5		210,2091	AdditionalGoldStageBoss
210	财富符文	Rune of Wealth	5		211	IncreaseGoldAmount
211	财富符文	Rune of Wealth	5		212,2111	AdditionalGoldStageBoss
212	财富符文	Rune of Wealth	5		213	IncreaseGoldAmount
213	财富符文	Rune of Wealth	5		214,2131,2132	AdditionalGoldStageBoss
214	财富符文	Rune of Wealth	5		215	IncreaseGoldAmount
215	财富符文	Rune of Wealth	5		2151	AdditionalGoldStageBoss
301	成长符文	Rune of Growth	1		302	AdditionalExp
302	成长符文	Rune of Growth	5		303,3031	IncreaseExpAmount
303	成长符文	Rune of Growth	5		304	AdditionalExpStageBoss
304	成长符文	Rune of Growth	1		305	AdditionalExpNormalMonster
305	成长符文	Rune of Growth	3		306	AdditionalExpActBoss
306	成长符文	Rune of Growth	5		307,3061	IncreaseExpAmount
307	成长符文	Rune of Growth	5		308	AdditionalExpStageBoss
308	成长符文	Rune of Growth	5		309	IncreaseExpAmount
309	成长符文	Rune of Growth	5		310,3091	AdditionalExpStageBoss
310	成长符文	Rune of Growth	5		311	IncreaseExpAmount
311	成长符文	Rune of Growth	5		312	AdditionalExpStageBoss
312	成长符文	Rune of Growth	5		313,3121	IncreaseExpAmount
313	成长符文	Rune of Growth	5		314	AdditionalExpStageBoss
314	成长符文	Rune of Growth	5		315	IncreaseExpAmount
315	成长符文	Rune of Growth	5		3151,3152	AdditionalExpStageBoss
401	盾之符文	Rune of the Shield	3	4031	402	AllHeroArmor
402	疾风符文	Rune of the Gale	3		403	AllHeroMoveSpeed
403	盾之符文	Rune of the Shield	10		404,4031	AllHeroArmor
404	疾风符文	Rune of the Gale	5		405	AllHeroMoveSpeed
405	战争符文	Rune of War	10		406	AllHeroAttackDamagePercent
406	疾风符文	Rune of the Gale	5		407,4061	AllHeroMoveSpeed
407	盾之符文	Rune of the Shield	5		408	AllHeroArmorPercent
408	战争符文	Rune of War	5		409,4081	AllHeroAttackDamagePercent
409	狂暴符文	Rune of Frenzy	5		410	AllHeroAttackSpeed
410	盾之符文	Rune of the Shield	5		411,4101	AllHeroArmor
411	战争符文	Rune of War	5		412	AllHeroAttackDamage
412	盾之符文	Rune of the Shield	5		413	AllHeroArmorPercent
413	战争符文	Rune of War	5		414	AllHeroAttackDamagePercent
414	狂暴符文	Rune of Frenzy	5			AllHeroAttackSpeed
1021	开启符文	Rune of Opening	1			OpenOneTypeChestAllAtOnce
1031	收纳符文	Rune of Containment	1	1071		MaxAmountNormalChest
1051	扩张符文	Rune of Expansion	5		1052,1053,1055,1056	MaxInventorySlot
1052	收纳符文	Rune of Containment	1		1054	MaxAmountNormalChest
1053	探索符文	Rune of Exploration	3			DropChanceNormalChest
1054	扩张符文	Rune of Expansion	5			MaxInventorySlot
1055	开启符文	Rune of Opening	1			OpenAllTypeChestAllAtOnce
1056	无限符文	Rune of Infinity	1			MaxAmountActBossChest
1061	收纳符文	Rune of Containment	1			MaxAmountNormalChest
1071	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1072	收纳符文	Rune of Containment	1			MaxAmountNormalChest
1091	收纳符文	Rune of Containment	1			MaxAmountNormalChest
1101	收纳符文	Rune of Containment	1			MaxAmountNormalChest
1102	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1111	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1121	收纳符文	Rune of Containment	1			MaxAmountNormalChest
1131	收纳符文	Rune of Containment	1			MaxAmountNormalChest
1132	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1133	无限符文	Rune of Infinity	1			MaxAmountActBossChest
1141	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1142	收纳符文	Rune of Containment	1			MaxAmountNormalChest
1161	收纳符文	Rune of Containment	1		11611	MaxAmountNormalChest
1171	缩短符文	Rune of Brevity	1			WaveCountReduction
1172	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1181	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1182	无限符文	Rune of Infinity	1			MaxAmountActBossChest
1191	收纳符文	Rune of Containment	1			MaxAmountNormalChest
1201	收纳符文	Rune of Containment	1			MaxAmountNormalChest
1202	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1203	无限符文	Rune of Infinity	1			MaxAmountActBossChest
1221	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1222	无限符文	Rune of Infinity	1			MaxAmountActBossChest
1241	收纳符文	Rune of Containment	1			MaxAmountNormalChest
1251	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1252	无限符文	Rune of Infinity	1			MaxAmountActBossChest
1261	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1262	无限符文	Rune of Infinity	1			MaxAmountActBossChest
1281	金库符文	Rune of the Vault	1			MaxAmountStageBossChest
1282	无限符文	Rune of Infinity	1		12821	MaxAmountActBossChest
1801	扩张符文	Rune of Expansion	3		1802	MaxInventorySlot
1802	扩张符文	Rune of Expansion	3		1803,180201	MaxInventorySlot
1803	扩张符文	Rune of Expansion	3		1804,180301	MaxInventorySlot
1804	扩张符文	Rune of Expansion	3		1805,180401	MaxInventorySlot
1805	扩张符文	Rune of Expansion	3		1806,180501	MaxInventorySlot
1806	扩张符文	Rune of Expansion	3		1807,180601	MaxInventorySlot
1807	扩张符文	Rune of Expansion	3		1808,180701	MaxInventorySlot
1808	扩张符文	Rune of Expansion	3			MaxInventorySlot
1901	扩张符文	Rune of Expansion	3		1902	MaxInventorySlot
1902	扩张符文	Rune of Expansion	3		1903,1902001	MaxInventorySlot
1903	扩张符文	Rune of Expansion	3		1904,190301,190302	MaxInventorySlot
1904	扩张符文	Rune of Expansion	3		1905,190401	MaxInventorySlot
1905	扩张符文	Rune of Expansion	3		1906,190501,190502	MaxInventorySlot
1906	扩张符文	Rune of Expansion	3		1907	MaxInventorySlot
1907	扩张符文	Rune of Expansion	3		1908	MaxInventorySlot
1908	扩张符文	Rune of Expansion	3			MaxInventorySlot
2031	炼金符文	Rune of Alchemy	1		2032	CubeAlchemyGoldPercent
2032	组合符文	Rune of Forging	5			CubeExpPercent
2071	财富符文	Rune of Wealth	1			AdditionalGoldNormalMonster
2091	财富符文	Rune of Wealth	5			AdditionalGoldActBoss
2111	财富符文	Rune of Wealth	5			AdditionalGold
2131	炼金符文	Rune of Alchemy	3			CubeAlchemyGoldPercent
2132	组合符文	Rune of Forging	5			CubeExpPercent
2151	财富符文	Rune of Wealth	2		2152	AdditionalGoldNormalMonster
2152	财富符文	Rune of Wealth	5			AdditionalGoldActBoss
3031	组合符文	Rune of Forging	1		3032	CubeExpPercent
3032	炼金符文	Rune of Alchemy	5			CubeAlchemyGoldPercent
3061	成长符文	Rune of Growth	5			AdditionalExpActBoss
3091	成长符文	Rune of Growth	1			AdditionalExpNormalMonster
3121	组合符文	Rune of Forging	5		3122	CubeExpPercent
3122	炼金符文	Rune of Alchemy	5			CubeAlchemyGoldPercent
3151	成长符文	Rune of Growth	5			AdditionalExp
3152	成长符文	Rune of Growth	5			AdditionalExpActBoss
4031	战争符文	Rune of War	1			AllHeroAttackDamage
4061	狂暴符文	Rune of Frenzy	3			AllHeroAttackSpeed
4081	战争符文	Rune of War	5		4082	AllHeroAttackDamage
4082	疾风符文	Rune of the Gale	1			AllHeroMoveSpeed
4101	疾风符文	Rune of the Gale	5			AllHeroMoveSpeed
11001	安息符文	Rune of Repose	1		110011,110012	UnlockOfflineReward
11002	收纳符文	Rune of Containment	1		11003	MaxAmountNormalChest
11003	金库符文	Rune of the Vault	1		11004	MaxAmountStageBossChest
11004	无限符文	Rune of Infinity	1			MaxAmountActBossChest
11611	收纳符文	Rune of Containment	1			MaxAmountNormalChest
12821	无限符文	Rune of Infinity	1			MaxAmountActBossChest
13001	储存符文	Rune of Storage	1			UnlockStashPageCount
13002	发条符文	Rune of the Mainspring	1	15001	130021	UnlockAutoOpenNormalChest
15001	发条符文	Rune of the Mainspring	1		150011	UnlockAutoOpenStageBossChest
15002	储藏符文	Rune of Hoarding	3		150021	OfflineRewardGoldPercent
16001	储存符文	Rune of Storage	1		160011	UnlockStashPageCount
110011	储藏符文	Rune of Hoarding	3			OfflineRewardGoldPercent
110012	训练符文	Rune of Training	3			OfflineRewardExpPercent
130021	润滑符文	Rune of Lubrication	3			ReduceAutoOpenNormalChestTime
150011	润滑符文	Rune of Lubrication	3			ReduceAutoOpenStageBossChestTime
150021	训练符文	Rune of Training	3			OfflineRewardExpPercent
160011	储存符文	Rune of Storage	1			UnlockStashPageCount
180201	储藏符文	Rune of Hoarding	5			OfflineRewardGoldPercent
180301	训练符文	Rune of Training	5			OfflineRewardExpPercent
180401	储藏符文	Rune of Hoarding	5			OfflineRewardGoldPercent
180501	训练符文	Rune of Training	5			OfflineRewardExpPercent
180601	储藏符文	Rune of Hoarding	5			OfflineRewardGoldPercent
180701	训练符文	Rune of Training	5			OfflineRewardExpPercent
190301	润滑符文	Rune of Lubrication	5			ReduceAutoOpenNormalChestTime
190302	润滑符文	Rune of Lubrication	5			ReduceAutoOpenStageBossChestTime
190401	润滑符文	Rune of Lubrication	3			ReduceAutoOpenActBossChestTime
190501	润滑符文	Rune of Lubrication	5		1905011	ReduceAutoOpenNormalChestTime
190502	润滑符文	Rune of Lubrication	5		1905021	ReduceAutoOpenStageBossChestTime
1902001	发条符文	Rune of the Mainspring	1		19020011	UnlockAutoOpenActBossChest
1905011	润滑符文	Rune of Lubrication	5			ReduceAutoOpenNormalChestTime
1905021	润滑符文	Rune of Lubrication	5			ReduceAutoOpenStageBossChestTime
19020011	润滑符文	Rune of Lubrication	3			ReduceAutoOpenActBossChestTime
"""
}

struct RuneTree: Codable, Equatable {
    static let requiredHeroLevel = 3
    static let allHeroAttackDamageBonus = 1
    static let allHeroArmorBonus = 1
    static let allHeroMoveSpeedBonus = 1
    static let allHeroAttackDamageMultiplierBonus = 0.10
    static let allHeroArmorMultiplierBonus = 0.10
    static let allHeroAttackSpeedMultiplierBonus = 0.10
    static let inventoryExpansionSlotBonus = 10
    static let stashPageSlotBonus = 20
    static let chestStorageCapacityBonus = 1
    static let stageClearTargetReductionBonus = 1
    static let combatRewardMultiplierBonus = 0.10
    static let cubeRewardMultiplierBonus = 0.10
    static let chestDropChanceBonus = 0.10
    static let normalChestAutoOpenBaseCooldown: TimeInterval = 300
    static let stageBossChestAutoOpenBaseCooldown: TimeInterval = 600
    static let actBossChestAutoOpenBaseCooldown: TimeInterval = 60
    static let minimumAutoOpenCooldown: TimeInterval = 1
    static let normalChestAutoOpenCooldownReductionByNode: [RuneTreeNode: TimeInterval] = [
        .normalChestAutoOpenSpeed1: 9,
        .normalChestAutoOpenSpeed2: 10,
        .normalChestAutoOpenSpeed3: 10,
        .normalChestAutoOpenSpeed4: 10,
    ]
    static let stageBossChestAutoOpenCooldownReductionByNode: [RuneTreeNode: TimeInterval] = [
        .stageBossChestAutoOpenSpeed1: 15,
        .stageBossChestAutoOpenSpeed2: 20,
        .stageBossChestAutoOpenSpeed3: 20,
        .stageBossChestAutoOpenSpeed4: 20,
    ]
    static let actBossChestAutoOpenCooldownReductionByNode: [RuneTreeNode: TimeInterval] = [
        .actBossChestAutoOpenSpeed1: 3,
        .actBossChestAutoOpenSpeed2: 3,
    ]
    static let combatGoldBoostNodes: [RuneTreeNode] = [
        .combatGoldBoost1,
        .combatGoldBoost2,
        .combatGoldBoost3,
        .combatGoldBoost4,
        .combatGoldBoost5,
        .combatGoldBoost6,
        .combatGoldBoost7,
    ]
    static let combatXPBoostNodes: [RuneTreeNode] = [
        .combatXPBoost1,
        .combatXPBoost2,
        .combatXPBoost3,
        .combatXPBoost4,
        .combatXPBoost5,
        .combatXPBoost6,
        .combatXPBoost7,
    ]
    static let additionalGoldBoostNodes: [RuneTreeNode] = [
        .additionalGold1,
        .additionalGold2,
    ]
    static let additionalGoldNormalMonsterNodes: [RuneTreeNode] = [
        .additionalGoldNormalMonster1,
        .additionalGoldNormalMonster2,
        .additionalGoldNormalMonster3,
    ]
    static let additionalGoldStageBossNodes: [RuneTreeNode] = [
        .additionalGoldStageBoss1,
        .additionalGoldStageBoss2,
        .additionalGoldStageBoss3,
        .additionalGoldStageBoss4,
        .additionalGoldStageBoss5,
        .additionalGoldStageBoss6,
        .additionalGoldStageBoss7,
    ]
    static let additionalGoldActBossNodes: [RuneTreeNode] = [
        .additionalGoldActBoss1,
        .additionalGoldActBoss2,
        .additionalGoldActBoss3,
    ]
    static let additionalXPBoostNodes: [RuneTreeNode] = [
        .additionalXP1,
        .additionalXP2,
    ]
    static let additionalXPNormalMonsterNodes: [RuneTreeNode] = [
        .additionalXPNormalMonster1,
        .additionalXPNormalMonster2,
    ]
    static let additionalXPStageBossNodes: [RuneTreeNode] = [
        .additionalXPStageBoss1,
        .additionalXPStageBoss2,
        .additionalXPStageBoss3,
        .additionalXPStageBoss4,
        .additionalXPStageBoss5,
        .additionalXPStageBoss6,
        .additionalXPStageBoss7,
    ]
    static let additionalXPActBossNodes: [RuneTreeNode] = [
        .additionalXPActBoss1,
        .additionalXPActBoss2,
        .additionalXPActBoss3,
    ]
    static let cubeXPBoostNodes: [RuneTreeNode] = [
        .cubeXPBoost1,
        .cubeXPBoost2,
        .cubeXPBoost3,
        .cubeXPBoost4,
    ]
    static let alchemyGoldBoostNodes: [RuneTreeNode] = [
        .alchemyGoldBoost1,
        .alchemyGoldBoost2,
        .alchemyGoldBoost3,
        .alchemyGoldBoost4,
    ]
    static let offlineGoldBoostNodes: [RuneTreeNode] = [
        .offlineGoldBoost,
        .offlineGoldBoost2,
        .offlineGoldBoost3,
        .offlineGoldBoost4,
        .offlineGoldBoost5,
    ]
    static let offlineXPBoostNodes: [RuneTreeNode] = [
        .offlineXPBoost,
        .offlineXPBoost2,
        .offlineXPBoost3,
        .offlineXPBoost4,
        .offlineXPBoost5,
    ]
    static let inventoryExpansionNodes: [RuneTreeNode] = [
        .inventoryExpansion1,
        .inventoryExpansion2,
        .inventoryExpansion3,
        .inventoryExpansion4,
        .inventoryExpansion5,
        .inventoryExpansion6,
        .inventoryExpansion7,
        .inventoryExpansion8,
        .inventoryExpansion9,
        .inventoryExpansion10,
        .inventoryExpansion11,
        .inventoryExpansion12,
        .inventoryExpansion13,
        .inventoryExpansion14,
        .inventoryExpansion15,
        .inventoryExpansion16,
        .inventoryExpansion17,
        .inventoryExpansion18,
        .inventoryExpansion19,
        .inventoryExpansion20,
        .inventoryExpansion21,
        .inventoryExpansion22,
        .inventoryExpansion23,
        .inventoryExpansion24,
        .inventoryExpansion25,
        .inventoryExpansion26,
    ]
    static let normalChestDropChanceNodes: [RuneTreeNode] = [
        .normalChestDropChance1,
        .normalChestDropChance2,
        .normalChestDropChance3,
        .normalChestDropChance4,
        .normalChestDropChance5,
        .normalChestDropChance6,
        .normalChestDropChance7,
        .normalChestDropChance8,
        .normalChestDropChance9,
        .normalChestDropChance10,
        .normalChestDropChance11,
        .normalChestDropChance12,
        .normalChestDropChance13,
        .normalChestDropChance14,
        .normalChestDropChance15,
    ]
    static let stageBossChestDropChanceNodes: [RuneTreeNode] = [
        .stageBossChestDropChance1,
        .stageBossChestDropChance2,
        .stageBossChestDropChance3,
        .stageBossChestDropChance4,
        .stageBossChestDropChance5,
        .stageBossChestDropChance6,
        .stageBossChestDropChance7,
        .stageBossChestDropChance8,
        .stageBossChestDropChance9,
        .stageBossChestDropChance10,
        .stageBossChestDropChance11,
        .stageBossChestDropChance12,
        .stageBossChestDropChance13,
        .stageBossChestDropChance14,
    ]
    static let normalChestAutoOpenSpeedNodes: [RuneTreeNode] = [
        .normalChestAutoOpenSpeed1,
        .normalChestAutoOpenSpeed2,
        .normalChestAutoOpenSpeed3,
        .normalChestAutoOpenSpeed4,
    ]
    static let stageBossChestAutoOpenSpeedNodes: [RuneTreeNode] = [
        .stageBossChestAutoOpenSpeed1,
        .stageBossChestAutoOpenSpeed2,
        .stageBossChestAutoOpenSpeed3,
        .stageBossChestAutoOpenSpeed4,
    ]
    static let actBossChestAutoOpenSpeedNodes: [RuneTreeNode] = [
        .actBossChestAutoOpenSpeed1,
        .actBossChestAutoOpenSpeed2,
    ]

    /// Kept for old-save compatibility; the currently verified formation runes spend gold.
    var points: Int
    var unlockedNodes: Set<RuneTreeNode>

    init(points: Int = 0, unlockedNodes: Set<RuneTreeNode> = []) {
        self.points = max(0, points)
        self.unlockedNodes = unlockedNodes
    }

    init(unlockedPartySlotCount: Int) {
        let clamped = min(max(unlockedPartySlotCount, 1), HeroParty.maxSlots)
        var nodes: Set<RuneTreeNode> = []
        if clamped >= 2 { nodes.insert(.partySlot2) }
        if clamped >= 3 { nodes.insert(.partySlot3) }
        self.init(points: 0, unlockedNodes: nodes)
    }

    var unlockedPartySlotCount: Int {
        1
            + (isUnlocked(.partySlot2) ? 1 : 0)
            + (isUnlocked(.partySlot3) ? 1 : 0)
    }

    var activeSkillSlotCount: Int {
        1 + (isUnlocked(.activeSkillSlot2) ? 1 : 0)
    }

    private var allHeroAttackDamageUnlockedCount: Int {
        [
            RuneTreeNode.allHeroAttackDamage1,
            .allHeroAttackDamage4,
            .allHeroAttackDamage2,
            .allHeroAttackDamage3,
        ].filter(isUnlocked).count
    }

    var allHeroAttackDamage: Int {
        allHeroAttackDamageUnlockedCount * Self.allHeroAttackDamageBonus
    }

    private var allHeroArmorUnlockedCount: Int {
        [
            RuneTreeNode.allHeroArmor1,
            .allHeroArmor2,
            .allHeroArmor3,
        ].filter(isUnlocked).count
    }

    var allHeroArmor: Int {
        allHeroArmorUnlockedCount * Self.allHeroArmorBonus
    }

    private var allHeroMoveSpeedUnlockedCount: Int {
        [
            RuneTreeNode.allHeroMoveSpeed1,
            .allHeroMoveSpeed2,
            .allHeroMoveSpeed3,
            .allHeroMoveSpeed4,
            .allHeroMoveSpeed5,
        ].filter(isUnlocked).count
    }

    var allHeroMoveSpeed: Int {
        allHeroMoveSpeedUnlockedCount * Self.allHeroMoveSpeedBonus
    }

    private var allHeroAttackDamagePercentUnlockedCount: Int {
        [
            RuneTreeNode.allHeroAttackDamagePercent1,
            .allHeroAttackDamagePercent2,
            .allHeroAttackDamagePercent3,
        ].filter(isUnlocked).count
    }

    var allHeroAttackDamageMultiplier: Double {
        1.0 + Double(allHeroAttackDamagePercentUnlockedCount) * Self.allHeroAttackDamageMultiplierBonus
    }

    private var allHeroArmorPercentUnlockedCount: Int {
        [
            RuneTreeNode.allHeroArmorPercent1,
            .allHeroArmorPercent2,
        ].filter(isUnlocked).count
    }

    var allHeroArmorMultiplier: Double {
        1.0 + Double(allHeroArmorPercentUnlockedCount) * Self.allHeroArmorMultiplierBonus
    }

    private var allHeroAttackSpeedUnlockedCount: Int {
        [
            RuneTreeNode.allHeroAttackSpeed1,
            .allHeroAttackSpeed2,
            .allHeroAttackSpeed3,
        ].filter(isUnlocked).count
    }

    var allHeroAttackSpeedMultiplier: Double {
        1.0 + Double(allHeroAttackSpeedUnlockedCount) * Self.allHeroAttackSpeedMultiplierBonus
    }

    private var inventoryExpansionUnlockedCount: Int {
        Self.inventoryExpansionNodes.filter(isUnlocked).count
    }

    var inventoryCapacity: Int {
        Inventory.baseCapacity
            + inventoryExpansionUnlockedCount * Self.inventoryExpansionSlotBonus
            + (isUnlocked(.stashPage1) ? Self.stashPageSlotBonus : 0)
            + (isUnlocked(.stashPage2) ? Self.stashPageSlotBonus : 0)
            + (isUnlocked(.stashPage3) ? Self.stashPageSlotBonus : 0)
    }

    var stageClearTargetReduction: Int {
        isUnlocked(.waveCountReduction1) ? Self.stageClearTargetReductionBonus : 0
    }

    private var normalChestDropChanceUnlockedCount: Int {
        Self.normalChestDropChanceNodes.filter(isUnlocked).count
    }

    private var stageBossChestDropChanceUnlockedCount: Int {
        Self.stageBossChestDropChanceNodes.filter(isUnlocked).count
    }

    var chestDropBonuses: ChestDropBonuses {
        ChestDropBonuses(
            normalMonsterChance: Double(normalChestDropChanceUnlockedCount) * Self.chestDropChanceBonus,
            stageBossChance: Double(stageBossChestDropChanceUnlockedCount) * Self.chestDropChanceBonus
        )
    }

    private var combatGoldBoostUnlockedCount: Int {
        Self.combatGoldBoostNodes.filter(isUnlocked).count
    }

    private var combatXPBoostUnlockedCount: Int {
        Self.combatXPBoostNodes.filter(isUnlocked).count
    }

    private var additionalGoldBoostUnlockedCount: Int {
        Self.additionalGoldBoostNodes.filter(isUnlocked).count
    }

    private var additionalGoldNormalMonsterUnlockedCount: Int {
        Self.additionalGoldNormalMonsterNodes.filter(isUnlocked).count
    }

    private var additionalGoldStageBossUnlockedCount: Int {
        Self.additionalGoldStageBossNodes.filter(isUnlocked).count
    }

    private var additionalGoldActBossUnlockedCount: Int {
        Self.additionalGoldActBossNodes.filter(isUnlocked).count
    }

    private var additionalXPBoostUnlockedCount: Int {
        Self.additionalXPBoostNodes.filter(isUnlocked).count
    }

    private var additionalXPNormalMonsterUnlockedCount: Int {
        Self.additionalXPNormalMonsterNodes.filter(isUnlocked).count
    }

    private var additionalXPStageBossUnlockedCount: Int {
        Self.additionalXPStageBossNodes.filter(isUnlocked).count
    }

    private var additionalXPActBossUnlockedCount: Int {
        Self.additionalXPActBossNodes.filter(isUnlocked).count
    }

    var combatGoldMultiplier: Double {
        1.0 + Double(combatGoldBoostUnlockedCount) * Self.combatRewardMultiplierBonus
    }

    var combatXPMultiplier: Double {
        1.0 + Double(combatXPBoostUnlockedCount) * Self.combatRewardMultiplierBonus
    }

    func combatGoldMultiplier(for encounterKind: CombatRewardEncounterKind) -> Double {
        let targetedCount: Int
        switch encounterKind {
        case .normalMonster:
            targetedCount = additionalGoldNormalMonsterUnlockedCount
        case .stageBoss:
            targetedCount = additionalGoldStageBossUnlockedCount
        case .actBoss:
            targetedCount = additionalGoldActBossUnlockedCount
        }
        return 1.0 + Double(combatGoldBoostUnlockedCount + additionalGoldBoostUnlockedCount + targetedCount) * Self.combatRewardMultiplierBonus
    }

    func combatXPMultiplier(for encounterKind: CombatRewardEncounterKind) -> Double {
        let targetedCount: Int
        switch encounterKind {
        case .normalMonster:
            targetedCount = additionalXPNormalMonsterUnlockedCount
        case .stageBoss:
            targetedCount = additionalXPStageBossUnlockedCount
        case .actBoss:
            targetedCount = additionalXPActBossUnlockedCount
        }
        return 1.0 + Double(combatXPBoostUnlockedCount + additionalXPBoostUnlockedCount + targetedCount) * Self.combatRewardMultiplierBonus
    }

    private var cubeXPBoostUnlockedCount: Int {
        Self.cubeXPBoostNodes.filter(isUnlocked).count
    }

    private var alchemyGoldBoostUnlockedCount: Int {
        Self.alchemyGoldBoostNodes.filter(isUnlocked).count
    }

    var cubeExperienceMultiplier: Double {
        1.0 + Double(cubeXPBoostUnlockedCount) * Self.cubeRewardMultiplierBonus
    }

    var alchemyGoldMultiplier: Double {
        1.0 + Double(alchemyGoldBoostUnlockedCount) * Self.cubeRewardMultiplierBonus
    }

    var canOpenOneChestTypeAtOnce: Bool {
        isUnlocked(.openOneChestType)
    }

    var canOpenAllChestTypesAtOnce: Bool {
        isUnlocked(.openAllChestTypes)
    }

    var canAutoOpenNormalChests: Bool {
        isUnlocked(.autoOpenNormalChests)
    }

    var canAutoOpenStageBossChests: Bool {
        isUnlocked(.autoOpenStageBossChests)
    }

    var canAutoOpenActBossChests: Bool {
        isUnlocked(.autoOpenActBossChests)
    }

    var normalChestAutoOpenCooldown: TimeInterval {
        autoOpenCooldown(for: .normalMonster)
    }

    var stageBossChestAutoOpenCooldown: TimeInterval {
        autoOpenCooldown(for: .stageBoss)
    }

    var actBossChestAutoOpenCooldown: TimeInterval {
        autoOpenCooldown(for: .actBoss)
    }

    func autoOpenCooldown(for family: ChestFamily) -> TimeInterval {
        max(Self.minimumAutoOpenCooldown, autoOpenBaseCooldown(for: family) - autoOpenCooldownReduction(for: family))
    }

    private func autoOpenBaseCooldown(for family: ChestFamily) -> TimeInterval {
        switch family {
        case .normalMonster:
            return Self.normalChestAutoOpenBaseCooldown
        case .stageBoss:
            return Self.stageBossChestAutoOpenBaseCooldown
        case .actBoss:
            return Self.actBossChestAutoOpenBaseCooldown
        }
    }

    private func autoOpenCooldownReduction(for family: ChestFamily) -> TimeInterval {
        let reductions: [RuneTreeNode: TimeInterval]
        switch family {
        case .normalMonster:
            reductions = Self.normalChestAutoOpenCooldownReductionByNode
        case .stageBoss:
            reductions = Self.stageBossChestAutoOpenCooldownReductionByNode
        case .actBoss:
            reductions = Self.actBossChestAutoOpenCooldownReductionByNode
        }

        return reductions.reduce(0) { total, entry in
            total + (isUnlocked(entry.key) ? entry.value : 0)
        }
    }

    private var maxNormalChestStorageUnlockedCount: Int {
        [
            RuneTreeNode.maxNormalChestStorage,
            .maxNormalChestStorage2,
            .maxNormalChestStorage3,
            .maxNormalChestStorage4,
            .maxNormalChestStorage5,
            .maxNormalChestStorage6,
            .maxNormalChestStorage7,
            .maxNormalChestStorage8,
            .maxNormalChestStorage9,
            .maxNormalChestStorage10,
            .maxNormalChestStorage11,
            .maxNormalChestStorage12,
            .maxNormalChestStorage13,
            .maxNormalChestStorage14,
            .maxNormalChestStorage15,
        ].filter(isUnlocked).count
    }

    private var maxStageBossChestStorageUnlockedCount: Int {
        [
            RuneTreeNode.maxStageBossChestStorage,
            .maxStageBossChestStorage2,
            .maxStageBossChestStorage3,
            .maxStageBossChestStorage4,
            .maxStageBossChestStorage5,
            .maxStageBossChestStorage6,
            .maxStageBossChestStorage7,
            .maxStageBossChestStorage8,
            .maxStageBossChestStorage9,
            .maxStageBossChestStorage10,
            .maxStageBossChestStorage11,
            .maxStageBossChestStorage12,
            .maxStageBossChestStorage13,
        ].filter(isUnlocked).count
    }

    private var maxActBossChestStorageUnlockedCount: Int {
        [
            RuneTreeNode.maxActBossChestStorage,
            .maxActBossChestStorage2,
            .maxActBossChestStorage3,
            .maxActBossChestStorage4,
            .maxActBossChestStorage5,
            .maxActBossChestStorage6,
            .maxActBossChestStorage7,
            .maxActBossChestStorage8,
            .maxActBossChestStorage9,
            .maxActBossChestStorage10,
        ].filter(isUnlocked).count
    }

    var chestStorageLimits: ChestStorageLimits {
        ChestStorageLimits(
            normalMonster: ChestStorageLimits.base.normalMonster + maxNormalChestStorageUnlockedCount * Self.chestStorageCapacityBonus,
            stageBoss: ChestStorageLimits.base.stageBoss + maxStageBossChestStorageUnlockedCount * Self.chestStorageCapacityBonus,
            actBoss: ChestStorageLimits.base.actBoss + maxActBossChestStorageUnlockedCount * Self.chestStorageCapacityBonus
        )
    }

    var offlineRewardsUnlocked: Bool {
        isUnlocked(.offlineRewards)
    }

    private var offlineGoldBoostUnlockedCount: Int {
        Self.offlineGoldBoostNodes.filter(isUnlocked).count
    }

    private var offlineXPBoostUnlockedCount: Int {
        Self.offlineXPBoostNodes.filter(isUnlocked).count
    }

    var offlineGoldMultiplier: Double {
        1.0 + Double(offlineGoldBoostUnlockedCount) * 0.10
    }

    var offlineXPMultiplier: Double {
        1.0 + Double(offlineXPBoostUnlockedCount) * 0.10
    }

    var verifiedResetRefundGold: Int {
        unlockedNodes.reduce(0) { total, node in
            total + (node.hasVerifiedGoldCost ? node.goldCost : 0)
        }
    }

    mutating func grantPoints(_ amount: Int) {
        points += max(0, amount)
    }

    func isUnlocked(_ node: RuneTreeNode) -> Bool {
        unlockedNodes.contains(node)
    }

    func hasPrerequisite(for node: RuneTreeNode) -> Bool {
        guard let requiredNode = node.requiredNode else { return true }
        return isUnlocked(requiredNode)
    }

    func canUnlock(_ node: RuneTreeNode, heroLevel: Int, availableGold: Int) -> Bool {
        guard heroLevel >= Self.requiredHeroLevel else { return false }
        guard !isUnlocked(node), availableGold >= node.goldCost else { return false }
        return hasPrerequisite(for: node)
    }

    @discardableResult
    mutating func unlock(_ node: RuneTreeNode, heroLevel: Int, availableGold: Int) -> Bool {
        guard canUnlock(node, heroLevel: heroLevel, availableGold: availableGold) else { return false }
        unlockedNodes.insert(node)
        return true
    }

    func directPartySlotUnlockCost(for slotIndex: Int) -> Int? {
        guard let nodes = directPartySlotNodes(for: slotIndex) else { return nil }
        let missingNodes = nodes.filter { !isUnlocked($0) }
        guard !missingNodes.isEmpty else { return nil }
        return missingNodes.reduce(0) { total, node in
            total + node.goldCost
        }
    }

    func canDirectlyUnlockPartySlot(_ slotIndex: Int, availableGold: Int) -> Bool {
        guard let cost = directPartySlotUnlockCost(for: slotIndex) else { return false }
        return availableGold >= cost
    }

    @discardableResult
    mutating func directlyUnlockPartySlot(_ slotIndex: Int, availableGold: Int) -> Int? {
        guard let nodes = directPartySlotNodes(for: slotIndex),
              let cost = directPartySlotUnlockCost(for: slotIndex),
              availableGold >= cost else {
            return nil
        }

        for node in nodes {
            unlockedNodes.insert(node)
        }
        return cost
    }

    private func directPartySlotNodes(for slotIndex: Int) -> [RuneTreeNode]? {
        switch slotIndex {
        case 1:
            return [.partySlot2]
        case 2:
            return [.partySlot2, .partySlot3]
        default:
            return nil
        }
    }

    @discardableResult
    mutating func resetUnlockedNodes() -> Int {
        let refundGold = verifiedResetRefundGold
        unlockedNodes.removeAll()
        return refundGold
    }
}
