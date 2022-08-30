//
//  LetterDayWidgetAccessoryRectangularView.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/25/22.
//

import SwiftUI

struct LetterDayWidgetAccessoryInlineView: View {
    var entry: LetterDayWidgetEntry
    
    var body: some View {
        Text(entry.day ?? "-")
    }
}
