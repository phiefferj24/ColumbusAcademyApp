//
//  CalendarView.swift
//  CA
//
//  Created by Jim Phieffer on 8/15/22.
//

import SwiftUI

struct CalendarView: View {
    @State var selectedDate = Date()
    @State var selectedMonth = Calendar.current.component(.month, from: Date())
    @State var selectedYear = Calendar.current.component(.year, from: Date())
    
    @State var detailViewPresented = false
    
    @State var events: Result<[Date: [Event]], Error>?
    
    @State var calendars: Result<MySchoolAppCalendarList, Error>?
    
    @AppStorage("app.calendar.selections") var selectionData: Data?
    @State var selections: [String: [String: Bool]] = [:]

    @State var filterViewPresented = false
    
    @State var currentCalendarTask: Task<Void, Error>?
    @State var currentMenuTask: Task<Void, Error>?
    
    @State var menuItems: Result<SageDiningMenuItems, Error>?
    
    let columns = [GridItem](repeating: GridItem(.flexible()), count: 7)
    
    init() {
        if let selectionData = selectionData, let selections = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(selectionData) as? [String: [String: Bool]] {
            self.selections = selections
        }
    }
    
    var body: some View {
        NavigationView {
            switch calendars {
            case .success(let calendars): RefreshableView {
                VStack {
                    HStack {
                        Button(action: {
                            if (selectedMonth == 1) {
                                selectedYear -= 1
                                selectedMonth = 12
                            } else {
                                selectedMonth -= 1
                            }
                            currentCalendarTask?.cancel()
                            currentCalendarTask = Task {
                                if let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth)) {
                                    await refreshEvents(from: date.startOfMonth(), to: date.startOfNextMonth(), refresh: true)
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left.circle")
                        }.padding()
                        Spacer()
                        Text(verbatim: "\(Calendar.current.monthSymbols[selectedMonth - 1]) \(selectedYear)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            if (selectedMonth == 12) {
                                selectedYear += 1
                                selectedMonth = 1
                            } else {
                                selectedMonth += 1
                            }
                            currentCalendarTask?.cancel()
                            currentCalendarTask = Task {
                                if let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth)) {
                                    await refreshEvents(from: date.startOfMonth(), to: date.startOfNextMonth(), refresh: true)
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right.circle")
                        }.padding()
                    }
                    LazyVGrid(columns: columns) {
                        ForEach(Calendar.current.veryShortStandaloneWeekdaySymbols.enumerated().map({ ($0.offset, $0.element) }), id: \.0) { symbol in
                            Text(symbol.1).fontWeight(.bold)
                        }
                    }
                    Divider()
                    LazyVGrid(columns: columns) {
                        ForEach(getDatesInCurrentMonth(), id: \.0) { (date, inCurrentMonth) in
                            Button(action: {
                                detailViewPresented = true
                                selectedDate = date
                                if !inCurrentMonth {
                                    selectedYear = Calendar.current.component(.year, from: date)
                                    selectedMonth = Calendar.current.component(.month, from: date)
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .foregroundColor(date == selectedDate ? .red : .clear)
                                    Text(String(Calendar.current.component(.day, from: date)))
                                        .foregroundColor(
                                            date == selectedDate ? .white :
                                                (Calendar.current.isDateInToday(date) ? .red :
                                                (inCurrentMonth ? .primary : .secondary))
                                        )
                                        .padding(10)
                                    }
                            }
                                
                        }
                    }
                    if detailViewPresented {
                        LunchPreviewView(menuItems: $menuItems, selectedDate: $selectedDate)
                        CalendarDetailView(events: $events, selectedDate: $selectedDate)
                    }
                    Spacer()
                }
            }.navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $filterViewPresented) {
                CalendarFilterView(calendars: calendars, selections: $selections, isPresented: $filterViewPresented)
            }.toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { filterViewPresented.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }.refreshable {
                if let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth)) {
                    await refreshCalendars(from: date.startOfMonth(), to: date.startOfNextMonth(), refresh: true)
                    await refreshEvents(from: date.startOfMonth(), to: date.startOfNextMonth(), refresh: true)
                    await refreshMenuItems(on: selectedDate, refresh: true)
                }
            }
            case .failure(_): RefreshableView {
                Text("Error. Pull down to retry.")
            }.refreshable {
                if let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth)) {
                    await refreshCalendars(from: date.startOfMonth(), to: date.startOfNextMonth(), refresh: true)
                    await refreshEvents(from: date.startOfMonth(), to: date.startOfNextMonth(), refresh: true)
                    await refreshMenuItems(on: selectedDate, refresh: true)
                }
            }
            case nil: VStack {
                Text("Loading...")
                ProgressView()
            }
            }
        }.task {
            if let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth)) {
                await refreshCalendars(from: date.startOfMonth(), to: date.startOfNextMonth())
                await refreshEvents(from: date.startOfMonth(), to: date.startOfNextMonth())
                await refreshMenuItems(on: selectedDate)
            }
        }.onChange(of: selectedDate) { selectedDate in
            currentMenuTask?.cancel()
            currentMenuTask = Task {
                menuItems = nil
                await refreshMenuItems(on: selectedDate)
            }
        }.onChange(of: selections) { newValue in
            if let selectionData = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) {
                self.selectionData = selectionData
            }
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
    
    fileprivate func getDatesInCurrentMonth() -> [(Date, Bool)] {
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
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
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

