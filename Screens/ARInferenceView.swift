import SwiftUI
import RealityKit
import ARKit

struct ARInferenceView: UIViewRepresentable {
    @ObservedObject var classifier: ObjectClassifier
    
    func makeUIView(context: Context) -> ARView {
        // 1. Initialize the AR View with ProMotion support for smooth 120fps feed
        let arView = ARView(frame: .zero)
        
        // 2. Configure World Tracking for spatial awareness and table/wall detection
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        // 3. Enable high-frequency session updates
        arView.session.run(config)
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.classifier = classifier
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(classifier: classifier)
    }
    
    // (Session Bridge)
    class Coordinator: NSObject, ARSessionDelegate {
        var classifier: ObjectClassifier
        
        private var lastPredictionTime: TimeInterval = 0
        private let predictionInterval: TimeInterval = 0.15
        
        init(classifier: ObjectClassifier) {
            self.classifier = classifier
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            let currentTime = CACurrentMediaTime()
            
            // 1. Adaptive Throttling: Only proceed if 0.15 seconds have passed
            guard currentTime - lastPredictionTime >= predictionInterval else { return }
            lastPredictionTime = currentTime
            
            // 2. Extract captured image buffer directly from ARKit
            let pixelBuffer = frame.capturedImage
            
            // 3. Concurrency Protection: Capture the classifier locally
            let targetClassifier = self.classifier
            
            Task { @MainActor in
                targetClassifier.predict(pixelBuffer: pixelBuffer)
            }
        }
    }
}
