//
//  URLRequest.swift
//  CA
//
//  Created by Jim Phieffer on 8/15/22.
//

import Foundation

extension URLRequest {
    init(url: URL, cookies: [HTTPCookie]) {
        self.init(url: url)
        for cookie in HTTPCookie.requestHeaderFields(with: cookies) {
            self.setValue(cookie.value, forHTTPHeaderField: cookie.key)
        }
    }
}
