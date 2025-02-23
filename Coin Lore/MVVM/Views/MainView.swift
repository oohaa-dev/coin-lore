import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                let columns = isLandscape ? 3 : 2
                let rows = isLandscape ? 2 : 3
                let gridItem = Array(repeating: GridItem(.flexible(), spacing: 0), count: columns)
                let cellSize = CGSize(width: geometry.size.width / CGFloat(columns), height: geometry.size.height / CGFloat(rows))
                
                VStack(spacing: 0) {
                    LazyVGrid(columns: gridItem, spacing: 0) {
                        if let errorMessage = viewModel.errorMessage {
                            ErrorCard(message: errorMessage)
                                .frame(width: cellSize.width, height: cellSize.height)
                        }
                        
                        if viewModel.isLoading {
                            ProgressView("Fetching latest data...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: cellSize.width, height: cellSize.height)
                        } else if let marketData = viewModel.marketData {
                            
                            // Market Overview Section
                            MarketStatSquare(title: "Coins Count", value: "\(marketData.coinsCount)", isStale: viewModel.isStaleData, size: cellSize)
                            MarketStatSquare(title: "Active Markets", value: "\(marketData.activeMarkets)", isStale: viewModel.isStaleData, size: cellSize)
                            
                            // Financial Metrics
                            MarketStatSquare(title: "Total Market Cap", value: viewModel.convertToNOK(usdValue: marketData.totalMcap), isStale: viewModel.isStaleData, size: cellSize)
                            MarketStatSquare(title: "Total Volume", value: viewModel.convertToNOK(usdValue: marketData.totalVolume), isStale: viewModel.isStaleData, size: cellSize)
                            
                            // Dominance Section
                            MarketStatSquare(title: "BTC Dominance", value: "\(marketData.btcDominance)%", isStale: viewModel.isStaleData, size: cellSize)
                            MarketStatSquare(title: "ETH Dominance", value: "\(marketData.ethDominance)%", isStale: viewModel.isStaleData, size: cellSize)
                        } else {
                            Text("No data available")
                                .foregroundColor(.gray)
                                .frame(width: cellSize.width, height: cellSize.height)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .refreshable {
                viewModel.fetchMarketData()
            }
            .navigationTitle("Global Market")
            .background(LinearGradient(gradient: Gradient(colors: [Color(.systemGray6), Color.white]), startPoint: .top, endPoint: .bottom))
            .onAppear {
                viewModel.fetchMarketData()
            }
        }
    }
}
