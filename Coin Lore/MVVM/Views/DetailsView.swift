import SwiftUI

struct DetailsView: View {
    @StateObject private var viewModel: DetailsViewModel
    let cryptoID: String

    init(cryptoID: String) {
        _viewModel = StateObject(wrappedValue: DetailsViewModel())
        self.cryptoID = cryptoID
    }

    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { geometry in
                    let isLandscape = geometry.size.width > geometry.size.height
                    let columns = isLandscape ? 5 : 2
                    let rows = isLandscape ? 2 : 5
                    let gridItem = Array(repeating: GridItem(.flexible(), spacing: 0), count: columns) 
                    let cellSize = CGSize(width: geometry.size.width / CGFloat(columns), height: geometry.size.height / CGFloat(rows))


                    LazyVGrid(columns: gridItem, spacing: 0) {
                        if viewModel.isLoading {
                            ProgressView("Loading...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity, minHeight: 100)
                        } else if let details = viewModel.cryptoDetails {
                            MarketStatSquare(title: "Symbol", value: details.symbol, isStale: viewModel.isStaleData, size: cellSize)
                            MarketStatSquare(title: "Price (\(viewModel.selectedCurrency))", value: viewModel.convertToSelectedCurrency(usdValue: details.priceUSD)
, isStale: viewModel.isStaleData, size: cellSize)
                            MarketStatSquare(title: "Market Cap (\(viewModel.selectedCurrency))", value: viewModel.formatMarketCap(details.marketCapUSD), isStale: viewModel.isStaleData, size: cellSize)
                            MarketStatSquare(title: "24h Volume", value: viewModel.formatVolume("\(details.volume24)"), isStale: viewModel.isStaleData, size: cellSize)


                            MarketStatSquare(title: "Circulating Supply", value: viewModel.formatSupply(details.circulatingSupply), isStale: viewModel.isStaleData, size: cellSize)
                            MarketStatSquare(title: "Total Supply", value: viewModel.formatSupply(details.totalSupply), isStale: viewModel.isStaleData, size: cellSize)
                            MarketStatSquare(title: "Max Supply", value: viewModel.formatSupply("\(details.maxSupply)"), isStale: viewModel.isStaleData, size: cellSize)

                            MarketStatSquare(title: "1h Change", value: details.percentChange1h, isStale: viewModel.isStaleData, size: cellSize)
                            MarketStatSquare(title: "24h Change", value: details.percentChange24h, isStale: viewModel.isStaleData, size: cellSize)
                            MarketStatSquare(title: "7d Change", value: details.percentChange7d, isStale: viewModel.isStaleData, size: cellSize)


                        } else {
                            Text("No data available")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, minHeight: 100)
                        }
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RefreshButton {
                            viewModel.fetchCryptoDetails(for: cryptoID)
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemBackground))
            .onAppear {
                viewModel.fetchCryptoDetails(for: cryptoID)
            }
            .onReceive(viewModel.$isStaleData) { _ in
                withAnimation { }
            }
        }
    }
}
