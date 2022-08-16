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
    let calendarSortOrder: Int
    let categoryDescription: String?
    let filterLeadPk: Int?
    let filterName: String?
    let includePractice: Bool?
    let isOwner: Bool?
    let personaId: Int?
    let presetId: Int?
    let presetTypeId: Int?
    let selected: Bool?
    let textColor: String?
    let userPhoto: String?
    let zoneID: Int?
    let calendarSetId: Int?
    let filters: [MySchoolAppCalendarListElement]?
}

typealias MySchoolAppCalendarList = [MySchoolAppCalendarListElement]
