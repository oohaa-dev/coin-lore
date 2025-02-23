import SwiftUI

// MARK: - Timeframe Enum
enum Timeframe: String, CaseIterable, Hashable, Identifiable {
    case oneHour = "1h"
    case twentyFourHour = "24h"
    case sevenDays = "7d"

    var id: String { self.rawValue }
    
    var sortOrder: Int {
        switch self {
        case .oneHour: return 0
        case .twentyFourHour: return 1
        case .sevenDays: return 2
        }
    }

    var color: Color {
        switch self {
        case .oneHour: return .blue
        case .twentyFourHour: return .orange
        case .sevenDays: return .purple
        }
    }
}
