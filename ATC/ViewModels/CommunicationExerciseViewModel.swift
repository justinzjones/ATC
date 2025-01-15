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
    
    let isControlled: Bool
    private let synthesizer: SpeechSynthesizer
    private var correctReadbackOrder: [CommunicationElement] = []
    
    init(isControlled: Bool) {
        self.isControlled = isControlled
        self.synthesizer = SpeechSynthesizer()
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-premium") {
            self.synthesizer.updateVoice(voice.identifier)
        }
    }
    
    private func createElements(from text: String?) -> [CommunicationElement] {
        guard let text = text else { return [] }
        
        // Process text with AirportManager
        let processedText = AirportManager.shared.processText(text, for: nil, isATCResponse: false)
        
        // Split into elements and create with appropriate type
        return processedText.components(separatedBy: ", ")
            .map { text in
                let lowercased = text.lowercased()
                if lowercased.contains("traffic") {
                    return CommunicationElement(text: text, type: .traffic)
                } else if lowercased.contains("ground") {
                    return CommunicationElement(text: text, type: .ground)
                } else if lowercased.contains("taxi") {
                    return CommunicationElement(text: text, type: .taxi)
                } else if text.contains("N") && text.count >= 5 && text.contains(where: { $0.isNumber }) {
                    return CommunicationElement(text: text, type: .callsign)
                } else if lowercased.contains("ramp") || lowercased.contains("terminal") {
                    return CommunicationElement(text: text, type: .location)
                } else {  // Airport name
                    return CommunicationElement(text: text, type: .airport)
                }
            }
    }
    
    private func findCommunications() -> [ExerciseCommunication] {
        guard let communications = DataLoader().loadCommunications() else {
            print("Failed to load communications")
            return []
        }
        
        // Find communications for this lesson based on lessonID
        let filteredComms = communications.filter { communication in
            if isControlled {
                return communication.lessonID == "VFR-TaxiOut-2" || communication.lessonID == "VFR-TaxiOut-3"
            } else {
                return communication.lessonID == "VFR-TaxiOut-1"
            }
        }.sorted { $0.stepNumber < $1.stepNumber }
        
        // Set totalSteps based on the actual number of steps in this lesson
        totalSteps = filteredComms.count
        
        // Set currentStep based on the first communication's step number
        if let firstComm = filteredComms.first {
            currentStep = firstComm.stepNumber
        }
        
        print("Found \(filteredComms.count) steps for lesson (isControlled: \(isControlled))")
        return filteredComms
    }
    
    func loadExercise() {
        let communications = findCommunications()
        
        // Ensure totalSteps reflects the actual number of communications
        totalSteps = communications.count
        
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
        // Update current step to match the communication's step number
        currentStep = communication.stepNumber
        
        // Set flags based on communication content
        hasATCResponse = communication.atcResponse != nil
        hasReadback = communication.pilotReadback != nil
        
        // Reset AirportManager with appropriate controlled status
        AirportManager.shared.resetForNewExercise(isControlled: isControlled)
        
        // Load and process situation text
        situationText = AirportManager.shared.processText(
            communication.situationText,
            for: nil,
            isATCResponse: false
        )
        
        // Store the correct order and load initial elements for the request
        if let pilotRequest = communication.pilotRequest {
            correctOrder = createElements(from: pilotRequest)
            initialElements = correctOrder.shuffled()
        }
        
        // Process ATC response with dynamic elements
        if hasATCResponse {
            controllerResponse = AirportManager.shared.processText(
                communication.atcResponse ?? "",
                for: nil,
                isATCResponse: true
            )
            
            if hasReadback {
                let processedReadback = AirportManager.shared.processText(
                    communication.pilotReadback ?? "",
                    for: nil,
                    isATCResponse: false
                )
                
                // Create elements and store correct order
                correctReadbackOrder = processedReadback.components(separatedBy: ", ")
                    .map { text in
                        CommunicationElement(text: text, type: determineElementType(text))
                    }
                
                // Create shuffled copy for presentation
                readbackElements = correctReadbackOrder.shuffled()
                
                print("Created readback elements in order: \(correctReadbackOrder.map { $0.processedText })")
                print("Shuffled elements: \(readbackElements.map { $0.processedText })")
                selectedReadbackElements = []
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
            print("Validating readback...")
            print("Selected elements: \(selectedReadbackElements.map { $0.processedText })")
            print("Correct order: \(correctReadbackOrder.map { $0.processedText })")
            
            // Compare against the correct order, not the shuffled elements
            let isCorrect = selectedReadbackElements.count == correctReadbackOrder.count &&
                zip(selectedReadbackElements, correctReadbackOrder).allSatisfy { selected, correct in
                    let matches = selected.processedText == correct.processedText
                    print("Comparing: '\(selected.processedText)' with '\(correct.processedText)' -> \(matches)")
                    return matches
                }
            
            if isCorrect {
                print("✅ Readback correct")
                isReadbackCorrect = true
                isControllerResponseExpanded = false
                isReadbackExpanded = false
                
                if let index = summaryItems.firstIndex(where: { $0.title == "Pilot Readback" }) {
                    summaryItems[index] = ExerciseSummaryItem(
                        title: "Pilot Readback",
                        isCompleted: true
                    )
                }
            } else {
                print("❌ Readback incorrect")
                readbackFeedback = "Incorrect readback. Please try again."
            }
        }
    }
    
    func speakATCResponse() {
        if let response = controllerResponse {
            synthesizer.speak(response)
        }
    }
    
    private func determineElementType(_ text: String) -> CommunicationElement.CommunicationElementType {
        let lowercased = text.lowercased()
        if lowercased.contains("runway") {
            return .runway
        } else if text.contains("N") && text.count >= 5 && text.contains(where: { $0.isNumber }) {
            return .callsign
        } else if lowercased.contains("taxi") {
            return .taxi
        } else {
            return .readback
        }
    }
} 