//
//  CeremonyCoordinator.swift
//  eternal_loop
//

import SwiftUI
import Observation

@Observable
class CeremonyCoordinator {
    // MARK: - Navigation State

    enum Screen: Equatable {
        case home
        case setup
        case qrCode
        case hostCeremony
        case guestCeremony
        case arExperience
        case certificate
    }

    var currentScreen: Screen = .home
    var isHost: Bool = true

    // MARK: - Shared State

    var ceremonyState = CeremonyState()
    var currentSession: ProposalSession?

    // MARK: - Managers

    private var multipeerManager: MultipeerManager?
    private var nearbyManager = NearbyInteractionManager()
    private var haptics = HeartbeatHaptics()
    private let certificateGenerator = CertificateGenerator()

    // MARK: - Setup Data

    var hostNickname: String = ""
    var guestNickname: String = ""
    var selectedRing: RingType = .classicSolitaire
    var confessionMessage: String = ""

    // MARK: - Initialization

    init() {
        // Managers are set up lazily when needed
    }

    // MARK: - Setup Multipeer Manager

    private func setupMultipeerManager(displayName: String) {
        multipeerManager = MultipeerManager(displayName: displayName)
        setupCallbacks()
    }

    // MARK: - Setup Callbacks

    private func setupCallbacks() {
        multipeerManager?.onConnected = { [weak self] in
            self?.handleConnection()
        }

        multipeerManager?.onMessageReceived = { [weak self] message in
            self?.handleMessage(message)
        }

        nearbyManager.onDistanceUpdate = { [weak self] distance in
            self?.handleDistanceUpdate(distance)
        }
    }

    // MARK: - Navigation Actions

    func startSetup() {
        isHost = true
        currentScreen = .setup
    }

    func completeSetup(hostName: String, guestName: String, ring: RingType, message: String) {
        hostNickname = hostName
        guestNickname = guestName
        selectedRing = ring
        confessionMessage = message

        // Create session
        currentSession = ProposalSession(
            hostNickname: hostName,
            guestNickname: guestName,
            message: message,
            selectedRing: ring
        )

        // Update ceremony state
        ceremonyState.ring = ring
        ceremonyState.message = message
        ceremonyState.partnerNickname = guestName

        // Setup multipeer manager with host name
        setupMultipeerManager(displayName: hostName)

        currentScreen = .qrCode
    }

    func startHostCeremony() {
        // Start advertising
        if let session = currentSession {
            multipeerManager?.startAdvertising(sessionId: session.id)
        }

        currentScreen = .hostCeremony
    }

    func sendRing() {
        ceremonyState.phase = .sending
        multipeerManager?.send(.ringSent)
        haptics.playRingSentImpact()

        // Wait for guest to receive ring then transition to AR
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.ceremonyState.phase = .arExperience
            self?.currentScreen = .arExperience
        }
    }

    func completeARExperience() {
        ceremonyState.phase = .complete
        multipeerManager?.send(.ceremonyComplete)
        haptics.playRingAttachedCelebration()

        // Mark session complete
        currentSession?.completedAt = Date()

        currentScreen = .certificate
    }

    @MainActor
    func generateCertificate() -> Data? {
        guard let session = currentSession else { return nil }
        return certificateGenerator.generateForSession(session)
    }

    @MainActor
    func saveCertificateToPhotos() async -> Bool {
        guard let session = currentSession else { return false }
        return await certificateGenerator.saveSessionToPhotos(session)
    }

    func resetAndGoHome() {
        // Stop all managers
        multipeerManager?.stopAdvertising()
        multipeerManager?.disconnect()
        nearbyManager.stop()
        haptics.stopHeartbeat()

        // Reset state
        ceremonyState = CeremonyState()
        currentSession = nil
        hostNickname = ""
        guestNickname = ""
        confessionMessage = ""
        multipeerManager = nil

        currentScreen = .home
    }

    func goBack() {
        switch currentScreen {
        case .setup:
            currentScreen = .home
        case .qrCode:
            currentScreen = .setup
        case .hostCeremony:
            multipeerManager?.stopAdvertising()
            currentScreen = .qrCode
        default:
            break
        }
    }

    // MARK: - Connection Handlers

    private func handleConnection() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.ceremonyState.isConnected = true

            // Send session info to guest
            if self.isHost {
                let message = CeremonyMessage.sessionInfo(
                    hostNickname: self.hostNickname,
                    guestNickname: self.guestNickname,
                    ring: self.selectedRing,
                    message: self.confessionMessage
                )
                self.multipeerManager?.send(message)
            }

            // Start UWB
            self.nearbyManager.start()

            // Exchange discovery tokens
            if let tokenData = self.nearbyManager.discoveryToken {
                self.multipeerManager?.sendDiscoveryToken(tokenData)
            }
        }
    }

    private func handleMessage(_ message: CeremonyMessage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            switch message.type {
            case .sessionInfo:
                if let payload = message.payload,
                   let info = try? JSONDecoder().decode(SessionInfo.self, from: payload) {
                    self.ceremonyState.partnerNickname = info.hostNickname
                    self.ceremonyState.ring = info.ring
                    self.ceremonyState.message = info.message
                }
            case .ringSent:
                self.ceremonyState.phase = .sending
                self.haptics.playRingSentImpact()
            case .ringReceived:
                // Host receives confirmation
                break
            case .ceremonyComplete:
                self.ceremonyState.phase = .complete
                self.haptics.playRingAttachedCelebration()
            default:
                break
            }
        }
    }

    private func handleDistanceUpdate(_ distance: Float) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.ceremonyState.distance = distance
            self.ceremonyState.updatePhase()
            self.haptics.updateForDistance(distance)
        }
    }
}
