//
//  LunchPreviewView.swift
//  CA
//
//  Created by Jim Phieffer on 8/16/22.
//

import Foundation
import SwiftUI

struct LunchPreviewView: View {
    @Binding var menuItems: Result<SageDiningMenuItems, Error>?
    @Binding var selectedDate: Date
    @State var dropped = true
    @State var detailViewPresented = false
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                Text("Lunch")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { dropped.toggle() }) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(dropped ? 180 : 0))
                        .animation(.linear.speed(3), value: dropped)
                }
            }.padding(10)
            switch menuItems {
            case .success(let menuItems): if let entrees = menuItems["Entrées"], entrees.count > 0 {
                if dropped {
                    LazyVStack(alignment: .leading) {
                        ForEach(entrees.clamped(to: 3), id: \.id) { item in
                            Text("• \(item.name)")
                                .fontWeight(.semibold)
                                .padding(EdgeInsets(top: 1, leading: 10, bottom: 1, trailing: 10))
                        }
                    }
                    NavigationLink(destination: LunchDetailView(lunchDetailViewModel: LunchDetailViewModel(menuItems: self.menuItems, selectedDate: selectedDate))) {
                        HStack {
                            Text("Show Full Menu")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }.padding(10)
                    }.background(.quaternary)
                        .cornerRadius(10)
                        .foregroundColor(.primary)
                        .padding(10)
                }
            }
            case .failure(_): VStack {
                Text("Error. Pull down to retry.")
            }.padding(10)
            case nil: VStack {
                Text("Loading...")
                ProgressView()
            }.padding(10)
            }
        }
    }
}
