//
//  ScheduleWidget.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/29/22.
//

import SwiftUI
import WidgetKit

struct ScheduleWidgetProvider: TimelineProvider {
    let formatter = DateFormatter("h:mm a", timeZone: .current)
    
    func placeholder(in context: Context) -> ScheduleWidgetEntry {
        return ScheduleWidgetEntry(date: Date(), schedule: .success([]))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ScheduleWidgetEntry) -> Void) {
        Task {
            do {
                let schedule = try await MySchoolAppAPI.shared.getSchedule(for: Date().start())
                completion (ScheduleWidgetEntry(date: Date(), schedule: .success(schedule)))
            } catch {
                completion(ScheduleWidgetEntry(date: Date(), schedule: .failure(error)))
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleWidgetEntry>) -> ()) {
        Task {
            var nextUpdate = Date().start() + 720
            do {
                let schedule = try await MySchoolAppAPI.shared.getSchedule(for: Date().start())
                if let nextClass = schedule.first(where: {
                    (formatter.date(from: $0.myDayStartTime)?.todayRetainingTime() ?? Date().start()) > Date()
                }) {
                    nextUpdate = formatter.date(from: nextClass.myDayStartTime)?.todayRetainingTime() ?? nextUpdate
                }
                completion (Timeline(entries: [
                    ScheduleWidgetEntry(date: Date(), schedule: .success(schedule))
                ], policy: .after(nextUpdate)))
            } catch {
                completion (Timeline(entries: [
                    ScheduleWidgetEntry(date: Date(), schedule: .failure(error))
                ], policy: .after(nextUpdate)))
            }
        }
    }
}

struct ScheduleWidgetEntry: TimelineEntry {
    var date: Date
    let schedule: Result<MySchoolAppScheduleList, Error>
}



struct ScheduleWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: ScheduleWidgetEntry
    
    var body: some View {
        switch family {
        case .systemSmall, .systemMedium: ScheduleWidgetSmallView(entry: entry)
        case .systemLarge, .systemExtraLarge: ScheduleWidgetLargeView(entry: entry)
        default: EmptyView()
        }
    }
}

struct ScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.jimphieffer.CA.ScheduleWidget", provider: ScheduleWidgetProvider()) { entry in
            ScheduleWidgetView(entry: entry)
        }
        .configurationDisplayName("CA Schedule Widget")
        .description("Displays details about your schedule.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
