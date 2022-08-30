//
//  LetterDayWidgetAccessoryRectangularView.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/25/22.
//

import SwiftUI

struct LetterDayWidgetAccessoryRectangularView: View {
    var entry: LetterDayWidgetEntry
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 10) {
            Text(entry.day?.split(separator: " ").first ?? "-")
                .font(.system(size: 60))
                .fontWeight(.heavy)
            Text("Day")
                .font(.system(size: 30))
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}
