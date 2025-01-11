import Foundation

class ATCTrainingViewModel: ObservableObject {
    @Published var sections: [ATCSection] = []
    @Published var selectedSection: ATCSection?
    @Published var selectedSubsection: ATCSubsection?
    
    private let dataLoader = DataLoader()
    
    init() {
        loadTrainingData()
    }
    
    private func loadTrainingData() {
        guard let content = dataLoader.loadTrainingData() else {
            print("❌ Failed to load training data")
            return
        }
        
        print("📱 App Content count: \(content.appContent.count)")
        print("📚 Subsections count: \(content.subsections.count)")
        print("📖 Lessons count: \(content.lessons.count)")
        
        // Debug print the actual data
        print("\nApp Content:")
        content.appContent.forEach { print("- Type: \($0.type), Title: \($0.title)") }
        
        print("\nSubsections:")
        content.subsections.forEach { print("- Section: \($0.section), Subsection: \($0.subsection ?? "nil")") }
        
        print("\nLessons:")
        content.lessons.forEach { print("- Section: \($0.section), Subsection: \($0.subsection), Title: \($0.title)") }
        
        // Convert the loaded data into our view models
        let sections = content.appContent
            .filter { $0.type == "Section" }
            .map { sectionContent in
                print("🔷 Processing section: \(sectionContent.title)")
                
                // Extract the prefix (VFR/IFR) from the section title
                let sectionPrefix = sectionContent.title.split(separator: " ").first?.description ?? ""
                
                let subsections = content.subsections
                    .filter { $0.section == sectionPrefix }  // Match on VFR/IFR prefix
                    .compactMap { subsectionContent -> ATCSubsection? in
                        print("  📍 Found subsection: \(subsectionContent.subsection ?? "")")
                        
                        let lessons = content.lessons
                            .filter { lesson in
                                lesson.section == sectionPrefix &&  // Match on VFR/IFR prefix
                                lesson.subsection == subsectionContent.subsection
                            }
                            .map { lesson in
                                print("    📝 Found lesson: \(lesson.title)")
                                return ATCLesson(
                                    title: lesson.title,
                                    objective: lesson.objective,
                                    type: lesson.communicationType.contains("Request") ? .taxiRequest : .radioScenario,
                                    scenarios: []
                                )
                            }
                        
                        return ATCSubsection(
                            title: subsectionContent.subsection ?? "",
                            description: subsectionContent.description,
                            lessons: lessons
                        )
                    }
                
                return ATCSection(
                    title: sectionContent.title,
                    description: sectionContent.description,
                    subsections: subsections
                )
            }
        
        self.sections = sections
    }
} 