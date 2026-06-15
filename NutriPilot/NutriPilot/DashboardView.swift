import SwiftUI

struct DashboardView: View {
    
    let goalCalories: Int
    @Environment(AppState.self) private var appState
    
//Macro Targets
    
    private var macroTargets: MacroTargets {
        MacroTargets.fromCalories(goalCalories)
    }
    
// Motivation
    
    private var motivationText: String {
        MotivationEngine.message(
            eaten: appState.eatenCalories,
            goal: goalCalories
        )
    }
    
//Smart Tip
    
    private var smartTip: String {
        NutritionTipEngine.tip(
            eatenProtein: appState.totalProtein,
            eatenCarbs: appState.totalCarbs,
            eatenFat: appState.totalFat,
            eatenFiber: appState.totalFiber,
            targets: macroTargets,
            remainingCalories: remainingCalories,
            totalLoggedFoods: appState.loggedFoods.count
        )
    }
    
// Computed

    var remainingCalories: Int {
        max(goalCalories - appState.eatenCalories, 0)
    }

    var progress: Double {
        guard goalCalories > 0 else { return 0 }
        return Double(appState.eatenCalories) / Double(goalCalories)
    }

    private var streak: Int {
        AnalyticsEngine.currentStreak(from: appState.loggedFoods)
    }

    private var waterGoalML: Int { appState.waterGoalML }
    
//Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                NavigationLink {
                    DailyProgressView(goalCalories: goalCalories)
                } label: {
                    headerCard
                }
                .buttonStyle(.plain)

                actionButtons
                quickStatsRow
                macrosCard
                mealsCard
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    AnalyticsView(goalCalories: goalCalories)
                } label: {
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ProfileView()
                } label: {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                }
            }
        }
    }
}

//Header Card


private extension DashboardView {
    
    var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Today's Progress")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
            
            Text(Date.now.formatted(.dateTime.weekday(.wide).month().day()))
                .font(.title.bold())
                .foregroundStyle(.white)
            
            HStack {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Calories Remaining")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Text("\(remainingCalories)")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 20) {
                        statItem("Goal", value: goalCalories)
                        statItem("Eaten", value: appState.eatenCalories)
                        statItem("Left", value: remainingCalories)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 10)
                        .frame(width: 80)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
            }
            
            Text(motivationText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.green, Color.green.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    func statItem(_ title: String, value: Int) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
            Text("\(value)")
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
    }
}


//Action Buttons


private extension DashboardView {
    
    var actionButtons: some View {
        HStack(spacing: 14) {
            
            NavigationLink {
                AddFoodView()
            } label: {
                Label("Add Food", systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            NavigationLink {
                MealPlanView(goalCalories: goalCalories)
            } label: {
                Label("Meal Plan", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}
//Macros Card


private extension DashboardView {
    
    var macrosCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            HStack {
                Text("Daily Macros")
                    .font(.headline)
                Spacer()
                Text("Personalized")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            
            macroRow("Protein", value: appState.totalProtein,
                     target: macroTargets.protein, color: .green)
            
            macroRow("Carbs", value: appState.totalCarbs,
                     target: macroTargets.carbs, color: .blue)
            
            macroRow("Fat", value: appState.totalFat,
                     target: macroTargets.fat, color: .orange)
            
            macroRow("Fiber", value: appState.totalFiber,
                     target: macroTargets.fiber, color: .purple)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    func macroRow(_ title: String,
                  value: Double,
                  target: Double,
                  color: Color) -> some View {
        
        let progress = target > 0 ? min(value / target, 1) : 0
        
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value, specifier: "%.1f")g / \(target, specifier: "%.0f")g")
                    .foregroundStyle(color)
            }
            
            ProgressView(value: progress)
                .tint(color)
        }
    }
}


//Meals + Smart Tip

private extension DashboardView {
    
    var mealsCard: some View {
        VStack(spacing: 16) {
            
            tipCard
            
            Text("Meals Logged Today")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if appState.loggedFoods.isEmpty {
                emptyMealsView
            } else {
                mealsGroupedView
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    var tipCard: some View {
        HStack(alignment: .top, spacing: 12) {
            
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.title3)
            
            Text(smartTip)
                .font(.subheadline)
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color.yellow.opacity(0.15),
                    Color.orange.opacity(0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    var emptyMealsView: some View {
        VStack(spacing: 8) {
            Image(systemName: "fork.knife")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("No meals logged yet")
                .font(.subheadline)
            
            Text("Start tracking by adding your first meal")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    var mealsGroupedView: some View {
        VStack(spacing: 14) {
            ForEach(MealType.allCases) { meal in
                let items = appState.loggedFoods.filter { $0.meal == meal }
                if !items.isEmpty {
                    mealSection(meal: meal, items: items)
                }
            }
        }
    }
    
    func mealSection(meal: MealType, items: [LoggedFood]) -> some View {
        let mealCalories = items.reduce(0) {
            $0 + Int(Double($1.food.calories) * $1.servings)
        }
        
        return VStack(spacing: 10) {
            HStack {
                Label(meal.rawValue, systemImage: mealIcon(meal))
                Spacer()
                Text("\(mealCalories) cal")
                    .foregroundStyle(.green)
            }
            
            ForEach(items) { item in
                mealFoodRow(item)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    func mealFoodRow(_ item: LoggedFood) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(item.food.name) (x\(Int(item.servings)))")
                    .font(.subheadline.bold())
                Text(item.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(role: .destructive) {
                appState.deleteFood(item)
            } label: {
                Image(systemName: "trash")
            }
        }
    }
    
    func mealIcon(_ meal: MealType) -> String {
        switch meal {
        case .breakfast: return "cup.and.saucer.fill"
        case .lunch: return "fork.knife"
        case .dinner: return "moon.stars.fill"
        case .snack: return "takeoutbag.and.cup.and.straw.fill"
        }
    }
}


// MARK: - Quick Stats Row (Streak + Water)

private extension DashboardView {

    var quickStatsRow: some View {
        HStack(spacing: 14) {

            // Streak mini-card → AnalyticsView
            NavigationLink {
                AnalyticsView(goalCalories: goalCalories)
            } label: {
                streakWidget
            }
            .buttonStyle(.plain)

            // Water mini-card → WaterTrackingView
            NavigationLink {
                WaterTrackingView()
            } label: {
                waterWidget
            }
            .buttonStyle(.plain)
        }
    }

    var streakWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.orange)
                    .font(.caption.bold())
                Text("Streak")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            Text("\(streak) day\(streak == 1 ? "" : "s")")
                .font(.title3.bold())

            Text("Keep it up! 🔥")
                .font(.caption2)
                .foregroundStyle(.orange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.25), lineWidth: 1)
        )
    }

    var waterWidget: some View {
        let waterProgress = waterGoalML > 0
            ? min(Double(appState.todayWaterIntake) / Double(waterGoalML), 1.0)
            : 0

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.cyan)
                    .font(.caption.bold())
                Text("Water")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            Text("\(appState.todayWaterIntake) ml")
                .font(.title3.bold())

            ProgressView(value: waterProgress)
                .tint(.cyan)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.cyan.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cyan.opacity(0.25), lineWidth: 1)
        )
    }
}

