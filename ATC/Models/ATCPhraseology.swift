import Foundation

/// Based on FAA Order 7110.65Z - Air Traffic Control
struct ATCPhraseology {
    
    /// Section 2-1-1. General
    struct General {
        static let readbackRequirements = [
            "Runway assignments",
            "Taxi instructions",
            "Hold short instructions",
            "Takeoff and landing clearances",
            "Altimeter settings below 18,000 feet",
            "VFR/IFR altitude assignments",
            "Heading assignments",
            "Speed assignments",
            "Time restrictions",
            "Approach clearances"
        ]
        
        static let phonetics = [
            "A": "Alpha", "B": "Bravo", "C": "Charlie",
            "D": "Delta", "E": "Echo", "F": "Foxtrot",
            "G": "Golf", "H": "Hotel", "I": "India",
            "J": "Juliet", "K": "Kilo", "L": "Lima",
            "M": "Mike", "N": "November", "O": "Oscar",
            "P": "Papa", "Q": "Quebec", "R": "Romeo",
            "S": "Sierra", "T": "Tango", "U": "Uniform",
            "V": "Victor", "W": "Whiskey", "X": "X-Ray",
            "Y": "Yankee", "Z": "Zulu"
        ]
        
        static let numbers = [
            "0": "Zero", "1": "One", "2": "Two",
            "3": "Three", "4": "Four", "5": "Five",
            "6": "Six", "7": "Seven", "8": "Eight",
            "9": "Niner", ".": "Point"
        ]
    }
    
    /// Section 2-6-1. ATIS
    struct ATIS {
        static let elements = [
            "Airport name",
            "Time of weather",
            "Wind direction and velocity",
            "Visibility",
            "Ceiling and sky condition",
            "Temperature",
            "Dew point",
            "Altimeter setting",
            "Other remarks",
            "Approach in use",
            "Landing runway",
            "Departure runway",
            "NOTAMs",
            "Information code"
        ]
        
        static func formatWeather(
            wind: String,
            visibility: String,
            ceiling: String,
            temp: String,
            dewpoint: String,
            altimeter: String
        ) -> String {
            return "Wind \(wind), visibility \(visibility), ceiling \(ceiling), temperature \(temp), dewpoint \(dewpoint), altimeter \(altimeter)"
        }
    }
    
    /// Section 3-7-2. Taxi and Ground Movement Operations
    struct TaxiPhraseology {
        static let initialContact = [
            "Airport Ground",
            "Aircraft callsign",
            "Current location",
            "ATIS information code",
            "Ready to taxi"
        ]
        
        static let groundResponses = [
            "Runway [number] in use",
            "Taxi via [taxiways]",
            "Hold short of [runway/point]",
            "Cross runway [number]",
            "Monitor tower [frequency]"
        ]
        
        static func formatInitialContact(
            airport: String,
            callsign: String,
            location: String,
            atis: String
        ) -> String {
            return "\(airport) Ground, \(callsign), \(location), Information \(atis), Ready to taxi"
        }
        
        static func formatTaxiClearance(
            runway: String,
            taxiways: [String],
            holdShort: String? = nil,
            additionalInstructions: String? = nil
        ) -> String {
            var clearance = "Runway \(runway), taxi via \(taxiways.joined(separator: ", "))"
            
            if let holdShort = holdShort {
                clearance += ", hold short of \(holdShort)"
            }
            
            if let additional = additionalInstructions {
                clearance += ", \(additional)"
            }
            
            return clearance
        }
        
        static let readbackRequired = [
            "Hold short instructions",
            "Runway crossing clearances",
            "Runway assignment instructions"
        ]
    }
    
    /// Section 3-9-3. Departure Operations
    struct DepartureOperations {
        static let elements = [
            "Aircraft callsign",
            "Departure procedure",
            "Altitude restrictions",
            "Departure frequency",
            "Transponder code",
            "Additional instructions"
        ]
        
        static func formatDepartureClearance(
            procedure: String,
            altitude: String,
            frequency: String,
            transponder: String,
            additional: String? = nil
        ) -> String {
            var clearance = "Cleared \(procedure), maintain \(altitude), departure frequency \(frequency), squawk \(transponder)"
            
            if let additional = additional {
                clearance += ", \(additional)"
            }
            
            return clearance
        }
        
        static func formatTakeoffClearance(
            runway: String,
            wind: String? = nil
        ) -> String {
            var clearance = "Runway \(runway), cleared for takeoff"
            if let wind = wind {
                clearance += ", wind \(wind)"
            }
            return clearance
        }
        
        static let lineUpAndWait = "Line up and wait"
        static let immediateLineUpAndWait = "Immediate line up and wait"
        static let expediteDeparture = "Expedite departure"
    }
    
    /// Section 4. En Route Operations
    struct EnRouteOperations {
        static func formatAltitudeAssignment(
            altitude: String,
            restriction: String? = nil
        ) -> String {
            var clearance = "Climb and maintain \(altitude)"
            if let restriction = restriction {
                clearance += ", \(restriction)"
            }
            return clearance
        }
        
        static func formatHeadingAssignment(
            heading: String,
            reason: String? = nil
        ) -> String {
            var clearance = "Turn \(heading)"
            if let reason = reason {
                clearance += ", \(reason)"
            }
            return clearance
        }
        
