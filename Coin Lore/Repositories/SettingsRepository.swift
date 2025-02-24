import Foundation

class SettingsRepository {
    private let userDefaults = UserDefaults.standard

    private enum Keys {
        static let currencyRate = "currencyRate"
        static let emojiThreshold = "emojiThreshold"
        static let selectedCurrency = "selectedCurrency"
        static let lastRealCurrency = "lastRealCurrency"
        static let useCustomCurrency = "useCustomCurrency"
        static let customCurrencyCode = "customCurrencyCode"
        static let customCurrencyRate = "customCurrencyRate"
        static let isDarkMode = "isDarkMode"

    }
    

    func getDarkMode() -> Bool {
        return userDefaults.bool(forKey: Keys.isDarkMode)
    }

    func setDarkMode(_ value: Bool) {
        userDefaults.set(value, forKey: Keys.isDarkMode)
    }
    
    func getSelectedCurrency() -> String {
        let useCustom = getUseCustomCurrency()
        if useCustom {
            return getCustomCurrencyCode()
        }
        return userDefaults.string(forKey: Keys.lastRealCurrency) ?? "NOK"
    }


    func setSelectedCurrency(_ currency: String) {
        if !getUseCustomCurrency() {
            userDefaults.set(currency, forKey: Keys.lastRealCurrency)
            userDefaults.set(currency, forKey: Keys.selectedCurrency)
        }
    }

    private enum DefaultValues {
        static let currencyRate: Double = 10.0
        static let emojiThreshold: Int = 10
        static let useCustomCurrency: Bool = false
        static let customCurrencyCode: String = "XYZ"
        static let customCurrencyRate: Double = 1.0
    }

    func getCurrencyRate() -> Double {
        return userDefaults.double(forKey: Keys.currencyRate, defaultValue: DefaultValues.currencyRate)
    }

    func setCurrencyRate(_ value: Double) {
        userDefaults.set(value, forKey: Keys.currencyRate)
    }

    func getEmojiThreshold() -> Int {
        return userDefaults.object(forKey: Keys.emojiThreshold) == nil
            ? DefaultValues.emojiThreshold
            : userDefaults.integer(forKey: Keys.emojiThreshold)
    }

    func setEmojiThreshold(_ value: Int) {
        userDefaults.set(value, forKey: Keys.emojiThreshold)
    }



    func getUseCustomCurrency() -> Bool {
        return userDefaults.bool(forKey: Keys.useCustomCurrency)
    }

    func setUseCustomCurrency(_ value: Bool) {
        userDefaults.set(value, forKey: Keys.useCustomCurrency)
        
        if !value {
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
