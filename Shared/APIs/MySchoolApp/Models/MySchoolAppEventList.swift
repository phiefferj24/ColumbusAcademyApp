//
//  ScheduleList.swift
//  CA
//
//  Created by Jim Phieffer on 8/11/22.
//

import Foundation

// MARK: - MySchoolAppEventListElement
struct MySchoolAppEventListElement: Codable {
    let associationId: Int
    let briefDescription: String
    let buildingName: String
    let cancelled: Bool
    let contactEmail: String
    let contactName: String
    let endDate: String
    let eventId: Int
    let eventType: String
    let groupId: Int
    let groupName: String
    let homeAway: String
    let invitational: Bool
    let league: Bool
    let location: String
    let longDescription: String
    let opponent: String
    let playoff: Bool
    let presetId: Int
    let recurrenceId: Int
    let rescheduled: Bool
    let rescheduleNote: String
    let roomName: String
    let scrimmage: Bool
    let startDate: String
    let title: String
    let tournament: Bool
    let userId: Int
    let allDay: Bool
    let externalUid: String
    let totalDays: Int
}


typealias MySchoolAppEventList = [MySchoolAppEventListElement]
