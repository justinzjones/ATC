import Foundation

// MARK: - View Models
struct ATCSection: Identifiable {
    let title: String
    let description: String
    var subsections: [ATCSubsection]
    var id: String { title }
}

struct ATCSubsection: Identifiable {
    let title: String
    let description: String
    var lessons: [ATCLesson]
    var id: String { title }
}

struct ATCLesson: Identifiable {
    let title: String
    let objective: String
    let isControlled: Bool
    let lessonID: String
    var id: String { lessonID }
} 