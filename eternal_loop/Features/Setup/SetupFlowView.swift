//
//  SetupFlowView.swift
//  eternal_loop
//

import SwiftUI

struct SetupFlowView: View {
    // Callbacks for coordinator integration
    var onComplete: ((String, String, RingType, String) -> Void)?
    var onBack: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var selectedRing: RingType = .classicSolitaire
    @State private var hostNickname = ""
    @State private var guestNickname = ""
    @State private var message = ""
    @State private var currentStep = 1

    var body: some View {
        NavigationStack {
            Group {
                switch currentStep {
                case 1:
                    RingSelectionView(selectedRing: $selectedRing) {
                        currentStep = 2
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("返回") {
                                handleBack()
                            }
                            .foregroundColor(.appTextSecondary)
                        }
                    }
                case 2:
                    MessageInputView(
                        hostNickname: $hostNickname,
                        guestNickname: $guestNickname,
                        message: $message
                    ) {
                        handleComplete()
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("返回") {
                                currentStep = 1
                            }
                            .foregroundColor(.appTextSecondary)
                        }
                    }
                default:
                    EmptyView()
                }
            }
        }
    }

    private func handleBack() {
        if let onBack = onBack {
            onBack()
        } else {
            dismiss()
        }
    }

    private func handleComplete() {
        if let onComplete = onComplete {
            onComplete(hostNickname, guestNickname, selectedRing, message)
        } else {
            // Standalone mode - navigate to QR code
            currentStep = 3
        }
    }
}

#Preview {
    NavigationStack {
        SetupFlowView(onComplete: nil, onBack: nil)
    }
}
