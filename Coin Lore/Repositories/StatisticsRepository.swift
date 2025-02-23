//
//  StatisticsRepository.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//

import Foundation

class StatisticsRepository {
    private let userDefaults = UserDefaults.standard

    // Nøkler for lagring
    private enum Keys {
        static let previousStatistics = "previousStatistics"
        static let selectedCurrencies = "selectedCurrencies" // New key for selected currencies
    }

    // MARK: - Store Selected Currencies
    func setSelectedCurrencies(_ currencies: Set<String>) {
        let encodedData = Array(currencies)
        userDefaults.set(encodedData, forKey: Keys.selectedCurrencies)
    }

    func getSelectedCurrencies() -> Set<String> {
        return Set(userDefaults.stringArray(forKey: Keys.selectedCurrencies) ?? [])
    }

    // MARK: - Save & Retrieve Statistics for Selected Currencies
    func savePreviousStatistics(_ statistics: [CryptoTickerModel]) {
        let selectedCurrencies = getSelectedCurrencies() // Get user-selected currencies
        let filteredStatistics = statistics.filter { selectedCurrencies.contains($0.name) } // Filter only selected

        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(filteredStatistics) {
            userDefaults.set(encodedData, forKey: Keys.previousStatistics)
        }
    }

    func getPreviousStatistics() -> [CryptoTickerModel] {
        guard let data = userDefaults.data(forKey: Keys.previousStatistics) else {
            return [] // Return empty if no data is saved
        }

        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode([CryptoTickerModel].self, from: data) {
            return decodedData
        } else {
            return []
        }
    }
}
