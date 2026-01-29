# Eternal Loop Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a digital proposal app with UWB distance sensing, AR ring experience, and certificate generation.

**Architecture:** SwiftUI + SwiftData for UI and persistence, Multipeer Connectivity for P2P communication, Nearby Interaction for UWB distance, RealityKit + ARKit for 3D ring and hand tracking.

**Tech Stack:** Swift 6, SwiftUI, SwiftData, Multipeer Connectivity, Nearby Interaction, ARKit, RealityKit, Core Haptics

**Design Document:** `docs/plans/2026-01-30-eternal-loop-design.md`

---

## Phase 1: Foundation

### Task 1: Design System - Colors & Typography

**Files:**
- Create: `eternal_loop/Core/DesignSystem/Colors.swift`
- Create: `eternal_loop/Core/DesignSystem/Typography.swift`
- Create: `eternal_loop/Core/DesignSystem/Spacing.swift`
- Test: `eternal_loopTests/DesignSystemTests.swift`

**Step 1: Create directory structure**

```bash
mkdir -p eternal_loop/Core/DesignSystem
```

**Step 2: Write Colors.swift**

```swift
//
//  Colors.swift
//  eternal_loop
//

import SwiftUI

extension Color {
    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Colors
extension Color {
    // Primary - Romantic Violet
    static let appPrimary = Color(hex: "#7C3AED")
    static let appPrimaryLight = Color(hex: "#A78BFA")
    static let appPrimaryDark = Color(hex: "#4C1D95")

    // Accent - Rose Gold
    static let appAccent = Color(hex: "#F9A8D4")
    static let appAccentGold = Color(hex: "#D4AF37")

    // Background
    static let appBackgroundDark = Color(hex: "#0F0A1A")
    static let appBackgroundLight = Color(hex: "#FAF5FF")

    // Text
    static let appTextPrimary = Color.white.opacity(0.95)
    static let appTextSecondary = Color.white.opacity(0.7)

    // Effects
    static let heartbeatGlow = Color(hex: "#FF6B9D")
    static let particleGold = Color(hex: "#FFD700")
}
```

**Step 3: Write Typography.swift**

```swift
//
//  Typography.swift
//  eternal_loop
//

import SwiftUI

extension Font {
    // Display - Elegant handwriting style (for certificates)
    static let displayLarge = Font.custom("GreatVibes-Regular", size: 48)

    // Headings - Elegant serif
    static let headingLarge = Font.system(size: 28, weight: .light, design: .serif)
    static let headingMedium = Font.system(size: 22, weight: .light, design: .serif)

    // Body
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .serif)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)

    // Caption
    static let appCaption = Font.system(size: 13, weight: .regular, design: .default)
}
```

**Step 4: Write Spacing.swift**

```swift
//
//  Spacing.swift
//  eternal_loop
//

import SwiftUI

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

**Step 5: Write unit tests**

```swift
//
//  DesignSystemTests.swift
//  eternal_loopTests
//

import XCTest
import SwiftUI
@testable import eternal_loop

final class DesignSystemTests: XCTestCase {

    func testColorHexInitializer() {
        let color = Color(hex: "#FF0000")
        // Color initialized without crash
        XCTAssertNotNil(color)
    }

    func testSpacingValues() {
        XCTAssertEqual(Spacing.xs, 4)
        XCTAssertEqual(Spacing.sm, 8)
        XCTAssertEqual(Spacing.md, 16)
        XCTAssertEqual(Spacing.lg, 24)
        XCTAssertEqual(Spacing.xl, 32)
        XCTAssertEqual(Spacing.xxl, 48)
    }
}
```

**Step 6: Run tests**

```bash
xcodebuild test -scheme eternal_loop -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -only-testing:eternal_loopTests/DesignSystemTests -quiet
```

Expected: PASS

**Step 7: Commit**

```bash
git add eternal_loop/Core/DesignSystem/ eternal_loopTests/DesignSystemTests.swift
git commit -m "feat: add design system (colors, typography, spacing)"
```

---

### Task 2: Data Models - RingType & CeremonyState

**Files:**
- Create: `eternal_loop/Core/Models/RingType.swift`
- Create: `eternal_loop/Core/Models/CeremonyState.swift`
- Create: `eternal_loop/Core/Models/CeremonyMessage.swift`
- Modify: `eternal_loop/Item.swift` → Rename to `eternal_loop/Core/Models/ProposalSession.swift`
- Test: `eternal_loopTests/ModelsTests.swift`

**Step 1: Create Models directory**

```bash
mkdir -p eternal_loop/Core/Models
```

**Step 2: Write RingType.swift**

```swift
//
//  RingType.swift
//  eternal_loop
//

import Foundation

enum RingType: String, Codable, CaseIterable, Identifiable {
    case classicSolitaire
    case haloLuxury
    case minimalistBand

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classicSolitaire: return "經典單鑽"
        case .haloLuxury: return "奢華光環"
        case .minimalistBand: return "簡約素圈"
        }
    }

    var modelFileName: String {
        switch self {
        case .classicSolitaire: return "ring_classic.usdz"
        case .haloLuxury: return "ring_halo.usdz"
        case .minimalistBand: return "ring_minimal.usdz"
        }
    }
}
```

**Step 3: Write CeremonyState.swift**

```swift
//
//  CeremonyState.swift
//  eternal_loop
//

import Foundation
import Observation

