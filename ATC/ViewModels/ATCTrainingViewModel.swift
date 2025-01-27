import Foundation
import SwiftUI

@MainActor
class ATCTrainingViewModel: ObservableObject {
    @Published private(set) var sections: [ATCSection] = []
    @Published private(set) var subsections: [SubsectionContent] = []
    @Published private(set) var subsectionLessons: [String: [LessonContent]] = [:]
    @Published private(set) var isLoadingLessons = false
    
    private let dataLoader = DataLoader()
    
    init() {
        print("ATCTrainingViewModel initialized")
        loadInitialContent()
    }
    
    private func loadInitialContent() {
        print("Loading initial content...")
        if let content = dataLoader.load() {
            print("Content loaded: \(content.appContent.count) sections")
            
            // Convert AppContent to ATCSection
            sections = content.appContent.map { appContent in
                print("\nProcessing section: \(appContent.title)")
                
                // Map section titles to their JSON counterparts
                let sectionKey = appContent.title.replacingOccurrences(of: " Training", with: "")
                
                // Debug subsection filtering
                let matchingSubsections = content.subsections.filter { $0.section == sectionKey }
                print("Found \(matchingSubsections.count) subsections for \(appContent.title) (key: \(sectionKey))")
                matchingSubsections.forEach { subsection in
                    print("- Subsection: \(subsection.subsection ?? "nil"), Section: \(subsection.section ?? "nil")")
                }
                
                let sectionSubsections = matchingSubsections.map { subsection in
                    print("Creating subsection: \(subsection.subsection ?? "")")
                    return ATCSubsection(
                        title: subsection.subsection ?? "",
                        description: subsection.description ?? "",
                        lessons: []  // We'll load these lazily
                    )
                }
                
                return ATCSection(
                    title: appContent.title,
                    description: appContent.description,
                    subsections: sectionSubsections
                )
            }
            
            subsections = content.subsections
            print("\nFinished loading:")
            sections.forEach { section in
                print("Section: \(section.title), Subsections: \(section.subsections.count)")
                section.subsections.forEach { subsection in
                    print("- \(subsection.title)")
                }
            }
        } else {
            print("Failed to load content")
        }
    }
    
    func loadLessons(for subsectionID: String) async {
        print("Loading lessons for subsection: \(subsectionID)")
        // Return if already loaded
        guard subsectionLessons[subsectionID] == nil else {
            print("Lessons already loaded for: \(subsectionID)")
            return
        }
        
        await MainActor.run { isLoadingLessons = true }
        
        if let lessons = dataLoader.loadLessons(for: subsectionID) {
            print("Loaded \(lessons.count) lessons for subsection: \(subsectionID)")
            await MainActor.run {
                subsectionLessons[subsectionID] = lessons
                isLoadingLessons = false
            }
        } else {
            print("Failed to load lessons for: \(subsectionID)")
        }
    }
    
    func getLessons(for subsectionID: String) -> [LessonContent] {
        return subsectionLessons[subsectionID] ?? []
    }
} 