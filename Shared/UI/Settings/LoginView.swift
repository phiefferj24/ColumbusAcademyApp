//
//  LoginView.swift
//  CA
//
//  Created by Jim Phieffer on 8/10/22.
//

import SwiftUI
import WebKit

class LoginToastModel: NSObject, ObservableObject {
    @Published var shown = false
    @Published var toast: DropdownToast = inProgress
    
    static let inProgress = DropdownToast(title: "Logging in...", subtitle: "Displaying cached data.", accessoryView: .progress)
    static let success = DropdownToast(title: "Logged in!", subtitle: "Displaying updated data.", accessoryView: .systemImage(name: "checkmark", color: .green))
    static let failed = DropdownToast(title: "Login failed.", subtitle: "Try again in settings.", accessoryView: .systemImage(name: "exclamationmark.triangle", color: .yellow))
}

class LoginViewModel: NSObject, ObservableObject {
    let webView = WKWebView()
    @Published var needsUserInput = false
    @Published var loggingIn = false
    @Published var shown = false
    @Published var cancellationTask: Task<Void, Never>? = nil
    @Published var loginToastModel = LoginToastModel()

    override init() {
        super.init()
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 Safari/604.1"
    }
    
    func open() {
        let request = URLRequest(url: URL(string: "https://columbusacademy.myschoolapp.com/app#login")!)
        _ = webView.load(request)
        Task { @MainActor in
            loggingIn = true
            loginToastModel.toast = LoginToastModel.inProgress
            loginToastModel.shown = true
        }
        cancellationTask?.cancel()
        cancellationTask = Task { [weak self] in
            do {
                try await Task.sleep(seconds: 60.0)
            } catch {
                return
            }
            Task { @MainActor [weak self] in
                self?.loginToastModel.toast = LoginToastModel.failed
                self?.loginToastModel.shown = true
                self?.loggingIn = false
            }
        }
        guard let data = UserDefaults(suiteName: "group.com.jimphieffer.CA")!.object(forKey: "api.myschoolapp.cookies") as? Data,
           let cookies = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)) as? [HTTPCookie],
           let _ = cookies.first(where: { $0.name == "s" }) else {
            Task { @MainActor in
                shown = true
                needsUserInput = true
                cancellationTask?.cancel()
            }
            return
        }
    }
    
    func updateCookies() {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false) {
                UserDefaults(suiteName: "group.com.jimphieffer.CA")!.set(data, forKey: "api.myschoolapp.cookies")
                NotificationCenter.default.post(name: Notification.Name("api.myschoolapp.cookies"), object: nil)
            }
        }
    }
}

extension LoginViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        guard let url = webView.url?.absoluteString else { return }
        if url.hasPrefix("https://app.blackbaud.com/signin") {
            if !needsUserInput {
                webView.evaluateJavaScript("let n = setInterval(() => document.querySelector(`button.spa-auth-googlesignin-primary-button`).click(), 500)")
            }
        } else if url.hasPrefix("https://columbusacademy.myschoolapp.com/app") {
            if url.contains("login") {
                if !needsUserInput {
                    webView.evaluateJavaScript("setInterval(() => document.querySelector(`input#nextBtn`).click(), 500)")
                }
            } else {
                updateCookies()
                Task { @MainActor in
                    shown = false
                    needsUserInput = false
                    loggingIn = false
                    loginToastModel.toast = LoginToastModel.success
                    loginToastModel.shown = true
                    cancellationTask?.cancel()
                    NotificationCenter.default.post(name: Notification.Name("api.myschoolapp.loginComplete"), object: nil)
                }
            }
        } else if url.hasPrefix("https://accounts.google.com/o/oauth2/auth") {
            Task { @MainActor in
                shown = true
                needsUserInput = true
                cancellationTask?.cancel()
            }
        }
    }
}

struct LoginView: View {
    @ObservedObject var loginViewModel: LoginViewModel

    var body: some View {
        NavigationView {
            if loginViewModel.needsUserInput {
                WebView(webView: loginViewModel.webView).toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            Task { @MainActor in
                                loginViewModel.shown = false
                                loginViewModel.needsUserInput = false
                                loginViewModel.loggingIn = false
                                loginViewModel.cancellationTask?.cancel()
                                loginViewModel.loginToastModel.toast = LoginToastModel.failed
                                loginViewModel.loginToastModel.shown = true
                            }
                        }) {
                            Text("Cancel")
                        }
                    }
                }
            } else {
                VStack {
                    Text("Logging in...")
                    ProgressView()
                }
            }
        }
    }
}
