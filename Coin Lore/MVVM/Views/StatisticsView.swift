import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @State private var showAnimation = false
    @State private var emojiPositions: [CGFloat] = []
    @State private var showCurrencySelection = false

    var body: some View {
        ZStack {
            NavigationView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Statistics")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Group {
                        if viewModel.isLoading {
                            ProgressView("Loading statistics...")
                        } else if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            StatisticsGraphView(cryptos: viewModel.chartData.filter { viewModel.selectedCurrencies.contains($0.cryptoName) })
                                .padding()
                        }
                    }
                    .refreshable {
                        viewModel.fetchStatistics()
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationBarHidden(true)
                .onAppear {
                    viewModel.fetchStatistics()
                }
            }
            .sheet(isPresented: $showCurrencySelection) {
                CurrencySelectionList(
                    viewModel: viewModel, // Pass the StatisticsViewModel instance
                    onDone: {
                        showCurrencySelection = false
                    }
                )
            }

            // Floating Add Button in Bottom-Right Corner
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AddCurrencyButton {
                        viewModel.fetchStatistics() // Ensure fresh data before showing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Slight delay for UI update
                            showCurrencySelection = true
                        }
                    }
                    .padding(.bottom, 20) // Adjust to position above the tab bar
                    .padding(.trailing, 20)
                }
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
        .onChange(of: viewModel.selectedCurrencies) { _ in
            viewModel.fetchStatistics() // Reload data when selection changes
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
