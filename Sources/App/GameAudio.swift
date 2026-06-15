import AppKit
import Combine
import Foundation

/// 游戏音效事件。优先使用包内原创像素风短音效，缺失时回退到系统短音效。
enum GameAudioEvent: String, CaseIterable {
    case heroAttack
    case heroCriticalHit
    case skillCast
    case heroDamaged
    case battleWon
    case lootFound
    case battleLost
    case levelUp
    case itemEquipped
    case preview
}

protocol GameAudioPlaying: AnyObject {
    var isEnabled: Bool { get set }
    func play(_ event: GameAudioEvent)
}

final class GameAudio: ObservableObject, GameAudioPlaying {
    static let shared = GameAudio()

    @Published var isEnabled: Bool = true

    private var sounds: [GameAudioEvent: NSSound] = [:]
    private var lastPlayedAt: [GameAudioEvent: Date] = [:]

    private init() {
        for event in GameAudioEvent.allCases {
            if let sound = event.bundledSound ?? NSSound(named: event.systemSoundName) {
                sound.volume = event.volume
                sounds[event] = sound
            }
        }
    }

    func play(_ event: GameAudioEvent) {
        guard isEnabled else { return }

        let now = Date()
        if let lastPlayed = lastPlayedAt[event],
           now.timeIntervalSince(lastPlayed) < event.minimumInterval {
            return
        }
        lastPlayedAt[event] = now

        let playBlock = { [weak self] in
            guard let self else { return }
            if let sound = self.sounds[event] {
                sound.stop()
                sound.currentTime = 0
                sound.play()
            } else {
                NSSound.beep()
            }
        }

        if Thread.isMainThread {
            playBlock()
        } else {
            DispatchQueue.main.async(execute: playBlock)
        }
    }
}

extension GameAudioEvent {
    static var bundledResourceNames: [String] {
        allCases.map(\.bundledResourceName)
    }

    var bundledResourceName: String {
        switch self {
        case .heroAttack: return "sfx_hero_attack"
        case .heroCriticalHit: return "sfx_hero_critical_hit"
        case .skillCast: return "sfx_skill_cast"
        case .heroDamaged: return "sfx_hero_damaged"
        case .battleWon: return "sfx_battle_won"
        case .lootFound: return "sfx_loot_found"
        case .battleLost: return "sfx_battle_lost"
        case .levelUp: return "sfx_level_up"
        case .itemEquipped: return "sfx_item_equipped"
        case .preview: return "sfx_preview"
        }
    }
}

extension GameAudioEvent {
    fileprivate var bundledSound: NSSound? {
        guard let url = Bundle.module.url(
            forResource: bundledResourceName,
            withExtension: "wav",
            subdirectory: "Extracted/sfx"
        ) else {
            return nil
        }
        return NSSound(contentsOf: url, byReference: false)
    }

    fileprivate var systemSoundName: String {
        switch self {
        case .heroAttack: return "Tink"
        case .heroCriticalHit: return "Pop"
        case .skillCast: return "Funk"
        case .heroDamaged: return "Blow"
        case .battleWon: return "Hero"
        case .lootFound: return "Glass"
        case .battleLost: return "Basso"
        case .levelUp: return "Ping"
        case .itemEquipped: return "Pop"
        case .preview: return "Glass"
        }
    }

    var volume: Float {
        switch self {
        case .heroAttack, .heroCriticalHit, .skillCast, .heroDamaged:
            return 0.42
        case .lootFound, .itemEquipped, .preview:
            return 0.36
        case .battleWon, .battleLost, .levelUp:
            return 0.46
        }
    }

    var minimumInterval: TimeInterval {
        switch self {
        case .heroAttack, .heroCriticalHit, .skillCast, .heroDamaged:
            return 0.18
        case .lootFound, .itemEquipped, .preview:
            return 0.25
        case .battleWon, .battleLost, .levelUp:
            return 0.5
        }
    }
}
