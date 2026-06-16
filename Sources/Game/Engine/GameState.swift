import Foundation

/// 游戏统计
struct GameStatistics: Codable {
    var monstersKilled: Int = 0
    var itemsFound: Int = 0
    var totalPlayTime: TimeInterval = 0
    var offlineXP: Int = 0
    var offlineGold: Int = 0
    var highestChapter: Int = 1
    var highestStageCode: String = "1-1"
    var highestDifficulty: Int = 1
    var totalGoldEarned: Int = 0
    var deaths: Int = 0

    mutating func recordVictory(
        rewards: BattleResult.Rewards,
        lootStored: Bool,
        chapter: Chapter,
        difficulty: Difficulty,
        stage: StageDefinition? = nil
    ) {
        recordVictory(
            rewards: rewards,
            lootStoredCount: lootStored ? 1 : 0,
            chapter: chapter,
            difficulty: difficulty,
            stage: stage
        )
    }

    mutating func recordVictory(
        rewards: BattleResult.Rewards,
        lootStoredCount: Int,
        chapter: Chapter,
        difficulty: Difficulty,
        stage: StageDefinition? = nil
    ) {
        monstersKilled += rewards.encountersCleared
        totalGoldEarned += rewards.gold
        itemsFound += max(0, lootStoredCount)
        highestChapter = max(highestChapter, chapter.rawValue)
        highestDifficulty = max(highestDifficulty, difficulty.rawValue)
        if let stage, stageSortValue(stage.displayCode) >= stageSortValue(highestStageCode) {
            highestStageCode = stage.displayCode
        }
    }

    mutating func recordDefeat() {
        deaths += 1
    }

    private func stageSortValue(_ code: String) -> Int {
        let parts = code.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 2 else { return 0 }
        return parts[0] * 100 + parts[1]
    }
}

extension GameStatistics {
    enum CodingKeys: String, CodingKey {
        case monstersKilled, itemsFound, totalPlayTime, offlineXP, offlineGold
        case highestChapter, highestStageCode, highestDifficulty, totalGoldEarned, deaths
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        monstersKilled = try c.decodeIfPresent(Int.self, forKey: .monstersKilled) ?? 0
        itemsFound = try c.decodeIfPresent(Int.self, forKey: .itemsFound) ?? 0
        totalPlayTime = try c.decodeIfPresent(TimeInterval.self, forKey: .totalPlayTime) ?? 0
        offlineXP = try c.decodeIfPresent(Int.self, forKey: .offlineXP) ?? 0
        offlineGold = try c.decodeIfPresent(Int.self, forKey: .offlineGold) ?? 0
        highestChapter = try c.decodeIfPresent(Int.self, forKey: .highestChapter) ?? 1
        highestStageCode = try c.decodeIfPresent(String.self, forKey: .highestStageCode) ?? "1-1"
        highestDifficulty = try c.decodeIfPresent(Int.self, forKey: .highestDifficulty) ?? 1
        totalGoldEarned = try c.decodeIfPresent(Int.self, forKey: .totalGoldEarned) ?? 0
        deaths = try c.decodeIfPresent(Int.self, forKey: .deaths) ?? 0
    }
}

/// 进度追踪
struct ProgressTracker: Codable {
    /// 当前实现以清怪次数推进非 Boss 关，Boss 关清一次即推进。
    static let killsToAdvance = StageDefinition.defaultClearsPerStage
    static let stagesPerAct = StageDefinition.stagesPerAct

    var currentChapterIndex: Int = 0
    var currentStageIndex: Int = 0
    var currentDifficultyIndex: Int = 0
    var soulStones = SoulStoneInventory()
    var chests = ChestInventory()
    var chaptersCleared: [Int] = []
    var stagesCleared: [String] = []
    var killsInChapter: Int = 0
    var highestUnlockedChapterIndex: Int = 0
    var highestUnlockedStageIndex: Int = 0
    var highestUnlockedDifficultyIndex: Int = 0
    var playthrough: Int = 1
    var completedPlaythroughs: Int = 0
    var isAwaitingNewGamePlus: Bool = false

    var currentChapter: Chapter {
        Chapter(rawValue: currentChapterIndex + 1) ?? .forest
    }

    var currentStage: StageDefinition {
        StageDefinition.stage(act: currentChapter, number: currentStageIndex + 1)
    }

    var currentDifficulty: Difficulty {
        Difficulty(rawValue: currentDifficultyIndex + 1) ?? .normal
    }

    var highestUnlockedStage: StageDefinition {
        StageDefinition.stage(
            act: Chapter(rawValue: highestUnlockedChapterIndex + 1) ?? .forest,
            number: highestUnlockedStageIndex + 1
        )
    }

