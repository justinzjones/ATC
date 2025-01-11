struct Lesson: Codable, Identifiable {
    let section: String
    let subsection: String
    let lessonNumber: Int
    let title: String
    let objective: String
    let communicationType: String
    let controlled: String
    var scenarios: [CommunicationScenario] = []
    
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