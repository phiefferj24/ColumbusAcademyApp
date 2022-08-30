//
//  LetterDayWidgetAccessoryCircularView.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/25/22.
//

import SwiftUI

struct LetterDayWidgetAccessoryCircularView: View {
    var entry: LetterDayWidgetEntry
    
    var body: some View {
        Text(entry.day?.split(separator: " ").first ?? "-")
            .font(.system(size: 60))
            .fontWeight(.heavy)
    }
}
