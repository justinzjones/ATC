struct CommunicationScenario: Codable, Identifiable {
    let id: String
    let lessonID: String
    let stepNumber: Int
    let type: String
    let situationText: String
    let pilotRequest: String?
    let atcResponse: String?
    let pilotReadback: String?
    let controlled: String
    
    enum CodingKeys: String, CodingKey {
        case lessonID = "Lesson ID"
        case stepNumber = "Step#"
        case type = "Type"
        case situationText = "Situation Text"
        case pilotRequest = "Pilot request"
        case atcResponse = "ATC Response"
        case pilotReadback = "Pilot readback"
        case controlled = "Controlled"
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
        controlled = try container.decode(String.self, forKey: .controlled)
        
        // Create a unique ID combining lesson ID and step number
        id = "\(lessonID)-\(stepNumber)"
    }
} 