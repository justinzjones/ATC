import Foundation

class DataLoader {
    func load() -> TrainingContent? {
        print("DataLoader: Attempting to load ATC_Training_Structure_v1.json")
        
        guard let url = Bundle.main.url(forResource: "ATC_Training_Structure_v1", withExtension: "json") else {
            print("DataLoader: Could not find ATC_Training_Structure_v1.json in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            print("DataLoader: Successfully read \(data.count) bytes")
            
            let content = try JSONDecoder().decode(TrainingContent.self, from: data)
            print("DataLoader: Successfully decoded content")
            return content
            
        } catch {
            print("DataLoader: Error loading/decoding content: \(error)")
            return nil
        }
    }
    
    func loadLessons(for subsectionID: String) -> [LessonContent]? {
        print("DataLoader: Loading lessons for subsection: \(subsectionID)")
        if let content = load() {
            let lessons = content.lessons.filter { $0.subsection == subsectionID }
            print("DataLoader: Found \(lessons.count) lessons")
            return lessons.sorted { $0.lessonNumber < $1.lessonNumber }
        }
        print("DataLoader: Failed to load lessons")
        return nil
    }
    
    func loadCommunications() -> [ExerciseCommunication]? {
        guard let content = load() else { return nil }
        return content.communications
    }
    
    func getIntroduction() -> AppContent? {
        guard let content = load() else { return nil }
        return content.appContent.first { $0.type == "Introduction" }
    }
}

struct CommunicationsContent: Codable {
    let communications: [ExerciseCommunication]
    
    enum CodingKeys: String, CodingKey {
        case communications = "Communications"
    }
} 