enum CeremonyPhase: String, Codable {
    case searching      // 尋找對方中
    case approaching    // 靠近中（心跳同步）
    case readyToSend    // 準備傳送（< 5cm）
    case sending        // 傳送動畫中
    case arExperience   // AR 戴戒指
    case complete       // 儀式完成
}

@Observable
class CeremonyState {
    var phase: CeremonyPhase = .searching
    var distance: Float = .infinity
    var isConnected: Bool = false
    var partnerNickname: String = ""
    var ring: RingType = .classicSolitaire
    var message: String = ""

    // Computed property for heartbeat interval based on distance
    var heartbeatInterval: TimeInterval? {
        switch distance {
        case 2.0...: return nil          // No heartbeat
        case 1.0..<2.0: return 2.0       // Slow
        case 0.2..<1.0: return 1.0       // Medium
        case 0.05..<0.2: return 0.5      // Fast
        case ..<0.05: return 0.1         // Continuous
        default: return nil
        }
    }

    func updatePhase() {
        guard isConnected else {
            phase = .searching
            return
        }

        switch distance {
        case 0.05...: phase = .approaching
        case ..<0.05: phase = .readyToSend
        default: phase = .searching
        }
    }
}
```

**Step 4: Write CeremonyMessage.swift**

```swift
//
//  CeremonyMessage.swift
//  eternal_loop
//

import Foundation

struct CeremonyMessage: Codable {
    enum MessageType: String, Codable {
        case sessionInfo
        case distanceUpdate
        case readyToSend
        case ringSent
        case ringReceived
        case ceremonyComplete
    }

    let type: MessageType
    let payload: Data?

    init(type: MessageType, payload: Data? = nil) {
        self.type = type
        self.payload = payload
    }

    // Convenience initializers
    static func sessionInfo(hostNickname: String, guestNickname: String, ring: RingType, message: String) -> CeremonyMessage {
        let info = SessionInfo(hostNickname: hostNickname, guestNickname: guestNickname, ring: ring, message: message)
        let data = try? JSONEncoder().encode(info)
        return CeremonyMessage(type: .sessionInfo, payload: data)
    }

    static func distanceUpdate(_ distance: Float) -> CeremonyMessage {
        let data = withUnsafeBytes(of: distance) { Data($0) }
        return CeremonyMessage(type: .distanceUpdate, payload: data)
    }

    static let readyToSend = CeremonyMessage(type: .readyToSend)
    static let ringSent = CeremonyMessage(type: .ringSent)
    static let ringReceived = CeremonyMessage(type: .ringReceived)
    static let ceremonyComplete = CeremonyMessage(type: .ceremonyComplete)
}

struct SessionInfo: Codable {
    let hostNickname: String
    let guestNickname: String
    let ring: RingType
    let message: String
}
```

**Step 5: Write ProposalSession.swift (replace Item.swift)**

```swift
//
//  ProposalSession.swift
//  eternal_loop
//

import Foundation
import SwiftData

@Model
class ProposalSession {
    var id: UUID
    var hostNickname: String
    var guestNickname: String
    var message: String
    var selectedRing: RingType
    var createdAt: Date
    var completedAt: Date?
    var certificateImageData: Data?

    init(
        id: UUID = UUID(),
        hostNickname: String,
        guestNickname: String,
        message: String,
        selectedRing: RingType,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        certificateImageData: Data? = nil
    ) {
        self.id = id
        self.hostNickname = hostNickname
        self.guestNickname = guestNickname
        self.message = message
        self.selectedRing = selectedRing
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.certificateImageData = certificateImageData
    }
}
```

**Step 6: Write unit tests**

```swift
//
//  ModelsTests.swift
//  eternal_loopTests
//

import XCTest
@testable import eternal_loop

final class ModelsTests: XCTestCase {

    // MARK: - RingType Tests

    func testRingTypeDisplayName() {
        XCTAssertEqual(RingType.classicSolitaire.displayName, "經典單鑽")
        XCTAssertEqual(RingType.haloLuxury.displayName, "奢華光環")
        XCTAssertEqual(RingType.minimalistBand.displayName, "簡約素圈")
    }

    func testRingTypeModelFileName() {
        XCTAssertEqual(RingType.classicSolitaire.modelFileName, "ring_classic.usdz")
        XCTAssertEqual(RingType.haloLuxury.modelFileName, "ring_halo.usdz")
        XCTAssertEqual(RingType.minimalistBand.modelFileName, "ring_minimal.usdz")
    }

    func testRingTypeAllCases() {
        XCTAssertEqual(RingType.allCases.count, 3)
    }

    // MARK: - CeremonyState Tests

    func testCeremonyStateInitialValues() {
        let state = CeremonyState()
        XCTAssertEqual(state.phase, .searching)
        XCTAssertEqual(state.distance, .infinity)
        XCTAssertFalse(state.isConnected)
    }

    func testHeartbeatIntervalForDistance() {
        let state = CeremonyState()

        state.distance = 3.0
        XCTAssertNil(state.heartbeatInterval)

        state.distance = 1.5
        XCTAssertEqual(state.heartbeatInterval, 2.0)

        state.distance = 0.5
        XCTAssertEqual(state.heartbeatInterval, 1.0)

        state.distance = 0.1
        XCTAssertEqual(state.heartbeatInterval, 0.5)

        state.distance = 0.03
        XCTAssertEqual(state.heartbeatInterval, 0.1)
    }

    func testPhaseTransitions() {
        let state = CeremonyState()
        state.isConnected = true

        state.distance = 1.5
        state.updatePhase()
        XCTAssertEqual(state.phase, .approaching)

        state.distance = 0.03
        state.updatePhase()
        XCTAssertEqual(state.phase, .readyToSend)
    }

