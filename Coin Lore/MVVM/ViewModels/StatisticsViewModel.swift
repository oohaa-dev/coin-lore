import Foundation
import SwiftUI

struct ChartData: Identifiable {
    let id = UUID()
    let cryptoName: String
    let change1h: Double
    let change24h: Double
    let change7d: Double
}

class StatisticsViewModel: ObservableObject {
    private let statisticsRepository = StatisticsRepository()
    @Published var shouldAnimate = false
    private var emojiThreshold: Int = 10

    @Published var cryptoStats: [CryptoTickerModel] = []
    @Published var isLoading = false

    @Published var availableCurrencies: [String] = []
    @Published var selectedCurrencies: Set<String> = []

    private let repository = CoinLoreRepository()
    private let errorHandler: ErrorHandler

    private var sortAscending = true
    private var currentSortKey: SortKey = .cryptoName

    enum SortKey {
        case cryptoName
        case percentChange1h
        case percentChange24h
        case percentChange7d
    }

    init(errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
        loadSelectedCurrencies()
    }

    /**
     * fetchStatistics-metoden henter kryptostatistikk og oppdager betydelige endringer i data.
     *
     * 1. **Starter lastestatus på hovedtråden**:
     *    - Setter `isLoading = true` for å indikere at data hentes.
     *    - Nullstiller eventuelle tidligere feil ved å kalle `errorHandler.clearError()`.
     *
     * 2. **Henter kryptostatistikk fra repository**:
     *    - Kaller `repository.getTickers()` for å hente de nyeste ticker-dataene.
     *    - Benytter en weak reference til `self` for å unngå retain cycles.
     *
     * 3. **Behandler API-responsen på hovedtråden**:
     *    - Setter `isLoading = false` når forespørselen er fullført.
     *
     * 4. **Håndterer vellykket respons**:
     *    - Mapper `tickers` til en liste med tilgjengelige valutaer (`availableCurrencies`).
     *    - Henter tidligere valgte valutaer fra `statisticsRepository.getSelectedCurrencies()`.
     *    - Filtrerer ticker-listen basert på de valgte valutaene.
     *    - Henter forrige statistikk fra `statisticsRepository.getPreviousStatistics()`.
     *
     * 5. **Sjekker om det har skjedd en betydelig endring**:
     *    - Bruker `hasSignificantChange(oldStats:newStats:)` til å sammenligne tidligere og nye statistikkdata.
     *    - Hvis en betydelig endring oppdages, settes `shouldAnimate = true`.
     *    - Lagrer den oppdaterte statistikken i `statisticsRepository.savePreviousStatistics(filteredTickers)`.
     *
     * 6. **Oppdaterer grensesnittet**:
     *    - Setter `cryptoStats = filteredTickers` for å oppdatere den interne dataen.
     *    - Kaller `sortData()` for å sortere de nye dataene.
     *    - Sender `objectWillChange.send()` for å varsle eventuelle observatører om at dataene har endret seg.
     *
     * 7. **Håndterer feilrespons**:
     *    - Kaller `errorHandler.setError(error)` for sentralisert feilbehandling.
     */
    func fetchStatistics() {

        DispatchQueue.main.async {
            self.isLoading = true
            self.errorHandler.clearError()
        }

        repository.getTickers { [weak self] result in
            DispatchQueue.main.async {

                self?.isLoading = false
                switch result {
                case .success(let tickers):

                    self?.availableCurrencies = tickers.map { $0.name }

                    let selected = self?.statisticsRepository.getSelectedCurrencies() ?? []
                    self?.selectedCurrencies = selected

                    let filteredTickers = tickers.filter { selected.contains($0.name) }

                    let previousStats = self?.statisticsRepository.getPreviousStatistics() ?? []

                    self?.shouldAnimate = self?.hasSignificantChange(oldStats: previousStats, newStats: filteredTickers) ?? false

                    self?.statisticsRepository.savePreviousStatistics(filteredTickers)

                    self?.cryptoStats = filteredTickers
                    self?.sortData()
                    self?.objectWillChange.send()
                    print("[StatisticsViewModel] fetchStatistics - Statistikk hentet og oppdatert. Antall valgte valutaer: \(self?.selectedCurrencies.count ?? 0)")


                case .failure(let error):
                    self?.errorHandler.setError(error)
                }
            }
        }
    }

