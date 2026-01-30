//
//  MultipeerManager.swift
//  eternal_loop
//

import Foundation
import MultipeerConnectivity
import Observation

@Observable
class MultipeerManager: NSObject {
    private let serviceType = "eternal-loop"
    private var peerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    var isConnected: Bool = false
    var connectedPeerName: String?
    var discoveryToken: Data?

    var onConnected: (() -> Void)?
    var onDisconnected: (() -> Void)?
    var onMessageReceived: ((CeremonyMessage) -> Void)?
    var onDiscoveryTokenReceived: ((Data) -> Void)?

    init(displayName: String) {
        self.peerID = MCPeerID(displayName: displayName)
        super.init()
    }

    private func createSession() {
        session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session?.delegate = self
    }

    func startBrowsing() {
        createSession()
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    func startAdvertising(sessionId: UUID) {
        createSession()
        let discoveryInfo = ["sessionId": sessionId.uuidString]
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: discoveryInfo,
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }

    func send(_ message: CeremonyMessage) {
        guard let session = session,
              !session.connectedPeers.isEmpty else { return }

        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send message: \(error)")
        }
    }

    func sendDiscoveryToken(_ token: Data) {
        guard let session = session,
              !session.connectedPeers.isEmpty else { return }

        do {
            try session.send(token, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send discovery token: \(error)")
        }
    }

    func disconnect() {
        session?.disconnect()
        stopBrowsing()
        stopAdvertising()
        isConnected = false
        connectedPeerName = nil
    }
}

extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.isConnected = true
                self.connectedPeerName = peerID.displayName
                self.onConnected?()
            case .notConnected:
                self.isConnected = false
                self.connectedPeerName = nil
                self.onDisconnected?()
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            if let message = try? JSONDecoder().decode(CeremonyMessage.self, from: data) {
                self.onMessageReceived?(message)
            } else {
                self.onDiscoveryTokenReceived?(data)
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let session = session else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
