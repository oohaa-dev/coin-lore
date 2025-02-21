import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var rotationAngle = 0.0

    var body: some View {
        if isActive {
            TabsView() // Navigate to the main TabsView after the splash screen
        } else {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 20) { // Add spacing between elements
                    Image(systemName: "globe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAngle))
                        .onAppear {
                            startRotationAnimation() // Start the animation
                        }

                    Text("NewsApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                // Delay before transitioning to TabsView
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }

    // Helper function for rotation animation
    private func startRotationAnimation() {
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
