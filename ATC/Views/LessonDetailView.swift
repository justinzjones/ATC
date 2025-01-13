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
                isControlled: lesson.isControlled
            )
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LessonDetailView(lesson: ATCLesson(
            title: "Sample Lesson",
            objective: "This is a sample lesson objective",
            isControlled: true,
            lessonID: "VFR-TaxiOut-1"
        ))
    }
} 