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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        coinsCount = try container.decode(Int.self, forKey: .coinsCount)
        activeMarkets = try container.decode(Int.self, forKey: .activeMarkets)
        totalMcap = try container.decode(Double.self, forKey: .totalMcap)
        totalVolume = try container.decode(Double.self, forKey: .totalVolume)
        
        // The JSON returns these values as strings, so convert them to Double.
        let btcString = try container.decode(String.self, forKey: .btcDominance)
        btcDominance = Double(btcString) ?? 0.0
        
        let ethString = try container.decode(String.self, forKey: .ethDominance)
        ethDominance = Double(ethString) ?? 0.0
        
        let mcapChangeString = try container.decode(String.self, forKey: .mcapChange)
        mcapChange = Double(mcapChangeString) ?? 0.0
        
        let volumeChangeString = try container.decode(String.self, forKey: .volumeChange)
        volumeChange = Double(volumeChangeString) ?? 0.0
        
        let avgChangePercentString = try container.decode(String.self, forKey: .avgChangePercent)
        avgChangePercent = Double(avgChangePercentString) ?? 0.0
        
        // The following fields are expected to be numbers.
        volumeATH = try container.decode(Double.self, forKey: .volumeATH)
        mcapATH = try container.decode(Double.self, forKey: .mcapATH)
    }
}
