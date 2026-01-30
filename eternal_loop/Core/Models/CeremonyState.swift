//
//  CeremonyState.swift
//  eternal_loop
//

import Foundation
import Observation

enum CeremonyPhase: String, Codable, Sendable {
    case searching
    case approaching
    case readyToSend
    case sending
    case arExperience
    case complete
}

@Observable
class CeremonyState {
    var phase: CeremonyPhase = .searching
    var distance: Float = .infinity
    var isConnected: Bool = false
    var partnerNickname: String = ""
    var ring: RingType = .classicSolitaire
    var message: String = ""

    var heartbeatInterval: TimeInterval? {
        switch distance {
        case 2.0...: return nil
        case 1.0..<2.0: return 2.0
        case 0.2..<1.0: return 1.0
        case 0.05..<0.2: return 0.5
        case ..<0.05: return 0.1
        default: return nil
        }
    }

    func updatePhase() {
        guard isConnected else {
            phase = .searching
            return
        }
        switch distance {
        case 0.05...: phase = .approaching
        case ..<0.05: phase = .readyToSend
        default: phase = .searching
        }
    }
}
