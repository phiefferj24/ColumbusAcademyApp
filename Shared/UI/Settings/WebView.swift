//
//  WebView.swift
//  CA
//
//  Created by Jim Phieffer on 8/10/22.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) { }
}
