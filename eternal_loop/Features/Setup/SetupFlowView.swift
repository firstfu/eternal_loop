//
//  SetupFlowView.swift
//  eternal_loop
//

import SwiftUI

struct SetupFlowView: View {
    @State private var selectedRing: RingType = .classicSolitaire
    @State private var hostNickname = ""
    @State private var guestNickname = ""
    @State private var message = ""
    @State private var currentStep = 1

    var body: some View {
        Group {
            switch currentStep {
            case 1:
                RingSelectionView(selectedRing: $selectedRing) {
                    currentStep = 2
                }
            case 2:
                MessageInputView(
                    hostNickname: $hostNickname,
                    guestNickname: $guestNickname,
                    message: $message
                ) {
                    currentStep = 3
                }
            case 3:
                QRGeneratorView(sessionId: UUID()) {
                    // TODO: Navigate to ceremony
                }
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SetupFlowView()
    }
}
