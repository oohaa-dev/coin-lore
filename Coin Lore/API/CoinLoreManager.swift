//
//  CoinLoreManager.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


import Foundation

class CoinLoreManager {
    static let shared = CoinLoreManager()
    private let baseURL = "https://api.coinlore.net/api"
    private let session = URLSession.shared
    
    private init() {} // Ensures Singleton
    
    /// Fetch global market data
    func fetchGlobalMarketData(completion: @escaping (Result<GlobalMarketModel, Error>) -> Void) {
        let urlString = "\(baseURL)/global/"
        guard let url = URL(string: urlString) else {
            print("[CoinLoreManager] Invalid URL: \(urlString)")
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("[CoinLoreManager] Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("[CoinLoreManager] No data received from API")
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(GlobalMarketModel.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                print("[CoinLoreManager] Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Fetch cryptocurrency tickers
    func fetchTickers(completion: @escaping (Result<[CryptoTickerModel], Error>) -> Void) {
        let urlString = "\(baseURL)/tickers/"
        guard let url = URL(string: urlString) else {
            print("[CoinLoreManager] Invalid URL: \(urlString)")
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("[CoinLoreManager] Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("[CoinLoreManager] No data received from API")
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(TickerResponseModel.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData.data))
                }
            } catch {
                print("[CoinLoreManager] Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
