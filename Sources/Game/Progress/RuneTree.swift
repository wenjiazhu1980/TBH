import Foundation

enum RuneTreeNode: String, CaseIterable, Codable, Identifiable {
    case partySlot2
    case partySlot3
    case activeSkillSlot2
    case inventoryExpansion1
    case openOneChestType
    case openAllChestTypes
    case offlineRewards
    case offlineGoldBoost
    case offlineXPBoost

    var id: String { rawValue }

    var sourceRuneID: String {
        switch self {
        case .partySlot2: return "21"
        case .partySlot3: return "24"
        case .activeSkillSlot2: return "27"
        case .inventoryExpansion1: return "22"
        case .openOneChestType: return "1021"
        case .openAllChestTypes: return "1055"
        case .offlineRewards: return "11001"
        case .offlineGoldBoost: return "110011"
        case .offlineXPBoost: return "110012"
        }
    }

    var displayName: String {
        switch self {
        case .partySlot2: return "指挥符文：第 2 编队位"
        case .partySlot3: return "指挥符文：第 3 编队位"
        case .activeSkillSlot2: return "觉醒符文：第 2 主动技能槽"
        case .inventoryExpansion1: return "扩张符文：背包容量 +10"
        case .openOneChestType: return "开启符文：同类箱子全部开启"
        case .openAllChestTypes: return "开启符文：全部箱子一键开启"
        case .offlineRewards: return "安息符文：离线奖励"
        case .offlineGoldBoost: return "储藏符文：离线金币 +10%"
        case .offlineXPBoost: return "训练符文：离线经验 +10%"
        }
    }

    var goldCost: Int {
        switch self {
        case .partySlot2: return 50_000
        case .partySlot3: return 150_000
        case .activeSkillSlot2, .inventoryExpansion1, .openOneChestType, .openAllChestTypes, .offlineRewards, .offlineGoldBoost, .offlineXPBoost: return 0
        }
    }

    var hasVerifiedGoldCost: Bool {
        switch self {
        case .partySlot2, .partySlot3:
            return true
        case .activeSkillSlot2, .inventoryExpansion1, .openOneChestType, .openAllChestTypes, .offlineRewards, .offlineGoldBoost, .offlineXPBoost:
            return false
        }
    }

    var approximateGoldCost: Int? {
        switch self {
        case .activeSkillSlot2:
            return 50_000
        case .partySlot2, .partySlot3, .inventoryExpansion1, .openOneChestType, .openAllChestTypes, .offlineRewards, .offlineGoldBoost, .offlineXPBoost:
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
        case .partySlot2, .activeSkillSlot2, .openOneChestType, .offlineRewards: return nil
        case .partySlot3, .inventoryExpansion1: return .partySlot2
        case .openAllChestTypes: return .openOneChestType
        case .offlineGoldBoost, .offlineXPBoost: return .offlineRewards
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
    static let inventoryExpansionSlotBonus = 10

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

    var inventoryCapacity: Int {
        Inventory.baseCapacity
            + (isUnlocked(.inventoryExpansion1) ? Self.inventoryExpansionSlotBonus : 0)
    }

    var canOpenOneChestTypeAtOnce: Bool {
        isUnlocked(.openOneChestType)
    }

    var canOpenAllChestTypesAtOnce: Bool {
        isUnlocked(.openAllChestTypes)
    }

    var offlineRewardsUnlocked: Bool {
        isUnlocked(.offlineRewards)
    }

    var offlineGoldMultiplier: Double {
        isUnlocked(.offlineGoldBoost) ? 1.10 : 1.0
    }

    var offlineXPMultiplier: Double {
        isUnlocked(.offlineXPBoost) ? 1.10 : 1.0
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
