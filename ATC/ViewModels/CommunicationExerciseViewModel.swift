import Foundation
import AVFoundation
import SwiftUI

@MainActor
class CommunicationExerciseViewModel: ObservableObject {
    @Published var situationText: String = ""
    @Published var initialElements: [CommunicationElement] = []
    @Published var selectedElements: [CommunicationElement] = []
    @Published var readbackElements: [CommunicationElement] = []
    @Published var selectedReadbackElements: [CommunicationElement] = []
    @Published var controllerResponse: String?
    @Published var showControllerResponse = false
    @Published var isReadbackCorrect = false
    @Published var readbackFeedback: String?
    @Published var currentStep = 1
    @Published var totalSteps = 1
    @Published var requestFeedback: String?
    @Published var showRequestFeedback = false
    @Published var isRequestExpanded = true
    
    private let dataLoader = DataLoader()
    private let settings = ATCSettings.shared
    private let lessonType: CommunicationExerciseType
    private var currentCommunication: ExerciseCommunication?
    
    private let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    init(lessonType: CommunicationExerciseType) {
        self.lessonType = lessonType
    }
    
    func loadExercise() {
        let lessonId = getLessonId()
        let communications = dataLoader.getCommunications(forLessonId: lessonId)
        
        // Reset all values for new exercise
        AirportManager.shared.resetCurrentLocation()
        
        // Get total number of steps
        totalSteps = communications.map { $0.stepNumber }.max() ?? 1
        
        // Get current step and convert to ExerciseCommunication
        currentCommunication = communications
            .first(where: { $0.stepNumber == currentStep })
            .map { ExerciseCommunication(from: $0) }
        
        // Update situation text
        situationText = AirportManager.shared.processText(currentCommunication?.situationText ?? "", for: nil)
        
        // Create initial elements from pilot request
        if let pilotRequest = currentCommunication?.pilotRequest {
            initialElements = createElements(from: pilotRequest)
        }
    }
    
    func moveElement(_ element: CommunicationElement, from source: inout [CommunicationElement], to destination: inout [CommunicationElement]) {
        if let index = source.firstIndex(where: { $0.id == element.id }) {
            source.remove(at: index)
            destination.append(element)
        }
    }
    
    func validateRequest() {
        let lessonId = getLessonId()
        let communications = dataLoader.getCommunications(forLessonId: lessonId)
        currentCommunication = communications
            .first(where: { $0.stepNumber == currentStep })
            .map { ExerciseCommunication(from: $0) }
        
        // Process the expected phrase through AirportManager
        let expectedTemplate = currentCommunication?.pilotRequest ?? ""
        let expectedPhrase = AirportManager.shared.processText(expectedTemplate, for: nil)
            .trimmingCharacters(in: .whitespaces)
        
        let selectedPhrase = selectedElements
            .map { element in element.processedText.trimmingCharacters(in: .whitespaces) }
            .joined(separator: ", ")
        
        if selectedPhrase == expectedPhrase {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showControllerResponse = true
                isRequestExpanded = false
                if let response = currentCommunication?.atcResponse {
                    controllerResponse = AirportManager.shared.processText(response, for: nil, isATCResponse: true)
                }
                showRequestFeedback = false
                
                if let readbackPhrase = currentCommunication?.pilotReadback {
                    let processedReadback = AirportManager.shared.processText(readbackPhrase, for: nil)
                    readbackElements = createElements(from: processedReadback)
                }
            }
        } else {
            withAnimation {
                showRequestFeedback = true
                requestFeedback = "Incorrect request. Please try again."
            }
        }
    }
    
    func validateReadback() {
        guard let currentCommunication = currentCommunication else { return }
        
        let expectedTemplate = currentCommunication.pilotReadback ?? ""
        let expectedPhrase = AirportManager.shared.processText(expectedTemplate, for: nil)
            .trimmingCharacters(in: .whitespaces)
        
        let selectedPhrase = selectedReadbackElements
            .map { element in element.processedText.trimmingCharacters(in: .whitespaces) }
            .joined(separator: ", ")
        
        withAnimation(.easeInOut(duration: 0.4)) {
            self.isReadbackCorrect = selectedPhrase == expectedPhrase
            if self.isReadbackCorrect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.showControllerResponse = false
                        if self.currentStep < self.totalSteps {
                            self.currentStep += 1
                            self.resetForNextStep()
                        }
                    }
                }
            } else {
                self.readbackFeedback = "Incorrect readback. Please try again."
            }
        }
    }
    
    private func resetForNextStep() {
        showControllerResponse = false
        controllerResponse = nil
        readbackElements = []
        selectedReadbackElements = []
        readbackFeedback = nil
        isRequestExpanded = true
        loadExercise()
    }
    
    private func getLessonId() -> String {
        switch lessonType {
        case .uncontrolled:
            return "VFR-TaxiOut-1"
        case .basic:
            return "VFR-TaxiOut-2"
        case .complex:
            return "VFR-TaxiOut-3"
        }
    }
    
    private func createElements(from request: String) -> [CommunicationElement] {
        let phrases = request.components(separatedBy: ", ")
        
        return phrases.map { phrase -> CommunicationElement in
            let lowercased = phrase.lowercased()
            let type: CommunicationElement.ElementType = {
                switch true {
                case lowercased.contains("n") && lowercased.first == "n":
                    return .callsign
                case lowercased.contains("ground"), 
                     lowercased.contains("tower"),
                     lowercased.contains("approach"):
                    return .facility
                case lowercased.contains("ramp"), 
                     lowercased.contains("terminal"),
                     lowercased.contains("location"),
                     lowercased.contains("parking"):
                    return .position
                case lowercased.contains("request taxi"),
                     lowercased.contains("ready to taxi"):
                    return .request
                case lowercased.contains("runway"):
                    return .runway
                case lowercased.contains("taxi via"),
                     lowercased.contains("alpha"),
                     lowercased.contains("bravo"),
                     lowercased.contains("charlie"),
                     lowercased.contains("delta"):
                    return .taxiway
                case lowercased.contains("information"),
                     lowercased.contains("atis"):
                    return .atis
                case lowercased.contains("hold short"),
                     lowercased.contains("cross runway"),
                     lowercased.contains("line up and wait"):
                    return .instruction
                default:
                    return .other
                }
            }()
            
            return CommunicationElement(text: phrase, type: type)
        }.shuffled()
    }
    
    func speakATCResponse() {
        guard let response = controllerResponse else { return }
        
        let processedResponse = AirportManager.shared.processText(response, for: nil)
        
        var chunks: [String] = []
        let elements = processedResponse.components(separatedBy: " ")
        var currentChunk: [String] = []
        
        for element in elements {
            switch element {
            case _ where element.contains("N"):
                if !currentChunk.isEmpty {
                    chunks.append(currentChunk.joined(separator: " "))
                    currentChunk = []
                }
                chunks.append(element)
                
            case "Taxi":
                if !currentChunk.isEmpty {
                    chunks.append(currentChunk.joined(separator: " "))
                }
                currentChunk = [element]
                
            default:
                currentChunk.append(element)
            }
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk.joined(separator: " "))
        }
        
        let formattedText = chunks.joined(separator: " | ")
        let utterance = AVSpeechUtterance(string: formattedText)
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-premium") {
            utterance.voice = voice
        }
        synthesizer.speak(utterance)
    }
} 