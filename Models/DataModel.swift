import SwiftUI
import Combine

// Core Data Structures
struct HistoryPoint: Identifiable, Equatable, Sendable {
    let id = UUID()
    let epoch: Int
    let accuracy: Double
}

struct TrainingClass: Identifiable {
    let id = UUID()
    var label: String
    var images: [UIImage]
}

// Managers
class DatasetModel: ObservableObject {
    @Published var classes: [TrainingClass] = []
    @Published var selectedClassID: UUID?
    
    init() {}

    func addImage(_ image: UIImage, to classID: UUID) {
        guard let index = classes.firstIndex(where: { $0.id == classID }) else { return }
        classes[index].images.insert(image, at: 0)
    }
}

class TrainingConfiguration: ObservableObject {
    @Published var selectedIntensity: TrainingIntensity = .standard
    @Published var learningStyle: LearningStyle = .careful
    @Published var selectedBatchSize: BatchSize = .medium
    
    @Published var momentum: Double = 0.90
    @Published var dropoutRate: Double = 0.30
    @Published var validationSplit: Double = 0.20
    
    func resetDefaults() {
        selectedIntensity = .standard
        learningStyle = .careful
        selectedBatchSize = .medium
        momentum = 0.90
        dropoutRate = 0.30
        validationSplit = 0.20
    }
}

// Enumerations

enum TrainingIntensity: Int, CaseIterable, Identifiable {
    case quick = 25
    case standard = 50
    case deep = 75
    case master = 100
    
    var id: Int { rawValue }
    
    var icon: String {
        switch self {
        case .quick: return "hare.fill"
        case .standard: return "figure.walk"
        case .deep: return "water.waves"
        case .master: return "brain.head.profile"
        }
    }
    
    var title: String {
        switch self {
        case .quick: return "Quick"
        case .standard: return "Standard"
        case .deep: return "Deep"
        case .master: return "Mastery"
        }
    }
}

enum LearningStyle: String, CaseIterable, Identifiable {
    case careful, fast
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .careful: return "Careful"
        case .fast: return "Fast"
        }
    }
    
    var subtitle: String {
        switch self {
        case .careful: return "Low L.R."
        case .fast: return "High L.R."
        }
    }
    
    var icon: String {
        switch self {
        case .careful: return "eyeglasses"
        case .fast: return "flame.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .careful: return .orange
        case .fast: return .red
        }
    }
}

enum BatchSize: Int, CaseIterable, Identifiable {
    case small = 8
    case medium = 32
    case large = 128
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
    
    var icon: String {
        switch self {
        case .small: return "square.grid.2x2.fill"
        case .medium: return "square.grid.3x3.fill"
        case .large: return "square.grid.4x3.fill"
        }
    }
}

// Architecture
struct InfoRowData: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let desc: String
}

struct ParameterInfo: Identifiable {
    let id = UUID()
    let navTitle: String
    let question: String
    let answer: String
    let options: [InfoRowData]
    let proTip: String?
}

struct InfoDataStore {
    static let epochs = ParameterInfo(
        navTitle: "Intensity Guide",
        question: "What is an Epoch?",
        answer: "An epoch is one full cycle where the Model looks at every image in your dataset. More cycles generally lead to better recognition.",
        options: TrainingIntensity.allCases.map { intensity in
            InfoRowData(
                icon: intensity.icon,
                color: .blue,
                title: intensity.title,
                desc: "Training cycles set to \(intensity.rawValue)."
            )
        },
        proTip: "Too many epochs on a small dataset can cause 'Overfitting', where the Model memorizes images instead of learning patterns."
    )
    
    static let batchSize = ParameterInfo(
        navTitle: "Batch Size Guide",
        question: "What is Batch Size?",
        answer: "Batch size is the number of images the Model looks at before updating its knowledge.",
        options: BatchSize.allCases.map { size in
            InfoRowData(
                icon: size.icon,
                color: .green,
                title: size.title,
                desc: "Processes \(size.rawValue) images per update step."
            )
        },
        proTip: "A medium batch size (32) is almost always the best starting point for a balanced training session."
    )
    
    static let learningStyle = ParameterInfo(
        navTitle: "Learning Style",
        question: "What is Learning Rate?",
        answer: "This controls the 'Learning Rate' - how big of a jump the Model makes when it learns something new.",
        options: LearningStyle.allCases.map { style in
            InfoRowData(
                icon: style.icon,
                color: style.color,
                title: style.title,
                desc: style.subtitle
            )
        },
        proTip: "Start with 'Careful' if your training accuracy is jumping up and down wildly."
    )
}
