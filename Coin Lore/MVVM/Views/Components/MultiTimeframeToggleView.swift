//
//  MultiTimeframeToggleView.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 22/02/2025.
//


import SwiftUI

struct MultiTimeframeToggleView: View {
    @Binding var selectedTimeframes: Set<Timeframe>

    var body: some View {
        HStack {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
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
                        .background(selectedTimeframes.contains(timeframe) ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

// MARK: - SwiftUI Preview
struct MultiTimeframeToggleView_Previews: PreviewProvider {
    static var previews: some View {
        MultiTimeframeToggleView(selectedTimeframes: .constant([.oneHour, .twentyFourHour, .sevenDays]))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
