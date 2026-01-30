//
//  QRGeneratorView.swift
//  eternal_loop
//

import SwiftUI

struct QRGeneratorView: View {
    let sessionId: UUID
    let onConnected: () -> Void

    @State private var qrImage: UIImage?
    @State private var isConnecting = false

    var body: some View {
        ZStack {
            Color.appBackgroundDark
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

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
                        onConnected()
                    }
                    .padding(Spacing.xl)
                }
            }
        }
        .navigationTitle("步驟 3/3")
        .navigationBarTitleDisplayMode(.inline)
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
