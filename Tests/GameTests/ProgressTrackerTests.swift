import Foundation
import Testing
@testable import TBH

@Suite struct ProgressTrackerTests {
    @Test func advanceCountsKills() {
        var tracker = ProgressTracker()
        tracker.advance()
        #expect(tracker.killsInChapter == 1)
        #expect(tracker.currentChapter == .forest, "Single kill should not advance chapter")
    }

    @Test func advanceToNextChapterAfterEnoughKills() {
        var tracker = ProgressTracker()
        for _ in 0..<ProgressTracker.killsToAdvance {
            tracker.advance()
        }
        #expect(tracker.currentChapter == .dungeon, "Should advance to chapter 2")
        #expect(tracker.killsInChapter == 0, "Kill counter should reset")
        #expect(tracker.chaptersCleared.contains(Chapter.forest.rawValue))
    }

    @Test func advanceToNextDifficultyAfterAllChapters() {
        var tracker = ProgressTracker()
        // 通关全部三章
        for _ in 0..<(ProgressTracker.killsToAdvance * Chapter.allCases.count) {
            tracker.advance()
        }
        #expect(tracker.currentDifficulty == .hard, "Should advance to hard difficulty")
        #expect(tracker.currentChapter == .forest, "Should restart from chapter 1")
        #expect(tracker.chaptersCleared.isEmpty, "Cleared chapters reset for new difficulty")
    }

    @Test func progressCapsAtMaxDifficulty() {
        var tracker = ProgressTracker()
        // 推进到远超全部内容的击杀数
        let totalKills = ProgressTracker.killsToAdvance * Chapter.allCases.count * Difficulty.allCases.count * 2
        for _ in 0..<totalKills {
            tracker.advance()
        }
        #expect(tracker.currentDifficulty == .hell, "Should cap at hell difficulty")
        #expect(tracker.currentChapter == .volcano, "Should cap at final chapter")
    }

    @Test func decodesLegacySaveWithoutKillCounter() throws {
        // 旧存档没有 killsInChapter 字段，必须能解码
        let legacyJSON = #"{"currentChapterIndex":1,"currentDifficultyIndex":0,"chaptersCleared":[1]}"#
        let data = Data(legacyJSON.utf8)
        let tracker = try JSONDecoder().decode(ProgressTracker.self, from: data)
        #expect(tracker.currentChapter == .dungeon)
        #expect(tracker.killsInChapter == 0)
    }
}