    /**
     * loadSelectedCurrencies-metoden laster inn brukerens valgte valutaer fra `statisticsRepository`.
     *
     * 1. **Henter lagrede valutaer**:
     *    - Kaller `statisticsRepository.getSelectedCurrencies()` for å hente listen over brukerens valgte valutaer.
     *
     * 2. **Oppdaterer `selectedCurrencies`-listen**:
     *    - Setter `selectedCurrencies` til verdien hentet fra `statisticsRepository`.
     */
    func loadSelectedCurrencies() {
        selectedCurrencies = statisticsRepository.getSelectedCurrencies()
        print("[StatisticsViewModel] loadSelectedCurrencies - Valgte valutaer lastet: \(selectedCurrencies)")
    }

    /**
     * updateSelectedCurrencies-metoden oppdaterer brukerens valgte valutaer og lagrer dem vedvarende.
     *
     * 1. **Oppdaterer listen over valgte valutaer**:
     *    - Setter `selectedCurrencies` til `newSelection`.
     *
     * 2. **Lagrer de nye valgte valutaene**:
     *    - Kaller `statisticsRepository.setSelectedCurrencies(newSelection)` for å lagre oppdateringen.
     */
    func updateSelectedCurrencies(_ newSelection: Set<String>) {
        selectedCurrencies = newSelection
        statisticsRepository.setSelectedCurrencies(newSelection)
        print("[StatisticsViewModel] updateSelectedCurrencies - Valgte valutaer oppdatert: \(selectedCurrencies)")
    }

    var filteredAvailableCurrencies: [String] {
        availableCurrencies.sorted()
    }

    /**
     * sortData-metoden sorterer kryptostatistikklisten basert på en valgt sorteringsnøkkel.
     *
     * 1. **Oppdaterer gjeldende sorteringsnøkkel**:
     *    - Hvis en `SortKey` er oppgitt, oppdateres `currentSortKey` med denne verdien.
     *
     * 2. **Utfører sortering basert på valgt sorteringsnøkkel**:
     *    - `.cryptoName`: Sorterer kryptovalutaer alfabetisk etter navn.
     *    - `.percentChange1h`: Sorterer basert på prosentvis prisendring siste time.
     *    - `.percentChange24h`: Sorterer basert på prosentvis prisendring siste 24 timer.
     *    - `.percentChange7d`: Sorterer basert på prosentvis prisendring siste 7 dager.
     *
     * 3. **Bruker valgt sorteringsrekkefølge**:
     *    - Hvis `sortAscending` er `true`, sorteres stigende (`<`).
     *    - Hvis `sortAscending` er `false`, sorteres synkende (`>`).
     *    - Bruker `Double(_:) ?? 0` for å håndtere ugyldige verdier i prosentvise endringer.
     */
    func sortData(by key: SortKey? = nil) {

        if let key = key {
            currentSortKey = key
        }

        switch currentSortKey {
        case .cryptoName:
            cryptoStats.sort { sortAscending ? $0.name < $1.name : $0.name > $1.name }
        case .percentChange1h:
            cryptoStats.sort { sortAscending ? Double($0.percentChange1h) ?? 0 < Double($1.percentChange1h) ?? 0 : Double($0.percentChange1h) ?? 0 > Double($1.percentChange1h) ?? 0 }
        case .percentChange24h:
            cryptoStats.sort { sortAscending ? Double($0.percentChange24h) ?? 0 < Double($1.percentChange24h) ?? 0 : Double($0.percentChange24h) ?? 0 > Double($1.percentChange24h) ?? 0 }
        case .percentChange7d:
            cryptoStats.sort { sortAscending ? Double($0.percentChange7d) ?? 0 < Double($1.percentChange7d) ?? 0 : Double($0.percentChange7d) ?? 0 > Double($1.percentChange7d) ?? 0 }
        }
        print("[StatisticsViewModel] sortData - Data sortert etter: \(currentSortKey) i \(sortAscending ? "stigende" : "synkende") rekkefølge")
    }

