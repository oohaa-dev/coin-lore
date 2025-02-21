import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var marketData: GlobalMarketModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isStaleData = false
    @Published var currencyRate: Double = 10.0  // Default value, updated dynamically

    private let coinLoreManager = CoinLoreManager.shared

    init() {
        observeCurrencyRateUpdates()
        fetchMarketData()
    }

    // MARK: - Fetch Market Data
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

    // MARK: - Observe Currency Rate Updates
    private func observeCurrencyRateUpdates() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrencyRate(_:)), name: .currencyRateUpdated, object: nil)
    }

    @objc private func updateCurrencyRate(_ notification: Notification) {
        if let newRate = notification.userInfo?["currencyRate"] as? Double {
            DispatchQueue.main.async {
                self.currencyRate = newRate
            }
        }
    }

    // MARK: - Convert USD to NOK
    func convertToNOK(usdValue: Double) -> String {
        let nokValue = usdValue * currencyRate
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "NOK"
        return formatter.string(from: NSNumber(value: nokValue)) ?? "\(nokValue) kr"
    }
}
