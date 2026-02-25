import SwiftUI

struct InferenceScreen: View {
    // MARK: - State & Dependencies
    @ObservedObject var dataset: DatasetModel
    @StateObject private var classifier = ObjectClassifier()
    
    @State private var tapLocation: CGPoint = CGPoint(x: 200, y: 300)
    @State private var showInspector = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 1. Live AR Layer (Hardware Accelerated)
            ARInferenceView(classifier: classifier)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { location in
                    handleSpatialTap(at: location)
                }
            
            // 2. Liquid Glass Overlay Layer
            GeometryReader { geo in
                if showInspector {
                    spatialAnchor(at: tapLocation)
                    
                    PredictionBubble(
                        label: classifier.prediction,
                        confidence: classifier.confidence,
                        allProbabilities: classifier.allProbabilities
                    )
                    .position(calculateBubblePosition(tapPos: tapLocation, screen: geo.size))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .zIndex(1)
                }
            }
            
            // 3. Status Indicators
            VStack {
                topStatusBar
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Spatial Vision")
                    .font(.system(.headline, design: .rounded))
            }
        }
    }
}

// MARK: - View Components

extension InferenceScreen {
    @ViewBuilder
    private func spatialAnchor(at position: CGPoint) -> some View {
        Circle()
            .fill(Color.blue.gradient)
            .frame(width: 16, height: 16)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(color: Color.blue.opacity(0.3), radius: 8)
            .position(position)
            .zIndex(2)
            .modifier(PulseAnimationModifier())
    }
    
    private var topStatusBar: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(classifier.prediction.contains("Ready") ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(classifier.prediction.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Material.ultraThin, in: Capsule())
            .padding(.top, 10)
        }
    }
}

// MARK: - Layout Logic

extension InferenceScreen {
    private func handleSpatialTap(at location: CGPoint) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            tapLocation = location
            showInspector = true
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func calculateBubblePosition(tapPos: CGPoint, screen: CGSize) -> CGPoint {
        let bubbleWidth: CGFloat = 280
        let bubbleHeight: CGFloat = 300
        let padding: CGFloat = 40
        
        var x = tapPos.x
        let minX = (bubbleWidth / 2) + 20
        let maxX = screen.width - (bubbleWidth / 2) - 20
        x = max(minX, min(x, maxX))
        
        var y = tapPos.y
        // Smart flip: If tap is bottom half, show bubble above. Else, show below.
        if tapPos.y < (screen.height / 2) {
            y += (bubbleHeight / 2) + padding + 20
        } else {
            y -= (bubbleHeight / 2) + padding + 20
        }
        
        // Final screen bounds clamping
        let minY = (bubbleHeight / 2) + padding
        let maxY = screen.height - (bubbleHeight / 2) - padding
        y = max(minY, min(y, maxY))
        
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Animation Helper

struct PulseAnimationModifier: ViewModifier {
    @State private var isAnimating = false
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .opacity(isAnimating ? 0.7 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}
