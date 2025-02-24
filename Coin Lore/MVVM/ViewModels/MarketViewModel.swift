import Foundation
import SwiftUI

class MarketViewModel: ObservableObject {
    @Published var cryptoTickers: [CryptoTickerModel] = []
    @Published var isLoading = false
    @Published var currencyRate: Double = 10.0  
    @Published var selectedCurrency: String = "NOK"
    @Published var useCustomCurrency: Bool = false
    @Published var isAscending: Bool = true

    private let repository = CoinLoreRepository()
    private let settingsRepository = SettingsRepository()
    private var currentSortKey: SortKey = .rank
    private let errorHandler: ErrorHandler

    enum SortKey {
        case rank
        case percentChange1h
        case percentChange24h
        case percentChange7d
    }

    init(errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
        loadSettings()
        observeCurrencyUpdates()
        fetchTickers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /**
     * loadSettings-metoden laster inn brukerens valuta- og valutakursinnstillinger fra `settingsRepository`.
     *
     * 1. **Henter innstilling for egendefinert valuta**:
     *    - Leser verdien av `useCustomCurrency` fra `settingsRepository` og lagrer den i `self.useCustomCurrency`.
     *
     * 2. **Laster riktig valuta og valutakurs basert på brukerens innstillinger**:
     *    - Hvis `useCustomCurrency` er `true`, hentes:
     *      - `selectedCurrency` fra `getCustomCurrencyCode()`.
     *      - `currencyRate` fra `getCustomCurrencyRate()`.
     *    - Hvis `useCustomCurrency` er `false`, hentes:
     *      - `selectedCurrency` fra `getSelectedCurrency()`.
     *      - `currencyRate` fra `getCurrencyRate()`.
     */
    private func loadSettings() {
        self.useCustomCurrency = settingsRepository.getUseCustomCurrency()

        if self.useCustomCurrency {
            self.selectedCurrency = settingsRepository.getCustomCurrencyCode()
            self.currencyRate = settingsRepository.getCustomCurrencyRate()
        } else {
            self.selectedCurrency = settingsRepository.getSelectedCurrency()
            self.currencyRate = settingsRepository.getCurrencyRate()
        }
    }

    /**
     * observeCurrencyUpdates-metoden setter opp observatører for valutarelaterte oppdateringer.
     *
     * 1. **Lytter etter valutakursoppdateringer**:
     *    - Legger til en observatør på `NotificationCenter` for `currencyRateUpdated`-meldinger.
     *    - Kaller `updateCurrencyRate(_:)` når en oppdatering mottas.
     *
     * 2. **Lytter etter endringer i valgt valuta**:
     *    - Legger til en observatør på `NotificationCenter` for `selectedCurrencyUpdated`-meldinger.
     *    - Kaller `updateSelectedCurrency(_:)` når en endring mottas.
     */
    private func observeCurrencyUpdates() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrencyRate(_:)), name: .currencyRateUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSelectedCurrency(_:)), name: .selectedCurrencyUpdated, object: nil)
    }

    /**
     * updateCurrencyRate-metoden oppdaterer valutakursen basert på en melding fra `NotificationCenter`.
     *
     * 1. **Henter den nye valutakursen**:
     *    - Leser `currencyRate`-verdien fra `notification.userInfo` og konverterer den til `Double`.
     *    - Hvis verdien ikke kan tolkes som en `Double`, ignoreres oppdateringen.
     *
     * 2. **Oppdaterer UI på hovedtråden**:
     *    - Bruker `DispatchQueue.main.async` for å sikre at `currencyRate`-verdien oppdateres på hovedtråden.
     */

    @objc private func updateCurrencyRate(_ notification: Notification) {
        if let newRate = notification.userInfo?["currencyRate"] as? Double {
            DispatchQueue.main.async {
                self.currencyRate = newRate
            }
        }
    }

    /**
     * updateSelectedCurrency-metoden oppdaterer den valgte valutaen basert på en melding fra `NotificationCenter`.
     *
     * 1. **Henter den nye valutaen**:
     *    - Leser `selectedCurrency`-verdien fra `notification.userInfo` og konverterer den til `String`.
     *    - Hvis verdien ikke er en `String`, ignoreres oppdateringen.
     *
     * 2. **Oppdaterer UI på hovedtråden**:
     *    - Bruker `DispatchQueue.main.async` for å sikre at `selectedCurrency`-verdien oppdateres på hovedtråden.
     */

    @objc private func updateSelectedCurrency(_ notification: Notification) {
        if let newCurrency = notification.userInfo?["selectedCurrency"] as? String {
            DispatchQueue.main.async {
                self.selectedCurrency = newCurrency
            }
        }
    }

    /**
     * convertToSelectedCurrency-metoden konverterer en gitt USD-verdi til brukerens valgte valuta.
     *
     * 1. **Validerer valutakursen**:
     *    - Sjekker at `currencyRate` er større enn 0 for å unngå feil i beregningen.
     *    - Hvis `currencyRate` er ugyldig eller null, returneres `"N/A"`.
     *
     * 2. **Utfører valutakonvertering**:
     *    - Multipliserer `usdValue` med `currencyRate` for å beregne den konverterte verdien.
     *
     * 3. **Formatterer og returnerer resultatet**:
     *    - Oppretter en `NumberFormatter`-instans og setter `numberStyle` til `.currency`.
     *    - Angir `currencyCode` til `selectedCurrency` for riktig valutavisning.
     *    - Konverterer `convertedValue` til en `NSNumber` og formaterer den som en valutastreng.
     *    - Hvis formatering mislykkes, returneres en fallback-streng med beløpet og valutaen.
     */
    func convertToSelectedCurrency(usdValue: Double) -> String {
        guard currencyRate > 0 else { return "N/A" }
        let convertedValue = usdValue * currencyRate
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency
        return formatter.string(from: NSNumber(value: convertedValue)) ?? "\(convertedValue) \(selectedCurrency)"
    }

    /**
     * fetchTickers-metoden henter kryptovaluta-tickers fra API-et og håndterer responsen.
     *
     * 1. **Starter lastestatus**:
     *    - Setter `isLoading = true` for å indikere at data blir hentet.
     *    - Kaller `errorHandler.clearError()` for å nullstille eventuelle tidligere feil før forespørselen starter.
     *
     * 2. **Henter ticker-data fra repository**:
     *    - Bruker `repository.getTickers()` for å hente listen over tickers.
     *    - Bruker en weak reference til `self` for å unngå retain cycles.
     *
     * 3. **Behandler API-responsen på hovedtråden**:
     *    - Setter `isLoading = false` når forespørselen er fullført.
     *
     * 4. **Håndterer vellykket respons**:
     *    - Setter `cryptoTickers` til listen over hentede tickers.
     *    - Kaller `sortTickers()` for å sortere tickers etter ønsket kriterium.
     *
     * 5. **Håndterer feilrespons**:
     *    - Kaller `errorHandler.setError(error)` for å håndtere feilen på en sentralisert måte.
     */
    func fetchTickers() {
        isLoading = true
        errorHandler.clearError()

        repository.getTickers { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let tickers):
                    self.cryptoTickers = tickers
                    self.sortTickers()
                case .failure(let error):
                    self.errorHandler.setError(error)
                }
            }
        }
    }

    /**
     * sortTickers-metoden sorterer listen over kryptovaluta-tickers basert på en valgt sorteringsnøkkel.
     *
     * 1. **Oppdaterer gjeldende sorteringsnøkkel**:
     *    - Hvis en `SortKey` er oppgitt, oppdateres `currentSortKey` med denne verdien.
     *
     * 2. **Sorter ticker-listen basert på valgt nøkkel**:
     *    - Bestemmer hvilke verdier som skal sammenlignes avhengig av `currentSortKey`:
     *      - `.rank`: Sorterer etter markedsrangering.
     *      - `.percentChange1h`: Sorterer etter prosentvis prisendring siste time.
     *      - `.percentChange24h`: Sorterer etter prosentvis prisendring siste 24 timer.
     *      - `.percentChange7d`: Sorterer etter prosentvis prisendring siste 7 dager.
     *    - Konverterer verdiene til `Double`, med fallback til `0` for å unngå feil.
     *
     * 3. **Bruker valgt sorteringsrekkefølge**:
     *    - Hvis `isAscending` er `true`, sorteres stigende (`<`).
     *    - Hvis `isAscending` er `false`, sorteres synkende (`>`).
     */
    func sortTickers(by key: SortKey? = nil) {
        if let key = key {
            currentSortKey = key
        }

        cryptoTickers.sort {
            let value1: Double
            let value2: Double

            switch currentSortKey {
            case .rank:
                value1 = Double($0.rank)
                value2 = Double($1.rank)
            case .percentChange1h:
                value1 = Double($0.percentChange1h) ?? 0
                value2 = Double($1.percentChange1h) ?? 0
            case .percentChange24h:
                value1 = Double($0.percentChange24h) ?? 0
                value2 = Double($1.percentChange24h) ?? 0
            case .percentChange7d:
                value1 = Double($0.percentChange7d) ?? 0
                value2 = Double($1.percentChange7d) ?? 0
            }

            return isAscending ? value1 < value2 : value1 > value2
        }
    }

    /**
     * toggleSortOrder-metoden bytter mellom stigende og synkende sorteringsrekkefølge.
     *
     * Funksjonen utfører følgende trinn:
     *
     * 1. **Endrer sorteringsrekkefølgen**:
     *    - Bruker `toggle()` på `isAscending` for å veksle mellom `true` (stigende) og `false` (synkende).
     *
     * 2. **Sorterer ticker-listen på nytt**:
     *    - Kaller `sortTickers()` for å sortere listen basert på den nye rekkefølgen.
     */
    func toggleSortOrder() {
        isAscending.toggle()
        sortTickers()
    }

    /**
     * formatPercentageChange-metoden formaterer en prosentvis endring til et lesbart format med to desimaler.
     *
     * 1. **Konverterer `value` til en `Double`**:
     *    - Forsøker å konvertere `value` (String) til `Double`.
     *    - Hvis konverteringen mislykkes, returneres `"N/A"`.
     *
     * 2. **Formatterer prosentverdien**:
     *    - Bruker `String(format: "%.2f%%", doubleValue)` for å vise verdien med to desimaler og prosenttegn.
     */
    func formatPercentageChange(_ value: String) -> String {
        if let doubleValue = Double(value) {
            return String(format: "%.2f%%", doubleValue)
        }
        return "N/A"
    }

    /**
     * getColorForChange-metoden returnerer en farge basert på om en prosentvis endring er positiv eller negativ.
     *
     * 1. **Konverterer `value` til en `Double`**:
     *    - Forsøker å konvertere `value` (String) til `Double`.
     *    - Hvis konverteringen mislykkes, returneres `gray` som standardfarge.
     *
     * 2. **Returnerer riktig farge basert på verdien**:
     *    - Hvis `doubleValue` er større enn eller lik `0`, returneres `green` (positiv endring).
     *    - Hvis `doubleValue` er mindre enn `0`, returneres `red` (negativ endring).
     */
    func getColorForChange(_ value: String) -> Color {
        if let doubleValue = Double(value) {
            return doubleValue >= 0 ? .green : .red
        }
        return .gray
    }
}
