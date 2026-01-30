//
//  CertificateGeneratorTests.swift
//  eternal_loopTests
//

import XCTest
import SwiftUI
@testable import eternal_loop

@MainActor
final class CertificateGeneratorTests: XCTestCase {

    var generator: CertificateGenerator!

    override func setUp() {
        super.setUp()
        generator = CertificateGenerator()
    }

    override func tearDown() {
        generator = nil
        super.tearDown()
    }

    func testGeneratorInitialization() {
        XCTAssertNotNil(generator)
    }

    func testGenerateImage() {
        let image = generator.generateImage(
            hostName: "Alan",
            guestName: "Emily",
            ringType: .classicSolitaire,
            date: Date()
        )

        XCTAssertNotNil(image)
    }

    func testGenerateImageData() {
        let data = generator.generateImageData(
            hostName: "Alan",
            guestName: "Emily",
            ringType: .haloLuxury,
            date: Date()
        )

        XCTAssertNotNil(data)
        // PNG data should start with specific bytes
        if let data = data {
            XCTAssertTrue(data.count > 0)
        }
    }

    func testAllRingTypesGenerateImages() {
        for ringType in RingType.allCases {
            let image = generator.generateImage(
                hostName: "Test",
                guestName: "User",
                ringType: ringType,
                date: Date()
            )

            XCTAssertNotNil(image, "Failed to generate image for \(ringType.displayName)")
        }
    }

    func testGenerateForSession() {
        let session = ProposalSession(
            hostNickname: "Alan",
            guestNickname: "Emily",
            message: "Will you marry me?",
            selectedRing: .minimalistBand,
            completedAt: Date()
        )

        let data = generator.generateForSession(session)

        XCTAssertNotNil(data)
    }
}
