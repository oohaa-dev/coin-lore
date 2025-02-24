import SwiftUI

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @ObservedObject private var errorHandler: ErrorHandler

    init(errorHandler: ErrorHandler) {
        _viewModel = StateObject(wrappedValue: MainViewModel(errorHandler: errorHandler))
        self.errorHandler = errorHandler
    }

    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { geometry in
                    let isLandscape = geometry.size.width > geometry.size.height
                    let columns = isLandscape ? 3 : 2
                    let rows = isLandscape ? 2 : 3
                    let gridItem = Array(repeating: GridItem(.flexible(), spacing: 0), count: columns)
                    let cellSize = CGSize(width: geometry.size.width / CGFloat(columns), height: geometry.size.height / CGFloat(rows))

                    VStack(spacing: 0) {
                        LazyVGrid(columns: gridItem, spacing: 0) {
                            if viewModel.isLoading {
                                ProgressView("Fetching latest data...")
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: cellSize.width, height: cellSize.height)
                            } else if let marketData = viewModel.marketData {
                                MarketStatSquare(title: "Coins Count", value: "\(marketData.coinsCount)", isStale: viewModel.isStaleData, size: cellSize)
                                MarketStatSquare(title: "Active Markets", value: "\(marketData.activeMarkets)", isStale: viewModel.isStaleData, size: cellSize)
                                MarketStatSquare(title: "Total Market Cap (\(viewModel.selectedCurrency))", value: viewModel.convertToSelectedCurrency(usdValue: marketData.totalMcap), isStale: viewModel.isStaleData, size: cellSize)
                                MarketStatSquare(title: "Total Volume (\(viewModel.selectedCurrency))", value: viewModel.convertToSelectedCurrency(usdValue: marketData.totalVolume), isStale: viewModel.isStaleData, size: cellSize)
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

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RefreshButton {
                            errorHandler.clearError()
                            viewModel.fetchMarketData()
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemBackground))
            .onAppear {
                viewModel.fetchMarketData()
            }
            .onReceive(viewModel.$isStaleData) { _ in
                withAnimation { }
            }

        }
    }
}
