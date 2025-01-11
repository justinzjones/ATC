import Foundation
import SwiftUI

struct CommunicationElement: Identifiable {
    let id = UUID()
    let rawText: String  // Original text with placeholders
    var processedText: String  // Text after processing placeholders
    let type: ElementType
    var isSelected: Bool = false
    
    init(text: String, type: ElementType) {
        self.rawText = text
        self.processedText = AirportManager.shared.processText(text, for: nil, isATCResponse: false)  // Ensure no quotes in pills
        self.type = type
    }
    
    enum ElementType {
        case callsign
        case facility    // ground, tower, approach
        case position    // ramp, terminal locations
        case request     // request taxi, cleared to land
        case runway      // runway numbers and instructions
        case taxiway    // taxiway identifiers
        case atis       // ATIS information
        case readback   // readback correct, etc.
        case instruction // hold short, cross runway
        case other
        
        var color: Color {
            switch self {
            case .callsign:
                return Color(red: 0.2, green: 0.6, blue: 0.2)  // Forest Green
            case .facility:
                return Color(red: 0.5, green: 0.2, blue: 0.7)  // Royal Purple
            case .position:
                return Color(red: 0.9, green: 0.5, blue: 0.2)  // Orange
            case .request:
                return Color(red: 0.8, green: 0.2, blue: 0.2)  // Red
            case .runway:
                return Color(red: 0.2, green: 0.4, blue: 0.8)  // Royal Blue
            case .taxiway:
                return Color(red: 0.2, green: 0.7, blue: 0.9)  // Sky Blue
            case .atis:
                return Color(red: 0.8, green: 0.4, blue: 0.0)  // Dark Orange
            case .readback:
                return Color(red: 0.3, green: 0.7, blue: 0.3)  // Green
            case .instruction:
                return Color(red: 0.3, green: 0.3, blue: 0.3)  // Darker Gray
            case .other:
                return Color(red: 0.4, green: 0.4, blue: 0.4)  // Medium Gray
            }
        }
    }
} 