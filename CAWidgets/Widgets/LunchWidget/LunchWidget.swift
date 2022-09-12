//
//  LunchWidget.swift
//  CAWidgetsExtension
//
//  Created by Jim Phieffer on 8/24/22.
//

import SwiftUI
import WidgetKit

struct LunchWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LunchWidgetEntry {
        return LunchWidgetEntry(date: Date(), menu: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LunchWidgetEntry) -> Void) {
        Task {
            do {
                completion(LunchWidgetEntry(date: Date(), menu: .success(try await SageDiningAPI.shared.getMenuItems(on: Date().start()))))
            } catch {
                completion(LunchWidgetEntry(date: Date(), menu: .failure(error)))
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LunchWidgetEntry>) -> ()) {
        let nextUpdate = Date().start() + 86400
        Task {
            do {
                let menu = try await SageDiningAPI.shared.getMenuItems(on: Date().start())
                completion(Timeline(entries: [
                    LunchWidgetEntry(date: Date(), menu: .success(menu))
                ], policy: .after(nextUpdate)))
            } catch {
                completion(Timeline(entries: [
                    LunchWidgetEntry(date: Date(), menu: .failure(error))
                ], policy: .after(nextUpdate)))
            }
        }
    }
}

struct LunchWidgetEntry: TimelineEntry {
    var date: Date
    let menu: Result<SageDiningMenuItems, Error>?
}



struct LunchWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LunchWidgetEntry
    
    var body: some View {
        switch family {
        case .systemSmall, .systemMedium: LunchWidgetSmallView(entry: entry)
        case .systemLarge, .systemExtraLarge: LunchWidgetLargeView(entry: entry)
        default: EmptyView()
        }
    }
}

struct LunchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.jimphieffer.CA.LunchWidget", provider: LunchWidgetProvider()) { entry in
            LunchWidgetView(entry: entry)
        }
        .configurationDisplayName("CA Lunch Widget")
        .description("Displays information about that day's lunch.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
