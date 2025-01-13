import Foundation

struct ExerciseSummaryItem: Identifiable {
    let id = UUID()
    let title: String
    let isCompleted: Bool
} 