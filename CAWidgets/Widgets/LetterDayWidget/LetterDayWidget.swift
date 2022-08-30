//
//  LetterDayWidget.swift
//  CAWidgetsExtension
//
//  Created by Jim Phieffer on 8/25/22.
//

import SwiftUI
import WidgetKit

struct LetterDayWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LetterDayWidgetEntry {
        return LetterDayWidgetEntry(date: Date(), day: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LetterDayWidgetEntry) -> Void) {
        Task {
            var day: String?
            do {
                let calendars = try await MySchoolAppAPI.shared.getCalendars(from: Date().start(), to: Date().start() + 86400)
                for calendar in calendars {
                    for filter in calendar.filters ?? [] {
                        if filter.filterName == "Master Calendar" {
                            let letterDays = try await MySchoolAppAPI.shared.getEvents(from: Date(), to: Date().addingTimeInterval(86400), for: [filter.calendarId], refresh: true, nocache: true)
                            if let letterDay = letterDays.first(where: { $0.title.range(of: "^[A-F] Day$", options: .regularExpression) != nil }) {
                                day = letterDay.title
                            }
                            break
                        }
                    }
                }
            } catch {}
            completion(LetterDayWidgetEntry(date: Date(), day: day))
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LetterDayWidgetEntry>) -> ()) {
        let nextUpdate = Date().start() + 86400
        Task {
            var day: String?
            do {
                let calendars = try await MySchoolAppAPI.shared.getCalendars(from: Date().startOfMonth(), to: Date().startOfNextMonth())
                for calendar in calendars {
                    for filter in calendar.filters ?? [] {
                        if filter.filterName == "Master Calendar" {
                            let letterDays = try await MySchoolAppAPI.shared.getEvents(from: Date(), to: Date().addingTimeInterval(86400), for: [filter.calendarId], refresh: true, nocache: true)
                            if let letterDay = letterDays.first(where: { $0.title.range(of: "^[A-F] Day$", options: .regularExpression) != nil }) {
                                day = letterDay.title
                            }
                            break
                        }
                    }
                }
            } catch {}
            completion(Timeline(entries: [
                LetterDayWidgetEntry(date: Date(), day: day)
            ], policy: .after(nextUpdate)))
        }
    }
}

struct LetterDayWidgetEntry: TimelineEntry {
    var date: Date
    let day: String?
}



struct LetterDayWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LetterDayWidgetEntry
    
    var body: some View {
        switch family {
        case .systemSmall: LetterDayWidgetSmallView(entry: entry)
        case .accessoryRectangular: LetterDayWidgetAccessoryRectangularView(entry: entry)
        case .accessoryInline: LetterDayWidgetAccessoryInlineView(entry: entry)
        case .accessoryCircular: LetterDayWidgetAccessoryCircularView(entry: entry)
        default: EmptyView()
        }
    }
}

struct LetterDayWidget: Widget {
    let supportedFamilies: [WidgetFamily] = {
        if #available(iOS 16, *) {
            return [.systemSmall, .accessoryRectangular, .accessoryInline, .accessoryCircular]
        } else {
            return [.systemSmall]
        }
    }()
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.jimphieffer.CA.LetterDayWidget", provider: LetterDayWidgetProvider()) { entry in
            LetterDayWidgetView(entry: entry)
        }
        .configurationDisplayName("CA Letter Day Widget")
        .description("Displays the current letter day.")
        .supportedFamilies(supportedFamilies)
    }
}
