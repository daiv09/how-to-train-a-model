import SwiftUI
import Charts

struct LiveChartView: View {
    @ObservedObject var manager: TrainingManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            chartHeader
            
            Chart {
                ForEach(manager.accuracyHistory) { point in
                    lineMark(for: point)
                    areaMark(for: point)
                    pointMark(for: point)
                }
            }
            .chartYScale(domain: 0...1.0)
            .chartYAxis {
                AxisMarks(format: FloatingPointFormatStyle<Double>.Percent.percent.precision(.fractionLength(0)))
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
        }
        .padding(20)
        .background(glassBackground)
        .overlay(glassOverlay)
    }
    
    // MARK: - Modular Marks (Fixes compiler timeout)
    private func lineMark(for point: HistoryPoint) -> some ChartContent {
        LineMark(x: .value("Epoch", point.epoch), y: .value("Accuracy", point.accuracy))
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
            .foregroundStyle(Color.blue.gradient)
    }
    
    private func areaMark(for point: HistoryPoint) -> some ChartContent {
        AreaMark(x: .value("Epoch", point.epoch), y: .value("Accuracy", point.accuracy))
            .interpolationMethod(.catmullRom)
            .foregroundStyle(LinearGradient(
                colors: [.blue.opacity(0.3), .blue.opacity(0.01)],
                startPoint: .top, endPoint: .bottom
            ))
    }
    
    private func pointMark(for point: HistoryPoint) -> some ChartContent {
        PointMark(x: .value("Epoch", point.epoch), y: .value("Accuracy", point.accuracy))
            .foregroundStyle(.blue)
            .symbolSize(40)
            .annotation(position: .top, spacing: 4) {
                if let last = manager.accuracyHistory.last, point.id == last.id {
                    lastPointLabel(point.accuracy)
                }
            }
    }

    // MARK: - Visual Components
    @ViewBuilder
    private var glassBackground: some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: 24)
                .fill(.clear)
                .glassEffect(in: RoundedRectangle(cornerRadius: 24))
        } else {
            RoundedRectangle(cornerRadius: 24).fill(.thinMaterial)
        }
    }
    
    private var glassOverlay: some View {
        RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.15), lineWidth: 0.5)
    }

    private var chartHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Training Accuracy").font(.subheadline.bold()).foregroundStyle(.secondary)
                if let last = manager.accuracyHistory.last {
                    Text(last.accuracy, format: .percent.precision(.fractionLength(1)))
                        .font(.title2.bold().monospacedDigit())
                        .contentTransition(.numericText())
                }
            }
            Spacer()
        }
    }
    
    private func lastPointLabel(_ accuracy: Double) -> some View {
        Text(accuracy, format: .percent.precision(.fractionLength(0)))
            .font(.caption2.bold()).padding(.horizontal, 6).padding(.vertical, 2)
            .background(.blue, in: Capsule()).foregroundStyle(.white)
    }
}
