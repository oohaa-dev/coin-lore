//
//  DetailsView.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 23/02/2025.
//


import SwiftUI

struct DetailsView: View {
    @StateObject private var viewModel: DetailsViewModel
    let cryptoID: String
    
    init(cryptoID: String) {
        _viewModel = StateObject(wrappedValue: DetailsViewModel())
        self.cryptoID = cryptoID
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let details = viewModel.cryptoDetails {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(details.name)
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Symbol: \(details.symbol)")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        DetailRow(label: "Price (USD)", value: "$\(details.priceUSD)")
                        DetailRow(label: "Market Cap (USD)", value: "$\(details.marketCapUSD)")
                        DetailRow(label: "24h Volume", value: "$\(details.volume24)")
                        DetailRow(label: "Circulating Supply", value: details.circulatingSupply)
                        DetailRow(label: "Total Supply", value: details.totalSupply)
                        DetailRow(label: "Max Supply", value: details.maxSupply ?? "N/A")
                        DetailRow(label: "1h Change", value: "\(details.percentChange1h)%")
                        DetailRow(label: "24h Change", value: "\(details.percentChange24h)%")
                        DetailRow(label: "7d Change", value: "\(details.percentChange7d)%")
                    }
                    .padding()
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            viewModel.fetchCryptoDetails(for: cryptoID)
        }
        .navigationTitle("Crypto Details")
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .bold()
            Spacer()
            Text(value)
        }
        .padding(.vertical, 4)
    }
}