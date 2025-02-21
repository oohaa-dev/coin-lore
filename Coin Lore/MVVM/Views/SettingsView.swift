import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Valuta")) {
                    HStack {
                        Text("Valutakurs (NOK/USD):")
                        Spacer()
                        TextField("F.eks. 10.50", value: $viewModel.currencyRate, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: viewModel.currencyRate) { newValue in
                                viewModel.updateCurrencyRate(newValue)
                            }
                    }
                }

                Section(header: Text("Emoji-animasjon")) {
                    HStack {
                        Text("Terskel for animasjon:")
                        Spacer()
                        Stepper("\(viewModel.emojiThreshold)%", value: $viewModel.emojiThreshold, in: 0...100, step: 1) { _ in
                            viewModel.updateEmojiThreshold(viewModel.emojiThreshold)
                        }
                    }
                    Text("Når prisendringer overstiger denne verdien, vises 💰-animasjon.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Innstillinger")
        }
    }
}
