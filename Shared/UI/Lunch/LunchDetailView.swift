//
//  LunchDetailView.swift
//  CA
//
//  Created by Jim Phieffer on 8/11/22.
//

import SwiftUI

struct LunchDetailView: View {
    @Binding var selectedDate: Date
    
    @State var menuItems: Result<SageDiningMenuItems, Error>?
    
    let sectionPriority: [String] = ["Entrées", "Specials", "Sides and Vegetables", "Soups", "Salads", "Desserts", "Deli", "Daily"]
    
    var body: some View {
        NavigationView {
            switch menuItems {
            case .success(let menuItems):
                List {
                    ForEach(menuItems.keys.sorted(by: { sectionPriority.firstIndex(of: $0) ?? sectionPriority.count < sectionPriority.firstIndex(of: $1) ?? sectionPriority.count }), id: \.self) { key in
                        if let menuItem = menuItems[key], menuItem.count > 0 {
                            Section(key) {
                                ForEach(menuItem, id: \.id) { value in
                                    Text(value.name)
                                }
                            }
                        }
                    }
                }.refreshable {
                    await refreshMenuItems(on: selectedDate, refresh: true)
                }
            case .failure(_): RefreshableView {
                Text("Loading failed. Pull down to retry.")
            }.refreshable {
                await refreshMenuItems(on: selectedDate, refresh: true)
            }
            case nil: VStack {
                Text("Loading...")
                ProgressView()
            }
            }
        }.task {
            if menuItems == nil {
                await refreshMenuItems(on: selectedDate)
            }
        }
    }
    
    fileprivate func refreshMenuItems(for meal: String = "Lunch", on date: Date, menu: String? = nil, refresh: Bool = false) async {
        do {
            self.menuItems = .success(try await SageDiningAPI.shared.getMenuItems(for: meal, on: date, menu: menu, refresh: refresh))
        } catch {
            self.menuItems = .failure(error)
        }
    }
}
