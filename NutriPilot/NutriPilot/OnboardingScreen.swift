import SwiftUI

struct OnboardingView: View {
    
    @State private var selectedGoal: Goal?
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 24) {
                
                Spacer(minLength: 20)
                
                headerSection
                
                VStack(spacing: 14) {
                    ForEach(goals) { goal in
                        GoalCardView(
                            goal: goal,
                            isSelected: selectedGoal == goal
                        ) {
                            withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                                selectedGoal = goal
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                startButton
            }
            .padding(.vertical)
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationDestination(for: Goal.self) { goal in
                DetailsView(selectedGoal: goal)
            }
        }
    }
}



private extension OnboardingView {
    
    var headerSection: some View {
        VStack(spacing: 12) {
            
            Image(systemName: "target")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.green)
                )
                .accessibilityHidden(true)
            
            Text("Start Your Journey")
                .font(.title.bold())
                .multilineTextAlignment(.center)
            
            Text("Choose your fitness goal to get personalized tracking")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}



private extension OnboardingView {
    
    var startButton: some View {
        Button {
            if let goal = selectedGoal {
                navigationPath.append(goal)
            }
        } label: {
            Text("Start My Journey")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.9),
                            Color.green.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .disabled(selectedGoal == nil)
        .opacity(selectedGoal == nil ? 0.5 : 1)
        .accessibilityHint("Starts your personalized fitness journey")
    }
}



#Preview {
    OnboardingView()
}

