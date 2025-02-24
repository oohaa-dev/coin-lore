import Foundation

class CoinLoreManager {
    static let shared = CoinLoreManager() 
    private let baseURL = "https://api.coinlore.net/api"
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }

    /**
     * fetchData-metoden er en generisk funksjon for å hente data fra et API.
     *
     * 1. **Bygger URL-strengen**:
     *    - Kombinerer `baseURL` med `endpoint` for å danne den fullstendige URL-en.
     *    - Validerer at URL-en er gyldig. Hvis ikke, returneres en feilmelding via `completion`.
     *
     * 2. **Utfører nettverksforespørselen**:
     *    - Bruker `session.dataTask(with: url)` til å sende forespørselen.
     *    - Håndterer feil dersom forespørselen feiler og returnerer en feilmelding via `completion`.
     *
     * 3. **Sikrer at data er mottatt**:
     *    - Hvis `data` er `nil`, returneres en feilmelding om manglende data.
     *
     * 4. **Dekoder JSON-responsen**:
     *    - Hvis `isArray` er `true`, forsøker å dekode data som en liste av `T`.
     *    - Hvis listen inneholder minst ett element, returneres det første elementet.
     *    - Hvis listen er tom, returneres en feilmelding om manglende data.
     *    - Hvis `isArray` er `false`, dekodes data som en enkelt instans av `T`.
     *
     * 5. **Håndterer feil ved dekoding**:
     *    - Hvis JSON-dekodingen mislykkes, returneres en feilmelding via `completion`.
     *
     * 6. **Oppdaterer hovedtråden**:
     *    - Bruker `DispatchQueue.main.async` for å sikre at `completion`-kallet skjer på hovedtråden.
     */
    private func fetchData<T: Decodable>(endpoint: String, isArray: Bool = false, completion: @escaping (Result<T, Error>) -> Void) {
        let urlString = "\(baseURL)\(endpoint)"
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
                if isArray {
                    let decodedArray = try JSONDecoder().decode([T].self, from: data)
                    if let firstElement = decodedArray.first {
                        DispatchQueue.main.async {
                            completion(.success(firstElement))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "No data found", code: 404, userInfo: nil)))
                        }
                    }
                } else {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                        print("[CoinLoreManager] fetchData - Datahenting fullført fra endpoint: \(endpoint)")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /**
     * fetchGlobalMarketData-metoden henter globale markedsdata fra API-et.
     *
     * 1. **Kaller fetchData-metoden**:
     *    - Bruker `fetchData` med endpoint `"/global/"` for å hente markedsdata.
     *    - Setter `isArray` til `true`, noe som indikerer at dataen forventes å være en liste.
     *
     * 2. **Bruker en generisk completion-handler**:
     *    - Viderefører resultatet til `completion`, enten en vellykket `GlobalMarketModel`-instans eller en feil.
     */
    func fetchGlobalMarketData(completion: @escaping (Result<GlobalMarketModel, Error>) -> Void) {
        fetchData(endpoint: "/global/", isArray: true, completion: completion)
    }
    
    /**
     * fetchTickers-metoden henter kryptovaluta-tickers fra API-et.
     *
     * 1. **Kaller fetchData-metoden**:
     *    - Bruker `fetchData` med endpoint `"/tickers/"` for å hente ticker-data.
     *    - Dekoder svaret som en `TickerResponseModel`, som inneholder en liste av `CryptoTickerModel`.
     *
     * 2. **Håndterer API-responsen**:
     *    - Hvis forespørselen er vellykket (`.success`), trekkes `response.data` ut og sendes videre via `completion`.
     *    - Hvis forespørselen feiler (`.failure`), returneres feilen via `completion`.
     */
    func fetchTickers(completion: @escaping (Result<[CryptoTickerModel], Error>) -> Void) {
        fetchData(endpoint: "/tickers/") { (result: Result<TickerResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /**
     * fetchCryptoDetails-metoden henter detaljer om en spesifikk kryptovaluta basert på ID.
     *
     * 1. **Bygger API-endpoint med ID**:
     *    - Setter sammen `endpoint` som `"/ticker/?id=\(id)"` for å hente detaljer for den spesifikke kryptovalutaen.
     *
     * 2. **Kaller fetchData-metoden**:
     *    - Bruker `fetchData` til å hente data.
     *    - Setter `isArray` til `true`, da API-responsen forventes å være en liste hvor første element er det ønskede objektet.
     *
     * 3. **Viderefører resultatet**:
     *    - Returnerer enten en vellykket `CryptoTickerModel`-instans eller en feil via `completion`.
     */
    func fetchCryptoDetails(id: String, completion: @escaping (Result<CryptoTickerModel, Error>) -> Void) {
        fetchData(endpoint: "/ticker/?id=\(id)", isArray: true, completion: completion)
    }

}

struct TickerResponse: Codable {
    let data: [CryptoTickerModel]
    let info: TickerInfo
}

struct TickerInfo: Codable {
    let coinsNum: Int
    let time: Int

    enum CodingKeys: String, CodingKey {
        case coinsNum = "coins_num"
        case time
    }
}

