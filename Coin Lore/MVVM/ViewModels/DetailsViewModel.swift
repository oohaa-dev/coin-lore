import Foundation

class DetailsViewModel: ObservableObject {
    @Published var cryptoDetails: CryptoTickerModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isStaleData = false
    @Published var lastUpdated: String = "-"
    
    @Published var currencyRate: Double = 10.0
    @Published var selectedCurrency: String = "NOK"

    private let repository = CoinLoreRepository()
    private let settingsRepository = SettingsRepository()
    private var lastFetchTime: Date?
    private var staleDataTimer: Timer?

    init() {
        loadSettings()
        observeCurrencyUpdates()
        startStaleDataTimer()
    }

    /**
     * fetchCryptoDetails-metoden henter detaljer om en spesifikk kryptovaluta og håndterer dataens ferskhet.
     *
     * 1. **Setter initial tilstand**:
     *    - `isLoading` settes til `true` for å indikere at en forespørsel pågår.
     *    - `errorMessage` nullstilles for å fjerne eventuelle tidligere feilmeldinger.
     *
     * 2. **Kaller repository for å hente data**:
     *    - Bruker `repository.getCryptoDetails(id: id)` for å hente detaljer for den angitte kryptovalutaen.
     *    - Benytter en weak reference til `self` for å unngå retain cycles i closure.
     *
     * 3. **Behandler API-responsen på hovedtråden**:
     *    - Setter `isLoading` til `false` etter at forespørselen er fullført.
     *
     * 4. **Håndterer vellykket respons**:
     *    - Henter gjeldende tidspunkt (`now`).
     *    - Sammenligner med `lastFetchTime` for å sjekke om dataen er mer enn 5 sekunder gammel (`isStaleData`).
     *    - Oppdaterer `lastFetchTime` med `now` for å registrere når dataen ble hentet.
     *    - Setter `cryptoDetails` til den mottatte responsen.
     *    - Tilbakestiller `isStaleData` til `false` for å markere at dataen er fersk.
     *    - Kaller `startStaleDataTimer()` for å overvåke om dataen blir utdatert over tid.
     *    - Oppdaterer `lastUpdated` med en formatert versjon av tidspunktet.
     *
     * 5. **Håndterer feilrespons**:
     *    - Setter `errorMessage` til en standard feilmelding for å informere brukeren.
     */
    func fetchCryptoDetails(for id: String) {
        isLoading = true
        errorMessage = nil

        repository.getCryptoDetails(id: id) { [weak self] (result: Result<CryptoTickerModel, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let details):
                    let now = Date()
                    
                    if let lastFetch = self.lastFetchTime {
                        self.isStaleData = now.timeIntervalSince(lastFetch) > 5
                    } else {
                        self.isStaleData = false
                    }

                    self.lastFetchTime = now
                    self.cryptoDetails = details
                    self.isStaleData = false
                    self.startStaleDataTimer()
                    self.lastUpdated = self.formatLastUpdated(date: now)
                    print("[DetailsViewModel] fetchCryptoDetails - Henting av kryptovalutadetaljer fullført for ID: \(id)")

                case .failure:
                    self.errorMessage = "Could not retrieve details. Please check your connection."
                }
            }
        }
    }

    /**
     * startStaleDataTimer-metoden starter en timer for å overvåke om dataen blir utdatert (stale).
     *
     * 1. **Invaliderer eksisterende timer**:
     *    - Hvis `staleDataTimer` allerede kjører, stoppes den (`invalidate()`) for å sikre at kun én timer er aktiv samtidig.
     *
     * 2. **Oppretter en ny timer**:
     *    - Timeren kjører med et intervall på 1 sekund og gjentar seg selv kontinuerlig (`repeats: true`).
     *    - Bruker en weak reference til `self` for å unngå retain cycles.
     *
     * 3. **Sjekker dataens ferskhet**:
     *    - Henter gjeldende tidspunkt (`now`).
     *    - Hvis `lastFetchTime` finnes, beregnes tidsforskjellen mellom `now` og `lastFetchTime`.
     *    - På hovedtråden (`DispatchQueue.main.async`), oppdateres `isStaleData` hvis dataen er eldre enn 5 sekunder.
     */
    private func startStaleDataTimer() {
        staleDataTimer?.invalidate()
        staleDataTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let lastFetch = self.lastFetchTime else { return }
            let now = Date()
            DispatchQueue.main.async {
                self.isStaleData = now.timeIntervalSince(lastFetch) > 5
                print("[DetailsViewModel] startStaleDataTimer - Timer startet")
            }
        }
    }

    /**
     * formatLastUpdated-metoden formaterer tidspunktet for siste oppdatering til en lesbar streng.
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
        print("[DetailsViewModel] formatLastUpdated - Formatert dato: \(formatter.string(from: date))")
        return "Last updated: " + formatter.string(from: date)
    }

    /**
     * loadSettings-metoden laster inn brukerens lagrede innstillinger fra `settingsRepository`.
     *
     * 1. **Henter og setter valgt valuta**:
     *    - Kaller `getSelectedCurrency()` fra `settingsRepository` for å hente den foretrukne valutaen.
     *    - Tilordner resultatet til `selectedCurrency`.
     *
     * 2. **Henter og setter valutakurs**:
     *    - Kaller `getCurrencyRate()` fra `settingsRepository` for å hente gjeldende valutakurs.
     *    - Tilordner resultatet til `currencyRate`.
     */
    private func loadSettings() {
        self.selectedCurrency = settingsRepository.getSelectedCurrency()
        self.currencyRate = settingsRepository.getCurrencyRate()
        print("[DetailsViewModel] loadSettings - Innstillinger lastet: Valgt valuta: \(self.selectedCurrency), Valutakurs: \(self.currencyRate)")
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
                print("[DetailsViewModel] updateCurrencyRate - Valutakurs oppdatert til: \(self.currencyRate)")
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
                print("[DetailsViewModel] updateSelectedCurrency - Valuta oppdatert til: \(self.selectedCurrency)")
            }
        }
    }

    /**
     * convertToSelectedCurrency-metoden konverterer en gitt USD-verdi til brukerens valgte valuta.
     *
     * 1. **Validerer inngangsverdien**:
     *    - Forsøker å konvertere `usdValue` (String) til en `Double`.
     *    - Sjekker at `currencyRate` er større enn 0 for å unngå feil ved beregning.
     *    - Hvis konverteringen mislykkes eller `currencyRate` er ugyldig, returneres `"N/A"`.
     *
     * 2. **Utfører valutakonvertering**:
     *    - Multipliserer `usdDouble` med `currencyRate` for å beregne den konverterte verdien.
     *
     * 3. **Formatterer og returnerer resultatet**:
     *    - Bruker `NumberFormatterUtility.formatCurrency(_:currency:)` for å formatere verdien riktig.
     *    - Sender den konverterte verdien og `selectedCurrency` som parametere for formatering.
     */
    func convertToSelectedCurrency(usdValue: String) -> String {
        guard let usdDouble = Double(usdValue), currencyRate > 0 else { return "N/A" }
        let convertedValue = usdDouble * currencyRate
        return NumberFormatterUtility.formatCurrency("\(convertedValue)", currency: selectedCurrency)
    }

    /**
     * formatMarketCap-metoden formaterer en markedsverdi-streng til riktig valutaformat.
     *
     * 1. **Kaller `NumberFormatterUtility` for formatering**:
     *    - Sender `value` og `selectedCurrency` til `formatCurrency`-metoden.
     *    - Sørger for at markedsverdien vises i riktig valutaformat basert på brukerens valg.
     *
     * 2. **Returnerer den formaterte verdien**:
     *    - Den formaterte markedsverdien returneres som en `String` for visning i brukergrensesnittet.
     */
    func formatMarketCap(_ value: String) -> String {
        return NumberFormatterUtility.formatCurrency(value, currency: selectedCurrency)
    }

    /**
     * formatVolume-metoden formaterer et handelsvolum til riktig valutaformat.
     *
     * 1. **Kaller `NumberFormatterUtility` for formatering**:
     *    - Sender `value` og `selectedCurrency` til `formatCurrency`-metoden.
     *    - Sørger for at handelsvolumet vises i riktig valutaformat basert på brukerens valg.
     *
     * 2. **Returnerer den formaterte verdien**:
     *    - Den formaterte volumverdien returneres som en `String` for visning i brukergrensesnittet.
     */

    func formatVolume(_ value: String) -> String {
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

    func formatSupply(_ value: String) -> String {
        return NumberFormatterUtility.formatNumber(value)
    }
}