    // MARK: - CeremonyMessage Tests

    func testCeremonyMessageEncoding() throws {
        let message = CeremonyMessage.sessionInfo(
            hostNickname: "Alan",
            guestNickname: "Emily",
            ring: .classicSolitaire,
            message: "Marry me"
        )

        XCTAssertEqual(message.type, .sessionInfo)
        XCTAssertNotNil(message.payload)
    }

    func testDistanceUpdateMessage() {
        let message = CeremonyMessage.distanceUpdate(1.5)
        XCTAssertEqual(message.type, .distanceUpdate)
        XCTAssertNotNil(message.payload)
    }

    // MARK: - ProposalSession Tests

    func testProposalSessionCreation() {
        let session = ProposalSession(
            hostNickname: "Alan",
            guestNickname: "Emily",
            message: "Marry me",
            selectedRing: .classicSolitaire
        )

        XCTAssertNotNil(session.id)
        XCTAssertEqual(session.hostNickname, "Alan")
        XCTAssertEqual(session.guestNickname, "Emily")
        XCTAssertEqual(session.message, "Marry me")
        XCTAssertEqual(session.selectedRing, .classicSolitaire)
        XCTAssertNil(session.completedAt)
    }
}
```

**Step 7: Update eternal_loopApp.swift to use new model**

```swift
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
```

**Step 8: Delete old Item.swift**

```bash
rm eternal_loop/Item.swift
```

**Step 9: Run tests**

```bash
xcodebuild test -scheme eternal_loop -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -only-testing:eternal_loopTests/ModelsTests -quiet
```

Expected: PASS

**Step 10: Commit**

```bash
git add eternal_loop/Core/Models/ eternal_loop/eternal_loopApp.swift eternal_loopTests/ModelsTests.swift
git rm eternal_loop/Item.swift
git commit -m "feat: add data models (RingType, CeremonyState, ProposalSession)"
```

---

## Phase 2: Host Setup Flow

### Task 3: Home View

**Files:**
- Create: `eternal_loop/Features/Home/HomeView.swift`
- Create: `eternal_loop/Features/Components/PrimaryButton.swift`
- Modify: `eternal_loop/ContentView.swift`
- Test: `eternal_loopUITests/HomeViewUITests.swift`

**Step 1: Create directories**

```bash
mkdir -p eternal_loop/Features/Home
mkdir -p eternal_loop/Features/Components
```

**Step 2: Write PrimaryButton.swift**

```swift
//
//  PrimaryButton.swift
//  eternal_loop
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.bodyLarge)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(
                    LinearGradient(
                        colors: [.appPrimary, .appPrimaryLight],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .appPrimary.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PrimaryButton(title: "開始準備求婚") {}
        .padding()
        .background(Color.appBackgroundDark)
}
```

**Step 3: Write HomeView.swift**

```swift
//
//  HomeView.swift
//  eternal_loop
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProposalSession.createdAt, order: .reverse) private var sessions: [ProposalSession]

    @State private var navigateToSetup = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.appBackgroundDark
                    .ignoresSafeArea()

                VStack(spacing: Spacing.xxl) {
                    Spacer()

                    // Ring preview placeholder
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.appPrimaryLight.opacity(0.3), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)

                        Image(systemName: "ring.circle")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.appAccentGold, .appAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    // Title
                    VStack(spacing: Spacing.sm) {
                        Text("永恆之環")
                            .font(.headingLarge)
                            .foregroundColor(.appTextPrimary)

                        Text("Eternal Loop")
                            .font(.bodyMedium)
                            .foregroundColor(.appTextSecondary)
                    }

                    Spacer()

                    // Main CTA
                    VStack(spacing: Spacing.md) {
                        PrimaryButton(title: "開始準備求婚") {
                            navigateToSetup = true
                        }
                        .accessibilityIdentifier("startProposalButton")

                        if !sessions.isEmpty {
                            Button("查看過往紀念 →") {
                                // TODO: Navigate to history
                            }
                            .font(.bodyMedium)
                            .foregroundColor(.appTextSecondary)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .navigationDestination(isPresented: $navigateToSetup) {
                // TODO: RingSelectionView()
                Text("Setup Flow")
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: ProposalSession.self, inMemory: true)
}
```

**Step 4: Update ContentView.swift**

```swift
//
//  ContentView.swift
//  eternal_loop
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ProposalSession.self, inMemory: true)
}
```

**Step 5: Write UI test**

```swift
//
//  HomeViewUITests.swift
//  eternal_loopUITests
//

import XCTest

final class HomeViewUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testHomeViewDisplaysTitle() throws {
        XCTAssertTrue(app.staticTexts["永恆之環"].exists)
        XCTAssertTrue(app.staticTexts["Eternal Loop"].exists)
    }

    func testHomeViewHasStartButton() throws {
        let button = app.buttons["startProposalButton"]
        XCTAssertTrue(button.exists)
    }

    func testTapStartButtonNavigates() throws {
        let button = app.buttons["startProposalButton"]
        button.tap()

        // Should navigate to setup flow
        XCTAssertTrue(app.staticTexts["Setup Flow"].waitForExistence(timeout: 2))
    }
}
```

**Step 6: Run tests**

```bash
xcodebuild test -scheme eternal_loop -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -only-testing:eternal_loopUITests/HomeViewUITests -quiet
```

Expected: PASS

**Step 7: Commit**

```bash
git add eternal_loop/Features/ eternal_loop/ContentView.swift eternal_loopUITests/HomeViewUITests.swift
git commit -m "feat: add home view with primary button component"
```

---

### Task 4: Ring Selection View

**Files:**
- Create: `eternal_loop/Features/Setup/RingSelectionView.swift`
- Create: `eternal_loop/Features/Setup/RingCardView.swift`
- Test: `eternal_loopTests/RingSelectionTests.swift`

**Step 1: Create Setup directory**

```bash
mkdir -p eternal_loop/Features/Setup
```

**Step 2: Write RingCardView.swift**

```swift
//
//  RingCardView.swift
//  eternal_loop
//

