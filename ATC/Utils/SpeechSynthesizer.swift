import Foundation
import AVFoundation

@MainActor
class SpeechSynthesizer: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    private var currentVoice: AVSpeechSynthesisVoice?
    
    override init() {
        super.init()
        synthesizer.delegate = self
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-premium") {
            currentVoice = voice
            print("Using voice: \(voice.name)")
        } else {
            setupPreferredVoice()
        }
    }
    
    func updateVoice(_ identifier: String) {
        if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.identifier == identifier }) {
            currentVoice = voice
            print("Voice updated to: \(voice.name)")
        }
    }
    
    private func setupPreferredVoice() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        // Try to find a male US English voice first
        if let maleVoice = voices.first(where: { $0.language.starts(with: "en-US") && $0.gender == .male }) {
            currentVoice = maleVoice
            print("Using male voice: \(maleVoice.name)")
            return
        }
        
        // Fallback to any US English voice
        currentVoice = AVSpeechSynthesisVoice(language: "en-US")
        print("Fallback to default voice: \(currentVoice?.name ?? "unknown")")
    }
    
    func speak(_ text: String) {
        if isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
            return
        }
        
        // Format the text for ATC-style speech
        let formattedText = formatForSpeech(text)
        
        let utterance = AVSpeechUtterance(string: formattedText)
        
        // Configure for natural ATC-style speech
        utterance.rate = 0.52  // Natural ATC pace
        utterance.pitchMultiplier = 0.95  // Slightly lower for authority
        utterance.volume = 1.0
        
        if let voice = currentVoice {
            utterance.voice = voice
        }
        
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    private func formatForSpeech(_ text: String) -> String {
        // Format callsigns (N followed by numbers and letters)
        let callsignRegex = try! NSRegularExpression(pattern: "N\\d{1,5}[A-Z]{1,2}")
        var formattedText = text
        
        // Process callsigns
        let range = NSRange(text.startIndex..., in: text)
        let matches = callsignRegex.matches(in: text, range: range)
        
        // Process matches in reverse order to not affect subsequent ranges
        for match in matches.reversed() {
            if let range = Range(match.range, in: text) {
                let callsign = String(text[range])
                var result = "november "
                
                for char in callsign.dropFirst() {
                    if let number = ATCPhraseology.General.numbers[String(char)] {
                        result += "\(number) "
                    } else if let letter = ATCPhraseology.General.phonetics[String(char)] {
                        result += "\(letter) "
                    } else {
                        result += "\(char) "
                    }
                }
                
                formattedText = formattedText.replacingCharacters(in: range, with: result.trimmingCharacters(in: .whitespaces))
            }
        }
        
        // Format runway numbers
        let runwayRegex = try! NSRegularExpression(pattern: "Runway (\\d{1,2})")
        let runwayRange = NSRange(formattedText.startIndex..., in: formattedText)
        let runwayMatches = runwayRegex.matches(in: formattedText, range: runwayRange)
        
        for match in runwayMatches.reversed() {
            if let matchRange = Range(match.range, in: formattedText),
               let numberRange = Range(match.range(at: 1), in: formattedText) {
                let runway = String(formattedText[numberRange])
                let numbers = runway.map { ATCPhraseology.General.numbers[String($0)] ?? String($0) }
                let replacement = "Runway \(numbers.joined(separator: " "))"
                formattedText = formattedText.replacingCharacters(in: matchRange, with: replacement)
            }
        }
        
        // Add slight pauses after key phrases
        return formattedText.replacingOccurrences(of: ",", with: "... ")
            .replacingOccurrences(of: ".", with: "... ")
    }
    
    func stop() {
        if isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        }
    }
    
    // AVSpeechSynthesizerDelegate methods
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
} 