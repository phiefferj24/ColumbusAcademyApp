//
//  Array.swift
//  CA
//
//  Created by Jim Phieffer on 8/16/22.
//

import Foundation

extension Array {
    func clamped(to length: Int) -> Array {
        return self.count <= length ? self : self.dropLast(self.count - length)
    }
}
