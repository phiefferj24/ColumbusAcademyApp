//
//  LetterDayWidgetSmallView.swift
//  CAWidgetsExtension
//
//  Created by Jim Phieffer on 8/25/22.
//

import SwiftUI

struct LetterDayWidgetSmallView: View {
    var entry: LetterDayWidgetEntry
    
    let formatter = DateFormatter("EEEE")
    
    var body: some View {
        VStack {
            Text(formatter.string(from: Date()))
                .font(.title2)
                .fontWeight(.semibold)
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text(entry.day?.split(separator: " ").first ?? "-")
                    .font(.system(size: 80))
                    .fontWeight(.bold)
                    .foregroundColor(Color("AccentColor"))
                Text("Day")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }.padding()
    }
}
