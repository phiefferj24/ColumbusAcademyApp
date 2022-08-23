//
//  FeedSettingsView.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/17/22.
//

import SwiftUI

struct FeedSettingsView: View {
    @ObservedObject var feedViewModel: FeedViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(feedViewModel.accounts.value, id: \.data.id) { account in
                        VStack(alignment: .leading) {
                            Text(account.data.name)
                                .fontWeight(.semibold)
                            Text("@\(account.data.username)")
                                .foregroundColor(.secondary)
                        }
                    }.onDelete { indexSet in
                        feedViewModel.accounts.value.remove(atOffsets: indexSet)
                        feedViewModel.accounts = Storable(feedViewModel.accounts.value)
                    }
                }
                Section {
                    TextField("Account Username", text: $feedViewModel.text)
                        .disabled(feedViewModel.updating)
                    Button(action: {
                        Task {
                            await feedViewModel.addUser()
                        }
                    }) {
                        Text("Follow User")
                    }.alert("No account found.", isPresented: $feedViewModel.error) {
                        Button(role: .cancel) {
                            feedViewModel.error = false
                        } label: {
                            Text("Ok")
                        }
                    }
                }
            }.listStyle(.insetGrouped)
                .navigationTitle("Followed Accounts")
        }
    }
}
