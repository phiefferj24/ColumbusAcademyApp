//
//  ScheduleList.swift
//  CA
//
//  Created by Jim Phieffer on 8/11/22.
//

import Foundation

// MARK: - MySchoolAppEventListElement
struct MySchoolAppEventListElement: Codable {
    let briefDescription: String
    let endDate: String
    let eventId: Int
    let groupId: Int
    let startDate: String
    let title: String
    let allDay: Bool
}

typealias MySchoolAppEventList = [MySchoolAppEventListElement]
