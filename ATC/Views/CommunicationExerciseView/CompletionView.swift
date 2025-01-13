import SwiftUI

struct CompletionView: View {
    let summaryItems: [ExerciseSummaryItem]
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                ForEach(summaryItems) { item in
                    ExerciseProgressCard(
                        text: item.title,
                        hasAudio: item.title.contains("Response")
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .padding(.horizontal)
        
        Spacer()
            .frame(height: 8)
        
        HStack {
            Text("Exercise Complete")
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
            Text("All requirements met")
                .font(.subheadline)
                .foregroundStyle(.green)
        }
        .padding(.horizontal)
        
        Button(action: onContinue) {
            Text("Continue to Next Exercise")
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal)
    }
}

struct ExerciseProgressCard: View {
    let text: String
    let hasAudio: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
            Text(text)
                .foregroundStyle(.primary)
            if hasAudio {
                Image(systemName: "speaker.wave.2")
                    .foregroundStyle(.blue)
            }
            Spacer()
        }
        .font(.subheadline)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
} 