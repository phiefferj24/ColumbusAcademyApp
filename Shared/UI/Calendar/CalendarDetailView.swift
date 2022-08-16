//
//  CalendarDetailView.swift
//  CA
//
//  Created by Jim Phieffer on 8/15/22.
//

import SwiftUI

struct CalendarDetailView: View {
    @Binding var events: Result<[Date: [Event]], Error>?
    @Binding var selectedDate: Date
    
    @State var dropped = true
    
    let formatter = DateFormatter("h:mm a")
    
    var body: some View {
        VStack {
            Divider()
            switch events {
            case .success(let events): if let events = events.first(where: { Calendar.current.isDate($0.key, inSameDayAs: selectedDate) })?.value {
                HStack {
                    Text("Events")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: { dropped.toggle() }) {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(dropped ? 180 : 0))
                            .animation(.linear.speed(3), value: dropped)
                    }
                }.padding(10)
                if dropped {
                    LazyVStack {
                        if dropped, let allDayEvents = events.filter({ $0.allDay }) {
                            ForEach(allDayEvents, id: \.id) { event in
                                HStack {
                                    RoundedRectangle(cornerRadius: 2, style: .circular)
                                        .foregroundColor(event.color)
                                        .frame(width: 4)
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(event.title)
                                            .fontWeight(.bold)
                                        if let description = event.description {
                                            Text(description)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 10) {
                                        Text("all-day")
                                    }
                                }.padding(EdgeInsets(top: 2.5, leading: 10, bottom: 2.5, trailing: 10))
                            }
                        }
                        if let timedEvents = events.filter({ !$0.allDay }) {
                            ForEach(timedEvents, id: \.id) { event in
                                HStack {
                                    RoundedRectangle(cornerRadius: 2, style: .circular)
                                        .foregroundColor(event.color)
                                        .frame(width: 4)
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(event.title)
                                            .fontWeight(.bold)
                                        if let description = event.description {
                                            Text(description)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 10) {
                                        Text(formatter.string(from: event.start))
                                        Text(formatter.string(from: event.end))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                }.padding(EdgeInsets(top: 2.5, leading: 10, bottom: 2.5, trailing: 10))
                            }
                        }
                    }
                }
            }
            case .failure(_): Text("Error")
            case nil: VStack {
                Text("Loading...")
                ProgressView()
            }
            }
        }
    }
}

