import Foundation

class AirportManager {
    static let shared = AirportManager()
    private var airports: [AirportInfo] = []
    private var currentLocation: String?
    private var currentAirport: AirportInfo?
    private var currentCallsign: String?
    private var currentAtisCode: String?
    private let dataLoader = DataLoader()
    private var currentRunway: String?
    private var currentTaxiway: String?
    
    init() {
        print("🛫 Initializing AirportManager...")
        
        guard let url = Bundle.main.url(forResource: "Airports", withExtension: "json") else {
            print("❌ Could not find Airports.json in bundle")
            // Initialize with a default airport to prevent crashes
            airports = [
                AirportInfo(
                    icao: "KFTW",
                    iata: "FTW",
                    name: "Fort Worth Meacham International Airport",
                    shortName: "Meacham",
                    elevation: 710,
                    groundFrequencies: GroundFrequencies(
                        ground: .single("121.7"),
                        tower: .single("118.6"),
                        clearance: "118.6"
                    ),
                    runways: [],
                    taxiways: [],
                    fbos: [],
                    commonRoutes: []
                )
            ]
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            print("📦 Loaded \(data.count) bytes from Airports.json")
            
            let decoder = JSONDecoder()
            let airportData = try decoder.decode(AirportData.self, from: data)
            self.airports = airportData.airports
            print("✅ Successfully decoded \(airports.count) airports")
            
        } catch {
            print("❌ Error loading/decoding airports: \(error)")
            // Initialize with default airport on error
            airports = [
                AirportInfo(
                    icao: "KFTW",
                    iata: "FTW",
                    name: "Fort Worth Meacham International Airport",
                    shortName: "Meacham",
                    elevation: 710,
                    groundFrequencies: GroundFrequencies(
                        ground: .single("121.7"),
                        tower: .single("118.6"),
                        clearance: "118.6"
                    ),
                    runways: [],
                    taxiways: [],
                    fbos: [],
                    commonRoutes: []
                )
            ]
        }
    }
    
    func getRandomAirport() -> AirportInfo {
        airports.randomElement() ?? airports[0]
    }
    
    func getRandomCallsign() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"  // Excluding I and O to avoid confusion
        let numbers = "0123456789"
        
        // Randomly choose between 4 numbers + 1 letter OR 3 numbers + 2 letters
        let useExtraLetter = Bool.random()
        
        if useExtraLetter {
            // Format: N123AB
            let randomNumbers = String((0..<3).map { _ in numbers.randomElement()! })
            let randomLetters = String((0..<2).map { _ in letters.randomElement()! })
            return "N\(randomNumbers)\(randomLetters)"
        } else {
            // Format: N1234A
            let randomNumbers = String((0..<4).map { _ in numbers.randomElement()! })
            let randomLetter = String(letters.randomElement()!)
            return "N\(randomNumbers)\(randomLetter)"
        }
    }
    
    func getRandomAtisCode() -> String {
        ATCPhraseology.phonetics.randomElement()?.letter ?? "Alpha"
    }
    
    func resetForNewExercise() {
        currentLocation = nil
        currentAirport = getRandomAirport()
        currentCallsign = ATCSettings.shared.callSign ?? getRandomCallsign()
        currentAtisCode = getRandomAtisCode()
    }
    
    func getRandomRunway() -> String {
        if let currentAirport = currentAirport {
            if let runway = currentAirport.runways.randomElement() {
                // Split identifier like "17/35" and take one
                let options = runway.identifier.split(separator: "/")
                return String(options.randomElement() ?? options[0])
            }
        }
        return "17" // Default fallback
    }
    
    func getRandomTaxiway() -> String {
        if let currentAirport = currentAirport {
            if let taxiway = currentAirport.taxiways.randomElement() {
                return taxiway.identifier
            }
        }
        return "A" // Default fallback
    }
    
    func getPhoneticTaxiway(_ identifier: String) -> String {
        return identifier.map { char in
            if let phonetic = ATCPhraseology.General.phonetics[String(char).uppercased()] {
                return phonetic
            }
            return String(char)
        }.joined(separator: " ")
    }
    
    func processText(_ text: String, for airport: AirportInfo?, isATCResponse: Bool = false) -> String {
        let selectedAirport = currentAirport ?? getRandomAirport()
        currentAirport = selectedAirport  // Store the selected airport
        
        var processedText = text
        
        // Handle airport_location consistently
        if processedText.contains("{{airport_location}}") || processedText.contains("{{airport location}}") {
            if currentLocation == nil {
                if let randomFBO = selectedAirport.fbos.randomElement() {
                    currentLocation = randomFBO.location
                }
            }
            
            if let location = currentLocation {
                processedText = processedText.replacingOccurrences(
                    of: "{{airport_location}}",
                    with: location
                )
                processedText = processedText.replacingOccurrences(
                    of: "{{airport location}}",
                    with: location
                )
            }
        }
        
        // Handle runway number
        if processedText.contains("{{runway_number}}") || processedText.contains("{{runway number}}") {
            if currentRunway == nil {
                currentRunway = getRandomRunway()
            }
            processedText = processedText.replacingOccurrences(
                of: "{{runway_number}}",
                with: currentRunway ?? ""
            )
            processedText = processedText.replacingOccurrences(
                of: "{{runway number}}",
                with: currentRunway ?? ""
            )
        }
        
        // Handle taxiway with phonetics for ATC responses
        if processedText.contains("{{taxi_way}}") {
            if currentTaxiway == nil {
                currentTaxiway = getRandomTaxiway()
            }
            let taxiwayText = currentTaxiway ?? ""
            if isATCResponse {
                // Use phonetic alphabet for ATC responses
                processedText = processedText.replacingOccurrences(
                    of: "{{taxi_way}}",
                    with: getPhoneticTaxiway(taxiwayText)
                )
            } else {
                // Use regular identifier for pills
                processedText = processedText.replacingOccurrences(
                    of: "{{taxi_way}}",
                    with: taxiwayText
                )
            }
        }
        
        // Always use shortName for airport_name replacements
        processedText = processedText.replacingOccurrences(
            of: "{{airport_name}}",
            with: selectedAirport.shortName
        )
        
        // Use stored callsign
        if processedText.contains("{{call_sign}}") {
            if currentCallsign == nil {
                currentCallsign = ATCSettings.shared.callSign ?? getRandomCallsign()
            }
            processedText = processedText.replacingOccurrences(
                of: "{{call_sign}}",
                with: currentCallsign ?? ""
            )
        }
        
        // Use stored ATIS code
        if processedText.contains("{{atis_information}}") {
            if currentAtisCode == nil {
                currentAtisCode = getRandomAtisCode()
            }
            processedText = processedText.replacingOccurrences(
                of: "{{atis_information}}",
                with: currentAtisCode ?? ""
            )
        }
        
        // Handle quotes differently for ATC responses vs pills
        if isATCResponse {
            // Remove all existing quotes first
            processedText = processedText.replacingOccurrences(of: "\"", with: "")
            // Add quotes only at start and end of the full response, without extra space
            processedText = "\"\(processedText.trimmingCharacters(in: .whitespaces))\""
        } else {
            // Remove quotes entirely for pills
            processedText = processedText.replacingOccurrences(of: "\"", with: "")
        }
        
        return processedText
    }
    
    func resetCurrentLocation() {
        currentLocation = nil
        currentAirport = nil
        currentCallsign = nil
        currentAtisCode = nil
        currentRunway = nil
        currentTaxiway = nil
    }
} 