//
//  HomeView.swift
//  eternal_loop
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProposalSession.createdAt, order: .reverse) private var sessions: [ProposalSession]

    var onStartSetup: (() -> Void)?

    @State private var navigateToSetup = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundDark
                    .ignoresSafeArea()

                VStack(spacing: Spacing.xxl) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.appPrimaryLight.opacity(0.3), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)

                        Image(systemName: "ring.circle")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.appAccentGold, .appAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    VStack(spacing: Spacing.sm) {
                        Text("永恆之環")
                            .font(.headingLarge)
                            .foregroundColor(.appTextPrimary)

                        Text("Eternal Loop")
                            .font(.bodyMedium)
                            .foregroundColor(.appTextSecondary)
                    }

                    Spacer()

                    VStack(spacing: Spacing.md) {
                        PrimaryButton(title: "開始準備求婚") {
                            if let onStartSetup = onStartSetup {
                                onStartSetup()
                            } else {
                                navigateToSetup = true
                            }
                        }
                        .accessibilityIdentifier("startProposalButton")

                        if !sessions.isEmpty {
                            Button("查看過往紀念 →") {
                                // TODO: Navigate to history
                            }
                            .font(.bodyMedium)
                            .foregroundColor(.appTextSecondary)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .navigationDestination(isPresented: $navigateToSetup) {
                SetupFlowView(onComplete: nil, onBack: nil)
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: ProposalSession.self, inMemory: true)
}
