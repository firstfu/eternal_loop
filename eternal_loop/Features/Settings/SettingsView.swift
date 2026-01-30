//
//  SettingsView.swift
//  eternal_loop
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("isMusicEnabled") private var isMusicEnabled: Bool = true
    @AppStorage("isHapticsEnabled") private var isHapticsEnabled: Bool = true
    @AppStorage("musicVolume") private var musicVolume: Double = 0.5

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundDark
                    .ignoresSafeArea()

                List {
                    // Audio Settings
                    Section {
                        Toggle(isOn: $isMusicEnabled) {
                            Label("背景音樂", systemImage: "music.note")
                        }
                        .tint(.appAccent)
                        .onChange(of: isMusicEnabled) { _, newValue in
                            AudioManager.shared.isMusicEnabled = newValue
                        }

                        if isMusicEnabled {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("音量")
                                    .font(.bodyMedium)

                                HStack {
                                    Image(systemName: "speaker.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appTextSecondary)

                                    Slider(value: $musicVolume, in: 0...1)
                                        .tint(.appAccent)
                                        .onChange(of: musicVolume) { _, newValue in
                                            AudioManager.shared.musicVolume = Float(newValue)
                                        }

                                    Image(systemName: "speaker.wave.3.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appTextSecondary)
                                }
                            }
                            .padding(.vertical, Spacing.xs)
                        }
                    } header: {
                        Text("音效")
                            .foregroundColor(.appTextSecondary)
                    }
                    .listRowBackground(Color.appPrimary.opacity(0.1))

                    // Haptics Settings
                    Section {
                        Toggle(isOn: $isHapticsEnabled) {
                            Label("觸覺回饋", systemImage: "waveform")
                        }
                        .tint(.appAccent)
                    } header: {
                        Text("觸覺")
                            .foregroundColor(.appTextSecondary)
                    }
                    .listRowBackground(Color.appPrimary.opacity(0.1))

                    // About Section
                    Section {
                        HStack {
                            Text("版本")
                            Spacer()
                            Text(appVersion)
                                .foregroundColor(.appTextSecondary)
                        }

                        NavigationLink {
                            CreditsView()
                        } label: {
                            Label("致謝與授權", systemImage: "heart.text.square")
                        }

                        NavigationLink {
                            PrivacyView()
                        } label: {
                            Label("隱私政策", systemImage: "hand.raised")
                        }
                    } header: {
                        Text("關於")
                            .foregroundColor(.appTextSecondary)
                    }
                    .listRowBackground(Color.appPrimary.opacity(0.1))
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.appAccent)
                }
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Credits View

struct CreditsView: View {
    var body: some View {
        ZStack {
            Color.appBackgroundDark
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // App Credit
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("永恆之環")
                            .font(.headingLarge)
                            .foregroundColor(.appTextPrimary)

                        Text("讓數位求婚成為永恆的回憶")
                            .font(.bodyMedium)
                            .foregroundColor(.appTextSecondary)
                    }

                    Divider()
                        .background(Color.appPrimary.opacity(0.3))

                    // 3D Models
                    creditSection(
                        title: "3D 模型",
                        items: [
                            ("戒指模型", "Poly by Google", "CC-BY 3.0"),
                            ("鑽石效果", "Creative Commons", "CC0 1.0")
                        ]
                    )

                    // Frameworks
                    creditSection(
                        title: "框架與技術",
                        items: [
                            ("ARKit", "Apple Inc.", ""),
                            ("RealityKit", "Apple Inc.", ""),
                            ("Nearby Interaction", "Apple Inc.", ""),
                            ("Core Haptics", "Apple Inc.", "")
                        ]
                    )

                    // Special Thanks
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("特別感謝")
                            .font(.headingSmall)
                            .foregroundColor(.appTextPrimary)

                        Text("感謝所有支持與鼓勵這個專案的人們。願每一對使用這個 App 的情侶，都能擁有最美好的回憶。")
                            .font(.bodyMedium)
                            .foregroundColor(.appTextSecondary)
                    }

                    Spacer(minLength: 50)
                }
                .padding(Spacing.lg)
            }
        }
        .navigationTitle("致謝與授權")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func creditSection(title: String, items: [(String, String, String)]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(.headingSmall)
                .foregroundColor(.appTextPrimary)

            ForEach(items, id: \.0) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.0)
                            .font(.bodyMedium)
                            .foregroundColor(.appTextPrimary)

                        Text(item.1)
                            .font(.appCaption)
                            .foregroundColor(.appTextSecondary)
                    }

                    Spacer()

                    if !item.2.isEmpty {
                        Text(item.2)
                            .font(.appCaption)
                            .foregroundColor(.appAccent)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.appAccent.opacity(0.1))
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Privacy View

struct PrivacyView: View {
    var body: some View {
        ZStack {
            Color.appBackgroundDark
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    privacySection(
                        icon: "location.slash",
                        title: "位置資訊",
                        content: "本 App 使用 UWB（超寬頻）技術測量兩台裝置之間的距離，但不會收集或儲存您的 GPS 位置資訊。"
                    )

                    privacySection(
                        icon: "camera.metering.none",
                        title: "相機使用",
                        content: "AR 體驗需要使用相機，但所有影像處理都在本機進行，不會上傳到任何伺服器。"
                    )

                    privacySection(
                        icon: "wifi",
                        title: "網路連線",
                        content: "裝置間的連線使用 Multipeer Connectivity，資料在本地網路直接傳輸，不經過外部伺服器。"
                    )

                    privacySection(
                        icon: "internaldrive",
                        title: "資料儲存",
                        content: "您的儀式紀錄僅儲存在您的裝置上，您可以隨時在「回憶」頁面中刪除這些資料。"
                    )

                    privacySection(
                        icon: "hand.raised",
                        title: "第三方分享",
                        content: "我們不會與任何第三方分享您的個人資料或儀式內容。"
                    )

                    Spacer(minLength: 50)
                }
                .padding(Spacing.lg)
            }
        }
        .navigationTitle("隱私政策")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func privacySection(icon: String, title: String, content: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.appAccent)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.headingSmall)
                    .foregroundColor(.appTextPrimary)

                Text(content)
                    .font(.bodyMedium)
                    .foregroundColor(.appTextSecondary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
