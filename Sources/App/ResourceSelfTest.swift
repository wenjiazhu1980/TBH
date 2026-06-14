import AppKit
import Foundation

/// Release-safe resource check used by packaging and CI.
enum ResourceSelfTest {
    private static let requiredSprites = [
        "app_icon",
        "official_hero_knight",
        "official_monster_slime",
        "official_item_weapon",
        "official_item_armor",
        "official_item_helmet",
        "official_item_boots",
        "official_item_accessory"
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
