import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel: MarketViewModel
    @ObservedObject private var errorHandler: ErrorHandler
    @State private var searchText = ""
    @State private var selectedSortKey: MarketViewModel.SortKey = .rank

    init(errorHandler: ErrorHandler) {
        _viewModel = StateObject(wrappedValue: MarketViewModel(errorHandler: errorHandler))
        self.errorHandler = errorHandler
    }

    var body: some View {
        NavigationView {
            VStack {
         
                SearchBar(searchText: $searchText)

                HStack {
                    Picker("Sort By", selection: $selectedSortKey) {
                        Text("Rank").tag(MarketViewModel.SortKey.rank)
                        Text("1h Change").tag(MarketViewModel.SortKey.percentChange1h)
                        Text("24h Change").tag(MarketViewModel.SortKey.percentChange24h)
                        Text("7d Change").tag(MarketViewModel.SortKey.percentChange7d)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedSortKey) { oldValue, newValue in
                        viewModel.sortTickers(by: newValue)
                    }


                    Button(action: {
                        viewModel.toggleSortOrder()
                    }) {
                        Image(systemName: viewModel.isAscending ? "arrow.down" : "arrow.up")
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
                            }, id: \.id) { ticker in
                                NavigationLink(destination: DetailsView(cryptoID: ticker.id)) {
                                    CryptoCardView(ticker: ticker, viewModel: viewModel)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .refreshable {
                        errorHandler.clearError()
                        viewModel.fetchTickers()
                    }
                }
            }
            .onAppear {
                viewModel.fetchTickers()
            }
        }
    }
}




