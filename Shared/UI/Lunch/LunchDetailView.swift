//
//  LunchDetailView.swift
//  CA
//
//  Created by Jim Phieffer on 8/11/22.
//

import SwiftUI
import Introspect

struct LunchDetailView: View {
    @ObservedObject var lunchDetailViewModel: LunchDetailViewModel
    
    let sectionPriority: [String] = ["Entrées", "Specials", "Sides and Vegetables", "Soups", "Salads", "Desserts", "Deli", "Daily"]
    
    var body: some View {
        NavigationView {
            switch lunchDetailViewModel.menuItems {
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
                    await lunchDetailViewModel.refreshMenuItems(on: lunchDetailViewModel.selectedDate, refresh: true)
                }
            case .failure(_): ScrollView {
                Text("Loading failed. Pull down to retry.")
            }.introspectScrollView { scrollView in
                scrollView.refreshControl = lunchDetailViewModel.refreshControl
            }
            case nil: VStack {
                Text("Loading...")
                ProgressView()
            }
            }
        }.task {
            if lunchDetailViewModel.menuItems == nil {
                await lunchDetailViewModel.refreshMenuItems(on: lunchDetailViewModel.selectedDate)
            }
        }
    }
}

@MainActor class LunchDetailViewModel: ObservableObject {
    @Published var refreshControl = UIRefreshControl()
    
    @Published var menuItems: Result<SageDiningMenuItems, Error>?
    @Published var selectedDate: Date
    
    init(menuItems: Result<SageDiningMenuItems, Error>?, selectedDate: Date) {
        self.menuItems = menuItems
        self.selectedDate = selectedDate
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        Task { [weak self] in
            if let self = self {
                await self.refreshMenuItems(on: selectedDate, refresh: true)
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func refreshMenuItems(for meal: String = "Lunch", on date: Date, menu: String? = nil, refresh: Bool = false) async {
        do {
            self.menuItems = .success(try await SageDiningAPI.shared.getMenuItems(for: meal, on: date, menu: menu, refresh: refresh))
        } catch {
            self.menuItems = .failure(error)
        }
    }
}
