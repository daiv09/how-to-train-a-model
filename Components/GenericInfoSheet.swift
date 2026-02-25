import SwiftUI

struct InfoRow: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color.gradient)
                .frame(width: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(desc)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct GenericInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    let info: ParameterInfo
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Concept Explanation
                    VStack(alignment: .leading, spacing: 10) {
                        Text(info.question)
                            .font(.title3.bold())
                        
                        Text(info.answer)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    // Options Breakdown
                    VStack(spacing: 12) {
                        ForEach(info.options) { option in
                            InfoRow(
                                icon: option.icon,
                                color: option.color,
                                title: option.title,
                                desc: option.desc
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Pro-Tip
                    if let tip = info.proTip {
                        proTipView(tip: tip)
                    }
                }
                .padding(.vertical, 24)
            }
            .navigationTitle(info.navTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func proTipView(tip: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            tipIcon
            
            Text(tip)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var tipIcon: some View {
        let icon = Image(systemName: "lightbulb.fill")
            .foregroundStyle(.orange.gradient)
            .font(.title3)
        
        if #available(iOS 17.0, *) {
            // This fixes the 'variableColor' and 'symbolEffect' error
            icon.symbolEffect(.variableColor)
        } else {
            icon
        }
    }
}
