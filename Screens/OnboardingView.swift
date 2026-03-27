import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 12) {
                    Text("How To Train A Model")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal)

                    Text("Train an on-device model in three simple steps.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 40)
                }
                
                VStack(spacing: 20) {
                    OnboardingStepRow(
                        icon: "plus.viewfinder",
                        title: "Gather Examples",
                        description: "Add a category and HOLD the capture button to record samples continuously.",
                        color: .blue
                    )
                    
                    OnboardingStepRow(
                        icon: "brain.head.profile",
                        title: "The Training Grounds",
                        description: "Tune your intensity (Epochs) and Batch Size to sharpen your model's senses.",
                        color: .orange
                    )
                    
                    OnboardingStepRow(
                        icon: "arkit",
                        title: "Take Flight in AR",
                        description: "Step into the real world. Point your camera at objects to see your Model in action.",
                        color: .purple
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        hasSeenOnboarding = true
                    }
                }) {
                    Text("Begin")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .background(Color.blue.gradient, in: RoundedRectangle(cornerRadius: 22))
                        .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingStepRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(color.gradient)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                )
        }
    }
}
