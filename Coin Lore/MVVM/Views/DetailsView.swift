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
                        
                        // Format and display the values with the selected currency
                        DetailRow(
                            label: "Price (\(viewModel.selectedCurrency))",
                            value: viewModel.convertToSelectedCurrency(usdValue: Double(details.priceUSD) ?? 0.0)
                        )

                        DetailRow(label: "Market Cap (\(viewModel.selectedCurrency))", value: viewModel.convertToSelectedCurrency(usdValue: Double(details.marketCapUSD) ?? 0.0))
                        DetailRow(label: "24h Volume", value: viewModel.convertToSelectedCurrency(usdValue: details.volume24))
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
