import SwiftUI
import Foundation

@Observable
@MainActor
final class AppState {

    // MARK: - Published State

    var loggedFoods: [LoggedFood] = [] {
        didSet { persist(loggedFoods, key: Keys.loggedFoods) }
    }

    var userProfile: UserProfile? {
        didSet { persistOptional(userProfile, key: Keys.userProfile) }
    }

    var waterEntries: [WaterEntry] = [] {
        didSet { persist(waterEntries, key: Keys.waterEntries) }
    }

    // MARK: - Storage Keys

    private enum Keys {
        static let loggedFoods  = "loggedFoods_storage"   // keeps legacy data
        static let userProfile  = "userProfile_storage"
        static let waterEntries = "waterEntries_storage"
    }

    // MARK: - Init

    init() {
        loggedFoods  = restored([LoggedFood].self, key: Keys.loggedFoods) ?? []
        userProfile  = restored(UserProfile.self,  key: Keys.userProfile)
        waterEntries = restored([WaterEntry].self,  key: Keys.waterEntries) ?? []
    }

    // MARK: - Calorie Aggregates (today)

    var eatenCalories: Int {
        loggedFoods.reduce(0) { $0 + Int(Double($1.food.calories) * $1.servings) }
    }

    var totalProtein: Double { loggedFoods.reduce(0.0) { $0 + $1.food.protein * $1.servings } }
    var totalCarbs:   Double { loggedFoods.reduce(0.0) { $0 + $1.food.carbs   * $1.servings } }
    var totalFat:     Double { loggedFoods.reduce(0.0) { $0 + $1.food.fat     * $1.servings } }
    var totalFiber:   Double { loggedFoods.reduce(0.0) { $0 + $1.food.fiber   * $1.servings } }

    // MARK: - Water Aggregates (today)

    var todayWaterIntake: Int {
        let cal = Calendar.current
        return waterEntries
            .filter { cal.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    var waterGoalML: Int { userProfile?.dailyWaterGoalML ?? 2500 }

    // MARK: - Date Queries

    func foods(for date: Date) -> [LoggedFood] {
        let cal = Calendar.current
        return loggedFoods.filter { cal.isDate($0.date, inSameDayAs: date) }
    }

    func calories(for date: Date) -> Int {
        foods(for: date).reduce(0) { $0 + Int(Double($1.food.calories) * $1.servings) }
    }

    // MARK: - Food Actions

    func addFood(_ food: FoodItem, servings: Double, meal: MealType) {
        loggedFoods.append(LoggedFood(food: food, servings: servings, meal: meal))
    }

    func addCustomFood(
        name: String, calories: Int, protein: Double,
        carbs: Double, fat: Double, fiber: Double,
        servings: Double, meal: MealType
    ) {
        let food = FoodItem(
            name: name, calories: calories, protein: protein,
            carbs: carbs, fat: fat, fiber: fiber,
            unit: .grams, baseAmount: "Custom"
        )
        loggedFoods.append(LoggedFood(food: food, servings: servings, meal: meal))
    }

    func deleteFood(_ item: LoggedFood) {
        loggedFoods.removeAll { $0.id == item.id }
    }

    func clearAllData() {
        loggedFoods.removeAll()
    }

    // MARK: - Water Actions

    func addWater(amount: Int) {
        waterEntries.append(WaterEntry(amount: amount))
    }

    func removeWaterEntry(_ entry: WaterEntry) {
        waterEntries.removeAll { $0.id == entry.id }
    }

    // MARK: - Profile Actions

    func saveProfile(_ profile: UserProfile) {
        userProfile = profile
    }

    // MARK: - Generic Persistence (Supabase-replaceable)

    private func persist<T: Encodable>(_ value: T, key: String) {
        do {
            UserDefaults.standard.set(try JSONEncoder().encode(value), forKey: key)
        } catch {
            print("❌ Persist[\(key)]:", error)
        }
    }

    private func persistOptional<T: Encodable>(_ value: T?, key: String) {
        guard let value else {
            UserDefaults.standard.removeObject(forKey: key)
            return
        }
        persist(value, key: key)
    }

    private func restored<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("❌ Restore[\(key)]:", error)
            return nil
        }
    }
}
