import AppKit
import Foundation

/// Release-safe resource check used by packaging and CI.
enum ResourceSelfTest {
    private static let requiredSprites = [
        "hero_knight",
        "monster_slime_red",
        "battle_knight"
    ]

    static func runAll() -> Never {
        print("=== TBH Resource Self Test ===")

        let missing = requiredSprites.filter { NSImage.loadExtracted(named: $0) == nil }
        if missing.isEmpty {
            print("=== RESOURCE SELF TEST PASSED ===")
            exit(0)
        }

        print("=== RESOURCE SELF TEST FAILED ===")
        for name in missing {
            print("  MISSING: \(name).png")
        }
        exit(1)
    }
}
