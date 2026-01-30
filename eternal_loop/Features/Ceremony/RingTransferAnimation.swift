//
//  RingTransferAnimation.swift
//  eternal_loop
//

import SwiftUI

struct RingTransferAnimation: View {
    let ringType: RingType
    var onComplete: () -> Void

    @State private var ringOffset: CGFloat = 500
    @State private var ringScale: CGFloat = 0.3
    @State private var ringRotation: Double = -180
    @State private var glowOpacity: Double = 0
    @State private var particles: [Particle] = []
    @State private var showCompletionText: Bool = false

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            // Particles
            ForEach(particles) { particle in
                ParticleView(particle: particle)
            }

            // Ring with glow
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.particleGold.opacity(0.6), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .opacity(glowOpacity)

                // Ring icon
                Image(systemName: "ring")
                    .font(.system(size: 100, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.particleGold, Color.appAccentGold, Color.particleGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.particleGold.opacity(0.5), radius: 20)
            }
            .offset(y: ringOffset)
            .scaleEffect(ringScale)
            .rotation3DEffect(.degrees(ringRotation), axis: (x: 0, y: 1, z: 0))

            // Completion text
            if showCompletionText {
                VStack(spacing: Spacing.md) {
                    Text(ringType.displayName)
                        .font(.headingMedium)
                        .foregroundColor(.appTextPrimary)

                    Text("送達")
                        .font(.system(size: 48, weight: .thin, design: .serif))
                        .foregroundColor(.appAccent)
                }
                .offset(y: 150)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    // MARK: - Animation

    private func startAnimation() {
        // Generate particles
        generateParticles()

        // Phase 1: Ring flies in with rotation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            ringOffset = 0
            ringScale = 1.0
            ringRotation = 0
        }

        // Phase 2: Glow appears
        withAnimation(.easeIn(duration: 0.3).delay(0.5)) {
            glowOpacity = 1.0
        }

        // Phase 3: Show text
        withAnimation(.easeIn(duration: 0.3).delay(1.0)) {
            showCompletionText = true
        }

        // Phase 4: Complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            onComplete()
        }
    }

    private func generateParticles() {
        // Create particles with slight delay for cascade effect
        for i in 0..<20 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                let particle = Particle(
                    id: UUID(),
                    position: CGPoint(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 200...600)
                    ),
                    isHeart: i % 3 == 0
                )
                particles.append(particle)
            }
        }
    }
}

// MARK: - Particle Model

struct Particle: Identifiable {
    let id: UUID
    let position: CGPoint
    let isHeart: Bool
}

// MARK: - Particle View

struct ParticleView: View {
    let particle: Particle

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var yOffset: CGFloat = 0

    var body: some View {
        Group {
            if particle.isHeart {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color.heartbeatGlow)
            } else {
                Circle()
                    .fill(Color.particleGold)
                    .frame(width: 8, height: 8)
            }
        }
        .opacity(opacity)
        .scaleEffect(scale)
        .position(particle.position)
        .offset(y: yOffset)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                opacity = 1
                scale = CGFloat.random(in: 0.8...1.5)
                yOffset = CGFloat.random(in: -100...(-50))
            }

            withAnimation(.easeIn(duration: 0.5).delay(1.5)) {
                opacity = 0
            }
        }
    }
}

#Preview {
    RingTransferAnimation(ringType: .classicSolitaire) {
        print("Animation complete!")
    }
}
