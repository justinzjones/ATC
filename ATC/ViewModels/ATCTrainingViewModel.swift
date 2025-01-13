import Foundation

@MainActor
class ATCTrainingViewModel: ObservableObject {
    @Published var sections: [ATCSection] = []
    private let dataLoader = DataLoader()
    
    init() {
        loadContent()
    }
    
    private func loadContent() {
        guard let content = dataLoader.loadContent() else { 
            print("Failed to load content")
            return 
        }
        
        // Process content and create sections
        var sectionsDict: [String: ATCSection] = [:]
        
        // Create subsections from content
        for subsectionContent in content.subsections {
            guard let subsectionTitle = subsectionContent.subsection else { continue }
            
            let subsection = ATCSubsection(
                title: subsectionTitle,
                description: subsectionContent.description,
                lessons: []
            )
            
            // Convert section name to full title
            let sectionKey = convertSectionName(subsectionContent.section)
            if sectionsDict[sectionKey] == nil {
                sectionsDict[sectionKey] = ATCSection(
                    title: sectionKey,
                    description: "",
                    subsections: []
                )
            }
            
            sectionsDict[sectionKey]?.subsections.append(subsection)
        }
        
        // Add lessons to appropriate subsections
        for lessonContent in content.lessons {
            let lesson = createLesson(from: lessonContent)
            let sectionKey = convertSectionName(lessonContent.section)
            
            if let sectionIndex = sectionsDict[sectionKey]?.subsections.firstIndex(
                where: { $0.title == lessonContent.subsection }
            ) {
                sectionsDict[sectionKey]?.subsections[sectionIndex].lessons.append(lesson)
            }
        }
        
        // Update section descriptions from app content
        for appContent in content.appContent where appContent.type == "Section" {
            if let section = sectionsDict[appContent.title] {
                sectionsDict[appContent.title] = ATCSection(
                    title: appContent.title,
                    description: appContent.description,
                    subsections: section.subsections
                )
            }
        }
        
        sections = Array(sectionsDict.values).sorted { first, second in
            first.title == "VFR Training" && second.title == "IFR Training"
        }
    }
    
    private func convertSectionName(_ name: String) -> String {
        switch name {
        case "VFR":
            return "VFR Training"
        case "IFR":
            return "IFR Training"
        default:
            return name
        }
    }
    
    private func createLesson(from content: LessonContent) -> ATCLesson {
        let lessonID = "\(content.section)-\(content.subsection.replacingOccurrences(of: " ", with: ""))-\(content.lessonNumber)"
        print("Creating lesson with ID: \(lessonID)")
        return ATCLesson(
            title: content.title,
            objective: content.objective,
            isControlled: content.controlled.lowercased() == "yes",
            lessonID: lessonID
        )
    }
} 