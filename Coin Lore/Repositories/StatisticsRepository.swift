//
//  StatisticsRepository.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


import Foundation

class StatisticsRepository {
    private let userDefaults = UserDefaults.standard

    // Nøkkel for lagring
    private enum Keys {
        static let previousStatistics = "previousStatistics"
    }

    // Funksjon for å lagre forrige statistikk
    func savePreviousStatistics(_ statistics: [CryptoTickerModel]) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(statistics) {
            userDefaults.set(encodedData, forKey: Keys.previousStatistics)
        }
    }

    // Funksjon for å hente lagret statistikk
    func getPreviousStatistics() -> [CryptoTickerModel] {
        guard let data = userDefaults.data(forKey: Keys.previousStatistics) else {
            return [] // Returnerer tom liste hvis ingen data er lagret
        }
        
        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode([CryptoTickerModel].self, from: data) {
            return decodedData
        } else {
            return []
        }
    }
}
