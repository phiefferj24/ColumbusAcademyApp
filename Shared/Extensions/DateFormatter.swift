//
//  DateFormatter.swift
//  CA
//
//  Created by Jim Phieffer on 8/15/22.
//

import Foundation

extension DateFormatter {
    convenience init(_ format: String) {
        self.init()
        self.dateFormat = format
    }
}
