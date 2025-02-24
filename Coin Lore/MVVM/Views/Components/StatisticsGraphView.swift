import SwiftUI
import Charts

struct StatisticsGraphView: View {
    @State private var selectedTimeframes: Set<Timeframe> = [.oneHour, .twentyFourHour, .sevenDays]
    var cryptos: [ChartData]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MultiTimeframeToggleView(selectedTimeframes: $selectedTimeframes)
            
            ScrollView{
                VStack {
                    
                    chartView
                }
                .frame(height: CGFloat(cryptos.count) * 50)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.horizontal)
    }

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
                    .position(by: .value("Timeframe", timeframe.rawValue))
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

    private var filteredData: [ChartData] {
        cryptos
    }
}
