import SwiftUI

struct ContentView: View {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("savedGoalCalories") private var savedGoalCalories = 2000
    
    var body: some View {
        if hasCompletedOnboarding {
            // Main app flow — DashboardView and its child screens
            // (DailyProgressView, AddFoodView, MealPlanView) all live here
            NavigationStack {
                DashboardView(goalCalories: savedGoalCalories)
            }
        } else {
            // Onboarding flow — OnboardingView owns its own NavigationStack
            // which pushes DetailsView via navigationDestination(for: Goal.self)
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
