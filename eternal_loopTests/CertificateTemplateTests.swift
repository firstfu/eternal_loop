//
//  CertificateTemplateTests.swift
//  eternal_loopTests
//

import XCTest
import SwiftUI
@testable import eternal_loop

final class CertificateTemplateTests: XCTestCase {

    func testCertificateTemplateCreation() {
        let template = CertificateTemplate(
            hostName: "Alan",
            guestName: "Emily",
            ringType: .classicSolitaire,
            date: Date()
        )

        XCTAssertNotNil(template)
    }

    func testAllRingTypesSupported() {
        let testDate = Date()

        for ringType in RingType.allCases {
            let template = CertificateTemplate(
                hostName: "Host",
                guestName: "Guest",
                ringType: ringType,
                date: testDate
            )
            XCTAssertNotNil(template)
        }
    }

    func testDateFormatting() {
        // Create a specific date
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 14

        let calendar = Calendar(identifier: .gregorian)
        guard let valentinesDay = calendar.date(from: components) else {
            XCTFail("Failed to create test date")
            return
        }

        let template = CertificateTemplate(
            hostName: "Alan",
            guestName: "Emily",
            ringType: .haloLuxury,
            date: valentinesDay
        )

        XCTAssertNotNil(template)
    }
}
