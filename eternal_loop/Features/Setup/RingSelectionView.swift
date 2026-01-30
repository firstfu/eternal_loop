//
//  RingSelectionView.swift
//  eternal_loop
//

import SwiftUI

struct RingSelectionView: View {
    @Binding var selectedRing: RingType
    let onNext: () -> Void

    var body: some View {
        ZStack {
            Color.appBackgroundDark
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.sm) {
                    Text("選擇一枚戒指")
                        .font(.headingLarge)
                        .foregroundColor(.appTextPrimary)
                }
                .padding(.top, Spacing.xl)

                HStack(spacing: Spacing.md) {
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

                Spacer()

                PrimaryButton(title: "下一步") {
                    onNext()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
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
