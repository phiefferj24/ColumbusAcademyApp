//
//  Cache.swift
//  CA
//
//  Created by Jim Phieffer on 8/14/22.
//

import Foundation

class Cache<T> {
    init(_ value: T, validFor: Double = 300) {
        self._value = value
        self.validFor = validFor
    }

    var time = Date()
    var validFor: Double
    private var _value: T?
    var value: T? {
        get {
            return Date().timeIntervalSince(time) < validFor ? _value : nil
        }
        set {
            _value = newValue
        }
    }
}
