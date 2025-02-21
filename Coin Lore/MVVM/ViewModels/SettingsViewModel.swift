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
    @Published var currencyRate: Double = 10.0  // Standardverdi, f.eks. 10 NOK per USD
    @Published var emojiThreshold: Int = 10     // Standard emoji-grense (0-100)

    private let settingsRepository = SettingsRepository()
    private let statisticsViewModel: StatisticsViewModel

    // MARK: - Initializer
    init(statisticsViewModel: StatisticsViewModel) {
        self.statisticsViewModel = statisticsViewModel
        loadSettings()
    }

    // MARK: - Load Settings
    private func loadSettings() {
        self.currencyRate = settingsRepository.getCurrencyRate()
        self.emojiThreshold = settingsRepository.getEmojiThreshold()
        statisticsViewModel.updateEmojiThreshold(self.emojiThreshold) // Oppdater StatisticsViewModel
    }

    // MARK: - Update Settings
    func updateCurrencyRate(_ newRate: Double) {
        currencyRate = newRate
        settingsRepository.setCurrencyRate(newRate)
    }

    func updateEmojiThreshold(_ newThreshold: Int) {
        emojiThreshold = newThreshold
        settingsRepository.setEmojiThreshold(newThreshold)
        statisticsViewModel.updateEmojiThreshold(newThreshold) // Oppdater StatisticsViewModel
    }
}
