import Foundation

class CurrencyManager {
    static let shared = CurrencyManager()
    private let baseURL = "https://api.freecurrencyapi.com/v1/latest"
    private let apiKey = "fca_live_kP2h5BHurPj2xhejha9Tpc4uC5IwBeChMnL5PkXZ"
    private let session = URLSession.shared

    private init() {}

    /**
     * fetchExchangeRates-metoden henter de nyeste valutakurser fra API-et.
     *
     * 1. **Bygger API-endpoint med API-nøkkel**:
     *    - Setter sammen `urlString` med `baseURL` og `apiKey` for å opprette en gyldig API-forespørsel.
     *    - Validerer URL-en og returnerer en feilmelding hvis den er ugyldig.
     *
     * 2. **Utfører nettverksforespørselen**:
     *    - Bruker `session.dataTask(with: url)` til å hente data fra API-et.
     *    - Håndterer nettverksfeil og returnerer en feilmelding ved feil.
     *
     * 3. **Sikrer at data er mottatt**:
     *    - Hvis `data` er `nil`, logges en feilmelding, og `completion` kalles med en feil.
     *
     * 4. **Dekoder JSON-responsen**:
     *    - Bruker `JSONDecoder()` til å dekode API-svaret som en `CurrencyResponse`.
     *    - Henter valutakursdata fra `decodedData.data`.
     *
     * 5. **Håndterer feil ved dekoding**:
     *    - Hvis dekodingen mislykkes, logges en feilmelding, og `completion` kalles med feilen.
     *
     * 6. **Oppdaterer hovedtråden**:
     *    - Sikrer at `completion` kalles på hovedtråden ved hjelp av `DispatchQueue.main.async`.
     */
    func fetchExchangeRates(completion: @escaping (Result<[String: Double], Error>) -> Void) {
        let urlString = "\(baseURL)?apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(CurrencyResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData.data))
                    print("[CurrencyManager] fetchExchangeRates - Valutakurser hentet fullført fra endpoint: \(urlString)")
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

struct CurrencyResponse: Codable {
    let data: [String: Double]
}
