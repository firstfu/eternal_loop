//
//  GuestCeremonyView.swift
//  eternal_loop
//

import SwiftUI

struct GuestCeremonyView: View {
    @Bindable var ceremonyState: CeremonyState
    var onRingReceived: () -> Void

    @State private var heartScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var ringScale: CGFloat = 0.0
    @State private var ringOpacity: Double = 0.0
    @State private var dotCount: Int = 0

    var body: some View {
        ZStack {
            // Background
            Color.appBackgroundDark
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Status Text
                statusText

                // Main Content
                mainContent

                // Partner's Message
                if ceremonyState.isConnected && !ceremonyState.message.isEmpty {
                    messageView
                }

                Spacer()

                // Ring Info
                if ceremonyState.isConnected {
                    ringInfoView
                }

                Spacer()
            }
            .padding(Spacing.lg)

            // Ring Receive Overlay
            if ceremonyState.phase == .sending {
                ringReceiveOverlay
            }
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: ceremonyState.heartbeatInterval) { _, _ in
            startHeartbeatAnimation()
        }
        .onChange(of: ceremonyState.phase) { _, newPhase in
            if newPhase == .sending {
                playRingReceiveAnimation()
            }
        }
    }

    // MARK: - Subviews

    private var statusText: some View {
        HStack(spacing: 4) {
            Text(statusMessage)
                .font(.headingMedium)
                .foregroundColor(.appTextPrimary)

            if ceremonyState.phase == .searching {
                Text(String(repeating: ".", count: dotCount))
                    .font(.headingMedium)
                    .foregroundColor(.appTextPrimary)
            }
        }
        .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var mainContent: some View {
        switch ceremonyState.phase {
        case .searching:
            // Waiting animation
            waitingView
        case .approaching, .readyToSend:
            // Heart with glow
            heartView
        case .sending:
            // Ring animation handled by overlay
            EmptyView()
        case .arExperience, .complete:
            EmptyView()
        }
    }

    private var waitingView: some View {
        ZStack {
            Circle()
                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 2)
                .frame(width: 150, height: 150)

            Circle()
                .stroke(Color.appPrimary, lineWidth: 2)
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(Double(dotCount) * 30))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: dotCount)
        }
    }

    private var heartView: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(Color.heartbeatGlow)
                .frame(width: 180, height: 180)
                .blur(radius: 50)
                .opacity(glowOpacity)

            // Heart icon
            Image(systemName: "heart.fill")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appAccent, Color.heartbeatGlow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(heartScale)
        }
    }

    private var messageView: some View {
        VStack(spacing: Spacing.sm) {
            Text("來自 \(ceremonyState.partnerNickname)")
                .font(.appCaption)
                .foregroundColor(.appTextSecondary)

            Text("\"\(ceremonyState.message)\"")
                .font(.bodyLarge)
                .foregroundColor(.appTextPrimary)
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
        }
    }

    private var ringInfoView: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: "ring")
                .font(.system(size: 24))
                .foregroundColor(.appAccentGold)

            Text(ceremonyState.ring.displayName)
                .font(.appCaption)
                .foregroundColor(.appTextSecondary)
        }
    }

    private var ringReceiveOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                // Animated ring
                ZStack {
                    // Glow
                    Circle()
                        .fill(Color.particleGold)
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                        .opacity(ringOpacity * 0.5)

                    // Ring icon
                    Image(systemName: "ring")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.particleGold, Color.appAccentGold],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                }

                Text("收到戒指！")
                    .font(.headingLarge)
                    .foregroundColor(.appTextPrimary)
                    .opacity(ringOpacity)
            }
        }
    }

    // MARK: - Computed Properties

    private var statusMessage: String {
        switch ceremonyState.phase {
        case .searching:
            return "等待連線"
        case .approaching:
            return "\(ceremonyState.partnerNickname) 靠近中"
        case .readyToSend:
            return "即將收到驚喜"
        case .sending:
            return ""
        case .arExperience:
            return "戴上你的戒指"
        case .complete:
            return "恭喜！"
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        // Dot animation for searching
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if ceremonyState.phase != .searching {
                timer.invalidate()
                return
            }
            dotCount = (dotCount + 1) % 4
        }

        startHeartbeatAnimation()
    }

    private func startHeartbeatAnimation() {
        guard let interval = ceremonyState.heartbeatInterval else {
            withAnimation(.easeInOut(duration: 0.3)) {
                heartScale = 1.0
                glowOpacity = 0.3
            }
            return
        }

        let glowIntensity = max(0.3, min(1.0, 1.0 - Double(ceremonyState.distance / 2.0)))

        withAnimation(
            .easeInOut(duration: interval / 2)
            .repeatForever(autoreverses: true)
        ) {
            heartScale = 1.12
            glowOpacity = glowIntensity
        }
    }

    private func playRingReceiveAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }

        // Transition to AR after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onRingReceived()
        }
    }
}

#Preview {
    let state = CeremonyState()
    state.isConnected = true
    state.distance = 0.5
    state.partnerNickname = "Alan"
    state.message = "Will you marry me?"
    state.ring = .classicSolitaire
    state.updatePhase()

    return GuestCeremonyView(ceremonyState: state) {
        print("Ring received!")
    }
}
