import Foundation

struct NutritionTipEngine {
    
    static func tip(
        eatenProtein: Double,
        eatenCarbs: Double,
        eatenFat: Double,
        eatenFiber: Double,
        targets: MacroTargets,
        remainingCalories: Int,
        totalLoggedFoods: Int
    ) -> String {
        
        
        // 🧊 NOTHING LOGGED
        
        if totalLoggedFoods == 0 {
            return motivationalQuotes.randomElement() ??
            "Start your day strong — log your first meal! 🚀"
        }
        
        //  Progress ratios
        let proteinProgress = eatenProtein / max(targets.protein, 1)
        let carbsProgress   = eatenCarbs / max(targets.carbs, 1)
        let fatProgress     = eatenFat / max(targets.fat, 1)
        let fiberProgress   = eatenFiber / max(targets.fiber, 1)
        
        
        // 🚨 PRIORITY
        
        if carbsProgress > 0.85 && proteinProgress < 0.6 {
            return "Carbs are getting high today. Balance your next meal with protein like eggs, paneer, or chicken. ⚖️"
        }
        
        
        //  PRIORITY
         
        if fatProgress > 0.85 {
            return "Fat intake is on the higher side. Prefer grilled or boiled foods next. 🥦"
        }
        
        
        // PRIORITY
        if proteinProgress < 0.45 {
            return "Your protein intake is low. Add eggs, tofu, paneer, or chicken breast. 💪"
        }
        
         
        //  PRIORITY
         
        if fiberProgress < 0.40 {
            return "Try adding salads, fruits, or veggies to improve fiber intake today. 🥗"
        }
        
        
        //  CALORIES TOO LOW
        
        if remainingCalories > 900 {
            return "You still have many calories left. A balanced meal would fit well now. 🍽️"
        }
        
        
        //  CALORIES ALMOST FULL
        
        if remainingCalories < 200 {
            return "You're close to your calorie goal. Keep remaining meals light. 🎯"
        }
        
        
        //  PERFECT DAY
         
        return "Great balance today — keep going strong! 🔥"
    }
    
    //Cool Quotes
    
    private static let motivationalQuotes: [String] = [
        "Every healthy choice is a step forward. 🌱",
        "Fuel your body, fuel your goals. 🚀",
        "Small meals, big progress. 💪",
        "Consistency beats perfection. 🔥",
        "Your future self will thank you. ✨",
        "Eat smart, feel strong. 🧠💪"
    ]
}