        static func formatSpeedAssignment(
            speed: String,
            type: SpeedType = .indicated
        ) -> String {
            switch type {
            case .indicated:
                return "Maintain \(speed) knots"
            case .mach:
                return "Maintain Mach \(speed)"
            }
        }
        
        enum SpeedType {
            case indicated
            case mach
        }
    }
    
    /// Section 5. Radar Operations
    struct RadarOperations {
        static func formatVectorForApproach(
            heading: String,
            approach: String,
            runway: String
        ) -> String {
            return "Turn \(heading), vector for \(approach) approach runway \(runway)"
        }
        
        static func formatTrafficAlert(
            position: String,
            altitude: String,
            type: String,
            movement: String
        ) -> String {
            return "Traffic, \(position), \(altitude), \(type), \(movement)"
        }
    }
    
    /// Section 3-10-5. Approach Operations
    struct ApproachOperations {
        static func formatApproachClearance(
            type: String,
            runway: String,
            additional: String? = nil
        ) -> String {
            var clearance = "Cleared \(type) approach runway \(runway)"
            if let additional = additional {
                clearance += ", \(additional)"
            }
            return clearance
        }
        
        static func formatLandingClearance(
            runway: String,
            wind: String? = nil
        ) -> String {
            var clearance = "Runway \(runway), cleared to land"
            if let wind = wind {
                clearance += ", wind \(wind)"
            }
            return clearance
        }
        
        static let goAround = "Go around"
        static let circleToLand = "Circle to land"
        static let sidestepTo = "Sidestep to"
    }
    
    /// Section 2-1-8. Radio Communications Transfer
    struct FrequencyChange {
        static func format(frequency: String, optional: Bool = false) -> String {
            optional ? 
                "Monitor tower \(frequency)" :
                "Contact tower \(frequency)"
        }
    }
    
    /// Section 2-1-9. Abbreviated Transmissions
    struct Acknowledgements {
        static let roger = "Roger"
        static let affirmative = "Affirmative"
        static let negative = "Negative"
        static let readback = "Readback correct"
        static let verify = "Verify"
        static let wilco = "Wilco"
        static let unable = "Unable"
        static let say_again = "Say again"
    }
    
    /// Section 2-4-17. Numbers Usage
    struct Numbers {
        static func formatAltitude(_ altitude: Int) -> String {
            if altitude >= 18000 {
                return "FL\(altitude / 100)"
            } else {
                return "\(altitude)"
            }
        }
        
        static func formatFrequency(_ frequency: String) -> String {
            // Convert "123.45" to "One Two Three Point Four Five"
            return frequency.map { char in
                General.numbers[String(char)] ?? String(char)
            }.joined(separator: " ")
        }
    }
}

// Example usage:
extension ATCPhraseology {
    static let taxiExample = TaxiPhraseology.formatTaxiClearance(
        runway: "17",
        taxiways: ["Alpha", "Bravo"],
        holdShort: "Runway 17",
        additionalInstructions: "remain this frequency"
    )
    
    static let departureExample = DepartureOperations.formatDepartureClearance(
        procedure: "RNAV departure",
        altitude: "3,000",
        frequency: "125.15",
        transponder: "4721",
        additional: "winds 180 at 5"
    )
}

extension ATCPhraseology {
    static let phonetics = [
        Phonetic(letter: "Alpha", pronunciation: "AL-fah"),
        Phonetic(letter: "Bravo", pronunciation: "BRAH-voh"),
        Phonetic(letter: "Charlie", pronunciation: "CHAR-lee"),
        Phonetic(letter: "Delta", pronunciation: "DELL-tah"),
        Phonetic(letter: "Echo", pronunciation: "ECK-oh"),
        Phonetic(letter: "Foxtrot", pronunciation: "FOKS-trot"),
        Phonetic(letter: "Golf", pronunciation: "GOLF"),
        Phonetic(letter: "Hotel", pronunciation: "hoh-TELL"),
        Phonetic(letter: "India", pronunciation: "IN-dee-ah"),
        Phonetic(letter: "Juliet", pronunciation: "JEW-lee-ETT"),
        Phonetic(letter: "Kilo", pronunciation: "KEY-loh"),
        Phonetic(letter: "Lima", pronunciation: "LEE-mah"),
        Phonetic(letter: "Mike", pronunciation: "MIKE"),
        Phonetic(letter: "November", pronunciation: "no-VEM-ber"),
        Phonetic(letter: "Oscar", pronunciation: "OSS-cah"),
        Phonetic(letter: "Papa", pronunciation: "pah-PAH"),
        Phonetic(letter: "Quebec", pronunciation: "keh-BECK"),
        Phonetic(letter: "Romeo", pronunciation: "ROW-me-oh"),
        Phonetic(letter: "Sierra", pronunciation: "see-AIR-rah"),
        Phonetic(letter: "Tango", pronunciation: "TANG-go"),
        Phonetic(letter: "Uniform", pronunciation: "YOU-nee-form"),
        Phonetic(letter: "Victor", pronunciation: "VIK-tah"),
        Phonetic(letter: "Whiskey", pronunciation: "WISS-key"),
        Phonetic(letter: "X-ray", pronunciation: "ECKS-RAY"),
        Phonetic(letter: "Yankee", pronunciation: "YANG-key"),
        Phonetic(letter: "Zulu", pronunciation: "ZOO-loo")
    ]
    
    struct Phonetic {
        let letter: String
        let pronunciation: String
    }
} 