//
//  SettingsViewModel.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


//
//  SettingsViewModel.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


import Foundation

class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currencyRate: Double = 10.0
    @Published var emojiThreshold: Int = 10
    
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


    // MARK: - Load Settings
    private func loadSettings() {
        self.currencyRate = settingsRepository.getCurrencyRate()
        self.emojiThreshold = settingsRepository.getEmojiThreshold()
        statisticsViewModel.updateEmojiThreshold(self.emojiThreshold) // Oppdater StatisticsViewModel
    }

  

    func updateEmojiThreshold(_ newThreshold: Int) {
        emojiThreshold = newThreshold
        settingsRepository.setEmojiThreshold(newThreshold)
        statisticsViewModel.updateEmojiThreshold(newThreshold) // Oppdater StatisticsViewModel
    }

}


// MARK: - Notification Name Extension
extension Notification.Name {
    static let currencyRateUpdated = Notification.Name("currencyRateUpdated")
}



