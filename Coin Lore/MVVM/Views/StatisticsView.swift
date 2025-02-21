//
//  StatisticsView.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


import SwiftUI

struct StatisticsView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Dropdown / Picker for å velge kryptovalutaer
                Picker("Velg kryptovaluta", selection: .constant(0)) {
                    Text("Bitcoin").tag(0)
                    Text("Ethereum").tag(1)
                    Text("Ripple").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Placeholder for graf (erstattes med riktig visualisering senere)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding()

                Spacer()
            }
            .navigationTitle("Statistikk")
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
