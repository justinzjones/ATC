import Foundation

// MARK: - Communication Models
struct ExerciseCommunication: Codable {
    let lessonID: String
    let stepNumber: Int
    let type: String
    let situationText: String
    let pilotRequest: String?
    let atcResponse: String?
    let pilotReadback: String?
    
    enum CodingKeys: String, CodingKey {
        case lessonID = "Lesson ID"
        case stepNumber = "Step#"
        case type = "Type"
        case situationText = "Situation Text"
        case pilotRequest = "Pilot request"
        case atcResponse = "ATC Response"
        case pilotReadback = "Pilot readback"
    }
}

// MARK: - Content Models
struct AppContent: Codable {
    let type: String
    let title: String
    let description: String
    let order: Int
    
    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case title = "Title"
        case description = "Description/Objective"
        case order = "Order"
    }
}

struct SubsectionContent: Codable {
    let section: String
    let subsection: String?
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case section = "Section"
        case subsection = "Subsection"
        case description = "Description/Objective"
    }
}

struct LessonContent: Codable {
    let section: String
    let subsection: String
    let lessonNumber: Int
    let title: String
    let objective: String
    let communicationType: String
    let controlled: String
    
    enum CodingKeys: String, CodingKey {
        case section = "Section"
        case subsection = "Subsection"
        case lessonNumber = "Lesson#"
        case title = "Title"
        case objective = "Objective"
        case communicationType = "Communication Type"
        case controlled = "Controlled"
    }
}

// MARK: - Main Content Structure
struct TrainingContent: Codable {
    let appContent: [AppContent]
    let subsections: [SubsectionContent]
    let lessons: [LessonContent]
    let communications: [ExerciseCommunication]
    
    enum CodingKeys: String, CodingKey {
        case appContent = "App Content"
        case subsections = "Subsections"
        case lessons = "Lessons"
        case communications = "Communications"
    }
} 