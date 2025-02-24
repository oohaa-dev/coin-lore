import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var coinRotation = 0.0
    @State private var coinFlip = false

    var body: some View {
        if isActive {
            TabsView() // Main app screen
        } else {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack {
                    // Coin Toss Animation
                    Image(systemName: "bitcoinsign.circle.fill") // You can replace this with a custom coin image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(coinRotation))
                        .onAppear {
                            startCoinTossAnimation()
                        }

                    Text("Coin Lore")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .opacity(coinFlip ? 1 : 0)
                }
            }
            .onAppear {
                startSplashScreenTransition()
            }
        }
    }

    private func startCoinTossAnimation() {
        // Animate the coin toss
        withAnimation(.easeInOut(duration: 0.7).repeatCount(1, autoreverses: false)) {
            coinRotation = 360
        }

        // After animation finishes, show the text and navigate to main view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation {
                coinFlip = true
            }
        }
    }

    private func startSplashScreenTransition() {
        // Transition to the next screen after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isActive = true
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
