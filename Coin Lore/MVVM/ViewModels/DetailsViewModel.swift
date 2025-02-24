//
//  DetailsViewModel.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 23/02/2025.
//

import Foundation

class DetailsViewModel: ObservableObject {
    @Published var cryptoDetails: CryptoTickerModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isStaleData = false // ✅ Tracks if data is stale
    @Published var lastUpdated: String = "-" // ✅ Stores last update time
    
    @Published var currencyRate: Double = 10.0  // Default value, updated dynamically
    @Published var selectedCurrency: String = "NOK" // Default currency, updated dynamically

    private let repository = CoinLoreRepository()
    private let settingsRepository = SettingsRepository()
    private var lastFetchTime: Date?
    private var staleDataTimer: Timer?

    init() {
        loadSettings()
        observeCurrencyUpdates()
        startStaleDataTimer() // ✅ Start timer when the view model is initialized
    }

    // MARK: - Fetch Crypto Details
    func fetchCryptoDetails(for id: String) {
        isLoading = true
        errorMessage = nil

        repository.getCryptoDetails(id: id) { [weak self] (result: Result<CryptoTickerModel, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let details):
                    let now = Date()
                    
                    if let lastFetch = self.lastFetchTime {
                        self.isStaleData = now.timeIntervalSince(lastFetch) > 5 // ✅ Mark stale if older than 5 sec
                    } else {
                        self.isStaleData = false
                    }

                    self.lastFetchTime = now // ✅ Update fetch time
                    self.cryptoDetails = details
                    self.isStaleData = false // ✅ Reset stale data status
                    self.startStaleDataTimer() // ✅ Restart timer to track freshness
                    self.lastUpdated = self.formatLastUpdated(date: now)
                    
                case .failure:
                    self.errorMessage = "Could not retrieve details. Please check your connection."
                }
            }
        }
    }

    // MARK: - Start Timer to Check Staleness
    private func startStaleDataTimer() {
        staleDataTimer?.invalidate() // ✅ Ensure only one timer exists
        staleDataTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let lastFetch = self.lastFetchTime else { return }
            let now = Date()
            DispatchQueue.main.async {
                self.isStaleData = now.timeIntervalSince(lastFetch) > 5 // ✅ Auto-update stale status
            }
        }
    }

    // MARK: - Format Last Updated Time
    private func formatLastUpdated(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return "Last updated: " + formatter.string(from: date)
    }

    // MARK: - Load Settings
    private func loadSettings() {
        self.selectedCurrency = settingsRepository.getSelectedCurrency()
        self.currencyRate = settingsRepository.getCurrencyRate()
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
    func convertToSelectedCurrency(usdValue: String) -> String {
        guard let usdDouble = Double(usdValue), currencyRate > 0 else { return "N/A" }
        let convertedValue = usdDouble * currencyRate
        return NumberFormatterUtility.formatCurrency("\(convertedValue)", currency: selectedCurrency)
    }

    // MARK: - Format Numbers Correctly
    func formatMarketCap(_ value: String) -> String {
        return NumberFormatterUtility.formatCurrency(value, currency: selectedCurrency)
    }

    func formatVolume(_ value: String) -> String {
        return NumberFormatterUtility.formatCurrency(value, currency: selectedCurrency)
    }

    func formatSupply(_ value: String) -> String {
        return NumberFormatterUtility.formatNumber(value)
    }
}