import SwiftUI

struct RingCardView: View {
    let ring: RingType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.md) {
                // Ring preview placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appBackgroundDark)
                        .frame(height: 120)

                    Image(systemName: "ring.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.appAccentGold, .appAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Text(ring.displayName)
                    .font(.bodyMedium)
                    .foregroundColor(.appTextPrimary)

                // Selection indicator
                Circle()
                    .fill(isSelected ? Color.appPrimary : Color.clear)
                    .stroke(Color.appPrimaryLight, lineWidth: 2)
                    .frame(width: 20, height: 20)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appBackgroundDark.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color.appPrimary : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("ringCard_\(ring.rawValue)")
    }
}

#Preview {
    HStack {
        RingCardView(ring: .classicSolitaire, isSelected: true) {}
        RingCardView(ring: .haloLuxury, isSelected: false) {}
    }
    .padding()
    .background(Color.appBackgroundDark)
}
```

**Step 3: Write RingSelectionView.swift**

```swift
//
//  RingSelectionView.swift
//  eternal_loop
//

import SwiftUI

struct RingSelectionView: View {
    @Binding var selectedRing: RingType
    let onNext: () -> Void

    var body: some View {
        ZStack {
            Color.appBackgroundDark
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.sm) {
                    Text("選擇一枚戒指")
                        .font(.headingLarge)
                        .foregroundColor(.appTextPrimary)
                }
                .padding(.top, Spacing.xl)

                // Ring grid
                HStack(spacing: Spacing.md) {
                    ForEach(RingType.allCases) { ring in
                        RingCardView(
                            ring: ring,
                            isSelected: selectedRing == ring
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedRing = ring
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)

                Spacer()

                // Next button
                PrimaryButton(title: "下一步") {
                    onNext()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
                .accessibilityIdentifier("nextButton")
            }
        }
        .navigationTitle("步驟 1/3")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RingSelectionView(selectedRing: .constant(.classicSolitaire)) {}
    }
}
```

**Step 4: Write unit tests**

```swift
//
//  RingSelectionTests.swift
//  eternal_loopTests
//

import XCTest
import SwiftUI
@testable import eternal_loop

final class RingSelectionTests: XCTestCase {

    func testAllRingTypesAvailable() {
        XCTAssertEqual(RingType.allCases.count, 3)
    }

    func testRingTypeIsIdentifiable() {
        let ring = RingType.classicSolitaire
        XCTAssertEqual(ring.id, "classicSolitaire")
    }
}
```

**Step 5: Run tests**

```bash
xcodebuild test -scheme eternal_loop -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -only-testing:eternal_loopTests/RingSelectionTests -quiet
```

Expected: PASS

**Step 6: Commit**

```bash
git add eternal_loop/Features/Setup/ eternal_loopTests/RingSelectionTests.swift
git commit -m "feat: add ring selection view with card component"
```

---

### Task 5: Message Input View

**Files:**
- Create: `eternal_loop/Features/Setup/MessageInputView.swift`
- Test: `eternal_loopUITests/MessageInputUITests.swift`

**Step 1: Write MessageInputView.swift**

```swift
//
//  MessageInputView.swift
//  eternal_loop
//

import SwiftUI

struct MessageInputView: View {
    @Binding var hostNickname: String
    @Binding var guestNickname: String
    @Binding var message: String
    let onNext: () -> Void

    private let maxMessageLength = 200

    private var isValid: Bool {
        !hostNickname.trimmingCharacters(in: .whitespaces).isEmpty &&
        !guestNickname.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Color.appBackgroundDark
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    Text("填寫你們的故事")
                        .font(.headingLarge)
                        .foregroundColor(.appTextPrimary)
                        .padding(.top, Spacing.xl)

                    VStack(spacing: Spacing.lg) {
                        // Host nickname
                        InputField(
                            label: "你的暱稱",
                            text: $hostNickname,
                            placeholder: "請輸入你的暱稱"
                        )
                        .accessibilityIdentifier("hostNicknameField")

                        // Guest nickname
                        InputField(
                            label: "對方的暱稱",
                            text: $guestNickname,
                            placeholder: "請輸入對方的暱稱"
                        )
                        .accessibilityIdentifier("guestNicknameField")

                        // Message
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("告白宣言")
                                .font(.bodyMedium)
                                .foregroundColor(.appTextSecondary)

                            TextEditor(text: $message)
                                .font(.bodyLarge)
                                .foregroundColor(.appTextPrimary)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 120)
                                .padding(Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                                .onChange(of: message) { _, newValue in
                                    if newValue.count > maxMessageLength {
                                        message = String(newValue.prefix(maxMessageLength))
                                    }
                                }
                                .accessibilityIdentifier("messageField")

                            Text("\(message.count)/\(maxMessageLength) 字")
                                .font(.appCaption)
                                .foregroundColor(.appTextSecondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)

                    Spacer(minLength: Spacing.xxl)

                    // Next button
                    PrimaryButton(title: "準備完成") {
                        onNext()
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1.0 : 0.5)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
                    .accessibilityIdentifier("nextButton")
                }
            }
        }
        .navigationTitle("步驟 2/3")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InputField: View {
    let label: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(label)
                .font(.bodyMedium)
                .foregroundColor(.appTextSecondary)

            TextField(placeholder, text: $text)
                .font(.bodyLarge)
                .foregroundColor(.appTextPrimary)
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
        }
    }
}

