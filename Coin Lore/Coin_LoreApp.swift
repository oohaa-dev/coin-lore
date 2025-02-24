import SwiftUI
import SwiftData

@main
struct Coin_LoreApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false 

    var body: some Scene {
        WindowGroup {
            SplashView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
