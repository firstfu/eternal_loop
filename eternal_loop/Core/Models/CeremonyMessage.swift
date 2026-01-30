//
//  CeremonyMessage.swift
//  eternal_loop
//

import Foundation

struct CeremonyMessage: Codable {
    enum MessageType: String, Codable {
        case sessionInfo
        case distanceUpdate
        case readyToSend
        case ringSent
        case ringReceived
        case ceremonyComplete
    }

    let type: MessageType
    let payload: Data?

    init(type: MessageType, payload: Data? = nil) {
        self.type = type
        self.payload = payload
    }

    static func sessionInfo(hostNickname: String, guestNickname: String, ring: RingType, message: String) -> CeremonyMessage {
        let info = SessionInfo(hostNickname: hostNickname, guestNickname: guestNickname, ring: ring, message: message)
        let data = try? JSONEncoder().encode(info)
        return CeremonyMessage(type: .sessionInfo, payload: data)
    }

    static func distanceUpdate(_ distance: Float) -> CeremonyMessage {
        let data = withUnsafeBytes(of: distance) { Data($0) }
        return CeremonyMessage(type: .distanceUpdate, payload: data)
    }

    static let readyToSend = CeremonyMessage(type: .readyToSend)
    static let ringSent = CeremonyMessage(type: .ringSent)
    static let ringReceived = CeremonyMessage(type: .ringReceived)
    static let ceremonyComplete = CeremonyMessage(type: .ceremonyComplete)
}

struct SessionInfo: Codable {
    let hostNickname: String
    let guestNickname: String
    let ring: RingType
    let message: String
}
