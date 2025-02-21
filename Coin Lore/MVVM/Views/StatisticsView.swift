import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    
    init() {
        print("🚀 StatisticsView is being initialized")
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading statistics...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(viewModel.chartData) { data in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(data.cryptoName)
                                        .font(.headline)
                                    
                                    HStack(spacing: 16) {
                                        BarView(value: data.change1h, label: "1h", color: .blue)
                                        BarView(value: data.change24h, label: "24h", color: .green)
                                        BarView(value: data.change7d, label: "7d", color: .orange)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        print("🔄 StatisticsView: Refreshing statistics")
                        viewModel.fetchStatistics()
                    }
                }
            }
            .navigationTitle("Statistics")
            .onAppear {
                print("👀 StatisticsView: onAppear triggered, fetching statistics")
                viewModel.fetchStatistics()
            }
        }
    }
}


struct BarView: View {
    let value: Double
    let label: String
    let color: Color
    
    // Scale the bar height (adjust the factor as needed)
    var barHeight: CGFloat {
        return CGFloat(max(10, min(abs(value) * 3, 100)))
    }
    
    var body: some View {
        VStack {
            // The bar represents the absolute percentage change.
            Rectangle()
                .fill(color)
                .frame(width: 20, height: barHeight)
            
            Text(label)
                .font(.caption)
        }
    }
}
