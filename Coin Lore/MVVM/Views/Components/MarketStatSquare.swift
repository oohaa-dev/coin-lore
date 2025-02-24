import SwiftUI

struct MarketStatSquare: View {
    let title: String
    let value: String
    let isStale: Bool
    let size: CGSize
    
    var body: some View {
        VStack {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(isStale ? Color(red: 0.6, green: 0, blue: 0) : .primary)
            Spacer()
        }
        .frame(width: size.width, height: size.height)
        .background(Rectangle().fill(Color(.systemBackground)).border(Color.gray.opacity(0.3), width: 1))
    }
}
