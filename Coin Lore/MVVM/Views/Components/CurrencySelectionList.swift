//
//  CurrencySelectionList.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 22/02/2025.
//

import SwiftUI

struct CurrencySelectionList: View {
    @ObservedObject var viewModel: StatisticsViewModel // ViewModel now manages data
    var onDone: () -> Void // Callback for when the user finishes selection

    @State private var sortOrder: Bool = true // true for A-Z, false for Z-A
    @State private var selectedFilter: FilterOption = .all // Default: show all
    @State private var searchText: String = "" // Stores search input

    enum FilterOption: String, CaseIterable {
        case all = "All"
        case selected = "Selected"
        case unselected = "Unselected"

        var next: FilterOption {
            switch self {
            case .all: return .selected
            case .selected: return .unselected
            case .unselected: return .all
            }
        }

        var icon: String {
            switch self {
            case .all: return "line.3.horizontal.circle"
            case .selected: return "checkmark.circle.fill"
            case .unselected: return "circle"
            }
        }
    }

    var filteredCurrencies: [String] {
        let sortedList = sortOrder ? viewModel.filteredAvailableCurrencies.sorted() : viewModel.filteredAvailableCurrencies.sorted(by: >)

        let filteredList: [String]
        switch selectedFilter {
        case .all:
            filteredList = sortedList
        case .selected:
            filteredList = sortedList.filter { viewModel.selectedCurrencies.contains($0) }
        case .unselected:
            filteredList = sortedList.filter { !viewModel.selectedCurrencies.contains($0) }
        }

        return filteredList.filter { searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchText: $searchText) // 🔍 Integrated Search Bar

                if filteredCurrencies.isEmpty {
                    VStack {
                        Spacer()
                        Text("No currencies available")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    List(filteredCurrencies, id: \.self) { currency in
                        HStack {
                            Text(currency)
                                .font(.body)

                            Spacer()

                            if viewModel.selectedCurrencies.contains(currency) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle()) // Makes the whole row tappable
                        .onTapGesture {
                            toggleSelection(currency)
                        }
                    }
                }
            }
            .navigationTitle("Select Currencies")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    HStack {
                        Button(action: selectAllCurrencies) {
                            Image(systemName: "checkmark.circle")
                        }
                        .help("Select All")

                        Button(action: clearAllCurrencies) {
                            Image(systemName: "xmark.circle")
                        }
                        .help("Clear All")

                        Button(action: {
                            sortOrder.toggle() // Toggle sorting order
                        }) {
                            Image(systemName: sortOrder ? "arrow.up" : "arrow.down")
                        }

                        Button(action: {
                            selectedFilter = selectedFilter.next // Cycle through filter options
                        }) {
                            Image(systemName: selectedFilter.icon)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDone() // Call the completion handler
                    }
                }
            }
            .onAppear {
                viewModel.fetchStatistics() // Ensure available currencies are loaded
            }
        }
    }

    private func toggleSelection(_ currency: String) {
        var updatedSelection = viewModel.selectedCurrencies // Create a local copy

        if updatedSelection.contains(currency) {
            updatedSelection.remove(currency) // Deselect if already selected
        } else {
            updatedSelection.insert(currency) // Select if not selected
        }

        viewModel.updateSelectedCurrencies(updatedSelection) // Save updated selection
    }

    private func selectAllCurrencies() {
        viewModel.updateSelectedCurrencies(Set(viewModel.filteredAvailableCurrencies)) // Select all available
    }

    private func clearAllCurrencies() {
        viewModel.updateSelectedCurrencies([]) // Clear all selections
    }
}


