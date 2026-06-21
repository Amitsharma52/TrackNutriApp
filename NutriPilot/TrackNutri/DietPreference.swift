import Foundation

enum DietPreference: String, CaseIterable, Identifiable, Codable {
    case veg = "Vegetarian"
    case nonVeg = "Non-Vegetarian"
    case all = "All"
    
    var id: String { rawValue }
}