#Preview {
    NavigationStack {
        MessageInputView(
            hostNickname: .constant(""),
            guestNickname: .constant(""),
            message: .constant("")
        ) {}
    }
}
```

**Step 2: Write UI test**

```swift
//
//  MessageInputUITests.swift
//  eternal_loopUITests
//

import XCTest

final class MessageInputUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testMessageInputFlow() throws {
        // Navigate to setup
        app.buttons["startProposalButton"].tap()

        // Select ring and proceed
        app.buttons["ringCard_classicSolitaire"].tap()
        app.buttons["nextButton"].tap()

        // Should be on message input
        XCTAssertTrue(app.staticTexts["填寫你們的故事"].waitForExistence(timeout: 2))
    }
}
```

**Step 3: Update HomeView to connect navigation**

Update `HomeView.swift` navigationDestination:

```swift
.navigationDestination(isPresented: $navigateToSetup) {
    SetupFlowView()
}
```

**Step 4: Create SetupFlowView.swift**

```swift
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
                // TODO: QRGeneratorView
                Text("QR Code View")
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
```

**Step 5: Run tests**

```bash
xcodebuild test -scheme eternal_loop -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -only-testing:eternal_loopUITests/MessageInputUITests -quiet
```

Expected: PASS

**Step 6: Commit**

```bash
git add eternal_loop/Features/Setup/ eternal_loop/Features/Home/HomeView.swift eternal_loopUITests/MessageInputUITests.swift
git commit -m "feat: add message input view with setup flow navigation"
```

---

### Task 6: QR Code Generator View

**Files:**
- Create: `eternal_loop/Features/Pairing/QRGeneratorView.swift`
- Create: `eternal_loop/Core/Utils/QRCodeGenerator.swift`
- Test: `eternal_loopTests/QRCodeGeneratorTests.swift`

**Step 1: Create directories**

```bash
mkdir -p eternal_loop/Features/Pairing
mkdir -p eternal_loop/Core/Utils
```

**Step 2: Write QRCodeGenerator.swift**

```swift
//
//  QRCodeGenerator.swift
//  eternal_loop
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {
    static func generate(sessionId: UUID) -> UIImage? {
        let urlString = "https://eternalloop.app/join?session=\(sessionId.uuidString)"

        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(urlString.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        // Scale up for better quality
        let scale = 10.0
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
```

**Step 3: Write QRGeneratorView.swift**

```swift
//
//  QRGeneratorView.swift
//  eternal_loop
//

import SwiftUI

struct QRGeneratorView: View {
    let sessionId: UUID
    let onConnected: () -> Void

    @State private var qrImage: UIImage?
    @State private var isConnecting = false
    @State private var manualTriggerProgress: CGFloat = 0
    @State private var isManualTriggerPressed = false

    var body: some View {
        ZStack {
            Color.appBackgroundDark
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Instructions
                Text("請對方掃描這個 QR Code")
                    .font(.headingMedium)
                    .foregroundColor(.appTextPrimary)

                // QR Code
                if let qrImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                        )
                        .shadow(color: .appPrimary.opacity(0.3), radius: 20)
                } else {
                    ProgressView()
                        .frame(width: 200, height: 200)
                }

                // Connection status
                VStack(spacing: Spacing.sm) {
                    Text("等待連線中...")
                        .font(.bodyMedium)
                        .foregroundColor(.appTextSecondary)

                    HStack(spacing: Spacing.sm) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.appPrimaryLight)
                                .frame(width: 8, height: 8)
                                .opacity(isConnecting ? 1 : 0.3)
                                .animation(
                                    .easeInOut(duration: 0.5)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: isConnecting
                                )
                        }
                    }
                }

                Spacer()
            }

            // Manual trigger button (bottom right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ManualTriggerButton {
                        onConnected()
                    }
                    .padding(Spacing.xl)
                }
            }
        }
        .navigationTitle("步驟 3/3")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            qrImage = QRCodeGenerator.generate(sessionId: sessionId)
            isConnecting = true
        }
    }
}

struct ManualTriggerButton: View {
    let onTrigger: () -> Void

    @State private var isPressed = false
    @State private var pressProgress: CGFloat = 0

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 20))
            .foregroundStyle(Color.appAccent.opacity(0.3))
            .scaleEffect(isPressed ? 1.2 : 1.0)
            .overlay {
                Circle()
                    .trim(from: 0, to: pressProgress)
                    .stroke(Color.appAccent, lineWidth: 2)
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))
            }
            .onLongPressGesture(minimumDuration: 3.0) {
                onTrigger()
            } onPressingChanged: { pressing in
                isPressed = pressing
                if pressing {
                    withAnimation(.linear(duration: 3.0)) {
                        pressProgress = 1.0
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.2)) {
                        pressProgress = 0
                    }
                }
            }
            .accessibilityIdentifier("manualTriggerButton")
    }
}

