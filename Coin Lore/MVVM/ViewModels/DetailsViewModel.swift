//
//  DetailsViewModel.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 23/02/2025.
//

import Foundation

class DetailsViewModel: ObservableObject {
    @Published var cryptoDetails: CryptoTickerModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var currencyRate: Double = 10.0  // Default value, updated dynamically
    @Published var selectedCurrency: String = "NOK" // Default currency, updated dynamically
    private let repository = CoinLoreRepository()
    private let settingsRepository = SettingsRepository()

    init() {
        loadSettings()
        observeCurrencyUpdates()
    }

    func fetchCryptoDetails(for id: String) {
        isLoading = true
        errorMessage = nil
        
        repository.getCryptoDetails(id: id) { [weak self] (result: Result<CryptoTickerModel, Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let details):
                    self?.cryptoDetails = details // Now correctly assigning CryptoTickerModel
                case .failure:
                    self?.errorMessage = "Could not retrieve details. Please check your connection."
                }
            }
        }

    }
    
    // MARK: - Load Settings
    private func loadSettings() {
        self.selectedCurrency = settingsRepository.getSelectedCurrency()
        self.currencyRate = settingsRepository.getCurrencyRate()
    }

    // MARK: - Currency Updates
    private func observeCurrencyUpdates() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrencyRate(_:)), name: .currencyRateUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSelectedCurrency(_:)), name: .selectedCurrencyUpdated, object: nil)
    }

    @objc private func updateCurrencyRate(_ notification: Notification) {
        if let newRate = notification.userInfo?["currencyRate"] as? Double {
            DispatchQueue.main.async {
                self.currencyRate = newRate
            }
        }
    }
    
    @objc private func updateSelectedCurrency(_ notification: Notification) {
        if let newCurrency = notification.userInfo?["selectedCurrency"] as? String {
            DispatchQueue.main.async {
                self.selectedCurrency = newCurrency
            }
        }
    }

    // MARK: - Convert USD to Selected Currency
    func convertToSelectedCurrency(usdValue: Double) -> String {
        guard currencyRate > 0 else { return "N/A" }
        let convertedValue = usdValue * currencyRate
        return NumberFormatterUtility.format(convertedValue, currency: selectedCurrency)
    }
    
}
