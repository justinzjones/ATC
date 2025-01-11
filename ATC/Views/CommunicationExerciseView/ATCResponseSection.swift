import SwiftUI

struct ATCResponseSection: View {
    let response: String
    let onSpeak: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundStyle(.green)
                    Text("ATC Response")
                        .foregroundStyle(.primary)
                }
                .font(.subheadline.weight(.medium))
                Spacer()
                Button(action: onSpeak) {
                    Image(systemName: "speaker.wave.2")
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 16) {
                // Message Display
                Text(response)
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .padding(.horizontal)
    }
} 