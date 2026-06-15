import SwiftUI

struct MealPlanView: View {
    
    let goalCalories: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var mealPlan: MealPlan?
    @State private var refreshID = UUID()
    @State private var preference: DietPreference = .all
    
    private let foods = FoodDatabase.foods
    private let headerHeight: CGFloat = 220
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    Color.clear
                        .frame(height: headerHeight - 40)
                    
                    if let plan = mealPlan {
                        ForEach(plan.meals) { section in
                            mealCard(section)
                        }
                    }
                }
                .padding()
            }
            .id(refreshID)
            
            header
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            generatePlan()
        }
    }
}

//HEADER

private extension MealPlanView {
    
    var header: some View {
        ZStack(alignment: .top) {
            
            LinearGradient(
                colors: [Color.blue, Color.cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: headerHeight)
            .clipShape(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: 30,
                    bottomTrailingRadius: 30
                )
            )
            .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 14) {
                
                HStack {
                    
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button {
                        regenerateTapped()
                    } label: {
                        Label("Regenerate", systemImage: "arrow.clockwise").foregroundStyle(.white)
                            .font(.subheadline.bold())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                
                Text("Smart Meal Plan")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                
                //  DIET
                Picker("Diet", selection: $preference) {
                    ForEach(DietPreference.allCases) { pref in
                        Text(pref.rawValue).tag(pref)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: preference) { _, _ in
                    generatePlan()
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
}

//Generation

private extension MealPlanView {
    
    func regenerateTapped() {
        withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
            generatePlan()
            refreshID = UUID()
        }
    }
    
    func generatePlan() {
        mealPlan = SmartMealPlanner.generate(
            goalCalories: goalCalories,
            foods: foods,
            preference: preference
        )
    }
}

// Meal Card

private extension MealPlanView {
    
    func mealCard(_ section: MealPlanSection) -> some View {
        
        let totalCalories = section.items.reduce(0) { $0 + $1.calories }
        
        return VStack(spacing: 14) {
            
            HStack {
                Label(section.meal.rawValue,
                      systemImage: mealIcon(section.meal))
                    .font(.headline)
                
                Spacer()
                
                Text("\(totalCalories) calories")
                    .font(.headline)
                    .foregroundStyle(.green)
            }
            
            Divider().opacity(0.3)
            
            ForEach(section.items) { item in
                mealRow(item)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
    
    func mealRow(_ item: MealPlanItem) -> some View {
        HStack {
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.food.name)
                    .font(.subheadline.bold())
                
                Text("\(Int(item.servings)) servings")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(item.calories) cal")
                .foregroundStyle(.green)
                .font(.subheadline.bold())
        }
        .padding(.vertical, 4)
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
