//
//  HandTrackingManager.swift
//  eternal_loop
//

import Foundation
import Vision
import AVFoundation
import Observation

@Observable
class HandTrackingManager: NSObject {
    // MARK: - Properties

    private var captureSession: AVCaptureSession?
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private let processingQueue = DispatchQueue(label: "com.eternalloop.handtracking")

    var ringFingerPosition: CGPoint?
    var isTracking: Bool = false
    var handConfidence: Float = 0.0

    var onRingFingerUpdate: ((CGPoint?) -> Void)?

    // MARK: - Initialization

    override init() {
        super.init()
        handPoseRequest.maximumHandCount = 1
    }

    // MARK: - Session Management

    func startTracking() {
        guard !isTracking else { return }

        setupCaptureSession()

        processingQueue.async { [weak self] in
            self?.captureSession?.startRunning()
            DispatchQueue.main.async {
                self?.isTracking = true
            }
        }
    }

    func stopTracking() {
        processingQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            DispatchQueue.main.async {
                self?.isTracking = false
                self?.ringFingerPosition = nil
                self?.handConfidence = 0.0
            }
        }
    }

    private func setupCaptureSession() {
        guard captureSession == nil else { return }

        let session = AVCaptureSession()
        session.sessionPreset = .high

        // Setup camera input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Failed to setup camera input")
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        // Setup video output
        videoDataOutput.setSampleBufferDelegate(self, queue: processingQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }

        // Set video orientation
        if let connection = videoDataOutput.connection(with: .video) {
            connection.videoRotationAngle = 90
        }

        captureSession = session
    }

    // MARK: - Hand Processing

    private func processHandPose(from sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

        do {
            try handler.perform([handPoseRequest])

            guard let observation = handPoseRequest.results?.first else {
                DispatchQueue.main.async {
                    self.ringFingerPosition = nil
                    self.handConfidence = 0.0
                    self.onRingFingerUpdate?(nil)
                }
                return
            }

            // Get ring finger tip position
            let ringFingerTip = try observation.recognizedPoint(.ringTip)

            // Check confidence
            guard ringFingerTip.confidence > 0.3 else {
                DispatchQueue.main.async {
                    self.ringFingerPosition = nil
                    self.handConfidence = 0.0
                    self.onRingFingerUpdate?(nil)
                }
                return
            }

            // Convert to normalized coordinates (Vision uses bottom-left origin)
            let position = CGPoint(
                x: ringFingerTip.location.x,
                y: 1.0 - ringFingerTip.location.y
            )

            DispatchQueue.main.async {
                self.ringFingerPosition = position
                self.handConfidence = ringFingerTip.confidence
                self.onRingFingerUpdate?(position)
            }

        } catch {
            print("Hand pose detection failed: \(error)")
        }
    }

    // MARK: - Utility

    func convertToViewCoordinates(_ normalizedPoint: CGPoint, in viewSize: CGSize) -> CGPoint {
        return CGPoint(
            x: normalizedPoint.x * viewSize.width,
            y: normalizedPoint.y * viewSize.height
        )
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension HandTrackingManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        processHandPose(from: sampleBuffer)
    }
}
