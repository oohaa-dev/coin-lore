import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Currency Selection
                Section(header: Text("Valuta")) {
                    Picker("Velg valuta", selection: $viewModel.selectedCurrency) {
                        ForEach(viewModel.exchangeRates.keys.sorted(), id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Makes it a dropdown menu
                    .onChange(of: viewModel.selectedCurrency) { newCurrency in
                        viewModel.updateSelectedCurrency(newCurrency) // 🔥 Save selection + update rate
                    }

                    HStack {
                        Text("Valutakurs (\(viewModel.selectedCurrency)/USD):")
                        Spacer()
                        Text(viewModel.currencyRate, format: .number)
                            .foregroundColor(.blue)
                            .font(.headline)
                    }
                }

                // MARK: - Custom Fake Currency
                Section(header: Text("Tilpasset Valuta")) {
                    Toggle("Bruk tilpasset valuta", isOn: $viewModel.useCustomCurrency)
                        .onChange(of: viewModel.useCustomCurrency) { _ in
                            viewModel.updateCustomCurrency()
                        }

                    TextField("Valutanavn (3 bokstaver)", text: $viewModel.customCurrencyCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!viewModel.useCustomCurrency)

                    TextField("Valutakurs", value: $viewModel.customCurrencyRate, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .disabled(!viewModel.useCustomCurrency)
                }

                // MARK: - Emoji Animation Threshold
                Section(header: Text("Emoji-animasjon")) {
                    VStack {
                        Text("Terskel for animasjon: \(Int(viewModel.emojiThreshold))%")
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

                    Text("Når prisendringer overstiger denne verdien, vises 💰-animasjon.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

            }
            .navigationTitle("Innstillinger")
            .onAppear {
                viewModel.fetchExchangeRates() // Fetch rates when view appears
            }
        }
    }
}
