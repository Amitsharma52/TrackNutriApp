import Foundation

struct MealPlan: Identifiable {
    let id = UUID()
    let meals: [MealPlanSection]
}

struct MealPlanSection: Identifiable {
    let id = UUID()
    let meal: MealType
    let items: [MealPlanItem]
}

struct MealPlanItem: Identifiable {
    let id = UUID()
    let food: FoodItem
    let servings: Double
    
    var calories: Int {
        Int(Double(food.calories) * servings)
    }
    
    var protein: Double {
        food.protein * servings
    }
    
    var carbs: Double {
        food.carbs * servings
    }
    
    var fat: Double {
        food.fat * servings
    }
}
