//
//  MySchoolAppAPI.swift
//  CA
//
//  Created by Jim Phieffer on 8/11/22.
//

import Foundation
import WebKit

class MySchoolAppAPIError: Error, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }
}

class MySchoolAppAPI {
    static let shared = MySchoolAppAPI()

    var observers: [NSObjectProtocol] = []

    var cookies: [HTTPCookie] = {
        if let data = UserDefaults(suiteName: "group.com.jimphieffer.CA")!.object(forKey: "api.myschoolapp.cookies") as? Data, let cookies = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [HTTPCookie] {
            return cookies
        } else {
            return []
        }
    }()

    var refreshTimer: Timer!
    
    let urlDateFormatter = DateFormatter()

    init() {
        urlDateFormatter.dateFormat = "M/d/YYYY"
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true) { [weak self] timer in
            Task { [weak self] in
                try? await self?.renewSession()
            }
        }
        observers.append(NotificationCenter.default.addObserver(forName: Notification.Name("api.myschoolapp.cookies"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            if let cookies = HTTPCookie.get("api.myschoolapp.cookies") {
                self?.cookies = cookies
            }
        })
    }
    
    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func renewSession() async throws {
        guard let url = URL(string: "https://sts-sso.myschoolapp.com/session/renew") else { throw MySchoolAppAPIError("URL creation failed.") }
        var request = URLRequest(url: url)
        for cookie in HTTPCookie.requestHeaderFields(with: cookies) {
            request.setValue(cookie.value, forHTTPHeaderField: cookie.key)
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw MySchoolAppAPIError("Could not parse response.") }
        if response.statusCode == 403 || response.statusCode == 401 {
            NotificationCenter.default.post(name: Notification.Name("api.myschoolapp.needsUserLogin"), object: nil)
            throw MySchoolAppAPIError("Unauthorized request.")
        }
        guard let headers = response.allHeaderFields as? [String : String] else { throw MySchoolAppAPIError("Could not get response cookies.") }
        let responseCookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
        responseCookies.store("api.myschoolapp.cookies")
    }
    
    @discardableResult func getCalendars(from start: Date, to end: Date, refresh: Bool = false, nocache: Bool = false) async throws -> MySchoolAppCalendarList {
        if !refresh, let calendarList = try? await MySchoolAppDataManager.shared.getCalendars(from: start, to: end) {
            return calendarList
        }
        guard let url = URL(string: "https://columbusacademy.myschoolapp.com/api/mycalendar/list?startDate=\(urlDateFormatter.string(from: start))&endDate=\(urlDateFormatter.string(from: end))&calendarSetId=1&settingsTypeId=1") else { throw MySchoolAppAPIError("URL creation failed.") }
        let request = URLRequest(url: url, cookies: cookies)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw MySchoolAppAPIError("Could not parse response.") }
        if response.statusCode == 403 || response.statusCode == 401 {
            NotificationCenter.default.post(name: Notification.Name("api.myschoolapp.needsUserLogin"), object: nil)
            if let calendarList = try? await MySchoolAppDataManager.shared.getCalendars(from: start, to: end) {
                return calendarList
            }
            throw MySchoolAppAPIError("Unauthorized request.")
        }
        let calendarList = try decoder.decode(MySchoolAppCalendarList.self, from: data)
        if !nocache {
            try? await MySchoolAppDataManager.shared.setCalendars(calendarList, from: start, to: end)
        }
        return calendarList
    }
    
    @discardableResult func getEvents(from start: Date, to end: Date, for calendars: [String], refresh: Bool = false, nocache: Bool = false) async throws -> MySchoolAppEventList {
        if !refresh, let eventList = try? await MySchoolAppDataManager.shared.getEvents(from: start, to: end) {
            return eventList
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        guard let url = URL(string: "https://columbusacademy.myschoolapp.com/api/mycalendar/events?startDate=\(urlDateFormatter.string(from: start))&endDate=\(urlDateFormatter.string(from: end))&filterString=\(calendars.joined(separator: ","))&showPractice=false&recentSave=false") else { throw MySchoolAppAPIError("URL creation failed.") }
        let request = URLRequest(url: url, cookies: cookies)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw MySchoolAppAPIError("Could not parse response.") }
        if response.statusCode == 403 || response.statusCode == 401 {
            NotificationCenter.default.post(name: Notification.Name("api.myschoolapp.needsUserLogin"), object: nil)
            if let eventList = try? await MySchoolAppDataManager.shared.getEvents(from: start, to: end) {
                return eventList
            }
            throw MySchoolAppAPIError("Unauthorized request.")
        }
        let eventList = try decoder.decode(MySchoolAppEventList.self, from: data)
        if !nocache {
            try? await MySchoolAppDataManager.shared.setEvents(eventList, from: start, to: end)
        }
        return eventList
    }
    
    @discardableResult func getSchedule(for date: Date, refresh: Bool = false, nocache: Bool = false) async throws -> MySchoolAppScheduleList {
        if !refresh, let scheduleList = try? await MySchoolAppDataManager.shared.getSchedule(for: date) {
            return scheduleList
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        guard let url = URL(string: "https://columbusacademy.myschoolapp.com/api/schedule/MyDayCalendarStudentList/?scheduleDate=\(urlDateFormatter.string(from: date))&personaId=2") else { throw MySchoolAppAPIError("URL creation failed.") }
        let request = URLRequest(url: url, cookies: cookies)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw MySchoolAppAPIError("Could not parse response.") }
        if response.statusCode == 403 || response.statusCode == 401 {
            NotificationCenter.default.post(name: Notification.Name("api.myschoolapp.needsUserLogin"), object: nil)
            if let scheduleList = try? await MySchoolAppDataManager.shared.getSchedule(for: date) {
                return scheduleList
            }
            throw MySchoolAppAPIError("Unauthorized request.")
        }
        let scheduleList = try decoder.decode(MySchoolAppScheduleList.self, from: data)
        if !nocache {
            try? await MySchoolAppDataManager.shared.setSchedule(scheduleList, for: date)
        }
        return scheduleList
    }
}
