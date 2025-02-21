//
//  SettingsRepository.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


import Foundation

class SettingsRepository {
    private let userDefaults = UserDefaults.standard

    // Nøkler for lagring i UserDefaults
    private enum Keys {
        static let currencyRate = "currencyRate"
        static let emojiThreshold = "emojiThreshold"
        static let selectedCurrency = "selectedCurrency"

    }
    
    // MARK: - Selected Currency
    func getSelectedCurrency() -> String {
        return userDefaults.string(forKey: Keys.selectedCurrency) ?? "NOK" // Default to NOK
    }

    func setSelectedCurrency(_ currency: String) {
        userDefaults.set(currency, forKey: Keys.selectedCurrency)
    }


    // Standardverdier hvis ingen verdi er lagret
    private enum DefaultValues {
        static let currencyRate: Double = 10.0  // Standard valutakurs NOK/USD
        static let emojiThreshold: Int = 10     // Standard emoji-animasjonsgrense
    }

    // MARK: - Valutakurs (NOK per USD)
    func getCurrencyRate() -> Double {
        userDefaults.double(forKey: Keys.currencyRate, defaultValue: DefaultValues.currencyRate)
    }

    func setCurrencyRate(_ value: Double) {
        userDefaults.set(value, forKey: Keys.currencyRate)
    }

    // MARK: - Emoji-animasjonsgrense
    func getEmojiThreshold() -> Int {
        userDefaults.integer(forKey: Keys.emojiThreshold, defaultValue: DefaultValues.emojiThreshold)
    }

    func setEmojiThreshold(_ value: Int) {
        userDefaults.set(value, forKey: Keys.emojiThreshold)
    }
}

// MARK: - UserDefaults Extension for Defaults
extension UserDefaults {
    func double(forKey key: String, defaultValue: Double) -> Double {
        if object(forKey: key) == nil { return defaultValue }
        return double(forKey: key)
    }

    func integer(forKey key: String, defaultValue: Int) -> Int {
        if object(forKey: key) == nil { return defaultValue }
        return integer(forKey: key)
    }
}
