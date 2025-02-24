import Foundation

class CoinLoreManager {
    static let shared = CoinLoreManager() 
    private let baseURL = "https://api.coinlore.net/api"
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Generic method to fetch data from API
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
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Fetch global market data
    func fetchGlobalMarketData(completion: @escaping (Result<GlobalMarketModel, Error>) -> Void) {
        fetchData(endpoint: "/global/", isArray: true, completion: completion)
    }
    
    /// Fetch cryptocurrency tickers
    func fetchTickers(completion: @escaping (Result<[CryptoTickerModel], Error>) -> Void) {
        fetchData(endpoint: "/tickers/") { (result: Result<TickerResponseModel, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Fetch cryptocurrency details by ID
    func fetchCryptoDetails(id: String, completion: @escaping (Result<CryptoTickerModel, Error>) -> Void) {
        fetchData(endpoint: "/ticker/?id=\(id)", isArray: true, completion: completion)
    }

}
