//
//  NearbyInteractionManagerTests.swift
//  eternal_loopTests
//

import XCTest
@testable import eternal_loop

final class NearbyInteractionManagerTests: XCTestCase {

    func testManagerInitialization() {
        let manager = NearbyInteractionManager()
        XCTAssertEqual(manager.distance, .infinity)
    }

    func testIsSupportedProperty() {
        let manager = NearbyInteractionManager()
        // Property should return without crash (actual value depends on device)
        _ = manager.isSupported
    }

    func testStop() {
        let manager = NearbyInteractionManager()
        manager.start()
        manager.stop()
        XCTAssertEqual(manager.distance, .infinity)
    }
}
