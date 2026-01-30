//
//  HeartbeatHapticsTests.swift
//  eternal_loopTests
//

import XCTest
@testable import eternal_loop

final class HeartbeatHapticsTests: XCTestCase {

    func testHapticsInitialization() {
        let haptics = HeartbeatHaptics()
        // Should not crash
        XCTAssertNotNil(haptics)
    }

    func testIntervalForDistance() {
        let haptics = HeartbeatHaptics()

        XCTAssertNil(haptics.intervalForDistance(3.0))
        XCTAssertEqual(haptics.intervalForDistance(1.5), 2.0)
        XCTAssertEqual(haptics.intervalForDistance(0.5), 1.0)
        XCTAssertEqual(haptics.intervalForDistance(0.1), 0.5)
        XCTAssertEqual(haptics.intervalForDistance(0.03), 0.2)
    }

    func testStopHeartbeat() {
        let haptics = HeartbeatHaptics()
        haptics.updateForDistance(0.5)
        haptics.stopHeartbeat()
        // Should not crash
    }
}
