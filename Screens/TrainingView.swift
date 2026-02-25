import SwiftUI

struct TrainingView: View {
    // Dependencies
    @EnvironmentObject var dataset: DatasetModel
    @StateObject private var manager = TrainingManager()
    @StateObject private var config = TrainingConfiguration()
    
    // State
    @State private var activeSheetData: ParameterInfo?
    
    // Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. Model Status (Top)
                ModelView(accuracy: manager.accuracy, isTraining: manager.isTraining)
                
                // 2. Training Controls / Progress (Now in Middle)
                if !manager.isTraining {
                    controlsSection
                } else {
                    trainingProgressSection
                }
                
                // 3. Training Insights (Now at Bottom)
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Label("Training Insights", systemImage: "bolt.shield.fill")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if manager.isTraining {
                            liveProcessingBadge
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Group {
                        if manager.accuracyHistory.isEmpty {
                            StatusPlaceholder(
                                title: "No Metrics",
                                subtitle: "Waiting for results...",
                                icon: "chart.bar.xaxis"
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                        } else {
                            LiveChartView(manager: manager)
                                .frame(height: 360)
                                .background(Color.primary.opacity(0.02), in: RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeSheetData) { infoData in
            GenericInfoSheet(info: infoData)
        }
    }
}

extension TrainingView {
    private var controlsSection: some View {
        VStack(spacing: 25) {
            if manager.accuracy < 1.0 {
                // 1. Intensity Picker
                VStack(alignment: .leading, spacing: 10) {
                    headerWithInfo(title: "Training Intensity (EPOCHS)", action: { activeSheetData = InfoDataStore.epochs })
                    HStack(spacing: 12) {
                        ForEach(TrainingIntensity.allCases) { intensity in
                            parameterButton(
                                title: "\(intensity.rawValue)",
                                icon: intensity.icon,
                                isSelected: config.selectedIntensity == intensity
                            ) {
                                config.selectedIntensity = intensity
                            }
                        }
                    }
                }
                
                // 2. Batch Size Picker
                VStack(alignment: .leading, spacing: 10) {
                    headerWithInfo(title: "Batch Size", action: { activeSheetData = InfoDataStore.batchSize })
                    HStack(spacing: 12) {
                        ForEach(BatchSize.allCases) { size in
                            parameterButton(
                                title: "\(size.rawValue)",
                                icon: size.icon,
                                isSelected: config.selectedBatchSize == size,
                                heightPadding: 18
                            ) {
                                config.selectedBatchSize = size
                            }
                        }
                    }
                }

                // 3. Learning Style
                VStack(alignment: .leading, spacing: 10) {
                    headerWithInfo(title: "Learning Style (Rate)", action: { activeSheetData = InfoDataStore.learningStyle })
                    HStack(spacing: 15) {
                        ForEach(LearningStyle.allCases) { style in
                            styleButton(style: style)
                        }
                    }
                }

                startTrainingButton
                
            } else {
                testARButton
            }
        }
        .padding()
    }
    
    private var trainingProgressSection: some View {
        VStack(spacing: 15) {
            Text("Epoch: \(manager.currentEpoch) / \(config.selectedIntensity.rawValue)")
                .font(.system(.headline, design: .monospaced))
            
            ProgressView(value: Double(manager.currentEpoch), total: Double(config.selectedIntensity.rawValue))
                .tint(.blue)
                .progressViewStyle(.linear)
            
            Text(config.learningStyle == .careful ? "Optimizing weights carefully..." : "Accelerating feature learning...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
}

// MARK: - Component Helpers
extension TrainingView {
    @ViewBuilder
    private var liveProcessingBadge: some View {
        if #available(iOS 17.0, *) {
            Text("Live Processing")
                .font(.caption2.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.orange.opacity(0.15), in: Capsule())
                .foregroundStyle(.orange)
                .symbolEffect(.pulse)
        } else {
            Text("Processing")
                .font(.caption2.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.orange.opacity(0.15), in: Capsule())
                .foregroundStyle(.orange)
        }
    }

    private var startTrainingButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                manager.startTraining(
                    epochs: config.selectedIntensity.rawValue,
                    batchSize: config.selectedBatchSize.rawValue,
                    style: config.learningStyle,
                    dataset: dataset
                )
            }
        }) {
            Text("Start Training")
                .font(.title3.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.gradient, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
        }
        .padding(.top, 8)
    }
    
    private var testARButton: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: InferenceScreen(dataset: dataset)) {
                HStack {
                    Image(systemName: "camera.viewfinder")
                    Text("Test in AR")
                }
                .font(.title3.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.gradient, in: RoundedRectangle(cornerRadius: 16))
            }
            
            Button("Retrain Model") {
                withAnimation { manager.accuracy = 0.0 }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private func headerWithInfo(title: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.caption).bold().textCase(.uppercase)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: action) {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.blue.gradient)
            }
        }
    }

    private func parameterButton(title: String, icon: String, isSelected: Bool, heightPadding: CGFloat = 10, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, heightPadding)
            .background(isSelected ? Color.blue.gradient : Color.primary.opacity(0.05).gradient, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
    
    private func styleButton(style: LearningStyle) -> some View {
        Button(action: { config.learningStyle = style }) {
            HStack(spacing: 12) {
                Image(systemName: style.icon)
                    .font(.title)
                    .foregroundStyle(style.color.gradient)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(style.title).font(.headline)
                    Text(style.subtitle).font(.caption).foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(config.learningStyle == style ? style.color.opacity(0.1) : Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                if config.learningStyle == style {
                    RoundedRectangle(cornerRadius: 16).stroke(style.color.opacity(0.5), lineWidth: 1)
                }
            }
            .foregroundStyle(config.learningStyle == style ? style.color : .primary)
        }
        .buttonStyle(.plain)
    }
}
