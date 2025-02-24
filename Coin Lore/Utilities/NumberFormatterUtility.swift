
import SwiftUI

struct NumberFormatterUtility {
    static func format(_ number: Double, currency: String = "NOK") -> String {
        let absNumber = abs(number)
        let sign = number < 0 ? "-" : ""
        
        let formatted: String
        
        switch absNumber {
        case 1_000_000_000_000...:
            formatted = String(format: "%.1fT", absNumber / 1_000_000_000_000)
        case 1_000_000_000...:
            formatted = String(format: "%.1fB", absNumber / 1_000_000_000)
        case 1_000_000...:
            formatted = String(format: "%.1fM", absNumber / 1_000_000)
        case 1_000...:
            formatted = String(format: "%.1fK", absNumber / 1_000)
        default:
            formatted = String(format: "%.0f", absNumber)
        }
        
        return "\(sign)\(currency) \(formatted)"
    }
}
