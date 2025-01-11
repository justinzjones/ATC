import Foundation

struct ATCScenario: Identifiable {
    let id = UUID()
    let situation: String
    let atcMessage: String
    let expectedResponse: String
    let keywords: [String]
    let difficulty: Int
}

// Sample scenarios
extension ATCScenario {
    static let sampleScenarios = [
        ATCScenario(
            situation: "You are approaching KJFK runway 13L",
            atcMessage: "N123AB, Kennedy Tower, runway 13L, cleared to land, wind 140 at 10",
            expectedResponse: "Cleared to land runway 13L, N123AB",
            keywords: ["cleared", "land", "13L"],
            difficulty: 1
        ),
        ATCScenario(
            situation: "You are ready for departure at KJFK",
            atcMessage: "N123AB, Kennedy Tower, runway 13L, cleared for takeoff, wind 140 at 10",
            expectedResponse: "Cleared for takeoff runway 13L, N123AB",
            keywords: ["cleared", "takeoff", "13L"],
            difficulty: 1
        )
    ]
} 