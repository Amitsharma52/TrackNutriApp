import SwiftUI

struct DetailsView: View {
    
    let selectedGoal: Goal?

    @Environment(AppState.self) private var appState

    // Onboarding flags
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("savedGoalCalories") private var savedGoalCalories = 2000
    
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var gender: Gender? = nil
    @State private var activity: ActivityLevel? = nil

    
    // Validation
    
    var isFormValid: Bool {
        guard
            let ageVal = Double(age),
            let weightVal = Double(weight),
            let heightVal = Double(height),
            gender != nil,
            activity != nil
        else { return false }
        
        return ageVal > 0 && weightVal > 0 && heightVal > 0
    }
    
    // Calories
    
    var maintenanceCalories: Int {
        guard isFormValid,
              let age = Double(age),
              let weight = Double(weight),
              let height = Double(height),
              let gender = gender,
              let activity = activity
        else { return 0 }
        
        let bmr: Double
        
        if gender == .male {
            bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5
        } else {
            bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161
        }
        
        return Int(bmr * activity.multiplier)
    }
    
    var recommendedCalories: Int {
        guard let goal = selectedGoal else { return maintenanceCalories }
        
        switch goal.title {
        case "Fat Loss":
            return maintenanceCalories - 500
        case "Weight Gain", "Lean Bulk", "Muscle Building":
            return maintenanceCalories + 300
        default:
            return maintenanceCalories
        }
    }
    
    // UI
    
    var body: some View {
        List {
            Section("Personal Information") {
                HStack {
                    Text("Age")
                    Spacer()
                    TextField("Required", text: $age)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Weight (kg)")
                    Spacer()
                    TextField("Required", text: $weight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Height (cm)")
                    Spacer()
                    TextField("Required", text: $height)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gender")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag(Gender.male as Gender?)
                        Text("Female").tag(Gender.female as Gender?)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 4)
            }
            
            Section("Activity Level") {
                ForEach(ActivityLevel.allCases) { level in
                    Button {
                        withAnimation {
                            activity = level
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.rawValue)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Text(level.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if activity == level {
                                Image(systemName: "checkmark")
                                    .font(.body.bold())
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if isFormValid {
                Section("Your Personalized Plan") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Maintenance")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(maintenanceCalories) cal/day")
                                    .font(.body.bold())
                            }
                            Spacer()
                            Divider()
                            Spacer()
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recommended Goal")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(recommendedCalories) cal/day")
                                    .font(.body.bold())
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Text("Based on your details and goal")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Your Details")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()
                Button {
                    guard isFormValid,
                          let ageVal      = Int(age),
                          let weightVal   = Double(weight),
                          let heightVal   = Double(height),
                          let genderVal   = gender,
                          let activityVal = activity
                    else { return }

                    savedGoalCalories = recommendedCalories

                    // Persist full profile so Dashboard, Analytics & Profile views have data
                    appState.saveProfile(
                        UserProfile(
                            age: ageVal,
                            weight: weightVal,
                            height: heightVal,
                            gender: genderVal,
                            activityLevel: activityVal,
                            goalType: selectedGoal?.title ?? "Maintenance",
                            goalCalories: recommendedCalories
                        )
                    )

                    hasCompletedOnboarding = true
                } label: {
                    Text("Continue to Dashboard")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(isFormValid ? Color.green : Color.gray.opacity(0.3))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!isFormValid)
                .padding()
            }
            .background(.ultraThinMaterial)
        }
    }
}

