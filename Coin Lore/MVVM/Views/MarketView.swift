//
//  MarketView.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel = MarketViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else {
                    List(viewModel.cryptoTickers, id: \.id) { ticker in
                        NavigationLink(destination: Text("Detail View for \(ticker.name)")) {
                            VStack(alignment: .leading) {
                                Text(ticker.name)
                                    .font(.headline)
                                Text("$\(ticker.priceUSD)")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .refreshable {
                        viewModel.fetchTickers()
                    }
                    
                    HStack {
                        Button("Sort by Rank") {
                            viewModel.sortTickers(by: .rank)
                        }
                        Button("Sort by 1h Change") {
                            viewModel.sortTickers(by: .percentChange1h)
                        }
                        Button("Sort by 24h Change") {
                            viewModel.sortTickers(by: .percentChange24h)
                        }
                        Button("Sort by 7d Change") {
                            viewModel.sortTickers(by: .percentChange7d)
                        }
                        Button("Toggle Order") {
                            viewModel.toggleSortOrder()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Cryptocurrencies")
            .onAppear {
                viewModel.fetchTickers()
            }
        }
    }
}
