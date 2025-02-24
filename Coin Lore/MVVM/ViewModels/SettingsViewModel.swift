import Foundation
import SwiftUI

extension Notification.Name {
    static let currencyRateUpdated = Notification.Name("currencyRateUpdated")
    static let selectedCurrencyUpdated = Notification.Name("selectedCurrencyUpdated")
}

class SettingsViewModel: ObservableObject {
    @Published var currencyRate: Double = 10.0
    @Published var emojiThreshold: Int
    @Published var selectedCurrency: String = "NOK"
    @Published var exchangeRates: [String: Double] = [:]

    @Published var useCustomCurrency: Bool = false
    @Published var customCurrencyCode: String = "XYZ"
    @Published var customCurrencyRate: Double = 1.0

    @Published var isDarkMode: Bool
    @Published var isLoading = false

    private let currencyManager = CurrencyManager.shared
    private let settingsRepository = SettingsRepository()
    private let statisticsViewModel: StatisticsViewModel
    private let errorHandler: ErrorHandler

    private var lastRealCurrency: String = "NOK"

    init(statisticsViewModel: StatisticsViewModel, errorHandler: ErrorHandler) {
        self.statisticsViewModel = statisticsViewModel
        self.errorHandler = errorHandler
        self.isDarkMode = settingsRepository.getDarkMode()
        
        self.emojiThreshold = settingsRepository.getEmojiThreshold()

        loadSettings()
    }

    /**
     * toggleDarkMode-metoden bytter mellom mørk og lys modus og lagrer brukerens valg.
     *
     * 1. **Endrer mørk modus-status**:
     *    - Bruker `toggle()` på `isDarkMode` for å veksle mellom `true` (mørk modus) og `false` (lys modus).
     *
     * 2. **Lagrer den nye modusen**:
     *    - Kaller `settingsRepository.setDarkMode(isDarkMode)` for å lagre innstillingen.
     */

    func toggleDarkMode() {
        isDarkMode.toggle()
        settingsRepository.setDarkMode(isDarkMode)
        print("[SettingsViewModel] toggleDarkMode - Mørk modus \(isDarkMode ? "aktivert" : "deaktivert")")
    }

    /**
     * updateCurrencyRate-metoden oppdaterer valutakursen og lagrer den i `settingsRepository`.
     *
     * 1. **Setter ny valutakurs**:
     *    - Oppdaterer `currencyRate` med den nye verdien `newRate`.
     *
     * 2. **Lagrer valutakursen**:
     *    - Kaller `settingsRepository.setCurrencyRate(newRate)` for å lagre den oppdaterte kursen.
     *
     * 3. **Sender en varsling via `NotificationCenter`**:
     *    - Publiserer en melding med navnet `.currencyRateUpdated`.
     *    - Inkluderer den nye valutakursen i `userInfo`-ordboken slik at andre deler av appen kan reagere på endringen.
     */
    func updateCurrencyRate(_ newRate: Double) {
        currencyRate = newRate
        settingsRepository.setCurrencyRate(newRate)

        NotificationCenter.default.post(name: .currencyRateUpdated, object: nil, userInfo: ["currencyRate": newRate])
        print("[SettingsViewModel] updateCurrencyRate - Valutakurs oppdatert til: \(newRate)")
    }

    /**
     * loadSettings-metoden laster inn brukerens lagrede innstillinger fra `settingsRepository`.
     *
     * 1. **Henter og setter valuta- og valutakursinnstillinger**:
     *    - Henter `selectedCurrency` og `currencyRate` fra `settingsRepository`.
     *
     * 2. **Henter og setter brukerens egendefinerte valuta- og terskelinnstillinger**:
     *    - Henter `emojiThreshold` for å definere en grenseverdi for emoji-visualisering.
     *    - Leser `useCustomCurrency`, `customCurrencyCode` og `customCurrencyRate` for å håndtere egendefinerte valutaer.
     *
     * 3. **Oppdaterer siste brukte reelle valuta**:
     *    - Hvis `useCustomCurrency` er `false`, settes `lastRealCurrency` til `selectedCurrency`.
     *
     * 4. **Oppdaterer statistikkmodellen med emoji-terskel**:
     *    - Kaller `statisticsViewModel.updateEmojiThreshold(self.emojiThreshold)` for å oppdatere emoji-visningen basert på brukerens terskelinnstilling.
     */
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
        
