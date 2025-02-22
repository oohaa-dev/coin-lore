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
            HStack {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                
                Text("Add Currencies")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .shadow(radius: 2)
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
