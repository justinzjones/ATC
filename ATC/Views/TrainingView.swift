import SwiftUI

struct TrainingView: View {
    @StateObject private var viewModel = ATCTrainingViewModel()
    let dataLoader = DataLoader()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(colors: [Color(.systemGray6), Color(.systemBackground)],
                             startPoint: .top,
                             endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        Text(dataLoader.getIntroduction()?.description ?? "Welcome to ATC Training. Through a series of interactive exercises you'll learn how to communicate with Air Traffic Control effectively.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                        
                        ForEach(viewModel.sections) { section in
                            NavigationLink(destination: SectionDetailView(section: section)) {
                                SectionCardView(section: section)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

struct SectionCardView: View {
    let section: ATCSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 16) {
                // Icon with gradient background
                Image(systemName: iconName(for: section))
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(backgroundGradient(for: section))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    Text(section.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
    }
    
    private func iconName(for section: ATCSection) -> String {
        switch section.title {
        case "VFR Training":
            return "graduationcap.fill"
        case "IFR Training":
            return "airplane"
        default:
            return "list.bullet"
        }
    }
    
    private func backgroundGradient(for section: ATCSection) -> LinearGradient {
        switch section.title {
        case "VFR Training":
            return LinearGradient(colors: [.blue, .blue.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        case "IFR Training":
            return LinearGradient(colors: [.green, .green.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        default:
            return LinearGradient(colors: [.blue, .blue.opacity(0.8)],
                              startPoint: .top,
                              endPoint: .bottom)
        }
    }
}

#Preview {
    TrainingView()
} 