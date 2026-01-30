//
//  AnimationEffects.swift
//  eternal_loop
//

import SwiftUI

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: phase * 200 - 100)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Pulse Animation

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false

    let color: Color
    let duration: Double

    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
                    .scaleEffect(isPulsing ? 1.5 : 1)
                    .opacity(isPulsing ? 0 : 0.8)
            )
            .onAppear {
                withAnimation(.easeOut(duration: duration).repeatForever(autoreverses: false)) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func pulse(color: Color = .appPrimary, duration: Double = 1.5) -> some View {
        modifier(PulseEffect(color: color, duration: duration))
    }
}

// MARK: - Floating Animation

struct FloatingEffect: ViewModifier {
    @State private var isFloating = false

    let amplitude: CGFloat
    let duration: Double

    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -amplitude : amplitude)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    isFloating = true
                }
            }
    }
}

extension View {
    func floating(amplitude: CGFloat = 5, duration: Double = 2) -> some View {
        modifier(FloatingEffect(amplitude: amplitude, duration: duration))
    }
}

// MARK: - Sparkle Effect View

struct SparkleView: View {
    let count: Int
    let color: Color

    @State private var sparkles: [Sparkle] = []

    struct Sparkle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
        var rotation: Double
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(sparkles) { sparkle in
                    Image(systemName: "sparkle")
                        .font(.system(size: 12))
                        .foregroundColor(color)
                        .scaleEffect(sparkle.scale)
                        .opacity(sparkle.opacity)
                        .rotationEffect(.degrees(sparkle.rotation))
                        .position(x: sparkle.x, y: sparkle.y)
                }
            }
            .onAppear {
                startSparkleAnimation(in: geometry.size)
            }
        }
    }

    private func startSparkleAnimation(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            let newSparkle = Sparkle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: 1,
                rotation: Double.random(in: 0...360)
            )

            if sparkles.count < count {
                sparkles.append(newSparkle)
            }

            // Animate out
            withAnimation(.easeOut(duration: 1)) {
                if let index = sparkles.firstIndex(where: { $0.id == newSparkle.id }) {
                    sparkles[index].opacity = 0
                    sparkles[index].scale = 0
                }
            }

            // Remove after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                sparkles.removeAll { $0.id == newSparkle.id }
            }
        }
    }
}

// MARK: - Connection Success Animation

struct ConnectionSuccessView: View {
    @State private var showRing1 = false
    @State private var showRing2 = false
    @State private var showRing3 = false
    @State private var showCheckmark = false

    var body: some View {
        ZStack {
            // Expanding rings
            Circle()
                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 2)
                .scaleEffect(showRing1 ? 2 : 0.5)
                .opacity(showRing1 ? 0 : 1)

            Circle()
                .stroke(Color.appPrimary.opacity(0.5), lineWidth: 2)
                .scaleEffect(showRing2 ? 1.5 : 0.5)
                .opacity(showRing2 ? 0 : 1)

            Circle()
                .stroke(Color.appPrimary.opacity(0.7), lineWidth: 2)
                .scaleEffect(showRing3 ? 1 : 0.5)
                .opacity(showRing3 ? 0 : 1)

            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .scaleEffect(showCheckmark ? 1 : 0)
                .opacity(showCheckmark ? 1 : 0)
        }
        .frame(width: 120, height: 120)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showRing1 = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                showRing2 = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showRing3 = true
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3)) {
                showCheckmark = true
            }
        }
    }
}

// MARK: - Heart Beat Animation

struct HeartBeatView: View {
    @State private var isBeating = false
    let color: Color

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 40))
            .foregroundColor(color)
            .scaleEffect(isBeating ? 1.2 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    isBeating = true
                }
            }
    }
}

// MARK: - Ring Glow Animation

struct RingGlowView: View {
    @State private var glowAmount: CGFloat = 0.5

    var body: some View {
        ZStack {
            // Glow layers
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.appAccentGold.opacity(0.5 * glowAmount), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)

            // Ring icon
            Image(systemName: "ring.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.appAccentGold, .appAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowAmount = 1
            }
        }
    }
}

// MARK: - Confetti Effect

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let rotation: Double
    let scale: CGFloat
}

struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = []
    @State private var isAnimating = false

    let colors: [Color] = [.pink, .purple, .blue, .green, .yellow, .orange, .red]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(pieces) { piece in
                    Rectangle()
                        .fill(piece.color)
                        .frame(width: 8 * piece.scale, height: 12 * piece.scale)
                        .rotationEffect(.degrees(piece.rotation))
                        .position(x: piece.x, y: piece.y)
                }
            }
            .onAppear {
                createConfetti(in: geometry.size)
            }
        }
    }

    private func createConfetti(in size: CGSize) {
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                color: colors.randomElement() ?? .pink,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.5)
            )
            pieces.append(piece)
        }

        // Animate falling
        for i in pieces.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 2...4)

            withAnimation(.easeIn(duration: duration).delay(delay)) {
                pieces[i].y = size.height + 50
                pieces[i].x += CGFloat.random(in: -50...50)
            }
        }
    }
}

#Preview("Animations") {
    VStack(spacing: 40) {
        RingGlowView()

        ConnectionSuccessView()

        HeartBeatView(color: .pink)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackgroundDark)
}
