//
//  ContentView.swift
//  eternal_loop
//
//  Created by firstfu on 2026/1/30.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [ProposalSession]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(sessions) { session in
                    NavigationLink {
                        Text("Session: \(session.hostNickname) & \(session.guestNickname)")
                    } label: {
                        VStack(alignment: .leading) {
                            Text("\(session.hostNickname) & \(session.guestNickname)")
                            Text(session.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteSessions)
            }
            .navigationTitle("Eternal Loop")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        } detail: {
            Text("Select a session")
        }
    }

    private func deleteSessions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sessions[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ProposalSession.self, inMemory: true)
}
