//
//  SchoolContext.swift
//  CA
//
//  Created by Jim Phieffer on 8/11/22.
//

import Foundation

// MARK: - SchoolContext
struct MySchoolAppSchoolContext: Codable {
    let generated: String
    let cacheSource: String
    let expire: String
    let schoolInfo: MySchoolAppSchoolContextSchoolInfo
    let style: MySchoolAppSchoolContextStyle
    let appCategories: [MySchoolAppSchoolContextAppCategory]
    let currentSchoolYear: MySchoolAppSchoolContextCurrentSchoolYear
    let culture: MySchoolAppSchoolContextCulture
    let schoolURL: MySchoolAppSchoolContextSchoolURL
    let cdnUrls: [MySchoolAppSchoolContextCDNURL]
    let trackerURL: String
    let colors: [MySchoolAppSchoolContextColor]
    let labelDictionary: [MySchoolAppSchoolContextColor]
    let eaps: [MySchoolAppSchoolContextEAP]
    let skyNav: Bool
    let caseCentral: String
    let engSysInfo: MySchoolAppSchoolContextEngSysInfo
    let pspdfKitServer: String
    let privateUploadURL: String
    let publicUploadURL: String
    let videoUploadURL: String
}

// MARK: - SchoolContextAppCategory
struct MySchoolAppSchoolContextAppCategory: Codable {
    let categoryID: Int
}

// MARK: - SchoolContextCDNURL
struct MySchoolAppSchoolContextCDNURL: Codable {
    let filePathTypeId: Int
    let cdnURLDescription: String
    let url: String
    let baseURL: String
    let defaultInd: Bool?
    let videoDefaultInd: Bool?
}

// MARK: - SchoolContextColor
struct MySchoolAppSchoolContextColor: Codable {
    let key: String
    let value: String
}

// MARK: - SchoolContextCulture
struct MySchoolAppSchoolContextCulture: Codable {
    let dateTimeFormat: MySchoolAppSchoolContextDateTimeFormat
    let numberFormat: MySchoolAppSchoolContextNumberFormat
    let culture: String
    let app: MySchoolAppSchoolContextApp
}

// MARK: - SchoolContextApp
struct MySchoolAppSchoolContextApp: Codable {
    let closeText: String
    let prevText: String
    let nextText: String
    let currentText: String
    let monthNames: [String]
    let monthNamesShort: [String]
    let dayNames: [String]
    let dayNamesShort: [String]
    let dayNamesMin: [String]
    let weekHeader: String
    let dateFormat: String
    let dateErrorFormat: String
    let yearSuffix: String
    let fullDateTimePattern: String
    let longDatePattern: String
    let longTimePattern: String
    let monthDayPattern: String
    let shortDatePattern: String
    let shortTimePattern: String
    let sortableDateTimePattern: String
    let universalSortableDateTimePattern: String
    let yearMonthPattern: String
    let fullMonthDayPattern: String
    let shortMonthDayPattern: String
    let shortMonthDayYearPattern: String
    let shortDayDatePattern: String
    let shortDayMonthDatePattern: String
    let smallAMPMTimePattern: String
    let shortMonthDatePattern: String
    let shortMonthDateTimePattern: String
    let shortDateSmallTimePattern: String
    let fullMonthPattern: String
    let shortMonthPattern: String
    let shortDayPattern: String
    let shortDayNamePattern: String
    let dashboardDatePattern: String
    let longDatePatternAbbr: String
}

// MARK: - SchoolContextDateTimeFormat
struct MySchoolAppSchoolContextDateTimeFormat: Codable {
    let amDesignator: String
    let calendar: MySchoolAppSchoolContextCalendar
    let dateSeparator: String
    let fullDateTimePattern: String
    let longDatePattern: String
    let longTimePattern: String
    let monthDayPattern: String
    let pmDesignator: String
    let rfc1123Pattern: String
    let shortDatePattern: String
    let shortTimePattern: String
    let sortableDateTimePattern: String
    let timeSeparator: String
    let universalSortableDateTimePattern: String
    let yearMonthPattern: String
    let abbreviatedDayNames: [String]
    let shortestDayNames: [String]
    let dayNames: [String]
    let abbreviatedMonthNames: [String]
    let monthNames: [String]
    let nativeCalendarName: String
    let abbreviatedMonthGenitiveNames: [String]
    let monthGenitiveNames: [String]
}

