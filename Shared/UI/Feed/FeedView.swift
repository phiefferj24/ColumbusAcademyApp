//
//  FeedView.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/17/22.
//

import SwiftUI
import SwiftUIX
import Introspect

struct FeedView: View {
    @StateObject var feedViewModel = FeedViewModel()
    
    var body: some View {
        NavigationView {
            if let tweets = feedViewModel.tweets {
                ScrollView {
                    if tweets.data.count > 0 {
                        LazyVStack {
                            ForEach(tweets.data, id: \.id) { tweet in
                                PostView(tweets: tweets, id: tweet.id)
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                            }
                            Spacer().frame(height: 10)
                        }.background(.secondarySystemBackground)
                    } else {
                        Text("No tweets found. Try following some accounts.")
                    }
                }.introspectScrollView { scrollView in
                        scrollView.refreshControl = feedViewModel.refreshControl
                    }.toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: FeedSettingsView(feedViewModel: feedViewModel)) {
                                Image(systemName: "gear")
                            }
                        }
                    }
            } else {
                VStack {
                    Text("Loading...")
                    ProgressView()
                }.toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: FeedSettingsView(feedViewModel: feedViewModel)) {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
        }.task {
            try? await feedViewModel.refreshTweets()
        }
    }
}

@MainActor class FeedViewModel: ObservableObject {
    @AppStorage("app.feed.twitter.accounts", store: UserDefaults(suiteName: "group.com.jimphieffer.CA")) var accounts: Storable<[TwitterUser]> = Storable([TwitterUser]())
    @Published var tweets: TwitterTweets?
    @Published var refreshControl = UIRefreshControl()
    
    init() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        Task { [weak self] in
            if let self = self {
                try? await refreshTweets()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func refreshTweets(for user: TwitterUser? = nil) async throws {
        if let user = user {
            var newTweets = [try await TwitterAPI.shared.getTweets(for: user.data.id)]
            if let tweets = tweets {
                let newData = tweets.data.filter({ $0.authorId != user.data.id })
                newTweets.append(TwitterTweets(
                    data: newData,
                    includes: TwitterTweetsIncludes(media: tweets.includes?.media?.filter({ mediaItem in
                        newData.contains(where: { $0.attachments?.mediaKeys.contains(mediaItem.mediaKey) ?? false })
                    }),
                    users: tweets.includes?.users?.filter({ $0.id != user.data.id })),
                    meta: TwitterTweetsMeta(resultCount: newData.count + newTweets[0].data.count, nextToken: nil, previousToken: nil))
                )
            }
            tweets = newTweets.joinedAndSorted()
        } else {
            var newTweets = [TwitterTweets]()
            for account in accounts.value {
                if let tweetGroup = try? await TwitterAPI.shared.getTweets(for: account.data.id) {
                    newTweets.append(tweetGroup)
                }
            }
            tweets = newTweets.joinedAndSorted()
        }
    }
    
    @Published var error = false
    @Published var updating = false
    @Published var text = ""
    
    func addUser() async {
        updating = true
        if let account = try? await TwitterAPI.shared.searchUser(text), !accounts.value.contains(where: { $0.data.id == account.data.id }) {
            accounts.value.append(account)
            accounts = Storable(accounts.value)
            try? await refreshTweets(for: account)
        } else {
            error = true
        }
        updating = false
        text = ""
    }
}
