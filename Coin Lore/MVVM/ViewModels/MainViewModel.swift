import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var marketData: GlobalMarketModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isStaleData = false
    @Published var currencyRate: Double = 10.0  // Default value, updated dynamically
    @Published var lastUpdated: String = "-"  // Stores last update time

    private let coinLoreManager = CoinLoreManager.shared
    private var lastFetchTime: Date?
    
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
                    let now = Date()
                    self?.isStaleData = self?.lastFetchTime != nil  // Mark data stale if it was previously loaded
                    self?.marketData = data
                    self?.lastFetchTime = now
                    self?.lastUpdated = self?.formatLastUpdated(date: now) ?? "-"
                case .failure:
                    self?.errorMessage = "Could not retrieve market data. Please check your connection."
                }
            }
        }
    }

    // MARK: - Format Last Updated Time
    private func formatLastUpdated(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return "Last updated: " + formatter.string(from: date)
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
        guard currencyRate > 0 else { return "N/A" }
        let nokValue = usdValue * currencyRate
        return NumberFormatterUtility.format(nokValue, currency: "NOK")
    }

}