// MARK: - SchoolContextCalendar
struct MySchoolAppSchoolContextCalendar: Codable {
    let maxSupportedDateTime: String
    let algorithmType: Int
    let calendarType: Int
    let eras: [Int]
    let twoDigitYearMax: Int
}

// MARK: - SchoolContextNumberFormat
struct MySchoolAppSchoolContextNumberFormat: Codable {
    let currencyDecimalDigits: Int
    let currencyDecimalSeparator: String
    let currencyGroupSizes: [Int]
    let numberGroupSizes: [Int]
    let percentGroupSizes: [Int]
    let currencyGroupSeparator: String
    let currencySymbol: String
    let naNSymbol: String
    let numberNegativePattern: Int
    let percentPositivePattern: Int
    let percentNegativePattern: Int
    let negativeInfinitySymbol: String
    let negativeSign: String
    let numberDecimalDigits: Int
    let numberDecimalSeparator: String
    let numberGroupSeparator: String
    let positiveInfinitySymbol: String
    let positiveSign: String
    let percentDecimalDigits: Int
    let percentDecimalSeparator: String
    let percentGroupSeparator: String
    let percentSymbol: String
    let perMilleSymbol: String
    let nativeDigits: [String]
    let digitSubstitution: Int
}

// MARK: - SchoolContextCurrentSchoolYear
struct MySchoolAppSchoolContextCurrentSchoolYear: Codable {
    let schoolYearLabel: String
    let beginSchoolYear: String
    let endSchoolYear: String
    let current: Bool
    let published: Bool
    let schoolYearId: Int
}

// MARK: - SchoolContextEAP
struct MySchoolAppSchoolContextEAP: Codable {
    let id: Int?
    let appEAPID: Int
    let isEnabled: Bool
    let lastModifyDate: String?
    let lastModifyUserId: Int?
    let optInAllowed: Bool?
}

// MARK: - SchoolContextEngSysInfo
struct MySchoolAppSchoolContextEngSysInfo: Codable {
    let environmentId: String
    let legalEntityId: String
}

// MARK: - SchoolContextSchoolInfo
struct MySchoolAppSchoolContextSchoolInfo: Codable {
    let schoolID: Int
    let schoolName: String
    let appLocaleID: Int
    let localeID: Int
    let timezone: String
    let databaseTimezone: String
    let liveURL: String
    let username: String
    let portalDisplayLabel: String
    let mailboxName: String
    let helplinkText: String
    let signInOption: Int
    let localDateTime: String
    let serverDateTime: String
    let bulkEmailEnabled: Bool
    let podiumFrontendStatus: Int
    let nameFormat: String
    let showFeaturedContent: Int
    let showRecentActivity: Int
    let showArchivedContent: Int
    let appCultureName: String
    let cultureName: String
    let encCookieSiteURL: String
    let bbSiteID: String
    let allowRubricBankAdd: Bool
    let sslInd: Bool
    let loginRedirectInd: Bool
    let timeout: Int
    let loginNameLabel: String
    let dbNum: Int
}

// MARK: - SchoolContextSchoolURL
struct MySchoolAppSchoolContextSchoolURL: Codable {
    let schoolId: Int
    let liveURL: String
    let devURL: String
    let siteURL: String
    let podiumFrontendStatus: Int
    let stagingDomain: String
}

// MARK: - SchoolContextStyle
struct MySchoolAppSchoolContextStyle: Codable {
    let styleID: Int
    let options: [MySchoolAppSchoolContextOption]
    let logo: String
    let logoId: Int
    let logoFilename: String
    let logoNavURL: String
    let logoName: String
    let iosLogoId: Int
    let iosLogoShortName: String
    let iosLogoFilename: String
    let iosLogoName: String
    let faviconId: Int
    let faviconFilename: String
    let faviconName: String
    let lastModifyDate: String
    let lastModifyUserId: Int
}

// MARK: - SchoolContextOption
struct MySchoolAppSchoolContextOption: Codable {
    let key: String
    let label: String
    let value: String
}
