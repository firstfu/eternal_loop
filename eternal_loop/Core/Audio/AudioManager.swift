//
//  AudioManager.swift
//  eternal_loop
//

import AVFoundation
import Observation

/// Manages background music and sound effects for the ceremony
@Observable
class AudioManager {
    // MARK: - Singleton

    static let shared = AudioManager()

    // MARK: - Properties

    private var backgroundPlayer: AVAudioPlayer?
    private var effectPlayer: AVAudioPlayer?

    var isMusicEnabled: Bool = true {
        didSet {
            if !isMusicEnabled {
                stopBackgroundMusic()
            }
        }
    }

    var musicVolume: Float = 0.5 {
        didSet {
            backgroundPlayer?.volume = musicVolume
        }
    }

    var isPlaying: Bool {
        backgroundPlayer?.isPlaying ?? false
    }

    // MARK: - Music Types

    enum MusicType: String, CaseIterable {
        case romantic = "romantic_piano"
        case elegant = "elegant_strings"
        case celebration = "celebration"

        var displayName: String {
            switch self {
            case .romantic: return "浪漫鋼琴"
            case .elegant: return "優雅弦樂"
            case .celebration: return "歡慶曲"
            }
        }
    }

    enum SoundEffect: String {
        case heartbeat = "heartbeat"
        case ringAppear = "ring_appear"
        case success = "success"
        case connection = "connection"
    }

    // MARK: - Initialization

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Background Music

    func playBackgroundMusic(_ type: MusicType = .romantic, fadeIn: Bool = true) {
        guard isMusicEnabled else { return }

        // First try to load from bundle
        if let url = Bundle.main.url(forResource: type.rawValue, withExtension: "mp3") {
            playMusic(from: url, fadeIn: fadeIn)
            return
        }

        // If no custom music, use system sound as placeholder
        // In production, add actual music files
        print("Music file not found: \(type.rawValue).mp3")
    }

    private func playMusic(from url: URL, fadeIn: Bool) {
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1 // Loop indefinitely

            if fadeIn {
                backgroundPlayer?.volume = 0
                backgroundPlayer?.play()
                fadeInMusic()
            } else {
                backgroundPlayer?.volume = musicVolume
                backgroundPlayer?.play()
            }
        } catch {
            print("Failed to play music: \(error)")
        }
    }

    func stopBackgroundMusic(fadeOut: Bool = true) {
        guard let player = backgroundPlayer, player.isPlaying else { return }

        if fadeOut {
            fadeOutMusic {
                player.stop()
            }
        } else {
            player.stop()
        }
    }

    func pauseBackgroundMusic() {
        backgroundPlayer?.pause()
    }

    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        backgroundPlayer?.play()
    }

    // MARK: - Fade Effects

    private func fadeInMusic(duration: TimeInterval = 2.0) {
        guard let player = backgroundPlayer else { return }

        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeStep = musicVolume / Float(steps)

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                player.volume = min(volumeStep * Float(i + 1), self.musicVolume)
            }
        }
    }

    private func fadeOutMusic(duration: TimeInterval = 1.5, completion: @escaping () -> Void) {
        guard let player = backgroundPlayer else {
            completion()
            return
        }

        let steps = 15
        let stepDuration = duration / Double(steps)
        let currentVolume = player.volume
        let volumeStep = currentVolume / Float(steps)

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                player.volume = max(currentVolume - volumeStep * Float(i + 1), 0)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion()
        }
    }

    // MARK: - Sound Effects

    func playSoundEffect(_ effect: SoundEffect) {
        guard isMusicEnabled else { return }

        // Try to load from bundle
        if let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav") {
            do {
                effectPlayer = try AVAudioPlayer(contentsOf: url)
                effectPlayer?.volume = 0.7
                effectPlayer?.play()
            } catch {
                print("Failed to play sound effect: \(error)")
            }
        } else {
            // Use system sound as fallback
            playSystemSound(for: effect)
        }
    }

    private func playSystemSound(for effect: SoundEffect) {
        let soundID: SystemSoundID

        switch effect {
        case .heartbeat:
            soundID = 1052 // Tink
        case .ringAppear:
            soundID = 1057 // Fanfare
        case .success:
            soundID = 1025 // Success
        case .connection:
            soundID = 1054 // Tweet
        }

        AudioServicesPlaySystemSound(soundID)
    }

    // MARK: - Ceremony Presets

    /// Start ceremony music with appropriate settings
    func startCeremonyAmbiance() {
        playBackgroundMusic(.romantic, fadeIn: true)
    }

    /// Transition to celebration when ring is received
    func transitionToCelebration() {
        stopBackgroundMusic(fadeOut: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.playBackgroundMusic(.celebration, fadeIn: true)
        }
    }

    /// Stop all audio
    func stopAllAudio() {
        stopBackgroundMusic(fadeOut: false)
        effectPlayer?.stop()
    }
}
