import Foundation
import SwiftUI

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
    private var emojiThreshold: Int = 10

    @Published var cryptoStats: [CryptoTickerModel] = []
    @Published var isLoading = false

    @Published var availableCurrencies: [String] = []
    @Published var selectedCurrencies: Set<String> = []

    private let repository = CoinLoreRepository()
    private let errorHandler: ErrorHandler

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

        DispatchQueue.main.async {
            self.isLoading = true
            self.errorHandler.clearError()
        }

        repository.getTickers { [weak self] result in
            DispatchQueue.main.async {

                self?.isLoading = false
                switch result {
                case .success(let tickers):

                    self?.availableCurrencies = tickers.map { $0.name }

                    let selected = self?.statisticsRepository.getSelectedCurrencies() ?? []
                    self?.selectedCurrencies = selected

                    let filteredTickers = tickers.filter { selected.contains($0.name) }

                    let previousStats = self?.statisticsRepository.getPreviousStatistics() ?? []

                    self?.shouldAnimate = self?.hasSignificantChange(oldStats: previousStats, newStats: filteredTickers) ?? false

                    self?.statisticsRepository.savePreviousStatistics(filteredTickers)

                    self?.cryptoStats = filteredTickers
                    self?.sortData()
                    self?.objectWillChange.send()

                case .failure(let error):
                    self?.errorHandler.setError(error)
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

    }

    func toggleSortOrder() {
        sortAscending.toggle()
        sortData()
    }

    // MARK: - Computed Property for Chart Data
    var chartData: [ChartData] {

        return cryptoStats.map { crypto in
            let change1h = Double(crypto.percentChange1h) ?? 0.0
            let change24h = Double(crypto.percentChange24h) ?? 0.0
            let change7d = Double(crypto.percentChange7d) ?? 0.0

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
