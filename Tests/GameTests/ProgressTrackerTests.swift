import Foundation
import Testing
@testable import TBH

@Suite struct ProgressTrackerTests {
    @Test func advanceCountsKills() {
        var tracker = ProgressTracker()
        tracker.advance()
        #expect(tracker.killsInChapter == 1)
        #expect(tracker.currentStage.displayCode == "1-1", "Single kill should not advance stage")
    }

    @Test func advanceToNextStageAfterEnoughClears() {
        var tracker = ProgressTracker()
        for _ in 0..<ProgressTracker.killsToAdvance {
            tracker.advance()
        }
        #expect(tracker.currentStage.displayCode == "1-2", "Should advance to stage 1-2")
        #expect(tracker.killsInChapter == 0, "Kill counter should reset")
        #expect(tracker.stagesCleared.contains("1-1-1"))
        #expect(tracker.highestUnlockedStage.displayCode == "1-2")
        #expect(tracker.unlockedStageSelections.map(\.id) == ["1-1-1", "1-1-2"])
    }

    @Test func selectUnlockedStagePreservesHighWaterProgress() {
        var tracker = ProgressTracker()
        for _ in 0..<ProgressTracker.killsToAdvance {
            tracker.advance()
        }

        #expect(tracker.selectStage(difficulty: .normal, chapter: .forest, stageNumber: 1))
        #expect(tracker.currentStage.displayCode == "1-1")
        #expect(tracker.highestUnlockedStage.displayCode == "1-2")
        #expect(tracker.canSelectStage(difficulty: .normal, chapter: .forest, stageNumber: 2))
        #expect(!tracker.selectStage(difficulty: .normal, chapter: .forest, stageNumber: 3))
        #expect(tracker.currentStage.displayCode == "1-1")
    }

    @Test func restartCurrentStageResetsEncounterProgress() {
        var tracker = ProgressTracker()
        tracker.advance()
        #expect(tracker.killsInChapter == 1)

        tracker.restartCurrentStage()

        #expect(tracker.killsInChapter == 0)
        #expect(tracker.currentStage.displayCode == "1-1")
    }

    @Test func advanceByWaveSizedEncounterCountClearsStage() {
        var tracker = ProgressTracker()
        tracker.currentStageIndex = 7
        tracker.killsInChapter = 72

        let cleared = tracker.advance(by: 6)

        #expect(cleared)
        #expect(tracker.currentStage.displayCode == "1-9")
        #expect(tracker.killsInChapter == 0)
    }

    @Test func advanceToNextActAfterAllStagesInAct() {
        var tracker = ProgressTracker()
        for _ in 0..<StageDefinition.stagesPerAct {
            clearCurrentStage(&tracker)
        }
        #expect(tracker.currentChapter == .dungeon, "Should advance to Act 2")
        #expect(tracker.currentStage.displayCode == "2-1", "Should restart from first stage in next act")
        #expect(tracker.chaptersCleared.contains(Chapter.forest.rawValue))
    }

    @Test func preBossStageGrantsChestAndOpeningChestGrantsSoulStone() {
        var tracker = ProgressTracker()
        tracker.currentStageIndex = 8
        clearCurrentStage(&tracker, openChests: false)

        #expect(tracker.currentStage.displayCode == "1-10")
        #expect(tracker.chests.count(for: .normal) == 2)
        #expect(tracker.soulStones.count(for: .normal) == 0)
        #expect(!tracker.canChallengeCurrentStage)

        let stageBossID = tracker.chests.chests.first { $0.family == .stageBoss }?.id
        let stageBossChest = stageBossID.flatMap { tracker.openChest(id: $0) }
        #expect(stageBossChest?.sourceStageCode == "1-9")
        #expect(stageBossChest?.displayName == "Stage Boss Box 6")
        #expect(stageBossChest?.databaseID == 920_022)
        #expect(stageBossChest?.rarity == .rare)
        #expect(tracker.soulStones.count(for: .normal) == 1)

        let chest = tracker.openChest(kind: .normal)
        #expect(chest?.sourceStageCode == "1-9")
        #expect(chest?.displayName == "Normal Monster Box 3")
        #expect(chest?.databaseID == 910_101)
        #expect(chest?.rarity == .common)
        #expect(tracker.soulStones.count(for: .normal) == 2)
        #expect(tracker.canChallengeCurrentStage)
    }

