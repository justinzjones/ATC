import Foundation
import SwiftUI

struct ControllerResponse {
    let elements: [TaxiRequestElement]
    let isCorrect: Bool
    let feedback: String
}

struct TaxiRequestElement: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let type: ElementType
    
    enum ElementType: String {
        case facility
        case callsign
        case position
        case atis
        case request
        case instruction
        case runway
        case taxiway
        case readback
        
        var color: Color {
            switch self {
            case .facility:
                return .blue
            case .callsign:
                return .green
            case .position:
                return .orange
            case .atis:
                return .purple
            case .request:
                return .red
            case .instruction:
                return .gray
            case .runway:
                return .brown
            case .taxiway:
                return .cyan
            case .readback:
                return .blue
            }
        }
    }
    
    static func == (lhs: TaxiRequestElement, rhs: TaxiRequestElement) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TaxiInstruction {
    enum Complexity {
        case basic
        case complex
    }
    
    static func elements(settings: ATCSettings = .shared, complexity: Complexity = .basic) -> [TaxiRequestElement] {
        let basicElements = [
            TaxiRequestElement(
                text: "\(settings.homeAirport.name) Ground",
                type: .facility
            ),
            TaxiRequestElement(
                text: settings.aircraftCallsign,
                type: .callsign
            ),
            TaxiRequestElement(
                text: "West Ramp",
                type: .position
            ),
            TaxiRequestElement(
                text: "Information Alpha",
                type: .atis
            ),
            TaxiRequestElement(
                text: "Ready to taxi",
                type: .request
            )
        ]
        
        switch complexity {
        case .basic:
            return basicElements.shuffled()
        case .complex:
            return basicElements.shuffled()
        }
    }
    
    static func validateRequest(_ request: [TaxiRequestElement], complexity: Complexity = .basic, settings: ATCSettings = .shared) -> ControllerResponse {
        let correctOrder = [
            TaxiRequestElement(
                text: "\(settings.homeAirport.name) Ground",
                type: .facility
            ),
            TaxiRequestElement(
                text: settings.aircraftCallsign,
                type: .callsign
            ),
            TaxiRequestElement(
                text: "West Ramp",
                type: .position
            ),
            TaxiRequestElement(
                text: "Information Alpha",
                type: .atis
            ),
            TaxiRequestElement(
                text: "Ready to taxi",
                type: .request
            )
        ]
        
        let isCorrect = request.map { $0.text } == correctOrder.map { $0.text }
        
        if isCorrect {
            switch complexity {
            case .basic:
                // Simple taxi instruction for Exercise 1
                let response = [
                    // Callsign chunk
                    TaxiRequestElement(text: settings.aircraftCallsign, type: .callsign),
                    
                    // Taxi instruction chunk
                    TaxiRequestElement(text: "Taxi", type: .instruction),
                    TaxiRequestElement(text: "to", type: .instruction),
                    TaxiRequestElement(text: "Runway 17", type: .runway),
                    TaxiRequestElement(text: "via", type: .instruction),
                    TaxiRequestElement(text: "Alpha", type: .taxiway)
                ]
                return ControllerResponse(
                    elements: response,
                    isCorrect: true,
                    feedback: ""
                )
                
            case .complex:
                // Complex taxi instruction for Exercise 2
                let response = [
                    // Callsign chunk
                    TaxiRequestElement(text: settings.aircraftCallsign, type: .callsign),
                    
                    // Active runway chunk
                    TaxiRequestElement(text: "Runway 17", type: .runway),
                    TaxiRequestElement(text: "in use", type: .instruction),
                    
                    // Taxi instruction chunk
                    TaxiRequestElement(text: "Taxi to", type: .instruction),
                    TaxiRequestElement(text: "Runway 17", type: .runway),
                    TaxiRequestElement(text: "via", type: .instruction),
                    TaxiRequestElement(text: "Charlie", type: .taxiway),
                    
                    // Hold short chunk
                    TaxiRequestElement(text: "hold short", type: .instruction),
                    TaxiRequestElement(text: "Runway 12", type: .runway),
                    
                    // Monitor tower chunk
                    TaxiRequestElement(text: "monitor Tower", type: .instruction),
                    TaxiRequestElement(text: "118.7", type: .instruction),
                    TaxiRequestElement(text: "when ready", type: .instruction)
                ]
                return ControllerResponse(
                    elements: response,
                    isCorrect: true,
                    feedback: ""
                )
            }
        } else {
            return ControllerResponse(
                elements: [],
                isCorrect: false,
                feedback: "Incorrect order. Remember to start with the facility, followed by your callsign, position, ATIS information, and request."
            )
        }
    }
    
    static func generateReadbackElements(from controllerResponse: [TaxiRequestElement], complexity: Complexity = .basic) -> [TaxiRequestElement] {
        // Keep original element types for consistent coloring
        return controllerResponse.shuffled()
    }
    
    static func validateReadback(_ readback: [TaxiRequestElement], controllerResponse: [TaxiRequestElement], complexity: Complexity = .basic) -> Bool {
        // For basic readback, just make sure all elements are present in the same order
        let readbackTexts = readback.map { $0.text }
        let responseTexts = controllerResponse.map { $0.text }
        
        print("Validating readback...")
        print("Readback: \(readbackTexts)")
        print("Expected: \(responseTexts)")
        print("Are they equal? \(readbackTexts == responseTexts)")
        
        return readbackTexts == responseTexts
    }
}