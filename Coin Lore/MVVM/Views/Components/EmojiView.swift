import SwiftUI

struct EmojiView: View {
    let xPosition: CGFloat
    @State private var yOffset: CGFloat = -100

    var body: some View {
        Text("💰")
            .font(.largeTitle)
            .position(x: xPosition, y: yOffset)
            .onAppear {
                withAnimation(Animation.easeIn(duration: 2).repeatCount(1, autoreverses: false)) {
                    yOffset = UIScreen.main.bounds.height
                }
            }
    }
}
