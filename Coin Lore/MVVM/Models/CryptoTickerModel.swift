import Foundation
/**
 * CryptoTickerModel-strukturen representerer en enkelt kryptovaluta-ticker fra API-et.
 *
 * 1. **Grunnleggende informasjon**:
 *    - `id`: Unik identifikator for kryptovalutaen.
 *    - `symbol`: Kort symbolnavn (f.eks. BTC, ETH).
 *    - `name`: Fullt navn på kryptovalutaen.
 *    - `nameID`: Alternativt navn for identifikasjon (valgfritt).
 *    - `rank`: Markedsrangering av kryptovalutaen.
 *
 * 2. **Pris- og markedsdata**:
 *    - `priceUSD`: Gjeldende pris i USD.
 *    - `percentChange1h`: Prosentvis prisendring siste time.
 *    - `percentChange24h`: Prosentvis prisendring siste 24 timer.
 *    - `percentChange7d`: Prosentvis prisendring siste 7 dager.
 *    - `priceBTC`: Pris i forhold til Bitcoin.
 *    - `marketCapUSD`: Markedsverdi i USD.
 *
 * 3. **Handelsvolum og forsyning**:
 *    - `volume24`: Handelsvolum siste 24 timer.
 *    - `volume24a`: Alternativt handelsvolum siste 24 timer.
 *    - `circulatingSupply`: Antall mynter i omløp.
 *    - `totalSupply`: Totalt antall mynter utstedt.
 *    - `maxSupply`: Maksimalt antall mynter som noen gang kan utstedes (valgfritt).
 *
 * 4. **Tilpassede JSON-mappinger**:
 *    - API-responsen bruker snake_case, så `CodingKeys`-enumet mapper JSON-nøkler til Swift-egenskaper.
 *    - F.eks. `market_cap_usd` fra JSON blir `marketCapUSD` i Swift.
 */
struct CryptoTickerModel: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let nameID: String?
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
        case nameID = "nameid"
        case priceUSD = "price_usd"
        case percentChange1h = "percent_change_1h"
        case percentChange24h = "percent_change_24h"
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
