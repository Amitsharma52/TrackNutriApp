
import SwiftUI

struct DailyProgressView: View {
    
    let goalCalories: Int
    @Environment(AppState.self) private var appState
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("savedGoalCalories") private var savedGoalCalories = 2000
    
    @State private var selectedDate = Date()

    var eaten: Int {
        appState.calories(for: selectedDate)
    }
    
    var progress: Double {
        guard goalCalories > 0 else { return 0 }
        return Double(eaten) / Double(goalCalories)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                //Calendar
                calendarSection
                
                progressCard
                foodsList
                

            }
            .padding()
        }
        .navigationTitle("Daily Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}



private extension DailyProgressView {
    
    var calendarSection: some View {
        DatePicker(
            "Select Date",
            selection: $selectedDate,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}



private extension DailyProgressView {
    
    var progressCard: some View {
        VStack(spacing: 16) {
            
            Text("Calories Progress")
                .font(.headline)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 14)
                    .frame(width: 140)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.green,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 140)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(eaten)")
                        .font(.title.bold())
                    Text("of \(goalCalories)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}



private extension DailyProgressView {
    
    var foodsList: some View {
        let items = appState.foods(for: selectedDate)
        
        return VStack(alignment: .leading, spacing: 12) {
            
            Text("Meals on this day")
                .font(.headline)
            
            if items.isEmpty {
                Text("No meals logged")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(items) { item in
                    row(item)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    func row(_ item: LoggedFood) -> some View {
        let cal = Int(Double(item.food.calories) * item.servings)
        
        return HStack {
            VStack(alignment: .leading) {
                Text(item.food.name)
                    .font(.subheadline.bold())
                Text(item.meal.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(cal) cal")
                .foregroundStyle(.green)
                .font(.subheadline.bold())
        }
        .padding(.vertical, 4)
    }
}
