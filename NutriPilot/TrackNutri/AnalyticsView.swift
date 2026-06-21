import SwiftUI
import Charts

struct AnalyticsView: View {

    let goalCalories: Int
    @Environment(AppState.self) private var appState

    private var macroTargets: MacroTargets { MacroTargets.fromCalories(goalCalories) }

    private var analytics: WeeklyAnalytics {
        AnalyticsEngine.compute(
            logs: appState.loggedFoods,
            goalCalories: goalCalories,
            macroTargets: macroTargets
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                streakBanner
                weeklyChart
                insightsGrid
                proteinCard
            }
            .padding()
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Streak Banner

private extension AnalyticsView {

    var streakBanner: some View {
        HStack(alignment: .top, spacing: 16) {

            VStack(alignment: .leading, spacing: 4) {
                Label("Current Streak", systemImage: "bolt.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.85))

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(analytics.streak)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                    Text("days")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 12) {
                statChip("Avg Calories", "\(analytics.averageCalories) cal")
                statChip("Days on Track", "\(analytics.daysOnTrack) / 7")
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.orange, Color.orange.opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    func statChip(_ title: String, _ value: String) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(.white)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}

// MARK: - Weekly Bar Chart

private extension AnalyticsView {

    var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("7-Day Calorie Trend")
                .font(.headline)

            Chart(analytics.weeklyData) { day in

                BarMark(
                    x: .value("Day", day.shortDay),
                    y: .value("Calories", day.calories)
                )
                .foregroundStyle(barColor(for: day).gradient)
                .cornerRadius(8)

                RuleMark(y: .value("Goal", goalCalories))
                    .foregroundStyle(Color.green.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Goal")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
            }
            .chartYScale(domain: 0...(maxChartY()))
            .frame(height: 180)

            // Legend
            HStack(spacing: 16) {
                legendDot(.green,  "On Track")
                legendDot(.orange, "Below Goal")
                legendDot(Color(.systemGray4), "Not Logged")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    func barColor(for day: DayCalorieData) -> Color {
        if day.calories == 0 { return Color(.systemGray4) }
        return day.isOnTrack ? .green : .orange
    }

    func maxChartY() -> Int {
        let maxLogged = analytics.weeklyData.map { $0.calories }.max() ?? 0
        return max(maxLogged, goalCalories) + 400
    }

    func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Insight Cards Grid

private extension AnalyticsView {

    var insightsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 14
        ) {
            insightCard("Avg Calories",   "\(analytics.averageCalories)", "cal/day",       "flame.fill",         .orange)
            insightCard("Days on Track",  "\(analytics.daysOnTrack)",     "of 7 days",     "checkmark.circle.fill", .green)
            insightCard("Streak",         "\(analytics.streak)",          "consecutive",   "bolt.fill",          .yellow)
            insightCard("Protein Score",  "\(Int(analytics.proteinConsistency * 100))%", "consistency", "dumbbell.fill", .purple)
        }
    }

    func insightCard(
        _ title: String,
        _ value: String,
        _ unit: String,
        _ icon: String,
        _ color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2.bold())
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(color.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Protein Consistency Ring

private extension AnalyticsView {

    var proteinCard: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Protein Consistency (7 days)")
                .font(.headline)

            HStack(spacing: 20) {

                ZStack {
                    Circle()
                        .stroke(Color.purple.opacity(0.2), lineWidth: 14)
                        .frame(width: 96)

                    Circle()
                        .trim(from: 0, to: analytics.proteinConsistency)
                        .stroke(
                            Color.purple,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 96)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(duration: 0.7, bounce: 0.2), value: analytics.proteinConsistency)

                    Text("\(Int(analytics.proteinConsistency * 100))%")
                        .font(.headline.bold())
                        .foregroundStyle(.purple)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Hitting ≥ 80% protein goal")
                        .font(.subheadline.bold())
                    Text("Across active logged days in the past week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if analytics.proteinConsistency < 0.5 {
                        Label("Add more protein-rich foods", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        AnalyticsView(goalCalories: 2000)
            .environment(AppState())
    }
}
