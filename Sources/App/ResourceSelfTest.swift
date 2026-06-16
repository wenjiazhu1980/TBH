import AppKit
import AudioToolbox
import AVFoundation
import Foundation

/// Release-safe resource check used by packaging and CI.
enum ResourceSelfTest {
    private static let requiredStaticSprites = [
        "app_icon",
        "campfire",
        "logo_tbh",
        "achievement_1",
        "achievement_2",
        "achievement_3",
        "achievement_4",
        "taskbar_hero_1",
        "taskbar_hero_2",
        "taskbar_hero_3",
        "taskbar_hero_4",
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
        let heroSprites = HeroClass.allCases.flatMap { heroClass in
            [
                GameArt.heroSpriteName(for: heroClass),
                GameArt.battleHeroSpriteName(for: heroClass)
            ]
        }
        let equipmentIcons = EquipmentType.allCases.map { GameArt.itemIconName(for: $0) }
        let gearIcons = SourceItemCatalog.allGearTypes.flatMap { $0.progressions.map(\.iconName) }
        let materialIcons = SourceItemCatalog.allMaterials.map { GameArt.itemIconName(for: $0) }
        let chestIcons = SourceItemCatalog.allStageChests.map { GameArt.stageChestIconName(for: $0) }

        return uniqueResourceNames(
            requiredStaticSprites +
                heroSprites +
                equipmentIcons +
                gearIcons +
                materialIcons +
                chestIcons +
                GameArt.skillIconNames +
                GameArt.passiveSkillIconNames +
                GameArt.runeTreeIconNames
        )
    }

    private struct SpriteIssue {
        let name: String
        let message: String
    }

    private struct SourceGearManifestRow {
        let iconName: String
        let slug: String
        let type: String
        let itemLevel: String
        let sourceID: String
        let name: String
        let sourceURL: String
        let sha256: String
        let bytes: String
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

    private struct SFXProfileMetrics {
        let duration: Double
        let rmsDBFS: Double
        let peakDBFS: Double
    }

    private struct SFXManifestRow {
        let resourceName: String
        let event: String
        let provenance: String
        let officialAudio: String
        let sampleRate: String
        let channels: String
        let bitDepth: String
        let durationSeconds: String
        let sha256: String
        let bytes: String
        let note: String
    }

    private struct BrandArtMetrics {
        let width: Int
        let height: Int
        let opaquePixels: Int
        let distinctColors: Int
        let saturatedPixels: Int
        let darkPixels: Int
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
        .itemConsumed: 0.28...0.44,
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
        .itemConsumed: 0.18...0.35,
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
        var spriteIssues = validateAppIconAndBrandArt()
        spriteIssues += validateHeroSpriteMappings()
        spriteIssues += validateStageMonsterSpriteMappings()
        spriteIssues += validateItemSpriteMappings()
        spriteIssues += validateSkillIconMappings()
        spriteIssues += validatePassiveSkillIconMappings()
        spriteIssues += validateRuneTreeIconMappings()
        var sfxIssues = validateSFXResourceNames()
        sfxIssues += validateSFXBattleEventRoutes()
        sfxIssues += validateSFXVolumes()
        sfxIssues += validateSFXMinimumIntervals()
        sfxIssues += validateSFXPayloadProfiles()
        sfxIssues += validateSFXManifestPayloads()
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

    private static func validateAppIconAndBrandArt() -> [SpriteIssue] {
        var issues: [SpriteIssue] = []

        if GameArt.appIconName != "app_icon" {
            issues.append(
                SpriteIssue(
                    name: "GameArt.appIconName",
                    message: "app icon mapping must point to app_icon"
                )
            )
        }

        if MenuBarIcon.nativeIconSide != 14 {
            issues.append(
                SpriteIssue(
                    name: "MenuBarIcon.nativeIconSide",
                    message: "menu-bar icon side must stay 14pt to avoid oversized status-item icons, got \(MenuBarIcon.nativeIconSide)"
                )
            )
        }

        if MenuBarIcon.nativeLabelHeight != 18 {
            issues.append(
                SpriteIssue(
                    name: "MenuBarIcon.nativeLabelHeight",
                    message: "menu-bar label height must stay 18pt to avoid status-item black-bar regressions, got \(MenuBarIcon.nativeLabelHeight)"
                )
            )
        }

        let expectedBrandArt: [(name: String, width: Int, height: Int, minColors: Int, minSaturated: Int)] = [
            ("app_icon", 180, 180, 12, 3_000),
            ("logo_tbh", 184, 86, 1_000, 1_000),
            ("campfire", 160, 180, 1_000, 3_000),
            ("achievement_1", 64, 64, 100, 1_000),
            ("achievement_2", 64, 64, 100, 1_000),
            ("achievement_3", 64, 64, 100, 1_000),
            ("achievement_4", 64, 64, 100, 1_000),
            ("taskbar_hero_1", 32, 32, 20, 0),
            ("taskbar_hero_2", 32, 32, 20, 0),
            ("taskbar_hero_3", 32, 32, 20, 0),
            ("taskbar_hero_4", 32, 32, 20, 0)
        ]

        for art in expectedBrandArt {
            guard let metrics = brandArtMetrics(named: art.name) else {
                issues.append(SpriteIssue(name: art.name, message: "brand art could not be decoded"))
                continue
            }

            if metrics.width != art.width || metrics.height != art.height {
                issues.append(
                    SpriteIssue(
                        name: art.name,
                        message: "brand art must be \(art.width)x\(art.height), got \(metrics.width)x\(metrics.height)"
                    )
                )
            }

            if metrics.opaquePixels != art.width * art.height {
                issues.append(
                    SpriteIssue(
                        name: art.name,
                        message: "brand art must remain fully opaque, got opaque pixels \(metrics.opaquePixels)"
                    )
                )
            }

            if metrics.distinctColors < art.minColors {
                issues.append(
                    SpriteIssue(
                        name: art.name,
                        message: "brand art lost too much color detail: \(metrics.distinctColors) colors"
                    )
                )
            }

            if metrics.saturatedPixels < art.minSaturated {
                issues.append(
                    SpriteIssue(
                        name: art.name,
                        message: "brand art lost saturated pixel-art signal: \(metrics.saturatedPixels) pixels"
                    )
                )
            }

            if art.name == "app_icon" {
                let totalPixels = max(1, metrics.width * metrics.height)
                let darkRatio = Double(metrics.darkPixels) / Double(totalPixels)
                if !(0.45...0.85).contains(darkRatio) {
                    issues.append(
                        SpriteIssue(
                            name: art.name,
                            message: "app icon lost the expected dark menu-bar-safe backing ratio"
                        )
                    )
                }
            }
        }

        if let icnsIssue = validateAppIconICNS() {
            issues.append(icnsIssue)
        }

        return issues
    }

