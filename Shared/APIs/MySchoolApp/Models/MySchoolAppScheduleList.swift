//
//  MySchoolAppScheduleList.swift
//  CA
//
//  Created by Jim Phieffer on 8/22/22.
//

import Foundation

// MARK: - MySchoolAppScheduleListElement
struct MySchoolAppScheduleListElement: Codable {
    let courseTitle: String
    let startTime: String
    let endTime: String
    let block: String
    let roomNumber: String
    let buildingName: String
    let myDayStartTime: String
    let myDayEndTime: String
}

typealias MySchoolAppScheduleList = [MySchoolAppScheduleListElement]
