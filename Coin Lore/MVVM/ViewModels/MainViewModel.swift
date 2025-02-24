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

    private let repository = CoinLoreRepository()
    private let settingsRepository = SettingsRepository()
    private var lastFetchTime: Date?
    private var staleDataTimer: Timer?

    
    private let errorHandler: ErrorHandler

    init(errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
        loadSettings()
        observeCurrencyUpdates()
        fetchMarketData()
        startStaleDataTimer() // ✅ Start timer when the view model is initialized
    }
    
    // MARK: - Start Timer to Check Staleness
    private func startStaleDataTimer() {
        staleDataTimer?.invalidate() // ✅ Ensure we don’t create multiple timers
        staleDataTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let lastFetch = self.lastFetchTime else { return }
            let now = Date()
            DispatchQueue.main.async {
                self.isStaleData = now.timeIntervalSince(lastFetch) > 5 // ✅ Auto-update stale status every second
            }
        }
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

        repository.getGlobalMarketData { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let data):
                    let now = Date()

                    if let lastFetch = self.lastFetchTime { // ✅ Check staleness FIRST
                        self.isStaleData = now.timeIntervalSince(lastFetch) > 5
                    } else {
                        self.isStaleData = false
                    }

                    self.lastFetchTime = now // ✅ Update fetch time
                    self.marketData = data // ✅ Update market data
                    self.isStaleData = false // ✅ Reset staleness status
                    self.startStaleDataTimer() // ✅ Restart timer to track freshness



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
