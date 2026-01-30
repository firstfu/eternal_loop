//
//  ModelLoader.swift
//  eternal_loop
//

import Foundation
import RealityKit
import Combine
import UIKit

/// Utility for loading 3D ring models with fallback support
class ModelLoader {

    // MARK: - Singleton

    static let shared = ModelLoader()

    private init() {}

    // MARK: - Model Loading

    /// Loads a ring model for the specified type
    /// - Parameter ringType: The type of ring to load
    /// - Returns: A ModelEntity, either from file or generated fallback
    func loadRingModel(for ringType: RingType) -> ModelEntity {
        // Try to load from bundle first
        if let modelEntity = loadFromBundle(ringType.modelFileName) {
            return modelEntity
        }

        // Try to load from Documents directory (for downloaded models)
        if let modelEntity = loadFromDocuments(ringType.modelFileName) {
            return modelEntity
        }

        // Fallback to generated geometry
        return generateFallbackRing(for: ringType)
    }

    /// Asynchronously loads a ring model
    /// - Parameters:
    ///   - ringType: The type of ring to load
    ///   - completion: Callback with the loaded model
    func loadRingModelAsync(for ringType: RingType, completion: @escaping (ModelEntity) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let model = self.loadRingModel(for: ringType)
            DispatchQueue.main.async {
                completion(model)
            }
        }
    }

    // MARK: - Private Loading Methods

    private func loadFromBundle(_ fileName: String) -> ModelEntity? {
        guard let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".usdz", with: ""),
                                         withExtension: "usdz") else {
            print("Model not found in bundle: \(fileName)")
            return nil
        }

        do {
            let entity = try Entity.load(contentsOf: url)
            if let modelEntity = entity as? ModelEntity {
                return modelEntity
            }
            // If it's not a ModelEntity, try to find one in children
            if let modelChild = entity.children.first(where: { $0 is ModelEntity }) as? ModelEntity {
                return modelChild
            }
            // Wrap in ModelEntity if needed
            let wrapper = ModelEntity()
            wrapper.addChild(entity)
            return wrapper
        } catch {
            print("Failed to load model from bundle: \(error)")
            return nil
        }
    }

    private func loadFromDocuments(_ fileName: String) -> ModelEntity? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let modelURL = documentsURL.appendingPathComponent("Models").appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: modelURL.path) else {
            return nil
        }

        do {
            let entity = try Entity.load(contentsOf: modelURL)
            if let modelEntity = entity as? ModelEntity {
                return modelEntity
            }
            let wrapper = ModelEntity()
            wrapper.addChild(entity)
            return wrapper
        } catch {
            print("Failed to load model from documents: \(error)")
            return nil
        }
    }

    // MARK: - Fallback Generation

    private func generateFallbackRing(for ringType: RingType) -> ModelEntity {
        switch ringType {
        case .classicSolitaire:
            return generateClassicSolitaire()
        case .haloLuxury:
            return generateHaloLuxury()
        case .minimalistBand:
            return generateMinimalistBand()
        }
    }

    /// Classic solitaire - gold band with a diamond-like gem on top
    private func generateClassicSolitaire() -> ModelEntity {
        // Ring band (using cylinder rotated to simulate a ring)
        let bandMesh = MeshResource.generateCylinder(height: 0.004, radius: 0.01)
        let goldMaterial = SimpleMaterial(
            color: .init(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0),
            roughness: 0.3,
            isMetallic: true
        )
        let band = ModelEntity(mesh: bandMesh, materials: [goldMaterial])
        band.orientation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(1, 0, 0))

        // Diamond (approximated with sphere)
        let diamondMesh = MeshResource.generateSphere(radius: 0.004)
        let diamondMaterial = SimpleMaterial(
            color: .init(white: 0.95, alpha: 0.9),
            roughness: 0.0,
            isMetallic: false
        )
        let diamond = ModelEntity(mesh: diamondMesh, materials: [diamondMaterial])
        diamond.position = SIMD3<Float>(0, 0.006, 0)

        // Combine
        let ring = ModelEntity()
        ring.addChild(band)
        ring.addChild(diamond)

        return ring
    }

    /// Halo luxury - gold band with center stone surrounded by smaller stones
    private func generateHaloLuxury() -> ModelEntity {
        // Ring band
        let bandMesh = MeshResource.generateCylinder(height: 0.005, radius: 0.01)
        let goldMaterial = SimpleMaterial(
            color: .init(red: 1.0, green: 0.78, blue: 0.0, alpha: 1.0),
            roughness: 0.2,
            isMetallic: true
        )
        let band = ModelEntity(mesh: bandMesh, materials: [goldMaterial])
        band.orientation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(1, 0, 0))

        // Center diamond
        let centerMesh = MeshResource.generateSphere(radius: 0.005)
        let diamondMaterial = SimpleMaterial(
            color: .init(white: 0.95, alpha: 0.9),
            roughness: 0.0,
            isMetallic: false
        )
        let center = ModelEntity(mesh: centerMesh, materials: [diamondMaterial])
        center.position = SIMD3<Float>(0, 0.007, 0)

        // Halo stones
        let haloMesh = MeshResource.generateSphere(radius: 0.0015)
        let ring = ModelEntity()
        ring.addChild(band)
        ring.addChild(center)

        // Add small stones around center
        let haloRadius: Float = 0.006
        for i in 0..<8 {
            let angle = Float(i) * (.pi * 2 / 8)
            let haloStone = ModelEntity(mesh: haloMesh, materials: [diamondMaterial])
            haloStone.position = SIMD3<Float>(
                cos(angle) * haloRadius,
                0.006,
                sin(angle) * haloRadius
            )
            ring.addChild(haloStone)
        }

        return ring
    }

    /// Minimalist band - simple polished metal ring
    private func generateMinimalistBand() -> ModelEntity {
        let bandMesh = MeshResource.generateCylinder(height: 0.006, radius: 0.01)
        let platinumMaterial = SimpleMaterial(
            color: .init(red: 0.9, green: 0.9, blue: 0.92, alpha: 1.0),
            roughness: 0.1,
            isMetallic: true
        )
        let band = ModelEntity(mesh: bandMesh, materials: [platinumMaterial])
        band.orientation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(1, 0, 0))

        return band
    }

    // MARK: - Model Management

    /// Checks if a model file exists for the given ring type
    func modelExists(for ringType: RingType) -> Bool {
        // Check bundle
        if Bundle.main.url(forResource: ringType.modelFileName.replacingOccurrences(of: ".usdz", with: ""),
                           withExtension: "usdz") != nil {
            return true
        }

        // Check documents
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let modelURL = documentsURL.appendingPathComponent("Models").appendingPathComponent(ringType.modelFileName)
            return FileManager.default.fileExists(atPath: modelURL.path)
        }

        return false
    }

    /// Returns the URL for the Models directory in Documents
    func modelsDirectoryURL() -> URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let modelsURL = documentsURL.appendingPathComponent("Models")

        // Create directory if needed
        if !FileManager.default.fileExists(atPath: modelsURL.path) {
            try? FileManager.default.createDirectory(at: modelsURL, withIntermediateDirectories: true)
        }

        return modelsURL
    }
}
