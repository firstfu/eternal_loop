//
//  RingTransferAnimationTests.swift
//  eternal_loopTests
//

import XCTest
import SwiftUI
@testable import eternal_loop

final class RingTransferAnimationTests: XCTestCase {

    func testRingTransferAnimationCreation() {
        var completed = false

        let view = RingTransferAnimation(ringType: .classicSolitaire) {
            completed = true
        }

        XCTAssertNotNil(view)
    }

    func testParticleCreation() {
        let particle = Particle(
            id: UUID(),
            position: CGPoint(x: 100, y: 200),
            isHeart: true
        )

        XCTAssertEqual(particle.position.x, 100)
        XCTAssertEqual(particle.position.y, 200)
        XCTAssertTrue(particle.isHeart)
    }

    func testAllRingTypesSupported() {
        for ringType in RingType.allCases {
            let view = RingTransferAnimation(ringType: ringType) {}
            XCTAssertNotNil(view)
        }
    }
}
