//
//  ModelsTests.swift
//  eternal_loopTests
//

import XCTest
@testable import eternal_loop

final class ModelsTests: XCTestCase {

    func testRingTypeDisplayName() {
        XCTAssertEqual(RingType.classicSolitaire.displayName, "經典單鑽")
        XCTAssertEqual(RingType.haloLuxury.displayName, "奢華光環")
        XCTAssertEqual(RingType.minimalistBand.displayName, "簡約素圈")
    }

    func testRingTypeModelFileName() {
        XCTAssertEqual(RingType.classicSolitaire.modelFileName, "ring_classic.usdz")
        XCTAssertEqual(RingType.haloLuxury.modelFileName, "ring_halo.usdz")
        XCTAssertEqual(RingType.minimalistBand.modelFileName, "ring_minimal.usdz")
    }

    func testRingTypeAllCases() {
        XCTAssertEqual(RingType.allCases.count, 3)
    }

    // MARK: - CeremonyState Tests
    // Note: These tests are disabled due to a known bug in iOS 26.2 beta
    // where @Observable macro causes crashes in the test environment.
    // The tests pass when run individually but crash in batch runs.

    func testCeremonyStateInitialValues() async {
        await MainActor.run {
            let state = CeremonyState()
            XCTAssertEqual(state.phase, .searching)
            XCTAssertEqual(state.distance, .infinity)
            XCTAssertFalse(state.isConnected)
        }
    }

    func testHeartbeatIntervalForDistance() async {
        await MainActor.run {
            let state = CeremonyState()

            state.distance = 3.0
            XCTAssertNil(state.heartbeatInterval)

            state.distance = 1.5
            XCTAssertEqual(state.heartbeatInterval, 2.0)

            state.distance = 0.5
            XCTAssertEqual(state.heartbeatInterval, 1.0)

            state.distance = 0.1
            XCTAssertEqual(state.heartbeatInterval, 0.5)

            state.distance = 0.03
            XCTAssertEqual(state.heartbeatInterval, 0.1)
        }
    }

    func testPhaseTransitions() async {
        await MainActor.run {
            let state = CeremonyState()
            state.isConnected = true

            state.distance = 1.5
            state.updatePhase()
            XCTAssertEqual(state.phase, .approaching)

            state.distance = 0.03
            state.updatePhase()
            XCTAssertEqual(state.phase, .readyToSend)
        }
    }

    func testCeremonyMessageEncoding() throws {
        let message = CeremonyMessage.sessionInfo(
            hostNickname: "Alan",
            guestNickname: "Emily",
            ring: .classicSolitaire,
            message: "Marry me"
        )

        XCTAssertEqual(message.type, .sessionInfo)
        XCTAssertNotNil(message.payload)
    }

    func testDistanceUpdateMessage() {
        let message = CeremonyMessage.distanceUpdate(1.5)
        XCTAssertEqual(message.type, .distanceUpdate)
        XCTAssertNotNil(message.payload)
    }

    func testProposalSessionCreation() {
        let session = ProposalSession(
            hostNickname: "Alan",
            guestNickname: "Emily",
            message: "Marry me",
            selectedRing: .classicSolitaire
        )

        XCTAssertNotNil(session.id)
        XCTAssertEqual(session.hostNickname, "Alan")
        XCTAssertEqual(session.guestNickname, "Emily")
        XCTAssertEqual(session.message, "Marry me")
        XCTAssertEqual(session.selectedRing, .classicSolitaire)
        XCTAssertNil(session.completedAt)
    }
}
