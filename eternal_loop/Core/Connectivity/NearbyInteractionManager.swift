//
//  NearbyInteractionManager.swift
//  eternal_loop
//

import Foundation
import NearbyInteraction
import Observation

@Observable
class NearbyInteractionManager: NSObject {
    // MARK: - Properties

    private var niSession: NISession?

    var distance: Float = .infinity
    var isSupported: Bool {
        NISession.deviceCapabilities.supportsPreciseDistanceMeasurement
    }

    var onDistanceUpdate: ((Float) -> Void)?

    // MARK: - Discovery Token

    var discoveryToken: Data? {
        guard let token = niSession?.discoveryToken else { return nil }
        return try? NSKeyedArchiver.archivedData(
            withRootObject: token,
            requiringSecureCoding: true
        )
    }

    // MARK: - Session Management

    func start() {
        guard isSupported else {
            print("UWB not supported on this device")
            return
        }

        niSession = NISession()
        niSession?.delegate = self
    }

    func configure(withPeerToken tokenData: Data) {
        guard let token = try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: NIDiscoveryToken.self,
            from: tokenData
        ) else {
            print("Failed to decode peer discovery token")
            return
        }

        let config = NINearbyPeerConfiguration(peerToken: token)
        niSession?.run(config)
    }

    func stop() {
        niSession?.invalidate()
        niSession = nil
        distance = .infinity
    }
}

// MARK: - NISessionDelegate

extension NearbyInteractionManager: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let nearbyObject = nearbyObjects.first,
              let distance = nearbyObject.distance else { return }

        DispatchQueue.main.async {
            self.distance = distance
            self.onDistanceUpdate?(distance)
        }
    }

    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        DispatchQueue.main.async {
            self.distance = .infinity
        }
    }

    func sessionWasSuspended(_ session: NISession) {
        print("NI Session suspended")
    }

    func sessionSuspensionEnded(_ session: NISession) {
        print("NI Session suspension ended")
    }

    func session(_ session: NISession, didInvalidateWith error: Error) {
        print("NI Session invalidated: \(error)")
        DispatchQueue.main.async {
            self.distance = .infinity
        }
    }
}
