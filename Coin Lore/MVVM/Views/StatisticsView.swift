import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @ObservedObject private var errorHandler: ErrorHandler
    @State private var showAnimation = false
    @State private var emojiPositions: [CGFloat] = []
    @State private var showCurrencySelection = false

    init(viewModel: StatisticsViewModel, errorHandler: ErrorHandler) {
        self.viewModel = viewModel
        self.errorHandler = errorHandler
    }

    var body: some View {
        ZStack {
            NavigationView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        // ✅ Centralized Error Handling
                        if let error = errorHandler.currentError as? LocalizedError {
                            ErrorView(message: error.errorDescription ?? "An unknown error occurred.")
                        } else if let error = errorHandler.currentError {
                            ErrorView(message: error.localizedDescription)
                        } else if viewModel.isLoading {
                            ProgressView("Loading statistics...")
                        } else {
                            StatisticsGraphView(cryptos: viewModel.chartData.filter { viewModel.selectedCurrencies.contains($0.cryptoName) })
                                .padding()
                        }
                    }
                    .refreshable {
                        errorHandler.clearError() // ✅ Clear errors on refresh
                        viewModel.fetchStatistics()
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationBarHidden(true)
                .onAppear {
                    errorHandler.clearError() // ✅ Clear old errors before fetching
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
                        errorHandler.clearError() // ✅ Ensure no old errors persist
                        viewModel.fetchStatistics() // Fetch fresh data before showing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Slight delay for UI update
                            showCurrencySelection = true
                        }
                    }
                    .padding(.bottom, 20) // Adjust to position above the tab bar
                    .padding(.trailing, 20)
                }
            }

            // 💰 Emoji Animation
            if showAnimation {
                ForEach(emojiPositions, id: \.self) { position in
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

    // MARK: - Start Emoji Animation
    private func startEmojiAnimation() {
        guard !showAnimation else { return } // Prevent multiple animations

        // Generate random start positions for emojis
        emojiPositions = (0..<10).map { _ in CGFloat.random(in: 0...UIScreen.main.bounds.width) }
        showAnimation = true

        // Stop the animation after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showAnimation = false
            }
        }
    }
}
