//
//  CryptoDetailsModel.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 23/02/2025.
//


import Foundation

struct CryptoDetailsModel: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let rank: Int
    let priceUSD: String
    let percentChange1h: String
    let percentChange24h: String
    let percentChange7d: String
    let priceBTC: String
    let marketCapUSD: String
    let volume24: Double
    let volume24a: Double
    let circulatingSupply: String
    let totalSupply: String
    let maxSupply: String?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, rank
        case priceUSD = "price_usd"
        case percentChange1h = "percent_change_1h"
        case percentChange24h = "percent_change_24h"
        case percentChange7d = "percent_change_7d"
        case priceBTC = "price_btc"
        case marketCapUSD = "market_cap_usd"
        case volume24 = "volume24"
        case volume24a = "volume24a"
        case circulatingSupply = "csupply"
        case totalSupply = "tsupply"
        case maxSupply = "msupply"
    }
}