//
//  MarketView.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//

import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel = MarketViewModel()
    @State private var searchText = ""
    @State private var selectedSortKey: MarketViewModel.SortKey = .rank

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                SearchBar(searchText: $searchText)

                // Sorting Controls (Placed Above the List)
                HStack {
                    Picker("Sort By", selection: $selectedSortKey) {
                        Text("Rank").tag(MarketViewModel.SortKey.rank)
                        Text("1h Change").tag(MarketViewModel.SortKey.percentChange1h)
                        Text("24h Change").tag(MarketViewModel.SortKey.percentChange24h)
                        Text("7d Change").tag(MarketViewModel.SortKey.percentChange7d)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedSortKey) { newValue in
                        viewModel.sortTickers(by: newValue)
                    }
                    
                    Button(action: {
                        viewModel.toggleSortOrder()
                    }) {
                        Image(systemName: viewModel.isAscending ? "arrow.down" : "arrow.up")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)

                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else {
                    List(viewModel.cryptoTickers.filter {
                        searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
                    }, id: \.id) { ticker in
                        NavigationLink(destination: Text("Detail View for \(ticker.name)")) {
                            VStack(alignment: .leading) {
                                Text(ticker.name)
                                    .font(.headline)
                                Text(viewModel.convertToNOK(usdValue: Double(ticker.priceUSD) ?? 0.0))
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .refreshable {
                        viewModel.fetchTickers()
                    }
                }
            }
            .navigationTitle("Cryptocurrencies")
            .onAppear {
                viewModel.fetchTickers()
            }
        }
    }
}
