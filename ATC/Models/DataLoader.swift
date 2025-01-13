import Foundation

class DataLoader {
    func loadContent() -> TrainingContent? {
        guard let url = Bundle.main.url(forResource: "ATC_Training_Structure_v1", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to find or read JSON file")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let content = try decoder.decode(TrainingContent.self, from: data)
            print("Successfully loaded content with \(content.appContent.count) app content items")
            print("Loaded \(content.subsections.count) subsections")
            print("Loaded \(content.lessons.count) lessons")
            return content
        } catch {
            print("Error decoding content: \(error)")
            return nil
        }
    }
    
    func loadCommunications() -> [ExerciseCommunication]? {
        guard let content = loadContent() else { return nil }
        return content.communications
    }
    
    func getIntroduction() -> AppContent? {
        guard let content = loadContent() else { return nil }
        return content.appContent.first { $0.type == "Introduction" }
    }
}

struct CommunicationsContent: Codable {
    let communications: [ExerciseCommunication]
    
    enum CodingKeys: String, CodingKey {
        case communications = "Communications"
    }
} 