import SwiftUI
import Combine

struct TrainingClass: Identifiable {
    let id = UUID()
    var label: String
    var images: [UIImage]
}

class DatasetModel: ObservableObject {
    @Published var classes: [TrainingClass] = [
        TrainingClass(label: "Red", images: []),
        TrainingClass(label: "Blue", images: []) // Default classes
    ]
    
    // Select which class we are currently training
    @Published var selectedClassID: UUID?
    
    init() {
        // Auto-select the first class
        selectedClassID = classes.first?.id
    }
    
    func addImage(_ image: UIImage, to classID: UUID) {
        if let index = classes.firstIndex(where: { $0.id == classID }) {
            classes[index].images.insert(image, at: 0) // Add to front for animation
        }
    }
}
