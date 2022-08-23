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
    let calendarDate: String
    let startTime: String
    let endTime: String
    let block: String
    let blockId: Int
    let roomId: Int
    let publishGroupToUser: Int
    let sectionId: Int
    let leadSectionId: Int
    let offeringType: Int
    let attendanceTaken: Int
    let attendanceRequired: Bool
    let roomNumber: String
    let buildingName: String
    let numAbsent: Int
    let rankNum: Int
    let offeringId: Int
    let hasSeatingChart: Bool
    let myDayStartTime: String
    let myDayEndTime: String
    let minuteDiff: Int
    let rankCount: Int
    let rankOrder: Int
    let scheduleItemType: String
    let opponent: String
    let directions: String
    let canceledInd: Bool
    let rescheduledInd: Bool
    let canceledStr: String
    let associationId: Int
    let levelDescription: String
    let levelNum: Int
    let athHomeAway: String
    let contact: String
    let contactEmail: String
    let contactId: Int
    let attendanceDisplay: String
    let attendanceInd: Int
    let attendanceComment: String
    let linkableCoursePage: Bool
    let rescheduledNote: String
    let additionalDetails: Bool
    let scheduleId: Int
    let displayAttendance: Bool
    let index: Int
    let facultyUserId: Int
    let useOnCampusAtt: Bool
    let attendanceTypeId: Int
    let enrollmentTypeDescription: String
    let enrollmentAttendanceTaken: Bool
    let excuseTypeId: Int
    let roomCapacity: Int
    let courseTitleEnrollmentDescription: String
}

typealias MySchoolAppScheduleList = [MySchoolAppScheduleListElement]
