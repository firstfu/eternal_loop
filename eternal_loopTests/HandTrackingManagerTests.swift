//
//  HandTrackingManagerTests.swift
//  eternal_loopTests
//

import XCTest
@testable import eternal_loop

final class HandTrackingManagerTests: XCTestCase {

    func testManagerInitialization() {
        let manager = HandTrackingManager()

        XCTAssertNil(manager.ringFingerPosition)
        XCTAssertFalse(manager.isTracking)
        XCTAssertEqual(manager.handConfidence, 0.0)
    }

    func testConvertToViewCoordinates() {
        let manager = HandTrackingManager()
        let viewSize = CGSize(width: 400, height: 800)

        // Test center point
        let centerNormalized = CGPoint(x: 0.5, y: 0.5)
        let centerConverted = manager.convertToViewCoordinates(centerNormalized, in: viewSize)

        XCTAssertEqual(centerConverted.x, 200, accuracy: 0.001)
        XCTAssertEqual(centerConverted.y, 400, accuracy: 0.001)

        // Test corner point
        let cornerNormalized = CGPoint(x: 1.0, y: 1.0)
        let cornerConverted = manager.convertToViewCoordinates(cornerNormalized, in: viewSize)

        XCTAssertEqual(cornerConverted.x, 400, accuracy: 0.001)
        XCTAssertEqual(cornerConverted.y, 800, accuracy: 0.001)
    }

    func testStopTrackingResetsState() {
        let manager = HandTrackingManager()

        // Manually set some state
        manager.stopTracking()

        // After stopping, state should be reset
        XCTAssertFalse(manager.isTracking)
    }
}
