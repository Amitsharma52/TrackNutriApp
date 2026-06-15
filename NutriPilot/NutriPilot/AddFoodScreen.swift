import SwiftUI

enum DietFilter: String, CaseIterable, Identifiable {
case all = "All Foods"
case veg = "Vegetarian"
case nonVeg = "Non-Veg"
var id: String { rawValue }
}


extension FoodItem {
var isVeg: Bool {
let lower = name.lowercased()
if lower.contains("chicken") || lower.contains("salmon") {
return false
}
return true
}
}

struct AddFoodView: View {


@Environment(AppState.self) private var appState
@Environment(\.dismiss) private var dismiss

@State private var searchText = ""
@State private var selectedMeal: MealType = .breakfast
@State private var selectedFilter: DietFilter = .all
@State private var expandedFoodID: UUID?
@State private var servings: Int = 1

private let foods = FoodDatabase.foods

var filteredFoods: [FoodItem] {
    foods.filter { food in
        
        let matchesSearch =
        searchText.isEmpty ||
        food.name.localizedCaseInsensitiveContains(searchText)
        
        let matchesDiet: Bool = {
            switch selectedFilter {
            case .all: return true
            case .veg: return food.isVeg
            case .nonVeg: return !food.isVeg
            }
        }()
        
        return matchesSearch && matchesDiet
    }
}



var body: some View {
    ScrollView {
        VStack(spacing: 20) {
            header
            NavigationLink {
                CustomFoodView(selectedMeal: selectedMeal)
            } label: {
                Label("Add Custom Food", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            searchBar
            filterChips
            mealSelector
            foodList
        }
        .padding()
    }
    .navigationTitle("Add Food")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
        ToolbarItem(placement: .topBarLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
    }
}


}



private extension AddFoodView {


var header: some View {
    VStack(alignment: .leading, spacing: 4) {
        Text("Search and track your meals")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}

var searchBar: some View {
    HStack {
        Image(systemName: "magnifyingglass")
            .foregroundStyle(.secondary)
        
        TextField("Search foods...", text: $searchText)
    }
    .padding(12)
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 14))
}

var filterChips: some View {
    HStack(spacing: 10) {
        ForEach(DietFilter.allCases) { filter in
            Button {
                selectedFilter = filter
            } label: {
                Text(filter.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        selectedFilter == filter
                        ? Color.green
                        : Color(.systemGray5)
                    )
                    .foregroundStyle(
                        selectedFilter == filter ? .white : .primary
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}

var mealSelector: some View {
    VStack(alignment: .leading, spacing: 10) {
        
        Text("Select Meal Type")
            .font(.headline)
        
        Menu {
            ForEach(MealType.allCases) { meal in
                Button {
                    selectedMeal = meal
                } label: {
                    Label(
                        meal.rawValue,
                        systemImage: selectedMeal == meal ? "checkmark" : ""
                    )
                }
            }
        } label: {
            HStack {
                Text(selectedMeal.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

var foodList: some View {
    VStack(spacing: 14) {
        
        Text("Popular Foods")
            .font(.title3.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
        
        ForEach(filteredFoods) { food in
            foodRow(food)
        }
    }
}

func foodRow(_ food: FoodItem) -> some View {
    VStack(spacing: 0) {
        
        Button {
            withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                if expandedFoodID == food.id {
                    expandedFoodID = nil
                } else {
                    expandedFoodID = food.id
                    servings = 1
                }
            }
        } label: {
            HStack {
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    HStack {
                        Text(food.name)
                            .font(.headline)
                        
                        if food.isVeg {
                            Image(systemName: "leaf.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                                .padding(6)
                                .background(Color.green.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("\(food.baseAmount) • Protein")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("P: \(food.protein, specifier: "%.0f")g   C: \(food.carbs, specifier: "%.0f")g   F: \(food.fat, specifier: "%.1f")g   Fiber: \(food.fiber, specifier: "%.0f")g")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(food.calories)")
                        .font(.title3.bold())
                        .foregroundStyle(.green)
                    Text("calories")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        expandedFoodID == food.id
                        ? Color.green
                        : Color(.systemGray4),
                        lineWidth: expandedFoodID == food.id ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        
        if expandedFoodID == food.id {
            expandedSection(food)
        }
    }
}

func expandedSection(_ food: FoodItem) -> some View {
    
    let totalCalories = food.calories * servings
    let totalProtein = food.protein * Double(servings)
    let totalCarbs = food.carbs * Double(servings)
    let totalFat = food.fat * Double(servings)
    let totalFiber = food.fiber * Double(servings)
    
    return VStack(spacing: 16) {
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Number of Servings")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Stepper(value: $servings, in: 1...20) {
                Text("\(servings)")
                    .font(.headline)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Text("Total Calories:")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(totalCalories)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.green)
            }
            
            Text("1x \(food.baseAmount)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Divider().overlay(Color.green.opacity(0.3))
            
            HStack {
                macroMini("Protein", totalProtein)
                Spacer()
                macroMini("Carbs", totalCarbs)
                Spacer()
                macroMini("Fat", totalFat)
                Spacer()
                macroMini("Fiber", totalFiber)
            }
        }
        .padding()
        .background(Color.green.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        
        Button {
            appState.addFood(food,
                             servings: Double(servings),
                             meal: selectedMeal)
            
            withAnimation {
                expandedFoodID = nil
                servings = 1
            }
        } label: {
            Label("Add to \(selectedMeal.rawValue)", systemImage: "plus")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.green, lineWidth: 2)
            .background(Color.green.opacity(0.04))
    )
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .padding(.top, 8)
}

func macroMini(_ title: String, _ value: Double) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
        Text("\(value, specifier: "%.1f")g")
            .font(.headline)
    }
}


}