    @Test func chestCatalogMetadataMatchesItemDatabase() {
        let normalChest = LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-9", sourceDifficulty: .normal, family: .normalMonster, catalogLevel: 10)
        let stageBossLevel10 = LootChest(kind: .normal, itemLevel: 10, sourceStageCode: "1-8", sourceDifficulty: .normal, family: .stageBoss)
        let actBossChest = LootChest(kind: .normal, itemLevel: 30, sourceStageCode: "3-10", sourceDifficulty: .normal, family: .actBoss, catalogLevel: 30)

        #expect(normalChest.displayName == "Normal Monster Box 3")
        #expect(normalChest.databaseID == 910_101)
        #expect(normalChest.rarity == .common)
        #expect(stageBossLevel10.displayName == "Stage Boss Box 6")
        #expect(stageBossLevel10.databaseID == 920_022)
        #expect(stageBossLevel10.rarity == .rare)
        let itemPageOnlyStageBossIDs = [920_004, 920_005, 920_006, 920_032, 920_042, 920_051, 920_052, 920_101]
        #expect(ChestCatalog.entryCount == 59)
        #expect(itemPageOnlyStageBossIDs.allSatisfy(ChestCatalog.contains(databaseID:)))
        #expect(actBossChest.displayName == "Act Boss Box Lv30")
        #expect(actBossChest.databaseID == 930_301)
        #expect(actBossChest.rarity == .legendary)
    }

    @Test func stageChestSourcesMatchDropsToolMapping() {
        let firstStageSources = StageDefinition.stage(act: .forest, number: 1)
            .chestSources(for: .normal)
            .map { "\($0.displayName) #\($0.databaseID)" }
        let preBossSources = StageDefinition.stage(act: .forest, number: 9)
            .chestSources(for: .normal)
            .map { "\($0.displayName) #\($0.databaseID)" }
        let actBossSources = StageDefinition.stage(act: .forest, number: 10)
            .chestSources(for: .normal)
            .map { "\($0.displayName) #\($0.databaseID)" }
        let finalBossSources = StageDefinition.stage(act: .volcano, number: 10)
            .chestSources(for: .torment)
            .map { "\($0.displayName) #\($0.databaseID)" }

        #expect(firstStageSources == ["Normal Monster Box 1 #910011", "Stage Boss Box 1 #920001"])
        #expect(preBossSources == ["Normal Monster Box 3 #910101", "Stage Boss Box 6 #920022"])
        #expect(actBossSources == ["Normal Monster Box 3 #910101", "Act Boss Box 1 #930101"])
        #expect(finalBossSources == ["Normal Monster Box Lv90 #910901", "Act Boss Box Lv90 #930901"])
    }

    @Test func soulStoneMetadataMatchesItemDatabase() {
        #expect(SoulStoneKind.allCases.map(\.materialID) == [190_001, 190_002, 190_003, 190_004])
        #expect(SoulStoneKind.allCases.map(\.rarity) == [.immortal, .arcana, .beyond, .celestial])
        #expect(SoulStoneKind.torment.displayName == "灵魂石 - 折磨")
    }

    @Test func chestSoulStoneTypeFollowsDifficultyBucketNotItemLevel() {
        let highLevelNormalChest = LootChest(kind: .normal, itemLevel: 50, sourceStageCode: "test", sourceDifficulty: .normal)
        let highLevelNightmareChest = LootChest(kind: .nightmare, itemLevel: 50, sourceStageCode: "test", sourceDifficulty: .nightmare)

        #expect(highLevelNormalChest.soulStoneDrop == .normal)
        #expect(highLevelNightmareChest.soulStoneDrop == .nightmare)
    }

    @Test func bossRequiresSoulStoneAndConsumesItOnClear() {
        var tracker = ProgressTracker()
        tracker.currentStageIndex = 9

        #expect(tracker.currentStage.isBoss)
        #expect(!tracker.canChallengeCurrentStage)
        #expect(tracker.stageLockReason?.contains("灵魂石") == true)

        tracker.soulStones.grant(.normal)
        #expect(tracker.canChallengeCurrentStage)

        let cleared = tracker.advance()
        #expect(cleared)
        #expect(tracker.soulStones.count(for: .normal) == 0)
        #expect(tracker.currentStage.displayCode == "2-1")
        #expect(tracker.chests.count(for: .normal) == 2)

        let normalChest = tracker.openChest(kind: .normal)
        let actBossChest = tracker.openChest(kind: .normal)
        #expect(normalChest?.displayName == "Normal Monster Box 3")
        #expect(actBossChest?.displayName == "Act Boss Box 1")
        #expect(actBossChest?.databaseID == 930_101)
    }

