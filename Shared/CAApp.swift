//
//  CAApp.swift
//  Shared
//
//  Created by Jim Phieffer on 8/10/22.
//

import SwiftUI

@main
struct CAApp: App {
    @StateObject var mySchoolApp = MySchoolAppAPI.shared
    @StateObject var loginViewModel = LoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                TodayView().tabItem {
                    Label("Today", systemImage: "newspaper")
                }
                CalendarView().tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                SettingsView(loginViewModel: loginViewModel).tabItem {
                    Label(title: {
                        Text("Settings")
                    }, icon: {
                        Image(systemName: "gear")
                    })
                }
            }.sheet(isPresented: $loginViewModel.shown) {
                LoginView(loginViewModel: loginViewModel)
            }.onChange(of: mySchoolApp.needsUserLogin) { newValue in
                loginViewModel.shown = true
            }
        }
    }
}
