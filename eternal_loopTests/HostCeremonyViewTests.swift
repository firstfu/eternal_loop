//
//  HostCeremonyViewTests.swift
//  eternal_loopTests
//

import XCTest
import SwiftUI
@testable import eternal_loop

final class HostCeremonyViewTests: XCTestCase {

    // TODO: Re-enable when iOS 26 @Observable XCTest crash is fixed
    // Tests using @Observable classes crash in iOS 26.2 beta test environment.

    func testCeremonyPhaseValues() {
        // Test enum values directly without @Observable class
        XCTAssertEqual(CeremonyPhase.searching.rawValue, "searching")
        XCTAssertEqual(CeremonyPhase.approaching.rawValue, "approaching")
        XCTAssertEqual(CeremonyPhase.readyToSend.rawValue, "readyToSend")
    }

    func testRingTypeForCeremony() {
        // Verify ring types are available for ceremony views
        XCTAssertEqual(RingType.allCases.count, 3)
        XCTAssertNotNil(RingType.classicSolitaire.displayName)
    }
}
