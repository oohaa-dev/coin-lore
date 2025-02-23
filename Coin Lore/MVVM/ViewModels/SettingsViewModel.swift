import Foundation

// MARK: - Centralized Notification Names
extension Notification.Name {
    static let currencyRateUpdated = Notification.Name("currencyRateUpdated")
    static let selectedCurrencyUpdated = Notification.Name("selectedCurrencyUpdated")
}

class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currencyRate: Double = 10.0
    @Published var emojiThreshold: Int = 10
    @Published var selectedCurrency: String = "NOK" // Default currency
    @Published var exchangeRates: [String: Double] = [:] // Store fetched exchange rates
    
    @Published var useCustomCurrency: Bool = false
    @Published var customCurrencyCode: String = "XYZ"
    @Published var customCurrencyRate: Double = 1.0
    
    @Published var isDarkMode: Bool

    
    private let currencyManager = CurrencyManager.shared
    private let settingsRepository = SettingsRepository()
    private let statisticsViewModel: StatisticsViewModel
    
    private var lastRealCurrency: String = "NOK" // Store last real currency
    
  
    
    // MARK: - Initializer
    init(statisticsViewModel: StatisticsViewModel) {
        self.statisticsViewModel = statisticsViewModel
        self.isDarkMode = settingsRepository.getDarkMode()
        loadSettings()
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        settingsRepository.setDarkMode(isDarkMode)
    }
    
    // MARK: - Update Settings
    func updateCurrencyRate(_ newRate: Double) {
        currencyRate = newRate
        settingsRepository.setCurrencyRate(newRate)
        
        NotificationCenter.default.post(name: .currencyRateUpdated, object: nil, userInfo: ["currencyRate": newRate])
    }
    
    // MARK: - Load Settings
    private func loadSettings() {
        self.selectedCurrency = settingsRepository.getSelectedCurrency()
        self.currencyRate = settingsRepository.getCurrencyRate()
        self.emojiThreshold = settingsRepository.getEmojiThreshold()
        self.useCustomCurrency = settingsRepository.getUseCustomCurrency()
        self.customCurrencyCode = settingsRepository.getCustomCurrencyCode()
        self.customCurrencyRate = settingsRepository.getCustomCurrencyRate()
        
        if !useCustomCurrency {
            lastRealCurrency = selectedCurrency
        }
        
        statisticsViewModel.updateEmojiThreshold(self.emojiThreshold)
    }
    
    // MARK: - Update Selected Currency
    func updateSelectedCurrency(_ newCurrency: String) {
        if !useCustomCurrency {
            selectedCurrency = newCurrency
            lastRealCurrency = newCurrency // Store real currency before switching
            settingsRepository.setSelectedCurrency(newCurrency)
            updateCurrencyRateFromAPI()
            
            NotificationCenter.default.post(name: .selectedCurrencyUpdated, object: nil, userInfo: ["selectedCurrency": newCurrency])
        }
    }
    
    func updateEmojiThreshold(_ newThreshold: Int) {
        emojiThreshold = newThreshold
        settingsRepository.setEmojiThreshold(newThreshold)
        statisticsViewModel.updateEmojiThreshold(newThreshold)
    }
    
    // MARK: - Fetch Exchange Rates
    func fetchExchangeRates() {
        currencyManager.fetchExchangeRates { [weak self] (result: Result<[String: Double], Error>) in
            switch result {
            case .success(let rates):
                DispatchQueue.main.async {
                    self?.exchangeRates = rates
                    self?.updateCurrencyRateFromAPI()
                }
            case .failure(let error):
                print("[SettingsViewModel] Failed to fetch exchange rates: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Update Currency Rate Based on Selected Currency
    func updateCurrencyRateFromAPI() {
        if useCustomCurrency {
            applyCustomCurrency()
        } else if let rate = exchangeRates[selectedCurrency] {
            updateCurrencyRate(rate)
        }
    }
    
    // MARK: - Custom Currency Logic
    func updateCustomCurrency() {
        settingsRepository.setUseCustomCurrency(useCustomCurrency)
        settingsRepository.setCustomCurrencyCode(customCurrencyCode)
        settingsRepository.setCustomCurrencyRate(customCurrencyRate)
        
        if useCustomCurrency {
            applyCustomCurrency()
        } else {
            restoreRealCurrency()
        }
    }
    
    private func applyCustomCurrency() {
        currencyRate = customCurrencyRate
        selectedCurrency = customCurrencyCode
        
        NotificationCenter.default.post(name: .currencyRateUpdated, object: nil, userInfo: ["currencyRate": customCurrencyRate])
        NotificationCenter.default.post(name: .selectedCurrencyUpdated, object: nil, userInfo: ["selectedCurrency": customCurrencyCode])
    }
    
    private func restoreRealCurrency() {
        selectedCurrency = lastRealCurrency // Restore previously selected real currency
        updateCurrencyRateFromAPI()
        
        NotificationCenter.default.post(name: .selectedCurrencyUpdated, object: nil, userInfo: ["selectedCurrency": lastRealCurrency])
    }
}
