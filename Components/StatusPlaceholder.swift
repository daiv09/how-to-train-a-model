import SwiftUI

struct StatusPlaceholder: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        // ── COMPLETELY HORIZONTAL LAYOUT ──
        HStack(spacing: 20) {
            placeholderIcon
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1) // Keep it tight and horizontal
            }
            
            Spacer() // Pushes content to the left, or remove for center-align
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.clear)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 24))
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            }
        }
    }
    
    @ViewBuilder
    private var placeholderIcon: some View {
        let baseIcon = Image(systemName: icon)
            .font(.system(size: 32, weight: .semibold)) // Reduced size for horizontal fit
        
        if #available(iOS 17.0, *) {
            baseIcon
                .foregroundStyle(.blue.gradient)
                .symbolEffect(.pulse, options: .repeating)
        } else {
            baseIcon
                .foregroundStyle(.blue)
        }
    }
}
