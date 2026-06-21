import Foundation

struct SmartMealPlanner {
    
    static func generate(
        goalCalories: Int,
        foods: [FoodItem],
        preference: DietPreference
    ) -> MealPlan {
        
        //  FILTER BASED ON DIET
        let filteredFoods: [FoodItem] = {
            switch preference {
            case .veg:
                return foods.filter { $0.isVeg }
            case .nonVeg:
                return foods.filter { !$0.isVeg }
            case .all:
                return foods
            }
        }()
        
        let mealSplit: [MealType: Double] = [
            .breakfast: 0.25,
            .lunch: 0.35,
            .dinner: 0.30,
            .snack: 0.10
        ]
        
        var sections: [MealPlanSection] = []
        var globalUsed: Set<String> = []
        
        let shuffledFoods = filteredFoods.shuffled()
        
        for meal in MealType.allCases {
            
            let mealCalories = Int(
                Double(goalCalories) * (mealSplit[meal] ?? 0.25)
            )
            
            let items = buildWiseMeal(
                targetCalories: mealCalories,
                foods: shuffledFoods,
                meal: meal,
                globalUsed: &globalUsed
            )
            
            sections.append(
                MealPlanSection(meal: meal, items: items)
            )
        }
        
        return MealPlan(meals: sections)
    }
}

// Intelligent Builder

private extension SmartMealPlanner {
    
    static func buildWiseMeal(
        targetCalories: Int,
        foods: [FoodItem],
        meal: MealType,
        globalUsed: inout Set<String>
    ) -> [MealPlanItem] {
        
        var remaining = targetCalories
        var result: [MealPlanItem] = []
        var localUsed: Set<String> = []
        
        //  HUMAN REALISTIC LIMITS
        let maxItemsPerMeal: Int = {
            switch meal {
            case .breakfast: return 2
            case .lunch, .dinner: return 3
            case .snack: return 1
            }
        }()
        
        //  role-based pools
        let carbBases = foods.filter {
            $0.role == .carbBase && !globalUsed.contains($0.name)
        }
        
        let heavyProteins = foods.filter {
            $0.role == .heavyProtein && !globalUsed.contains($0.name)
        }
        
        let lightProteins = foods.filter {
            $0.role == .lightProtein && !globalUsed.contains($0.name)
        }
        
        let fibers = foods.filter {
            $0.role == .fiber && !globalUsed.contains($0.name)
        }
        
        let normalProteins = foods.filter {
            $0.role == .protein && !globalUsed.contains($0.name)
        }
        
        // BREAKFAST
        if meal == .breakfast {
            
            remaining = addBest(
                from: lightProteins + normalProteins,
                remaining: &remaining,
                result: &result,
                used: &localUsed,
                globalUsed: &globalUsed,
                maxItems: 1
            )
            
            if result.count >= maxItemsPerMeal { return result }
            
            remaining = addBest(
                from: carbBases,
                remaining: &remaining,
                result: &result,
                used: &localUsed,
                globalUsed: &globalUsed,
                maxItems: 1
            )
        }
        
        //  LUNCH / DINNER
        else if meal == .lunch || meal == .dinner {
            
            remaining = addBest(
                from: heavyProteins + normalProteins,
                remaining: &remaining,
                result: &result,
                used: &localUsed,
                globalUsed: &globalUsed,
                maxItems: 1
            )
            
            if result.count >= maxItemsPerMeal { return result }
            
            remaining = addBest(
                from: carbBases,
                remaining: &remaining,
                result: &result,
                used: &localUsed,
                globalUsed: &globalUsed,
                maxItems: 1
            )
            
            if result.count >= maxItemsPerMeal { return result }
            
            remaining = addBest(
                from: fibers,
                remaining: &remaining,
                result: &result,
                used: &localUsed,
                globalUsed: &globalUsed,
                maxItems: 1
            )
        }
        
        //  SNACK
        else {
            remaining = addBest(
                from: lightProteins + normalProteins,
                remaining: &remaining,
                result: &result,
                used: &localUsed,
                globalUsed: &globalUsed,
                maxItems: 1
            )
        }
        
        //  Final calorie tuning
        if result.count < maxItemsPerMeal {
            fillRemainingCalories(
                foods: foods,
                remaining: &remaining,
                result: &result,
                used: &localUsed,
                globalUsed: &globalUsed,
                maxItemsPerMeal: maxItemsPerMeal
            )
        }
        
        return result
    }
}

// Helpers

private extension SmartMealPlanner {
    
    static func addBest(
        from pool: [FoodItem],
        remaining: inout Int,
        result: inout [MealPlanItem],
        used: inout Set<String>,
        globalUsed: inout Set<String>,
        maxItems: Int
    ) -> Int {
        
        guard !pool.isEmpty else { return remaining }
        
        var added = 0
        
        let sorted = pool.shuffled()
        
        for food in sorted {
            
            if added >= maxItems { break }
            if used.contains(food.name) { continue }
            if remaining < 80 { break }
            
            let servings = min(
                Double(remaining) / Double(max(food.calories, 1)),
                2.0
            )
            
            if servings < 0.5 { continue }
            
            let item = MealPlanItem(food: food, servings: servings)
            
            result.append(item)
            used.insert(food.name)
            globalUsed.insert(food.name)
            remaining -= item.calories
            added += 1
        }
        
        return remaining
    }
    
    static func fillRemainingCalories(
        foods: [FoodItem],
        remaining: inout Int,
        result: inout [MealPlanItem],
        used: inout Set<String>,
        globalUsed: inout Set<String>,
        maxItemsPerMeal: Int
    ) {
        guard remaining > 120 else { return }
        
        let shuffled = foods.shuffled()
        
        for food in shuffled {
            
            if result.count >= maxItemsPerMeal { break }
            if used.contains(food.name) { continue }
            if globalUsed.contains(food.name) { continue }
            if remaining < 80 { break }
            
            let servings = min(
                Double(remaining) / Double(max(food.calories, 1)),
                1.2
            )
            
            if servings < 0.5 { continue }
            
            let item = MealPlanItem(food: food, servings: servings)
            
            result.append(item)
            used.insert(food.name)
            globalUsed.insert(food.name)
            remaining -= item.calories
        }
    }
}
