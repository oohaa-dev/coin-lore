//
//  SettingsView.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


import SwiftUI

struct SettingsView: View {
    @State private var nokExchangeRate: String = "" // Brukerinput for valutakurs
    @State private var animationThreshold: String = "" // Brukerinput for animasjonsterskel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Valutainnstillinger")) {
                    TextField("Skriv inn valutakurs for 1 USD i NOK", text: $nokExchangeRate)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Animasjonsinnstillinger")) {
                    TextField("Terskelverdi for animasjon (%)", text: $animationThreshold)
                        .keyboardType(.numberPad)
                    
                    Text("Velg en verdi mellom 0 og 100.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Innstillinger")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
