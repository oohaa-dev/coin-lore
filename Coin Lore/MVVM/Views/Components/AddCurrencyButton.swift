//
//  AddCurrencyButton.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 22/02/2025.
//


import SwiftUI

struct AddCurrencyButton: View {
    var action: () -> Void // Closure to handle button tap
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
        }
    }
}

// Preview
struct AddCurrencyButton_Previews: PreviewProvider {
    static var previews: some View {
        AddCurrencyButton(action: {
            print("Add Currency Button Pressed")
        })
    }
}
