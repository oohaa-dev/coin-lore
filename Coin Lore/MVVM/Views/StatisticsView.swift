import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @State private var showAnimation = false
    @State private var emojiPositions: [CGFloat] = []
    @State private var showCurrencySelection = false
    @State private var selectedCurrencies: Set<String> = []

    var body: some View {
        ZStack {
            NavigationView {
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading statistics...")
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        VStack {
                            AddCurrencyButton {
                                showCurrencySelection = true
                            }
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    StatisticsGraphView(cryptos: viewModel.chartData.filter { selectedCurrencies.contains($0.cryptoName) })
                                        .padding()

                                }
                                .padding(.vertical)
                            }
                            .refreshable {
                                print("🔄 StatisticsView: Refreshing statistics")
                                viewModel.fetchStatistics()
                            }
                        }
                    }
                }
                .navigationTitle("Statistics")
                .onAppear {
                    print("👀 StatisticsView: onAppear triggered, fetching statistics")
                    viewModel.fetchStatistics()
                }
            }
            .sheet(isPresented: $showCurrencySelection) {
                CurrencySelectionList(
                    selectedCurrencies: $selectedCurrencies,
                    availableCurrencies: viewModel.cryptoStats.map { $0.name },
                    onDone: {
                        showCurrencySelection = false
                    }
                )
            }

            // 💰 Emoji-animasjon
            if showAnimation {
                ForEach(emojiPositions, id: \ .self) { position in
                    EmojiView(xPosition: position)
                }
            }
        }
        .onChange(of: viewModel.shouldAnimate) { newValue in
            if newValue {
                startEmojiAnimation()
            }
        }
    }

    // MARK: - Start Emoji Animasjon
    private func startEmojiAnimation() {
        guard !showAnimation else { return } // Unngå at animasjonen starter flere ganger

        // Generer tilfeldige startposisjoner for emojiene
        emojiPositions = (0..<10).map { _ in CGFloat.random(in: 0...UIScreen.main.bounds.width) }
        showAnimation = true

        // Stopp animasjonen etter 3 sekunder
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showAnimation = false
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
