//
//  CalendarView.swift
//  CA
//
//  Created by Jim Phieffer on 8/15/22.
//

import SwiftUI
import Introspect

struct CalendarView: View {
    @StateObject var calendarViewModel = CalendarViewModel()
    
    let columns = [GridItem](repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        NavigationView {
            switch calendarViewModel.calendars {
            case .success(_): ScrollView {
                VStack {
                    HStack {
                        Button(action: {
                            calendarViewModel.decrementMonth()
                        }) {
                            Image(systemName: "chevron.left.circle")
                        }.padding()
                        Spacer()
                        Text(verbatim: "\(Calendar.current.monthSymbols[calendarViewModel.selectedMonth - 1]) \(calendarViewModel.selectedYear)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            calendarViewModel.incrementMonth()
                        }) {
                            Image(systemName: "chevron.right.circle")
                        }.padding()
                    }
                    LazyVGrid(columns: columns) {
                        ForEach(Calendar.current.veryShortStandaloneWeekdaySymbols.enumerated().map({ ($0.offset, $0.element) }), id: \.0) { symbol in
                            Text(symbol.1).fontWeight(.bold)
                        }
                    }.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    Divider()
                    LazyVGrid(columns: columns) {
                        ForEach(calendarViewModel.getDatesInCurrentMonth(), id: \.0) { (date, inCurrentMonth) in
                            Button(action: {
                                if date == calendarViewModel.selectedDate && calendarViewModel.detailViewPresented {
                                    calendarViewModel.detailViewPresented = false
                                    return
                                }
                                calendarViewModel.detailViewPresented = true
                                calendarViewModel.selectedDate = date
                                calendarViewModel.dateChanged()
                                if !inCurrentMonth {
                                    calendarViewModel.selectedYear = Calendar.current.component(.year, from: date)
                                    calendarViewModel.selectedMonth = Calendar.current.component(.month, from: date)
                                    calendarViewModel.monthChanged()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .foregroundColor(date == calendarViewModel.selectedDate && calendarViewModel.detailViewPresented ? .accentColor : .clear)
                                    Text(String(Calendar.current.component(.day, from: date)))
                                        .foregroundColor(
                                            date == calendarViewModel.selectedDate && calendarViewModel.detailViewPresented ? .white :
                                                (Calendar.current.isDateInToday(date) ? .red :
                                                (inCurrentMonth ? .primary : .secondary))
                                        )
                                        .padding(10)
                                    }
                            }
                                
                        }
                    }.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    if calendarViewModel.detailViewPresented {
                        ScheduleView(schedule: $calendarViewModel.schedule)
                        LunchPreviewView(menuItems: $calendarViewModel.menuItems, selectedDate: $calendarViewModel.selectedDate)
                        CalendarDetailView(events: $calendarViewModel.events, selectedDate: $calendarViewModel.selectedDate)
                    }
                    Spacer()
                }
            }.introspectScrollView { scrollView in
                scrollView.refreshControl = calendarViewModel.refreshControl
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CalendarFilterView(calendarViewModel: calendarViewModel)) {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
            case .failure(_): ScrollView {
                Text("Error. Pull down to retry.")
            }.introspectScrollView { scrollView in
                scrollView.refreshControl = calendarViewModel.refreshControl
            }
            case nil: VStack {
                Text("Loading...")
                ProgressView()
            }
            }
        }.task {
            if let date = Calendar.current.date(from: DateComponents(year: calendarViewModel.selectedYear, month: calendarViewModel.selectedMonth)) {
                await calendarViewModel.refreshCalendars(from: date.startOfMonth(), to: date.startOfNextMonth())
                await calendarViewModel.refreshEvents(from: date.startOfMonth(), to: date.startOfNextMonth())
                await calendarViewModel.refreshSchedule(for: calendarViewModel.selectedDate)
                await calendarViewModel.refreshMenuItems(on: calendarViewModel.selectedDate)
            }
        }
    }
}

@MainActor class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var selectedMonth = Calendar.current.component(.month, from: Date())
    @Published var selectedYear = Calendar.current.component(.year, from: Date())
    
    @Published var detailViewPresented = false
    
    @Published var events: Result<[Date: [Event]], Error>?
    
    @Published var calendars: Result<MySchoolAppCalendarList, Error>?
    
    @Published var schedule: Result<MySchoolAppScheduleList, Error>?
    
