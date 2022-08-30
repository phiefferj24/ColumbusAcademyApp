//
//  LunchWidgetLargeView.swift
//  CAWidgetsExtension
//
//  Created by Jim Phieffer on 8/25/22.
//

import Foundation
import SwiftUI

struct LunchWidgetLargeView: View {
    var entry: LunchWidgetEntry
    let formatter = DateFormatter("EEEE, MMMM d, YYYY")
    
    let sectionPriority: [String] = ["Entrées", "Specials", "Sides and Vegetables", "Desserts"]

    var body: some View {
        switch entry.menu {
        case .success(let menu): HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(formatter.string(from: entry.date))
                    .fontWeight(.bold)
                    .font(.title2)
                Spacer()
                ForEach(menu.keys.sorted(by: { sectionPriority.firstIndex(of: $0) ?? sectionPriority.count < sectionPriority.firstIndex(of: $1) ?? sectionPriority.count }).clamped(to: 4), id: \.self) { key in
                    VStack(alignment: .leading) {
                        Text(key)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                        ForEach(menu[key]!.clamped(to: 3), id: \.id) { item in
                            Text(" • \(item.name)")
                                .lineLimit(1)
                        }
                    }
                }
            }
            Spacer()
        }.padding(10)
        case .failure(_): Text("Error")
        case nil: ProgressView()
        }
    }
}
