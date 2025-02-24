import SwiftUI

struct TabsView: View {
    @StateObject private var errorHandler = ErrorHandler() // ✅ Centralized Error Handler
    @StateObject private var statisticsViewModel: StatisticsViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false // Persist dark mode setting

    // ✅ Initialize `@StateObject` inline to avoid referencing `self`
    init() {
        let errorHandler = ErrorHandler() // ✅ Shared error handler instance
        let statsVM = StatisticsViewModel(errorHandler: errorHandler)
        _statisticsViewModel = StateObject(wrappedValue: statsVM)
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(statisticsViewModel: statsVM, errorHandler: errorHandler))
    }

    var body: some View {
        TabView {
            MainView(errorHandler: errorHandler) // ✅ Pass ErrorHandler to all views
                .tabItem {
                    Image(systemName: "square.grid.3x3.fill")
                    Text("Dashboard")
                }

            MarketView(errorHandler: errorHandler) // ✅ Pass ErrorHandler
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Market")
                }

            StatisticsView(viewModel: statisticsViewModel, errorHandler: errorHandler) // ✅ Pass ErrorHandler
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Statistics")
                }

            SettingsView(viewModel: settingsViewModel, errorHandler: errorHandler) // ✅ Pass ErrorHandler
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light) // Apply theme globally in TabsView
        .overlay(
            Group {
                if let error = errorHandler.currentError {
                    ErrorView(message: error.localizedDescription)
                        .padding()
                        .transition(.slide)
                }
            }
        )

    }
}

// MARK: - Preview
struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
