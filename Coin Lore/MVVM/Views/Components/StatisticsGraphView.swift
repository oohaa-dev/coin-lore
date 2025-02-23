import SwiftUI
import Charts

struct StatisticsGraphView: View {
    @State private var selectedTimeframes: Set<Timeframe> = [.oneHour, .twentyFourHour, .sevenDays]
    var cryptos: [ChartData]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // ✅ Ensuring top alignment
            // Timeframe Selection
            MultiTimeframeToggleView(selectedTimeframes: $selectedTimeframes)
            
            ScrollView{
                VStack {
                    
                    chartView
                }
                .frame(height: CGFloat(cryptos.count) * 50) // ✅ Ensuring correct height
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading) // ✅ Keeping content at the top
        .padding(.horizontal)
    }

    // Chart View
    private var chartView: some View {
        Chart {
            ForEach(filteredData.indices, id: \ .self) { index in
                let crypto = filteredData[index]
                let timeframes = selectedTimeframes.sorted(by: { $0.sortOrder < $1.sortOrder })

                ForEach(timeframes.indices, id: \ .self) { tIndex in
                    let timeframe = timeframes[tIndex]
                    let changeValue = timeframe == .oneHour ? crypto.change1h :
                                      timeframe == .twentyFourHour ? crypto.change24h :
                                      crypto.change7d

                    BarMark(
                        x: .value("Change", changeValue),
                        y: .value("Cryptocurrency", crypto.cryptoName)
                    )
                    .position(by: .value("Timeframe", timeframe.rawValue)) // Prevents stacking
                    .foregroundStyle(timeframe.color)
                }
            }
        }
        .chartXAxis {
            AxisMarks(position: .top) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisValueLabel()
            }
        }
        .chartXScale(domain: adjustedXAxisRange)
    }

    // Adjusted X-Axis Range
    private var adjustedXAxisRange: ClosedRange<Double> {
        let maxChange = filteredData.flatMap { crypto in
            selectedTimeframes.map { timeframe in
                abs(timeframe == .oneHour ? crypto.change1h :
                    timeframe == .twentyFourHour ? crypto.change24h :
                    crypto.change7d)
            }
        }.max() ?? 5.0

        return -maxChange...maxChange
    }

    // Filtered Data
    private var filteredData: [ChartData] {
        cryptos
    }
}


// MARK: - SwiftUI Preview
struct StatisticsGraphView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsGraphView(cryptos: [
            ChartData(cryptoName: "Bitcoin", change1h: -3.4, change24h: 2.1, change7d: 5.3),
            ChartData(cryptoName: "Ethereum", change1h: 3.2, change24h: -1.7, change7d: 4.2),
            ChartData(cryptoName: "Ripple", change1h: -3.3, change24h: 1.2, change7d: -2.4),
            ChartData(cryptoName: "Litecoin", change1h: 3.4, change24h: 4.0, change7d: -1.8),
            ChartData(cryptoName: "Dogecoin", change1h: 1.3, change24h: -2.1, change7d: 3.9)
        ])
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
