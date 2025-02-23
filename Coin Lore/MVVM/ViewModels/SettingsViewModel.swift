import Foundation

class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currencyRate: Double = 10.0
    @Published var emojiThreshold: Int = 10
    @Published var selectedCurrency: String = "NOK" // Default currency
    @Published var exchangeRates: [String: Double] = [:] // Store fetched exchange rates
    
    private let currencyManager = CurrencyManager.shared
    private let settingsRepository = SettingsRepository()
    private let statisticsViewModel: StatisticsViewModel

    // MARK: - Initializer
    init(statisticsViewModel: StatisticsViewModel) {
        self.statisticsViewModel = statisticsViewModel
        loadSettings()
    }
    
    // MARK: - Update Settings
    func updateCurrencyRate(_ newRate: Double) {
        currencyRate = newRate
        settingsRepository.setCurrencyRate(newRate)
        
        // 🔥 Notify other ViewModels about the change
        NotificationCenter.default.post(name: .currencyRateUpdated, object: nil, userInfo: ["currencyRate": newRate])
    }
    
    // MARK: - Load Settings (Updated)
    private func loadSettings() {
        self.selectedCurrency = settingsRepository.getSelectedCurrency() // Load saved currency
        self.currencyRate = settingsRepository.getCurrencyRate()
        self.emojiThreshold = settingsRepository.getEmojiThreshold()
        statisticsViewModel.updateEmojiThreshold(self.emojiThreshold) // Oppdater StatisticsViewModel
        
        // Notify observers of the selected currency
        NotificationCenter.default.post(name: .selectedCurrencyUpdated, object: nil, userInfo: ["selectedCurrency": selectedCurrency])
    }
    
    // MARK: - Update Selected Currency
    func updateSelectedCurrency(_ newCurrency: String) {
        selectedCurrency = newCurrency
        settingsRepository.setSelectedCurrency(newCurrency) // Save currency
        updateCurrencyRateFromAPI() // Update conversion rate
        
        // Notify observers of the selected currency change
        NotificationCenter.default.post(name: .selectedCurrencyUpdated, object: nil, userInfo: ["selectedCurrency": newCurrency])
    }
    
    func updateEmojiThreshold(_ newThreshold: Int) {
        emojiThreshold = newThreshold
        settingsRepository.setEmojiThreshold(newThreshold)
        statisticsViewModel.updateEmojiThreshold(newThreshold) // Oppdater StatisticsViewModel
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
        if let rate = exchangeRates[selectedCurrency] {
            updateCurrencyRate(rate)
        }
    }
}

// MARK: - Notification Name Extension
extension Notification.Name {
    static let currencyRateUpdated = Notification.Name("currencyRateUpdated")
    static let selectedCurrencyUpdated = Notification.Name("selectedCurrencyUpdated") // New notification for currency changes
}
