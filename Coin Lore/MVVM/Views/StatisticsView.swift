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
                        errorHandler.clearError()
                        viewModel.fetchStatistics()
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationBarHidden(true)
                .onAppear {
                    errorHandler.clearError()
                    viewModel.fetchStatistics()
                }
            }
            .sheet(isPresented: $showCurrencySelection) {
                CurrencySelectionList(
                    viewModel: viewModel,
                    onDone: {
                        showCurrencySelection = false
                    }
                )
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AddCurrencyButton {
                        errorHandler.clearError()
                        viewModel.fetchStatistics()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showCurrencySelection = true
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.trailing, 20)
                }
            }

            if showAnimation {
                ForEach(emojiPositions, id: \.self) { position in
                    EmojiView(xPosition: position)
                }
            }
        }
        .onChange(of: viewModel.shouldAnimate) { oldValue, newValue in
            if newValue {
                startEmojiAnimation()
            }
        }
        .onChange(of: viewModel.selectedCurrencies) {
            viewModel.fetchStatistics()
        }
    }

    private func startEmojiAnimation() {
        guard !showAnimation else { return }

        emojiPositions = (0..<10).map { _ in CGFloat.random(in: 0...UIScreen.main.bounds.width) }
        showAnimation = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showAnimation = false
            }
        }
    }
}
