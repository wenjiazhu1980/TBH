import AppKit
import AudioToolbox
import AVFoundation
import Foundation

/// Release-safe resource check used by packaging and CI.
enum ResourceSelfTest {
    private static let requiredStaticSprites = [
        "app_icon",
        "official_monster_slime",
        "monster_slime_red",
        "monster_skeleton_boss",
        "boss_golden",
        "boss_demon",
        "stage_monster_assassin_goblin",
        "stage_monster_shaman_goblin",
        "stage_monster_basic_orc",
        "stage_monster_armored_orc",
        "stage_monster_elite_orc",
        "stage_monster_skeleton",
        "stage_monster_armored_skeleton",
        "stage_monster_skeleton_archer",
        "stage_monster_skeleton_king",
        "stage_monster_berserker_rat",
        "stage_monster_warrior_rat",
        "stage_monster_cobra",
        "stage_monster_poison_insect",
        "stage_monster_homunculus",
        "stage_monster_ghoul",
        "stage_monster_zombie_rat",
        "stage_monster_spear_kobolt",
        "stage_monster_small_mummy",
        "stage_monster_sibuna",
        "stage_monster_voidcaller",
        "official_item_weapon",
        "official_item_armor",
        "official_item_helmet",
        "official_item_boots",
        "official_item_accessory",
        "official_item_material",
        "official_item_gem",
        "official_item_box"
    ]

    private static var requiredSprites: [String] {
        uniqueResourceNames(
            requiredStaticSprites +
                HeroClass.allCases.flatMap {
                    [
                        GameArt.heroSpriteName(for: $0),
                        GameArt.battleHeroSpriteName(for: $0)
                    ]
                } +
                EquipmentType.allCases.map {
                    GameArt.itemIconName(for: $0)
                } +
                SourceItemCatalog.allMaterials.map {
                    GameArt.itemIconName(for: $0)
                } +
                SourceItemCatalog.allStageChests.map {
                    GameArt.stageChestIconName(for: $0)
                } +
                GameArt.skillIconNames +
                GameArt.runeTreeIconNames
        )
    }

    private struct SpriteIssue {
        let name: String
        let message: String
    }

    private struct SpritePixel: Equatable {
        var red: Int
        var green: Int
        var blue: Int
        var alpha: Int
    }

    private struct SpritePixels {
        var width: Int
        var height: Int
        var pixels: [SpritePixel]
    }

    private struct SFXIssue {
        let name: String
        let message: String
    }

    private struct SFXLevelMetrics {
        let rmsDBFS: Double
        let peakDBFS: Double
    }

    private enum WAVLevelError: LocalizedError {
        case invalidHeader
        case truncatedChunk(String)
        case missingDataChunk
        case invalidDataSize
        case emptyData

        var errorDescription: String? {
            switch self {
            case .invalidHeader:
                return "expected RIFF/WAVE header"
            case .truncatedChunk(let chunkID):
                return "truncated WAV chunk \(chunkID)"
            case .missingDataChunk:
                return "missing WAV data chunk"
            case .invalidDataSize:
                return "expected even 16-bit PCM data size"
            case .emptyData:
                return "missing PCM samples"
            }
        }
    }

    private static let sfxDurationRange: ClosedRange<Double> = 0.05...0.75
    private static let sfxPeakDBFSRange: ClosedRange<Double> = (-18.0)...(-3.0)
    private static let sfxRMSDBFSRange: ClosedRange<Double> = (-28.0)...(-8.0)
    private static let sfxVolumeProfiles: [GameAudioEvent: ClosedRange<Float>] = [
        .heroAttack: 0.32...0.50,
        .heroCriticalHit: 0.32...0.50,
        .skillCast: 0.32...0.50,
        .heroDamaged: 0.32...0.50,
        .battleWon: 0.36...0.55,
        .lootFound: 0.28...0.44,
        .battleLost: 0.36...0.55,
        .levelUp: 0.36...0.55,
        .itemEquipped: 0.28...0.44,
        .preview: 0.28...0.44
    ]
    private static let sfxMinimumIntervalProfiles: [GameAudioEvent: ClosedRange<TimeInterval>] = [
        .heroAttack: 0.12...0.25,
        .heroCriticalHit: 0.12...0.25,
        .skillCast: 0.12...0.28,
        .heroDamaged: 0.12...0.25,
        .battleWon: 0.40...0.80,
        .lootFound: 0.18...0.35,
        .battleLost: 0.40...0.80,
        .levelUp: 0.40...0.80,
        .itemEquipped: 0.18...0.35,
        .preview: 0.18...0.35
    ]
    private static let battleHeroOpaquePixelRatioRange: ClosedRange<Double> = 0.15...0.75
    private static let battleHeroMinimumOpaquePixels = 120

    private static var requiredSFX: [String] {
        GameAudioEvent.bundledResourceNames
    }

    static func runAll() -> Never {
        print("=== TBH Resource Self Test ===")

        let missing = requiredSprites.filter { NSImage.loadExtracted(named: $0) == nil }
        var spriteIssues = validateHeroSpriteMappings()
        spriteIssues += validateStageMonsterSpriteMappings()
        spriteIssues += validateItemSpriteMappings()
        spriteIssues += validateSkillIconMappings()
        spriteIssues += validateRuneTreeIconMappings()
        var sfxIssues = validateSFXResourceNames()
        sfxIssues += validateSFXBattleEventRoutes()
        sfxIssues += validateSFXVolumes()
        sfxIssues += validateSFXMinimumIntervals()
        sfxIssues += requiredSFX.compactMap {
            validateSFX(named: $0)
        }

        if missing.isEmpty, spriteIssues.isEmpty, sfxIssues.isEmpty {
            print("=== RESOURCE SELF TEST PASSED ===")
            exit(0)
        }

        print("=== RESOURCE SELF TEST FAILED ===")
        for name in missing {
            print("  MISSING: \(name).png")
        }
        for issue in spriteIssues {
            print("  SPRITE: \(issue.name) - \(issue.message)")
        }
        for issue in sfxIssues {
            if issue.name.hasPrefix("GameAudioEvent") || issue.name.hasPrefix("BattleEvent") {
                print("  SFX: \(issue.name) - \(issue.message)")
            } else {
                print("  SFX: sfx/\(issue.name).wav - \(issue.message)")
            }
        }
        exit(1)
    }

