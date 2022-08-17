//
//  SettingsView.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/10/22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    var quickpin = Binding(get: {
        UserDefaults.standard.string(forKey: "app.user.quickpin") ?? ""
    }, set: { newValue in
        UserDefaults.standard.set(newValue, forKey: "app.user.quickpin")
        NotificationCenter.default.post(name: Notification.Name("app.user.quickpin"), object: nil)
    })
    
    
    var body: some View {
        Form {
            Section("General") {
                Button(action: {
                    loginViewModel.shown.toggle()
                }) {
                    Text("Login")
                }.sheet(isPresented: $loginViewModel.shown) {
                    LoginView(loginViewModel: loginViewModel)
                }
            }
            Section(content: {
                TextField("Quickpin", text: quickpin)
            }, header: {
                Text("Quickpin")
            }, footer: {
                Text("Found on the top right of your SchoolPass ID. Entering your QuickPin here will display your QR code on the Today page.")
            })
        }.listStyle(.insetGrouped)
    }
}
