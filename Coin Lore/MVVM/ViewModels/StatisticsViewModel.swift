import Foundation
import SwiftUI

/// A helper struct representing the chart data for a single cryptocurrency.
struct ChartData: Identifiable {
    let id = UUID()
    let cryptoName: String
    let change1h: Double
    let change24h: Double
    let change7d: Double
}

class StatisticsViewModel: ObservableObject {
    // MARK: - Dependencies
    private let statisticsRepository = StatisticsRepository()
    @Published var shouldAnimate = false
    private var emojiThreshold: Int = 10 // Standard value, updated from SettingsViewModel

    @Published var cryptoStats: [CryptoTickerModel] = []
    @Published var isLoading = false

    @Published var availableCurrencies: [String] = [] // List of all possible currencies
    @Published var selectedCurrencies: Set<String> = [] // Selected currencies from user

    private let repository = CoinLoreRepository()
    private let errorHandler: ErrorHandler // ✅ Centralized error handling

    private var sortAscending = true
    private var currentSortKey: SortKey = .cryptoName

    enum SortKey {
        case cryptoName
        case percentChange1h
        case percentChange24h
        case percentChange7d
    }

    // MARK: - Initialization
    init(errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
        loadSelectedCurrencies()
    }

    // MARK: - Fetching Data with Change Detection
    func fetchStatistics() {
        print("📡 fetchStatistics() called, setting isLoading = true")

        DispatchQueue.main.async {
            self.isLoading = true
            self.errorHandler.clearError() // ✅ Clear previous errors before fetching
        }

        print("🔄 Calling CoinLoreManager.fetchTickers()")
        repository.getTickers { [weak self] result in
            DispatchQueue.main.async {
                print("✅ Received response in fetchTickers closure")

                self?.isLoading = false
                switch result {
                case .success(let tickers):
                    print("📊 Successfully fetched \(tickers.count) tickers")

                    // Store all available currencies
                    self?.availableCurrencies = tickers.map { $0.name }

                    // Get selected currencies
                    let selected = self?.statisticsRepository.getSelectedCurrencies() ?? []
                    self?.selectedCurrencies = selected

                    // Filter tickers to only include selected currencies
                    let filteredTickers = tickers.filter { selected.contains($0.name) }

                    // Fetch previous statistics only for selected currencies
                    let previousStats = self?.statisticsRepository.getPreviousStatistics() ?? []

                    // Check if animation should play based on selected currencies
                    self?.shouldAnimate = self?.hasSignificantChange(oldStats: previousStats, newStats: filteredTickers) ?? false

                    // Save only the selected cryptocurrencies' statistics
                    self?.statisticsRepository.savePreviousStatistics(filteredTickers)

                    // Update UI
                    self?.cryptoStats = filteredTickers
                    self?.sortData()
                    self?.objectWillChange.send()
                    print("🎯 cryptoStats updated with \(self?.cryptoStats.count ?? 0) items")

                case .failure(let error):
                    print("❌ Error fetching statistics: \(error.localizedDescription)")
                    self?.errorHandler.setError(error) // ✅ Handle error centrally
                }
            }
        }
    }

    // MARK: - Handle Selected Currencies
    func loadSelectedCurrencies() {
        selectedCurrencies = statisticsRepository.getSelectedCurrencies()
    }

    func updateSelectedCurrencies(_ newSelection: Set<String>) {
        selectedCurrencies = newSelection
        statisticsRepository.setSelectedCurrencies(newSelection)
    }

    var filteredAvailableCurrencies: [String] {
        availableCurrencies.sorted()
    }

    // MARK: - Sorting
    func sortData(by key: SortKey? = nil) {
        print("🔀 sortData() called with key: \(key.map { "\($0)" } ?? "currentSortKey")")

        if let key = key {
            currentSortKey = key
        }

        switch currentSortKey {
        case .cryptoName:
            cryptoStats.sort { sortAscending ? $0.name < $1.name : $0.name > $1.name }
        case .percentChange1h:
            cryptoStats.sort { sortAscending ? Double($0.percentChange1h) ?? 0 < Double($1.percentChange1h) ?? 0 : Double($0.percentChange1h) ?? 0 > Double($1.percentChange1h) ?? 0 }
        case .percentChange24h:
            cryptoStats.sort { sortAscending ? Double($0.percentChange24h) ?? 0 < Double($1.percentChange24h) ?? 0 : Double($0.percentChange24h) ?? 0 > Double($1.percentChange24h) ?? 0 }
        case .percentChange7d:
            cryptoStats.sort { sortAscending ? Double($0.percentChange7d) ?? 0 < Double($1.percentChange7d) ?? 0 : Double($0.percentChange7d) ?? 0 > Double($1.percentChange7d) ?? 0 }
        }

        print("✅ Sorting completed, first item (if exists): \(cryptoStats.first?.name ?? "No data")")
    }

    func toggleSortOrder() {
        sortAscending.toggle()
        print("🔄 Sorting order toggled to: \(sortAscending ? "Ascending" : "Descending")")
        sortData()
    }

    // MARK: - Computed Property for Chart Data
    var chartData: [ChartData] {
        print("📊 Accessing chartData, cryptoStats count: \(cryptoStats.count)")

        return cryptoStats.map { crypto in
            let change1h = Double(crypto.percentChange1h) ?? 0.0
            let change24h = Double(crypto.percentChange24h) ?? 0.0
            let change7d = Double(crypto.percentChange7d) ?? 0.0

            print("📉 ChartData - \(crypto.name): 1h=\(change1h), 24h=\(change24h), 7d=\(change7d)")

            return ChartData(
                cryptoName: crypto.name,
                change1h: change1h,
                change24h: change24h,
                change7d: change7d
            )
        }
    }

    // MARK: - Check for Significant Changes
    private func hasSignificantChange(oldStats: [CryptoTickerModel], newStats: [CryptoTickerModel]) -> Bool {
        for newCrypto in newStats {
            if let oldCrypto = oldStats.first(where: { $0.id == newCrypto.id }) {
                let change1h = abs((Double(newCrypto.percentChange1h) ?? 0) - (Double(oldCrypto.percentChange1h) ?? 0))
                let change24h = abs((Double(newCrypto.percentChange24h) ?? 0) - (Double(oldCrypto.percentChange24h) ?? 0))
                let change7d = abs((Double(newCrypto.percentChange7d) ?? 0) - (Double(oldCrypto.percentChange7d) ?? 0))

                if change1h > Double(emojiThreshold) || change24h > Double(emojiThreshold) || change7d > Double(emojiThreshold) {
                    print("💰 Significant change detected! Triggering animation.")
                    return true
                }
            }
        }
        return false
    }

    // MARK: - Update Emoji Threshold from Settings
    func updateEmojiThreshold(_ newThreshold: Int) {
        self.emojiThreshold = newThreshold
    }
}
