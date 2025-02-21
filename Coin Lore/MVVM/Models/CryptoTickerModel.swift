//
//  CryptoTickerModel.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


import Foundation

struct CryptoTickerModel: Codable {
    let id: String
    let symbol: String
    let name: String
    let nameID: String
    let rank: Int
    let priceUSD: String
    let percentChange24h: String
    let percentChange1h: String
    let percentChange7d: String
    let priceBTC: String
    let marketCapUSD: String
    let volume24: Double
    let volume24a: Double
    let circulatingSupply: String
    let totalSupply: String
    let maxSupply: String?

    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case nameID = "nameid"
        case rank
        case priceUSD = "price_usd"
        case percentChange24h = "percent_change_24h"
        case percentChange1h = "percent_change_1h"
        case percentChange7d = "percent_change_7d"
        case priceBTC = "price_btc"
        case marketCapUSD = "market_cap_usd"
        case volume24
        case volume24a
        case circulatingSupply = "csupply"
        case totalSupply = "tsupply"
        case maxSupply = "msupply"
    }
}
