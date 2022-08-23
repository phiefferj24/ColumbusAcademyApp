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

extension Array where Element == TwitterTweets {
    func joinedAndSorted() -> TwitterTweets {
        var data: [TwitterTweetData] = []
        var media: [TwitterTweetsMedia] = []
        var users: [TwitterTweetsUser] = []
        for element in self {
            data.append(contentsOf: element.data)
            if let includes = element.includes {
                if let mediaItems = includes.media {
                    media.append(contentsOf: mediaItems)
                }
                if let usersItems = includes.users {
                    users.append(contentsOf: usersItems)
                }
            }
        }
        return TwitterTweets(data: data.sorted(by: { $0.createdAt > $1.createdAt }), includes: TwitterTweetsIncludes(media: media, users: users), meta: TwitterTweetsMeta(resultCount: data.count, nextToken: nil, previousToken: nil))
    }
}