    /**
     * toggleSortOrder-metoden bytter mellom stigende og synkende sorteringsrekkefølge og sorterer dataene på nytt.
     *
     * 1. **Endrer sorteringsrekkefølgen**:
     *    - Bruker `toggle()` på `sortAscending` for å veksle mellom `true` (stigende) og `false` (synkende).
     *
     * 2. **Sorter kryptostatistikken på nytt**:
     *    - Kaller `sortData()` for å anvende den oppdaterte sorteringsrekkefølgen.
     */
    func toggleSortOrder() {
        sortAscending.toggle()
        sortData()
        print("[StatisticsViewModel] toggleSortOrder - Sorteringsrekkefølge endret til: \(sortAscending ? "Stigende" : "Synkende")")
    }

    var chartData: [ChartData] {

        return cryptoStats.map { crypto in
            let change1h = Double(crypto.percentChange1h) ?? 0.0
            let change24h = Double(crypto.percentChange24h) ?? 0.0
            let change7d = Double(crypto.percentChange7d) ?? 0.0

            return ChartData(
                cryptoName: crypto.name,
                change1h: change1h,
                change24h: change24h,
                change7d: change7d
            )
        }
    }

    /**
     * hasSignificantChange-metoden sjekker om det har skjedd en betydelig endring i kryptostatistikken.
     *
     * 1. **Itererer gjennom den nye statistikken**:
     *    - Går gjennom hver kryptovaluta i `newStats`.
     *
     * 2. **Sammenligner med tidligere statistikk**:
     *    - Søker etter en tilsvarende kryptovaluta i `oldStats` basert på `id`.
     *    - Hvis den finnes, beregnes forskjellen i prosentvis prisendring for:
     *      - Siste 1 time (`change1h`).
     *      - Siste 24 timer (`change24h`).
     *      - Siste 7 dager (`change7d`).
     *
     * 3. **Sjekker om endringene overskrider terskelen**:
     *    - Hvis noen av endringene overstiger `emojiThreshold`, returneres `true` (betydelig endring).
     *
     * 4. **Returnerer `false` hvis ingen betydelige endringer oppdages**:
     *    - Hvis ingen av kryptovalutaene har overskredet terskelen, returneres `false`.
     */
    private func hasSignificantChange(oldStats: [CryptoTickerModel], newStats: [CryptoTickerModel]) -> Bool {
        for newCrypto in newStats {
            if let oldCrypto = oldStats.first(where: { $0.id == newCrypto.id }) {
                let change1h = abs((Double(newCrypto.percentChange1h) ?? 0) - (Double(oldCrypto.percentChange1h) ?? 0))
                let change24h = abs((Double(newCrypto.percentChange24h) ?? 0) - (Double(oldCrypto.percentChange24h) ?? 0))
                let change7d = abs((Double(newCrypto.percentChange7d) ?? 0) - (Double(oldCrypto.percentChange7d) ?? 0))

                if change1h > Double(emojiThreshold) || change24h > Double(emojiThreshold) || change7d > Double(emojiThreshold) {
                    print("[StatisticsViewModel] hasSignificantChange - Signifikant endring oppdaget for \(newCrypto.name)")
    
                    return true
                }
            }
        }
        print("[StatisticsViewModel] hasSignificantChange - Ingen signifikant endring oppdaget")
        return false
    }

    /**
     * updateEmojiThreshold-metoden oppdaterer terskelverdien for betydelige endringer i kryptostatistikken.
     *
     * 1. **Setter ny terskelverdi**:
     *    - Oppdaterer `emojiThreshold` til `newThreshold`.
     */
    func updateEmojiThreshold(_ newThreshold: Int) {
        self.emojiThreshold = newThreshold
        print("[StatisticsViewModel] updateEmojiThreshold - Emoji terskel oppdatert til: \(self.emojiThreshold)")
    }
}
