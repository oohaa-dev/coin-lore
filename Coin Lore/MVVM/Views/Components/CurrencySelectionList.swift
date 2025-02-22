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
    
    var body: some View {
        NavigationView {
            List(availableCurrencies, id: \.self) { currency in
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
