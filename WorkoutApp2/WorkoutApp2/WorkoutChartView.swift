import SwiftUI

struct WorkoutChartView: View {
    let workoutName: String
    let entries: [WorkoutEntry]
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                WorkoutProgressChart(
                    workoutName: workoutName,
                    entries: entriesForWorkout,
                    unitSystemRaw: unitSystemRaw
                )

                detailsSection
            }
            .padding(.horizontal)
        }
        .navigationTitle(workoutName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var entriesForWorkout: [WorkoutEntry] {
        entries
            .filter { $0.workoutType == workoutName }
            .sorted { $0.date > $1.date }
    }

    private var weightUnit: String {
        UnitSystem(rawValue: unitSystemRaw) == .imperial ? "lbs" : "kg"
    }

    // MARK: - Details below the chart
    @ViewBuilder
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.title3).bold()

            if entriesForWorkout.isEmpty {
                ContentUnavailableView("No sets yet", systemImage: "list.bullet.rectangle", description: Text("Log a set to see details here."))
            } else {
                // Recent sets
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Sets")
                        .font(.headline)
                    ForEach(entriesForWorkout.prefix(5)) { e in
                        HStack {
                            Text(e.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                            Spacer()
                            Text(detailLine(for: e))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Highlights
                VStack(alignment: .leading, spacing: 8) {
                    Text("Highlights")
                        .font(.headline)

                    let (bestWeight, bestReps) = bests()
                    if let bestWeight {
                        Text("Best Weight: \(bestWeight) \(weightUnit)")
                            .font(.subheadline)
                    }
                    if let bestReps {
                        Text("Best Reps: \(bestReps)")
                            .font(.subheadline)
                    }

                    let totalSessions = Set(entriesForWorkout.map { Calendar.current.startOfDay(for: $0.date) }).count
                    Text("Total Sessions: \(totalSessions)")
                        .font(.subheadline)
                }
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func detailLine(for entry: WorkoutEntry) -> String {
        if let w = Double(entry.weight), !entry.weight.isEmpty {
            return "\(format(w)) \(weightUnit) x \(entry.reps)"
        } else {
            return "\(entry.reps) reps"
        }
    }

    private func bests() -> (bestWeight: String?, bestReps: String?) {
        let w = entriesForWorkout
            .compactMap { Double($0.weight) }
            .max()
            .map { format($0) }
        let r = entriesForWorkout
            .compactMap { Int($0.reps) }
            .max()
            .map { String($0) }
        return (w, r)
    }

    private func format(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }
}

#Preview {
    let sampleEntries: [WorkoutEntry] = [
        WorkoutEntry(workoutType: "Bench Press", weight: "135", reps: "8", date: .now.addingTimeInterval(-86400 * 6)),
        WorkoutEntry(workoutType: "Bench Press", weight: "145", reps: "8", date: .now.addingTimeInterval(-86400 * 4)),
        WorkoutEntry(workoutType: "Bench Press", weight: "155", reps: "6", date: .now.addingTimeInterval(-86400 * 2)),
        WorkoutEntry(workoutType: "Bench Press", weight: "165", reps: "5", date: .now)
    ]
    return NavigationView { WorkoutChartView(workoutName: "Bench Press", entries: sampleEntries) }
}
