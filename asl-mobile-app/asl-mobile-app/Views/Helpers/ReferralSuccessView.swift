//
//  ReferralSuccessView.swift
//  asl-mobile-app
//
//  Created by vlad.achim on 09.05.2025.
//

import SwiftUI
import Foundation

struct ReferralSuccessView: View {
    @Binding var showAnimation: Bool
    var onCompletion: () -> Void
    
    // Animation states
    @State private var showConfetti: Bool = false
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0
    @State private var coinOffset: CGFloat = 200
    @State private var coinOpacity: Double = 0
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
                // Emoji and coins animation
                ZStack {
                    // Celebration emoji
                    Text("🎉")
                        .font(.system(size: 60))
                        .zIndex(1)
                    
                    // Coins animation
                    ForEach(0..<8) { i in
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.yellow)
                            .offset(y: coinOffset)
                            .rotationEffect(.degrees(Double(i) * 45))
                            .opacity(coinOpacity)
                            .zIndex(0)
                    }
                }
                .padding(.top, 30)
                
                Text("Referral Bonus!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.main)
                    .opacity(textOpacity)
                
                Text("Thanks for using a friend's referral code.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textSecondary)
                    .opacity(textOpacity)
                
                Text("You've received")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .padding(.top, 10)
                    .opacity(textOpacity)
                
                HStack(alignment: .center) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                    
                    Text("100")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .opacity(textOpacity)
                .padding(.top, -5)
                
                Text("in your account")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .padding(.top, -5)
                    .opacity(textOpacity)
                
                // Done button
                Button(action: {
                    dismissAnimation()
                }) {
                    Text("Awesome!")
                        .fontWeight(.semibold)
                        .foregroundColor(.textSecondary)
                        .frame(width: 200, height: 50)
                        .background(.main)
                        .cornerRadius(25)
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
                .opacity(textOpacity)
                .foregroundColor(.main)
            }
            .frame(width: 300)
            .background(Color.background)
            .cornerRadius(20)
            .shadow(radius: 10)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
            
            // Confetti
            if showConfetti {
                ConfettiView()
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
            coinOffset = 0
            coinOpacity = 1
            showConfetti = true
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

struct ConfettiView: View {
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    let symbols = ["star.fill", "circle.fill", "heart.fill", "dollarsign.circle.fill"]
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { i in
                ConfettiSymbol(
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

struct ConfettiSymbol: View {
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


struct Referral_Previews: PreviewProvider {
    static var previews: some View {
        ReferralSuccessView(showAnimation: .constant(true), onCompletion: { })
    }
}
