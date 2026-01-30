//
//  HeartbeatHaptics.swift
//  eternal_loop
//

import Foundation
import CoreHaptics

class HeartbeatHaptics {
    // MARK: - Properties

    private var engine: CHHapticEngine?
    private var heartbeatPlayer: CHHapticPatternPlayer?
    private var timer: Timer?
    private var currentInterval: TimeInterval = 2.0

    var isSupported: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    // MARK: - Initialization

    init() {
        setupEngine()
    }

    private func setupEngine() {
        guard isSupported else { return }

        do {
            engine = try CHHapticEngine()
            engine?.stoppedHandler = { [weak self] reason in
                print("Haptic engine stopped: \(reason)")
                self?.engine = nil
            }
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            try engine?.start()
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }

    // MARK: - Heartbeat Pattern

    private func createHeartbeatPattern(intensity: Float) throws -> CHHapticPattern {
        // lub-dub heartbeat pattern
        let beat1 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0
        )

        let beat2 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0.15
        )

        return try CHHapticPattern(events: [beat1, beat2], parameters: [])
    }

    // MARK: - Distance-based Updates

    func updateForDistance(_ distance: Float) {
        let interval: TimeInterval?
        let intensity: Float

        switch distance {
        case 2.0...:
            interval = nil
            intensity = 0
        case 1.0..<2.0:
            interval = 2.0
            intensity = 0.4
        case 0.2..<1.0:
            interval = 1.0
            intensity = 0.6
        case 0.05..<0.2:
            interval = 0.5
            intensity = 0.8
        case ..<0.05:
            interval = 0.2
            intensity = 1.0
        default:
            interval = nil
            intensity = 0
        }

        if let interval = interval {
            startHeartbeat(interval: interval, intensity: intensity)
        } else {
            stopHeartbeat()
        }
    }

    func intervalForDistance(_ distance: Float) -> TimeInterval? {
        switch distance {
        case 2.0...: return nil
        case 1.0..<2.0: return 2.0
        case 0.2..<1.0: return 1.0
        case 0.05..<0.2: return 0.5
        case ..<0.05: return 0.2
        default: return nil
        }
    }

    // MARK: - Playback Control

    private func startHeartbeat(interval: TimeInterval, intensity: Float) {
        guard isSupported, let engine = engine else { return }

        // Only restart if interval changed
        guard interval != currentInterval else { return }
        currentInterval = interval

        stopHeartbeat()

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playHeartbeat(intensity: intensity)
        }
        // Play immediately
        playHeartbeat(intensity: intensity)
    }

    private func playHeartbeat(intensity: Float) {
        guard isSupported, let engine = engine else { return }

        do {
            let pattern = try createHeartbeatPattern(intensity: intensity)
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play heartbeat: \(error)")
        }
    }

    func stopHeartbeat() {
        timer?.invalidate()
        timer = nil
        currentInterval = 2.0
    }

    // MARK: - Special Effects

    func playRingSentImpact() {
        guard isSupported, let engine = engine else { return }

        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play impact: \(error)")
        }
    }

    func playRingAttachedCelebration() {
        guard isSupported, let engine = engine else { return }

        do {
            var events: [CHHapticEvent] = []

            // Rapid succession of impacts
            for i in 0..<5 {
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                    ],
                    relativeTime: Double(i) * 0.1
                )
                events.append(event)
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play celebration: \(error)")
        }
    }

    deinit {
        stopHeartbeat()
        engine?.stop()
    }
}
