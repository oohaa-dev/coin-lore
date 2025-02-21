import SwiftUI

struct TabsView: View {
    @StateObject private var statisticsViewModel = StatisticsViewModel()
    @StateObject private var settingsViewModel: SettingsViewModel

    init() {
        let statsVM = StatisticsViewModel()
        _statisticsViewModel = StateObject(wrappedValue: statsVM)
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(statisticsViewModel: statsVM))
    }

    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Hjem")
                }
            
            MarketView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Marked")
                }
            
            StatisticsView(viewModel: statisticsViewModel)
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Statistikk")
                }
            
            SettingsView(viewModel: settingsViewModel)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Innstillinger")
                }
        }
    }
}

// Move this **outside** of TabsView struct
struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
