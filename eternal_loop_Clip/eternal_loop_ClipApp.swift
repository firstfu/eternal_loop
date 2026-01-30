//
//  eternal_loop_ClipApp.swift
//  eternal_loop_Clip
//

import SwiftUI

@main
struct eternal_loop_ClipApp: App {
    @State private var sessionId: UUID?
    @State private var isReady: Bool = false

    var body: some Scene {
        WindowGroup {
            AppClipContentView(sessionId: $sessionId, isReady: $isReady)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    handleUserActivity(activity)
                }
        }
    }

    // MARK: - URL Handling

    private func handleIncomingURL(_ url: URL) {
        // Expected URL format: https://eternalloop.app/join?session=<UUID>
        // Or custom scheme: eternalloop://join?session=<UUID>
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems,
              let sessionItem = queryItems.first(where: { $0.name == "session" }),
              let sessionString = sessionItem.value,
              let uuid = UUID(uuidString: sessionString) else {
            print("Invalid URL format: \(url)")
            return
        }

        sessionId = uuid
        isReady = true
    }

    private func handleUserActivity(_ activity: NSUserActivity) {
        guard let url = activity.webpageURL else { return }
        handleIncomingURL(url)
    }
}
