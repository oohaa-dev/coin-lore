//
//  CryptoCardView.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 24/02/2025.
//

import SwiftUICore


struct CryptoCardView: View {
    let ticker: CryptoTickerModel
    let viewModel: MarketViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ticker.name)
                    .font(.headline)

                Text(viewModel.convertToSelectedCurrency(usdValue: Double(ticker.priceUSD) ?? 0.0))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()

            Text(viewModel.formatPercentageChange(ticker.percentChange24h))
                .font(.subheadline)
                .bold()
                .foregroundColor(viewModel.getColorForChange(ticker.percentChange24h))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(radius: 3))
    }
}
