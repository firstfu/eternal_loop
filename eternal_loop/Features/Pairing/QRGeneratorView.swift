//
//  QRGeneratorView.swift
//  eternal_loop
//

import SwiftUI

struct QRGeneratorView: View {
    let sessionId: UUID
    var hostNickname: String = ""
    var guestNickname: String = ""
    var onStartCeremony: (() -> Void)?
    var onBack: (() -> Void)?

    // Legacy initializer support
    let onConnected: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var qrImage: UIImage?
    @State private var isConnecting = false

    init(sessionId: UUID, onConnected: @escaping () -> Void) {
        self.sessionId = sessionId
        self.onConnected = onConnected
        self.hostNickname = ""
        self.guestNickname = ""
        self.onStartCeremony = nil
        self.onBack = nil
    }

    init(
        sessionId: UUID,
        hostNickname: String,
        guestNickname: String,
        onStartCeremony: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) {
        self.sessionId = sessionId
        self.hostNickname = hostNickname
        self.guestNickname = guestNickname
        self.onStartCeremony = onStartCeremony
        self.onBack = onBack
        self.onConnected = onStartCeremony
    }

    var body: some View {
        ZStack {
            Color.appBackgroundDark
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Session info header
                if !hostNickname.isEmpty || !guestNickname.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Text("\(hostNickname) & \(guestNickname)")
                            .font(.headingMedium)
                            .foregroundColor(.appAccentGold)
                    }
                }

                Text("請對方掃描這個 QR Code")
                    .font(.headingMedium)
                    .foregroundColor(.appTextPrimary)

                if let qrImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                        )
                        .shadow(color: .appPrimary.opacity(0.3), radius: 20)
                } else {
                    ProgressView()
                        .frame(width: 200, height: 200)
                }

                VStack(spacing: Spacing.sm) {
                    Text("等待連線中...")
                        .font(.bodyMedium)
                        .foregroundColor(.appTextSecondary)

                    HStack(spacing: Spacing.sm) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.appPrimaryLight)
                                .frame(width: 8, height: 8)
                                .opacity(isConnecting ? 1 : 0.3)
                                .animation(
                                    .easeInOut(duration: 0.5)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: isConnecting
                                )
                        }
                    }
                }

                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ManualTriggerButton {
                        if let onStartCeremony = onStartCeremony {
                            onStartCeremony()
                        } else {
                            onConnected()
                        }
                    }
                    .padding(Spacing.xl)
                }
            }
        }
        .navigationTitle("步驟 3/3")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if onBack != nil {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        onBack?()
                    }
                    .foregroundColor(.appTextSecondary)
                }
            }
        }
        .onAppear {
            qrImage = QRCodeGenerator.generate(sessionId: sessionId)
            isConnecting = true
        }
    }
}

struct ManualTriggerButton: View {
    let onTrigger: () -> Void

    @State private var isPressed = false
    @State private var pressProgress: CGFloat = 0

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 20))
            .foregroundStyle(Color.appAccent.opacity(0.3))
            .scaleEffect(isPressed ? 1.2 : 1.0)
            .overlay {
                Circle()
                    .trim(from: 0, to: pressProgress)
                    .stroke(Color.appAccent, lineWidth: 2)
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))
            }
            .onLongPressGesture(minimumDuration: 3.0) {
                onTrigger()
            } onPressingChanged: { pressing in
                isPressed = pressing
                if pressing {
                    withAnimation(.linear(duration: 3.0)) {
                        pressProgress = 1.0
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.2)) {
                        pressProgress = 0
                    }
                }
            }
            .accessibilityIdentifier("manualTriggerButton")
    }
}

#Preview {
    NavigationStack {
        QRGeneratorView(sessionId: UUID()) {}
    }
}