        print("[SettingsViewModel] loadSettings - Innstillinger lastet")
    }

    /**
     * updateSelectedCurrency-metoden oppdaterer den valgte valutaen hvis brukeren ikke har valgt egendefinert valuta.
     *
     * 1. **Sjekker om brukeren benytter egendefinert valuta**:
     *    - Hvis `useCustomCurrency` er `true`, gjøres ingen endringer.
     *
     * 2. **Oppdaterer valgt valuta**:
     *    - Setter `selectedCurrency` til `newCurrency`.
     *    - Lagrer `lastRealCurrency` for å holde styr på den siste ikke-egendefinerte valutaen.
     *    - Lagrer den nye valutaen i `settingsRepository` ved å kalle `setSelectedCurrency(newCurrency)`.
     *
     * 3. **Oppdaterer valutakursen fra API-et**:
     *    - Kaller `updateCurrencyRateFromAPI()` for å hente den nyeste valutakursen.
     *
     * 4. **Sender en varsling via `NotificationCenter`**:
     *    - Publiserer en melding med navnet `.selectedCurrencyUpdated`.
     *    - Inkluderer den nye valutaen i `userInfo`-ordboken slik at andre deler av appen kan reagere på endringen.
     */
    func updateSelectedCurrency(_ newCurrency: String) {
        if !useCustomCurrency {
            selectedCurrency = newCurrency
            lastRealCurrency = newCurrency
            settingsRepository.setSelectedCurrency(newCurrency)
            updateCurrencyRateFromAPI()

            NotificationCenter.default.post(name: .selectedCurrencyUpdated, object: nil, userInfo: ["selectedCurrency": newCurrency])
            print("[SettingsViewModel] updateSelectedCurrency - Valuta oppdatert til: \(newCurrency)")
        }
    }

    /**
     * updateEmojiThreshold-metoden oppdaterer terskelverdien for emoji-visualisering og lagrer den i `settingsRepository`.
     *
     * 1. **Oppdaterer emoji-terskelverdien**:
     *    - Setter `emojiThreshold` til `newThreshold`.
     *
     * 2. **Lagrer den nye terskelverdien**:
     *    - Kaller `settingsRepository.setEmojiThreshold(newThreshold)` for å lagre verdien vedvarende.
     *
     * 3. **Oppdaterer statistikkvisningen**:
     *    - Kaller `statisticsViewModel.updateEmojiThreshold(newThreshold)` for å sikre at visningen
     *      reflekterer den oppdaterte terskelen umiddelbart.
     */
    func updateEmojiThreshold(_ newThreshold: Int) {
        emojiThreshold = newThreshold
        settingsRepository.setEmojiThreshold(newThreshold)
        statisticsViewModel.updateEmojiThreshold(newThreshold)
        print("[SettingsViewModel] updateEmojiThreshold - Emoji terskel oppdatert til: \(newThreshold)")
    }

    /**
     * fetchExchangeRates-metoden henter de nyeste valutakursene fra API-et og håndterer responsen.
     *
     * 1. **Starter lastestatus**:
     *    - Setter `isLoading = true` for å indikere at data blir hentet.
     *    - Kaller `errorHandler.clearError()` for å nullstille eventuelle tidligere feil før forespørselen starter.
     *
     * 2. **Henter valutakurser fra `currencyManager`**:
     *    - Bruker `fetchExchangeRates()` for å hente valutakursene.
     *    - Benytter en weak reference til `self` for å unngå retain cycles.
     *
     * 3. **Behandler API-responsen på hovedtråden**:
     *    - Setter `isLoading = false` etter at forespørselen er fullført.
     *
     * 4. **Håndterer vellykket respons**:
     *    - Setter `exchangeRates` til de mottatte valutakursene.
     *    - Kaller `updateCurrencyRateFromAPI()` for å oppdatere den valgte valutaens kurs.
     *
     * 5. **Håndterer feilrespons**:
     *    - Kaller `errorHandler.setError(error)` for å håndtere feilen sentralt.
     */
    func fetchExchangeRates() {
        isLoading = true
        errorHandler.clearError()

        currencyManager.fetchExchangeRates { [weak self] (result: Result<[String: Double], Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let rates):
                    self?.exchangeRates = rates
                    self?.updateCurrencyRateFromAPI()
                    print("[SettingsViewModel] fetchExchangeRates - Valutakurser hentet og oppdatert")
                case .failure(let error):
                    self?.errorHandler.setError(error)
                }
            }
        }
    }

    /**
     * updateCurrencyRateFromAPI-metoden oppdaterer valutakursen basert på valgt valuta og tilgjengelige valutakurser.
     *
     * 1. **Sjekker om brukeren benytter egendefinert valuta**:
     *    - Hvis `useCustomCurrency` er `true`, kalles `applyCustomCurrency()` for å bruke den egendefinerte valutakursen.
     *
     * 2. **Henter valutakurs fra API-data**:
     *    - Hvis `useCustomCurrency` er `false`, forsøker metoden å finne valutakursen for `selectedCurrency` i `exchangeRates`.
     *    - Hvis kursen finnes, kalles `updateCurrencyRate(rate)` for å oppdatere verdien.
     */
    func updateCurrencyRateFromAPI() {
        if useCustomCurrency {
            applyCustomCurrency()
        } else if let rate = exchangeRates[selectedCurrency] {
            updateCurrencyRate(rate)
            print("[SettingsViewModel] updateCurrencyRateFromAPI - Valutakurs oppdatert til: \(selectedCurrency) - \(exchangeRates[selectedCurrency] ?? 0)")
        }
    }

    /**
     * updateCustomCurrency-metoden oppdaterer innstillingene for egendefinert valuta og lagrer dem i `settingsRepository`.
     *
     * 1. **Lagrer egendefinerte valutainnstillinger**:
     *    - Setter `useCustomCurrency`-verdien i `settingsRepository`.
     *    - Lagrer den egendefinerte valutakoden (`customCurrencyCode`).
     *    - Lagrer den egendefinerte valutakursen (`customCurrencyRate`).
     *
     * 2. **Bruker riktig valuta basert på innstillingen**:
     *    - Hvis `useCustomCurrency` er `true`, kalles `applyCustomCurrency()` for å aktivere den egendefinerte valutaen.
     *    - Hvis `useCustomCurrency` er `false`, kalles `restoreRealCurrency()` for å gjenopprette den reelle valutakursen fra API-et.
     */
    func updateCustomCurrency() {
        settingsRepository.setUseCustomCurrency(useCustomCurrency)
        settingsRepository.setCustomCurrencyCode(customCurrencyCode)
        settingsRepository.setCustomCurrencyRate(customCurrencyRate)

        if useCustomCurrency {
            applyCustomCurrency()
        } else {
            restoreRealCurrency()
        }

        print("[SettingsViewModel] updateCustomCurrency - Tilpasset valuta oppdatert: \(useCustomCurrency ? "Bruker tilpasset valuta: \(customCurrencyCode)" : "Gjenopprettet original valuta")")
    }

    /**
    **applyCustomCurrency-metoden aktiverer den egendefinerte valutaen og oppdaterer relevante verdier.**
    *
    * 1. **Setter egendefinerte valutaverdier**:
    *    - Oppdaterer currencyRate til customCurrencyRate.
    *    - Oppdaterer selectedCurrency til customCurrencyCode.
    *
    * 2. **Varsler om valutakurs- og valutaskifte**:
    *    - Sender en melding via NotificationCenter med .currencyRateUpdated, inkludert den nye valutakursen.
    *    - Sender en melding via NotificationCenter med .selectedCurrencyUpdated, inkludert den nye valutaen.
    */

    private func applyCustomCurrency() {
        currencyRate = customCurrencyRate
        selectedCurrency = customCurrencyCode

        NotificationCenter.default.post(name: .currencyRateUpdated, object: nil, userInfo: ["currencyRate": customCurrencyRate])
        NotificationCenter.default.post(name: .selectedCurrencyUpdated, object: nil, userInfo: ["selectedCurrency": customCurrencyCode])
        print("[SettingsViewModel] applyCustomCurrency - Tilpasset valuta aktivert: \(customCurrencyCode), Valutakurs satt til: \(customCurrencyRate)")
    }

    /**
      **restoreRealCurrency-metoden gjenoppretter den sist brukte reelle valutaen og oppdaterer valutakursen.**
    
      1. **Setter tilbake den opprinnelige valutaen**:
         - `selectedCurrency` settes til `lastRealCurrency` for å gjenopprette brukerens tidligere valgte ikke-egendefinerte valuta.
     
      2. **Oppdaterer valutakursen fra API-et**:
         - Kaller `updateCurrencyRateFromAPI()` for å hente den nyeste valutakursen for den gjenopprettede valutaen.
     
      3. **Varsler om valutaskifte**:
         - Sender en melding via `NotificationCenter` med `.selectedCurrencyUpdated`, inkludert den gjenopprettede valutaen.
     */
    private func restoreRealCurrency() {
        selectedCurrency = lastRealCurrency // Restore previously selected real currency
        updateCurrencyRateFromAPI()

        NotificationCenter.default.post(name: .selectedCurrencyUpdated, object: nil, userInfo: ["selectedCurrency": lastRealCurrency])
        print("[SettingsViewModel] restoreRealCurrency - Gjenopprettet original valuta: \(lastRealCurrency)")

    }
}
