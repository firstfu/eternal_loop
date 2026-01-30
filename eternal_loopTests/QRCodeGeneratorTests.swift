//
//  QRCodeGeneratorTests.swift
//  eternal_loopTests
//

import XCTest
@testable import eternal_loop

final class QRCodeGeneratorTests: XCTestCase {

    func testQRCodeGeneration() {
        let sessionId = UUID()
        let image = QRCodeGenerator.generate(sessionId: sessionId)

        XCTAssertNotNil(image)
        XCTAssertGreaterThan(image!.size.width, 0)
        XCTAssertGreaterThan(image!.size.height, 0)
    }

    func testQRCodeIsDeterministic() {
        let sessionId = UUID()
        let image1 = QRCodeGenerator.generate(sessionId: sessionId)
        let image2 = QRCodeGenerator.generate(sessionId: sessionId)

        XCTAssertNotNil(image1)
        XCTAssertNotNil(image2)
        XCTAssertEqual(image1?.size, image2?.size)
    }
}
