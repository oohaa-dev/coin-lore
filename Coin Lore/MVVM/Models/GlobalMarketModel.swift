import Foundation
/**
 * GlobalMarketModel-strukturen representerer samlede markedsdata for kryptovaluta.
 *
 * 1. **Generell markedsinformasjon**:
 *    - `coinsCount`: Totalt antall kryptovalutaer på markedet.
 *    - `activeMarkets`: Antall aktive handelsmarkeder.
 *    - `totalMcap`: Total markedsverdi i USD.
 *    - `totalVolume`: Totalt handelsvolum i USD.
 *
 * 2. **Dominans og endringer**:
 *    - `btcDominance`: Bitcoin-dominans i prosent.
 *    - `ethDominance`: Ethereum-dominans i prosent.
 *    - `mcapChange`: Endring i total markedsverdi.
 *    - `volumeChange`: Endring i handelsvolum.
 *    - `avgChangePercent`: Gjennomsnittlig prisendring på tvers av markedet.
 *
 * 3. **All-Time High (ATH) verdier**:
 *    - `volumeATH`: Historisk høyeste handelsvolum.
 *    - `mcapATH`: Historisk høyeste markedsverdi.
 *
 * 4. **Tilpassede JSON-mappinger**:
 *    - Bruker `CodingKeys` for å mappe API-responsens snake_case-nøkler til Swift-egenskaper.
 *
 * 5. **Tilpasset dekodering i initialiseringsmetoden**:
 *    - Noen API-felter (`btc_d`, `eth_d`, `mcap_change`, `volume_change`, `avg_change_percent`) returneres som strenger i JSON.
 *    - Disse verdiene konverteres til `Double` ved hjelp av `Double(string) ?? 0.0` for å unngå krasj ved feilformatert data.
 *    - Andre numeriske verdier dekodes direkte som `Double`.
 */
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
        
        volumeATH = try container.decode(Double.self, forKey: .volumeATH)
        mcapATH = try container.decode(Double.self, forKey: .mcapATH)
    }
}
