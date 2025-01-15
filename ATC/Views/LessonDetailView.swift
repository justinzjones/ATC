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
            
            CommunicationExerciseView(
                lessonTitle: lesson.title,
                objective: lesson.objective,
                isControlled: lesson.isControlled,
                lessonID: lesson.lessonID
            )
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LessonDetailView(lesson: ATCLesson(
            title: "Basic Taxi Request",
            objective: "Practice basic taxi requests",
            isControlled: true,
            lessonID: "VFR-TaxiOut-2"
        ))
    }
} 