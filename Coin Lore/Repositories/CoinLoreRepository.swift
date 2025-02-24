import Foundation

class CoinLoreRepository {
    private let apiClient: CoinLoreManager
    
    init(apiClient: CoinLoreManager = CoinLoreManager.shared) {
        self.apiClient = apiClient
    }
    
    /// Fetch global market data
    func getGlobalMarketData(completion: @escaping (Result<GlobalMarketModel, Error>) -> Void) {
        apiClient.fetchGlobalMarketData(completion: completion)
    }
    
    /// Fetch cryptocurrency tickers
    func getTickers(completion: @escaping (Result<[CryptoTickerModel], Error>) -> Void) {
        apiClient.fetchTickers(completion: completion)
    }
    
    /// Fetch cryptocurrency details by ID
    func getCryptoDetails(id: String, completion: @escaping (Result<CryptoTickerModel, Error>) -> Void) {
        apiClient.fetchCryptoDetails(id: id, completion: completion)
    }

}
