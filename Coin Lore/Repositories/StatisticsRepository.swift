import Foundation

class StatisticsRepository {
    private let userDefaults = UserDefaults.standard

    private enum Keys {
        static let previousStatistics = "previousStatistics"
        static let selectedCurrencies = "selectedCurrencies"
    }

    func setSelectedCurrencies(_ currencies: Set<String>) {
        let encodedData = Array(currencies)
        userDefaults.set(encodedData, forKey: Keys.selectedCurrencies)
    }

    func getSelectedCurrencies() -> Set<String> {
        return Set(userDefaults.stringArray(forKey: Keys.selectedCurrencies) ?? [])
    }

    func savePreviousStatistics(_ statistics: [CryptoTickerModel]) {
        let selectedCurrencies = getSelectedCurrencies()
        let filteredStatistics = statistics.filter { selectedCurrencies.contains($0.name) }

        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(filteredStatistics) {
            userDefaults.set(encodedData, forKey: Keys.previousStatistics)
        }
    }

    func getPreviousStatistics() -> [CryptoTickerModel] {
        guard let data = userDefaults.data(forKey: Keys.previousStatistics) else {
            return []
        }

        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode([CryptoTickerModel].self, from: data) {
            return decodedData
        } else {
            return []
        }
    }
}
