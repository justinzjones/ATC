import Foundation
import SwiftUI

struct CommunicationElement: Identifiable {
    let id = UUID()
    let rawText: String  // Original text with placeholders
    var processedText: String  // Text after processing placeholders
    let type: CommunicationElementType
    var isSelected: Bool = false
    
    init(text: String, type: CommunicationElementType) {
        self.rawText = text
        self.processedText = AirportManager.shared.processText(text, for: nil, isATCResponse: false)  // Ensure no quotes in pills
        self.type = type
    }
    
    enum CommunicationElementType {
        case traffic
        case ground
        case taxi
        case callsign
        case location
        case airport
        
        var color: Color {
            switch self {
            case .traffic:
                return .orange
            case .ground:
                return .blue
            case .taxi:
                return .green
            case .callsign:
                return .purple
            case .location:
                return .red
            case .airport:
                return .indigo
            }
        }
    }
} 