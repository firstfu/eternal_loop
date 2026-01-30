//
//  ProposalSession.swift
//  eternal_loop
//

import Foundation
import SwiftData

@Model
class ProposalSession {
    var id: UUID
    var hostNickname: String
    var guestNickname: String
    var message: String
    var selectedRing: RingType
    var createdAt: Date
    var completedAt: Date?
    var certificateImageData: Data?

    init(
        id: UUID = UUID(),
        hostNickname: String,
        guestNickname: String,
        message: String,
        selectedRing: RingType,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        certificateImageData: Data? = nil
    ) {
        self.id = id
        self.hostNickname = hostNickname
        self.guestNickname = guestNickname
        self.message = message
        self.selectedRing = selectedRing
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.certificateImageData = certificateImageData
    }
}
