import Foundation

struct MacroTargets {
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    
    static func fromCalories(_ calories: Int) -> MacroTargets {
        
        // Standard macro distribution
        // Protein = 30%
        // Carbs = 40%
        // Fat = 30%
        
        let proteinCalories = Double(calories) * 0.30
        let carbsCalories = Double(calories) * 0.40
        let fatCalories = Double(calories) * 0.30
        
        return MacroTargets(
            protein: proteinCalories / 4, // 4 cal per gram
            carbs: carbsCalories / 4,
            fat: fatCalories / 9,         // 9 cal per gram
            fiber: 25                     // default daily fiber target
        )
    }
}
