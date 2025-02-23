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

// MARK: - Components

struct MarketStatSquare: View {
    let title: String
    let value: String
    let isStale: Bool
    let size: CGSize
    
    var body: some View {
        VStack {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(isStale ? Color(red: 0.6, green: 0, blue: 0) : .primary)
            Spacer()
        }
        .frame(width: size.width, height: size.height)
        .background(Rectangle().fill(Color(.systemBackground)).border(Color.gray.opacity(0.3), width: 1))
    }
}

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