    var highestUnlockedDifficulty: Difficulty {
        Difficulty(rawValue: highestUnlockedDifficultyIndex + 1) ?? .normal
    }

    var highestUnlockedStageText: String {
        "\(highestUnlockedDifficulty.name) \(highestUnlockedStage.displayName)"
    }

    var playthroughText: String {
        playthrough <= 1 ? "一周目" : "第 \(playthrough) 周目"
    }

    var nextPlaythroughText: String {
        "第 \(playthrough + 1) 周目"
    }

    var newGamePlusEnemyMultiplier: Double {
        NewGamePlusTuning.enemyStatMultiplier(for: playthrough)
    }

    var newGamePlusRewardMultiplier: Double {
        NewGamePlusTuning.rewardMultiplier(for: playthrough)
    }

    var currentStageSelectionID: String {
        StageSelectionOption.id(difficulty: currentDifficulty, stage: currentStage)
    }

    var stageProgressText: String {
        let target = currentStage.clearTarget(for: currentDifficulty)
        return "\(min(killsInChapter, target))/\(target)"
    }

    var currentEncounterState: StageEncounterState {
        currentStage.encounterState(for: currentDifficulty, encounterIndex: killsInChapter)
    }

    var currentEncounterPlan: StageEncounterPlan {
        currentStage.encounterPlan(for: currentDifficulty)
    }

    var waveProgressText: String {
        let state = currentEncounterState
        return "\(state.wave)/\(state.waveCount)"
    }

    var waveEncounterProgressText: String {
        let state = currentEncounterState
        return "\(state.waveEncounterNumber)/\(state.waveEncounterTarget)"
    }

    var currentEncounterText: String {
        let state = currentEncounterState
        return "\(state.encounterNumber)/\(state.clearTarget)"
    }

    var requiredSoulStone: SoulStoneKind? {
        currentStage.requiredSoulStone(for: currentDifficulty)
    }

    var canChallengeCurrentStage: Bool {
        guard let requiredSoulStone else { return true }
        return soulStones.count(for: requiredSoulStone) > 0
    }

    var stageLockReason: String? {
        guard let requiredSoulStone, !canChallengeCurrentStage else { return nil }
        return "\(currentStage.displayCode) Boss 需要 \(requiredSoulStone.displayName)"
    }

    var unlockedStageSelections: [StageSelectionOption] {
        var selections: [StageSelectionOption] = []
        for difficulty in Difficulty.allCases {
            for chapter in Chapter.allCases {
                for stageNumber in 1...Self.stagesPerAct {
                    guard canSelectStage(
                        difficulty: difficulty,
                        chapter: chapter,
                        stageNumber: stageNumber
                    ) else {
                        continue
                    }
                    selections.append(
                        StageSelectionOption(
                            difficulty: difficulty,
                            chapter: chapter,
                            stageNumber: stageNumber
                        )
                    )
                }
            }
        }
        return selections
    }

    /// 已到达最终章 + 最高难度
    var isAtFinalContent: Bool {
        currentChapterIndex == Chapter.allCases.count - 1 &&
        currentStageIndex == Self.stagesPerAct - 1 &&
        currentDifficultyIndex == Difficulty.allCases.count - 1
    }

    /// 每次胜利调用：清完当前关推进到下一关；全 Act 通关后进入下一 Act；全难度通关后封顶。
    @discardableResult
    mutating func advance(chestStorageLimits: ChestStorageLimits = .unlimited) -> Bool {
        guard !isAwaitingNewGamePlus else { return false }
        killsInChapter += 1
        let clearedStage = currentStage
        let clearTarget = clearedStage.clearTarget(for: currentDifficulty)
        guard killsInChapter >= clearTarget else { return false }

        if let required = clearedStage.requiredSoulStone(for: currentDifficulty) {
            guard soulStones.consume(required) else {
                killsInChapter = max(clearTarget - 1, 0)
                return false
            }
        }

        recordClearedStage(clearedStage)
        for chest in clearedStage.chestRewards(for: currentDifficulty) {
            chests.add(chest, limits: chestStorageLimits)
        }

        if isAtFinalContent {
            // 终局内容：停留在结算页，等待玩家选择是否开启下一周目。
            killsInChapter = clearTarget
            isAwaitingNewGamePlus = true
            completedPlaythroughs = max(completedPlaythroughs, playthrough)
            updateHighestUnlockedIfNeeded()
            return true
        }

        killsInChapter = 0
        if currentStageIndex + 1 < Self.stagesPerAct {
            currentStageIndex += 1
        } else if currentChapterIndex + 1 < Chapter.allCases.count {
            currentChapterIndex += 1
            currentStageIndex = 0
        } else {
            // 当前难度全 Act 通关 → 下一难度从第一关重新开始
            currentChapterIndex = 0
            currentStageIndex = 0
            currentDifficultyIndex += 1
            chaptersCleared.removeAll()
            stagesCleared.removeAll()
        }

        updateHighestUnlockedIfNeeded()
        return true
    }