    private static func brandArtMetrics(named spriteName: String) -> BrandArtMetrics? {
        guard let url = Bundle.module.url(
            forResource: spriteName,
            withExtension: "png",
            subdirectory: "Extracted"
        ),
              let data = try? Data(contentsOf: url),
              let bitmap = NSBitmapImageRep(data: data) else {
            return nil
        }

        var opaquePixels = 0
        var saturatedPixels = 0
        var darkPixels = 0
        var distinctColors = Set<Int>()

        for y in 0..<bitmap.pixelsHigh {
            for x in 0..<bitmap.pixelsWide {
                guard let color = bitmap.colorAt(x: x, y: y),
                      color.alphaComponent > 0.10 else { continue }

                opaquePixels += 1
                let red = Int((color.redComponent * 255).rounded())
                let green = Int((color.greenComponent * 255).rounded())
                let blue = Int((color.blueComponent * 255).rounded())
                distinctColors.insert((red << 16) | (green << 8) | blue)

                let brightest = max(red, green, blue)
                let darkest = min(red, green, blue)
                if brightest - darkest >= 48, brightest >= 80 {
                    saturatedPixels += 1
                }
                if red <= 40, green <= 45, blue <= 55 {
                    darkPixels += 1
                }
            }
        }

        return BrandArtMetrics(
            width: bitmap.pixelsWide,
            height: bitmap.pixelsHigh,
            opaquePixels: opaquePixels,
            distinctColors: distinctColors.count,
            saturatedPixels: saturatedPixels,
            darkPixels: darkPixels
        )
    }

