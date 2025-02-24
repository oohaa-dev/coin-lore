import SwiftUI

struct TabsView: View {
    @StateObject private var errorHandler = ErrorHandler() 
    @StateObject private var statisticsViewModel: StatisticsViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    init() {
        let errorHandler = ErrorHandler()
        let statsVM = StatisticsViewModel(errorHandler: errorHandler)
        _statisticsViewModel = StateObject(wrappedValue: statsVM)
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(statisticsViewModel: statsVM, errorHandler: errorHandler))
    }

    var body: some View {
        TabView {
            MainView(errorHandler: errorHandler)
                .tabItem {
                    Image(systemName: "square.grid.3x3.fill")
                    Text("Dashboard")
                }

            MarketView(errorHandler: errorHandler)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Market")
                }

            StatisticsView(viewModel: statisticsViewModel, errorHandler: errorHandler)
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Statistics")
                }

            SettingsView(viewModel: settingsViewModel, errorHandler: errorHandler)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
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

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
