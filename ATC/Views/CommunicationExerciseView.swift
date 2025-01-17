import SwiftUI

struct CommunicationExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    let lessonTitle: String
    let objective: String
    let isControlled: Bool
    let currentLessonID: String
    @StateObject private var viewModel: CommunicationExerciseViewModel
    @Namespace private var animation  // For matched geometry transitions
    
    init(lessonTitle: String, objective: String, isControlled: Bool, lessonID: String) {
        self.lessonTitle = lessonTitle
        self.objective = objective
        self.isControlled = isControlled
        self.currentLessonID = lessonID
        self._viewModel = StateObject(wrappedValue: CommunicationExerciseViewModel(
        isControlled: isControlled,
        lessonID: lessonID

    ))
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
                    
                    // Only show Request Section if there's a pilot request
                    if viewModel.hasRequest {
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
                    }
                    
                    // Show ATC Response section if it exists and either there's no request or showControllerResponse is true
                    if viewModel.hasATCResponse && (!viewModel.hasRequest || viewModel.showControllerResponse) {
                        ATCResponseSection(
                            response: viewModel.controllerResponse ?? "",
                            onSpeak: viewModel.speakATCResponse
                        )
                        
                        if viewModel.hasReadback {
                            ReadbackSection(
                                elements: $viewModel.readbackElements,
                                selectedElements: $viewModel.selectedReadbackElements,
                                isCorrect: viewModel.isReadbackCorrect,
                                onSubmit: viewModel.validateReadback,
                                errorMessage: viewModel.readbackFeedback
                            )
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
}

#Preview {
    NavigationStack {
        CommunicationExerciseView(lessonTitle: "Basic Taxi Request", objective: "Learn how to handle taxi requests", isControlled: true, lessonID: "1")
    }
} 