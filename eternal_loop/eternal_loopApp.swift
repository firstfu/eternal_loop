//
//  eternal_loopApp.swift
//  eternal_loop
//

import SwiftUI
import SwiftData

@main
struct eternal_loopApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ProposalSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