    private static func uniqueResourceNames(_ names: [String]) -> [String] {
        var seen = Set<String>()
        return names.filter { seen.insert($0).inserted }
    }

    private static func validateHeroSpriteMappings() -> [SpriteIssue] {
        var issues: [SpriteIssue] = []
        var heroSprites: [String] = []
        var battleSprites: [String] = []

        for heroClass in HeroClass.allCases {
            let heroSprite = GameArt.heroSpriteName(for: heroClass)
            let battleSprite = GameArt.battleHeroSpriteName(for: heroClass)
            heroSprites.append(heroSprite)
            battleSprites.append(battleSprite)

            if battleSprite != expectedBattleHeroSpriteName(for: heroClass) {
                issues.append(
                    SpriteIssue(
                        name: heroClass.rawValue,
                        message: "battle sprite must match hero class identity, expected \(expectedBattleHeroSpriteName(for: heroClass)), got \(battleSprite)"
                    )
                )
            }

            if battleSprite == heroSprite {
                issues.append(
                    SpriteIssue(
                        name: heroClass.rawValue,
                        message: "battle sprite \(battleSprite) must be separate from UI portrait sprite \(heroSprite)"
                    )
                )
            }

            if !battleSprite.hasPrefix("battle_hero_") {
                issues.append(
                    SpriteIssue(
                        name: heroClass.rawValue,
                        message: "battle sprite must use battle_hero_* art, got \(battleSprite)"
                    )
                )
            }

            if let alphaIssue = validateBattleHeroSpriteTransparency(
                named: battleSprite,
                heroClass: heroClass
            ) {
                issues.append(alphaIssue)
            }

            if let contaminatedCropIssue = validateBattleHeroSpriteIsolatedSubject(
                named: battleSprite,
                heroClass: heroClass
            ) {
                issues.append(contaminatedCropIssue)
            }

            if let classMarkerIssue = validateBattleHeroClassMarkers(
                named: battleSprite,
                heroClass: heroClass
            ) {
                issues.append(classMarkerIssue)
            }

            if let provenanceIssue = validateBattleHeroSourceProvenance(
                named: battleSprite,
                sourceSpriteName: heroSprite,
                heroClass: heroClass
            ) {
                issues.append(provenanceIssue)
            }
        }

        if Set(heroSprites).count != HeroClass.allCases.count {
            issues.append(
                SpriteIssue(
                    name: "HeroClass",
                    message: "UI hero sprites must be unique across all hero classes"
                )
            )
        }

        if Set(battleSprites).count != HeroClass.allCases.count {
            issues.append(
                SpriteIssue(
                    name: "HeroClass",
                    message: "battle hero sprites must be unique across all hero classes"
                )
            )
        }

        return issues
    }

    private static func expectedBattleHeroSpriteName(for heroClass: HeroClass) -> String {
        switch heroClass {
        case .knight:
            return "battle_hero_knight"
        case .ranger:
            return "battle_hero_ranger"
        case .sorcerer:
            return "battle_hero_sorcerer"
        case .priest:
            return "battle_hero_priest"
        case .hunter:
            return "battle_hero_hunter"
        case .slayer:
            return "battle_hero_slayer"
        }
    }

