//
//  LoginView.swift
//  CA
//
//  Created by Jim Phieffer on 8/10/22.
//

import SwiftUI
import WebKit

class LoginViewModel: NSObject, ObservableObject {
    let webView = WKWebView()
    @Published var needsUserInput = false
    @Published var shown: Bool = false

    override init() {
        super.init()
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 Safari/604.1"
    }
    
    func open() {
        let request = URLRequest(url: URL(string: "https://columbusacademy.myschoolapp.com/app#login")!)
        webView.load(request)
        guard let data = UserDefaults.standard.object(forKey: "api.myschoolapp.cookies") as? Data,
           let cookies = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)) as? [HTTPCookie],
           let _ = cookies.first(where: { $0.name == "s" }) else {
            needsUserInput = true
            return
        }
    }
    
    func updateCookies() {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false) {
                UserDefaults.standard.set(data, forKey: "api.myschoolapp.cookies")
                NotificationCenter.default.post(name: Notification.Name("api.myschoolapp.cookies"), object: nil)
            }
        }
    }
}

extension LoginViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        guard let url = webView.url?.absoluteString else { return }
        if url.hasPrefix("https://app.blackbaud.com/signin") {
            webView.evaluateJavaScript("let n = setInterval(() => document.querySelector(`button.spa-auth-googlesignin-primary-button`).click(), 500)")
        } else if url.hasPrefix("https://columbusacademy.myschoolapp.com/app") {
            if url.contains("login") {
                if !needsUserInput {
                    webView.evaluateJavaScript("setInterval(() => document.querySelector(`input#nextBtn`).click(), 500)")
                }
            } else {
                updateCookies()
                shown = false
            }
        } else if url.hasPrefix("https://accounts.google.com/o/oauth2/auth") {
            self.needsUserInput = true
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
                            loginViewModel.shown = false
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
        }.onAppear {
            loginViewModel.open()
        }
    }
}
