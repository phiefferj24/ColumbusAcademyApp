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
    
    @AppStorage("app.settings.autoLogin", store: UserDefaults(suiteName: "group.com.jimphieffer.CA")) var autoLogin: Bool = false
    
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
            }.toast(isPresenting: $loginViewModel.loginToastModel.shown, expiresAfter: 4.0) {
                loginViewModel.loginToastModel.toast
            }.onAppear {
                NotificationCenter.default.addObserver(forName: Notification.Name("api.myschoolapp.needsUserLogin"), object: nil, queue: OperationQueue.main) { _ in
                    if autoLogin {
                        loginViewModel.open()
                    }
                }
            }.task {
                for index in 0..<7 {
                    _ = try? await MySchoolAppAPI.shared.getSchedule(for: Date().start() + (Double(index) * 86400.0))
                }
            }
        }
    }
}
