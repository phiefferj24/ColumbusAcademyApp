//
//  ScheduleView.swift
//  CA
//
//  Created by Jim Phieffer on 8/22/22.
//

import SwiftUI

struct ScheduleView: View {
    @Binding var schedule: Result<MySchoolAppScheduleList, Error>?
    
    @State var dropped = true
    
    let hours = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM",
                 "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]
    
    let formatter = DateFormatter("h:mm a", timeZone: .current)
    
    var body: some View {
        VStack {
            Divider()
            switch schedule {
            case .success(let schedule): HStack {
                    Text("Schedule")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: { dropped.toggle() }) {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(dropped ? 180 : 0))
                            .animation(.linear.speed(3), value: dropped)
                    }
                }.padding(10)
                LazyVStack {
                    if dropped {
                        ForEach(schedule, id: \.startTime) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(item.courseTitle)
                                        .fontWeight(.bold)
                                    Text("\(item.block.count == 0 ? "No Block" : item.block) - \(item.roomNumber.count == 0 ? "No Room" : item.roomNumber)")
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 10) {
                                    Text(item.myDayStartTime)
                                    Text(item.myDayEndTime)
                                        .foregroundColor(.secondary)
                                }
                            }
                            if item.startTime != schedule.last?.startTime {
                                Divider()
                            }
                        }.padding(EdgeInsets(top: 2.5, leading: 10, bottom: 2.5, trailing: 10))
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
