import SwiftUI
import Foundation

struct StreakFreezeSuccessView: View {
    @Binding var showAnimation: Bool
    var onCompletion: () -> Void
    
    // Animation states
    @State private var showIceCrystals: Bool = false
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0
    @State private var shieldOffset: CGFloat = 200
    @State private var shieldOpacity: Double = 0
    @State private var textOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissAnimation()
                }
            
            // Main card
            VStack(spacing: 20) {
                // Shield and ice animation
                ZStack {
                    // Shield emoji
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .zIndex(1)
                    
                    // Ice crystals animation
                    ForEach(0..<8) { i in
                        Image(systemName: "snowflake")
                            .font(.system(size: 30))
                            .foregroundColor(.cyan)
                            .offset(y: shieldOffset)
                            .rotationEffect(.degrees(Double(i) * 45))
                            .opacity(shieldOpacity)
                            .zIndex(0)
                    }
                }
                .padding(.top, 30)
                
                Text("Streak Freeze Active!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .opacity(textOpacity)
                
                Text("Your streak is protected for today.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textSecondary)
                    .opacity(textOpacity)
                
                Text("If you miss your daily goal")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .padding(.top, 10)
                    .opacity(textOpacity)
                
                HStack(alignment: .center) {
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("Your streak will be safe")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.blue)
                }
                .opacity(textOpacity)
                .padding(.top, -5)
                
                // Done button
                Button(action: {
                    dismissAnimation()
                }) {
                    Text("Got it!")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(25)
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
                .opacity(textOpacity)
            }
            .frame(width: 300)
            .background(Color.background)
            .cornerRadius(20)
            .shadow(radius: 10)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
            
            // Ice crystals effect
            if showIceCrystals {
                IceCrystalsView()
            }
        }
        .onAppear {
            animateIn()
        }
    }
    
    private func animateIn() {
        // Sequence of animations
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
            cardScale = 1.0
            cardOpacity = 1
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            shieldOffset = 0
            shieldOpacity = 1
            showIceCrystals = true
        }
        
        withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
            textOpacity = 1
        }
    }
    
    private func dismissAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            cardOpacity = 0
            cardScale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showAnimation = false
            onCompletion()
        }
    }
}

struct IceCrystalsView: View {
    
    let colors: [Color] = [.blue, .cyan, .teal, .mint, .white]
    let symbols = ["snowflake", "circle.fill", "drop.fill", "sparkle"]
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { i in
                IceCrystal(
                    color: colors.randomElement()!,
                    symbol: symbols.randomElement()!,
                    position: randomPosition(),
                    angle: Double.random(in: 0...360),
                    size: CGFloat.random(in: 10...25)
                )
            }
        }
    }
    
    private func randomPosition() -> CGPoint {
        return CGPoint(
            x: CGFloat.random(in: -150...150),
            y: CGFloat.random(in: -300...50)
        )
    }
}

struct IceCrystal: View {
    let color: Color
    let symbol: String
    let position: CGPoint
    let angle: Double
    let size: CGFloat
    
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size))
            .foregroundColor(color)
            .rotationEffect(.degrees(isAnimating ? angle + 360 : angle))
            .position(
                x: 150 + position.x,
                y: 150 + (isAnimating ? position.y + 400 : position.y)
            )
            .opacity(isAnimating ? 0 : 1)
            .onAppear {
                withAnimation(
                    Animation
                        .easeOut(duration: Double.random(in: 2...4))
                        .delay(Double.random(in: 0...0.5))
                ) {
                    isAnimating = true
                }
            }
    }
}

struct StreakFreeze_Previews: PreviewProvider {
    static var previews: some View {
        StreakFreezeSuccessView(showAnimation: .constant(true), onCompletion: { })
    }
}
