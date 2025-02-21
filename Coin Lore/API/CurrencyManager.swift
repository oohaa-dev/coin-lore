
import Foundation

class CurrencyManager {
    static let shared = CurrencyManager()
    private let baseURL = "https://api.freecurrencyapi.com/v1/latest"
    private let apiKey = "fca_live_kP2h5BHurPj2xhejha9Tpc4uC5IwBeChMnL5PkXZ" // Replace with a secure storage method if needed
    private let session = URLSession.shared

    private init() {} // Ensures Singleton

    /// Fetches the latest currency exchange rates
    func fetchExchangeRates(completion: @escaping (Result<[String: Double], Error>) -> Void) {
        let urlString = "\(baseURL)?apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("[CurrencyManager] Invalid URL: \(urlString)")
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("[CurrencyManager] Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("[CurrencyManager] No data received from API")
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(CurrencyResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData.data))
                }
            } catch {
                print("[CurrencyManager] Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

/// Response model to decode API response
struct CurrencyResponse: Codable {
    let data: [String: Double] // Dictionary where key is currency code, value is exchange rate
}
