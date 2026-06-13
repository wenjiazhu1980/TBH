import Foundation

/// 游戏统计
struct GameStatistics: Codable {
    var monstersKilled: Int = 0
    var itemsFound: Int = 0
    var totalPlayTime: TimeInterval = 0
    var offlineXP: Int = 0
    var offlineGold: Int = 0
    var highestChapter: Int = 1
    var highestDifficulty: Int = 1
    var totalGoldEarned: Int = 0
    var deaths: Int = 0

    mutating func recordVictory(rewards: BattleResult.Rewards, lootStored: Bool, chapter: Chapter, difficulty: Difficulty) {
        monstersKilled += 1
        totalGoldEarned += rewards.gold
        if lootStored {
            itemsFound += 1
        }
        highestChapter = max(highestChapter, chapter.rawValue)
        highestDifficulty = max(highestDifficulty, difficulty.rawValue)
    }

    mutating func recordDefeat() {
        deaths += 1
    }
}

/// 进度追踪
struct ProgressTracker: Codable {
    /// 每章需要的击杀数，达到后推进到下一章
    static let killsToAdvance = 25

    var currentChapterIndex: Int = 0
    var currentDifficultyIndex: Int = 0
    var chaptersCleared: [Int] = []
    var killsInChapter: Int = 0

    var currentChapter: Chapter {
        Chapter(rawValue: currentChapterIndex + 1) ?? .forest
    }

    var currentDifficulty: Difficulty {
        Difficulty(rawValue: currentDifficultyIndex + 1) ?? .normal
    }

    /// 已到达最终章 + 最高难度
    var isAtFinalContent: Bool {
        currentChapterIndex == Chapter.allCases.count - 1 &&
        currentDifficultyIndex == Difficulty.allCases.count - 1
    }

    /// 每次击杀调用：满 killsToAdvance 杀推进章节；全章通关则提升难度并重回第一章
    mutating func advance() {
        killsInChapter += 1
        guard killsInChapter >= Self.killsToAdvance else { return }

        if isAtFinalContent {
            // 终局内容：停留并封顶计数，防止数值无限增长
            killsInChapter = Self.killsToAdvance
            return
        }

        killsInChapter = 0
        if !chaptersCleared.contains(currentChapter.rawValue) {
            chaptersCleared.append(currentChapter.rawValue)
        }

        if currentChapterIndex + 1 < Chapter.allCases.count {
            currentChapterIndex += 1
        } else {
            // 当前难度全章通关 → 下一难度从第一章重新开始
            currentChapterIndex = 0
            currentDifficultyIndex += 1
            chaptersCleared.removeAll()
        }
    }
}

extension ProgressTracker {
    enum CodingKeys: String, CodingKey {
        case currentChapterIndex, currentDifficultyIndex, chaptersCleared, killsInChapter
    }

    /// 兼容旧存档：killsInChapter 字段缺失时取默认值
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        currentChapterIndex = try c.decodeIfPresent(Int.self, forKey: .currentChapterIndex) ?? 0
        currentDifficultyIndex = try c.decodeIfPresent(Int.self, forKey: .currentDifficultyIndex) ?? 0
        chaptersCleared = try c.decodeIfPresent([Int].self, forKey: .chaptersCleared) ?? []
        killsInChapter = try c.decodeIfPresent(Int.self, forKey: .killsInChapter) ?? 0
    }
}
