//
//  HostCeremonyViewTests.swift
//  eternal_loopTests
//

import XCTest
import SwiftUI
@testable import eternal_loop

final class HostCeremonyViewTests: XCTestCase {

    func testHostCeremonyViewCreation() async {
        await MainActor.run {
            let state = CeremonyState()

            let view = HostCeremonyView(ceremonyState: state) {
                // Ring sent callback
            }

            XCTAssertNotNil(view)
        }
    }

    func testCeremonyStatePhaseUpdates() async {
        await MainActor.run {
            let state = CeremonyState()

            // Initially searching
            XCTAssertEqual(state.phase, .searching)

            // Connected but far
            state.isConnected = true
            state.distance = 1.5
            state.updatePhase()
            XCTAssertEqual(state.phase, .approaching)

            // Very close
            state.distance = 0.03
            state.updatePhase()
            XCTAssertEqual(state.phase, .readyToSend)
        }
    }
}
