//
//  RingCardView.swift
//  eternal_loop
//

import SwiftUI

struct RingCardView: View {
    let ring: RingType
    let isSelected: Bool
    let onTap: () -> Void

    private var ringColor: Color {
        Color(hex: ring.previewColor) ?? .appAccentGold
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    // Ring glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [ringColor.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)

                    Image(systemName: "ring.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ringColor, ringColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .frame(height: 80)

                VStack(spacing: 4) {
                    Text(ring.displayName)
                        .font(.bodyMedium)
                        .fontWeight(.medium)
                        .foregroundColor(.appTextPrimary)

                    Text(ring.description)
                        .font(.appCaption)
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(height: 32)
                }

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .appPrimary : .appTextSecondary.opacity(0.5))
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appBackgroundDark.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.appPrimary : Color.appPrimary.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
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
