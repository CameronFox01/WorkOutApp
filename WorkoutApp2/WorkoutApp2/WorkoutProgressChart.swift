import SwiftUI
import Charts

// A single point on the workout chart
struct WorkoutDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct WorkoutProgressChart: View {
    // Inputs
    var workoutName: String
    var entries: [WorkoutEntry] // expects entries across all workouts
    var unitSystemRaw: String // to decide weight units label if needed

    // Goal lookup from UserDefaults (as saved in GoalView with key "goal_<workoutName>")
    private var goalValue: Double? {
        if let str = UserDefaults.standard.string(forKey: "goal_\(workoutName)"),
           let val = Double(str) {
            return val
        }
        return nil
    }

    // Additional target weight for Body Weight workout from UserDefaults key "userTargetWeight"
    private var targetBodyWeight: Double? {
        guard workoutName == "Body Weight",
              let str = UserDefaults.standard.string(forKey: "userTargetWeight"),
              let raw = Double(str) else { return nil }
        let displayImperial = UnitSystem(rawValue: unitSystemRaw) == .imperial
        // Normalize to kg then convert to display
        let kg = displayImperial ? (raw / 2.20462) : raw
        let displayValue = displayImperial ? (kg * 2.20462) : kg
        return displayValue
    }

    private var unitLabel: String {
        // If any entry for this workout has non-empty weight, treat as weight-based; else reps
        let isWeightBased = entriesForWorkout.contains { !$0.weight.isEmpty }
        if isWeightBased {
            let unit = UnitSystem(rawValue: unitSystemRaw) == .imperial ? "lbs" : "kg"
            return unit
        } else {
            return "reps"
        }
    }

    // Filter and map entries for the selected workout
    private var entriesForWorkout: [WorkoutEntry] {
        entries.filter { $0.workoutType == workoutName }
            .sorted { $0.date < $1.date }
    }

    private var points: [WorkoutDataPoint] {
        let isWeightBased = entriesForWorkout.contains { !$0.weight.isEmpty }
        let displayImperial = UnitSystem(rawValue: unitSystemRaw) == .imperial
        return entriesForWorkout.compactMap { entry in
            if isWeightBased, let raw = Double(entry.weight), !entry.weight.isEmpty {
                // Normalize to kg first: we don't know the unit the entry was saved in, but we will assume it was saved in the unit active at that time.
                // Since we don't persist per-entry unit, we approximate by converting all values from the CURRENT unit to kg, then back to display unit.
                // This keeps the chart consistent when toggling units.
                let kgFromCurrent: Double = displayImperial ? (raw / 2.20462) : raw
                let displayValue: Double = displayImperial ? (kgFromCurrent * 2.20462) : kgFromCurrent
                return WorkoutDataPoint(date: entry.date, value: displayValue)
            } else if let repsVal = Double(entry.reps), !entry.reps.isEmpty {
                return WorkoutDataPoint(date: entry.date, value: repsVal)
            } else {
                return nil
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workoutName)
                    .font(.headline)
                Spacer()
                Text(unitLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if points.isEmpty {
                ContentUnavailableView("No data yet", systemImage: "chart.xyaxis.line", description: Text("Log some sets to see your progress."))
                    .frame(maxWidth: .infinity)
            } else {
                Chart(points) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )

                    if let latest = latestPoint, latest.id == point.id {
                        PointMark(
                            x: .value("Date", latest.date),
                            y: .value("Value", latest.value)
                        )
                        .foregroundStyle(Color.accentColor)
                        .annotation(position: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(format(latest.value)) \(unitLabel)")
                                    .font(.caption).bold()
                                if let ref = (goalValue ?? targetBodyWeight) {
                                    let delta = latest.value - ref
                                    Text(deltaText(delta))
                                        .font(.caption2)
                                        .foregroundStyle(delta >= 0 ? .green : .secondary)
                                }
                            }
                            .padding(6)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                }
                .chartYScale(domain: yDomainNonOptional)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .frame(height: 240)
                .padding(.top, 4)
                .overlay(alignment: .trailing) {
                    if let goal = goalValue {
                        goalBadge(goal: goal)
                    } else if let t = targetBodyWeight {
                        goalBadge(goal: t)
                    }
                }
                .overlay {
                    if let goal = goalValue {
                        goalLine(goal: goal)
                    } else if let t = targetBodyWeight {
                        goalLine(goal: t)
                    }
                }
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var yDomain: ClosedRange<Double>? {
        guard !points.isEmpty else { return nil }
        let minVal = points.map(\.value).min() ?? 0
        let maxVal = max(points.map(\.value).max() ?? 0, max(goalValue ?? 0, targetBodyWeight ?? 0))
        if minVal == maxVal { return (minVal - 1)...(maxVal + 1) }
        return (minVal * 0.9)...(maxVal * 1.1)
    }

    private var yDomainNonOptional: ClosedRange<Double> {
        if let domain = yDomain { return domain }
        // Fallback: compute from points or default
        let values = points.map(\.value)
        let minVal = values.min() ?? 0
        let maxVal = max(values.max() ?? 1, max(goalValue ?? 0, targetBodyWeight ?? 0))
        if minVal == maxVal { return (minVal - 1)...(maxVal + 1) }
        return (minVal * 0.9)...(maxVal * 1.1)
    }

    private var latestPoint: WorkoutDataPoint? { points.last }

    private func deltaText(_ delta: Double) -> String {
        let prefix = delta >= 0 ? "+" : ""
        return "\(prefix)\(format(delta)) vs goal"
    }

    @ViewBuilder
    private func goalLine(goal: Double) -> some View {
        GeometryReader { geo in
            let height = geo.size.height
            if let domain = yDomain {
                let normalized = (goal - domain.lowerBound) / (domain.upperBound - domain.lowerBound)
                let y = height * (1 - normalized)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.accentColor)
            }
        }
    }

    @ViewBuilder
    private func goalBadge(goal: Double) -> some View {
        Text("Goal: \(format(goal)) \(unitLabel)")
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(8)
    }

    private func format(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }
}