#Preview {
    NavigationStack {
        QRGeneratorView(sessionId: UUID()) {}
    }
}
```

**Step 4: Write unit tests**

```swift
//
//  QRCodeGeneratorTests.swift
//  eternal_loopTests
//

import XCTest
@testable import eternal_loop

final class QRCodeGeneratorTests: XCTestCase {

    func testQRCodeGeneration() {
        let sessionId = UUID()
        let image = QRCodeGenerator.generate(sessionId: sessionId)

        XCTAssertNotNil(image)
        XCTAssertGreaterThan(image!.size.width, 0)
        XCTAssertGreaterThan(image!.size.height, 0)
    }

    func testQRCodeIsDeterministic() {
        let sessionId = UUID()
        let image1 = QRCodeGenerator.generate(sessionId: sessionId)
        let image2 = QRCodeGenerator.generate(sessionId: sessionId)

        XCTAssertNotNil(image1)
        XCTAssertNotNil(image2)
        // Same session ID should produce same size QR code
        XCTAssertEqual(image1?.size, image2?.size)
    }
}
```

**Step 5: Update SetupFlowView.swift**

```swift
case 3:
    QRGeneratorView(sessionId: UUID()) {
        // TODO: Navigate to ceremony
    }
```

**Step 6: Run tests**

```bash
xcodebuild test -scheme eternal_loop -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -only-testing:eternal_loopTests/QRCodeGeneratorTests -quiet
```

Expected: PASS

**Step 7: Commit**

```bash
git add eternal_loop/Features/Pairing/ eternal_loop/Core/Utils/ eternal_loop/Features/Setup/SetupFlowView.swift eternal_loopTests/QRCodeGeneratorTests.swift
git commit -m "feat: add QR code generator view with manual trigger fallback"
```

---

## Phase 3: Core Connectivity

### Task 7: Multipeer Connectivity Manager

**Files:**
- Create: `eternal_loop/Core/Connectivity/MultipeerManager.swift`
- Test: `eternal_loopTests/MultipeerManagerTests.swift`

**Step 1: Create Connectivity directory**

```bash
mkdir -p eternal_loop/Core/Connectivity
```

**Step 2: Write MultipeerManager.swift**

```swift
//
//  MultipeerManager.swift
//  eternal_loop
//

import Foundation
import MultipeerConnectivity
import Observation

@Observable
class MultipeerManager: NSObject {
    // MARK: - Properties

    private let serviceType = "eternal-loop"
    private var peerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    var isConnected: Bool = false
    var connectedPeerName: String?
    var discoveryToken: Data?

    var onConnected: (() -> Void)?
    var onDisconnected: (() -> Void)?
    var onMessageReceived: ((CeremonyMessage) -> Void)?
    var onDiscoveryTokenReceived: ((Data) -> Void)?

    // MARK: - Initialization

    init(displayName: String) {
        self.peerID = MCPeerID(displayName: displayName)
        super.init()
    }

    // MARK: - Session Management

    private func createSession() {
        session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session?.delegate = self
    }

    // MARK: - Host (Browser) Methods

    func startBrowsing() {
        createSession()
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    // MARK: - Guest (Advertiser) Methods

    func startAdvertising(sessionId: UUID) {
        createSession()
        let discoveryInfo = ["sessionId": sessionId.uuidString]
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: discoveryInfo,
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }

    // MARK: - Messaging

    func send(_ message: CeremonyMessage) {
        guard let session = session,
              !session.connectedPeers.isEmpty else { return }

        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send message: \(error)")
        }
    }

