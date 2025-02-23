import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var marketData: GlobalMarketModel?
    @Published var isLoading = false
    @Published var isStaleData = false
    @Published var currencyRate: Double = 10.0  // Default value, updated dynamically
    @Published var selectedCurrency: String = "NOK" // Default currency, updated dynamically
    @Published var useCustomCurrency: Bool = false // Track if custom currency is used
    @Published var lastUpdated: String = "-"  // Stores last update time

    private let coinLoreManager = CoinLoreManager.shared
    private let settingsRepository = SettingsRepository()
    private var lastFetchTime: Date?
    
    private let errorHandler: ErrorHandler

    init(errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
        loadSettings()
        observeCurrencyUpdates()
        fetchMarketData()
    }

    // MARK: - Load Settings
    private func loadSettings() {
        self.useCustomCurrency = settingsRepository.getUseCustomCurrency()

        if self.useCustomCurrency {
            self.selectedCurrency = settingsRepository.getCustomCurrencyCode()
            self.currencyRate = settingsRepository.getCustomCurrencyRate()
        } else {
            self.selectedCurrency = settingsRepository.getSelectedCurrency()
            self.currencyRate = settingsRepository.getCurrencyRate()
        }
    }

    // MARK: - Fetch Market Data
    func fetchMarketData() {
        isLoading = true
        errorHandler.clearError() // ✅ Clear errors before fetching

        coinLoreManager.fetchGlobalMarketData { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let data):
                    let now = Date()

                    // ✅ Data is stale if it's older than 5 minutes
                    if let lastFetch = self.lastFetchTime {
                        let fiveMinutesAgo = Date().addingTimeInterval(-300)
                        self.isStaleData = lastFetch < fiveMinutesAgo
                    } else {
                        self.isStaleData = false
                    }

                    self.marketData = data
                    self.lastFetchTime = now
                    self.lastUpdated = self.formatLastUpdated(date: now)
                    
                case .failure(let error):
                    self.errorHandler.setError(error) // ✅ Handle error centrally
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
    
    // MARK: - Observe Currency Updates
    private func observeCurrencyUpdates() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrencyRate(_:)), name: .currencyRateUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSelectedCurrency(_:)), name: .selectedCurrencyUpdated, object: nil)
    }

    @objc private func updateCurrencyRate(_ notification: Notification) {
        if let newRate = notification.userInfo?["currencyRate"] as? Double {
            DispatchQueue.main.async {
                self.currencyRate = newRate
            }
        }
    }
    
    @objc private func updateSelectedCurrency(_ notification: Notification) {
        if let newCurrency = notification.userInfo?["selectedCurrency"] as? String {
            DispatchQueue.main.async {
                self.selectedCurrency = newCurrency
            }
        }
    }
    
    // MARK: - Convert USD to Selected Currency
    func convertToSelectedCurrency(usdValue: Double) -> String {
        guard currencyRate > 0 else { return "N/A" }
        let convertedValue = usdValue * currencyRate
        return NumberFormatterUtility.format(convertedValue, currency: selectedCurrency)
    }
}
