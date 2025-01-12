import SwiftUI

struct CommunicationExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    let lessonType: CommunicationExerciseType
    let lessonTitle: String
    let objective: String
    @StateObject private var viewModel: CommunicationExerciseViewModel
    @Namespace private var animation  // For matched geometry transitions
    
    init(lessonType: CommunicationExerciseType, lessonTitle: String, objective: String) {
        self.lessonType = lessonType
        self.lessonTitle = lessonTitle
        self.objective = objective
        self._viewModel = StateObject(wrappedValue: CommunicationExerciseViewModel(lessonType: lessonType))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Exercise Title and Progress
                HStack {
                    Text(objective)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    StepProgressView(
                        currentStep: viewModel.currentStep,
                        totalSteps: viewModel.totalSteps
                    )
                }
                .padding(.horizontal)
                
                if !viewModel.isReadbackCorrect {
                    // Situation Card
                    SituationCard(text: viewModel.situationText)
                        .transition(.move(edge: .leading))
                        .id("situation-\(viewModel.currentStep)")
                    
                    // Request Section
                    RequestSection(
                        initialElements: $viewModel.initialElements,
                        selectedElements: $viewModel.selectedElements,
                        showControllerResponse: viewModel.showControllerResponse,
                        showFeedback: viewModel.showRequestFeedback,
                        feedbackMessage: viewModel.requestFeedback,
                        onSubmit: viewModel.validateRequest,
                        isExpanded: $viewModel.isRequestExpanded
                    )
                    .transition(.move(edge: .trailing))
                    .id("request-\(viewModel.currentStep)")
                    
                    // Only show ATC Response and Readback if they exist in the communication
                    if viewModel.hasATCResponse {
                        if viewModel.showControllerResponse {
                            ATCResponseSection(
                                response: viewModel.controllerResponse ?? "",
                                onSpeak: viewModel.speakATCResponse
                            )
                            
                            if viewModel.hasReadback {
                                ReadbackSection(
                                    availableElements: $viewModel.availableReadbackElements,
                                    selectedElements: $viewModel.selectedReadbackElements,
                                    isCorrect: viewModel.isReadbackCorrect,
                                    onSubmit: viewModel.validateReadback,
                                    errorMessage: viewModel.readbackFeedback
                                )
                            }
                        }
                    }
                } else {
                    CompletionView(
                        summaryItems: viewModel.summaryItems,
                        onContinue: { dismiss() }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)).animation(.easeInOut(duration: 0.5)))
                }
            }
            .padding(.vertical)
            .animation(.easeInOut(duration: 0.4), value: viewModel.currentStep)
            .animation(.easeInOut(duration: 0.4), value: viewModel.showControllerResponse)
            .animation(.easeInOut(duration: 0.5), value: viewModel.isReadbackCorrect)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.loadExercise()
        }
    }
    
    private func getLessonTitle() -> String {
        switch lessonType {
        case .uncontrolled:
            return "Uncontrolled Taxi"
        case .basic:
            return "Basic Taxi Request"
        case .complex:
            return "Complex Taxi Request"
        }
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

#Preview {
    NavigationStack {
        CommunicationExerciseView(lessonType: .basic, lessonTitle: "Basic Taxi Request", objective: "Learn how to handle taxi requests")
    }
} 