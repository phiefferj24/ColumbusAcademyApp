//
//  SettingsView.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/10/22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        List {
            Section("General") {
                Button(action: {
                    loginViewModel.shown.toggle()
                }) {
                    Text("Login")
                }.sheet(isPresented: $loginViewModel.shown) {
                    LoginView(loginViewModel: loginViewModel)
                }
            }
        }.listStyle(.insetGrouped)
    }
}
