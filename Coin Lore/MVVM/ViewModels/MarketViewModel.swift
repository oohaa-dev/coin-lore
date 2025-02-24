import Foundation
import SwiftUI

class MarketViewModel: ObservableObject {
    @Published var cryptoTickers: [CryptoTickerModel] = []
    @Published var isLoading = false
    @Published var currencyRate: Double = 10.0  // Default value, updated dynamically
    @Published var selectedCurrency: String = "NOK" // Default currency, updated dynamically
    @Published var useCustomCurrency: Bool = false // Track if custom currency is used
    @Published var isAscending: Bool = true // Tracks sorting order

    private let repository = CoinLoreRepository()
    private let settingsRepository = SettingsRepository()
    private var currentSortKey: SortKey = .rank
    private let errorHandler: ErrorHandler

    enum SortKey {
        case rank
        case percentChange1h
        case percentChange24h
        case percentChange7d
    }

    init(errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
        loadSettings()
        observeCurrencyUpdates()
        fetchTickers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency
        return formatter.string(from: NSNumber(value: convertedValue)) ?? "\(convertedValue) \(selectedCurrency)"
    }

    // MARK: - Fetch Crypto Tickers
    func fetchTickers() {
        isLoading = true
        errorHandler.clearError() // ✅ Clear previous errors before fetching new data

        repository.getTickers { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let tickers):
                    self.cryptoTickers = tickers
                    self.sortTickers()
                case .failure(let error):
                    self.errorHandler.setError(error) // ✅ Handle error centrally
                }
            }
        }
    }

    // MARK: - Sorting Functions
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
