import Foundation

struct MealPlanGenerator {
    
    static func generate(
        goalCalories: Int,
        foods: [FoodItem]
    ) -> MealPlan {
        
        // calorie split
        let targets: [MealType: Double] = [
            .breakfast: 0.25,
            .lunch: 0.35,
            .dinner: 0.30,
            .snack: 0.10
        ]
        
        var sections: [MealPlanSection] = []
        
        for meal in MealType.allCases {
            
            let targetCalories = Int(Double(goalCalories) * (targets[meal] ?? 0.25))
            
            let items = generateMealItems(
                targetCalories: targetCalories,
                foods: foods
            )
            
            sections.append(
                MealPlanSection(meal: meal, items: items)
            )
        }
        
        return MealPlan(meals: sections)
    }
    
    //Builder
    
    private static func generateMealItems(
        targetCalories: Int,
        foods: [FoodItem]
    ) -> [MealPlanItem] {
        
        var remaining = targetCalories
        var result: [MealPlanItem] = []
        
        let shuffled = foods.shuffled()
        
        for food in shuffled.prefix(4) {
            if remaining <= 0 { break }
            
            let serving = max(1, remaining / max(food.calories, 1))
            let finalServing = Double(min(serving, 3))
            
            let item = MealPlanItem(
                food: food,
                servings: finalServing
            )
            
            remaining -= item.calories
            result.append(item)
        }
        
        return result
    }
}
