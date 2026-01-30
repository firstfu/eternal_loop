//
//  CertificateTemplate.swift
//  eternal_loop
//

import SwiftUI

struct CertificateTemplate: View {
    let hostName: String
    let guestName: String
    let ringType: RingType
    let date: Date

    private let certificateSize = CGSize(width: 1080, height: 1920)

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient

            // Decorative elements
            decorativeElements

            // Main content
            VStack(spacing: Spacing.xxl) {
                Spacer()

                // Title
                titleSection

                Spacer()

                // Names
                namesSection

                // Ring icon
                ringSection

                Spacer()

                // Date and footer
                footerSection

                Spacer()
            }
            .padding(Spacing.xxl)

            // Border frame
            borderFrame
        }
        .frame(width: certificateSize.width, height: certificateSize.height)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.appPrimaryDark,
                Color.appBackgroundDark,
                Color.appPrimaryDark.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Decorative Elements

    private var decorativeElements: some View {
        ZStack {
            // Top left sparkle
            Image(systemName: "sparkle")
                .font(.system(size: 40))
                .foregroundColor(Color.particleGold.opacity(0.3))
                .position(x: 120, y: 200)

            // Top right sparkle
            Image(systemName: "sparkle")
                .font(.system(size: 30))
                .foregroundColor(Color.particleGold.opacity(0.2))
                .position(x: 960, y: 280)

            // Bottom left hearts
            Image(systemName: "heart.fill")
                .font(.system(size: 25))
                .foregroundColor(Color.appAccent.opacity(0.2))
                .position(x: 100, y: 1650)

            // Bottom right hearts
            Image(systemName: "heart.fill")
                .font(.system(size: 35))
                .foregroundColor(Color.appAccent.opacity(0.15))
                .position(x: 980, y: 1700)
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: Spacing.lg) {
            Text("Certificate of Love")
                .font(.system(size: 32, weight: .light, design: .serif))
                .foregroundColor(Color.appAccentGold)
                .tracking(8)

            // Decorative line
            HStack(spacing: Spacing.md) {
                Rectangle()
                    .fill(Color.appAccentGold.opacity(0.5))
                    .frame(width: 100, height: 1)

                Image(systemName: "heart.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color.appAccentGold)

                Rectangle()
                    .fill(Color.appAccentGold.opacity(0.5))
                    .frame(width: 100, height: 1)
            }
        }
    }

    // MARK: - Names Section

    private var namesSection: some View {
        VStack(spacing: Spacing.xl) {
            // Host name
            Text(hostName)
                .font(.system(size: 72, weight: .light, design: .serif))
                .foregroundColor(.appTextPrimary)

            // Ampersand
            Text("&")
                .font(.system(size: 48, weight: .ultraLight, design: .serif))
                .foregroundColor(Color.appAccent)

            // Guest name
            Text(guestName)
                .font(.system(size: 72, weight: .light, design: .serif))
                .foregroundColor(.appTextPrimary)
        }
    }

    // MARK: - Ring Section

    private var ringSection: some View {
        VStack(spacing: Spacing.md) {
            // Ring icon with glow
            ZStack {
                Circle()
                    .fill(Color.particleGold.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Image(systemName: "ring")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.particleGold, Color.appAccentGold],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            Text(ringType.displayName)
                .font(.appCaption)
                .foregroundColor(Color.appTextSecondary)
                .tracking(2)
        }
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: Spacing.lg) {
            Text(formattedDate)
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundColor(Color.appTextSecondary)

            // App branding
            HStack(spacing: Spacing.sm) {
                Image(systemName: "infinity")
                    .font(.system(size: 16))
                Text("Eternal Loop")
                    .font(.system(size: 14, weight: .light))
            }
            .foregroundColor(Color.appTextSecondary.opacity(0.6))
        }
    }

    // MARK: - Border Frame

    private var borderFrame: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.appAccentGold.opacity(0.6),
                        Color.appAccentGold.opacity(0.2),
                        Color.appAccentGold.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
            .padding(40)
    }
}

#Preview {
    CertificateTemplate(
        hostName: "Alan",
        guestName: "Emily",
        ringType: .classicSolitaire,
        date: Date()
    )
    .scaleEffect(0.3)
}
