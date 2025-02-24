import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var marketData: GlobalMarketModel?
    @Published var isLoading = false
    @Published var isStaleData = false
    @Published var currencyRate: Double = 10.0
    @Published var selectedCurrency: String = "NOK"
    @Published var useCustomCurrency: Bool = false
    @Published var lastUpdated: String = "-"

    private let repository = CoinLoreRepository()
    private let settingsRepository = SettingsRepository()
    private var lastFetchTime: Date?
    private var staleDataTimer: Timer?

    private let errorHandler: ErrorHandler

    init(errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
        loadSettings()
        observeCurrencyUpdates()
        fetchMarketData()
        startStaleDataTimer()
    }
    
    /**
     * startStaleDataTimer-metoden starter en timer for å overvåke om dataen er utdatert (stale).
     * 
     * 1. **Invaliderer eksisterende timer**:
     *    - Hvis `staleDataTimer` allerede kjører, stoppes den (`invalidate()`) for å forhindre at flere timere opprettes.
     *
     * 2. **Oppretter og starter en ny timer**:
     *    - Timeren kjøres hvert sekund (`withTimeInterval: 1, repeats: true`).
     *    - Bruker en weak reference til `self` for å unngå retain cycles.
     *
     * 3. **Sjekker om dataen er utdatert**:
     *    - Henter gjeldende tidspunkt (`now`).
     *    - Beregner tidsforskjellen fra `lastFetchTime` og oppdaterer `isStaleData` på hovedtråden (`DispatchQueue.main.async`).
     *    - Setter `isStaleData = true` hvis dataen er eldre enn 5 sekunder.
     */
    private func startStaleDataTimer() {
        staleDataTimer?.invalidate()
        staleDataTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let lastFetch = self.lastFetchTime else { return }
            let now = Date()
            DispatchQueue.main.async {
                self.isStaleData = now.timeIntervalSince(lastFetch) > 5
            }
        }
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
        print("[MainViewModel] loadSettings - Innstillinger lastet")
    }


    /**
     * fetchMarketData-metoden henter globale markedsdata og håndterer oppdateringsstatus.
     *
     * 1. **Starter lastestatus**:
     *    - Setter `isLoading = true` for å indikere at data blir hentet.
     *    - Kaller `errorHandler.clearError()` for å nullstille eventuelle tidligere feil før forespørselen starter.
     *
     * 2. **Henter markedsdata fra repository**:
     *    - Bruker `repository.getGlobalMarketData()` for å hente data.
     *    - Bruker en weak reference til `self` for å unngå retain cycles.
     *
     * 3. **Behandler API-responsen på hovedtråden**:
     *    - Setter `isLoading = false` når forespørselen er fullført.
     *
     * 4. **Håndterer vellykket respons**:
     *    - Henter gjeldende tidspunkt (`now`).
     *    - Sammenligner med `lastFetchTime` for å avgjøre om dataen er utdatert (`isStaleData` settes til `true` hvis eldre enn 5 sekunder).
     *    - Oppdaterer `lastFetchTime` til `now` for å markere når dataen ble hentet.
     *    - Setter `marketData` til den mottatte responsen.
     *    - Tilbakestiller `isStaleData = false` for å indikere at dataen er fersk.
     *    - Starter `startStaleDataTimer()` for å kontinuerlig overvåke ferskheten av dataen.
     *    - Oppdaterer `lastUpdated` med en formatert versjon av tidspunktet.
     *
     * 5. **Håndterer feilrespons**:
     *    - Kaller `errorHandler.setError(error)` for å håndtere feilen på en sentralisert måte.
     */
  
    func fetchMarketData() {
        isLoading = true
        errorHandler.clearError()

        repository.getGlobalMarketData { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let data):
                    let now = Date()

                    if let lastFetch = self.lastFetchTime {
                        self.isStaleData = now.timeIntervalSince(lastFetch) > 5
                    } else {
                        self.isStaleData = false
                    }

                    self.lastFetchTime = now
                    self.marketData = data
                    self.isStaleData = false
                    self.startStaleDataTimer()

                    self.lastUpdated = self.formatLastUpdated(date: now)
                    print("[MainViewModel] fetchMarketData - Markedsdata henting fullført, data oppdatert")
                    
                case .failure(let error):
                    self.errorHandler.setError(error)
                }
            }
        }
    }

    /**
     * formatLastUpdated-metoden formaterer tidspunktet for siste oppdatering til et lesbart format.
     *
     * 1. **Oppretter en `DateFormatter`-instans**:
     *    - Setter formatet til `"HH:mm:ss"` for å vise tidspunktet i timer, minutter og sekunder.
     *
     * 2. **Formaterer den gitte datoen**:
     *    - Bruker `formatter.string(from: date)` for å konvertere `Date`-objektet til en streng.
     *
     * 3. **Returnerer den formaterte strengen**:
     *    - Legger til prefikset `"Last updated: "` for å gi brukeren kontekst.
     */
    private func formatLastUpdated(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        print("[MainViewModel] formatLastUpdated - Formatert dato: \(formatter.string(from: date))")
        return "Last updated: " + formatter.string(from: date)
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
                print("[MainViewModel] updateCurrencyRate - Valutakurs oppdatert til: \(self.currencyRate)")
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
                print("[MainViewModel] updateSelectedCurrency - Valuta oppdatert til: \(self.selectedCurrency)")
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
     *    - Bruker `NumberFormatterUtility.formatCurrency(_:currency:)` for å formatere verdien riktig.
     *    - Sender den konverterte verdien og `selectedCurrency` som parametere for formatering.
     */
    func convertToSelectedCurrency(usdValue: Double) -> String {
        guard currencyRate > 0 else { return "N/A" }
        let convertedValue = usdValue * currencyRate
        return NumberFormatterUtility.formatCurrency(convertedValue, currency: selectedCurrency)
    }

    /**
     * formatMarketCap-metoden formaterer en markedsverdi til riktig valutaformat.
     *
     * 1. **Kaller `NumberFormatterUtility` for formatering**:
     *    - Sender `value` og `selectedCurrency` til `formatCurrency`-metoden.
     *    - Sikrer at markedsverdien vises i riktig valutaformat basert på brukerens valg.
     *
     * 2. **Returnerer den formaterte verdien**:
     *    - Den formaterte markedsverdien returneres som en `String` for visning i brukergrensesnittet.
     */
    func formatMarketCap(_ value: Double) -> String {
        return NumberFormatterUtility.formatCurrency(value, currency: selectedCurrency)
    }

    /**
     * formatVolume-metoden formaterer et handelsvolum til riktig valutaformat.
     *
     * 1. **Kaller `NumberFormatterUtility` for formatering**:
     *    - Sender `value` og `selectedCurrency` til `formatCurrency`-metoden.
     *    - Sikrer at handelsvolumet vises i riktig valutaformat basert på brukerens valg.
     *
     * 2. **Returnerer den formaterte verdien**:
     *    - Den formaterte volumverdien returneres som en `String` for visning i brukergrensesnittet.
     */

    func formatVolume(_ value: Double) -> String {
        return NumberFormatterUtility.formatCurrency(value, currency: selectedCurrency)
    }

    /**
     * formatSupply-metoden formaterer en forsyningsverdi til et lesbart tallformat.
     *
     * 1. **Kaller `NumberFormatterUtility` for formatering**:
     *    - Sender `value` til `formatNumber`-metoden.
     *    - Sikrer at forsyningsverdien vises i et riktig og lesbart numerisk format.
     *
     * 2. **Returnerer den formaterte verdien**:
     *    - Den formaterte forsyningsverdien returneres som en `String` for visning i brukergrensesnittet.
     */
    func formatSupply(_ value: Double) -> String {
        return NumberFormatterUtility.formatNumber(value)
    }

}
