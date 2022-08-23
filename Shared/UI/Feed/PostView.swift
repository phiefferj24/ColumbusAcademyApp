//
//  PostView.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/17/22.
//

import SwiftUI
import AVKit
import Introspect

struct PostView: View {
    let tweets: TwitterTweets
    let id: String
    
    @State var width = UIScreen.main.bounds.width

    var body: some View {
        VStack {
            if let tweet = tweets.data.first(where: { $0.id == id }) {
                VStack(alignment: .leading) {
                    if let user = tweets.includes?.users?.first(where: { $0.id == tweet.authorId }) {
                        Text(user.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    Text(tweet.createdAt.relativeString())
                        .foregroundColor(.secondary)
                    if let text = tweet.text {
                        Divider()
                        Text(text)
                    }
                }.padding(10)
                if let media = tweet.attachments?.mediaKeys.map({ mediaKey in
                    tweets.includes?.media?.first(where: { entry in
                        entry.mediaKey == mediaKey
                    })
                }).filter({ $0 != nil }) as? [TwitterTweetsMedia], media.count > 0 {
                    let minAspect: CGFloat = media.reduce(5.0) { $0 > CGFloat($1.width) / CGFloat($1.height) ? CGFloat($1.width) / CGFloat($1.height) : $0 }
                    ZStack(alignment: .topTrailing) {
                        if media.count == 1 {
                            let entry = media[0]
                            if entry.type == .photo || entry.type == .animatedGif, let url = entry.url, let url = URL(string: url) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                            } else if entry.type == .video, let variants = entry.variants, let url = variants.sorted(by: { $0.bitRate ?? 0 > $1.bitRate ?? 0 }).first?.url, let url = URL(string: url) {
                                VideoPlayer(player: AVPlayer(url: url))
                                    .scaledToFill()
                            }
                        } else {
                            TabView {
                                ForEach(media, id: \.mediaKey) { entry in
                                    if entry.type == .photo || entry.type == .animatedGif, let url = entry.url, let url = URL(string: url) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                .scaledToFit()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    } else if entry.type == .video, let variants = entry.variants, let url = variants.sorted(by: { $0.bitRate ?? 0 > $1.bitRate ?? 0 }).first?.url, let url = URL(string: url) {
                                        VideoPlayer(player: AVPlayer(url: url))
                                            .scaledToFill()
                                    }
                                }
                                if !media.contains(where: { $0.type == .photo || $0.type == .animatedGif }) {
                                    Spacer()
                                }
                            }.tabViewStyle(.page)
                                .frame(height: width / minAspect)
                        }
                    }.introspectViewController { viewController in
                        width = viewController.view.bounds.width
                    }
                }
            }
        }.background(.background)
            .cornerRadius(10)
    }
}
