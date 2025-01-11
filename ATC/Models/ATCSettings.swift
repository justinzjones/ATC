import Foundation
import SwiftUI

struct Airport: Codable, Equatable, Hashable {
    let code: String
    let name: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
    
    static func == (lhs: Airport, rhs: Airport) -> Bool {
        lhs.code == rhs.code
    }
}

class ATCSettings: ObservableObject {
    static let shared = ATCSettings()
    
    private let defaults = UserDefaults.standard
    private let homeAirportKey = "homeAirport"
    private let aircraftCallsignKey = "aircraftCallsignKey"
    
    // Sample airports with their proper names
    let airports = [
        Airport(code: "KDTO", name: "Denton"),
        Airport(code: "KFTW", name: "Meacham"),
        Airport(code: "KDFW", name: "DFW"),
        Airport(code: "KDAL", name: "Dallas"),
        Airport(code: "KADS", name: "Addison"),
        Airport(code: "KAFW", name: "Alliance")
    ]
    
    @Published var homeAirport: Airport {
        didSet {
            if let data = try? JSONEncoder().encode(homeAirport) {
                defaults.set(data, forKey: homeAirportKey)
            }
        }
    }
    
    @Published var aircraftCallsign: String {
        didSet {
            defaults.set(aircraftCallsign, forKey: aircraftCallsignKey)
        }
    }
    
    @AppStorage("selectedAirport") var selectedAirport: String?
    @AppStorage("callSign") var callSign: String?
    
    // Generate a random N-number if none is set
    func generateRandomCallsign() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
        let numbers = "0123456789"
        
        let randomNumbers = String((0..<3).map { _ in numbers.randomElement()! })
        let randomLetters = String((0..<2).map { _ in letters.randomElement()! })
        
        return "N\(randomNumbers)\(randomLetters)"
    }
    
    private init() {
        // Initialize home airport first
        if let data = defaults.data(forKey: homeAirportKey),
           let airport = try? JSONDecoder().decode(Airport.self, from: data) {
            self.homeAirport = airport
        } else {
            self.homeAirport = airports[0] // Default to Denton
        }
        
        // Initialize callsign with a default value first
        self.aircraftCallsign = "N12345"
        
        // Then update it if we have a saved value or generate a new one
        if let callsign = defaults.string(forKey: aircraftCallsignKey) {
            self.aircraftCallsign = callsign
        } else {
            self.aircraftCallsign = generateRandomCallsign()
        }
    }
    
    func setCallSign(_ callSign: String) {
        self.callSign = callSign
    }
    
    func clearCallSign() {
        self.callSign = nil
    }
} 