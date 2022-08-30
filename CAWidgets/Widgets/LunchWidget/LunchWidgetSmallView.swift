//
//  LunchWidgetSmallView.swift
//  CAWidgetsExtension
//
//  Created by Jim Phieffer on 8/25/22.
//

import SwiftUI

struct LunchWidgetSmallView: View {
    var entry: LunchWidgetEntry
    let weekdayFormatter = DateFormatter("EEEE")
    let dayFormatter = DateFormatter("d")

    var body: some View {
        switch entry.menu {
        case .success(let menu): HStack {
            VStack(alignment: .leading) {
                Text(weekdayFormatter.string(from: entry.date))
                    .fontWeight(.semibold)
                    .font(.caption)
                Text(dayFormatter.string(from: entry.date))
                    .foregroundColor(Color("AccentColor"))
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                if let entrees = menu["Entrées"] {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(entrees.clamped(to: 2), id: \.id) { item in
                            Text(item.name)
                                .lineLimit(2)
                                .font(.system(size: 16))
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
