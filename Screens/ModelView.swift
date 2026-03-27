import SwiftUI

struct ModelView: View {
    var accuracy: Double
    var isTraining: Bool
    
    @State private var rotation1: Double = 0
    @State private var rotation2: Double = 0
    @State private var rotation3: Double = 0
    @State private var pulse: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(modelColor.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .blur(radius: 25)
                    .scaleEffect(pulse)
                
                Circle()
                    .stroke(
                        LinearGradient(colors: [modelColor, .clear], startPoint: .top, endPoint: .bottom),
                        lineWidth: 3
                    )
                    .frame(width: 160, height: 160)
                    .rotation3DEffect(.degrees(rotation1), axis: (x: 1, y: 1, z: 0))
                
                Circle()
                    .stroke(
                        LinearGradient(colors: [modelColor.opacity(0.8), .clear], startPoint: .leading, endPoint: .trailing),
                        lineWidth: 3
                    )
                    .frame(width: 130, height: 130)
                    .rotation3DEffect(.degrees(rotation2), axis: (x: 1, y: 0, z: 1))
                
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                    Circle()
                        .stroke(modelColor.gradient, lineWidth: 2)
                }
                .frame(width: 100, height: 100)
                .rotation3DEffect(.degrees(rotation3), axis: (x: 0, y: 1, z: 1))
                
                VStack {
                    Text(accuracy, format: .percent.precision(.fractionLength(0)))
                        .font(.system(.title2, design: .rounded).bold())
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
            }
            .frame(height: 220)
            
            VStack(spacing: 6) {
                Text(statusText)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(isTraining ? "Model is processing features..." : "Model state: Ready")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { startAnimations() }
        .onChange(of: isTraining) { _ in startAnimations() }
    }
}

// Properties & Logic
extension ModelView {
    var modelColor: Color {
        if accuracy < 0.4 { return .red }
        if accuracy < 0.8 { return .orange }
        return .cyan
    }
    
    var statusText: String {
        if accuracy < 0.1 { return "Initializing Sensor..." }
        if accuracy < 0.5 { return "Analyzing Patterns..." }
        if accuracy < 0.85 { return "Optimizing Weights..." }
        return "Model Converged"
    }
    
    func startAnimations() {
        withAnimation(.linear(duration: isTraining ? 1.2 : 5.0).repeatForever(autoreverses: false)) {
            rotation1 = 360
        }
        withAnimation(.linear(duration: isTraining ? 1.8 : 7.0).repeatForever(autoreverses: false)) {
            rotation2 = -360
        }
        withAnimation(.linear(duration: isTraining ? 0.9 : 4.0).repeatForever(autoreverses: false)) {
            rotation3 = 180
        }
        
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulse = 1.15
        }
    }
}
