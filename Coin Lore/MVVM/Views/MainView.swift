import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

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
                } else if let marketData = viewModel.marketData {
                    List {
                        Text("Coins Count: \(marketData.coinsCount)")
                            .foregroundColor(viewModel.isStaleData ? .red : .primary)
                        Text("Active Markets: \(marketData.activeMarkets)")
                            .foregroundColor(viewModel.isStaleData ? .red : .primary)
                        
                        Text("Total Market Cap: \(viewModel.convertToNOK(usdValue: marketData.totalMcap))")
                            .foregroundColor(viewModel.isStaleData ? .red : .primary)
                        
                        Text("Total Volume: \(viewModel.convertToNOK(usdValue: marketData.totalVolume))")
                            .foregroundColor(viewModel.isStaleData ? .red : .primary)
                        
                        Text("BTC Dominance: \(marketData.btcDominance)%")
                            .foregroundColor(viewModel.isStaleData ? .red : .primary)
                        
                        Text("ETH Dominance: \(marketData.ethDominance)%")
                            .foregroundColor(viewModel.isStaleData ? .red : .primary)
                    }
                    .refreshable {
                        viewModel.fetchMarketData()
                    }
                } else {
                    Text("No data available")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Global Market")
            .onAppear {
                viewModel.fetchMarketData()
            }
        }
    }
}
