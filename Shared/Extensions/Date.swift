//
//  Date.swift
//  CA
//
//  Created by Jim Phieffer on 8/15/22.
//

import Foundation

extension Date {
    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.month, .year], from: self)) ?? self
    }
    
    func startOfNextMonth() -> Date {
        Calendar.current.date(byAdding: .month, value: 1, to: Calendar.current.date(from: Calendar.current.dateComponents([.month, .year], from: self)) ?? self) ?? self
    }
    func relativeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    func start() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}
