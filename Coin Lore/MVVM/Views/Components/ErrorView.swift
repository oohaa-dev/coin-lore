import SwiftUI

struct ErrorView: View {
    let message: String

    var body: some View {
        VStack {
            Text("⚠️ Error")
                .font(.headline)
                .foregroundColor(.red)

            Text(message)
                .font(.callout)
                .foregroundColor(.white)
                .padding()
                .background(Color.red.opacity(0.8))
                .cornerRadius(8)
                .padding(.horizontal)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .padding()
    }
}
