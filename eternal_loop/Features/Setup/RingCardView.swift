//
//  RingCardView.swift
//  eternal_loop
//

import SwiftUI

struct RingCardView: View {
    let ring: RingType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appBackgroundDark)
                        .frame(height: 120)

                    Image(systemName: "ring.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.appAccentGold, .appAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Text(ring.displayName)
                    .font(.bodyMedium)
                    .foregroundColor(.appTextPrimary)

                Circle()
                    .fill(isSelected ? Color.appPrimary : Color.clear)
                    .stroke(Color.appPrimaryLight, lineWidth: 2)
                    .frame(width: 20, height: 20)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appBackgroundDark.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color.appPrimary : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("ringCard_\(ring.rawValue)")
    }
}

#Preview {
    HStack {
        RingCardView(ring: .classicSolitaire, isSelected: true) {}
        RingCardView(ring: .haloLuxury, isSelected: false) {}
    }
    .padding()
    .background(Color.appBackgroundDark)
}