    @AppStorage("app.calendar.selections", store: UserDefaults(suiteName: "group.com.jimphieffer.CA")) var selections: Storable<[String: [String: Bool]]> = Storable([String: [String: Bool]]())
    
    @Published var currentCalendarTask: Task<Void, Error>?
    @Published var currentMenuTask: Task<Void, Error>?
    
    @Published var menuItems: Result<SageDiningMenuItems, Error>?
    
    @Published var refreshControl = UIRefreshControl()
    
    init() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        Task { [weak self] in
            if let self = self {
                if let date = Calendar.current.date(from: DateComponents(year: self.selectedYear, month: self.selectedMonth)) {
                    await self.refreshCalendars(from: date.startOfMonth(), to: date.startOfNextMonth(), refresh: true)
                    await self.refreshEvents(from: date.startOfMonth(), to: date.startOfNextMonth(), refresh: true)
                    await self.refreshSchedule(for: self.selectedDate, refresh: true)
                    await self.refreshMenuItems(on: self.selectedDate, refresh: true)
                }
                self.refreshControl.endRefreshing()
            }
        }
    }

    func getDatesInCurrentMonth() -> [(Date, Bool)] {
        var dates: [(Date, Bool)] = []
        guard var dateOn = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth)) else { return [] }
        while Calendar.current.component(.weekday, from: dateOn) != 1 {
            dateOn = Calendar.current.date(byAdding: .day, value: -1, to: dateOn)!
        }
        while Calendar.current.component(.weekday, from: dateOn) != 1
                || Calendar.current.component(.month, from: dateOn) != (selectedMonth == 12 ? 1 : selectedMonth + 1)
                || Calendar.current.component(.year, from: dateOn) != (selectedMonth == 12 ? selectedYear + 1 : selectedYear) {
            dates.append((dateOn, Calendar.current.component(.month, from: dateOn) == selectedMonth))
            dateOn = Calendar.current.date(byAdding: .day, value: 1, to: dateOn)!
        }
        return dates
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
        selections = Storable(selections.value)
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
    
    func refreshCalendars(from start: Date, to end: Date, refresh: Bool = false) async {
        do {
            let calendars = try await MySchoolAppAPI.shared.getCalendars(from: start, to: end, refresh: refresh)
            for calendar in calendars {
                if selections.value[calendar.calendarId] == nil {
                    selections.value[calendar.calendarId] = [:]
                    for filter in calendar.filters ?? [] {
                        selections.value[calendar.calendarId]![filter.calendarId] = selections.value[calendar.calendarId]![filter.calendarId] ?? false
                    }
                }
            }
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
    
    func refreshSchedule(for date: Date, refresh: Bool = false) async {
        do {
            self.schedule = .success(try await MySchoolAppAPI.shared.getSchedule(for: date, refresh: refresh))
        } catch {
            self.schedule = .failure(error)
        }
    }
    
    func incrementMonth() {
        if (selectedMonth == 12) {
            selectedYear += 1
            selectedMonth = 1
        } else {
            selectedMonth += 1
        }
        monthChanged()
    }
    
    func decrementMonth() {
        if (selectedMonth == 1) {
            selectedYear -= 1
            selectedMonth = 12
        } else {
            selectedMonth -= 1
        }
        monthChanged()
    }
    
    func monthChanged() {
        currentCalendarTask?.cancel()
        currentCalendarTask = Task {
            if let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth)) {
                await refreshEvents(from: date.startOfMonth(), to: date.startOfNextMonth(), refresh: true)
            }
        }
    }
    
    func dateChanged() {
        currentMenuTask?.cancel()
        currentMenuTask = Task {
            menuItems = nil
            schedule = nil
            await refreshSchedule(for: selectedDate)
            await refreshMenuItems(on: selectedDate)
        }
    }
    
    func binding(section: String, row: String) -> Binding<Bool> {
       return .init(get: { [weak self] in
           return self?.selections.value[section]?[row] ?? false
       }, set: { [weak self] in
           if let self = self {
               self.selections.value[section]![row] = $0
               Task {
                   await MainActor.run {
                       self.selections = Storable(self.selections.value)
                   }
               }
           }
       })
   }
}

struct Event {
    var id: Int
    let allDay: Bool
    let start: Date
    let end: Date
    let title: String
    let description: String?
    let color: Color?
}

