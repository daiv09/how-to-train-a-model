import SwiftUI
import CoreML
import Vision
import CoreImage

@MainActor
class ObjectClassifier: ObservableObject {
    // State
    @Published var prediction: String = "Waiting..."
    @Published var confidence: Double = 0.0
    @Published var allProbabilities: [(String, Double)] = []
    
    // Properties
    private var visionModel: VNCoreMLModel?
    private var isPredicting = false
    private let modelURL = URL.documentsDirectory.appending(path: "PersonalizedModel.mlmodel")

    init() {
        loadModel()
    }

    private func loadModel() {
        guard FileManager.default.fileExists(atPath: modelURL.path) else {
            prediction = "Train a model first!"
            return
        }

        Task {
            do {
                let compiledURL = try await MLModel.compileModel(at: self.modelURL)
                let config = MLModelConfiguration()
                config.computeUnits = .all // Leverages iPhone 26 Neural Engine
                
                let mlModel = try MLModel(contentsOf: compiledURL, configuration: config)
                self.visionModel = try VNCoreMLModel(for: mlModel)
                self.prediction = "Ready for AR"
            } catch {
                self.prediction = "Model Error"
            }
        }
    }

    func predict(pixelBuffer: CVPixelBuffer) {
        guard !isPredicting, let model = visionModel else { return }
        isPredicting = true
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let result = try await Task.detached(priority: .userInitiated) { () -> (String, Double, [(String, Double)])? in
                    let request = VNCoreMLRequest(model: model)
                    request.imageCropAndScaleOption = .centerCrop
                    
                    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
                    try handler.perform([request])
                    
                    guard let observations = request.results as? [VNClassificationObservation],
                          let topResult = observations.first else {
                        return nil
                    }
                    
                    return (
                        topResult.identifier,
                        Double(topResult.confidence),
                        observations.prefix(4).map { ($0.identifier, Double($0.confidence)) }
                    )
                }.value
                
                if let (label, conf, probs) = result {
                    self.updateUI(label: label, confidence: conf, probabilities: probs)
                } else {
                    self.isPredicting = false
                }
                
            } catch {
                self.isPredicting = false
            }
        }
    }

    private func updateUI(label: String, confidence: Double, probabilities: [(String, Double)]) {
        self.prediction = label
        self.confidence = confidence
        self.allProbabilities = probabilities
        self.isPredicting = false
    }
}
