import SwiftUI

struct TabsView: View {
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
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Statistikk")
                }
            SettingsView()
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
