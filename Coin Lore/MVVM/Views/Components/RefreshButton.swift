//
//  RefreshButton.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 24/02/2025.
//


import SwiftUI

struct RefreshButton: View {
    var action: () -> Void // Closure to handle button tap
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.clockwise.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
        }
    }
}

// Preview
struct RefreshButton_Previews: PreviewProvider {
    static var previews: some View {
        RefreshButton(action: {
            print("Refresh Button Pressed")
        })
    }
}