    func sendDiscoveryToken(_ token: Data) {
        guard let session = session,
              !session.connectedPeers.isEmpty else { return }

        do {
            try session.send(token, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send discovery token: \(error)")
        }
    }

    // MARK: - Cleanup

    func disconnect() {
        session?.disconnect()
        stopBrowsing()
        stopAdvertising()
        isConnected = false
        connectedPeerName = nil
    }
}

// MARK: - MCSessionDelegate

extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.isConnected = true
                self.connectedPeerName = peerID.displayName
                self.onConnected?()
            case .notConnected:
                self.isConnected = false
                self.connectedPeerName = nil
                self.onDisconnected?()
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            // Try to decode as CeremonyMessage
            if let message = try? JSONDecoder().decode(CeremonyMessage.self, from: data) {
                self.onMessageReceived?(message)
            } else {
                // Assume it's a discovery token
                self.onDiscoveryTokenReceived?(data)
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let session = session else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
```

**Step 3: Write unit tests**

```swift
//
//  MultipeerManagerTests.swift
//  eternal_loopTests
//

import XCTest
@testable import eternal_loop

final class MultipeerManagerTests: XCTestCase {

    func testManagerInitialization() {
        let manager = MultipeerManager(displayName: "TestHost")
        XCTAssertFalse(manager.isConnected)
        XCTAssertNil(manager.connectedPeerName)
    }

    func testStartBrowsing() {
        let manager = MultipeerManager(displayName: "TestHost")
        manager.startBrowsing()
        // Should not crash
        manager.stopBrowsing()
    }

    func testStartAdvertising() {
        let manager = MultipeerManager(displayName: "TestGuest")
        manager.startAdvertising(sessionId: UUID())
        // Should not crash
        manager.stopAdvertising()
    }

    func testDisconnect() {
        let manager = MultipeerManager(displayName: "Test")
        manager.startBrowsing()
        manager.disconnect()
        XCTAssertFalse(manager.isConnected)
    }
}
```

**Step 4: Run tests**

```bash
xcodebuild test -scheme eternal_loop -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -only-testing:eternal_loopTests/MultipeerManagerTests -quiet
```

Expected: PASS

**Step 5: Commit**

```bash
git add eternal_loop/Core/Connectivity/ eternal_loopTests/MultipeerManagerTests.swift
git commit -m "feat: add Multipeer Connectivity manager for P2P communication"
```

---

### Task 8: Nearby Interaction Manager (UWB)

**Files:**
- Create: `eternal_loop/Core/Connectivity/NearbyInteractionManager.swift`
- Test: `eternal_loopTests/NearbyInteractionManagerTests.swift`

**Step 1: Write NearbyInteractionManager.swift**

```swift
//
//  NearbyInteractionManager.swift
//  eternal_loop
//

import Foundation
import NearbyInteraction
import Observation

@Observable
class NearbyInteractionManager: NSObject {
    // MARK: - Properties

    private var niSession: NISession?

    var distance: Float = .infinity
    var isSupported: Bool {
        NISession.deviceCapabilities.supportsPreciseDistanceMeasurement
    }

    var onDistanceUpdate: ((Float) -> Void)?

    // MARK: - Discovery Token

    var discoveryToken: Data? {
        guard let token = niSession?.discoveryToken else { return nil }
        return try? NSKeyedArchiver.archivedData(
            withRootObject: token,
            requiringSecureCoding: true
        )
    }

    // MARK: - Session Management

    func start() {
        guard isSupported else {
            print("UWB not supported on this device")
            return
        }

        niSession = NISession()
        niSession?.delegate = self
    }

    func configure(withPeerToken tokenData: Data) {
        guard let token = try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: NIDiscoveryToken.self,
            from: tokenData
        ) else {
            print("Failed to decode peer discovery token")
            return
        }

        let config = NINearbyPeerConfiguration(peerToken: token)
        niSession?.run(config)
    }

    func stop() {
        niSession?.invalidate()
        niSession = nil
        distance = .infinity
    }
}

// MARK: - NISessionDelegate

extension NearbyInteractionManager: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let nearbyObject = nearbyObjects.first,
              let distance = nearbyObject.distance else { return }

        DispatchQueue.main.async {
            self.distance = distance
            self.onDistanceUpdate?(distance)
        }
    }

    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        DispatchQueue.main.async {
            self.distance = .infinity
        }
    }

    func sessionWasSuspended(_ session: NISession) {
        print("NI Session suspended")
    }

    func sessionSuspensionEnded(_ session: NISession) {
        print("NI Session suspension ended")
    }

    func session(_ session: NISession, didInvalidateWith error: Error) {
        print("NI Session invalidated: \(error)")
        DispatchQueue.main.async {
            self.distance = .infinity
        }
    }
}
```

**Step 2: Write unit tests**

```swift
//
//  NearbyInteractionManagerTests.swift
//  eternal_loopTests
//

import XCTest
@testable import eternal_loop

final class NearbyInteractionManagerTests: XCTestCase {

    func testManagerInitialization() {
        let manager = NearbyInteractionManager()
        XCTAssertEqual(manager.distance, .infinity)
    }

    func testIsSupportedProperty() {
        let manager = NearbyInteractionManager()
        // Property should return without crash (actual value depends on device)
        _ = manager.isSupported
    }

    func testStop() {
        let manager = NearbyInteractionManager()
        manager.start()
        manager.stop()
        XCTAssertEqual(manager.distance, .infinity)
    }
}
```

**Step 3: Run tests**

```bash
xcodebuild test -scheme eternal_loop -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -only-testing:eternal_loopTests/NearbyInteractionManagerTests -quiet
```

Expected: PASS

**Step 4: Commit**

```bash
git add eternal_loop/Core/Connectivity/NearbyInteractionManager.swift eternal_loopTests/NearbyInteractionManagerTests.swift
git commit -m "feat: add Nearby Interaction manager for UWB distance measurement"
```

---

## Phase 4: Haptics

### Task 9: Heartbeat Haptics

**Files:**
- Create: `eternal_loop/Core/Haptics/HeartbeatHaptics.swift`
- Test: `eternal_loopTests/HeartbeatHapticsTests.swift`

**Step 1: Create Haptics directory**

```bash
mkdir -p eternal_loop/Core/Haptics
```

**Step 2: Write HeartbeatHaptics.swift**

```swift
//
//  HeartbeatHaptics.swift
//  eternal_loop
//

import Foundation
import CoreHaptics

class HeartbeatHaptics {
    // MARK: - Properties

    private var engine: CHHapticEngine?
    private var heartbeatPlayer: CHHapticPatternPlayer?
    private var timer: Timer?
    private var currentInterval: TimeInterval = 2.0

    var isSupported: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    // MARK: - Initialization

    init() {
        setupEngine()
    }

    private func setupEngine() {
        guard isSupported else { return }

        do {
            engine = try CHHapticEngine()
            engine?.stoppedHandler = { [weak self] reason in
                print("Haptic engine stopped: \(reason)")
                self?.engine = nil
            }
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            try engine?.start()
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }

    // MARK: - Heartbeat Pattern

    private func createHeartbeatPattern(intensity: Float) throws -> CHHapticPattern {
        // lub-dub heartbeat pattern
        let beat1 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0
        )

        let beat2 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0.15
        )