    private static func validateAppIconICNS() -> SpriteIssue? {
        guard let url = Bundle.module.url(
            forResource: "TBH",
            withExtension: "icns",
            subdirectory: "Extracted"
        ) else {
            return SpriteIssue(name: "TBH.icns", message: "missing app icon ICNS resource")
        }

        guard let data = try? Data(contentsOf: url), data.count >= 8 else {
            return SpriteIssue(name: "TBH.icns", message: "app icon ICNS could not be read")
        }

        guard asciiString(in: data, at: 0, count: 4) == "icns" else {
            return SpriteIssue(name: "TBH.icns", message: "app icon ICNS must start with an icns header")
        }

        let declaredSize = Int(bigEndianUInt32(in: data, at: 4))
        guard declaredSize == data.count else {
            return SpriteIssue(
                name: "TBH.icns",
                message: "app icon ICNS declared size mismatch: declared \(declaredSize), actual \(data.count)"
            )
        }

        var chunks = Set<String>()
        var offset = 8
        while offset + 8 <= data.count {
            let chunkType = asciiString(in: data, at: offset, count: 4)
            let chunkSize = Int(bigEndianUInt32(in: data, at: offset + 4))
            guard chunkSize >= 8, offset + chunkSize <= data.count else {
                return SpriteIssue(
                    name: "TBH.icns",
                    message: "app icon ICNS has invalid chunk \(chunkType) size \(chunkSize)"
                )
            }
            chunks.insert(chunkType)
            offset += chunkSize
        }

        let requiredChunks: Set<String> = ["icp4", "icp5", "icp6", "ic07", "ic08", "ic09", "ic10"]
        let missingChunks = requiredChunks.subtracting(chunks).sorted()
        guard missingChunks.isEmpty else {
            return SpriteIssue(
                name: "TBH.icns",
                message: "app icon ICNS is missing chunks: \(missingChunks.joined(separator: ","))"
            )
        }

        return nil
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
        var legacyUICropContexts: [String] = []
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

                    if spriteName == "monster_slime_red" ||
                        spriteName == "monster_skeleton_boss" ||
                        spriteName == "boss_golden" ||
                        spriteName == "boss_demon" {
                        legacyUICropContexts.append("\(context) -> \(spriteName)")
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

        if !legacyUICropContexts.isEmpty {
            issues.append(
                SpriteIssue(
                    name: "StageMonsterArt",
                    message: "stage battle monsters must not use legacy full-screenshot UI crops: \(sampleContexts(legacyUICropContexts))"
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

        if distinctTypeIconNames.count != EquipmentType.allCases.count ||
            distinctTypeIconNames.count <= slotIconNames.count {
            issues.append(
                SpriteIssue(
                    name: "EquipmentType",
                    message: "each equipment type must keep its own source-backed gear icon instead of falling back to shared slot art"
                )
            )
        }

        for (equipmentType, iconName) in equipmentTypeIcons {
            if !iconName.hasPrefix("item_") {
                issues.append(
                    SpriteIssue(
                        name: equipmentType.rawValue,
                        message: "equipment type icon must use pinned item_* source gear art, got \(iconName)"
                    )
                )
                continue
            }

            if let dimensionIssue = validateItemGridSprite(named: iconName, equipmentType: equipmentType) {
                issues.append(dimensionIssue)
            }
        }

        issues += validateEquipmentFallbackIconsMatchSourceGear()
        issues += validateSourceGearManifestPayloads()

        for gearType in SourceItemCatalog.allGearTypes {
            for progression in gearType.progressions {
                if let issue = validateSourceItemSprite(
                    named: progression.iconName,
                    context: "\(gearType.sourceTitle) \(progression.id)",
                    expectedWidth: 16,
                    expectedHeight: 16,
                    label: "source gear progression"
                ) {
                    issues.append(issue)
                }
            }
        }

        let officialFallbackSprites: [(name: String, width: Int, height: Int)] = [
            ("official_item_weapon", 16, 16),
            ("official_item_armor", 16, 16),
            ("official_item_helmet", 16, 16),
            ("official_item_boots", 16, 16),
            ("official_item_accessory", 16, 16),
            ("official_item_material", 16, 16),
            ("official_item_gem", 16, 16),
            ("official_item_box", 32, 32)
        ]
        for fallback in officialFallbackSprites {
            if let issue = validateCleanItemLikeSprite(
                named: fallback.name,
                context: fallback.name,
                expectedWidth: fallback.width,
                expectedHeight: fallback.height,
                label: "official item fallback"
            ) {
                issues.append(issue)
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

            if let dimensionIssue = validateCleanItemLikeSprite(
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

    private static func validateEquipmentFallbackIconsMatchSourceGear() -> [SpriteIssue] {
        var issues: [SpriteIssue] = []

        for equipmentType in EquipmentType.allCases {
            let fallbackIconName = GameArt.itemIconName(for: equipmentType)
            guard let sourceIconName = SourceItemCatalog.progression(
                for: equipmentType,
                itemLevel: 1
            )?.iconName else {
                issues.append(
                    SpriteIssue(
                        name: equipmentType.rawValue,
                        message: "equipment type has no checked source gear progression for fallback comparison"
                    )
                )
                continue
            }

            guard let fallbackData = resourceData(named: fallbackIconName, withExtension: "png", subdirectory: "Extracted") else {
                issues.append(
                    SpriteIssue(
                        name: equipmentType.rawValue,
                        message: "fallback icon \(fallbackIconName).png is missing"
                    )
                )
                continue
            }

            guard let sourceData = resourceData(named: sourceIconName, withExtension: "png", subdirectory: "Extracted") else {
                issues.append(
                    SpriteIssue(
                        name: equipmentType.rawValue,
                        message: "source progression icon \(sourceIconName).png is missing"
                    )
                )
                continue
            }

            if fallbackData != sourceData {
                issues.append(
                    SpriteIssue(
                        name: equipmentType.rawValue,
                        message: "fallback icon \(fallbackIconName).png must be byte-identical to checked source gear icon \(sourceIconName).png; do not redraw equipment icons"
                    )
                )
            }
        }

        return issues
    }

    private static func validateSourceGearManifestPayloads() -> [SpriteIssue] {
        var issues: [SpriteIssue] = []
        let expectedHeader = [
            "iconName",
            "slug",
            "type",
            "itemLevel",
            "sourceID",
            "name",
            "sourceURL",
            "sha256",
            "bytes"
        ]

        guard let manifestData = resourceData(
            named: "source_gear_icons",
            withExtension: "tsv",
            subdirectory: "Extracted"
        ) else {
            return [
                SpriteIssue(
                    name: "source_gear_icons.tsv",
                    message: "source gear provenance manifest is missing; equipment icons must stay source-backed, not redrawn"
                )
            ]
        }

        guard let manifestText = String(data: manifestData, encoding: .utf8) else {
            return [
                SpriteIssue(
                    name: "source_gear_icons.tsv",
                    message: "source gear provenance manifest is not valid UTF-8"
                )
            ]
        }

        var lines = manifestText
            .split(whereSeparator: \.isNewline)
            .map(String.init)
        guard !lines.isEmpty else {
            return [
                SpriteIssue(
                    name: "source_gear_icons.tsv",
                    message: "source gear provenance manifest is empty"
                )
            ]
        }

        let header = lines.removeFirst().split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
        if header != expectedHeader {
            issues.append(
                SpriteIssue(
                    name: "source_gear_icons.tsv",
                    message: "source gear manifest header mismatch: \(header.joined(separator: ","))"
                )
            )
        }

        let expectedRows = Dictionary(
            uniqueKeysWithValues: SourceItemCatalog.allGearTypes.flatMap { gearType in
                gearType.progressions.map { progression in
                    (
                        progression.iconName,
                        (
                            slug: gearType.sourceSlug,
                            type: gearType.sourceTitle,
                            itemLevel: String(progression.itemLevel),
                            sourceID: progression.id,
                            name: progression.name
                        )
                    )
                }
            }
        )

        var rowsByIconName: [String: SourceGearManifestRow] = [:]
        for (lineIndex, line) in lines.enumerated() {
            let columns = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard columns.count == expectedHeader.count else {
                issues.append(
                    SpriteIssue(
                        name: "source_gear_icons.tsv",
                        message: "line \(lineIndex + 2) has \(columns.count) columns, expected \(expectedHeader.count)"
                    )
                )
                continue
            }

            let row = SourceGearManifestRow(
                iconName: columns[0],
                slug: columns[1],
                type: columns[2],
                itemLevel: columns[3],
                sourceID: columns[4],
                name: columns[5],
                sourceURL: columns[6],
                sha256: columns[7],
                bytes: columns[8]
            )

            if rowsByIconName[row.iconName] != nil {
                issues.append(
                    SpriteIssue(
                        name: row.iconName,
                        message: "duplicate source gear manifest row"
                    )
                )
            }
            rowsByIconName[row.iconName] = row
        }

        if rowsByIconName.count != SourceItemCatalog.expectedGearLevelProgressionCount {
            issues.append(
                SpriteIssue(
                    name: "source_gear_icons.tsv",
                    message: "manifest must cover \(SourceItemCatalog.expectedGearLevelProgressionCount) checked source gear progression icons, got \(rowsByIconName.count)"
                )
            )
        }

        let missing = Set(expectedRows.keys).subtracting(rowsByIconName.keys).sorted()
        if !missing.isEmpty {
            issues.append(
                SpriteIssue(
                    name: "source_gear_icons.tsv",
                    message: "manifest is missing checked source gear icons: \(missing.prefix(6).joined(separator: ","))"
                )
            )
        }

        let extra = Set(rowsByIconName.keys).subtracting(expectedRows.keys).sorted()
        if !extra.isEmpty {
            issues.append(
                SpriteIssue(
                    name: "source_gear_icons.tsv",
                    message: "manifest includes unknown source gear icons: \(extra.prefix(6).joined(separator: ","))"
                )
            )
        }

        for iconName in expectedRows.keys.sorted() {
            guard let row = rowsByIconName[iconName],
                  let expected = expectedRows[iconName] else {
                continue
            }

            if row.slug != expected.slug ||
                row.type != expected.type ||
                row.itemLevel != expected.itemLevel ||
                row.sourceID != expected.sourceID ||
                row.name != expected.name {
                issues.append(
                    SpriteIssue(
                        name: iconName,
                        message: "manifest metadata does not match SourceItemCatalog row"
                    )
                )
            }

            let expectedURLPrefix = "https://taskbarhero.org/assets/tbhdb/game/gear/\(expected.slug)/"
            if !row.sourceURL.hasPrefix(expectedURLPrefix) {
                issues.append(
                    SpriteIssue(
                        name: iconName,
                        message: "manifest source URL must stay under \(expectedURLPrefix), got \(row.sourceURL)"
                    )
                )
            }

            guard let expectedByteCount = Int(row.bytes), expectedByteCount > 0 else {
                issues.append(
                    SpriteIssue(
                        name: iconName,
                        message: "manifest byte count is invalid: \(row.bytes)"
                    )
                )
                continue
            }

            guard let data = resourceData(named: iconName, withExtension: "png", subdirectory: "Extracted") else {
                issues.append(
                    SpriteIssue(
                        name: iconName,
                        message: "source gear icon payload is missing"
                    )
                )
                continue
            }

            if data.count != expectedByteCount {
                issues.append(
                    SpriteIssue(
                        name: iconName,
                        message: "source gear icon byte count changed from manifest \(expectedByteCount) to \(data.count); do not replace source icons with redrawn art"
                    )
                )
            }

            let digest = sha256Hex(data)
            if digest != row.sha256 {
                issues.append(
                    SpriteIssue(
                        name: iconName,
                        message: "source gear icon SHA-256 changed; expected \(row.sha256), got \(digest); do not redraw equipment icons"
                    )
                )
            }
        }

        return issues
    }

    private static func validateCleanItemLikeSprite(
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

        guard bitmap.hasAlpha else {
            return SpriteIssue(
                name: context,
                message: "\(label) sprite \(spriteName) must keep a transparent background"
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
                name: context,
                message: "\(label) sprite \(spriteName) includes opaque corner pixels; likely a cropped inventory UI tile"
            )
        }

        var visiblePixelCount = 0
        var edgeVisiblePixelCount = 0
        for y in 0..<bitmap.pixelsHigh {
            for x in 0..<bitmap.pixelsWide {
                if alphaComponent(in: bitmap, x: x, y: y) > 0.10 {
                    visiblePixelCount += 1
                    if x == 0 || y == 0 || x == bitmap.pixelsWide - 1 || y == bitmap.pixelsHigh - 1 {
                        edgeVisiblePixelCount += 1
                    }
                }
            }
        }

        let visiblePixelRatio = Double(visiblePixelCount) / Double(bitmap.pixelsWide * bitmap.pixelsHigh)
        guard (0.04...0.70).contains(visiblePixelRatio) else {
            return SpriteIssue(
                name: context,
                message: "\(label) sprite \(spriteName) has suspicious visible-pixel coverage \(String(format: "%.1f", visiblePixelRatio * 100))%; likely blank or a cropped UI tile"
            )
        }

        guard edgeVisiblePixelCount == 0 else {
            return SpriteIssue(
                name: context,
                message: "\(label) sprite \(spriteName) has \(edgeVisiblePixelCount) visible pixels touching the canvas edge; likely includes grid lines or adjacent item fragments"
            )
        }

        return nil
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

        guard bitmap.pixelsWide == 16, bitmap.pixelsHigh == 16 else {
            return SpriteIssue(
                name: equipmentType.rawValue,
                message: "item sprite \(spriteName) must keep the pinned source gear icon size 16x16, got \(bitmap.pixelsWide)x\(bitmap.pixelsHigh)"
            )
        }

        guard bitmap.hasAlpha else {
            return SpriteIssue(
                name: equipmentType.rawValue,
                message: "item sprite \(spriteName) must keep a transparent background"
            )
        }

        var opaquePixelCount = 0
        for y in 0..<bitmap.pixelsHigh {
            for x in 0..<bitmap.pixelsWide {
                if alphaComponent(in: bitmap, x: x, y: y) > 0.10 {
                    opaquePixelCount += 1
                }
            }
        }

        let opaquePixelRatio = Double(opaquePixelCount) / Double(bitmap.pixelsWide * bitmap.pixelsHigh)
        guard (0.10...0.80).contains(opaquePixelRatio) else {
            return SpriteIssue(
                name: equipmentType.rawValue,
                message: "item sprite \(spriteName) has suspicious visible-pixel coverage \(String(format: "%.1f", opaquePixelRatio * 100))%; likely blank or not the pinned source gear icon"
            )
        }

        let connectivity = alphaConnectivitySummary(in: bitmap, alphaThreshold: 0.10)
        let largestShare = connectivity.totalPixels > 0
            ? Double(connectivity.largestComponentPixelCount) / Double(connectivity.totalPixels)
            : 0
        guard connectivity.componentCount == 1 || largestShare >= 0.92 else {
            return SpriteIssue(
                name: equipmentType.rawValue,
                message: "item sprite \(spriteName) has \(connectivity.componentCount) visible fragments; likely a cropped inventory tile with adjacent item art"
            )
        }

        return nil
    }

    private static func alphaConnectivitySummary(
        in bitmap: NSBitmapImageRep,
        alphaThreshold: CGFloat
    ) -> (componentCount: Int, largestComponentPixelCount: Int, totalPixels: Int) {
        let width = bitmap.pixelsWide
        let height = bitmap.pixelsHigh
        var visited = Array(repeating: false, count: width * height)
        var componentCount = 0
        var largestComponentPixelCount = 0
        var totalPixels = 0

        func index(_ x: Int, _ y: Int) -> Int {
            y * width + x
        }

        func isVisible(_ x: Int, _ y: Int) -> Bool {
            alphaComponent(in: bitmap, x: x, y: y, defaultValue: 0.0) > alphaThreshold
        }

        for y in 0..<height {
            for x in 0..<width {
                let startIndex = index(x, y)
                guard !visited[startIndex], isVisible(x, y) else {
                    continue
                }

                componentCount += 1
                var componentPixelCount = 0
                var queue = [(x, y)]
                var cursor = 0
                visited[startIndex] = true

                while cursor < queue.count {
                    let (currentX, currentY) = queue[cursor]
                    cursor += 1
                    componentPixelCount += 1

                    for nextY in max(0, currentY - 1)...min(height - 1, currentY + 1) {
                        for nextX in max(0, currentX - 1)...min(width - 1, currentX + 1) {
                            let nextIndex = index(nextX, nextY)
                            guard !visited[nextIndex], isVisible(nextX, nextY) else {
                                continue
                            }
                            visited[nextIndex] = true
                            queue.append((nextX, nextY))
                        }
                    }
                }

                totalPixels += componentPixelCount
                largestComponentPixelCount = max(largestComponentPixelCount, componentPixelCount)
            }
        }

        return (componentCount, largestComponentPixelCount, totalPixels)
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

    private static func validatePassiveSkillIconMappings() -> [SpriteIssue] {
        var issues: [SpriteIssue] = []
        let mappedIcons = PassiveSkills.all.compactMap { GameArt.passiveSkillIconName(for: $0) }
        let missingSourceIconStats = Set(
            PassiveSkills.all
                .filter { GameArt.passiveSkillIconName(for: $0) == nil }
                .map(\.stat)
        )

        if mappedIcons.count != 104 || missingSourceIconStats != ["IncreaseProjectileDamage", "SkillHealIncrease"] {
            issues.append(
                SpriteIssue(
                    name: "PassiveSkillArt",
                    message: "expected 104 passive rows to use source icons and only IncreaseProjectileDamage/SkillHealIncrease to have no current source icon, got mapped=\(mappedIcons.count), missing=\(missingSourceIconStats.sorted().joined(separator: ","))"
                )
            )
        }

        if Set(mappedIcons).count != GameArt.passiveSkillIconNames.count || GameArt.passiveSkillIconNames.count != 27 {
            issues.append(
                SpriteIssue(
                    name: "PassiveSkillArt",
                    message: "passive source icon family coverage must stay at 27 current Wiki image families"
                )
            )
        }

        if !mappedIcons.allSatisfy({ $0.hasPrefix("source_passive_") }) {
            issues.append(
                SpriteIssue(
                    name: "PassiveSkillArt",
                    message: "passive skill icons must use bundled source_passive_* source art"
                )
            )
        }

        for iconName in GameArt.passiveSkillIconNames {
            let expectedSize = passiveSkillIconSize(named: iconName)
            if let issue = validateSourceItemSprite(
                named: iconName,
                context: "PassiveSkillArt",
                expectedWidth: expectedSize.width,
                expectedHeight: expectedSize.height,
                label: "passive skill"
            ) {
                issues.append(issue)
            }
        }

        return issues
    }

    private static func passiveSkillIconSize(named iconName: String) -> (width: Int, height: Int) {
        switch iconName {
        case "source_passive_Armor",
            "source_passive_AttackDamage",
            "source_passive_AttackSpeed",
            "source_passive_CastSpeed",
            "source_passive_CooldownReduction",
            "source_passive_CriticalChance",
            "source_passive_CriticalDamage",
            "source_passive_DamageAbsorption",
            "source_passive_MaxDodgeChance",
            "source_passive_MaxHp",
            "source_passive_MovementSpeed":
            return (32, 32)
        default:
            return (16, 16)
        }
    }

    private static func validateRuneTreeIconMappings() -> [SpriteIssue] {
        var issues: [SpriteIssue] = []
        let mappedIcons = RuneTreeNode.allCases.map { GameArt.runeTreeIconName(for: $0) }

        if !mappedIcons.allSatisfy({ $0.hasPrefix("source_rune_") }) {
            issues.append(
                SpriteIssue(
                    name: "RuneTreeArt",
                    message: "modeled Rune Tree nodes must use bundled source_rune_* node art"
                )
            )
        }

        let expectedSourceIconNames = Set(
            SourceRuneCatalog.iconNames.map { GameArt.sourceRuneIconName(forIconFamily: $0) }
        )
        let bundledSourceIconNames = Set(GameArt.runeTreeIconNames)
        if bundledSourceIconNames != expectedSourceIconNames {
            issues.append(
                SpriteIssue(
                    name: "RuneTreeArt",
                    message: "Rune Tree icon list must match the checked source icon families"
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

        let expectedSize = sourceNodeIconSize(named: spriteName)
        guard bitmap.pixelsWide == expectedSize.width, bitmap.pixelsHigh == expectedSize.height else {
            return SpriteIssue(
                name: issueName,
                message: "source node icon \(spriteName) must be \(expectedSize.width)x\(expectedSize.height) node art, got \(bitmap.pixelsWide)x\(bitmap.pixelsHigh)"
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

        let minimumDistinctColors = expectedSize.width == 16 ? 8 : 24
        let minimumSaturatedPixels = expectedSize.width == 16 ? 8 : 64
        guard distinctColors.count >= minimumDistinctColors, saturatedPixels >= minimumSaturatedPixels else {
            return SpriteIssue(
                name: issueName,
                message: "source node icon \(spriteName) looks like a background crop instead of a detailed source node"
            )
        }

        return nil
    }

    private static func sourceNodeIconSize(named spriteName: String) -> (width: Int, height: Int) {
        if spriteName.hasPrefix("source_rune_") {
            return (16, 16)
        }
        switch spriteName {
        case "rune_open_one_chest_type", "rune_open_all_chest_types":
            return (16, 16)
        default:
            return (40, 40)
        }
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
            GameAudioEvent.itemConsumed.volume,
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

    private static func validateSFXPayloadProfiles() -> [SFXIssue] {
        var issues: [SFXIssue] = []
        var payloadsByData: [Data: [String]] = [:]
        var profiles: [String: SFXProfileMetrics] = [:]

        for name in requiredSFX {
            guard let url = Bundle.module.url(
                forResource: name,
                withExtension: "wav",
                subdirectory: "Extracted/sfx"
            ) else {
                continue
            }

            do {
                let data = try Data(contentsOf: url)
                payloadsByData[data, default: []].append(name)

                let file = try AVAudioFile(forReading: url)
                let duration = Double(file.length) / file.fileFormat.sampleRate
                let levels = try measurePCM16MonoLevels(at: url)
                profiles[name] = SFXProfileMetrics(
                    duration: duration,
                    rmsDBFS: levels.rmsDBFS,
                    peakDBFS: levels.peakDBFS
                )
            } catch {
                issues.append(
                    SFXIssue(
                        name: name,
                        message: "SFX profile validation failed: \(error.localizedDescription)"
                    )
                )
            }
        }

        for duplicateNames in payloadsByData.values where duplicateNames.count > 1 {
            issues.append(
                SFXIssue(
                    name: duplicateNames.sorted().joined(separator: ","),
                    message: "identical WAV payload reused by multiple audio events"
                )
            )
        }

        func requireRelationship(_ condition: Bool, name: String, message: String) {
            guard !condition else { return }
            issues.append(SFXIssue(name: name, message: message))
        }

        if let attack = profiles["sfx_hero_attack"],
           let critical = profiles["sfx_hero_critical_hit"] {
            requireRelationship(
                critical.duration > attack.duration,
                name: "sfx_hero_critical_hit",
                message: "critical-hit SFX should be longer than basic attack SFX"
            )
            requireRelationship(
                critical.rmsDBFS >= attack.rmsDBFS - 1.0,
                name: "sfx_hero_critical_hit",
                message: "critical-hit SFX should keep comparable energy to basic attack SFX"
            )
        }

        if let attack = profiles["sfx_hero_attack"],
           let skill = profiles["sfx_skill_cast"] {
            requireRelationship(
                skill.duration > attack.duration,
                name: "sfx_skill_cast",
                message: "skill-cast SFX should be longer than basic attack SFX"
            )
        }

        if let preview = profiles["sfx_preview"],
           let levelUp = profiles["sfx_level_up"] {
            requireRelationship(
                levelUp.duration > preview.duration * 2,
                name: "sfx_level_up",
                message: "level-up SFX should read as a longer progression cue than preview SFX"
            )
            requireRelationship(
                levelUp.peakDBFS >= preview.peakDBFS,
                name: "sfx_level_up",
                message: "level-up SFX should not peak quieter than preview SFX"
            )
        }

        if let equipped = profiles["sfx_item_equipped"],
           let consumed = profiles["sfx_item_consumed"] {
            requireRelationship(
                consumed.duration >= equipped.duration,
                name: "sfx_item_consumed",
                message: "item-consumed SFX should be at least as long as item-equipped SFX"
            )
            requireRelationship(
                consumed.peakDBFS >= equipped.peakDBFS,
                name: "sfx_item_consumed",
                message: "item-consumed SFX should not peak quieter than item-equipped SFX"
            )
        }

        return issues
    }

    private static func validateSFXManifestPayloads() -> [SFXIssue] {
        var issues: [SFXIssue] = []
        let expectedHeader = [
            "resourceName",
            "event",
            "provenance",
            "officialAudio",
            "sampleRate",
            "channels",
            "bitDepth",
            "durationSeconds",
            "sha256",
            "bytes",
            "note"
        ]

        guard let manifestData = resourceData(
            named: "sfx_manifest",
            withExtension: "tsv",
            subdirectory: "Extracted/sfx"
        ) else {
            return [
                SFXIssue(
                    name: "sfx_manifest.tsv",
                    message: "missing SFX provenance manifest"
                )
            ]
        }

        guard let manifestText = String(data: manifestData, encoding: .utf8) else {
            return [
                SFXIssue(
                    name: "sfx_manifest.tsv",
                    message: "SFX provenance manifest is not valid UTF-8"
                )
            ]
        }

        var lines = manifestText
            .split(whereSeparator: \.isNewline)
            .map(String.init)
        guard !lines.isEmpty else {
            return [
                SFXIssue(
                    name: "sfx_manifest.tsv",
                    message: "SFX provenance manifest is empty"
                )
            ]
        }

        let header = lines.removeFirst().split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
        if header != expectedHeader {
            issues.append(
                SFXIssue(
                    name: "sfx_manifest.tsv",
                    message: "SFX manifest header mismatch: \(header.joined(separator: ","))"
                )
            )
        }

        var rowsByResourceName: [String: SFXManifestRow] = [:]
        for (lineIndex, line) in lines.enumerated() {
            let columns = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard columns.count == expectedHeader.count else {
                issues.append(
                    SFXIssue(
                        name: "sfx_manifest.tsv",
                        message: "line \(lineIndex + 2) has \(columns.count) columns, expected \(expectedHeader.count)"
                    )
                )
                continue
            }

            let row = SFXManifestRow(
                resourceName: columns[0],
                event: columns[1],
                provenance: columns[2],
                officialAudio: columns[3],
                sampleRate: columns[4],
                channels: columns[5],
                bitDepth: columns[6],
                durationSeconds: columns[7],
                sha256: columns[8],
                bytes: columns[9],
                note: columns[10]
            )

            if rowsByResourceName[row.resourceName] != nil {
                issues.append(
                    SFXIssue(
                        name: row.resourceName,
                        message: "duplicate SFX manifest row"
                    )
                )
            }
            rowsByResourceName[row.resourceName] = row
        }

        let expectedResourceNames = Set(requiredSFX)
        let manifestResourceNames = Set(rowsByResourceName.keys)

        for missingResource in expectedResourceNames.subtracting(manifestResourceNames).sorted() {
            issues.append(
                SFXIssue(
                    name: missingResource,
                    message: "missing from SFX provenance manifest"
                )
            )
        }

        for extraResource in manifestResourceNames.subtracting(expectedResourceNames).sorted() {
            issues.append(
                SFXIssue(
                    name: extraResource,
                    message: "manifest row is not referenced by GameAudioEvent"
                )
            )
        }

        for event in GameAudioEvent.allCases {
            let resourceName = event.bundledResourceName
            guard let row = rowsByResourceName[resourceName] else {
                continue
            }

            if row.event != event.rawValue {
                issues.append(
                    SFXIssue(
                        name: resourceName,
                        message: "manifest event \(row.event) does not match GameAudioEvent.\(event.rawValue)"
                    )
                )
            }

            if row.provenance != "generated_substitute" {
                issues.append(
                    SFXIssue(
                        name: resourceName,
                        message: "manifest provenance must stay generated_substitute until isolated original SFX are available"
                    )
                )
            }

            if row.officialAudio != "false" {
                issues.append(
                    SFXIssue(
                        name: resourceName,
                        message: "manifest officialAudio must be false for local substitute SFX"
                    )
                )
            }

            if !row.note.contains("not extracted from original TBH") {
                issues.append(
                    SFXIssue(
                        name: resourceName,
                        message: "manifest note must explicitly state the cue is not extracted from original TBH"
                    )
                )
            }

            guard let data = resourceData(
                named: resourceName,
                withExtension: "wav",
                subdirectory: "Extracted/sfx"
            ) else {
                issues.append(
                    SFXIssue(
                        name: resourceName,
                        message: "manifested SFX payload is missing"
                    )
                )
                continue
            }

            if row.bytes != String(data.count) {
                issues.append(
                    SFXIssue(
                        name: resourceName,
                        message: "manifest bytes \(row.bytes) does not match payload \(data.count)"
                    )
                )
            }

            let digest = sha256Hex(data)
            if row.sha256 != digest {
                issues.append(
                    SFXIssue(
                        name: resourceName,
                        message: "manifest SHA-256 \(row.sha256) does not match payload \(digest)"
                    )
                )
            }

            guard let url = Bundle.module.url(
                forResource: resourceName,
                withExtension: "wav",
                subdirectory: "Extracted/sfx"
            ) else {
                continue
            }

            do {
                let file = try AVAudioFile(forReading: url)
                let format = file.fileFormat
                let streamDescription = format.streamDescription.pointee
                let duration = Double(file.length) / format.sampleRate
                let checks = [
                    ("sampleRate", row.sampleRate, String(Int(format.sampleRate.rounded()))),
                    ("channels", row.channels, String(format.channelCount)),
                    ("bitDepth", row.bitDepth, String(streamDescription.mBitsPerChannel)),
                    ("durationSeconds", row.durationSeconds, String(format: "%.3f", duration))
                ]

                for (field, actualManifestValue, expectedPayloadValue) in checks
                    where actualManifestValue != expectedPayloadValue {
                    issues.append(
                        SFXIssue(
                            name: resourceName,
                            message: "manifest \(field)=\(actualManifestValue) does not match payload \(expectedPayloadValue)"
                        )
                    )
                }
            } catch {
                issues.append(
                    SFXIssue(
                        name: resourceName,
                        message: "manifest payload validation failed: \(error.localizedDescription)"
                    )
                )
            }
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

    private static func bigEndianUInt32(in data: Data, at offset: Int) -> UInt32 {
        guard offset >= 0, offset + 4 <= data.count else { return 0 }
        return (UInt32(data[offset]) << 24) |
            (UInt32(data[offset + 1]) << 16) |
            (UInt32(data[offset + 2]) << 8) |
            UInt32(data[offset + 3])
    }

    private static func resourceData(
        named name: String,
        withExtension resourceExtension: String,
        subdirectory: String
    ) -> Data? {
        guard let url = Bundle.module.url(
            forResource: name,
            withExtension: resourceExtension,
            subdirectory: subdirectory
        ) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    private static func sha256Hex(_ data: Data) -> String {
        let digest = sha256(data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func sha256(_ data: Data) -> [UInt8] {
        var message = [UInt8](data)
        let bitLength = UInt64(message.count) * 8

        message.append(0x80)
        while message.count % 64 != 56 {
            message.append(0)
        }
        for shift in stride(from: 56, through: 0, by: -8) {
            message.append(UInt8((bitLength >> UInt64(shift)) & 0xff))
        }

        var h0: UInt32 = 0x6a09e667
        var h1: UInt32 = 0xbb67ae85
        var h2: UInt32 = 0x3c6ef372
        var h3: UInt32 = 0xa54ff53a
        var h4: UInt32 = 0x510e527f
        var h5: UInt32 = 0x9b05688c
        var h6: UInt32 = 0x1f83d9ab
        var h7: UInt32 = 0x5be0cd19

        let k: [UInt32] = [
            0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
            0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
            0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
            0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
            0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
            0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
            0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
            0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
            0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
            0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
            0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
            0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
            0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
            0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
            0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
            0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
        ]

        for chunkStart in stride(from: 0, to: message.count, by: 64) {
            var w = Array(repeating: UInt32(0), count: 64)

            for index in 0..<16 {
                let offset = chunkStart + index * 4
                w[index] = (UInt32(message[offset]) << 24) |
                    (UInt32(message[offset + 1]) << 16) |
                    (UInt32(message[offset + 2]) << 8) |
                    UInt32(message[offset + 3])
            }

            for index in 16..<64 {
                let s0 = rightRotate(w[index - 15], by: 7) ^
                    rightRotate(w[index - 15], by: 18) ^
                    (w[index - 15] >> 3)
                let s1 = rightRotate(w[index - 2], by: 17) ^
                    rightRotate(w[index - 2], by: 19) ^
                    (w[index - 2] >> 10)
                w[index] = w[index - 16] &+ s0 &+ w[index - 7] &+ s1
            }

            var a = h0
            var b = h1
            var c = h2
            var d = h3
            var e = h4
            var f = h5
            var g = h6
            var h = h7

            for index in 0..<64 {
                let s1 = rightRotate(e, by: 6) ^ rightRotate(e, by: 11) ^ rightRotate(e, by: 25)
                let ch = (e & f) ^ ((~e) & g)
                let temp1 = h &+ s1 &+ ch &+ k[index] &+ w[index]
                let s0 = rightRotate(a, by: 2) ^ rightRotate(a, by: 13) ^ rightRotate(a, by: 22)
                let maj = (a & b) ^ (a & c) ^ (b & c)
                let temp2 = s0 &+ maj

                h = g
                g = f
                f = e
                e = d &+ temp1
                d = c
                c = b
                b = a
                a = temp1 &+ temp2
            }

            h0 = h0 &+ a
            h1 = h1 &+ b
            h2 = h2 &+ c
            h3 = h3 &+ d
            h4 = h4 &+ e
            h5 = h5 &+ f
            h6 = h6 &+ g
            h7 = h7 &+ h
        }

        var digest: [UInt8] = []
        digest.reserveCapacity(32)
        for word in [h0, h1, h2, h3, h4, h5, h6, h7] {
            digest.append(UInt8((word >> 24) & 0xff))
            digest.append(UInt8((word >> 16) & 0xff))
            digest.append(UInt8((word >> 8) & 0xff))
            digest.append(UInt8(word & 0xff))
        }
        return digest
    }

    private static func rightRotate(_ value: UInt32, by count: UInt32) -> UInt32 {
        (value >> count) | (value << (32 - count))
    }
}
