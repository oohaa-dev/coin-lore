//
//  LoadingView.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 24/02/2025.
//
import SwiftUI


struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        }
    }
}
