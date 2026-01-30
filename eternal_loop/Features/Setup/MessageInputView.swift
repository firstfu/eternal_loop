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
                    Text("填寫你們的故事")
                        .font(.headingLarge)
                        .foregroundColor(.appTextPrimary)
                        .padding(.top, Spacing.xl)

                    VStack(spacing: Spacing.lg) {
                        InputField(
                            label: "你的暱稱",
                            text: $hostNickname,
                            placeholder: "請輸入你的暱稱"
                        )
                        .accessibilityIdentifier("hostNicknameField")

                        InputField(
                            label: "對方的暱稱",
                            text: $guestNickname,
                            placeholder: "請輸入對方的暱稱"
                        )
                        .accessibilityIdentifier("guestNicknameField")

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
