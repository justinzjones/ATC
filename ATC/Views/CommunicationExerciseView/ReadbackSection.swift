import SwiftUI

struct ReadbackSection: View {
    @Binding var elements: [CommunicationElement]
    @Binding var selectedElements: [CommunicationElement]
    let isCorrect: Bool
    let onSubmit: () -> Void
    let errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "mic")
                        .foregroundStyle(.purple)
                    Text("Your Readback")
                        .foregroundStyle(.primary)
                    if isCorrect {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.green)
                    }
                }
                .font(.subheadline.weight(.medium))
                Spacer()
            }
            .padding()
            
            if !isCorrect {
                VStack(spacing: 16) {
                    // Selected readback elements
                    if !selectedElements.isEmpty {
                        FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                            ForEach(selectedElements) { element in
                                CommunicationPill(element: element)
                                    .onTapGesture {
                                        withAnimation {
                                            moveElement(element, from: &selectedElements, to: &elements)
                                        }
                                    }
                            }
                        }
                    }
                    
                    // Error message display
                    if let error = errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Available readback elements
                    if !elements.isEmpty {
                        FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                            ForEach(elements) { element in
                                CommunicationPill(element: element)
                                    .onTapGesture {
                                        withAnimation {
                                            moveElement(element, from: &elements, to: &selectedElements)
                                        }
                                    }
                            }
                        }
                    }
                    
                    // Submit button
                    Button(action: onSubmit) {
                        Text("Submit Readback")
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