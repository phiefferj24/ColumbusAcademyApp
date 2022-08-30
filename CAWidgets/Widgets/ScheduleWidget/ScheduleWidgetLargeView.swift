//
//  ScheduleWidgetLargeView.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/29/22.
//

import SwiftUI

struct ScheduleWidgetLargeView: View {
    let entry: ScheduleWidgetEntry
    let smallFormatter = DateFormatter("h:mm a", timeZone: .current)
    let formatter = DateFormatter("EEEE, MMMM d, YYYY")
    
    var body: some View {
        switch entry.schedule {
        case .success(let schedule): VStack(alignment: .leading) {
            Text(formatter.string(from: Date()))
                .fontWeight(.bold)
            ForEach(schedule.filter({ (smallFormatter.date(from: $0.myDayEndTime)?.todayRetainingTime() ?? Date().start()) > Date() }).clamped(to: 4), id: \.startTime) { item in
                Divider()
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
                }.padding(EdgeInsets(top: 2.5, leading: 0, bottom: 2.5, trailing: 0))
            }
            Spacer()
        }.padding(10)
        case .failure(let error): Text("Error: \(error.localizedDescription)")
        }
    }
}