    @Test func advanceToNextDifficultyAfterAllStages() {
        var tracker = ProgressTracker()
        for _ in 0..<StageDefinition.all.count {
            clearCurrentStage(&tracker)
        }
        #expect(tracker.currentDifficulty == .nightmare, "Should advance to nightmare difficulty")
        #expect(tracker.currentChapter == .forest, "Should restart from chapter 1")
        #expect(tracker.currentStage.displayCode == "1-1", "Should restart from stage 1-1")
        #expect(tracker.chaptersCleared.isEmpty, "Cleared chapters reset for new difficulty")
    }

    @Test func progressCapsAtMaxDifficulty() {
        var tracker = ProgressTracker()
        // 推进到远超全部内容的通关数
        for _ in 0..<(StageDefinition.all.count * Difficulty.allCases.count * 2) {
            clearCurrentStage(&tracker)
        }
        #expect(tracker.currentDifficulty == .torment, "Should cap at torment difficulty")
        #expect(tracker.currentChapter == .volcano, "Should cap at final act")
        #expect(tracker.currentStage.displayCode == "3-10", "Should cap at final stage")
    }

    @Test func decodesLegacySaveWithoutKillCounter() throws {
        // 旧存档没有 currentStageIndex / killsInChapter 字段，必须能解码
        let legacyJSON = #"{"currentChapterIndex":1,"currentDifficultyIndex":0,"chaptersCleared":[1]}"#
        let data = Data(legacyJSON.utf8)
        let tracker = try JSONDecoder().decode(ProgressTracker.self, from: data)
        #expect(tracker.currentChapter == .dungeon)
        #expect(tracker.currentStage.displayCode == "2-1")
        #expect(tracker.killsInChapter == 0)
    }

    @Test func stageCatalogMatchesOriginalScaffold() {
        #expect(StageDefinition.all.count == 30)
        #expect(StageDefinition.runtimeDataCount == 120)
        #expect(StageDefinition.all.filter(\.isBoss).map(\.displayCode) == ["1-10", "2-10", "3-10"])
        #expect(Difficulty.allCases.map(\.name) == ["普通", "噩梦", "地狱", "苦痛"])
        #expect(StageDefinition.stage(act: .forest, number: 2).clearTarget(for: .normal) == 22)
        #expect(StageDefinition.stage(act: .forest, number: 1).clearTarget(for: .nightmare) == 200)
    }

