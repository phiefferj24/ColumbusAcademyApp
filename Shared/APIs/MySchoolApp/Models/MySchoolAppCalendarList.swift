//
//  MySchoolAppCalendarList.swift
//  CA
//
//  Created by Jim Phieffer on 8/14/22.
//

import Foundation

// MARK: - MySchoolAppCalendarListElement
struct MySchoolAppCalendarListElement: Codable {
    let associationId: Int
    let backgroundColor: String?
    let calendar: String
    let calendarId: String
    let filterName: String?
    let filterLeadPk: Int?
    let filters: [MySchoolAppCalendarListElement]?
}

typealias MySchoolAppCalendarList = [MySchoolAppCalendarListElement]
