//
//  CertificateGenerator.swift
//  eternal_loop
//

import SwiftUI
import Photos

@MainActor
class CertificateGenerator {

    // MARK: - Image Generation

    /// Generates a certificate image from the template
    /// - Parameters:
    ///   - hostName: The host's name
    ///   - guestName: The guest's name
    ///   - ringType: The selected ring type
    ///   - date: The ceremony date
    /// - Returns: The generated UIImage, or nil if generation failed
    func generateImage(
        hostName: String,
        guestName: String,
        ringType: RingType,
        date: Date
    ) -> UIImage? {
        let template = CertificateTemplate(
            hostName: hostName,
            guestName: guestName,
            ringType: ringType,
            date: date
        )

        let renderer = ImageRenderer(content: template)
        renderer.scale = 3.0 // High resolution

        return renderer.uiImage
    }

    /// Generates certificate image data
    /// - Parameters:
    ///   - hostName: The host's name
    ///   - guestName: The guest's name
    ///   - ringType: The selected ring type
    ///   - date: The ceremony date
    /// - Returns: PNG image data, or nil if generation failed
    func generateImageData(
        hostName: String,
        guestName: String,
        ringType: RingType,
        date: Date
    ) -> Data? {
        guard let image = generateImage(
            hostName: hostName,
            guestName: guestName,
            ringType: ringType,
            date: date
        ) else {
            return nil
        }

        return image.pngData()
    }

    // MARK: - Photos Library

    /// Saves the certificate to the Photos library
    /// - Parameters:
    ///   - hostName: The host's name
    ///   - guestName: The guest's name
    ///   - ringType: The selected ring type
    ///   - date: The ceremony date
    /// - Returns: True if save was successful
    func saveToPhotos(
        hostName: String,
        guestName: String,
        ringType: RingType,
        date: Date
    ) async -> Bool {
        guard let image = generateImage(
            hostName: hostName,
            guestName: guestName,
            ringType: ringType,
            date: date
        ) else {
            return false
        }

        // Request authorization
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)

        guard status == .authorized || status == .limited else {
            print("Photos permission denied")
            return false
        }

        // Save to library
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            return true
        } catch {
            print("Failed to save to Photos: \(error)")
            return false
        }
    }

    /// Checks if Photos library access is available
    /// - Returns: Current authorization status
    func checkPhotosAuthorization() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .addOnly)
    }

    /// Requests Photos library access
    /// - Returns: The resulting authorization status
    func requestPhotosAuthorization() async -> PHAuthorizationStatus {
        return await PHPhotoLibrary.requestAuthorization(for: .addOnly)
    }
}

// MARK: - Convenience Extension for ProposalSession

extension CertificateGenerator {

    /// Generates and saves certificate for a ProposalSession
    /// - Parameter session: The completed proposal session
    /// - Returns: The generated image data
    func generateForSession(_ session: ProposalSession) -> Data? {
        return generateImageData(
            hostName: session.hostNickname,
            guestName: session.guestNickname,
            ringType: session.selectedRing,
            date: session.completedAt ?? Date()
        )
    }

    /// Saves certificate for a ProposalSession to Photos
    /// - Parameter session: The completed proposal session
    /// - Returns: True if save was successful
    func saveSessionToPhotos(_ session: ProposalSession) async -> Bool {
        return await saveToPhotos(
            hostName: session.hostNickname,
            guestName: session.guestNickname,
            ringType: session.selectedRing,
            date: session.completedAt ?? Date()
        )
    }
}
