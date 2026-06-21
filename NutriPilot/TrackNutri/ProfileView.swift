import SwiftUI

struct ProfileView: View {

    @Environment(AppState.self) private var appState
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("savedGoalCalories") private var savedGoalCalories = 2000

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let profile = appState.userProfile {
                    headerCard(profile)
                    bodyStatsCard(profile)
                    statsGrid(profile)
                    goalCard(profile)
                    resetGoalButton
                } else {
                    emptyState
                }
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Header

private extension ProfileView {

    func headerCard(_ p: UserProfile) -> some View {
        VStack(spacing: 14) {

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)

                Image(systemName: "person.fill")
                    .font(.title)
                    .foregroundStyle(.white)
            }

            VStack(spacing: 4) {
                Text(p.gender.rawValue)
                    .font(.title2.bold())
                Text("Age \(p.age) · \(p.goalType)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Member since \(p.createdAt.formatted(.dateTime.month().year()))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color.green.opacity(0.12), Color.green.opacity(0.04)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Body Stats + BMI

private extension ProfileView {

    func bodyStatsCard(_ p: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text("Body Stats")
                    .font(.headline)
                Spacer()
                Text(p.bmiCategory)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(bmiColor(p.bmi).opacity(0.15))
                    .foregroundStyle(bmiColor(p.bmi))
                    .clipShape(Capsule())
            }

            // Weight / Height / BMI
            HStack(spacing: 0) {
                bodyStat("Weight", String(format: "%.1f", p.weight), "kg")
                Divider().frame(height: 40)
                bodyStat("Height", String(format: "%.0f", p.height), "cm")
                Divider().frame(height: 40)
                bodyStat("BMI",    String(format: "%.1f", p.bmi),    "")
            }

            // BMI colour scale
            VStack(alignment: .leading, spacing: 6) {
                Text("BMI Scale")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        LinearGradient(
                            colors: [.blue, .green, .yellow, .orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 8)
                        .clipShape(Capsule())

                        let clamped  = min(max(p.bmi, 15.0), 40.0)
                        let fraction = (clamped - 15.0) / 25.0
                        Circle()
                            .fill(.white)
                            .frame(width: 18, height: 18)
                            .shadow(color: .black.opacity(0.2), radius: 3)
                            .offset(x: geo.size.width * fraction - 9)
                    }
                }
                .frame(height: 18)

                HStack {
                    ForEach(["15", "18.5", "25", "30", "40"], id: \.self) { label in
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        if label != "40" { Spacer() }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    func bmiColor(_ bmi: Double) -> Color {
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }

    func bodyStat(_ title: String, _ value: String, _ unit: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value).font(.title3.bold())
                if !unit.isEmpty {
                    Text(unit).font(.caption).foregroundStyle(.secondary)
                }
            }
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stats Grid

private extension ProfileView {

    func statsGrid(_ p: UserProfile) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 14
        ) {
            miniStat("Calorie Goal",  "\(p.goalCalories)",         "cal/day",    "flame.fill",         .green)
            miniStat("Maintenance",   "\(p.maintenanceCalories)",  "cal/day",    "equal.circle.fill",  .blue)
            miniStat("Activity",      p.activityLevel.rawValue,    p.activityLevel.subtitle, "figure.run", .orange)
            miniStat("Water Goal",    "\(p.dailyWaterGoalML)",     "ml/day",     "drop.fill",          .cyan)
        }
    }

    func miniStat(_ title: String, _ value: String, _ unit: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value)
                .font(.headline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(unit).font(.caption2).foregroundStyle(color.opacity(0.8)).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Goal Card

private extension ProfileView {

    func goalCard(_ p: UserProfile) -> some View {
        HStack(spacing: 16) {
            Image(systemName: goalIcon(p.goalType))
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(p.goalType).font(.headline)
                Text(goalDescription(p.goalType))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    func goalIcon(_ g: String) -> String {
        switch g {
        case "Fat Loss":         return "chart.line.downtrend.xyaxis"
        case "Weight Gain":      return "chart.line.uptrend.xyaxis"
        case "Muscle Building":  return "dumbbell.fill"
        case "Lean Bulk":        return "target"
        default:                 return "star.fill"
        }
    }

    func goalDescription(_ g: String) -> String {
        switch g {
        case "Fat Loss":         return "~500 cal deficit below maintenance"
        case "Weight Gain":      return "~300 cal surplus above maintenance"
        case "Muscle Building":  return "Calorie surplus with strength focus"
        case "Lean Bulk":        return "Moderate surplus, minimal fat gain"
        default:                 return "Maintain current weight"
        }
    }

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text("No profile found")
                .font(.headline)
            Text("Complete onboarding to build your profile")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Reset Goal & Restart

private extension ProfileView {

    var resetGoalButton: some View {
        Button(role: .destructive) {
            performFullReset()
        } label: {
            Text("Reset Goal & Restart")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(.ultraThinMaterial)
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.25), lineWidth: 1)
                )
        }
        .padding(.top, 10)
    }

    func performFullReset() {
        // clear logged foods
        appState.loggedFoods.removeAll()

        // reset onboarding
        hasCompletedOnboarding = false

        // reset calories goal
        savedGoalCalories = 2000
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(AppState())
    }
}
