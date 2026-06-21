import Foundation

// MARK: - DayCalorieData
// One data point per day for the 7-day bar chart.

struct DayCalorieData: Identifiable {
    var id = UUID()
    let date: Date
    let calories: Int
    let goal: Int

    var percentage: Double {
        guard goal > 0 else { return 0 }
        return min(Double(calories) / Double(goal), 1.3)
    }

    /// A day is "on track" if it hits ≥ 85% of the calorie goal.
    var isOnTrack: Bool {
        guard goal > 0, calories > 0 else { return false }
        return Double(calories) / Double(goal) >= 0.85
    }

    var shortDay: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date)
    }
}

// MARK: - WeeklyAnalytics
// Aggregated result returned by AnalyticsEngine.compute(…)

struct WeeklyAnalytics {
    let weeklyData: [DayCalorieData]
    let streak: Int
    let proteinConsistency: Double   // 0–1
    let averageCalories: Int
    let daysOnTrack: Int

    var daysOnTrackPercentage: Double {
        guard !weeklyData.isEmpty else { return 0 }
        return Double(daysOnTrack) / Double(weeklyData.count)
    }
}

// MARK: - AnalyticsEngine
// Pure static functions — no side effects, fully testable.

enum AnalyticsEngine {

    // MARK: Main entry point
    static func compute(
        logs: [LoggedFood],
        goalCalories: Int,
        macroTargets: MacroTargets
    ) -> WeeklyAnalytics {
        let weekly   = weeklyCalories(from: logs, goal: goalCalories)
        let streak   = currentStreak(from: logs)
        let protein  = proteinConsistency(from: logs, target: macroTargets.protein)
        let avg      = averageCalories(from: weekly)
        let onTrack  = weekly.filter { $0.isOnTrack }.count

        return WeeklyAnalytics(
            weeklyData: weekly,
            streak: streak,
            proteinConsistency: protein,
            averageCalories: avg,
            daysOnTrack: onTrack
        )
    }

    // MARK: - Weekly calorie breakdown (oldest → today)
    static func weeklyCalories(from logs: [LoggedFood], goal: Int) -> [DayCalorieData] {
        let cal   = Calendar.current
        let today = Date()

        return (0..<7).reversed().map { offset in
            let date     = cal.date(byAdding: .day, value: -offset, to: today)!
            let dayLogs  = logs.filter { cal.isDate($0.date, inSameDayAs: date) }
            let calories = dayLogs.reduce(0) { $0 + Int(Double($1.food.calories) * $1.servings) }
            return DayCalorieData(date: date, calories: calories, goal: goal)
        }
    }

    // MARK: - Consecutive-day streak
    // Today counts even if no food has been logged yet.
    static func currentStreak(from logs: [LoggedFood]) -> Int {
        let cal   = Calendar.current
        var date  = cal.startOfDay(for: Date())
        var streak = 0

        for _ in 0..<365 {
            let dayLogs = logs.filter { cal.isDate($0.date, inSameDayAs: date) }

            if dayLogs.isEmpty {
                // Allow today to be empty without breaking the streak
                if cal.isDateInToday(date) {
                    guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
                    date = prev
                    continue
                }
                break
            }

            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }

        return streak
    }

    // MARK: - Protein consistency over last N days
    // Returns fraction of *active* days where protein ≥ 80% of target.
    static func proteinConsistency(
        from logs: [LoggedFood],
        target: Double,
        days: Int = 7
    ) -> Double {
        let cal   = Calendar.current
        let today = Date()
        var met   = 0
        var active = 0

        for offset in 0..<days {
            guard let date = cal.date(byAdding: .day, value: -offset, to: today) else { continue }
            let dayLogs = logs.filter { cal.isDate($0.date, inSameDayAs: date) }
            guard !dayLogs.isEmpty else { continue }
            active += 1
            let protein = dayLogs.reduce(0.0) { $0 + ($1.food.protein * $1.servings) }
            if protein >= target * 0.8 { met += 1 }
        }

        guard active > 0 else { return 0 }
        return Double(met) / Double(active)
    }

    // MARK: - Average over days where food was logged
    static func averageCalories(from data: [DayCalorieData]) -> Int {
        let active = data.filter { $0.calories > 0 }
        guard !active.isEmpty else { return 0 }
        return active.reduce(0) { $0 + $1.calories } / active.count
    }
}
