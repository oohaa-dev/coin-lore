import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var marketData: GlobalMarketModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isStaleData = false

    private let coinLoreManager = CoinLoreManager.shared

    func fetchMarketData() {
        isLoading = true
        errorMessage = nil
        
        coinLoreManager.fetchGlobalMarketData { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let data):
                    // Check if data is stale (if already loaded)
                    self?.isStaleData = (self?.marketData != nil)
                    self?.marketData = data
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                }
            }
        }
    }
}
