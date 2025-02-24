import SwiftUI

struct NumberFormatterUtility {
    static func formatCurrency(_ number: Any, currency: String = "NOK") -> String {
        let numberValue: Double
        
        if let numberString = number as? String, let convertedNumber = Double(numberString) {
            numberValue = convertedNumber
        } else if let numberDouble = number as? Double {
            numberValue = numberDouble
        } else {
            return "N/A"
        }
        
        let absNumber = abs(numberValue)
        let sign = numberValue < 0 ? "-" : ""
        
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
            formatted = String(format: "%.2f", absNumber)
        }
        
        return "\(sign)\(formatted) \(currency)"
    }
    
    static func formatNumber(_ number: Any) -> String {
        let numberValue: Double
        
        if let numberString = number as? String, let convertedNumber = Double(numberString) {
            numberValue = convertedNumber
        } else if let numberDouble = number as? Double {
            numberValue = numberDouble
        } else {
            return "N/A"
        }
        
        let absNumber = abs(numberValue)
        let sign = numberValue < 0 ? "-" : ""
        
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
            formatted = String(format: "%.2f", absNumber)
        }
        
        return "\(sign)\(formatted)"
    }
}
