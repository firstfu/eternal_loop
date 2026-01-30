//
//  ARRingViewTests.swift
//  eternal_loopTests
//

import XCTest
import SwiftUI
@testable import eternal_loop

final class ARRingViewTests: XCTestCase {

    func testARRingViewCreation() {
        var completed = false

        let view = ARRingView(ringType: .classicSolitaire) {
            completed = true
        }

        XCTAssertNotNil(view)
    }

    func testAllRingTypesSupported() {
        for ringType in RingType.allCases {
            let view = ARRingView(ringType: ringType) {}
            XCTAssertNotNil(view)
        }
    }

    func testRingTypeModelFileName() {
        XCTAssertEqual(RingType.classicSolitaire.modelFileName, "ring_classic.usdz")
        XCTAssertEqual(RingType.haloLuxury.modelFileName, "ring_halo.usdz")
        XCTAssertEqual(RingType.minimalistBand.modelFileName, "ring_minimal.usdz")
    }
}
