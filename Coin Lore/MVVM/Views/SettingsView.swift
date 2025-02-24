import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject private var errorHandler: ErrorHandler
    
    init(viewModel: SettingsViewModel, errorHandler: ErrorHandler) {
        self.viewModel = viewModel
        self.errorHandler = errorHandler
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                
                // MARK: - Currency Selection
                Section(header: Text("Currency")) {
                    Picker("Choose app currency", selection: $viewModel.selectedCurrency) {
                        ForEach(viewModel.exchangeRates.keys.sorted(), id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: viewModel.selectedCurrency) { newCurrency in
                        viewModel.updateSelectedCurrency(newCurrency)
                    }
                    
                    HStack {
                        Text("Currency exchange rate (\(viewModel.selectedCurrency)/USD):")
                        Spacer()
                        Text(viewModel.currencyRate, format: .number)
                            .foregroundColor(.blue)
                            .font(.headline)
                    }
                }
                
                // MARK: - Custom Fake Currency
                Section(header: Text("Custom Currency")) {
                    Toggle("Use a custom currency", isOn: $viewModel.useCustomCurrency)
                        .onChange(of: viewModel.useCustomCurrency) { _ in
                            viewModel.updateCustomCurrency()
                        }
                    
                    TextField("Currency code (3 letters)", text: $viewModel.customCurrencyCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!viewModel.useCustomCurrency)
                    
                    TextField("Currency value", value: $viewModel.customCurrencyRate, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .disabled(!viewModel.useCustomCurrency)
                }
                
                // MARK: - Emoji Animation Threshold
                Section(header: Text("Emoji-animation")) {
                    VStack {
                        Text("Threshold for animation: \(Int(viewModel.emojiThreshold))%")
                            .font(.headline)
                        
                        Slider(
                            value: Binding(
                                get: { Double(viewModel.emojiThreshold) },
                                set: { viewModel.emojiThreshold = Int($0) }
                            ),
                            in: 0...100,
                            step: 1
                        )
                    }
                    
                    
                    // MARK: - Dark Mode Toggle
                    Section() {
                        Toggle("Dark mode", isOn: $viewModel.isDarkMode)
                            .onChange(of: viewModel.isDarkMode) { _ in
                                viewModel.toggleDarkMode()
                            }
                    }
                }
                .navigationTitle("Settings")
                .onAppear {
                    errorHandler.clearError() // ✅ Clear old errors before fetching
                    viewModel.fetchExchangeRates()
                }
            }
        }
    }
}
