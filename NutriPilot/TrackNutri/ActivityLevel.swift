

import Foundation

enum Gender: String, CaseIterable, Identifiable, Codable {
    case male = "Male"
    case female = "Female"
    
    var id: String { rawValue }
}

enum ActivityLevel: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    
    var id: String { rawValue }
    
    var multiplier: Double {
        switch self {
        case .low: return 1.2
        case .moderate: return 1.55
        case .high: return 1.725
        }
    }
    
    var subtitle: String {
        switch self {
        case .low: return "Little to no exercise"
        case .moderate: return "Exercise 3–5 days/week"
        case .high: return "Exercise 6–7 days/week"
        }
    }
}