    @discardableResult
    mutating func startNextPlaythrough() -> Bool {
        guard isAwaitingNewGamePlus else { return false }

        completedPlaythroughs = max(completedPlaythroughs, playthrough)
        playthrough += 1
        isAwaitingNewGamePlus = false
        currentDifficultyIndex = 0
        currentChapterIndex = 0
        currentStageIndex = 0
        highestUnlockedDifficultyIndex = 0
        highestUnlockedChapterIndex = 0
        highestUnlockedStageIndex = 0
        killsInChapter = 0
        chaptersCleared.removeAll()
        stagesCleared.removeAll()
        return true
    }

    @discardableResult
    mutating func advance(by encountersCleared: Int, chestStorageLimits: ChestStorageLimits = .unlimited) -> Bool {
        guard encountersCleared > 0 else { return false }
        var clearedAnyStage = false
        for _ in 0..<encountersCleared {
            clearedAnyStage = advance(chestStorageLimits: chestStorageLimits) || clearedAnyStage
        }
        return clearedAnyStage
    }

    @discardableResult
    mutating func openChest(kind: ChestKind) -> LootChest? {
        guard let chest = chests.removeFirst(kind: kind) else { return nil }
        soulStones.grant(chest.soulStoneDrop)
        return chest
    }

    @discardableResult
    mutating func openChest(family: ChestFamily) -> LootChest? {
        guard let chest = chests.removeFirst(family: family) else { return nil }
        soulStones.grant(chest.soulStoneDrop)
        return chest
    }

    @discardableResult
    mutating func openChest(id: String) -> LootChest? {
        guard let chest = chests.remove(id: id) else { return nil }
        soulStones.grant(chest.soulStoneDrop)
        return chest
    }

    func canSelectStage(
        difficulty: Difficulty,
        chapter: Chapter,
        stageNumber: Int
    ) -> Bool {
        guard let indices = Self.indices(
            difficulty: difficulty,
            chapter: chapter,
            stageNumber: stageNumber
        ) else {
            return false
        }

        return Self.sortValue(
            difficultyIndex: indices.difficultyIndex,
            chapterIndex: indices.chapterIndex,
            stageIndex: indices.stageIndex
        ) <= highestUnlockedSortValue
    }

    @discardableResult
    mutating func selectStage(_ selection: StageSelectionOption) -> Bool {
        selectStage(
            difficulty: selection.difficulty,
            chapter: selection.chapter,
            stageNumber: selection.stageNumber
        )
    }

    @discardableResult
    mutating func selectStage(
        difficulty: Difficulty,
        chapter: Chapter,
        stageNumber: Int
    ) -> Bool {
        guard canSelectStage(
            difficulty: difficulty,
            chapter: chapter,
            stageNumber: stageNumber
        ),
              let indices = Self.indices(
                difficulty: difficulty,
                chapter: chapter,
                stageNumber: stageNumber
              ) else {
            return false
        }

        currentDifficultyIndex = indices.difficultyIndex
        currentChapterIndex = indices.chapterIndex
        currentStageIndex = indices.stageIndex
        killsInChapter = 0
        return true
    }

    mutating func restartCurrentStage() {
        guard !isAwaitingNewGamePlus else { return }
        killsInChapter = 0
    }

    private mutating func recordClearedStage(_ stage: StageDefinition) {
        let key = "\(currentDifficulty.rawValue)-\(stage.displayCode)"
        if !stagesCleared.contains(key) {
            stagesCleared.append(key)
        }
        if stage.isBoss && !chaptersCleared.contains(stage.act.rawValue) {
            chaptersCleared.append(stage.act.rawValue)
        }
    }

    private var currentSortValue: Int {
        Self.sortValue(
            difficultyIndex: currentDifficultyIndex,
            chapterIndex: currentChapterIndex,
            stageIndex: currentStageIndex
        )
    }

    private var highestUnlockedSortValue: Int {
        Self.sortValue(
            difficultyIndex: highestUnlockedDifficultyIndex,
            chapterIndex: highestUnlockedChapterIndex,
            stageIndex: highestUnlockedStageIndex
        )
    }

    private mutating func updateHighestUnlockedIfNeeded() {
        guard currentSortValue > highestUnlockedSortValue else { return }
        highestUnlockedDifficultyIndex = currentDifficultyIndex
        highestUnlockedChapterIndex = currentChapterIndex
        highestUnlockedStageIndex = currentStageIndex
    }

