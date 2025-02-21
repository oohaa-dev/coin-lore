//
//  TickerResponseModel.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


import Foundation

struct TickerResponseModel: Codable {
    let data: [CryptoTickerModel]
    let info: TickerInfoModel
}

struct TickerInfoModel: Codable {
    let coinsNum: Int
    let time: Int

    enum CodingKeys: String, CodingKey {
        case coinsNum = "coins_num"
        case time
    }
}
