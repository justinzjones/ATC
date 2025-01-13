import Foundation

struct AirportData: Codable {
    let Airports: [AirportInfo]
    
    enum CodingKeys: String, CodingKey {
        case Airports
    }
    
    var airports: [AirportInfo] {
        return Airports
    }
}

struct AirportInfo: Codable {
    let icao: String
    let iata: String
    let name: String
    let shortName: String
    let elevation: Int
    let isControlled: Bool
    let groundFrequencies: GroundFrequencies
    let runways: [Runway]
    let taxiways: [Taxiway]
    let fbos: [FBO]
    let commonRoutes: [CommonRoute]?
    let commonLocations: [String]?
    
    enum CodingKeys: String, CodingKey {
        case icao = "ICAO"
        case iata = "IATA"
        case name = "Name"
        case shortName = "ShortName"
        case elevation = "Elevation"
        case isControlled = "IsControlled"
        case groundFrequencies = "Ground_Frequencies"
        case runways = "Runways"
        case taxiways = "Taxiways"
        case fbos = "FBOs"
        case commonRoutes = "CommonRoutes"
        case commonLocations = "CommonLocations"
    }
}

struct GroundFrequencies: Codable {
    let ground: StringOrArray
    let tower: StringOrArray
    let clearance: String
    
    enum CodingKeys: String, CodingKey {
        case ground = "Ground"
        case tower = "Tower"
        case clearance = "Clearance"
    }
}

// Handle both String and [String] cases for frequencies
enum StringOrArray: Codable {
    case single(String)
    case multiple([String])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .single(string)
        } else if let array = try? container.decode([String].self) {
            self = .multiple(array)
        } else {
            throw DecodingError.typeMismatch(StringOrArray.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or [String]"))
        }
    }
}

struct Runway: Codable {
    let identifier: String
    let length: Int
    let width: Int
    let surface: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "Identifier"
        case length = "Length"
        case width = "Width"
        case surface = "Surface"
    }
}

struct Taxiway: Codable {
    let identifier: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "Identifier"
        case description = "Description"
    }
}

struct FBO: Codable {
    let name: String
    let location: String
    let accessVia: [String]
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case location = "Location"
        case accessVia = "AccessVia"
    }
}

struct CommonRoute: Codable {
    let from: String
    let to: String
    let instructions: String
    let hotspots: [String]
    
    enum CodingKeys: String, CodingKey {
        case from = "From"
        case to = "To"
        case instructions = "Instructions"
        case hotspots = "Hotspots"
    }
} 