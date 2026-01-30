//
//  GuestCeremonyViewTests.swift
//  eternal_loopTests
//

import XCTest
import SwiftUI
@testable import eternal_loop

final class GuestCeremonyViewTests: XCTestCase {

    // TODO: Re-enable when iOS 26 @Observable XCTest crash is fixed
    // Tests using @Observable classes crash in iOS 26.2 beta test environment.

    func testRingTypeForGuest() {
        // Verify ring types have display names for guest view
        XCTAssertEqual(RingType.classicSolitaire.displayName, "經典單鑽")
        XCTAssertEqual(RingType.haloLuxury.displayName, "奢華光環")
        XCTAssertEqual(RingType.minimalistBand.displayName, "簡約素圈")
    }

    func testCeremonyPhaseForGuest() {
        // Verify ceremony phases exist
        XCTAssertEqual(CeremonyPhase.sending.rawValue, "sending")
        XCTAssertEqual(CeremonyPhase.arExperience.rawValue, "arExperience")
        XCTAssertEqual(CeremonyPhase.complete.rawValue, "complete")
    }
}
