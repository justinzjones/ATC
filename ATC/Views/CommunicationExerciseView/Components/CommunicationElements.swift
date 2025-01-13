import SwiftUI

struct CommunicationPill: View {
    let element: CommunicationElement
    
    var body: some View {
        Text(element.processedText)
            .font(.subheadline)
            .foregroundStyle(element.type.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(element.type.color.opacity(0.1))
            .clipShape(Capsule())
    }
}

struct CommunicationElementView: View {
    let element: CommunicationElement
    
    var body: some View {
        Text(element.processedText)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(element.isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(element.isSelected ? Color.blue : Color.gray.opacity(0.3))
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        CommunicationPill(element: CommunicationElement(
            text: "N12345",
            type: .callsign
        ))
        
        CommunicationElementView(element: CommunicationElement(
            text: "Ground",
            type: .ground
        ))
    }
    .padding()
} 