//
//  EternalLoopWidget.swift
//  eternal_loop
//
//  Widget showing anniversary countdown and ceremony memories
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct AnniversaryProvider: TimelineProvider {
    func placeholder(in context: Context) -> AnniversaryEntry {
        AnniversaryEntry(
            date: Date(),
            partnerName: "心愛的人",
            ceremonyDate: Date(),
            daysTogether: 365
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AnniversaryEntry) -> Void) {
        let entry = AnniversaryEntry(
            date: Date(),
            partnerName: loadPartnerName(),
            ceremonyDate: loadCeremonyDate(),
            daysTogether: calculateDaysTogether()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AnniversaryEntry>) -> Void) {
        let currentDate = Date()
        let entry = AnniversaryEntry(
            date: currentDate,
            partnerName: loadPartnerName(),
            ceremonyDate: loadCeremonyDate(),
            daysTogether: calculateDaysTogether()
        )

        // Update at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)

        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    // MARK: - Data Loading

    private func loadPartnerName() -> String? {
        UserDefaults(suiteName: "group.com.eternal-loop")?.string(forKey: "partnerName")
    }

    private func loadCeremonyDate() -> Date? {
        UserDefaults(suiteName: "group.com.eternal-loop")?.object(forKey: "ceremonyDate") as? Date
    }

    private func calculateDaysTogether() -> Int? {
        guard let ceremonyDate = loadCeremonyDate() else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: ceremonyDate, to: Date())
        return components.day
    }
}

// MARK: - Timeline Entry

struct AnniversaryEntry: TimelineEntry {
    let date: Date
    let partnerName: String?
    let ceremonyDate: Date?
    let daysTogether: Int?
}

// MARK: - Widget Views

struct EternalLoopWidgetEntryView: View {
    var entry: AnniversaryProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: AnniversaryEntry

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.05, blue: 0.2),
                    Color(red: 0.1, green: 0.02, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                // Ring icon
                Image(systemName: "ring.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.84, blue: 0.0),
                                Color(red: 0.85, green: 0.65, blue: 0.13)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                if let days = entry.daysTogether {
                    Text("\(days)")
                        .font(.system(size: 36, weight: .light, design: .rounded))
                        .foregroundColor(.white)

                    Text("天")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("永恆之環")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)

                    Text("開始你的故事")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: AnniversaryEntry

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.05, blue: 0.2),
                    Color(red: 0.1, green: 0.02, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 20) {
                // Left side - Ring and days
                VStack(spacing: 8) {
                    Image(systemName: "ring.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.84, blue: 0.0),
                                    Color(red: 0.85, green: 0.65, blue: 0.13)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    if let days = entry.daysTogether {
                        Text("\(days) 天")
                            .font(.system(size: 24, weight: .light, design: .rounded))
                            .foregroundColor(.white)
                    }
                }

                // Right side - Details
                VStack(alignment: .leading, spacing: 6) {
                    if let name = entry.partnerName {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.pink)
                            Text(name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }

                    if let ceremonyDate = entry.ceremonyDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            Text(formatDate(ceremonyDate))
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    if let days = entry.daysTogether {
                        Text(anniversaryMessage(days: days))
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(2)
                    } else {
                        Text("開啟 App 創造你們的回憶")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Spacer()
            }
            .padding()
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    private func anniversaryMessage(days: Int) -> String {
        switch days {
        case 0:
            return "今天是你們的紀念日！"
        case 1..<7:
            return "剛開始的甜蜜時光"
        case 7..<30:
            return "愛情正在發芽"
        case 30..<100:
            return "攜手走過每一天"
        case 100..<365:
            return "愛情持續升溫中"
        case 365..<730:
            return "一週年快樂！"
        default:
            return "永恆的承諾"
        }
    }
}

// MARK: - Widget Configuration

struct EternalLoopWidget: Widget {
    let kind: String = "EternalLoopWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AnniversaryProvider()) { entry in
            EternalLoopWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("永恆之環")
        .description("追蹤你們在一起的日子")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    EternalLoopWidget()
} timeline: {
    AnniversaryEntry(date: Date(), partnerName: "Emily", ceremonyDate: Date().addingTimeInterval(-86400 * 100), daysTogether: 100)
    AnniversaryEntry(date: Date(), partnerName: nil, ceremonyDate: nil, daysTogether: nil)
}

#Preview(as: .systemMedium) {
    EternalLoopWidget()
} timeline: {
    AnniversaryEntry(date: Date(), partnerName: "Emily", ceremonyDate: Date().addingTimeInterval(-86400 * 365), daysTogether: 365)
}