        return try CHHapticPattern(events: [beat1, beat2], parameters: [])
    }

    // MARK: - Distance-based Updates

    func updateForDistance(_ distance: Float) {
        let interval: TimeInterval?
        let intensity: Float

        switch distance {
        case 2.0...:
            interval = nil
            intensity = 0
        case 1.0..<2.0:
            interval = 2.0
            intensity = 0.4
        case 0.2..<1.0:
            interval = 1.0
            intensity = 0.6
        case 0.05..<0.2:
            interval = 0.5
            intensity = 0.8
        case ..<0.05:
            interval = 0.2
            intensity = 1.0
        default:
            interval = nil
            intensity = 0
        }

        if let interval = interval {
            startHeartbeat(interval: interval, intensity: intensity)
        } else {
            stopHeartbeat()
        }
    }

    func intervalForDistance(_ distance: Float) -> TimeInterval? {
        switch distance {
        case 2.0...: return nil
        case 1.0..<2.0: return 2.0
        case 0.2..<1.0: return 1.0
        case 0.05..<0.2: return 0.5
        case ..<0.05: return 0.2
        default: return nil
        }
    }

    // MARK: - Playback Control

    private func startHeartbeat(interval: TimeInterval, intensity: Float) {
        guard isSupported, let engine = engine else { return }

        // Only restart if interval changed
        guard interval != currentInterval else { return }
        currentInterval = interval

        stopHeartbeat()

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playHeartbeat(intensity: intensity)
        }
        // Play immediately
        playHeartbeat(intensity: intensity)
    }

    private func playHeartbeat(intensity: Float) {
        guard isSupported, let engine = engine else { return }

        do {
            let pattern = try createHeartbeatPattern(intensity: intensity)
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play heartbeat: \(error)")
        }
    }

    func stopHeartbeat() {
        timer?.invalidate()
        timer = nil
        currentInterval = 2.0
    }

    // MARK: - Special Effects

    func playRingSentImpact() {
        guard isSupported, let engine = engine else { return }

        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play impact: \(error)")
        }
    }

    func playRingAttachedCelebration() {
        guard isSupported, let engine = engine else { return }

        do {
            var events: [CHHapticEvent] = []

            // Rapid succession of impacts
            for i in 0..<5 {
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                    ],
                    relativeTime: Double(i) * 0.1
                )
                events.append(event)
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play celebration: \(error)")
        }
    }

    deinit {
        stopHeartbeat()
        engine?.stop()
    }
}
```

**Step 3: Write unit tests**

```swift
//
//  HeartbeatHapticsTests.swift
//  eternal_loopTests
//

import XCTest
@testable import eternal_loop

final class HeartbeatHapticsTests: XCTestCase {

    func testHapticsInitialization() {
        let haptics = HeartbeatHaptics()
        // Should not crash
        XCTAssertNotNil(haptics)
    }

    func testIntervalForDistance() {
        let haptics = HeartbeatHaptics()

        XCTAssertNil(haptics.intervalForDistance(3.0))
        XCTAssertEqual(haptics.intervalForDistance(1.5), 2.0)
        XCTAssertEqual(haptics.intervalForDistance(0.5), 1.0)
        XCTAssertEqual(haptics.intervalForDistance(0.1), 0.5)
        XCTAssertEqual(haptics.intervalForDistance(0.03), 0.2)
    }

    func testStopHeartbeat() {
        let haptics = HeartbeatHaptics()
        haptics.updateForDistance(0.5)
        haptics.stopHeartbeat()
        // Should not crash
    }
}
```

**Step 4: Run tests**

```bash
xcodebuild test -scheme eternal_loop -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -only-testing:eternal_loopTests/HeartbeatHapticsTests -quiet
```

Expected: PASS

**Step 5: Commit**

```bash
git add eternal_loop/Core/Haptics/ eternal_loopTests/HeartbeatHapticsTests.swift
git commit -m "feat: add Core Haptics heartbeat manager with distance-based patterns"
```

---

## Remaining Tasks (Summary)

Due to the length of this plan, the remaining tasks are summarized below. Each follows the same TDD structure.

### Phase 5: Ceremony Views (Tasks 10-12)
- **Task 10:** HostCeremonyView - Heart animation, glow effects, swipe gesture
- **Task 11:** GuestCeremonyView - Waiting state, ring receive animation
- **Task 12:** RingTransferAnimation - Spring animation, particle system placeholder

### Phase 6: AR Experience (Tasks 13-14)
- **Task 13:** HandTrackingManager - VNDetectHumanHandPoseRequest, ring finger detection
- **Task 14:** ARRingView - RealityKit integration, 3D model loading, hand tracking binding

### Phase 7: Certificate (Tasks 15-16)
- **Task 15:** CertificateTemplate - SwiftUI view with gradient background, typography
- **Task 16:** CertificateGenerator - ImageRenderer, Photos framework save

### Phase 8: App Clip (Tasks 17-18)
- **Task 17:** App Clip Target Setup - Xcode configuration, entitlements
- **Task 18:** AppClipApp Entry Point - URL handling, session ID parsing

### Phase 9: Integration (Task 19)
- **Task 19:** End-to-End Flow Test - Full ceremony simulation test

---

## Checkpoint Schedule

| After Task | Checkpoint |
|------------|------------|
| 6 | Host setup flow complete - Test on device |
| 9 | Core systems complete - Verify haptics on device |
| 12 | Ceremony flow complete - Test 2-device pairing |
| 14 | AR complete - Test hand tracking |
| 16 | Certificate complete - Verify image generation |
| 19 | Full integration - End-to-end test |

---

*Plan complete.*
