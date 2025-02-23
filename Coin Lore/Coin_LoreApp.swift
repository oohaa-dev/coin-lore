import SwiftUI
import SwiftData

@main
struct Coin_LoreApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false // Store dark mode preference

    var body: some Scene {
        WindowGroup {
            SplashView()
                .preferredColorScheme(isDarkMode ? .dark : .light) // Apply dark mode setting
        }
    }
}
