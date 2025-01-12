import SwiftUI
import AVFoundation

@MainActor
class CommunicationExerciseViewModel: ObservableObject {
    @Published var situationText: String = ""
    @Published var initialElements: [CommunicationElement] = []
    @Published var selectedElements: [CommunicationElement] = []
    @Published var readbackElements: [CommunicationElement] = []
    @Published var selectedReadbackElements: [CommunicationElement] = []
    @Published var controllerResponse: String?
    @Published var isRequestExpanded = true
    @Published var isControllerResponseExpanded = false
    @Published var isReadbackExpanded = false
    @Published var isReadbackCorrect = false
    @Published var showControllerResponse = false
    @Published var readbackFeedback: String?
    @Published var requestFeedback: String?
    @Published var showRequestFeedback = false
    @Published var currentStep = 1
    @Published var totalSteps = 1
    @Published var hasATCResponse: Bool = false
    @Published var hasReadback: Bool = false
    @Published var correctOrder: [CommunicationElement] = []
    @Published var summaryItems: [ExerciseSummaryItem] = []
    @Published var availableReadbackElements: [CommunicationElement] = []
    
    let lessonType: CommunicationExerciseType
    private let synthesizer: SpeechSynthesizer
    
    init(lessonType: CommunicationExerciseType) {
        self.lessonType = lessonType
        self.synthesizer = SpeechSynthesizer()
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-premium") {
            self.synthesizer.updateVoice(voice.identifier)
        }
    }
    
    private func createElements(from text: String?) -> [CommunicationElement] {
        guard let text = text else { return [] }
        
        // Process text with AirportManager
        let processedText = AirportManager.shared.processText(text, for: nil, isATCResponse: false)
        print("Creating elements from text:", text)
        print("Processed into:", processedText)
        
        // Split into elements and create with appropriate type
        return processedText.components(separatedBy: ", ")
            .map { text in
                let trimmedText = text.trimmingCharacters(in: .whitespaces)
                if trimmedText.contains("traffic") {
                    return CommunicationElement(text: trimmedText, type: .traffic)
                } else if trimmedText.contains("Ground") {
                    return CommunicationElement(text: trimmedText, type: .ground)
                } else if trimmedText.contains("taxi") {
                    return CommunicationElement(text: trimmedText, type: .taxi)
                } else if trimmedText.contains("N") && trimmedText.count >= 5 {  // N-number
                    return CommunicationElement(text: trimmedText, type: .callsign)
                } else if trimmedText.contains("Runway") {  // Add Runway handling
                    return CommunicationElement(text: trimmedText, type: .runway)
                } else if trimmedText.contains("Ramp") || trimmedText.contains("Terminal") {
                    return CommunicationElement(text: trimmedText, type: .location)
                } else {
                    return CommunicationElement(text: trimmedText, type: .airport)
                }
            }
    }
    
    private func findCommunications() -> [ExerciseCommunication] {
        // Load communications from JSON
        guard let communications = DataLoader().loadCommunications() else {
            return []
        }
        
        // Find all communications for this lesson
        return communications.filter { communication in
            switch lessonType {
            case .uncontrolled:
                return communication.lessonID == "VFR-TaxiOut-1"
            case .basic:
                return communication.lessonID == "VFR-TaxiOut-2"
            case .complex:
                return communication.lessonID == "VFR-TaxiOut-3"
            }
        }.sorted { $0.stepNumber < $1.stepNumber }
    }
    
    func loadExercise() {
        let communications = findCommunications()
        totalSteps = communications.count  // Set total steps based on actual steps in lesson
        
        if let firstStep = communications.first {
            loadStep(firstStep)
        }
    }
    
    func moveToNextStep() {
        let communications = findCommunications()
        if currentStep < totalSteps,
           let nextStep = communications.first(where: { $0.stepNumber == currentStep + 1 }) {
            currentStep += 1
            loadStep(nextStep)
        }
    }
    
    private func loadStep(_ communication: ExerciseCommunication) {
        print("Loading step...")
        print("Pilot Request:", communication.pilotRequest ?? "nil")
        print("ATC Response:", communication.atcResponse ?? "nil")
        print("Pilot Readback:", communication.pilotReadback ?? "nil")
        
        // Set flags based on communication content
        hasATCResponse = communication.atcResponse != nil
        hasReadback = communication.pilotReadback != nil
        
        print("Has ATC Response:", hasATCResponse)
        print("Has Readback:", hasReadback)
        
        // Reset AirportManager with appropriate controlled status
        let isControlled = lessonType != .uncontrolled
        AirportManager.shared.resetForNewExercise(isControlled: isControlled)
        
        // Load and process situation text
        situationText = AirportManager.shared.processText(
            communication.situationText,
            for: nil,
            isATCResponse: false
        )
        
        // Store the correct order and load initial elements for request
        if let pilotRequest = communication.pilotRequest {
            correctOrder = createElements(from: pilotRequest)
            initialElements = correctOrder.shuffled()
            print("Created request elements:", correctOrder.map { $0.processedText })
        }
        
        // Only load ATC response and readback if they exist
        if let atcResponse = communication.atcResponse {
            controllerResponse = AirportManager.shared.processText(
                atcResponse,
                for: nil,
                isATCResponse: true
            )
            print("Processed ATC response:", controllerResponse ?? "nil")
            
            if let pilotReadback = communication.pilotReadback {
                let processedReadback = AirportManager.shared.processText(
                    pilotReadback,
                    for: nil,
                    isATCResponse: false
                )
                print("Processed readback text:", processedReadback)
                readbackElements = createElements(from: processedReadback)
                availableReadbackElements = readbackElements.shuffled()
                selectedReadbackElements = []
                print("Created readback elements:", readbackElements.map { $0.processedText })
            }
        }
        
        // Generate summary items based on communication elements
        generateSummaryItems(from: communication)
    }
    
    private func generateSummaryItems(from communication: ExerciseCommunication) {
        var items: [ExerciseSummaryItem] = []
        
        // Always add Situation if there's situation text
        if !communication.situationText.isEmpty {
            items.append(ExerciseSummaryItem(
                title: "Situation Review",
                isCompleted: true
            ))
        }
        
        // Add Pilot Request if present
        if communication.pilotRequest != nil {
            items.append(ExerciseSummaryItem(
                title: "Pilot Request",
                isCompleted: isRequestCorrect
            ))
        }
        
        // Add ATC Response if present
        if communication.atcResponse != nil {
            items.append(ExerciseSummaryItem(
                title: "ATC Response",
                isCompleted: showControllerResponse
            ))
        }
        
        // Add Pilot Readback if present
        if communication.pilotReadback != nil {
            items.append(ExerciseSummaryItem(
                title: "Pilot Readback",
                isCompleted: isReadbackCorrect
            ))
        }
        
        summaryItems = items
    }
    
    var isRequestCorrect: Bool {
        guard selectedElements.count == correctOrder.count else { return false }
        
        // Compare selected elements with correct order
        return zip(selectedElements, correctOrder).allSatisfy { selected, correct in
            selected.processedText == correct.processedText
        }
    }
    
    func validateRequest() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showRequestFeedback = true
            
            if isRequestCorrect {
                // Update summary when request is correct
                if let index = summaryItems.firstIndex(where: { $0.title == "Pilot Request" }) {
                    summaryItems[index] = ExerciseSummaryItem(
                        title: "Pilot Request",
                        isCompleted: true
                    )
                }
                
                if !hasATCResponse {
                    isReadbackCorrect = true
                } else {
                    showControllerResponse = true
                    isRequestExpanded = false
                    isControllerResponseExpanded = true
                    
                    // Update ATC Response in summary
                    if let index = summaryItems.firstIndex(where: { $0.title == "ATC Response" }) {
                        summaryItems[index] = ExerciseSummaryItem(
                            title: "ATC Response",
                            isCompleted: true
                        )
                    }
                }
            } else {
                requestFeedback = "Incorrect request. Please try again."
            }
        }
    }
    
    func validateReadback() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            // Debug prints to see what we're comparing
            print("Selected Readback:", selectedReadbackElements.map { $0.processedText })
            print("Expected Readback:", readbackElements.map { $0.processedText })
            
            // Process both arrays through AirportManager to ensure consistent formatting
            let selectedProcessed = selectedReadbackElements.map { element in
                AirportManager.shared.processText(element.processedText, for: nil, isATCResponse: false)
            }
            
            let expectedProcessed = readbackElements.map { element in
                AirportManager.shared.processText(element.processedText, for: nil, isATCResponse: false)
            }
            
            print("Processed Selected:", selectedProcessed)
            print("Processed Expected:", expectedProcessed)
            
            if selectedProcessed == expectedProcessed {
                isReadbackCorrect = true
                isControllerResponseExpanded = false
                isReadbackExpanded = false
            } else {
                readbackFeedback = "Incorrect readback. Please try again."
            }
        }
    }
    
    func speakATCResponse() {
        if let response = controllerResponse {
            synthesizer.speak(response)
        }
    }
} 