//
//  AppCoordinator.swift
//  eternal_loop
//

import SwiftUI

struct AppCoordinator: View {
    @State private var coordinator = CeremonyCoordinator()

    var body: some View {
        ZStack {
            switch coordinator.currentScreen {
            case .home:
                HomeView(
                    onStartSetup: {
                        coordinator.startSetup()
                    },
                    onShowHistory: {
                        coordinator.showHistory()
                    }
                )
                .transition(.opacity)

            case .history:
                HistoryView()
                    .transition(.move(edge: .trailing))

            case .setup:
                SetupFlowView(
                    onComplete: { host, guest, ring, message in
                        coordinator.completeSetup(
                            hostName: host,
                            guestName: guest,
                            ring: ring,
                            message: message
                        )
                    },
                    onBack: {
                        coordinator.goBack()
                    }
                )
                .transition(.move(edge: .trailing))

            case .qrCode:
                QRGeneratorView(
                    sessionId: coordinator.currentSession?.id ?? UUID(),
                    hostNickname: coordinator.hostNickname,
                    guestNickname: coordinator.guestNickname,
                    onStartCeremony: {
                        coordinator.startHostCeremony()
                    },
                    onBack: {
                        coordinator.goBack()
                    }
                )
                .transition(.move(edge: .trailing))

            case .hostCeremony:
                HostCeremonyView(
                    ceremonyState: coordinator.ceremonyState,
                    onSendRing: {
                        coordinator.sendRing()
                    }
                )
                .transition(.opacity)

            case .guestCeremony:
                GuestCeremonyView(
                    ceremonyState: coordinator.ceremonyState,
                    onRingReceived: {
                        coordinator.currentScreen = .arExperience
                    }
                )
                .transition(.opacity)

            case .arExperience:
                ARRingView(
                    ringType: coordinator.ceremonyState.ring,
                    onComplete: {
                        coordinator.completeARExperience()
                    }
                )
                .transition(.opacity)

            case .certificate:
                CertificateView(
                    coordinator: coordinator,
                    onDone: {
                        coordinator.resetAndGoHome()
                    }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentScreen)
    }
}

// MARK: - Certificate View

struct CertificateView: View {
    let coordinator: CeremonyCoordinator
    var onDone: () -> Void

    @State private var isSaving: Bool = false
    @State private var showSaveSuccess: Bool = false

    var body: some View {
        ZStack {
            Color.appBackgroundDark
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Title
                VStack(spacing: Spacing.md) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    Text("恭喜！")
                        .font(.headingLarge)
                        .foregroundColor(.appTextPrimary)

                    Text("儀式已完成")
                        .font(.bodyLarge)
                        .foregroundColor(.appTextSecondary)
                }

                Spacer()

                // Certificate preview
                if let session = coordinator.currentSession {
                    CertificateTemplate(
                        hostName: session.hostNickname,
                        guestName: session.guestNickname,
                        ringType: session.selectedRing,
                        date: session.completedAt ?? Date()
                    )
                    .scaleEffect(0.25)
                    .frame(height: 300)
                }

                Spacer()

                // Actions
                VStack(spacing: Spacing.md) {
                    Button(action: saveCertificate) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: showSaveSuccess ? "checkmark" : "square.and.arrow.down")
                            }
                            Text(showSaveSuccess ? "已儲存" : "儲存到相簿")
                        }
                        .font(.bodyLarge)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(showSaveSuccess ? Color.green : Color.appPrimary)
                        )
                    }
                    .disabled(isSaving)

                    Button(action: onDone) {
                        Text("完成")
                            .font(.bodyLarge)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .padding(.horizontal, Spacing.lg)

                Spacer()
            }
            .padding(Spacing.lg)
        }
    }

    private func saveCertificate() {
        isSaving = true
        Task {
            let success = await coordinator.saveCertificateToPhotos()
            await MainActor.run {
                isSaving = false
                if success {
                    showSaveSuccess = true
                }
            }
        }
    }
}

#Preview {
    AppCoordinator()
}
