import Foundation

class SettingsRepository {
    private let userDefaults = UserDefaults.standard

    // Nøkler for lagring i UserDefaults
    private enum Keys {
        static let currencyRate = "currencyRate"
        static let emojiThreshold = "emojiThreshold"
        static let selectedCurrency = "selectedCurrency"
        static let lastRealCurrency = "lastRealCurrency" // Stores the last real currency
        static let useCustomCurrency = "useCustomCurrency"
        static let customCurrencyCode = "customCurrencyCode"
        static let customCurrencyRate = "customCurrencyRate"
    }
    
    // MARK: - Selected Currency
    func getSelectedCurrency() -> String {
        if getUseCustomCurrency() {
            return getCustomCurrencyCode() // Use fake currency if toggled on
        }
        return userDefaults.string(forKey: Keys.lastRealCurrency) ?? "NOK" // Restore last real currency
    }

    func setSelectedCurrency(_ currency: String) {
        if !getUseCustomCurrency() {
            userDefaults.set(currency, forKey: Keys.lastRealCurrency) // Store real currency
            userDefaults.set(currency, forKey: Keys.selectedCurrency)
        }
    }

    // Standardverdier hvis ingen verdi er lagret
    private enum DefaultValues {
        static let currencyRate: Double = 10.0
        static let emojiThreshold: Int = 10
        static let useCustomCurrency: Bool = false
        static let customCurrencyCode: String = "XYZ"
        static let customCurrencyRate: Double = 1.0
    }

    // MARK: - Valutakurs (NOK per USD)
    func getCurrencyRate() -> Double {
        return userDefaults.double(forKey: Keys.currencyRate, defaultValue: DefaultValues.currencyRate)
    }

    func setCurrencyRate(_ value: Double) {
        userDefaults.set(value, forKey: Keys.currencyRate)
    }

    // MARK: - Emoji-animasjonsgrense
    func getEmojiThreshold() -> Int {
        return userDefaults.integer(forKey: Keys.emojiThreshold, defaultValue: DefaultValues.emojiThreshold)
    }

    func setEmojiThreshold(_ value: Int) {
        userDefaults.set(value, forKey: Keys.emojiThreshold)
    }

    // MARK: - Custom Currency
    func getUseCustomCurrency() -> Bool {
        return userDefaults.bool(forKey: Keys.useCustomCurrency)
    }

    func setUseCustomCurrency(_ value: Bool) {
        userDefaults.set(value, forKey: Keys.useCustomCurrency)
        
        if !value {
            // If disabling custom currency, restore last real currency
            setSelectedCurrency(getSelectedCurrency())
        }
    }

    func getCustomCurrencyCode() -> String {
        return userDefaults.string(forKey: Keys.customCurrencyCode) ?? DefaultValues.customCurrencyCode
    }

    func setCustomCurrencyCode(_ code: String) {
        userDefaults.set(code, forKey: Keys.customCurrencyCode)
    }

    func getCustomCurrencyRate() -> Double {
        return userDefaults.double(forKey: Keys.customCurrencyRate, defaultValue: DefaultValues.customCurrencyRate)
    }

    func setCustomCurrencyRate(_ rate: Double) {
        userDefaults.set(rate, forKey: Keys.customCurrencyRate)
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
