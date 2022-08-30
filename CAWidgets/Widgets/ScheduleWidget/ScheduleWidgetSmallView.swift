//
//  ScheduleWidgetSmallView.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/29/22.
//

import SwiftUI

struct ScheduleWidgetSmallView: View {
    var entry: ScheduleWidgetEntry
    
    let formatter = DateFormatter("h:mm a", timeZone: .current)
    
    var body: some View {
        switch entry.schedule {
        case .success(let schedule): HStack {
            VStack(alignment: .leading) {
                Text("Current")
                    .font(.footnote)
                    .fontWeight(.bold)
                if let currentClass = schedule.first(where: {
                    (formatter.date(from: $0.myDayStartTime)?.todayRetainingTime() ?? Date().start() + 86400) < Date() &&
                    (formatter.date(from: $0.myDayEndTime)?.todayRetainingTime() ?? Date().start()) > Date()
                }) {
                    Text(currentClass.courseTitle)
                        .lineLimit(1)
                    if #available(iOSApplicationExtension 16.0, *) {
                        Text("\(currentClass.myDayStartTime) - \(currentClass.myDayEndTime)")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    } else {
                        Text("\(currentClass.myDayStartTime) - \(currentClass.myDayEndTime)")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if #available(iOSApplicationExtension 16.0, *) {
                        Text("\(currentClass.block.count == 0 ? "No Block" : currentClass.block) - \(currentClass.roomNumber.count == 0 ? "No Room" : currentClass.roomNumber)")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    } else {
                        Text("\(currentClass.block.count == 0 ? "No Block" : currentClass.block) - \(currentClass.roomNumber.count == 0 ? "No Room" : currentClass.roomNumber)")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("No Class")
                }
                Spacer()
                Text("Next")
                    .font(.footnote)
                    .fontWeight(.bold)
                if let nextClass = schedule.first(where: {
                    (formatter.date(from: $0.myDayStartTime)?.todayRetainingTime() ?? Date().start()) > Date()
                }) {
                    Text(nextClass.courseTitle)
                        .lineLimit(1)
                    if #available(iOSApplicationExtension 16.0, *) {
                        Text("\(nextClass.myDayStartTime) - \(nextClass.myDayEndTime)")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    } else {
                        Text("\(nextClass.myDayStartTime) - \(nextClass.myDayEndTime)")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if #available(iOSApplicationExtension 16.0, *) {
                        Text("\(nextClass.block.count == 0 ? "No Block" : nextClass.block) - \(nextClass.roomNumber.count == 0 ? "No Room" : nextClass.roomNumber)")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    } else {
                        Text("\(nextClass.block.count == 0 ? "No Block" : nextClass.block) - \(nextClass.roomNumber.count == 0 ? "No Room" : nextClass.roomNumber)")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("No Class")
                }
            }
            Spacer()
        }.padding()
        case .failure(let e): Text("Error: \(e.localizedDescription)")
        }
    }
}
