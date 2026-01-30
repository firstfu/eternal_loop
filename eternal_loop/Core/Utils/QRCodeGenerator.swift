//
//  QRCodeGenerator.swift
//  eternal_loop
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {
    static func generate(sessionId: UUID) -> UIImage? {
        let urlString = "https://eternalloop.app/join?session=\(sessionId.uuidString)"

        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(urlString.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        let scale = 10.0
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
