import SwiftUI

struct WaterTrackingView: View {

    @Environment(AppState.self) private var appState

    private var goal: Int { appState.waterGoalML }
    private var today: Int { appState.todayWaterIntake }
    private var progress: Double { goal > 0 ? min(Double(today) / Double(goal), 1.0) : 0 }

    private var todayEntries: [WaterEntry] {
        let cal = Calendar.current
        return appState.waterEntries
            .filter { cal.isDateInToday($0.date) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                gaugeCard
                quickAddGrid
                if !todayEntries.isEmpty { logCard }
            }
            .padding()
        }
        .navigationTitle("Water Tracker")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Gauge Card

private extension WaterTrackingView {

    var gaugeCard: some View {
        VStack(spacing: 20) {

            // Ring gauge
            ZStack {
                Circle()
                    .stroke(Color.cyan.opacity(0.15), lineWidth: 22)
                    .frame(width: 180)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 22, lineCap: .round)
                    )
                    .frame(width: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.6, bounce: 0.2), value: progress)

                VStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .foregroundStyle(.cyan)
                        .font(.title3)
                    Text("\(today)")
                        .font(.system(size: 34, weight: .bold))
                    Text("of \(goal) ml")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Stats row
            HStack(spacing: 0) {
                waterStat("Consumed", "\(today) ml")
                Divider().frame(height: 32)
                waterStat("Remaining", "\(max(goal - today, 0)) ml")
                Divider().frame(height: 32)
                waterStat("Progress", "\(Int(progress * 100))%")
            }

            if today >= goal {
                Label("Daily water goal achieved! 🎉", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    func waterStat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.subheadline.bold())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick Add

private extension WaterTrackingView {

    var quickAddGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .font(.headline)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(WaterQuickAdd.allCases) { option in
                    Button {
                        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                            appState.addWater(amount: option.rawValue)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: option.icon)
                                .foregroundStyle(.cyan)
                            Text(option.label)
                                .font(.subheadline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.cyan.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Today's Log

private extension WaterTrackingView {

    var logCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Today's Intake")
                .font(.headline)

            ForEach(todayEntries) { entry in
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundStyle(.cyan)
                        .font(.caption)

                    Text("\(entry.amount) ml")
                        .font(.subheadline.bold())

                    Spacer()

                    Text(entry.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button(role: .destructive) {
                        withAnimation {
                            appState.removeWaterEntry(entry)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(Color(.systemGray3))
                    }
                }
                .padding(.vertical, 4)

                if entry.id != todayEntries.last?.id {
                    Divider()
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
        WaterTrackingView()
            .environment(AppState())
    }
}
