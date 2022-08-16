//
//  CalendarFilterView.swift
//  CA
//
//  Created by Jim Phieffer on 8/15/22.
//

import SwiftUI

struct CalendarFilterView: View {
    var calendars: MySchoolAppCalendarList
    @Binding var selections: [String: [String: Bool]]
    @Binding var isPresented: Bool
    var body: some View {
        NavigationView {
            Form {
                ForEach(calendars.filter({ $0.filters != nil && $0.filters!.count > 0 }), id: \.calendarId) { calendar in
                    Section(calendar.calendar) {
                        ForEach(calendar.filters!, id: \.calendarId) { filter in
                            Toggle(isOn: binding(section: calendar.calendarId, row: filter.calendarId)) {
                                Text(filter.filterName ?? "")
                            }.toggleStyle(CheckmarkToggleStyle())
                        }
                    }
                }
            }.navigationTitle("Calendars")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Done")
                        }
                    }
                }
        }
    }
    
    fileprivate func binding(section: String, row: String) -> Binding<Bool> {
        return .init(get: {
            return selections[section]?[row] ?? false
        }, set: {
            selections[section]![row] = $0
        })
    }
}

// from https://stackoverflow.com/questions/57022615/select-multiple-items-in-swiftui-list - simibac's answer
struct CheckmarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Button(action: { withAnimation { configuration.$isOn.wrappedValue.toggle() }}){
                HStack{
                    configuration.label.foregroundColor(.primary)
                    Spacer()
                    if configuration.isOn {
                        Image(systemName: "checkmark").foregroundColor(.primary)
                    }
                }
            }
        }
    }
}
