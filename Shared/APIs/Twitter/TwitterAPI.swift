//
//  TwitterAPI.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/17/22.
//

import Foundation

class TwitterAPIError: Error, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }
}

class TwitterAPI {
    static let shared = TwitterAPI()
    
    let accessToken = "AAAAAAAAAAAAAAAAAAAAAF84gAEAAAAAxOw%2B3zx3fKJYeNiJYbazHLW%2BCnM%3DOVCja0D6ktiNDHgC1xxf41TQOVFgkQW3RVjZalroROgjGXXHUD"
    
    let decoder = JSONDecoder()
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(DateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timeZone: TimeZone(secondsFromGMT: 0)))
    }
    
    func getTweets(_ amount: Int = 25, for id: String, pagination: String? = nil) async throws -> TwitterTweets {
        guard let url = URL(string: "https://api.twitter.com/2/users/\(id)/tweets?media.fields=type,url,variants,width,height&expansions=attachments.media_keys,author_id&tweet.fields=created_at&max_results=\(String(amount))\(pagination == nil ? "" : "&pagination_token=\(pagination!)")") else { throw TwitterAPIError("URL creation failed.") }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        let tweets = try decoder.decode(TwitterTweets.self, from: data)
        return tweets
    }
    
    func searchUser(_ username: String) async throws -> TwitterUser {
        guard let url = URL(string: "https://api.twitter.com/2/users/by/username/\(username)") else { throw TwitterAPIError("URL creation failed.") }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        let user = try decoder.decode(TwitterUser.self, from: data)
        return user
    }
}
