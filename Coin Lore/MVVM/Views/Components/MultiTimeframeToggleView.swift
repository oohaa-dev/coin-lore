import SwiftUI

struct MultiTimeframeToggleView: View {
    @Binding var selectedTimeframes: Set<Timeframe>

    var body: some View {
        HStack {
            ForEach(Timeframe.allCases) { timeframe in
                Button(action: {
                    if selectedTimeframes.contains(timeframe) {
                        selectedTimeframes.remove(timeframe)
                    } else {
                        selectedTimeframes.insert(timeframe)
                    }
                }) {
                    Text(timeframe.rawValue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedTimeframes.contains(timeframe) ? backgroundColor(for: timeframe) : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }

    private func backgroundColor(for timeframe: Timeframe) -> Color {
        switch timeframe {
        case .oneHour:
            return Color(hex: "006FFE")
        case .twentyFourHour:
            return Color(hex: "FF8A09")
        case .sevenDays:
            return Color(hex: "A548D9")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        if hex.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        } else {
            r = 0
            g = 0
            b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}
