

import SwiftUI

struct Goal: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
}

let goals: [Goal] = [
    Goal(
        title: "Fat Loss",
        subtitle: "Lose weight and burn fat with a calorie deficit",
        icon: "chart.line.downtrend.xyaxis"
    ),
    Goal(
        title: "Weight Gain",
        subtitle: "Gain healthy weight with a calorie surplus",
        icon: "chart.line.uptrend.xyaxis"
    ),
    Goal(
        title: "Muscle Building",
        subtitle: "Build muscle mass with strength training focus",
        icon: "dumbbell.fill"
    ),
    Goal(
        title: "Lean Bulk",
        subtitle: "Gain muscle while minimizing fat gain",
        icon: "target"
    )
]

