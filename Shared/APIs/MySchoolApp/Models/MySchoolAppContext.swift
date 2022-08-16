//
//  Context.swift
//  CA
//
//  Created by Jim Phieffer on 8/11/22.
//

import Foundation

// MARK: - Context
struct MySchoolAppContext: Codable {
    let expire: String
    let generated: String
    let cacheSource: String
    let userInfo: MySchoolAppContextUserInfo
    let masterUserInfo: MySchoolAppContextUserInfo
    let tasks: [MySchoolAppContextTask]
    let personas: [MySchoolAppContextPersona]
    let groups: [MySchoolAppContextGroup]
    let isImpersonating: Bool
    let showGuidedTours: Bool
    let guidedTourSetting: Bool
    let directories: [MySchoolAppContextDirectory]
    let calendars: [MySchoolAppContextCalendar]
    let podiumCalendars: [MySchoolAppContextCalendar]
    let userParam: MySchoolAppContextUserParam
    let inboxSettings: MySchoolAppContextInboxSettings
    let isBBIDUser: Bool

    enum CodingKeys: String, CodingKey {
        case expire
        case generated
        case cacheSource
        case userInfo
        case masterUserInfo
        case tasks
        case personas
        case groups
        case isImpersonating
        case showGuidedTours
        case guidedTourSetting
        case directories
        case calendars
        case podiumCalendars
        case userParam
        case inboxSettings
        case isBBIDUser
    }
}

// MARK: - ContextCalendar
struct MySchoolAppContextCalendar: Codable {
    let viewID: Int
    let title: String

    enum CodingKeys: String, CodingKey {
        case viewID
        case title
    }
}

// MARK: - ContextDirectory
struct MySchoolAppContextDirectory: Codable {
    let directoryID: Int
    let directoryName: String

    enum CodingKeys: String, CodingKey {
        case directoryID
        case directoryName
    }
}

// MARK: - ContextGroup
struct MySchoolAppContextGroup: Codable {
    let leadSectionID: Int
    let sectionID: Int
    let currentSectionID: Int
    let association: Int
    let offeringID: Int
    let groupName: String
    let schoolYear: String
    let sectionBlock: String
    let ownerName: String
    let category: String
    let publishGroupToUser: Bool
    let currentEnrollment: Bool

    enum CodingKeys: String, CodingKey {
        case leadSectionID
        case sectionID
        case currentSectionID
        case association
        case offeringID
        case groupName
        case schoolYear
        case sectionBlock
        case ownerName
        case category
        case publishGroupToUser
        case currentEnrollment
    }
}

// MARK: - ContextInboxSettings
struct MySchoolAppContextInboxSettings: Codable {
    let bulkEmailEnabled: Bool
    let googleLabel: String
    let googleURL: String
    let googleAccessGranted: Bool

    enum CodingKeys: String, CodingKey {
        case bulkEmailEnabled
        case googleLabel
        case googleURL
        case googleAccessGranted
    }
}

// MARK: - ContextUserInfo
struct MySchoolAppContextUserInfo: Codable {
    let userId: Int
    let firstName: String
    let lastName: String
    let email: String
    let userName: String
    let legacyUserName: String
    let hostID: String
    let nickName: String
    let userInfoPrefix: String
    let suffix: String
    let middleName: String
    let emailIsBad: Bool
    let otherLastName: String
    let ccEmailIsBad: Bool
    let studentDisplay: String
    let studentInfo: MySchoolAppContextStudentInfo
    let isLost: Bool
    let gender: String
    let birthDate: String
    let miscBio: String
    let lockerNbr: String
    let lockerCombo: String
    let studentResponsibleSignerInd: Bool
    let publishUserPage: Bool
    let gradebookDefaultInd: Bool
    let customField1: String
    let customField2: String
    let customField3: String
    let profilePhoto: MySchoolAppContextProfilePhoto
    let profilePhotoFile: MySchoolAppContextProfilePhotoFile
    let bbid: String
    let insertDate: String
    let lastModifyDate: String
    let lastModifyUserId: Int
}

// MARK: - ContextProfilePhoto
struct MySchoolAppContextProfilePhoto: Codable {
    let id: Int
    let largeFilenameURL: String
    let largeFilename: String
    let largeHeight: Int
    let largeWidth: Int
    let thumbFilenameURL: String
    let thumbFilename: String
    let thumbWidth: Int
    let thumbHeight: Int
    let zoomFilenameURL: String
    let originalFilenameURL: String
    let originalFilename: String
    let photoEditSettings: String
    let title: String
    let caption: String
    let photoAlttext: String
    let hoverAlttext: String
    let longDescription: String
    let originalFilenameEditedURL: String
    let largeFilenameEditedURL: String
    let zoomFilenameEditedURL: String
    let thumbFilenameEditedURL: String
}

// MARK: - ContextProfilePhotoFile
struct MySchoolAppContextProfilePhotoFile: Codable {
    let attachment: String
    let downloadHref: String
    let openHref: String

    enum CodingKeys: String, CodingKey {
        case attachment
        case downloadHref
        case openHref
    }
}

// MARK: - ContextStudentInfo
struct MySchoolAppContextStudentInfo: Codable {
    let gradYear: String

    enum CodingKeys: String, CodingKey {
        case gradYear
    }
}

// MARK: - ContextPersona
struct MySchoolAppContextPersona: Codable {
    let id: Int
    let personaDescription: String
    let longDescription: String
    let type: Int
    let sort: Int
    let active: Bool
    let startingPageId: Int
    let startingPageName: String
    let urlFriendlyDescription: String
    let url: String
    let selected: Bool
}

// MARK: - ContextTask
struct MySchoolAppContextTask: Codable {
    let taskId: Int
    let applicationID: Int
    let taskTypeId: Int
    let taskDescription: String
    let hashString: String?
    let personas: String
    let roles: String
    let roleTypes: String?
    let taskRef: String?
    let parentTaskId: Int?
    let navLocation: Int?
    let sortOrder: Int?
}

// MARK: - ContextUserParam
struct MySchoolAppContextUserParam: Codable {
    let listPersonas: String

    enum CodingKeys: String, CodingKey {
        case listPersonas
    }
}
