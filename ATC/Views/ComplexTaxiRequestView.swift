import SwiftUI
import AVFoundation

struct ComplexTaxiRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settings = ATCSettings.shared
    @StateObject private var synthesizer: SpeechSynthesizer = {
        let synth = SpeechSynthesizer()
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-premium") {
            synth.updateVoice(voice.identifier)
        }
        return synth
    }()
    @State private var initialElements: [TaxiRequestElement] = []
    @State private var selectedElements: [TaxiRequestElement] = []
    @State private var readbackElements: [TaxiRequestElement] = []
    @State private var selectedReadbackElements: [TaxiRequestElement] = []
    @State private var controllerResponse: ControllerResponse?
    @State private var isRequestExpanded = true
    @State private var isControllerResponseExpanded = false
    @State private var isReadbackExpanded = false
    @State private var isReadbackCorrect = false
    @State private var showControllerResponse = false
    @State private var readbackFeedback: String?
    
    var situationText: String {
        "You are parked at the West Ramp of \(settings.homeAirport.name) and ready to taxi for departure. Multiple runways are active, and you'll need to cross other runways to reach your departure runway. Request taxi clearance from Ground Control."
    }
    
    var requestSectionHeader: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "mic")
                    .foregroundStyle(.purple)
                Text("Your Request")
                    .foregroundStyle(.primary)
                if showControllerResponse {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                }
            }
            .font(.subheadline.weight(.medium))
            Spacer()
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Exercise Title
                HStack {
                    Text("Exercise 2: Complex Taxi Instructions")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)
                
                if !isReadbackCorrect {
                    // Situation Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "airplane")
                                .foregroundStyle(.blue)
                            Text("Situation")
                                .foregroundStyle(.blue)
                        }
                        .font(.subheadline.weight(.medium))
                        
                        Text(situationText)
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Your Request Section
                    VStack(spacing: 0) {
                        requestSectionHeader
                            .padding()
                        
                        if isRequestExpanded {
                            VStack(spacing: 16) {
                                // Selected elements
                                if !selectedElements.isEmpty {
                                    FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                                        ForEach(selectedElements) { element in
                                            RequestPill(text: element.text, type: element.type)
                                                .onTapGesture {
                                                    moveElement(element, from: &selectedElements, to: &initialElements)
                                                }
                                        }
                                    }
                                }
                                
                                // Available elements
                                if !initialElements.isEmpty {
                                    FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                                        ForEach(initialElements) { element in
                                            RequestPill(text: element.text, type: element.type)
                                                .onTapGesture {
                                                    moveElement(element, from: &initialElements, to: &selectedElements)
                                                }
                                        }
                                    }
                                }
                                
                                // Submit button
                                Button(action: validateRequest) {
                                    Text("Submit Request")
                                        .font(.subheadline.weight(.medium))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .disabled(selectedElements.isEmpty)
                                .padding(.top, 8)
                            }
                            .padding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // ATC Response Section
                    if showControllerResponse {
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "tower.cell.broadcast")
                                        .foregroundStyle(.green)
                                    Text("ATC Response")
                                        .foregroundStyle(.primary)
                                }
                                .font(.subheadline.weight(.medium))
                                Spacer()
                                Button(action: {
                                    let elements = controllerResponse?.elements ?? []
                                    var chunks: [String] = []
                                    var currentChunk: [String] = []
                                    
                                    for element in elements {
                                        switch element.text {
                                        case _ where element.type == .callsign:
                                            // Callsign is its own chunk
                                            chunks.append(element.text)
                                            
                                        case "in use":
                                            // Complete the active runway chunk
                                            currentChunk.append(element.text)
                                            chunks.append(currentChunk.joined(separator: " "))
                                            currentChunk = []
                                            
                                        case "Taxi to":
                                            // Start a new taxi instruction chunk
                                            currentChunk = [element.text]
                                            
                                        case "hold short":
                                            // Complete previous chunk if any
                                            if !currentChunk.isEmpty {
                                                chunks.append(currentChunk.joined(separator: " "))
                                                currentChunk = []
                                            }
                                            // Start hold short chunk
                                            currentChunk = [element.text]
                                            
                                        case "monitor Tower":
                                            // Complete previous chunk if any
                                            if !currentChunk.isEmpty {
                                                chunks.append(currentChunk.joined(separator: " "))
                                                currentChunk = []
                                            }
                                            // Start monitor tower chunk
                                            currentChunk = [element.text]
                                            
                                        case "118.7":
                                            // Add frequency with proper pronunciation
                                            currentChunk.append("one one eight point seven")
                                            
                                        case "when ready":
                                            // Complete the monitor tower chunk
                                            currentChunk.append(element.text)
                                            chunks.append(currentChunk.joined(separator: " "))
                                            currentChunk = []
                                            
                                        default:
                                            currentChunk.append(element.text)
                                        }
                                    }
                                    
                                    // Add any remaining chunk
                                    if !currentChunk.isEmpty {
                                        chunks.append(currentChunk.joined(separator: " "))
                                    }
                                    
                                    let formattedText = chunks.joined(separator: " | ")
                                    synthesizer.speak(formattedText)
                                }) {
                                    Image(systemName: "speaker.wave.2")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding()
                            
                            if !isReadbackCorrect {
                                VStack(alignment: .leading, spacing: 16) {
                                    // Message Display
                                    Text("\"\(controllerResponse?.elements.map { $0.text }.joined(separator: " ") ?? "")\"")
                                        .font(.title3)
                                        .foregroundStyle(.primary)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding()
                            }
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Readback Section
                    if showControllerResponse {
                        VStack(spacing: 0) {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "mic")
                                        .foregroundStyle(.purple)
                                    Text("Your Readback")
                                        .foregroundStyle(.primary)
                                    if isReadbackCorrect {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.green)
                                    }
                                }
                                .font(.subheadline.weight(.medium))
                                Spacer()
                            }
                            .padding()
                            
                            if !isReadbackCorrect {
                                VStack(spacing: 16) {
                                    // Selected readback elements
                                    if !selectedReadbackElements.isEmpty {
                                        FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                                            ForEach(selectedReadbackElements) { element in
                                                RequestPill(text: element.text, type: element.type)
                                                    .onTapGesture {
                                                        moveElement(element, from: &selectedReadbackElements, to: &readbackElements)
                                                    }
                                            }
                                        }
                                    }
                                    
                                    // Available readback elements
                                    if !readbackElements.isEmpty {
                                        FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                                            ForEach(readbackElements) { element in
                                                RequestPill(text: element.text, type: element.type)
                                                    .onTapGesture {
                                                        moveElement(element, from: &readbackElements, to: &selectedReadbackElements)
                                                    }
                                            }
                                        }
                                    }
                                    
                                    // Submit button
                                    Button(action: validateReadback) {
                                        Text("Submit Readback")
                                            .font(.subheadline.weight(.medium))
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundStyle(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .disabled(selectedReadbackElements.isEmpty)
                                    .padding(.top, 8)
                                }
                                .padding()
                            }
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                } else {
                    // Progress Summary Card
                    VStack(spacing: 12) {
                        VStack(spacing: 8) {
                            ProgressCard(text: "Situation Review", hasAudio: false)
                            ProgressCard(text: "ATC Request", hasAudio: false)
                            ProgressCard(text: "ATC Response", hasAudio: true)
                            ProgressCard(text: "Readback Complete", hasAudio: false)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    HStack {
                        Text("Exercise Complete")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("All requirements met")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
                    .padding(.horizontal)
                    
                    Button(action: { dismiss() }) {
                        Text("Continue to Next Exercise")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            resetElements()
        }
    }
    
    private func moveElement(_ element: TaxiRequestElement, from source: inout [TaxiRequestElement], to destination: inout [TaxiRequestElement]) {
        if let index = source.firstIndex(of: element) {
            source.remove(at: index)
            destination.append(element)
        }
    }
    
    private func resetElements() {
        initialElements = TaxiInstruction.elements(complexity: .complex)
        selectedElements = []
        readbackElements = []
        selectedReadbackElements = []
        controllerResponse = nil
        showControllerResponse = false
        isReadbackCorrect = false
        readbackFeedback = nil
    }
    
    private func validateRequest() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            controllerResponse = TaxiInstruction.validateRequest(selectedElements, complexity: .complex)
            if controllerResponse?.isCorrect == true {
                showControllerResponse = true
                isRequestExpanded = false
                isControllerResponseExpanded = true
                isReadbackExpanded = false
                readbackElements = TaxiInstruction.generateReadbackElements(from: controllerResponse!.elements, complexity: .complex)
            }
        }
    }
    
    private func validateReadback() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            guard let response = controllerResponse else { return }
            isReadbackCorrect = TaxiInstruction.validateReadback(selectedReadbackElements, controllerResponse: response.elements, complexity: .complex)
            if isReadbackCorrect {
                isControllerResponseExpanded = false
                isReadbackExpanded = false
            } else {
                readbackFeedback = "Incorrect readback. Please try again."
            }
        }
    }
}

#Preview {
    ComplexTaxiRequestView()
} 