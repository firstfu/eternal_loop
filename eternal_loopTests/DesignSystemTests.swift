//
//  DesignSystemTests.swift
//  eternal_loopTests
//

import XCTest
import SwiftUI
@testable import eternal_loop

final class DesignSystemTests: XCTestCase {

    func testColorHexInitializer() {
        let color = Color(hex: "#FF0000")
        // Color initialized without crash
        XCTAssertNotNil(color)
    }

    func testSpacingValues() {
        XCTAssertEqual(Spacing.xs, 4)
        XCTAssertEqual(Spacing.sm, 8)
        XCTAssertEqual(Spacing.md, 16)
        XCTAssertEqual(Spacing.lg, 24)
        XCTAssertEqual(Spacing.xl, 32)
        XCTAssertEqual(Spacing.xxl, 48)
    }
}
