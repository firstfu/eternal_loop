//
//  AppClipContentView.swift
//  eternal_loop_Clip
//

import SwiftUI

struct AppClipContentView: View {
    @Binding var sessionId: UUID?
    @Binding var isReady: Bool

    @State private var ceremonyState = CeremonyState()
    @State private var multipeerManager: MultipeerManager?
    @State private var nearbyManager = NearbyInteractionManager()
    @State private var haptics = HeartbeatHaptics()

    @State private var connectionStatus: ConnectionStatus = .searching

    enum ConnectionStatus {
        case searching
        case connecting
        case connected
        case ceremony
        case arExperience
        case complete
    }

    var body: some View {
        ZStack {
            Color.appBackgroundDark
                .ignoresSafeArea()

            switch connectionStatus {
            case .searching, .connecting:
                searchingView
            case .connected, .ceremony:
                GuestCeremonyView(ceremonyState: ceremonyState) {
                    connectionStatus = .arExperience
                }
            case .arExperience:
                ARRingView(ringType: ceremonyState.ring) {
                    connectionStatus = .complete
                    ceremonyState.phase = .complete
                }
            case .complete:
                completionView
            }
        }
        .onAppear {
            if isReady, let sessionId = sessionId {
                startConnection(sessionId: sessionId)
            }
        }
        .onChange(of: isReady) { _, newValue in
            if newValue, let sessionId = sessionId {
                startConnection(sessionId: sessionId)
            }
        }
    }

    // MARK: - Subviews

    private var searchingView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // App icon/logo
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "infinity")
                    .font(.system(size: 50))
                    .foregroundColor(.appPrimary)
            }

            Text("Eternal Loop")
                .font(.headingLarge)
                .foregroundColor(.appTextPrimary)

            Spacer()

            // Status
            VStack(spacing: Spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .appAccent))
                    .scaleEffect(1.5)

                Text(statusMessage)
                    .font(.bodyMedium)
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            // Instructions
            if sessionId == nil {
                instructionsView
            }

            Spacer()
        }
        .padding(Spacing.lg)
    }

    private var instructionsView: some View {
        VStack(spacing: Spacing.md) {
            Text("請掃描 QR Code")
                .font(.bodyLarge)
                .foregroundColor(.appTextPrimary)

            Text("或點擊邀請連結開始")
                .font(.appCaption)
                .foregroundColor(.appTextSecondary)
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appPrimary.opacity(0.1))
        )
    }

    private var completionView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appAccent, Color.heartbeatGlow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("恭喜！")
                .font(.headingLarge)
                .foregroundColor(.appTextPrimary)

            Text("你們的故事才剛開始")
                .font(.bodyLarge)
                .foregroundColor(.appTextSecondary)

            Spacer()

            // Download full app prompt
            VStack(spacing: Spacing.md) {
                Text("下載完整版 App")
                    .font(.bodyMedium)
                    .foregroundColor(.appTextPrimary)

                Text("保存你們的證書和回憶")
                    .font(.appCaption)
                    .foregroundColor(.appTextSecondary)

                Button(action: openAppStore) {
                    Text("前往 App Store")
                        .font(.bodyMedium)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.md)
                        .background(
                            Capsule()
                                .fill(Color.appPrimary)
                        )
                }
            }
            .padding(Spacing.lg)

            Spacer()
        }
        .padding(Spacing.lg)
    }

    // MARK: - Computed Properties

    private var statusMessage: String {
        switch connectionStatus {
        case .searching:
            return sessionId == nil ? "等待邀請連結..." : "搜尋中..."
        case .connecting:
            return "正在連接..."
        case .connected:
            return "已連接！"
        case .ceremony:
            return "儀式進行中"
        case .arExperience:
            return "AR 體驗"
        case .complete:
            return "完成！"
        }
    }

    // MARK: - Connection

    private func startConnection(sessionId: UUID) {
        connectionStatus = .connecting

        // Create MultipeerManager with guest display name
        let manager = MultipeerManager(displayName: "Guest-\(sessionId.uuidString.prefix(8))")
        multipeerManager = manager

        // Setup Multipeer
        manager.onConnected = {
            DispatchQueue.main.async {
                connectionStatus = .connected
                ceremonyState.isConnected = true

                // Start UWB
                nearbyManager.start()
            }
        }

        manager.onMessageReceived = { message in
            handleMessage(message)
        }

        // Start browsing for the host
        manager.startBrowsing()

        // Setup UWB distance updates
        nearbyManager.onDistanceUpdate = { distance in
            DispatchQueue.main.async {
                ceremonyState.distance = distance
                ceremonyState.updatePhase()
                haptics.updateForDistance(distance)
            }
        }
    }

    private func handleMessage(_ message: CeremonyMessage) {
        switch message.type {
        case .sessionInfo:
            if let payload = message.payload,
               let info = try? JSONDecoder().decode(SessionInfo.self, from: payload) {
                ceremonyState.partnerNickname = info.hostNickname
                ceremonyState.ring = info.ring
                ceremonyState.message = info.message
                connectionStatus = .ceremony
            }
        case .ringSent:
            ceremonyState.phase = .sending
            haptics.playRingSentImpact()
        case .ceremonyComplete:
            connectionStatus = .complete
        default:
            break
        }
    }

    // MARK: - Actions

    private func openAppStore() {
        // Replace with actual App Store URL
        if let url = URL(string: "https://apps.apple.com/app/eternal-loop/id123456789") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    AppClipContentView(
        sessionId: .constant(UUID()),
        isReady: .constant(true)
    )
}