    @Test func stageMonsterCompositionMatchesDropsToolMapping() {
        let firstStageRuntime = StageDefinition.stage(act: .forest, number: 1).runtimeData(for: .normal)
        let graveyardRuntime = StageDefinition.stage(act: .forest, number: 8).runtimeData(for: .normal)
        let finalBossRuntime = StageDefinition.stage(act: .volcano, number: 10).runtimeData(for: .torment)

        #expect(firstStageRuntime.monsterComposition == [
            StageMonsterSpawn(name: "哥布林盗贼", count: 1, isStageLeader: true),
            StageMonsterSpawn(name: "史莱姆", count: 5, isStageLeader: false),
            StageMonsterSpawn(name: "哥布林", count: 5, isStageLeader: false)
        ])
        #expect(graveyardRuntime.monsterComposition.map(\.name) == ["蝙蝠", "骷髅", "骷髅弓箭手", "骷髅战士"])
        #expect(graveyardRuntime.monsterComposition.map(\.count) == [24, 24, 17, 12])
        #expect(finalBossRuntime.monsterComposition == [
            StageMonsterSpawn(name: "执政官莫尔卡", count: 1, isStageLeader: true)
        ])
    }

    @Test func stageCompositionMonsterArtAvoidsSlimeFallback() {
        var sampledCompositionNames = Set<String>()
        var slimeFallbacks: [String] = []

        for stage in StageDefinition.all {
            for difficulty in Difficulty.allCases {
                let target = stage.clearTarget(for: difficulty)
                for encounterIndex in 0..<target {
                    let monster = stage.spawnMonster(difficulty: difficulty, encounterIndex: encounterIndex)
                    let spriteName = GameArt.battleMonsterSpriteName(for: monster.id)
                    sampledCompositionNames.insert(monster.name)

                    if monster.name != "史莱姆" && (monster.id == "slime_green" || spriteName == "monster_slime_red" || spriteName == "official_monster_slime") {
                        slimeFallbacks.append("\(stage.displayCode) \(difficulty.name) \(monster.name)")
                    }
                }
            }
        }

        #expect(sampledCompositionNames.count == 49)
        #expect(slimeFallbacks.isEmpty, "Non-slime composition monsters should not use slime art fallback: \(slimeFallbacks.sorted().joined(separator: ", "))")
    }

    @Test func stageSpawnUsesMinedRuntimeData() {
        let monster = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal)
        #expect(monster.name == "哥布林盗贼")
        #expect(monster.id == "assassin_goblin")
        #expect(GameArt.battleMonsterSpriteName(for: monster.id) == "stage_monster_assassin_goblin")
        #expect(monster.hp == 470)
        #expect(monster.goldReward == 140)
        #expect(monster.xpReward == 155)
        #expect(monster.itemLevelCap == 1)

        let firstStageSecondEncounter = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal, encounterIndex: 1)
        let firstStageSeventhEncounter = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal, encounterIndex: 6)
        let firstStageOverflowEncounter = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal, encounterIndex: 99)
        let firstStageOpeningState = StageDefinition.stage(act: .forest, number: 1).encounterState(for: .normal, encounterIndex: 0)
        let firstStageFinalState = StageDefinition.stage(act: .forest, number: 1).encounterState(for: .normal, encounterIndex: 9)
        #expect(firstStageSecondEncounter.name == "史莱姆")
        #expect(firstStageSeventhEncounter.name == "哥布林")
        #expect(firstStageOverflowEncounter.name == "哥布林")
        #expect(firstStageOpeningState.wave == 1)
        #expect(firstStageOpeningState.waveCount == 10)
        #expect(firstStageOpeningState.encounterNumber == 1)
        #expect(firstStageOpeningState.waveEncounterNumber == 1)
        #expect(firstStageOpeningState.waveEncounterTarget == 1)
        #expect(firstStageFinalState.wave == 10)
        #expect(firstStageFinalState.encounterNumber == 10)
        #expect(firstStageFinalState.waveEncounterNumber == 1)

        let graveyardPlan = StageDefinition.stage(act: .forest, number: 8).encounterPlan(for: .normal)
        #expect(graveyardPlan.clearTarget == 78)
        #expect(graveyardPlan.waveCount == 13)
        #expect(graveyardPlan.encounters.count == 78)
        #expect(graveyardPlan.encounters(inWave: 13).count == 6)

        let curseStageScaledEncounter = StageDefinition.stage(act: .forest, number: 9).encounterState(for: .normal, encounterIndex: 70)
        #expect(curseStageScaledEncounter.clearTarget == 91)
        #expect(curseStageScaledEncounter.compositionTotal == 70)
        #expect(curseStageScaledEncounter.wave == 11)
        #expect(curseStageScaledEncounter.waveEncounterNumber == 1)
        #expect(curseStageScaledEncounter.waveEncounterTarget == 7)
        #expect(curseStageScaledEncounter.monsterSpawn.name == "骷髅")

        let boss = StageDefinition.stage(act: .volcano, number: 10).spawnMonster(difficulty: .torment)
        #expect(boss.name == "执政官莫尔卡")
        #expect(GameArt.battleMonsterSpriteName(for: boss.id) == "stage_monster_voidcaller")
        #expect(boss.hp == 3550)
        #expect(boss.goldReward == 198_300)
    }

    @Test func monsterItemLevelCapsFollowStageThresholds() {
        let firstMonster = StageDefinition.stage(act: .forest, number: 1).spawnMonster(difficulty: .normal)
        #expect(firstMonster.itemLevelCap == 1)
        #expect(LootTable.itemLevel(for: firstMonster) == 1)

        let graveyardMonster = StageDefinition.stage(act: .forest, number: 8).spawnMonster(difficulty: .normal)
        #expect(graveyardMonster.name == "蝙蝠")
        #expect(graveyardMonster.hp == 3_235)
        #expect(graveyardMonster.itemLevelCap == 10)
        #expect(LootTable.itemLevel(for: graveyardMonster) == 10)

        let nightmareMonster = StageDefinition.stage(act: .volcano, number: 9).spawnMonster(difficulty: .nightmare)
        #expect(nightmareMonster.itemLevelCap == 50)
        #expect(LootTable.itemLevel(for: nightmareMonster) == 50)

        let tormentMonster = StageDefinition.stage(act: .volcano, number: 9).spawnMonster(difficulty: .torment)
        #expect(tormentMonster.hp == 53_215)
        #expect(tormentMonster.xpReward / 35 > 1_000_000)
        #expect(LootTable.itemLevel(for: tormentMonster) == 50)
    }

    private func clearCurrentStage(_ tracker: inout ProgressTracker, openChests: Bool = true) {
        let difficulty = tracker.currentDifficulty
        let target = tracker.currentStage.clearTarget(for: difficulty)
        for _ in 0..<target {
            tracker.advance()
        }
        if openChests {
            while tracker.openChest(kind: ChestKind(difficulty: difficulty)) != nil {}
        }
    }
}
