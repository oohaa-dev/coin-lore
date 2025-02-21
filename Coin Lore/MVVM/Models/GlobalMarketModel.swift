//
//  GlobalMarketModel.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


import Foundation

struct GlobalMarketModel: Codable {
    let coinsCount: Int
    let activeMarkets: Int
    let totalMcap: Double
    let totalVolume: Double
    let btcDominance: Double
    let ethDominance: Double
    let mcapChange: Double
    let volumeChange: Double
    let avgChangePercent: Double
    let volumeATH: Double
    let mcapATH: Double

    enum CodingKeys: String, CodingKey {
        case coinsCount = "coins_count"
        case activeMarkets = "active_markets"
        case totalMcap = "total_mcap"
        case totalVolume = "total_volume"
        case btcDominance = "btc_d"
        case ethDominance = "eth_d"
        case mcapChange = "mcap_change"
        case volumeChange = "volume_change"
        case avgChangePercent = "avg_change_percent"
        case volumeATH = "volume_ath"
        case mcapATH = "mcap_ath"
    }
}
