//
//  TodayView.swift
//  CA
//
//  Created by Jim Phieffer on 8/16/22.
//

import Foundation
import SwiftUI

struct TodayView: View {
    
    @State var letterDay: String?
    
    @State var events: Result<[Date: [Event]], Error>?
    @State var calendars: Result<MySchoolAppCalendarList, Error>?
    @State var menuItems: Result<SageDiningMenuItems, Error>?
    
    @AppStorage("app.calendar.selections") var selectionData: Data?
    
    @State var selections: [String: [String: Bool]] = [:]
    
    init() {
        if let selectionData = selectionData, let selections = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(selectionData) as? [String: [String: Bool]] {
            self.selections = selections
        }
    }
    
    var body: some View {
        NavigationView {
            RefreshableView {
                VStack {
                    TodayHeaderView(letterDay: $letterDay)
                    LunchPreviewView(menuItems: $menuItems, selectedDate: Binding.constant(Date()))
                    CalendarDetailView(events: $events, selectedDate: Binding.constant(Date()))
                }.navigationBarTitleDisplayMode(.inline)
            }.refreshable {
                await refreshCalendars(from: Date().startOfMonth(), to: Date().startOfNextMonth(), refresh: true)
                await refreshEvents(from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: Date() + 86400), refresh: true)
                await refreshLetterDay(refresh: true)
                await refreshMenuItems(on: Date(), refresh: true)
            }
        }.task {
            await refreshCalendars(from: Date().startOfMonth(), to: Date().startOfNextMonth())
            await refreshEvents(from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: Date() + 86400))
            await refreshLetterDay()
            await refreshMenuItems(on: Date())
        }.onChange(of: selectionData) { newValue in
            if let selectionData = newValue, let selections = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(selectionData) as? [String: [String: Bool]] {
                self.selections = selections
            }
        }
    }
    
    fileprivate func refreshLetterDay(refresh: Bool = false) async {
        do {
            guard let calendars = try? calendars?.get() else { return }
            for calendar in calendars {
                for filter in calendar.filters ?? [] {
                    if filter.filterName == "Master Calendar" {
                        let letterDays = try await MySchoolAppAPI.shared.getEvents(from: Date(), to: Date().addingTimeInterval(86400), for: [filter.calendarId], refresh: true, nocache: true)
                        if let letterDay = letterDays.first(where: { $0.title.range(of: "^[A-F] Day$", options: .regularExpression) != nil }) {
                            self.letterDay = letterDay.title
                        }
                        return
                    }
                }
            }
        } catch {}
    }
    
    fileprivate func refreshEvents(from start: Date, to end: Date, refresh: Bool = false) async {
        guard let calendars = try? calendars?.get() else { return }
        var selectedCalendars: [String] = []
        selections.forEach { selection in
            selection.value.forEach { calendar in
                if calendar.value {
                    selectedCalendars.append(calendar.key)
                }
            }
        }
        do {
            let events = try await MySchoolAppAPI.shared.getEvents(from: start, to: end, for: selectedCalendars, refresh: refresh)
            let mappedEvents = try events.map { event -> Event in
                var color: Color?
                for calendar in calendars {
                    for filter in calendar.filters ?? [] {
                        if filter.filterLeadPk == event.groupId, let hex = filter.backgroundColor {
                            color = Color(hex: hex)
                        }
                    }
                }
                return Event(id: event.eventId, allDay: event.allDay, start: try Date(event.startDate, strategy: .dateTime), end: try Date(event.endDate, strategy: .dateTime), title: event.title, description: event.briefDescription.count > 0 ? event.briefDescription : nil, color: color)
            }
            var groupedEvents: [Date: [Event]] = [:]
            mappedEvents.forEach { event in
                let date = Calendar.current.startOfDay(for: event.start)
                if groupedEvents[date] == nil {
                    groupedEvents[date] = []
                }
                groupedEvents[date]!.append(event)
            }
            self.events = .success(groupedEvents)
        } catch {
            events = .failure(error)
        }
    }
    
    fileprivate func refreshMenuItems(for meal: String = "Lunch", on date: Date, menu: String? = nil, refresh: Bool = false) async {
        do {
            self.menuItems = .success(try await SageDiningAPI.shared.getMenuItems(for: meal, on: date, menu: menu, refresh: refresh))
        } catch {
            self.menuItems = .failure(error)
        }
    }
    
    fileprivate func refreshCalendars(from start: Date, to end: Date, refresh: Bool = false) async {
        do {
            let calendars = try await MySchoolAppAPI.shared.getCalendars(from: start, to: end, refresh: refresh)
            for calendar in calendars {
                selections[calendar.calendarId] = [:]
                for filter in calendar.filters ?? [] {
                    selections[calendar.calendarId]![filter.calendarId] = filter.selected ?? false
                }
            }
            self.calendars = .success(calendars)
        } catch {
            calendars = .failure(error)
        }
    }
}
