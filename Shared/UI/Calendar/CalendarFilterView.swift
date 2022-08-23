//
//  CalendarFilterView.swift
//  CA
//
//  Created by Jim Phieffer on 8/15/22.
//

import SwiftUI

struct CalendarFilterView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel

    var body: some View {
        NavigationView {
            Form {
                if case .success(let calendars) = calendarViewModel.calendars {
                    ForEach(calendars.filter({ ($0.filters ?? []).count > 0 }), id: \.calendarId) { calendar in
                        Section(calendar.calendar) {
                            ForEach(calendar.filters ?? [], id: \.calendarId) { filter in
                                Toggle(isOn: calendarViewModel.binding(section: calendar.calendarId, row: filter.calendarId)) {
                                    Text(filter.filterName ?? "")
                                }.toggleStyle(CheckmarkToggleStyle())
                            }
                        }
                    }
                }
            }.navigationTitle("Calendars")
        }
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
