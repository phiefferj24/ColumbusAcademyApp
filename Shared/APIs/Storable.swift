//
//  Storable.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/18/22.
//

import Foundation

class Storable<T>: RawRepresentable where T: Codable {
    var value: T
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self.value),
            let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    required public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(T.self, from: data)
        else {
            return nil
        }
        self.value = result
    }
}
