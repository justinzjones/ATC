import Foundation

// Use TrainingLesson instead of Lesson
struct ATCContent: Codable {
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

class DataLoader {
    static let shared = DataLoader()
    
    init() {}
    
    func loadTrainingData() -> ATCContent? {
        guard let url = Bundle.main.url(forResource: "ATC_Training_Structure_v1", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error loading training data")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let content = try decoder.decode(ATCContent.self, from: data)
            return content
        } catch {
            print("Error decoding training data: \(error)")
            return nil
        }
    }
    
    func loadLessons() -> [TrainingLesson] {
        guard let content = loadTrainingData() else {
            return []
        }
        return content.lessons
    }
    
    func loadScenarios() -> [TrainingScenario] {
        guard let content = loadTrainingData() else {
            return []
        }
        return content.communications
    }
    
    func loadSubsections() -> [TrainingSubsection] {
        guard let content = loadTrainingData() else {
            return []
        }
        return content.subsections
    }
    
    func loadAppContent() -> [TrainingContent] {
        guard let content = loadTrainingData() else {
            return []
        }
        return content.appContent
    }
    
    func getCommunications(forLessonId lessonID: String) -> [TrainingScenario] {
        guard let content = loadTrainingData() else {
            return []
        }
        return content.communications.filter { $0.lessonID == lessonID }
    }
    
    func loadJSON<T: Decodable>(from filename: String) -> T? {
        print("📂 Attempting to load \(filename).json")
        
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            print("❌ Could not find \(filename).json in bundle")
            return nil
        }
        
        print("📍 Found file at path: \(path)")
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            print("📦 Successfully loaded data: \(data.count) bytes")
            
            let decoded = try JSONDecoder().decode(T.self, from: data)
            print("✅ Successfully decoded JSON")
            return decoded
        } catch {
            print("❌ Error loading/decoding JSON: \(error)")
            return nil
        }
    }
    
    func getIntroduction() -> TrainingContent? {
        guard let content = loadTrainingData() else {
            return nil
        }
        
        return content.appContent.first { content in
            content.type.lowercased() == "introduction"
        }
    }
} 