import Foundation
import os

/// 存档数据
struct SaveData: Codable {
    let hero: Hero
    let inventory: Inventory
    let progress: ProgressTracker
    let statistics: GameStatistics
    let autoEquipBestItems: Bool
    let timestamp: Date

    init(
        hero: Hero,
        inventory: Inventory,
        progress: ProgressTracker,
        statistics: GameStatistics,
        autoEquipBestItems: Bool = false,
        timestamp: Date
    ) {
        self.hero = hero
        self.inventory = inventory
        self.progress = progress
        self.statistics = statistics
        self.autoEquipBestItems = autoEquipBestItems
        self.timestamp = timestamp
    }

    enum CodingKeys: String, CodingKey {
        case hero, inventory, progress, statistics, autoEquipBestItems, timestamp
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hero = try c.decode(Hero.self, forKey: .hero)
        inventory = try c.decode(Inventory.self, forKey: .inventory)
        progress = try c.decode(ProgressTracker.self, forKey: .progress)
        statistics = try c.decode(GameStatistics.self, forKey: .statistics)
        autoEquipBestItems = try c.decodeIfPresent(Bool.self, forKey: .autoEquipBestItems) ?? false
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

    func deleteSave() {
        try? FileManager.default.removeItem(at: saveURL)
        lastSaveTimestamp = nil
    }
}