    private static func validateBattleHeroSpriteTransparency(
        named spriteName: String,
        heroClass: HeroClass
    ) -> SpriteIssue? {
        guard let url = Bundle.module.url(
            forResource: spriteName,
            withExtension: "png",
            subdirectory: "Extracted"
        ) else {
            return nil
        }

        guard let data = try? Data(contentsOf: url),
              let bitmap = NSBitmapImageRep(data: data) else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) could not be decoded as a bitmap"
            )
        }

        guard bitmap.hasAlpha else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) must keep transparent background pixels"
            )
        }

        var transparentEdgePixelCount = 0
        var opaquePixelCount = 0
        let width = bitmap.pixelsWide
        let height = bitmap.pixelsHigh

        guard (18...40).contains(width), (24...48).contains(height) else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) must be compact full-body art, got \(width)x\(height)"
            )
        }

        let expectedPixelSize = GameArt.battleHeroPixelSize(for: heroClass)
        guard width == Int(expectedPixelSize.width), height == Int(expectedPixelSize.height) else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) must match registered \(Int(expectedPixelSize.width))x\(Int(expectedPixelSize.height)) source size, got \(width)x\(height)"
            )
        }

        let cornerAlphaValues: [CGFloat] = [
            alphaComponent(in: bitmap, x: 0, y: 0),
            alphaComponent(in: bitmap, x: width - 1, y: 0),
            alphaComponent(in: bitmap, x: 0, y: height - 1),
            alphaComponent(in: bitmap, x: width - 1, y: height - 1)
        ]

        guard cornerAlphaValues.allSatisfy({ $0 == 0.0 }) else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) must keep all four corners transparent"
            )
        }

        for y in 0..<height {
            for x in 0..<width {
                if (bitmap.colorAt(x: x, y: y)?.alphaComponent ?? 0) > 0 {
                    opaquePixelCount += 1
                }
            }
        }

        for x in 0..<width {
            if (bitmap.colorAt(x: x, y: 0)?.alphaComponent ?? 1) == 0 {
                transparentEdgePixelCount += 1
            }
            if (bitmap.colorAt(x: x, y: height - 1)?.alphaComponent ?? 1) == 0 {
                transparentEdgePixelCount += 1
            }
        }

        for y in 0..<height {
            if (bitmap.colorAt(x: 0, y: y)?.alphaComponent ?? 1) == 0 {
                transparentEdgePixelCount += 1
            }
            if (bitmap.colorAt(x: width - 1, y: y)?.alphaComponent ?? 1) == 0 {
                transparentEdgePixelCount += 1
            }
        }

        let edgePixelCount = width * 2 + height * 2
        guard transparentEdgePixelCount == edgePixelCount else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) must keep a fully transparent outer edge"
            )
        }

        guard opaquePixelCount >= Self.battleHeroMinimumOpaquePixels else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) does not contain enough visible character pixels"
            )
        }

        let opaquePixelRatio = Double(opaquePixelCount) / Double(width * height)
        guard Self.battleHeroOpaquePixelRatioRange.contains(opaquePixelRatio) else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) has suspicious visible-pixel coverage \(String(format: "%.1f", opaquePixelRatio * 100))%"
            )
        }

        return nil
    }

    private static func validateBattleHeroSpriteIsolatedSubject(
        named spriteName: String,
        heroClass: HeroClass
    ) -> SpriteIssue? {
        guard let url = Bundle.module.url(
            forResource: spriteName,
            withExtension: "png",
            subdirectory: "Extracted"
        ) else {
            return nil
        }

        guard let data = try? Data(contentsOf: url),
              let bitmap = NSBitmapImageRep(data: data) else {
            return nil
        }

        let width = bitmap.pixelsWide
        let height = bitmap.pixelsHigh
        var longestHPGreenRun = 0
        var longestPortraitWhiteRun = 0

        for y in 0..<height {
            var currentHPGreenRun = 0
            var currentPortraitWhiteRun = 0
            for x in 0..<width {
                if isHPBarGreen(bitmap.colorAt(x: x, y: y)) {
                    currentHPGreenRun += 1
                    longestHPGreenRun = max(longestHPGreenRun, currentHPGreenRun)
                } else {
                    currentHPGreenRun = 0
                }

                if isPortraitFrameWhite(bitmap.colorAt(x: x, y: y)) {
                    currentPortraitWhiteRun += 1
                    longestPortraitWhiteRun = max(longestPortraitWhiteRun, currentPortraitWhiteRun)
                } else {
                    currentPortraitWhiteRun = 0
                }
            }
        }

        guard longestHPGreenRun < max(8, width / 3) else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) appears to include an HP bar crop, longest green run is \(longestHPGreenRun)px"
            )
        }

        guard longestPortraitWhiteRun < max(8, width / 3) else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) appears to include a portrait-card white background, longest white run is \(longestPortraitWhiteRun)px"
            )
        }

        return nil
    }

    private static func isHPBarGreen(_ color: NSColor?) -> Bool {
        guard let convertedColor = color?.usingColorSpace(.deviceRGB),
              convertedColor.alphaComponent > 0.10 else {
            return false
        }

        let red = convertedColor.redComponent
        let green = convertedColor.greenComponent
        let blue = convertedColor.blueComponent

        return green >= 0.58 &&
            red <= 0.47 &&
            blue <= 0.47 &&
            green > red * 1.3 &&
            green > blue * 1.3
    }

    private static func isPortraitFrameWhite(_ color: NSColor?) -> Bool {
        guard let convertedColor = color?.usingColorSpace(.deviceRGB),
              convertedColor.alphaComponent > 0.10 else {
            return false
        }

        return convertedColor.redComponent >= 0.90 &&
            convertedColor.greenComponent >= 0.90 &&
            convertedColor.blueComponent >= 0.90
    }

    private static func validateBattleHeroSourceProvenance(
        named spriteName: String,
        sourceSpriteName: String,
        heroClass: HeroClass
    ) -> SpriteIssue? {
        guard let battlePixels = decodedSpritePixels(named: spriteName) else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) could not be decoded for source-provenance validation"
            )
        }

        guard let sourcePixels = decodedSpritePixels(named: sourceSpriteName) else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "source sprite \(sourceSpriteName) could not be decoded for battle-sprite provenance validation"
            )
        }

        let expectedPixels = removeConnectedOfficialHeroPortraitFrame(from: sourcePixels)
        guard expectedPixels.width == battlePixels.width,
              expectedPixels.height == battlePixels.height else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) must match frame-removed \(sourceSpriteName) dimensions, expected \(expectedPixels.width)x\(expectedPixels.height), got \(battlePixels.width)x\(battlePixels.height)"
            )
        }

        let mismatchCount = zip(expectedPixels.pixels, battlePixels.pixels)
            .filter { !sourceProvenancePixelsMatch(expected: $0, actual: $1) }
            .count
        guard mismatchCount == 0 else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) must match \(sourceSpriteName) after connected portrait-frame removal, got \(mismatchCount) differing visible/alpha pixels"
            )
        }

        return nil
    }

    private static func sourceProvenancePixelsMatch(expected: SpritePixel, actual: SpritePixel) -> Bool {
        guard expected.alpha == actual.alpha else {
            return false
        }

        // PNG decoders can normalize RGB payloads behind fully transparent pixels.
        // Those bytes are invisible, so source provenance is checked by alpha mask
        // plus exact visible RGB.
        guard expected.alpha > 0 else {
            return true
        }

        return expected.red == actual.red &&
            expected.green == actual.green &&
            expected.blue == actual.blue
    }

    private static func decodedSpritePixels(named spriteName: String) -> SpritePixels? {
        guard let url = Bundle.module.url(
            forResource: spriteName,
            withExtension: "png",
            subdirectory: "Extracted"
        ),
              let data = try? Data(contentsOf: url),
              let bitmap = NSBitmapImageRep(data: data) else {
            return nil
        }

        let width = bitmap.pixelsWide
        let height = bitmap.pixelsHigh
        var pixels: [SpritePixel] = []
        pixels.reserveCapacity(width * height)

        for y in 0..<height {
            for x in 0..<width {
                pixels.append(spritePixel(in: bitmap, x: x, y: y))
            }
        }

        return SpritePixels(width: width, height: height, pixels: pixels)
    }

    private static func spritePixel(in bitmap: NSBitmapImageRep, x: Int, y: Int) -> SpritePixel {
        var samples = [Int](repeating: 0, count: max(bitmap.samplesPerPixel, 4))
        bitmap.getPixel(&samples, atX: x, y: y)
        return SpritePixel(
            red: samples[0],
            green: samples[1],
            blue: samples[2],
            alpha: bitmap.hasAlpha ? samples[min(3, samples.count - 1)] : 255
        )
    }

    private static func alphaComponent(
        in bitmap: NSBitmapImageRep,
        x: Int,
        y: Int,
        defaultValue: CGFloat = 1.0
    ) -> CGFloat {
        guard let color = bitmap.colorAt(x: x, y: y) else {
            return defaultValue
        }

        return color.alphaComponent
    }

    private static func removeConnectedOfficialHeroPortraitFrame(from source: SpritePixels) -> SpritePixels {
        var result = source
        var visited = Array(repeating: false, count: source.width * source.height)
        var queue: [(Int, Int)] = []
        var cursor = 0

        func index(_ x: Int, _ y: Int) -> Int {
            y * source.width + x
        }

        func appendIfBackground(_ x: Int, _ y: Int) {
            let pixelIndex = index(x, y)
            guard !visited[pixelIndex],
                  isOfficialHeroPortraitBackground(source.pixels[pixelIndex]) else {
                return
            }
            visited[pixelIndex] = true
            queue.append((x, y))
        }

        for x in 0..<source.width {
            appendIfBackground(x, 0)
            appendIfBackground(x, source.height - 1)
        }

        for y in 0..<source.height {
            appendIfBackground(0, y)
            appendIfBackground(source.width - 1, y)
        }

        while cursor < queue.count {
            let (x, y) = queue[cursor]
            cursor += 1

            let pixelIndex = index(x, y)
            result.pixels[pixelIndex].alpha = 0

            for (nextX, nextY) in [
                (x + 1, y),
                (x - 1, y),
                (x, y + 1),
                (x, y - 1)
            ] where nextX >= 0 && nextX < source.width && nextY >= 0 && nextY < source.height {
                appendIfBackground(nextX, nextY)
            }
        }

        return result
    }

    private static func isOfficialHeroPortraitBackground(_ pixel: SpritePixel) -> Bool {
        if pixel.alpha == 0 {
            return true
        }

        let brightness = Double(pixel.red + pixel.green + pixel.blue) / 3.0
        let spread = max(pixel.red, pixel.green, pixel.blue) -
            min(pixel.red, pixel.green, pixel.blue)

        if pixel.red >= 230, pixel.green >= 230, pixel.blue >= 230 {
            return true
        }

        if spread <= 28, brightness <= 42 {
            return true
        }

        return spread <= 24 && brightness > 42 && brightness <= 90
    }

    private static func validateBattleHeroClassMarkers(
        named spriteName: String,
        heroClass: HeroClass
    ) -> SpriteIssue? {
        guard heroClass == .knight else { return nil }
        guard let url = Bundle.module.url(
            forResource: spriteName,
            withExtension: "png",
            subdirectory: "Extracted"
        ) else {
            return nil
        }

        guard let data = try? Data(contentsOf: url),
              let bitmap = NSBitmapImageRep(data: data) else {
            return nil
        }

        var shieldPixelCount = 0
        var steelPixelCount = 0
        let width = bitmap.pixelsWide
        let height = bitmap.pixelsHigh

        for y in 0..<height {
            for x in 0..<width {
                guard let color = bitmap.colorAt(x: x, y: y),
                      color.alphaComponent > 0.10 else {
                    continue
                }
                let red = color.redComponent
                let green = color.greenComponent
                let blue = color.blueComponent
                let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
                let isShieldRed = red >= 0.38 &&
                    green <= 0.36 &&
                    blue <= 0.36 &&
                    red > green * 1.4 &&
                    red > blue * 1.4
                let isKnightSteel = luminance >= 0.20 &&
                    luminance <= 0.92 &&
                    abs(red - green) <= 0.16 &&
                    abs(green - blue) <= 0.22 &&
                    blue >= red - 0.10
                if isShieldRed {
                    shieldPixelCount += 1
                }
                if isKnightSteel {
                    steelPixelCount += 1
                }
            }
        }

        guard shieldPixelCount >= 8 else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) must keep a visible red Knight class marker"
            )
        }

        guard steelPixelCount >= 60 else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) must keep enough steel-gray Knight armor pixels"
            )
        }

        let componentMetrics = opaqueComponentMetrics(in: bitmap)
        let connectedRatio = Double(componentMetrics.largestComponentPixelCount) /
            Double(max(componentMetrics.opaquePixelCount, 1))
        guard connectedRatio >= 0.50 else {
            return SpriteIssue(
                name: heroClass.rawValue,
                message: "battle sprite \(spriteName) must keep a coherent Knight subject, largest component is \(String(format: "%.1f", connectedRatio * 100))%"
            )
        }

        return nil
    }

    private static func opaqueComponentMetrics(in bitmap: NSBitmapImageRep) -> (
        opaquePixelCount: Int,
        largestComponentPixelCount: Int
    ) {
        let width = bitmap.pixelsWide
        let height = bitmap.pixelsHigh
        var visited = Array(repeating: false, count: width * height)
        var opaquePixelCount = 0
        var largestComponentPixelCount = 0

        func index(_ x: Int, _ y: Int) -> Int {
            y * width + x
        }

        func isOpaque(_ x: Int, _ y: Int) -> Bool {
            (bitmap.colorAt(x: x, y: y)?.alphaComponent ?? 0) > 0.10
        }

        for y in 0..<height {
            for x in 0..<width where isOpaque(x, y) {
                opaquePixelCount += 1
            }
        }

        for y in 0..<height {
            for x in 0..<width {
                let startIndex = index(x, y)
                guard !visited[startIndex], isOpaque(x, y) else { continue }

                var componentPixelCount = 0
                var stack = [(x, y)]
                visited[startIndex] = true

                while let (currentX, currentY) = stack.popLast() {
                    componentPixelCount += 1

                    for (nextX, nextY) in [
                        (currentX + 1, currentY),
                        (currentX - 1, currentY),
                        (currentX, currentY + 1),
                        (currentX, currentY - 1)
                    ] where nextX >= 0 && nextX < width && nextY >= 0 && nextY < height {
                        let nextIndex = index(nextX, nextY)
                        guard !visited[nextIndex], isOpaque(nextX, nextY) else { continue }
                        visited[nextIndex] = true
                        stack.append((nextX, nextY))
                    }
                }

                largestComponentPixelCount = max(largestComponentPixelCount, componentPixelCount)
            }
        }

        return (opaquePixelCount, largestComponentPixelCount)
    }

    private static func validateStageMonsterSpriteMappings() -> [SpriteIssue] {
        var issues: [SpriteIssue] = []
        var sampledMonsterNames = Set<String>()
        var missingSpriteContexts: [String: [String]] = [:]
        var slimeFallbackContexts: [String] = []
        var bossMismatchContexts: [String] = []

        for stage in StageDefinition.all {
            for difficulty in Difficulty.allCases {
                let target = stage.clearTarget(for: difficulty)
                for encounterIndex in 0..<target {
                    let monster = stage.spawnMonster(
                        difficulty: difficulty,
                        encounterIndex: encounterIndex
                    )
                    let spriteName = GameArt.battleMonsterSpriteName(for: monster.id)
                    let context = "\(difficulty.name) \(stage.displayCode) #\(encounterIndex + 1) \(monster.name)"

                    sampledMonsterNames.insert(monster.name)

                    if NSImage.loadExtracted(named: spriteName) == nil {
                        missingSpriteContexts[spriteName, default: []].append(context)
                    }

                    if monster.name != "史莱姆" &&
                        (monster.id == "slime_green" ||
                         spriteName == "monster_slime_red" ||
                         spriteName == "official_monster_slime") {
                        slimeFallbackContexts.append("\(context) -> \(spriteName)")
                    }

                    if stage.isBoss,
                       let expectedBossSprite = expectedBossBattleMonsterSpriteName(for: stage),
                       spriteName != expectedBossSprite {
                        bossMismatchContexts.append("\(context) expected \(expectedBossSprite), got \(spriteName)")
                    }
                }
            }
        }

        if sampledMonsterNames.count != 49 {
            issues.append(
                SpriteIssue(
                    name: "StageMonsterArt",
                    message: "expected to sample 49 mined stage monster names, got \(sampledMonsterNames.count)"
                )
            )
        }

        for (spriteName, contexts) in missingSpriteContexts.sorted(by: { $0.key < $1.key }) {
            issues.append(
                SpriteIssue(
                    name: spriteName,
                    message: "missing battle sprite for stage monsters: \(sampleContexts(contexts))"
                )
            )
        }

        if !slimeFallbackContexts.isEmpty {
            issues.append(
                SpriteIssue(
                    name: "StageMonsterArt",
                    message: "non-slime stage monsters must not use slime art fallback: \(sampleContexts(slimeFallbackContexts))"
                )
            )
        }

        if !bossMismatchContexts.isEmpty {
            issues.append(
                SpriteIssue(
                    name: "StageBossArt",
                    message: "boss stages must map to their act boss sprites: \(sampleContexts(bossMismatchContexts))"
                )
            )
        }

        return issues
    }

    private static func expectedBossBattleMonsterSpriteName(for stage: StageDefinition) -> String? {
        guard stage.isBoss else { return nil }

        switch stage.act {
        case .forest:
            return "stage_monster_skeleton_king"
        case .dungeon:
            return "stage_monster_sibuna"
        case .volcano:
            return "stage_monster_voidcaller"
        }
    }

    private static func sampleContexts(_ contexts: [String], limit: Int = 5) -> String {
        let samples = contexts.prefix(limit).joined(separator: "; ")
        let remainingCount = contexts.count - min(contexts.count, limit)
        guard remainingCount > 0 else { return samples }
        return "\(samples); +\(remainingCount) more"
    }

    private static func validateItemSpriteMappings() -> [SpriteIssue] {
        var issues: [SpriteIssue] = []
        let equipmentTypeIcons = EquipmentType.allCases.map { equipmentType in
            (equipmentType, GameArt.itemIconName(for: equipmentType))
        }
        let slotIconNames = Set(EquipSlot.allCases.map { GameArt.itemIconName(for: $0) })
        let distinctTypeIconNames = Set(equipmentTypeIcons.map(\.1))

        if distinctTypeIconNames.count < 15 || distinctTypeIconNames.count <= slotIconNames.count {
            issues.append(
                SpriteIssue(
                    name: "EquipmentType",
                    message: "equipment type icons must stay more granular than slot fallback icons"
                )
            )
        }

        for (equipmentType, iconName) in equipmentTypeIcons {
            if !iconName.hasPrefix("item_") {
                issues.append(
                    SpriteIssue(
                        name: equipmentType.rawValue,
                        message: "equipment type icon must use extracted item-grid art, got \(iconName)"
                    )
                )
                continue
            }

            if let dimensionIssue = validateItemGridSprite(named: iconName, equipmentType: equipmentType) {
                issues.append(dimensionIssue)
            }
        }

        for material in SourceItemCatalog.allMaterials {
            let iconName = GameArt.itemIconName(for: material)
            if !iconName.hasPrefix("source_material_") {
                issues.append(
                    SpriteIssue(
                        name: material.id,
                        message: "source material icon must use source_material_* art, got \(iconName)"
                    )
                )
                continue
            }

            if let dimensionIssue = validateSourceItemSprite(
                named: iconName,
                context: material.id,
                expectedWidth: 16,
                expectedHeight: 16,
                label: "source material"
            ) {
                issues.append(dimensionIssue)
            }
        }

        var stageChestIcons: [String: String] = [:]
        for chest in SourceItemCatalog.allStageChests {
            stageChestIcons[chest.iconName] = chest.sourceIconID
        }
        for (iconName, sourceIconID) in stageChestIcons {
            if !iconName.hasPrefix("source_stage_chest_") {
                issues.append(
                    SpriteIssue(
                        name: sourceIconID,
                        message: "source stage chest icon must use source_stage_chest_* art, got \(iconName)"
                    )
                )
                continue
            }

            if let dimensionIssue = validateSourceItemSprite(
                named: iconName,
                context: sourceIconID,
                expectedWidth: 64,
                expectedHeight: 64,
                label: "source stage chest"
            ) {
                issues.append(dimensionIssue)
            }
        }

        return issues
    }

    private static func validateItemGridSprite(
        named spriteName: String,
        equipmentType: EquipmentType
    ) -> SpriteIssue? {
        guard let url = Bundle.module.url(
            forResource: spriteName,
            withExtension: "png",
            subdirectory: "Extracted"
        ) else {
            return nil
        }

        guard let data = try? Data(contentsOf: url),
              let bitmap = NSBitmapImageRep(data: data) else {
            return SpriteIssue(
                name: equipmentType.rawValue,
                message: "item sprite \(spriteName) could not be decoded as a bitmap"
            )
        }

        guard bitmap.pixelsWide == 32, bitmap.pixelsHigh == 32 else {
            return SpriteIssue(
                name: equipmentType.rawValue,
                message: "item sprite \(spriteName) must be the cleaned 32x32 inventory-grid art, got \(bitmap.pixelsWide)x\(bitmap.pixelsHigh)"
            )
        }

        guard bitmap.hasAlpha else {
            return SpriteIssue(
                name: equipmentType.rawValue,
                message: "item sprite \(spriteName) must keep transparent padding around the cleaned inventory crop"
            )
        }

        let cornerAlphaValues: [CGFloat] = [
            alphaComponent(in: bitmap, x: 0, y: 0),
            alphaComponent(in: bitmap, x: bitmap.pixelsWide - 1, y: 0),
            alphaComponent(in: bitmap, x: 0, y: bitmap.pixelsHigh - 1),
            alphaComponent(in: bitmap, x: bitmap.pixelsWide - 1, y: bitmap.pixelsHigh - 1)
        ]

        guard cornerAlphaValues.allSatisfy({ $0 == 0.0 }) else {
            return SpriteIssue(
                name: equipmentType.rawValue,
                message: "item sprite \(spriteName) appears to include inventory frame edges instead of transparent padding"
            )
        }

        return nil
    }

    private static func validateSourceItemSprite(
        named spriteName: String,
        context: String,
        expectedWidth: Int,
        expectedHeight: Int,
        label: String
    ) -> SpriteIssue? {
        guard let url = Bundle.module.url(
            forResource: spriteName,
            withExtension: "png",
            subdirectory: "Extracted"
        ) else {
            return nil
        }

        guard let data = try? Data(contentsOf: url),
              let bitmap = NSBitmapImageRep(data: data) else {
            return SpriteIssue(
                name: context,
                message: "\(label) sprite \(spriteName) could not be decoded as a bitmap"
            )
        }

        guard bitmap.pixelsWide == expectedWidth, bitmap.pixelsHigh == expectedHeight else {
            return SpriteIssue(
                name: context,
                message: "\(label) sprite \(spriteName) must be \(expectedWidth)x\(expectedHeight), got \(bitmap.pixelsWide)x\(bitmap.pixelsHigh)"
            )
        }

        return nil
    }

    private static func validateSkillIconMappings() -> [SpriteIssue] {
        var issues: [SpriteIssue] = []
        let allNamedSkills = HeroClass.allCases.flatMap { HeroSkills.named(for: $0) }
        let resolvedIcons = allNamedSkills.map { GameArt.skillIconName(for: $0) }

        if resolvedIcons.count != 36 {
            issues.append(
                SpriteIssue(
                    name: "SkillArt",
                    message: "expected 36 modeled active skills to resolve to icons, got \(resolvedIcons.count)"
                )
            )
        }

        if !resolvedIcons.allSatisfy({ $0.hasPrefix("skill_") }) {
            issues.append(
                SpriteIssue(
                    name: "SkillArt",
                    message: "modeled skill icons must use bundled skill_* category art"
                )
            )
        }

        if Set(resolvedIcons).count < 8 {
            issues.append(
                SpriteIssue(
                    name: "SkillArt",
                    message: "skill category icons must retain visual variety across modeled skills"
                )
            )
        }

        for iconName in GameArt.skillIconNames {
            if let issue = validateSkillCategorySprite(named: iconName) {
                issues.append(issue)
            }
        }

        return issues
    }

    private static func validateRuneTreeIconMappings() -> [SpriteIssue] {
        var issues: [SpriteIssue] = []
        let mappedIcons = RuneTreeNode.allCases.map { GameArt.runeTreeIconName(for: $0) }

        if !mappedIcons.allSatisfy({ $0.hasPrefix("rune_") }) {
            issues.append(
                SpriteIssue(
                    name: "RuneTreeArt",
                    message: "modeled Rune Tree nodes must use bundled rune_* node art"
                )
            )
        }

        if Set(mappedIcons).count < 5 {
            issues.append(
                SpriteIssue(
                    name: "RuneTreeArt",
                    message: "Rune Tree icons must distinguish the current modeled node categories"
                )
            )
        }

        for iconName in GameArt.runeTreeIconNames {
            if let issue = validateSourceNodeSprite(named: iconName, issueName: "RuneTreeArt") {
                issues.append(issue)
            }
        }

        return issues
    }

    private static func validateSkillCategorySprite(named spriteName: String) -> SpriteIssue? {
        validateSourceNodeSprite(named: spriteName, issueName: spriteName)
    }

    private static func validateSourceNodeSprite(named spriteName: String, issueName: String) -> SpriteIssue? {
        guard let url = Bundle.module.url(
            forResource: spriteName,
            withExtension: "png",
            subdirectory: "Extracted"
        ) else {
            return nil
        }

        guard let data = try? Data(contentsOf: url),
              let bitmap = NSBitmapImageRep(data: data) else {
            return SpriteIssue(
                name: issueName,
                message: "source node icon \(spriteName) could not be decoded as a bitmap"
            )
        }

        guard bitmap.pixelsWide == 40, bitmap.pixelsHigh == 40 else {
            return SpriteIssue(
                name: issueName,
                message: "source node icon \(spriteName) must be extracted 40x40 Rune Tree node art, got \(bitmap.pixelsWide)x\(bitmap.pixelsHigh)"
            )
        }

        var distinctColors = Set<Int>()
        var saturatedPixels = 0

        for y in 0..<bitmap.pixelsHigh {
            for x in 0..<bitmap.pixelsWide {
                guard let color = bitmap.colorAt(x: x, y: y) else { continue }
                let alpha = color.alphaComponent
                guard alpha > 0 else { continue }

                let red = Int((color.redComponent * 255).rounded())
                let green = Int((color.greenComponent * 255).rounded())
                let blue = Int((color.blueComponent * 255).rounded())
                distinctColors.insert((red << 16) | (green << 8) | blue)

                let brightest = max(red, green, blue)
                let darkest = min(red, green, blue)
                if brightest - darkest >= 48 && brightest >= 80 {
                    saturatedPixels += 1
                }
            }
        }

        guard distinctColors.count >= 24, saturatedPixels >= 64 else {
            return SpriteIssue(
                name: issueName,
                message: "source node icon \(spriteName) looks like a background crop instead of a detailed source node"
            )
        }

        return nil
    }

    private static func validateSFXResourceNames() -> [SFXIssue] {
        var issues: [SFXIssue] = []

        if Set(requiredSFX).count != requiredSFX.count {
            issues.append(
                SFXIssue(
                    name: "GameAudioEvent",
                    message: "duplicate bundled SFX resource names"
                )
            )
        }

        let requiredNames = Set(requiredSFX)
        let bundledNames = Set(
            Bundle.module.urls(
                forResourcesWithExtension: "wav",
                subdirectory: "Extracted/sfx"
            )?.map { $0.deletingPathExtension().lastPathComponent } ?? []
        )

        for extraName in bundledNames.subtracting(requiredNames).sorted() {
            issues.append(
                SFXIssue(
                    name: extraName,
                    message: "unreferenced bundled SFX file"
                )
            )
        }

        return issues
    }

    private static func validateSFXBattleEventRoutes() -> [SFXIssue] {
        var issues: [SFXIssue] = []
        let battleRoutes: [(BattleEvent, GameAudioEvent)] = [
            (.heroAttack(isCrit: false), .heroAttack),
            (.heroAttack(isCrit: true), .heroCriticalHit),
            (.heroSkill(skillName: "resource-test-skill", isCrit: false), .skillCast),
            (.heroSkill(skillName: "resource-test-skill", isCrit: true), .heroCriticalHit),
            (.supportAttack(isCrit: false), .heroAttack),
            (.supportAttack(isCrit: true), .heroCriticalHit),
            (.supportSkill(heroClass: .priest, skillName: "治愈", isCrit: false), .skillCast),
            (.supportSkill(heroClass: .priest, skillName: "治愈", isCrit: true), .heroCriticalHit),
            (.heroDamaged(isCrit: false), .heroDamaged),
            (.heroDamaged(isCrit: true), .heroDamaged),
            (.battleWon(hasLoot: false), .battleWon),
            (.battleWon(hasLoot: true), .battleWon),
            (.battleLost, .battleLost)
        ]
        let requiredNames = Set(requiredSFX)

        for (battleEvent, expectedAudioEvent) in battleRoutes {
            let actualAudioEvent = GameEngine.audioEvent(for: battleEvent)
            if actualAudioEvent != expectedAudioEvent {
                issues.append(
                    SFXIssue(
                        name: "BattleEvent.audioEvent",
                        message: "expected \(battleRouteDescription(battleEvent)) to route to \(expectedAudioEvent.rawValue), got \(actualAudioEvent.rawValue)"
                    )
                )
            }

            if !requiredNames.contains(actualAudioEvent.bundledResourceName) {
                issues.append(
                    SFXIssue(
                        name: "BattleEvent.audioEvent",
                        message: "\(battleRouteDescription(battleEvent)) routes to \(actualAudioEvent.rawValue), but \(actualAudioEvent.bundledResourceName).wav is not in required SFX resources"
                    )
                )
            }
        }

        return issues
    }

    private static func validateSFXVolumes() -> [SFXIssue] {
        var issues: [SFXIssue] = []
        let profiledEvents = Set(sfxVolumeProfiles.keys)
        let expectedEvents = Set(GameAudioEvent.allCases)

        for event in GameAudioEvent.allCases where !profiledEvents.contains(event) {
            issues.append(
                SFXIssue(
                    name: "GameAudioEvent.\(event.rawValue)",
                    message: "missing playback volume profile"
                )
            )
        }

        for event in profiledEvents.subtracting(expectedEvents).sorted(by: { $0.rawValue < $1.rawValue }) {
            issues.append(
                SFXIssue(
                    name: "GameAudioEvent.\(event.rawValue)",
                    message: "playback volume profile references an unknown audio event"
                )
            )
        }

        for event in GameAudioEvent.allCases {
            guard let profile = sfxVolumeProfiles[event] else { continue }
            guard profile.contains(event.volume) else {
                issues.append(
                    SFXIssue(
                        name: "GameAudioEvent.\(event.rawValue)",
                        message: "expected playback volume \(formatFloat(profile.lowerBound))-\(formatFloat(profile.upperBound)), got \(formatFloat(event.volume))"
                    )
                )
                continue
            }
        }

        let inventoryAndPreviewVolumes = [
            GameAudioEvent.lootFound.volume,
            GameAudioEvent.itemEquipped.volume,
            GameAudioEvent.preview.volume
        ]
        let terminalVolumes = [
            GameAudioEvent.battleWon.volume,
            GameAudioEvent.battleLost.volume,
            GameAudioEvent.levelUp.volume
        ]
        if let maxInventoryAndPreviewVolume = inventoryAndPreviewVolumes.max(),
           let minTerminalVolume = terminalVolumes.min(),
           minTerminalVolume < maxInventoryAndPreviewVolume {
            issues.append(
                SFXIssue(
                    name: "GameAudioEvent.volume",
                    message: "terminal/progression events must not be quieter than inventory/preview events"
                )
            )
        }

        return issues
    }

    private static func validateSFXMinimumIntervals() -> [SFXIssue] {
        var issues: [SFXIssue] = []
        let profiledEvents = Set(sfxMinimumIntervalProfiles.keys)
        let expectedEvents = Set(GameAudioEvent.allCases)

        for event in GameAudioEvent.allCases where !profiledEvents.contains(event) {
            issues.append(
                SFXIssue(
                    name: "GameAudioEvent.\(event.rawValue)",
                    message: "missing minimum playback interval profile"
                )
            )
        }

        for event in profiledEvents.subtracting(expectedEvents).sorted(by: { $0.rawValue < $1.rawValue }) {
            issues.append(
                SFXIssue(
                    name: "GameAudioEvent.\(event.rawValue)",
                    message: "minimum playback interval profile references an unknown audio event"
                )
            )
        }

        for event in GameAudioEvent.allCases {
            guard let profile = sfxMinimumIntervalProfiles[event] else { continue }
            guard profile.contains(event.minimumInterval) else {
                issues.append(
                    SFXIssue(
                        name: "GameAudioEvent.\(event.rawValue)",
                        message: "expected minimum playback interval \(formatSeconds(profile.lowerBound))-\(formatSeconds(profile.upperBound))s, got \(formatSeconds(event.minimumInterval))s"
                    )
                )
                continue
            }
        }

        let repeatableCombatIntervals = [
            GameAudioEvent.heroAttack.minimumInterval,
            GameAudioEvent.heroCriticalHit.minimumInterval,
            GameAudioEvent.skillCast.minimumInterval,
            GameAudioEvent.heroDamaged.minimumInterval
        ]
        let terminalIntervals = [
            GameAudioEvent.battleWon.minimumInterval,
            GameAudioEvent.battleLost.minimumInterval,
            GameAudioEvent.levelUp.minimumInterval
        ]
        if let maxRepeatableCombatInterval = repeatableCombatIntervals.max(),
           let minTerminalInterval = terminalIntervals.min(),
           minTerminalInterval <= maxRepeatableCombatInterval {
            issues.append(
                SFXIssue(
                    name: "GameAudioEvent.minimumInterval",
                    message: "terminal/progression events must be throttled longer than repeatable combat events"
                )
            )
        }

        return issues
    }

    private static func validateSFX(named name: String) -> SFXIssue? {
        guard let url = Bundle.module.url(
            forResource: name,
            withExtension: "wav",
            subdirectory: "Extracted/sfx"
        ) else {
            return SFXIssue(name: name, message: "missing file")
        }

        guard NSSound(contentsOf: url, byReference: false) != nil else {
            return SFXIssue(name: name, message: "not playable by NSSound")
        }

        do {
            let file = try AVAudioFile(forReading: url)
            let format = file.fileFormat
            let duration = Double(file.length) / format.sampleRate

            guard format.channelCount == 1 else {
                return SFXIssue(
                    name: name,
                    message: "expected mono audio, got \(format.channelCount) channels"
                )
            }

            let streamDescription = format.streamDescription.pointee
            guard streamDescription.mFormatID == kAudioFormatLinearPCM,
                  streamDescription.mBitsPerChannel == 16,
                  format.commonFormat == .pcmFormatInt16 else {
                return SFXIssue(
                    name: name,
                    message: "expected 16-bit PCM WAV, got formatID \(streamDescription.mFormatID), \(streamDescription.mBitsPerChannel)-bit, \(format.commonFormat)"
                )
            }

            guard abs(format.sampleRate - 22_050) < 0.5 else {
                return SFXIssue(
                    name: name,
                    message: "expected 22050 Hz sample rate, got \(Int(format.sampleRate)) Hz"
                )
            }

            guard sfxDurationRange.contains(duration) else {
                let roundedDuration = String(format: "%.3f", duration)
                return SFXIssue(
                    name: name,
                    message: "expected SFX duration between 0.05 and 0.75 seconds, got \(roundedDuration)s"
                )
            }

            let levelMetrics = try measurePCM16MonoLevels(at: url)
            guard sfxPeakDBFSRange.contains(levelMetrics.peakDBFS) else {
                return SFXIssue(
                    name: name,
                    message: "expected peak between -18 and -3 dBFS, got \(formatDBFS(levelMetrics.peakDBFS)) dBFS"
                )
            }

            guard sfxRMSDBFSRange.contains(levelMetrics.rmsDBFS) else {
                return SFXIssue(
                    name: name,
                    message: "expected RMS between -28 and -8 dBFS, got \(formatDBFS(levelMetrics.rmsDBFS)) dBFS"
                )
            }
        } catch {
            return SFXIssue(name: name, message: "SFX validation failed: \(error.localizedDescription)")
        }

        return nil
    }

    private static func measurePCM16MonoLevels(at url: URL) throws -> SFXLevelMetrics {
        let data = try Data(contentsOf: url)
        guard data.count >= 12,
              asciiString(in: data, at: 0, count: 4) == "RIFF",
              asciiString(in: data, at: 8, count: 4) == "WAVE" else {
            throw WAVLevelError.invalidHeader
        }

        var pcmDataRange: Range<Int>?
        var offset = 12

        while offset + 8 <= data.count {
            let chunkID = asciiString(in: data, at: offset, count: 4)
            let chunkSize = Int(littleEndianUInt32(in: data, at: offset + 4))
            let chunkStart = offset + 8
            let chunkEnd = chunkStart + chunkSize

            guard chunkEnd <= data.count else {
                throw WAVLevelError.truncatedChunk(chunkID)
            }

            if chunkID == "data" {
                pcmDataRange = chunkStart..<chunkEnd
                break
            }

            offset = chunkEnd + (chunkSize % 2)
        }

        guard let pcmDataRange else {
            throw WAVLevelError.missingDataChunk
        }

        guard !pcmDataRange.isEmpty else {
            throw WAVLevelError.emptyData
        }

        guard pcmDataRange.count.isMultiple(of: 2) else {
            throw WAVLevelError.invalidDataSize
        }

        var maxAbsoluteSample = 0
        var sumSquares = 0.0
        var sampleCount = 0
        var sampleOffset = pcmDataRange.lowerBound

        while sampleOffset < pcmDataRange.upperBound {
            let rawSample = UInt16(data[sampleOffset]) |
                (UInt16(data[sampleOffset + 1]) << 8)
            let sample = Int(Int16(bitPattern: rawSample))
            let absoluteSample = sample == Int(Int16.min) ? 32_768 : abs(sample)

            maxAbsoluteSample = max(maxAbsoluteSample, absoluteSample)
            sumSquares += Double(sample) * Double(sample)
            sampleCount += 1
            sampleOffset += 2
        }

        guard sampleCount > 0 else {
            throw WAVLevelError.emptyData
        }

        let peak = Double(maxAbsoluteSample) / 32_768.0
        let rms = sqrt(sumSquares / Double(sampleCount)) / 32_768.0

        return SFXLevelMetrics(
            rmsDBFS: dbFS(rms),
            peakDBFS: dbFS(peak)
        )
    }

    private static func dbFS(_ amplitude: Double) -> Double {
        guard amplitude > 0 else { return -.infinity }
        return 20 * log10(amplitude)
    }

    private static func formatDBFS(_ value: Double) -> String {
        value.isFinite ? String(format: "%.1f", value) : "-inf"
    }

    private static func formatSeconds(_ value: TimeInterval) -> String {
        String(format: "%.2f", value)
    }

    private static func formatFloat(_ value: Float) -> String {
        String(format: "%.2f", value)
    }

    private static func battleRouteDescription(_ event: BattleEvent) -> String {
        switch event {
        case .heroAttack(let isCrit):
            return isCrit ? "hero critical attack" : "hero attack"
        case .heroSkill(_, let isCrit):
            return isCrit ? "hero critical skill" : "hero skill"
        case .supportAttack(let isCrit):
            return isCrit ? "support critical attack" : "support attack"
        case .supportSkill(_, _, let isCrit):
            return isCrit ? "support critical skill" : "support skill"
        case .heroDamaged(let isCrit):
            return isCrit ? "critical hero damage" : "hero damage"
        case .battleWon(let hasLoot):
            return hasLoot ? "battle victory with loot" : "battle victory"
        case .battleLost:
            return "battle defeat"
        }
    }

    private static func asciiString(in data: Data, at offset: Int, count: Int) -> String {
        guard offset >= 0, count >= 0, offset + count <= data.count else { return "" }
        return String(bytes: data[offset..<offset + count], encoding: .ascii) ?? ""
    }

    private static func littleEndianUInt32(in data: Data, at offset: Int) -> UInt32 {
        guard offset >= 0, offset + 4 <= data.count else { return 0 }
        return UInt32(data[offset]) |
            (UInt32(data[offset + 1]) << 8) |
            (UInt32(data[offset + 2]) << 16) |
            (UInt32(data[offset + 3]) << 24)
    }
}
