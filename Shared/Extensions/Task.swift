//
//  Task.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 9/11/22.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1000000000)
        try await Task.sleep(nanoseconds: duration)
    }
}
