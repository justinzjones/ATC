import SwiftUI

struct PillView: View {
    let text: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(text)
                .lineLimit(1)
                .truncationMode(.tail)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color, lineWidth: 1)
        )
    }
}

#Preview {
    HStack(spacing: 12) {
        PillView(text: "Sample", color: .blue)
        PillView(text: "Another Sample", color: .green)
    }
    .padding()
} 