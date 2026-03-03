import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void
    
    @State private var animateTitle = false
    @State private var animateBody = false
    @State private var animateButton = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.backgroundStart, Theme.backgroundEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            StarsOverlay()
                .opacity(0.5)
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Not all thoughts")
                    Text("deserve your")
                    Text("attention.")
                        .foregroundColor(Theme.thoughtGlow)
                        .shadow(color: Theme.thoughtGlow, radius: 10)
                }
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(animateTitle ? 1 : 0)
                .scaleEffect(animateTitle ? 1 : 0.9)
                .blur(radius: animateTitle ? 0 : 10)
                
                Text("Watch your worries float through the cosmos. Choose which ones to release, and let the rest fade into darkness.")
                    .font(.body)
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
                    .opacity(animateBody ? 1 : 0)
                    .offset(y: animateBody ? 0 : 20)
                
                Spacer()
                
                Button(action: onFinish) {
                    Text("Begin Your Journey")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Theme.thoughtBubbleFill, Theme.thoughtBubbleFill.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Theme.thoughtGlow.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: Theme.thoughtGlow.opacity(0.4), radius: 20, y: 10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .opacity(animateButton ? 1 : 0)
                .offset(y: animateButton ? 0 : 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                animateTitle = true
            }
            withAnimation(.easeOut(duration: 1.0).delay(0.8)) {
                animateBody = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2)) {
                animateButton = true
            }
        }
    }
}
