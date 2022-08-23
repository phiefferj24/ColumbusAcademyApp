//
//  TwitterUser.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/17/22.
//

import Foundation

struct TwitterUser: Codable {
    let data: TwitterUserData
}

struct TwitterUserData: Codable {
    let id: String
    let name: String
    let username: String
}
