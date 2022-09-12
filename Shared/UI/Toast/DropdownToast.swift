//
//  DropdownToast.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 9/7/22.
//

import Foundation
import SwiftUI

struct DropdownToast: Toast {
    let type: ToastDisplayType = .dropdown

    let accessoryView: ToastAccessoryViewType?
    let title: String?
    let subtitle: String?
    
    init(title: String? = nil, subtitle: String? = nil, accessoryView: ToastAccessoryViewType? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.accessoryView = accessoryView
    }
    
    var body: some View {
        Group {
            VStack {
                HStack(spacing: 16) {
                    switch accessoryView {
                    case .none:
                        EmptyView()
                    case .systemImage(let name, let color):
                        Image(systemName: name)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 20, maxHeight: 20, alignment: .center)
                            .foregroundColor(color ?? .primary)
                    case .progress:
                        ProgressView()
                    }
                    VStack(alignment: (accessoryView == nil) ? .center : .leading) {
                        if let title {
                            Text(title)
                                .fontWeight(.bold)
                        }
                        if let subtitle {
                            Text(subtitle)
                        }
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .frame(minHeight: 50)
                .background(.secondarySystemBackground)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 6)
                .compositingGroup()

                Spacer()
            }
        }.padding(.top)
    }
}
