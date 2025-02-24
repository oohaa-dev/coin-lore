import Foundation

class CoinLoreRepository {
    private let apiClient: CoinLoreManager
    
    init(apiClient: CoinLoreManager = CoinLoreManager.shared) {
        self.apiClient = apiClient
    }
    
    func getGlobalMarketData(completion: @escaping (Result<GlobalMarketModel, Error>) -> Void) {
        apiClient.fetchGlobalMarketData(completion: completion)
    }
    
    func getTickers(completion: @escaping (Result<[CryptoTickerModel], Error>) -> Void) {
        apiClient.fetchTickers(completion: completion)
    }
    
    func getCryptoDetails(id: String, completion: @escaping (Result<CryptoTickerModel, Error>) -> Void) {
        apiClient.fetchCryptoDetails(id: id, completion: completion)
    }

}
