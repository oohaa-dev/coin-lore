//
//  ErrorCard.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 23/02/2025.
//


import SwiftUI

struct ErrorCard: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .bold()
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.red.opacity(0.1)).shadow(radius: 2))
            .padding(.horizontal)
    }
}