    private static func indices(
        difficulty: Difficulty,
        chapter: Chapter,
        stageNumber: Int
    ) -> (difficultyIndex: Int, chapterIndex: Int, stageIndex: Int)? {
        guard (1...Self.stagesPerAct).contains(stageNumber) else { return nil }
        return (
            difficulty.rawValue - 1,
            chapter.rawValue - 1,
            stageNumber - 1
        )
    }

    private static func sortValue(
        difficultyIndex: Int,
        chapterIndex: Int,
        stageIndex: Int
    ) -> Int {
        difficultyIndex * Chapter.allCases.count * Self.stagesPerAct +
            chapterIndex * Self.stagesPerAct +
            stageIndex
    }
}

extension ProgressTracker {
    enum CodingKeys: String, CodingKey {
        case currentChapterIndex, currentStageIndex, currentDifficultyIndex
        case soulStones, chests, chaptersCleared, stagesCleared, killsInChapter
        case highestUnlockedChapterIndex, highestUnlockedStageIndex, highestUnlockedDifficultyIndex
        case playthrough, completedPlaythroughs, isAwaitingNewGamePlus
    }

    /// 兼容旧存档：currentStageIndex / stagesCleared / killsInChapter / high-water 字段缺失时取默认值。
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        currentChapterIndex = Self.clamp(
            try c.decodeIfPresent(Int.self, forKey: .currentChapterIndex) ?? 0,
            upperBound: Chapter.allCases.count - 1
        )
        currentStageIndex = Self.clamp(
            try c.decodeIfPresent(Int.self, forKey: .currentStageIndex) ?? 0,
            upperBound: Self.stagesPerAct - 1
        )
        currentDifficultyIndex = Self.clamp(
            try c.decodeIfPresent(Int.self, forKey: .currentDifficultyIndex) ?? 0,
            upperBound: Difficulty.allCases.count - 1
        )
        soulStones = try c.decodeIfPresent(SoulStoneInventory.self, forKey: .soulStones) ?? SoulStoneInventory()
        chests = try c.decodeIfPresent(ChestInventory.self, forKey: .chests) ?? ChestInventory()
        chaptersCleared = try c.decodeIfPresent([Int].self, forKey: .chaptersCleared) ?? []
        stagesCleared = try c.decodeIfPresent([String].self, forKey: .stagesCleared) ?? []
        killsInChapter = max(0, try c.decodeIfPresent(Int.self, forKey: .killsInChapter) ?? 0)
        highestUnlockedChapterIndex = Self.clamp(
            try c.decodeIfPresent(Int.self, forKey: .highestUnlockedChapterIndex) ?? currentChapterIndex,
            upperBound: Chapter.allCases.count - 1
        )
        highestUnlockedStageIndex = Self.clamp(
            try c.decodeIfPresent(Int.self, forKey: .highestUnlockedStageIndex) ?? currentStageIndex,
            upperBound: Self.stagesPerAct - 1
        )
        highestUnlockedDifficultyIndex = Self.clamp(
            try c.decodeIfPresent(Int.self, forKey: .highestUnlockedDifficultyIndex) ?? currentDifficultyIndex,
            upperBound: Difficulty.allCases.count - 1
        )
        playthrough = max(1, try c.decodeIfPresent(Int.self, forKey: .playthrough) ?? 1)
        completedPlaythroughs = max(0, try c.decodeIfPresent(Int.self, forKey: .completedPlaythroughs) ?? 0)
        isAwaitingNewGamePlus = try c.decodeIfPresent(Bool.self, forKey: .isAwaitingNewGamePlus) ?? false
        updateHighestUnlockedIfNeeded()
    }

    private static func clamp(_ value: Int, upperBound: Int) -> Int {
        min(max(value, 0), upperBound)
    }
}

enum NewGamePlusTuning {
    static func completedCycles(before playthrough: Int) -> Int {
        max(0, playthrough - 1)
    }

    static func enemyStatMultiplier(for playthrough: Int) -> Double {
        1.0 + Double(completedCycles(before: playthrough)) * 0.35
    }

    static func rewardMultiplier(for playthrough: Int) -> Double {
        1.0 + Double(completedCycles(before: playthrough)) * 0.25
    }
}

struct StageSelectionOption: Identifiable, Equatable {
    let difficulty: Difficulty
    let chapter: Chapter
    let stageNumber: Int

    var id: String {
        Self.id(difficulty: difficulty, stage: stage)
    }

    var stage: StageDefinition {
        StageDefinition.stage(act: chapter, number: stageNumber)
    }

    var menuLabel: String {
        "\(difficulty.name) \(stage.displayName)"
    }

    static func id(difficulty: Difficulty, stage: StageDefinition) -> String {
        "\(difficulty.rawValue)-\(stage.displayCode)"
    }
}
