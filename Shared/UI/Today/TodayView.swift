//
//  TodayView.swift
//  CA
//
//  Created by Jim Phieffer on 8/16/22.
//

import Foundation
import SwiftUI
import Introspect

struct TodayView: View {
    @StateObject var todayViewModel = TodayViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    TodayHeaderView(letterDay: $todayViewModel.letterDay)
                    ScheduleView(schedule: $todayViewModel.schedule)
                    LunchPreviewView(menuItems: $todayViewModel.menuItems, selectedDate: Binding.constant(Date().start()))
                    CalendarDetailView(events: $todayViewModel.events, selectedDate: Binding.constant(Date().start()))
                }.navigationBarTitleDisplayMode(.inline)
            }.introspectScrollView { scrollView in
                scrollView.refreshControl = todayViewModel.refreshControl
            }
        }.task {
            await todayViewModel.refreshCalendars(from: Date().startOfMonth(), to: Date().startOfNextMonth())
            await todayViewModel.refreshEvents(from: Date().start(), to: Date().start() + 86400)
            await todayViewModel.refreshLetterDay()
            await todayViewModel.refreshSchedule(for: Date().start())
            await todayViewModel.refreshMenuItems(on: Date().start())
        }
    }
}

@MainActor class TodayViewModel: ObservableObject {
    @Published var letterDay: String?
    
    @Published var events: Result<[Date: [Event]], Error>?
    @Published var calendars: Result<MySchoolAppCalendarList, Error>?
    @Published var schedule: Result<MySchoolAppScheduleList, Error>?
    @Published var menuItems: Result<SageDiningMenuItems, Error>?
    
    @AppStorage("app.calendar.selections", store: UserDefaults(suiteName: "group.com.jimphieffer.CA")) var selections: Storable<[String: [String: Bool]]> = Storable([String: [String: Bool]]())
    
    @Published var refreshControl = UIRefreshControl()

    var observers: [NSObjectProtocol] = []
    
    init() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        observers.append(
            NotificationCenter.default.addObserver(forName: Notification.Name("api.myschoolapp.loginComplete"), object: nil, queue: OperationQueue.main) { [weak self] _ in
                Task { @MainActor [weak self] in
                    await self?.refreshCalendars(from: Date().startOfMonth(), to: Date().startOfNextMonth(), refresh: true)
                    await self?.refreshEvents(from: Date().start(), to: Date().start() + 86400, refresh: true)
                    await self?.refreshLetterDay(refresh: true)
                    await self?.refreshSchedule(for: Date().start(), refresh: true)
                    await self?.refreshMenuItems(on: Date().start(), refresh: true)
                }
            }
        )
    }
    
    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @objc func refresh() {
        Task { [weak self] in
            if let self = self {
                await self.refreshCalendars(from: Date().startOfMonth(), to: Date().startOfNextMonth(), refresh: true)
                await self.refreshEvents(from: Date().start(), to: Date().start() + 86400, refresh: true)
                await self.refreshLetterDay(refresh: true)
                await self.refreshSchedule(for: Date().start(), refresh: true)
                await self.refreshMenuItems(on: Date().start(), refresh: true)
                self.refreshControl.endRefreshing()
            }
        }
    }

    func refreshCalendars(from start: Date, to end: Date, refresh: Bool = false) async {
        do {
            let calendars = try await MySchoolAppAPI.shared.getCalendars(from: start, to: end, refresh: refresh)
            for calendar in calendars {
                if selections.value[calendar.calendarId] == nil {
                    selections.value[calendar.calendarId] = [:]
                    for filter in calendar.filters ?? [] {
                        selections.value[calendar.calendarId]![filter.calendarId] = selections.value[calendar.calendarId]![filter.calendarId] ?? true
                    }
                }
            }
            selections = Storable(selections.value)
            self.calendars = .success(calendars)
        } catch {
            calendars = .failure(error)
        }
    }
    func refreshMenuItems(for meal: String = "Lunch", on date: Date, menu: String? = nil, refresh: Bool = false) async {
        do {
            self.menuItems = .success(try await SageDiningAPI.shared.getMenuItems(for: meal, on: date, menu: menu, refresh: refresh))
        } catch {
            self.menuItems = .failure(error)
        }
    }
    func refreshEvents(from start: Date, to end: Date, refresh: Bool = false) async {
        guard let calendars = try? calendars?.get() else { return }
        var selectedCalendars: [String] = []
        selections.value.forEach { selection in
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
    func refreshLetterDay(refresh: Bool = false) async {
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
    func refreshSchedule(for date: Date, refresh: Bool = false) async {
        do {
            self.schedule = .success(try await MySchoolAppAPI.shared.getSchedule(for: date, refresh: refresh))
        } catch {
            self.schedule = .failure(error)
        }
    }
}
