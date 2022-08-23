//
//  TwitterTweets.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/17/22.
//

import Foundation

struct TwitterTweets: Codable {
    let data: [TwitterTweetData]
    let includes: TwitterTweetsIncludes?
    let meta: TwitterTweetsMeta
}

struct TwitterTweetData: Codable {
    let id: String
    let authorId: String?
    let createdAt: Date
    let attachments: TwitterTweetAttachments?
    let text: String?
}

struct TwitterTweetAttachments: Codable {
    let mediaKeys: [String]
}

struct TwitterTweetsIncludes: Codable {
    let media: [TwitterTweetsMedia]?
    let users: [TwitterTweetsUser]?
}

struct TwitterTweetsUser: Codable {
    let id: String
    let name: String
    let username: String
}

enum TwitterTweetsMediaType: String, Codable {
    case photo
    case video
    case animatedGif = "animated_gif"
}

struct TwitterTweetsMedia: Codable {
    let mediaKey: String
    let type: TwitterTweetsMediaType
    let url: String?
    let variants: [TwitterTweetsMediaVariant]?
    let width: Int
    let height: Int
}

struct TwitterTweetsMediaVariant: Codable {
    let bitRate: Int?
    let contentType: String
    let url: String
}

struct TwitterTweetsMeta: Codable {
    let resultCount: Int
    let nextToken: String?
    let previousToken: String?
}
