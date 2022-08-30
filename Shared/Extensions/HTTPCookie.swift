//
//  HTTPCookie.swift
//  CA
//
//  Created by Jim Phieffer on 8/14/22.
//

import Foundation

extension HTTPCookie {
    func store(_ key: String) {
        guard let storedData = UserDefaults(suiteName: "group.com.jimphieffer.CA")!.object(forKey: key) as? Data else { return }
        guard var cookies = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(storedData) as? [HTTPCookie] else { return }
        if let index = cookies.firstIndex(where: { $0.name == self.name }) {
            cookies[index] = self
        } else {
            cookies.append(self)
        }
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false) else { return }
        UserDefaults(suiteName: "group.com.jimphieffer.CA")!.set(data, forKey: key)
        NotificationCenter.default.post(name: Notification.Name(key), object: nil)
    }
    
    static func get(_ key: String) -> [HTTPCookie]? {
        guard let storedData = UserDefaults(suiteName: "group.com.jimphieffer.CA")!.object(forKey: key) as? Data else { return nil }
        guard let cookies = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(storedData) as? [HTTPCookie] else { return nil }
        return cookies
    }
}

extension Array where Element == HTTPCookie {
    func store(_ key: String) {
        guard let storedData = UserDefaults(suiteName: "group.com.jimphieffer.CA")!.object(forKey: key) as? Data else { return }
        guard var cookies = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(storedData) as? [HTTPCookie] else { return }
        for cookie in self {
            if let index = cookies.firstIndex(where: { $0.name == cookie.name }) {
                cookies[index] = cookie
            } else {
                cookies.append(cookie)
            }
        }
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false) else { return }
        UserDefaults(suiteName: "group.com.jimphieffer.CA")!.set(data, forKey: key)
        NotificationCenter.default.post(name: Notification.Name(key), object: nil)
    }
}
