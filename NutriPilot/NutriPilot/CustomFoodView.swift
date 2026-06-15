import SwiftUI

struct CustomFoodView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    let selectedMeal: MealType
    
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var fiber = ""
    @State private var servings = 1
    
    var isValid: Bool {
        !name.isEmpty &&
        Int(calories) != nil &&
        Double(protein) != nil &&
        Double(carbs) != nil &&
        Double(fat) != nil &&
        Double(fiber) != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                field("Food Name", text: $name)
                numberField("Calories", text: $calories)
                numberField("Protein (g)", text: $protein)
                numberField("Carbs (g)", text: $carbs)
                numberField("Fat (g)", text: $fat)
                numberField("Fiber (g)", text: $fiber)
                
                Stepper("Servings: \(servings)", value: $servings, in: 1...20)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button {
                    addFood()
                } label: {
                    Text("Add Custom Food")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!isValid)
                .opacity(isValid ? 1 : 0.5)
            }
            .padding()
        }
        .navigationTitle("Custom Food")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addFood() {
        guard
            let cal = Int(calories),
            let p = Double(protein),
            let c = Double(carbs),
            let f = Double(fat),
            let fi = Double(fiber)
        else { return }
        
        appState.addCustomFood(
            name: name,
            calories: cal,
            protein: p,
            carbs: c,
            fat: f,
            fiber: fi,
            servings: Double(servings),
            meal: selectedMeal
        )
        
        dismiss()
    }
}



private extension CustomFoodView {
    
    func field(_ title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .textFieldStyle(.roundedBorder)
    }
    
    func numberField(_ title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
    }
}
