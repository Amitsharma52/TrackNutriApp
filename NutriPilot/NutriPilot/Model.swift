import SwiftUI
import Foundation

// Serving Unit

enum ServingUnit: Codable {
    case grams
    case count
}

// Meal Type

enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var id: String { rawValue }
}

// Food Item

struct FoodItem: Identifiable, Hashable, Codable {
    var id = UUID()
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let unit: ServingUnit
    let baseAmount: String
}

// Logged Food

struct LoggedFood: Identifiable, Codable {
    var id = UUID()
    let food: FoodItem
    let servings: Double
    let meal: MealType
    var date = Date()
}
