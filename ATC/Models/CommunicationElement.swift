import Foundation
import SwiftUI

struct CommunicationElement: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let type: ElementType
    var isSelected: Bool = false
    
    var processedText: String {
        text.trimmingCharacters(in: .whitespaces)
    }
    
    enum ElementType {
        case callsign
        case ground
        case taxi
        case traffic
        case location
        case airport
        case runway
        
        var color: Color {
            switch self {
            case .callsign:
                return .blue
            case .ground:
                return .purple
            case .taxi:
                return .green
            case .traffic:
                return .orange
            case .location:
                return .red
            case .airport:
                return .gray
            case .runway:
                return .indigo
            }
        }
    }
} 