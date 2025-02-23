import Foundation
import SwiftUI

class MarketViewModel: ObservableObject {
    @Published var cryptoTickers: [CryptoTickerModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currencyRate: Double = 10.0  // Default value, updated dynamically
    @Published var isAscending: Bool = true // Tracks sorting order

    private let coinLoreManager = CoinLoreManager.shared
    private var currentSortKey: SortKey = .rank
    
    enum SortKey {
        case rank
        case percentChange1h
        case percentChange24h
        case percentChange7d
    }
    
    init() {
        observeCurrencyRateUpdates()
        fetchTickers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Convert USD to NOK
    func convertToNOK(usdValue: Double) -> String {
        guard currencyRate > 0 else { return "N/A" }
        let nokValue = usdValue * currencyRate
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "NOK"
        return formatter.string(from: NSNumber(value: nokValue)) ?? "\(nokValue) kr"
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
    
    func fetchTickers() {
        isLoading = true
        errorMessage = nil
        
        coinLoreManager.fetchTickers { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let tickers):
                    self?.cryptoTickers = tickers
                    self?.sortTickers()
                case .failure:
                    self?.errorMessage = "Could not retrieve data. Please check your connection."
                }
            }
        }
    }
    
    func sortTickers(by key: SortKey? = nil) {
        if let key = key {
            currentSortKey = key
        }
        
        cryptoTickers.sort {
            let value1: Double
            let value2: Double
            
            switch currentSortKey {
            case .rank:
                value1 = Double($0.rank)
                value2 = Double($1.rank)
            case .percentChange1h:
                value1 = Double($0.percentChange1h) ?? 0
                value2 = Double($1.percentChange1h) ?? 0
            case .percentChange24h:
                value1 = Double($0.percentChange24h) ?? 0
                value2 = Double($1.percentChange24h) ?? 0
            case .percentChange7d:
                value1 = Double($0.percentChange7d) ?? 0
                value2 = Double($1.percentChange7d) ?? 0
            }
            
            return isAscending ? value1 < value2 : value1 > value2
        }
    }
    
    func toggleSortOrder() {
        isAscending.toggle()
        sortTickers()
    }
    
    // MARK: - Format Percentage Change
    func formatPercentageChange(_ value: String) -> String {
        if let doubleValue = Double(value) {
            return String(format: "%.2f%%", doubleValue)
        }
        return "N/A"
    }
    
    // MARK: - Get Color for Change
    func getColorForChange(_ value: String) -> Color {
        if let doubleValue = Double(value) {
            return doubleValue >= 0 ? .green : .red
        }
        return .gray
    }
}
