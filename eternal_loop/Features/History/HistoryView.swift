//
//  HistoryView.swift
//  eternal_loop
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProposalSession.createdAt, order: .reverse) private var sessions: [ProposalSession]

    @State private var selectedSession: ProposalSession?
    @State private var showCertificateDetail: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundDark
                    .ignoresSafeArea()

                if sessions.isEmpty {
                    emptyStateView
                } else {
                    sessionListView
                }
            }
            .navigationTitle("回憶")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !sessions.isEmpty {
                        EditButton()
                            .foregroundColor(.appAccent)
                    }
                }
            }
            .sheet(isPresented: $showCertificateDetail) {
                if let session = selectedSession {
                    CertificateDetailView(session: session)
                }
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 80))
                .foregroundColor(.appPrimary.opacity(0.5))

            Text("還沒有任何回憶")
                .font(.headingMedium)
                .foregroundColor(.appTextPrimary)

            Text("完成一場儀式後，\n這裡會保存你們的珍貴時刻")
                .font(.bodyMedium)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xl)
    }

    private var sessionListView: some View {
        List {
            ForEach(sessions) { session in
                SessionRowView(session: session)
                    .listRowBackground(Color.appBackgroundDark)
                    .listRowSeparatorTint(.appPrimary.opacity(0.3))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSession = session
                        showCertificateDetail = true
                    }
            }
            .onDelete(perform: deleteSessions)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Actions

    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            let session = sessions[index]
            modelContext.delete(session)
        }
    }
}

// MARK: - Session Row View

struct SessionRowView: View {
    let session: ProposalSession

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: session.completedAt ?? session.createdAt)
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Ring icon
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: "ring")
                    .font(.system(size: 24))
                    .foregroundColor(.appAccentGold)
            }

            // Info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(session.hostNickname)
                        .font(.bodyLarge)
                        .foregroundColor(.appTextPrimary)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.appAccent)

                    Text(session.guestNickname)
                        .font(.bodyLarge)
                        .foregroundColor(.appTextPrimary)
                }

                HStack(spacing: Spacing.sm) {
                    Text(session.selectedRing.displayName)
                        .font(.appCaption)
                        .foregroundColor(.appTextSecondary)

                    Text("•")
                        .foregroundColor(.appTextSecondary)

                    Text(formattedDate)
                        .font(.appCaption)
                        .foregroundColor(.appTextSecondary)
                }
            }

            Spacer()

            // Status indicator
            if session.completedAt != nil {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "clock")
                    .foregroundColor(.orange)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
        }
        .padding(.vertical, Spacing.sm)
    }
}

// MARK: - Certificate Detail View

struct CertificateDetailView: View {
    let session: ProposalSession
    @Environment(\.dismiss) private var dismiss

    @State private var certificateImage: UIImage?
    @State private var isLoading: Bool = true
    @State private var showShareSheet: Bool = false

    private let generator = CertificateGenerator()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundDark
                    .ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    // Certificate preview
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .appAccent))
                            .scaleEffect(1.5)
                    } else if let image = certificateImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.3), radius: 10)
                            .padding(Spacing.lg)
                    }

                    // Session info
                    sessionInfoCard

                    Spacer()

                    // Action buttons
                    actionButtons
                }
                .padding(Spacing.lg)
            }
            .navigationTitle("證書詳情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.appAccent)
                }
            }
            .task {
                await loadCertificate()
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = certificateImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }

    private var sessionInfoCard: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text(session.hostNickname)
                    .font(.headingMedium)
                    .foregroundColor(.appTextPrimary)

                Image(systemName: "heart.fill")
                    .foregroundColor(.appAccent)

                Text(session.guestNickname)
                    .font(.headingMedium)
                    .foregroundColor(.appTextPrimary)
            }

            if !session.message.isEmpty {
                Text("\"\(session.message)\"")
                    .font(.bodyMedium)
                    .foregroundColor(.appTextSecondary)
                    .italic()
            }

            HStack(spacing: Spacing.lg) {
                Label(session.selectedRing.displayName, systemImage: "ring")
                    .font(.appCaption)
                    .foregroundColor(.appTextSecondary)

                if let date = session.completedAt {
                    Label(formatDate(date), systemImage: "calendar")
                        .font(.appCaption)
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appPrimary.opacity(0.1))
        )
    }

    private var actionButtons: some View {
        HStack(spacing: Spacing.md) {
            // Share button
            Button(action: { showShareSheet = true }) {
                Label("分享", systemImage: "square.and.arrow.up")
                    .font(.bodyLarge)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appPrimary)
                    )
            }
            .disabled(certificateImage == nil)

            // Save button
            Button(action: saveCertificate) {
                Label("儲存", systemImage: "square.and.arrow.down")
                    .font(.bodyLarge)
                    .foregroundColor(.appPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appPrimary, lineWidth: 2)
                    )
            }
            .disabled(certificateImage == nil)
        }
    }

    // MARK: - Actions

    @MainActor
    private func loadCertificate() async {
        isLoading = true
        certificateImage = generator.generateImage(
            hostName: session.hostNickname,
            guestName: session.guestNickname,
            ringType: session.selectedRing,
            date: session.completedAt ?? session.createdAt
        )
        isLoading = false
    }

    private func saveCertificate() {
        Task {
            _ = await generator.saveSessionToPhotos(session)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    HistoryView()
        .modelContainer(for: ProposalSession.self, inMemory: true)
}
