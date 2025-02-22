//
//  TimeframeToggleView.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 22/02/2025.
//


import SwiftUI

struct TimeframeToggleView: View {
    @Binding var selectedTimeframe: Timeframe

    var body: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

// MARK: - SwiftUI Preview
struct TimeframeToggleView_Previews: PreviewProvider {
    static var previews: some View {
        TimeframeToggleView(selectedTimeframe: .constant(.oneHour))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
