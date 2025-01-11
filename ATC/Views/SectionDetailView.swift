import SwiftUI

struct SectionDetailView: View {
    let section: ATCSection
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [Color(.systemGray6), Color(.systemBackground)],
                         startPoint: .top,
                         endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Section description (no card)
                    Text(section.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Subsections
                    ForEach(section.subsections) { subsection in
                        SubsectionCardView(subsection: subsection)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(section.title)
    }
}

struct SubsectionCardView: View {
    let subsection: ATCSubsection
    
    var body: some View {
        NavigationLink(destination: SubsectionDetailView(subsection: subsection)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    // Icon with gradient background
                    Image(systemName: iconName(for: subsection))
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(backgroundGradient(for: subsection))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(subsection.title)
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                        Text(subsection.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconName(for subsection: ATCSubsection) -> String {
        switch subsection.title {
        case "Taxi Out":
            return "airplane.departure"
        case "Taxi In":
            return "airplane.arrival"
        case "Takeoff":
            return "arrow.up.circle"
        case "Flight Plan":
            return "doc.text"
        case "Flight Following":
            return "binoculars"
        case "Airspace Entry":
            return "map"
        case "Approach":
            return "arrow.down.circle"
        default:
            return "airplane"
        }
    }
    
    private func backgroundGradient(for subsection: ATCSubsection) -> LinearGradient {
        switch subsection.title {
        case "Taxi Out", "Taxi In":
            return LinearGradient(colors: [.orange, .orange.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        case "Takeoff", "Approach":
            return LinearGradient(colors: [.blue, .blue.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        case "Flight Plan":
            return LinearGradient(colors: [.purple, .purple.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        case "Flight Following":
            return LinearGradient(colors: [.green, .green.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        case "Airspace Entry":
            return LinearGradient(colors: [.red, .red.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        default:
            return LinearGradient(colors: [.gray, .gray.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        }
    }
}

struct SubsectionDetailView: View {
    let subsection: ATCSubsection
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [Color(.systemGray6), Color(.systemBackground)],
                         startPoint: .top,
                         endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Description text (no card)
                    Text(subsection.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Lessons
                    ForEach(subsection.lessons) { lesson in
                        NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                            LessonCardView(lesson: lesson)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(subsection.title)
    }
}

struct LessonCardView: View {
    let lesson: ATCLesson
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            Image(systemName: iconName(for: lesson))
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(backgroundGradient(for: lesson))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Text(lesson.objective)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
    }
    
    private func iconName(for lesson: ATCLesson) -> String {
        switch lesson.title {
        case let title where title.contains("Self announce"):
            return "megaphone"
        case let title where title.contains("Basic"):
            return "airplane"
        case let title where title.contains("Complex"):
            return "airplane.circle"
        default:
            return "airplane"
        }
    }
    
    private func backgroundGradient(for lesson: ATCLesson) -> LinearGradient {
        switch lesson.title {
        case let title where title.contains("Self announce"):
            return LinearGradient(colors: [.green, .green.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        case let title where title.contains("Basic"):
            return LinearGradient(colors: [.blue, .blue.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        case let title where title.contains("Complex"):
            return LinearGradient(colors: [.orange, .orange.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        default:
            return LinearGradient(colors: [.gray, .gray.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        }
    }
}

#Preview {
    NavigationStack {
        SectionDetailView(section: ATCSection(
            title: "Sample Section",
            description: "This is a sample section description",
            subsections: [
                ATCSubsection(
                    title: "Sample Subsection",
                    description: "This is a sample subsection description",
                    lessons: [
                        ATCLesson(
                            title: "Sample Lesson",
                            objective: "This is a sample lesson objective",
                            type: .radioScenario,
                            scenarios: []
                        )
                    ]
                )
            ]
        ))
    }
} 