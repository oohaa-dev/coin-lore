//
//  MarketViewModel.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//

import Foundation
import SwiftUI

class MarketViewModel: ObservableObject {
    @Published var cryptoTickers: [CryptoTickerModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currencyRate: Double = 10.0  // Default value, updated dynamically
    @Published var isAscending: Bool = true // Tracks sorting order

    private let coinLoreManager = CoinLoreManager.shared
    private var sortAscending = true
    private var currentSortKey: SortKey = .rank
    
    enum SortKey {
        case rank
        case percentChange1h
        case percentChange24h
        case percentChange7d
    }
    
    init() {
        observeCurrencyRateUpdates()
    }
    
    // MARK: - Convert USD to NOK
    func convertToNOK(usdValue: Double) -> String {
        let nokValue = usdValue * currencyRate
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "NOK"
        return formatter.string(from: NSNumber(value: nokValue)) ?? "\(nokValue) kr"
    }
    
    // MARK: - Observe Currency Rate Updates
    private func observeCurrencyRateUpdates() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrencyRate(_:)), name: .currencyRateUpdated, object: nil)
    }

    @objc private func updateCurrencyRate(_ notification: Notification) {
        if let newRate = notification.userInfo?["currencyRate"] as? Double {
            DispatchQueue.main.async {
                self.currencyRate = newRate
            }
        }
    }
    
    func fetchTickers() {
        isLoading = true
        errorMessage = nil
        
        coinLoreManager.fetchTickers { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let tickers):
                    self?.cryptoTickers = tickers
                    self?.sortTickers()
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch tickers: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func sortTickers(by key: SortKey? = nil) {
        if let key = key {
            currentSortKey = key
        }
        
        switch currentSortKey {
        case .rank:
            cryptoTickers.sort { isAscending ? $0.rank < $1.rank : $0.rank > $1.rank }
        case .percentChange1h:
            cryptoTickers.sort { isAscending ? Double($0.percentChange1h) ?? 0 < Double($1.percentChange1h) ?? 0 : Double($0.percentChange1h) ?? 0 > Double($1.percentChange1h) ?? 0 }
        case .percentChange24h:
            cryptoTickers.sort { isAscending ? Double($0.percentChange24h) ?? 0 < Double($1.percentChange24h) ?? 0 : Double($0.percentChange24h) ?? 0 > Double($1.percentChange24h) ?? 0 }
        case .percentChange7d:
            cryptoTickers.sort { isAscending ? Double($0.percentChange7d) ?? 0 < Double($1.percentChange7d) ?? 0 : Double($0.percentChange7d) ?? 0 > Double($1.percentChange7d) ?? 0 }
        }
    }
    
    func toggleSortOrder() {
        isAscending.toggle() // Toggle sorting direction
        sortAscending.toggle()
        sortTickers()
    }
}
