//
//  DateFormatter.swift
//  CA
//
//  Created by Jim Phieffer on 8/15/22.
//

import Foundation

extension DateFormatter {
    convenience init(_ format: String, timeZone: TimeZone? = nil) {
        self.init()
        self.dateFormat = format
        if let timeZone = timeZone {
            self.timeZone = timeZone
        }
    }
}
