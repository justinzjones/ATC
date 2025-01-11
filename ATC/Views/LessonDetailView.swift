import SwiftUI

struct LessonDetailView: View {
    let lesson: ATCLesson
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [Color(.systemGray6), Color(.systemBackground)],
                         startPoint: .top,
                         endPoint: .bottom)
                .ignoresSafeArea()
            
            CommunicationExerciseView(lessonType: exerciseType)
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var exerciseType: CommunicationExerciseType {
        switch lesson.title.lowercased() {
        case let title where title.contains("uncontrolled"):
            return .uncontrolled
        case let title where title.contains("complex"):
            return .complex
        default:
            return .basic
        }
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LessonDetailView(lesson: ATCLesson(
                title: "Sample Lesson",
                objective: "This is a sample lesson objective",
                type: .radioScenario,
                scenarios: []
            ))
        }
    }
} 