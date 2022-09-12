//
//  SettingsView.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/10/22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    @AppStorage("app.user.quickpin", store: UserDefaults(suiteName: "group.com.jimphieffer.CA")) var quickpin = ""
    @AppStorage("app.settings.autoLogin", store: UserDefaults(suiteName: "group.com.jimphieffer.CA")) var autoLogin = true
    
    @State var logoutToastPresented = false

    var body: some View {
        Form {
            Section {
                Button(action: {
                    Task { @MainActor in
                        loginViewModel.open()
                    }
                }) {
                    Text("Login")
                }
                Button(action: {
                    if let data = UserDefaults(suiteName: "group.com.jimphieffer.CA")!.object(forKey: "api.myschoolapp.cookies") as? Data, let cookies = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [HTTPCookie] {
                        for cookie in cookies {
                            loginViewModel.webView.configuration.websiteDataStore.httpCookieStore.delete(cookie)
                        }
                    }
                    UserDefaults(suiteName: "group.com.jimphieffer.CA")!.removeObject(forKey: "api.myschoolapp.cookies")
                    NotificationCenter.default.post(name: Notification.Name("api.myschoolapp.cookies"), object: nil)
                    Task { @MainActor in
                        logoutToastPresented = true
                    }
                }) {
                    Text("Logout")
                }
                Toggle(isOn: $autoLogin) {
                    Text("Auto Login")
                }
            } header: {
                Text("MySchoolApp")
            } footer: {
                Text("Enabling auto-login will automatically bring up the login screen when necessary.")
            }
            Section {
                TextField("Quickpin", text: $quickpin)
            } header: {
                Text("Quickpin")
            } footer: {
                Text("Found on the top right of your SchoolPass ID. Entering your QuickPin here will display your QR code on the Today page.")
            }
        }.listStyle(.insetGrouped)
            .toast(isPresenting: $logoutToastPresented, expiresAfter: 4.0) {
                DropdownToast(title: "Logged out.", accessoryView: .systemImage(name: "xmark", color: .red))
            }
    }
}
