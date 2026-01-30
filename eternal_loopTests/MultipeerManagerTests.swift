//
//  MultipeerManagerTests.swift
//  eternal_loopTests
//

import XCTest
@testable import eternal_loop

final class MultipeerManagerTests: XCTestCase {

    func testManagerInitialization() {
        let manager = MultipeerManager(displayName: "TestHost")
        XCTAssertFalse(manager.isConnected)
        XCTAssertNil(manager.connectedPeerName)
    }

    func testStartBrowsing() {
        let manager = MultipeerManager(displayName: "TestHost")
        manager.startBrowsing()
        manager.stopBrowsing()
    }

    func testStartAdvertising() {
        let manager = MultipeerManager(displayName: "TestGuest")
        manager.startAdvertising(sessionId: UUID())
        manager.stopAdvertising()
    }

    func testDisconnect() {
        let manager = MultipeerManager(displayName: "Test")
        manager.startBrowsing()
        manager.disconnect()
        XCTAssertFalse(manager.isConnected)
    }
}
