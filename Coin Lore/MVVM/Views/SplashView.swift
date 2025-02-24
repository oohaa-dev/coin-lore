import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var coinRotation = 0.0
    @State private var coinFlip = false

    var body: some View {
        if isActive {
            TabsView()
        } else {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack {
                    Image(systemName: "bitcoinsign.circle.fill")
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
        withAnimation(.easeInOut(duration: 0.7).repeatCount(1, autoreverses: false)) {
            coinRotation = 360
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation {
                coinFlip = true
            }
        }
    }

    private func startSplashScreenTransition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isActive = true
            }
        }
    }
}
