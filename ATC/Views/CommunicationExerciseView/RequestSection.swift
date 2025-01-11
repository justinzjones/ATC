import SwiftUI

struct RequestSection: View {
    @Binding var initialElements: [CommunicationElement]
    @Binding var selectedElements: [CommunicationElement]
    let showControllerResponse: Bool
    let showFeedback: Bool
    let feedbackMessage: String?
    let onSubmit: () -> Void
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "mic")
                    .foregroundStyle(.purple)
                Text("Your Request")
                    .foregroundStyle(.primary)
                if showControllerResponse {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                }
                Spacer()
            }
            .font(.subheadline.weight(.medium))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if isExpanded {
                VStack(spacing: 16) {
                    // Selected elements
                    if !selectedElements.isEmpty {
                        FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                            ForEach(selectedElements) { element in
                                CommunicationPill(element: element)
                                    .onTapGesture {
                                        withAnimation {
                                            moveElement(element, from: &selectedElements, to: &initialElements)
                                        }
                                    }
                            }
                        }
                    }
                    
                    // Available elements
                    if !initialElements.isEmpty {
                        FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                            ForEach(initialElements) { element in
                                CommunicationPill(element: element)
                                    .onTapGesture {
                                        withAnimation {
                                            moveElement(element, from: &initialElements, to: &selectedElements)
                                        }
                                    }
                            }
                        }
                    }
                    
                    if showFeedback, let message = feedbackMessage {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Submit button
                    Button(action: onSubmit) {
                        Text("Submit Request")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .disabled(selectedElements.isEmpty)
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private func moveElement(_ element: CommunicationElement, from source: inout [CommunicationElement], to destination: inout [CommunicationElement]) {
        if let index = source.firstIndex(where: { $0.id == element.id }) {
            source.remove(at: index)
            destination.append(element)
        }
    }
} 