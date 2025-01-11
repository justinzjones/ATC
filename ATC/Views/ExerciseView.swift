import SwiftUI
import AVFoundation

struct ExerciseView: View {
    let scenarios: [ATCScenario]
    @StateObject private var synthesizer = SpeechSynthesizer()
    @State private var currentScenarioIndex = 0
    @State private var userResponse = ""
    @State private var feedback = ""
    @State private var showingFeedback = false
    @State private var score = 0
    
    private var currentScenario: ATCScenario {
        guard currentScenarioIndex < scenarios.count else {
            // Return the first scenario as a fallback
            return scenarios.first ?? ATCScenario.sampleScenarios[0]
        }
        return scenarios[currentScenarioIndex]
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [Color(.systemGray6), Color(.systemBackground)],
                         startPoint: .top,
                         endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Progress and Score
                    HStack {
                        // Progress indicator
                        HStack(spacing: 4) {
                            Image(systemName: "airplane")
                                .foregroundStyle(.blue)
                            Text("Scenario \(currentScenarioIndex + 1) of \(scenarios.count)")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline.bold())
                        
                        Spacer()
                        
                        // Score display
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("Score: \(score)")
                                .foregroundStyle(.primary)
                        }
                        .font(.subheadline.bold())
                    }
                    .padding(.horizontal)
                    
                    // Situation Description
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Situation", systemImage: "info.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.blue)
                        Text(currentScenario.situation)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // ATC Message
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("ATC Message", systemImage: "radio.fill")
                                .font(.headline)
                                .foregroundStyle(.purple)
                            Spacer()
                            Button {
                                synthesizer.speak(currentScenario.atcMessage)
                            } label: {
                                Label(synthesizer.isSpeaking ? "Stop" : "Play",
                                      systemImage: synthesizer.isSpeaking ? "stop.circle.fill" : "play.circle.fill")
                                    .font(.headline)
                                    .foregroundStyle(.purple)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.purple.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        Text(currentScenario.atcMessage)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.purple.opacity(0.1))
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // User Response
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Your Response", systemImage: "mic.fill")
                            .font(.headline)
                            .foregroundStyle(.green)
                        TextEditor(text: $userResponse)
                            .frame(height: 100)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 2)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Submit Button
                    Button(action: evaluateResponse) {
                        Text("Submit Response")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.blue, .purple],
                                             startPoint: .leading,
                                             endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    if !feedback.isEmpty {
                        // Feedback Section
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Feedback", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.orange)
                            Text(feedback)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.1))
                                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        // Next Button
                        if currentScenarioIndex < scenarios.count - 1 {
                            Button(action: nextScenario) {
                                Text("Next Scenario")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(colors: [.green, .mint],
                                                     startPoint: .leading,
                                                     endPoint: .trailing)
                                    )
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Practice Exercise")
    }
    
    private func evaluateResponse() {
        let cleanedResponse = standardizeResponse(userResponse)
        let result = evaluateResponseComponents(response: cleanedResponse)
        
        // Calculate final score and generate feedback
        let finalScore = Int(result.score * 10)  // Convert to 0-10 scale
        score += finalScore
        
        // Generate detailed feedback
        if result.score >= 0.9 {
            if result.score == 1.0 {
                feedback = "Excellent! Perfect response."
            } else {
                feedback = "Very good! Response contains acceptable variations but is correct."
            }
        } else if result.score >= 0.7 {
            feedback = "Good response with minor variations.\nCorrect elements: \(result.correctElements.joined(separator: ", "))"
            if !result.missingElements.isEmpty {
                feedback += "\nMissing or incorrect: \(result.missingElements.joined(separator: ", "))"
            }
        } else {
            feedback = "Review needed. Missing key elements: \(result.missingElements.joined(separator: ", "))"
        }
    }
    
    private func nextScenario() {
        currentScenarioIndex += 1
        userResponse = ""
        feedback = ""
    }
    
    private func standardizeResponse(_ response: String) -> String {
        return response.lowercased()
            .replacingOccurrences(of: "runway one three left", with: "runway 13 left")
            .replacingOccurrences(of: "runway one three right", with: "runway 13 right")
            .replacingOccurrences(of: "runway one three center", with: "runway 13 center")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private struct EvaluationResult {
        var score: Double
        var missingElements: [String]
        var correctElements: [String]
    }
    
    private func evaluateResponseComponents(response: String) -> EvaluationResult {
        var missingElements: [String] = []
        var correctElements: [String] = []
        var componentScores: [Double] = []
        
        // Check for each keyword
        for keyword in currentScenario.keywords {
            if response.contains(keyword.lowercased()) {
                correctElements.append(keyword)
                componentScores.append(1.0)
            } else {
                missingElements.append(keyword)
                componentScores.append(0.0)
            }
        }
        
        // Calculate total score
        let totalScore = componentScores.isEmpty ? 0 : componentScores.reduce(0, +) / Double(componentScores.count)
        
        return EvaluationResult(
            score: totalScore,
            missingElements: missingElements,
            correctElements: correctElements
        )
    }
}

#Preview {
    NavigationStack {
        ExerciseView(scenarios: ATCScenario.sampleScenarios)
    }
} 