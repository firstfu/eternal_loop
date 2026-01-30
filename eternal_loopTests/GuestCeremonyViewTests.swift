//
//  GuestCeremonyViewTests.swift
//  eternal_loopTests
//

import XCTest
import SwiftUI
@testable import eternal_loop

final class GuestCeremonyViewTests: XCTestCase {

    func testGuestCeremonyViewCreation() async {
        await MainActor.run {
            let state = CeremonyState()
            var ringReceived = false

            let view = GuestCeremonyView(ceremonyState: state) {
                ringReceived = true
            }

            XCTAssertNotNil(view)
        }
    }

    func testGuestCeremonyStateBinding() async {
        await MainActor.run {
            let state = CeremonyState()
            state.partnerNickname = "Alan"
            state.message = "I love you"
            state.ring = .haloLuxury

            XCTAssertEqual(state.partnerNickname, "Alan")
            XCTAssertEqual(state.message, "I love you")
            XCTAssertEqual(state.ring, .haloLuxury)
        }
    }
}
