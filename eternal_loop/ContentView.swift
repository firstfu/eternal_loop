//
//  ContentView.swift
//  eternal_loop
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ProposalSession.self, inMemory: true)
}
