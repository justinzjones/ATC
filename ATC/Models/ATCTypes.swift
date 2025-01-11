import Foundation

// Represents a single lesson within a subsection
struct ATCLesson: Identifiable {
    let id = UUID()
    let title: String
    let objective: String
    let type: LessonType
    let scenarios: [ATCScenario]
    
    enum LessonType {
        case radioScenario
        case taxiRequest
    }
}

// Represents a subsection of training (e.g., Taxi out, Takeoff, etc.)
struct ATCSubsection: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let lessons: [ATCLesson]
    var isCompleted: Bool = false
}

// Represents main sections (VFR or IFR)
struct ATCSection: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let subsections: [ATCSubsection]
} 