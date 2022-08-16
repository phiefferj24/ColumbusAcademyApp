//
//  SageDiningAPI.swift
//  CA
//
//  Created by Jim Phieffer on 8/11/22.
//

import Foundation

class SageDiningAPIError: Error, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }
}

class SageDiningAPI {
    static let shared = SageDiningAPI()

    fileprivate var _venueInformation: Cache<SageDiningVenueInformation>?
    fileprivate var _menuItems: [Date: Cache<SageDiningMenuItems>?] = [:]
    fileprivate var _weeklyMenuItems: [Date: Cache<SageDiningWeeklyMenuItems>?] = [:]
    
    fileprivate var dateFormatter = ISO8601DateFormatter()
    
    init() {
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
    }
    
    func getVenueInformation(refresh: Bool = false, nocache: Bool = false) async throws -> SageDiningVenueInformation {
        if !refresh, let _venueInformation = _venueInformation, let value = _venueInformation.value {
            return value
        }
        guard let url = URL(string: "https://www.sagedining.com/microsites/getVenueInformation?name=columbusacademy") else { throw SageDiningAPIError("URL creation failed.") }
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        let venueInformation = try JSONDecoder().decode(SageDiningVenueInformation.self, from: data)
        if !nocache {
            _venueInformation = Cache(venueInformation)
        }
        return venueInformation
    }
    
    func getMenuItems(for meal: String = "Lunch", on date: Date, menu: String? = nil, refresh: Bool = false, nocache: Bool = false) async throws -> SageDiningMenuItems {
        if !refresh, let menuItems = _menuItems[date], let value = menuItems?.value {
            return value
        }
        let venueInformation = try await getVenueInformation()
        var menu = menu
        if menu == nil {
            menu = venueInformation.menus.first { $0.meals.contains { $0 == meal } }?.name
        }
        guard let menu = menu, let menuId = venueInformation.menus.first(where: { $0.name == menu })?.id else { throw SageDiningAPIError("Could not find menu.") }
        guard let url = URL(string: "https://www.sagedining.com/microsites/getMenuItems?menuId=\(menuId)&date=\(dateFormatter.string(from: date))&meal=\(meal)") else { throw SageDiningAPIError("URL creation failed.") }
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        let menuItems = try JSONDecoder().decode(SageDiningMenuItems.self, from: data)
        if !nocache {
            _menuItems[date] = Cache(menuItems)
        }
        return menuItems
    }
    
    func getWeeklyMenuItems(for meal: String = "Lunch", on date: Date, menu: String? = nil, refresh: Bool = false, nocache: Bool = false) async throws -> SageDiningWeeklyMenuItems {
        if !refresh, let weeklyMenuItems = _weeklyMenuItems[date], let value = weeklyMenuItems?.value {
            return value
        }
        let venueInformation = try await getVenueInformation()
        var menu = menu
        if menu == nil {
            menu = venueInformation.menus.first { $0.meals.contains { $0 == meal } }?.name
        }
        guard let menu = menu, let menuId = venueInformation.menus.first(where: { $0.name == menu })?.id else { throw SageDiningAPIError("Could not find menu.") }
        guard let url = URL(string: "https://www.sagedining.com/microsites/getWeeklyMenuItems?menuId=\(menuId)&date=\(dateFormatter.string(from: date))") else { throw SageDiningAPIError("URL creation failed.") }
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        let weeklyMenuItems = try JSONDecoder().decode(SageDiningWeeklyMenuItems.self, from: data)
        if !nocache {
            _weeklyMenuItems[date] = Cache(weeklyMenuItems)
        }
        return weeklyMenuItems
    }
}
