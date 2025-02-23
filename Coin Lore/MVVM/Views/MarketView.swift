import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel = MarketViewModel()
    @State private var searchText = ""
    @State private var selectedSortKey: MarketViewModel.SortKey = .rank

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                }
                
                SearchBar(searchText: $searchText)
                
                // Sorting Controls
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
                        Image(systemName: viewModel.isAscending ? "arrow.up" : "arrow.down")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.cryptoTickers.filter {
                                searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
                            }, id: \ .id) { ticker in
                                NavigationLink(destination: Text("Detail View for \(ticker.name)")) {
                                    CryptoCardView(ticker: ticker, viewModel: viewModel)
                                }
                            }
                        }
                        .padding(.horizontal)
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

// MARK: - Subviews

struct ErrorView: View {
    let message: String
    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .font(.callout)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            .padding()
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        }
    }
}

struct CryptoCardView: View {
    let ticker: CryptoTickerModel
    let viewModel: MarketViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ticker.name)
                    .font(.headline)
                
                Text(viewModel.convertToNOK(usdValue: Double(ticker.priceUSD) ?? 0.0))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Text(viewModel.formatPercentageChange(ticker.percentChange24h))
                .font(.subheadline)
                .bold()
                .foregroundColor(viewModel.getColorForChange(ticker.percentChange24h))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(radius: 3))
    }
}
