//
//  CurrencySelectionList.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 22/02/2025.
//

import SwiftUI

struct CurrencySelectionList: View {
    @Binding var selectedCurrencies: Set<String> // Stores selected cryptocurrencies
    let availableCurrencies: [String] // List of all possible currencies
    var onDone: () -> Void // Callback for when the user finishes selection
    
    @State private var sortOrder: Bool = true // true for A-Z, false for Z-A
    @State private var selectedFilter: FilterOption = .all // Default: show all

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
        let sortedList = sortOrder ? availableCurrencies.sorted() : availableCurrencies.sorted(by: >)
        
        switch selectedFilter {
        case .all:
            return sortedList
        case .selected:
            return sortedList.filter { selectedCurrencies.contains($0) }
        case .unselected:
            return sortedList.filter { !selectedCurrencies.contains($0) }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredCurrencies, id: \.self) { currency in
                HStack {
                    Text(currency)
                        .font(.body)
                    
                    Spacer()
                    
                    if selectedCurrencies.contains(currency) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle()) // Makes the whole row tappable
                .onTapGesture {
                    toggleSelection(currency)
                }
            }
            .navigationTitle("Select Currencies")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
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
        }
    }
    
    private func toggleSelection(_ currency: String) {
        if selectedCurrencies.contains(currency) {
            selectedCurrencies.remove(currency) // Deselect if already selected
        } else {
            selectedCurrencies.insert(currency) // Select if not selected
        }
    }
}

// Preview
struct CurrencySelectionList_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySelectionList(
            selectedCurrencies: .constant(["Bitcoin", "Ethereum"]),
            availableCurrencies: ["Bitcoin", "Ethereum", "Dogecoin", "Litecoin"],
            onDone: { print("Selection completed") }
        )
    }
}
