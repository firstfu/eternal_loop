//
//  RingSelectionView.swift
//  eternal_loop
//

import SwiftUI

struct RingSelectionView: View {
    @Binding var selectedRing: RingType
    let onNext: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        ZStack {
            Color.appBackgroundDark
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                VStack(spacing: Spacing.sm) {
                    Text("選擇一枚戒指")
                        .font(.headingLarge)
                        .foregroundColor(.appTextPrimary)

                    Text("挑選一款代表你們愛情的戒指")
                        .font(.bodyMedium)
                        .foregroundColor(.appTextSecondary)
                }
                .padding(.top, Spacing.lg)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: Spacing.md) {
                        ForEach(RingType.allCases) { ring in
                            RingCardView(
                                ring: ring,
                                isSelected: selectedRing == ring
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedRing = ring
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }

                PrimaryButton(title: "下一步") {
                    onNext()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.lg)
                .accessibilityIdentifier("nextButton")
            }
        }
        .navigationTitle("步驟 1/3")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RingSelectionView(selectedRing: .constant(.classicSolitaire)) {}
    }
}
