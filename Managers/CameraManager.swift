import SwiftUI
@preconcurrency import AVFoundation
import Combine

@MainActor
class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var currentFrame: CGImage?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let ciContext = CIContext(options: [.cacheIntermediates: false])
    private let sessionQueue = DispatchQueue(label: "com.app.camera.processing", qos: .userInteractive)
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        captureSession.beginConfiguration()
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.sessionPreset = .hd1280x720
        captureSession.commitConfiguration()
        
        Task.detached(priority: .userInitiated) { [weak self] in
            await self?.captureSession.startRunning()
        }
    }
    
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: buffer).oriented(.right)
        
        if let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) {
            Task { @MainActor [weak self] in
                self?.currentFrame = cgImage
            }
        }
    }
    
    func captureCurrentThumb() -> UIImage? {
        guard let cgImage = currentFrame else { return nil }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 224, height: 224), format: format)
        return renderer.image { _ in
            UIImage(cgImage: cgImage).draw(in: CGRect(x: 0, y: 0, width: 224, height: 224))
        }
    }
}
