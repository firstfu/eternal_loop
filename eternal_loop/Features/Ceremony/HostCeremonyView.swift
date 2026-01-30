//
//  HostCeremonyView.swift
//  eternal_loop
//

import SwiftUI

struct HostCeremonyView: View {
    @Bindable var ceremonyState: CeremonyState
    var onSendRing: () -> Void

    @State private var heartScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var dragOffset: CGFloat = 0

    private let sendThreshold: CGFloat = -150

    var body: some View {
        ZStack {
            // Background
            Color.appBackgroundDark
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Status Text
                statusText

                // Heart with Glow
                heartView

                // Distance Indicator
                distanceIndicator

                Spacer()

                // Swipe Instruction (only when ready)
                if ceremonyState.phase == .readyToSend {
                    swipeInstruction
                }

                Spacer()
            }
            .padding(Spacing.lg)
        }
        .onAppear {
            startHeartbeatAnimation()
        }
        .onChange(of: ceremonyState.heartbeatInterval) { _, _ in
            startHeartbeatAnimation()
        }
    }

    // MARK: - Subviews

    private var statusText: some View {
        Text(statusMessage)
            .font(.headingMedium)
            .foregroundColor(.appTextPrimary)
            .multilineTextAlignment(.center)
    }

    private var heartView: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(Color.heartbeatGlow)
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .opacity(glowOpacity)

            // Heart icon
            Image(systemName: "heart.fill")
                .font(.system(size: 120))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appAccent, Color.heartbeatGlow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(heartScale)
        }
        .offset(y: dragOffset)
        .gesture(
            ceremonyState.phase == .readyToSend ?
            DragGesture()
                .onChanged { value in
                    if value.translation.height < 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height < sendThreshold {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            dragOffset = -500
                        }
                        onSendRing()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            dragOffset = 0
                        }
                    }
                }
            : nil
        )
    }

    private var distanceIndicator: some View {
        VStack(spacing: Spacing.sm) {
            if ceremonyState.distance < Float.infinity && ceremonyState.isConnected {
                Text(String(format: "%.2f m", ceremonyState.distance))
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundColor(.appTextPrimary)

                Text("距離")
                    .font(.appCaption)
                    .foregroundColor(.appTextSecondary)
            }
        }
    }

    private var swipeInstruction: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "chevron.up")
                .font(.system(size: 24))
                .foregroundColor(.appAccent)
                .floating(amplitude: 8, duration: 1.2)

            Text("向上滑動送出戒指")
                .font(.bodyMedium)
                .foregroundColor(.appTextSecondary)
        }
        .opacity(ceremonyState.phase == .readyToSend ? 1 : 0)
        .animation(.easeInOut, value: ceremonyState.phase)
    }

    // MARK: - Computed Properties

    private var statusMessage: String {
        switch ceremonyState.phase {
        case .searching:
            return "正在搜尋..."
        case .approaching:
            return "感應到 \(ceremonyState.partnerNickname)"
        case .readyToSend:
            return "準備好了！"
        case .sending:
            return "傳送中..."
        case .arExperience, .complete:
            return ""
        }
    }

    // MARK: - Animation

    private func startHeartbeatAnimation() {
        guard let interval = ceremonyState.heartbeatInterval else {
            // Reset to default when no heartbeat
            withAnimation(.easeInOut(duration: 0.3)) {
                heartScale = 1.0
                glowOpacity = 0.3
            }
            return
        }

        // Calculate glow based on distance
        let glowIntensity = max(0.3, min(1.0, 1.0 - Double(ceremonyState.distance / 2.0)))

        withAnimation(
            .easeInOut(duration: interval / 2)
            .repeatForever(autoreverses: true)
        ) {
            heartScale = 1.15
            glowOpacity = glowIntensity
        }
    }
}

#Preview {
    let state = CeremonyState()
    state.isConnected = true
    state.distance = 0.5
    state.partnerNickname = "Emily"
    state.updatePhase()

    return HostCeremonyView(ceremonyState: state) {
        print("Ring sent!")
    }
}
