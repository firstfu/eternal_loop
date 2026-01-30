//
//  ARRingView.swift
//  eternal_loop
//

import SwiftUI
import RealityKit
import ARKit

struct ARRingView: View {
    let ringType: RingType
    var onComplete: () -> Void

    @State private var handTracker = HandTrackingManager()
    @State private var ringPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var isRingPlaced: Bool = false
    @State private var showConfirmButton: Bool = false

    var body: some View {
        ZStack {
            // AR View
            ARViewContainer(ringType: ringType, ringPosition: $ringPosition)
                .ignoresSafeArea()

            // Overlay UI
            VStack {
                // Instructions
                instructionBanner

                Spacer()

                // Hand tracking indicator
                if !handTracker.isTracking || handTracker.ringFingerPosition == nil {
                    handNotDetectedView
                }

                Spacer()

                // Confirm button
                if showConfirmButton {
                    confirmButton
                }
            }
            .padding(Spacing.lg)
        }
        .onAppear {
            startHandTracking()
        }
        .onDisappear {
            handTracker.stopTracking()
        }
    }

    // MARK: - Subviews

    private var instructionBanner: some View {
        Text("將手掌面向相機")
            .font(.bodyMedium)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.6))
            )
    }

    private var handNotDetectedView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "hand.raised")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.7))

            Text("請將手掌面向相機")
                .font(.bodyLarge)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.5))
        )
    }

    private var confirmButton: some View {
        Button(action: {
            onComplete()
        }) {
            HStack(spacing: Spacing.md) {
                Image(systemName: "checkmark.circle.fill")
                Text("確認戴上")
            }
            .font(.headingMedium)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.lg)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary, Color.appAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Hand Tracking

    private func startHandTracking() {
        handTracker.onRingFingerUpdate = { position in
            if let pos = position {
                withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.8)) {
                    ringPosition = pos
                    isRingPlaced = true
                }

                // Show confirm button after stable detection
                if !showConfirmButton && handTracker.handConfidence > 0.5 {
                    withAnimation(.easeIn(duration: 0.3).delay(1.0)) {
                        showConfirmButton = true
                    }
                }
            } else {
                isRingPlaced = false
            }
        }

        handTracker.startTracking()
    }
}

// MARK: - AR View Container

struct ARViewContainer: UIViewRepresentable {
    let ringType: RingType
    @Binding var ringPosition: CGPoint

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = []
        arView.session.run(config)

        // Add ring entity
        let ringAnchor = AnchorEntity()

        // Load ring model using ModelLoader (handles fallback automatically)
        let ringEntity = ModelLoader.shared.loadRingModel(for: ringType)
        ringAnchor.addChild(ringEntity)

        arView.scene.addAnchor(ringAnchor)
        context.coordinator.ringAnchor = ringAnchor

        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {
        // Update ring position based on hand tracking
        guard let anchor = context.coordinator.ringAnchor else { return }

        // Position ring at a fixed distance from camera
        let transform = arView.cameraTransform
        var position = transform.translation

        // Offset based on normalized screen position (0-1 range)
        let offsetX = Float(ringPosition.x - 0.5) * 0.2
        let offsetY = Float(0.5 - ringPosition.y) * 0.2

        position.x += offsetX
        position.y += offsetY
        position.z -= 0.3 // 30cm in front of camera

        anchor.position = position
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var ringAnchor: AnchorEntity?
    }
}

#Preview {
    ARRingView(ringType: .classicSolitaire) {
        print("AR complete!")
    }
}
