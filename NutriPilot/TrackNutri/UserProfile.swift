import Foundation

// MARK: - UserProfile
// Persisted via AppState. Populated during onboarding (DetailsView).
// All computed properties are side-effect free for safe use in views.

struct UserProfile: Codable, Equatable {

    var id: UUID         = UUID()
    var age: Int
    var weight: Double   // kg
    var height: Double   // cm
    var gender: Gender
    var activityLevel: ActivityLevel
    var goalType: String
    var goalCalories: Int
    var dailyWaterGoalML: Int = 2500
    var createdAt: Date  = Date()
    var updatedAt: Date  = Date()

    // MARK: - BMI
    var bmi: Double {
        let h = height / 100.0
        guard h > 0 else { return 0 }
        return weight / (h * h)
    }

    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Healthy"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }

    // MARK: - Calorie math (Mifflin-St Jeor)
    var maintenanceCalories: Int {
        let bmr: Double = gender == .male
            ? (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
            : (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
        return Int(bmr * activityLevel.multiplier)
    }

    // MARK: - Mutating update (call from ProfileEditView when ready)
    mutating func update(
        age: Int, weight: Double, height: Double,
        gender: Gender, activityLevel: ActivityLevel,
        goalType: String, goalCalories: Int
    ) {
        self.age           = age
        self.weight        = weight
        self.height        = height
        self.gender        = gender
        self.activityLevel = activityLevel
        self.goalType      = goalType
        self.goalCalories  = goalCalories
        self.updatedAt     = Date()
    }
}
