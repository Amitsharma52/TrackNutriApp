import Foundation

// MARK: - AI-Ready Architecture
// Replace LocalMealRecommendationService with GeminiMealService
// when integrating the Gemini API. All callers use the protocol,
// so the swap requires zero UI changes.

protocol MealRecommendationService {
    func recommendMeals(
        for profile: UserProfile,
        remainingCalories: Int,
        mealType: MealType,
        preference: DietPreference
    ) async throws -> [FoodItem]

    func analyzeFoodImage(_ imageData: Data) async throws -> FoodItem?

    func generateDayPlan(
        for profile: UserProfile,
        goalCalories: Int,
        preference: DietPreference
    ) async throws -> MealPlan
}

// MARK: - Local fallback (in use until Gemini is integrated)

struct LocalMealRecommendationService: MealRecommendationService {

    func recommendMeals(
        for profile: UserProfile,
        remainingCalories: Int,
        mealType: MealType,
        preference: DietPreference
    ) async throws -> [FoodItem] {
        let plan = SmartMealPlanner.generate(
            goalCalories: remainingCalories,
            foods: FoodDatabase.foods,
            preference: preference
        )
        return plan.meals.first(where: { $0.meal == mealType })?.items.map { $0.food } ?? []
    }

    func analyzeFoodImage(_ imageData: Data) async throws -> FoodItem? {
        // 🔮 Placeholder — will call Gemini Vision API
        // POST https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent
        return nil
    }

    func generateDayPlan(
        for profile: UserProfile,
        goalCalories: Int,
        preference: DietPreference
    ) async throws -> MealPlan {
        SmartMealPlanner.generate(
            goalCalories: goalCalories,
            foods: FoodDatabase.foods,
            preference: preference
        )
    }
}

// MARK: - Food Search Architecture (API-ready)
// Replace LocalFoodService with RemoteFoodService when integrating
// Nutritionix, USDA FoodData Central, or a custom Supabase endpoint.

protocol FoodSearchService {
    func search(query: String, filter: DietFilter) async throws -> [FoodItem]
    func details(for id: String) async throws -> FoodItem?
}

// MARK: - Local food search (current implementation)

struct LocalFoodService: FoodSearchService {

    private let foods = FoodDatabase.foods

    func search(query: String, filter: DietFilter) async throws -> [FoodItem] {
        foods.filter { food in
            let matchesQuery  = query.isEmpty || food.name.localizedCaseInsensitiveContains(query)
            let matchesDiet: Bool = {
                switch filter {
                case .all:    return true
                case .veg:    return food.isVeg
                case .nonVeg: return !food.isVeg
                }
            }()
            return matchesQuery && matchesDiet
        }
    }

    func details(for id: String) async throws -> FoodItem? {
        foods.first { $0.id.uuidString == id }
    }
}

// MARK: - Supabase-ready persistence stub
// When ready to sync:
// 1. Create SupabasePersistenceService conforming to this protocol
// 2. Inject into AppState replacing UserDefaults calls
// 3. Wrap with offline-first caching using local UserDefaults

protocol PersistenceService {
    func save<T: Encodable>(_ value: T, key: String) throws
    func load<T: Decodable>(_ type: T.Type, key: String) throws -> T?
    func delete(key: String)
}

struct UserDefaultsPersistenceService: PersistenceService {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func save<T: Encodable>(_ value: T, key: String) throws {
        UserDefaults.standard.set(try encoder.encode(value), forKey: key)
    }

    func load<T: Decodable>(_ type: T.Type, key: String) throws -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try decoder.decode(type, from: data)
    }

    func delete(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
