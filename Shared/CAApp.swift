//
//  CAApp.swift
//  Shared
//
//  Created by Jim Phieffer on 8/10/22.
//

import SwiftUI

@main
struct CAApp: App {
    @StateObject var loginViewModel = LoginViewModel()
    var autoLogin: Bool {
        UserDefaults.standard.bool(forKey: "app.settings.autoLogin")
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                TodayView().tabItem {
                    Label("Today", systemImage: "list.bullet.below.rectangle")
                }
                FeedView().tabItem {
                    Label("Feed", systemImage: "newspaper")
                }
                CalendarView().tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                SettingsView(loginViewModel: loginViewModel).tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }.sheet(isPresented: $loginViewModel.shown) {
                LoginView(loginViewModel: loginViewModel)
            }.onAppear {
                NotificationCenter.default.addObserver(forName: Notification.Name("api.myschoolapp.needsUserLogin"), object: nil, queue: OperationQueue.main) { _ in
                    if autoLogin {
                        loginViewModel.shown = true
                    }
                }
            }
        }
    }
}
