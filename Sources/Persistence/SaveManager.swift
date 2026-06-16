import Foundation
import os

/// 存档数据
struct SaveData: Codable {
    let hero: Hero
    let party: HeroParty
    let runeTree: RuneTree
    let cubeProgress: CubeProgress
    let purchasedInventoryExpansionCount: Int
    let activeSkillLoadouts: ActiveSkillLoadouts
    let inventory: Inventory
    let progress: ProgressTracker
    let statistics: GameStatistics
    let autoEquipBestItems: Bool
    let worseEquipmentHandling: WorseEquipmentHandling
    let soundEffectsEnabled: Bool
    let unyieldingWillConsumedStageKey: String?
    let timestamp: Date

    init(
        hero: Hero,
        party: HeroParty? = nil,
        runeTree: RuneTree? = nil,
        cubeProgress: CubeProgress = CubeProgress(),
        purchasedInventoryExpansionCount: Int = 0,
        activeSkillLoadouts: ActiveSkillLoadouts = ActiveSkillLoadouts(),
        inventory: Inventory,
        progress: ProgressTracker,
        statistics: GameStatistics,
        autoEquipBestItems: Bool = false,
        worseEquipmentHandling: WorseEquipmentHandling = .keep,
        soundEffectsEnabled: Bool = true,
        unyieldingWillConsumedStageKey: String? = nil,
        timestamp: Date
    ) {
        self.hero = hero
        let resolvedRuneTree = runeTree ?? RuneTree(unlockedPartySlotCount: party?.activeCount ?? 1)
        var resolvedParty = party ?? HeroParty(
            primaryClass: hero.heroClass,
            unlockedSlotCount: resolvedRuneTree.unlockedPartySlotCount
        )
        resolvedParty.setUnlockedSlotCount(resolvedRuneTree.unlockedPartySlotCount)
        self.party = resolvedParty
        self.runeTree = resolvedRuneTree
        self.cubeProgress = cubeProgress
        self.purchasedInventoryExpansionCount = InventoryExpansion.normalizedCount(purchasedInventoryExpansionCount)
        self.activeSkillLoadouts = activeSkillLoadouts
        inventory.setMaxCapacity(InventoryExpansion.maxCapacity(
            runeTree: resolvedRuneTree,
            purchasedExpansionCount: self.purchasedInventoryExpansionCount
        ))
        self.inventory = inventory
        self.progress = progress
        self.statistics = statistics
        self.autoEquipBestItems = autoEquipBestItems
        self.worseEquipmentHandling = worseEquipmentHandling
        self.soundEffectsEnabled = soundEffectsEnabled
        self.unyieldingWillConsumedStageKey = unyieldingWillConsumedStageKey
        self.timestamp = timestamp
    }

    enum CodingKeys: String, CodingKey {
        case hero, party, runeTree, cubeProgress, purchasedInventoryExpansionCount, activeSkillLoadouts, inventory, progress, statistics, autoEquipBestItems, worseEquipmentHandling, soundEffectsEnabled, unyieldingWillConsumedStageKey, timestamp
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hero = try c.decode(Hero.self, forKey: .hero)
        let decodedParty = try c.decodeIfPresent(HeroParty.self, forKey: .party)
        runeTree = try c.decodeIfPresent(RuneTree.self, forKey: .runeTree)
            ?? RuneTree(unlockedPartySlotCount: decodedParty?.activeCount ?? 1)
        var resolvedParty = decodedParty ?? HeroParty(
            primaryClass: hero.heroClass,
            unlockedSlotCount: runeTree.unlockedPartySlotCount
        )
        resolvedParty.setUnlockedSlotCount(runeTree.unlockedPartySlotCount)
        party = resolvedParty
        cubeProgress = try c.decodeIfPresent(CubeProgress.self, forKey: .cubeProgress) ?? CubeProgress()
        purchasedInventoryExpansionCount = InventoryExpansion.normalizedCount(
            try c.decodeIfPresent(Int.self, forKey: .purchasedInventoryExpansionCount) ?? 0
        )
        activeSkillLoadouts = try c.decodeIfPresent(ActiveSkillLoadouts.self, forKey: .activeSkillLoadouts) ?? ActiveSkillLoadouts()
        inventory = try c.decode(Inventory.self, forKey: .inventory)
        inventory.setMaxCapacity(InventoryExpansion.maxCapacity(
            runeTree: runeTree,
            purchasedExpansionCount: purchasedInventoryExpansionCount
        ))
        progress = try c.decode(ProgressTracker.self, forKey: .progress)
        statistics = try c.decode(GameStatistics.self, forKey: .statistics)
        autoEquipBestItems = try c.decodeIfPresent(Bool.self, forKey: .autoEquipBestItems) ?? false
        worseEquipmentHandling = try c.decodeIfPresent(WorseEquipmentHandling.self, forKey: .worseEquipmentHandling) ?? .keep
        soundEffectsEnabled = try c.decodeIfPresent(Bool.self, forKey: .soundEffectsEnabled) ?? true
        unyieldingWillConsumedStageKey = try c.decodeIfPresent(String.self, forKey: .unyieldingWillConsumedStageKey)
        timestamp = try c.decode(Date.self, forKey: .timestamp)
    }
}

/// 存档管理器 — JSON 文件存储
class SaveManager {
    private static let logger = Logger(subsystem: "com.tbh.game", category: "SaveManager")

    private let saveURL: URL
    var lastSaveTimestamp: Date?

    /// - Parameter directory: 存档目录；默认为 Application Support/TBH。测试时注入临时目录。
    init(directory: URL? = nil) {
        let base: URL
        if let directory {
            base = directory
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            base = appSupport.appendingPathComponent("TBH", isDirectory: true)
        }
        do {
            try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        } catch {
            Self.logger.error("Create save directory failed: \(error.localizedDescription)")
        }
        saveURL = base.appendingPathComponent("save.json")
    }

    func save(_ data: SaveData) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: saveURL, options: .atomic)
            lastSaveTimestamp = data.timestamp
        } catch {
            Self.logger.error("Save failed: \(error.localizedDescription)")
        }
    }

    func load() -> SaveData? {
        guard FileManager.default.fileExists(atPath: saveURL.path) else { return nil }
        do {
            let jsonData = try Data(contentsOf: saveURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let data = try decoder.decode(SaveData.self, from: jsonData)
            lastSaveTimestamp = data.timestamp
            return data
        } catch {
            Self.logger.error("Load failed: \(error.localizedDescription)")
            return nil
        }
    }

    @discardableResult
    func deleteSave() -> Bool {
        guard FileManager.default.fileExists(atPath: saveURL.path) else {
            lastSaveTimestamp = nil
            return true
        }
        do {
            try FileManager.default.removeItem(at: saveURL)
            lastSaveTimestamp = nil
            return true
        } catch {
            Self.logger.error("Delete save failed: \(error.localizedDescription)")
            return false
        }
    }

    var saveFileExists: Bool {
        FileManager.default.fileExists(atPath: saveURL.path)
    }

    var saveFilePath: String {
        saveURL.path
    }
}
