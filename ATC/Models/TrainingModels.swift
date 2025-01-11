// Combines all the new model structures in one file
struct TrainingLesson: Codable, Identifiable {
    let section: String
    let subsection: String
    let lessonNumber: Int
    let title: String
    let objective: String
    let communicationType: String
    let controlled: String
    var scenarios: [TrainingScenario] = []
    
    var id: String {
        "\(section)-\(subsection)-\(lessonNumber)"
    }
    
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

struct TrainingScenario: Codable, Identifiable {
    let id: String
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lessonID = try container.decode(String.self, forKey: .lessonID)
        stepNumber = try container.decode(Int.self, forKey: .stepNumber)
        type = try container.decode(String.self, forKey: .type)
        situationText = try container.decode(String.self, forKey: .situationText)
        pilotRequest = try container.decodeIfPresent(String.self, forKey: .pilotRequest)
        atcResponse = try container.decodeIfPresent(String.self, forKey: .atcResponse)
        pilotReadback = try container.decodeIfPresent(String.self, forKey: .pilotReadback)
        
        id = "\(lessonID)-\(stepNumber)"
    }
}

struct TrainingContent: Codable {
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

struct TrainingSubsection: Codable {
    let section: String
    let subsection: String?
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case section = "Section"
        case subsection = "Subsection"
        case description = "Description/Objective"
    }
}

struct TrainingStructure: Codable {
    let appContent: [TrainingContent]
    let subsections: [TrainingSubsection]
    let lessons: [TrainingLesson]
    let communications: [TrainingScenario]
    
    enum CodingKeys: String, CodingKey {
        case appContent = "App Content"
        case subsections = "Subsections"
        case lessons = "Lessons"
        case communications = "Communications"
    }
} 