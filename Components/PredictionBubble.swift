import SwiftUI

struct PredictionBubble: View {
    var label: String
    var confidence: Double
    var allProbabilities: [(String, Double)]
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 15) {
                statusIcon
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label.uppercased())
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.bold)
                    
                    Text("\(Int(confidence * 100))% MATCH CONFIDENCE")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .padding(16)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }

            // Analysis
            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    Divider()
                        .padding(.horizontal, 10)
                        .padding(.bottom, 5)
                    
                    Text("PROBABILITY ANALYSIS")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 16)

                    ForEach(allProbabilities, id: \.0) { item in
                        probabilityRow(for: item)
                    }
                }
                .padding(.bottom, 20)
                .transition(.opacity)
            }
        }
        .frame(width: 280)
        .background(bubbleBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.25), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
    }

    // Subviews
    
    @ViewBuilder
    private var statusIcon: some View {
        let icon = Image(systemName: confidence > 0.7 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
            .font(.title2)
            .foregroundStyle(confidenceColor.gradient)
        
        if #available(iOS 17.0, *) {
            icon.symbolEffect(.pulse, value: confidence)
        } else {
            icon
        }
    }
    
    @ViewBuilder
    private var bubbleBackground: some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: 24)
                .fill(.clear)
                .glassEffect(in: RoundedRectangle(cornerRadius: 24))
        } else {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        }
    }
    
    private func probabilityRow(for item: (String, Double)) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.0)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(Int(item.1 * 100))%")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { barGeo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.1))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(item.0 == label ? confidenceColor.gradient : Color.secondary.gradient)
                        .frame(width: barGeo.size.width * CGFloat(item.1), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 16)
    }

    private var confidenceColor: Color {
        confidence > 0.7 ? .blue : (confidence > 0.4 ? .orange : .red)
    }
}
