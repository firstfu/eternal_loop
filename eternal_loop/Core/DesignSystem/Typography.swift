//
//  Typography.swift
//  eternal_loop
//

import SwiftUI

extension Font {
    // Display - Elegant handwriting style (for certificates)
    static let displayLarge = Font.custom("GreatVibes-Regular", size: 48)

    // Headings - Elegant serif
    static let headingLarge = Font.system(size: 28, weight: .light, design: .serif)
    static let headingMedium = Font.system(size: 22, weight: .light, design: .serif)
    static let headingSmall = Font.system(size: 18, weight: .medium, design: .serif)

    // Body
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .serif)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)

    // Caption
    static let appCaption = Font.system(size: 13, weight: .regular, design: .default)
}
