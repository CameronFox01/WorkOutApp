import SwiftUI

struct WorkoutChartView: View {
    @State private var selectedEntryID: UUID?
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings
    
    @EnvironmentObject var workoutData: WorkoutData

    let workoutName: String
    let entries: [WorkoutEntry]
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    
    
    // copied over
    let category: WorkoutCategory
    var saveAction: (WorkoutCategory) -> Void = { _ in }
    @State private var selections: [WorkoutCategory: String] = [:]
    @State private var weights: [WorkoutCategory: String] = [:]
    @State private var reps: [WorkoutCategory: String] = [:]
    @State private var sets: [WorkoutCategory: String] = [:]
    @State private var distances: [WorkoutCategory: String] = [:]
    @State private var times: [WorkoutCategory: String] = [:]
    @State private var notes: [WorkoutCategory: String] = [:]
    @State private var entriesLocal: [WorkoutEntry] = []
    @State private var showSavedToastLocal: Bool = false
    @State private var unitSystemRawLocal: String = UnitSystem.metric.rawValue
    @State private var showSavedToast: Bool = false
    private var GoToHomeScreenWhenSaved: Bool { false }
    let workout: String

    var body: some View {
        ZStack {
            // Same gradient as TimeViewBig
            LinearGradient(
                colors: gradientSettings.darkGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

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
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(gradientSettings.selectedPreset.topColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(workoutName.capitalized)
                    .font(.title2).bold()
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(
                    destination: ImportView.CategoryDetailView(
                    category: category,
                    date: Date(),
                    unitSystemRaw: $unitSystemRawLocal,
                    selections: $selections,
                    weights: $weights,
                    reps: $reps,
                    sets: $sets,
                    distances: $distances,
                    times: $times,
                    entries: $entriesLocal,
                    notes: $notes,
                    save: { saveEntry()},
                    increment: { dict, step in self.increment(&dict, for: category, by: Int(step)) },
                    decrement: { dict, step in self.decrement(&dict, for: category, by: Int(step)) },
                    weightUnitProvider: { self.weightUnit },
                    goHomeAfterSave: GoToHomeScreenWhenSaved,
                    showSavedToast: $showSavedToast,
                    resetParent: { resetImportView() }
                )
                .onAppear{
                    if selections[category] == nil {
                        selections[category] = workout
                    }
                })
                {
                    Label("Import", systemImage: "plus")
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
    // Reset behavior used after save when GoToHomeScreenWhenSaved is true
    private func resetImportView() {
        selections.removeAll()
        weights.removeAll()
        reps.removeAll()
        sets.removeAll()
        distances.removeAll()
        times.removeAll()
        notes.removeAll()
    }

    private var entriesForWorkout: [WorkoutEntry] {
        entries
            .filter { $0.workoutType == workoutName }
            .sorted { $0.date > $1.date }
    }

    private var mostRecentEntry: WorkoutEntry? {
        entriesForWorkout.first
    }

    private var weightUnit: String {
        UnitSystem(rawValue: unitSystemRaw) == .imperial ? "lbs" : "kg"
    }

    // MARK: - Details Section
    @ViewBuilder
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Details")
                .font(.title3.bold())
                .foregroundStyle(.white)

            if entriesForWorkout.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.4))
                    Text("No sets yet")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("Log a set to see details here.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

            } else {

                // MARK: Recent Sets
                VStack(alignment: .leading, spacing: 10) {
                    Label("Recent Sets", systemImage: "clock.arrow.circlepath")
                        .font(.headline.bold())
                        .foregroundStyle(.white)

                    let latestEntry = mostRecentEntry!
                    NavigationLink(destination: EditWorkoutView(entry: latestEntry)) {
                        HStack {
                            Text(latestEntry.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                            Spacer()
                            Text(detailLine(for: latestEntry))
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                            Image(systemName: "plus")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(12)
                        .background(.white.opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    if entriesForWorkout.count > 1 {
                        ForEach(entriesForWorkout.dropFirst(1).prefix(4)) { e in
                            HStack {
                                Text(e.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.75))
                                Spacer()
                                Text(detailLine(for: e))
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.55))
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.white.opacity(0.10))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                )

                // MARK: Highlights
                VStack(alignment: .leading, spacing: 12) {
                    Label("Highlights", systemImage: "star.fill")
                        .font(.headline.bold())
                        .foregroundStyle(.white)

                    let totalSessions = Set(entriesForWorkout.map {
                        Calendar.current.startOfDay(for: $0.date)
                    }).count

                    HStack(spacing: 12) {

                        if isDistanceCardio {

                            if let bestDistance = bestDistance() {
                                highlightPill(
                                    icon: "figure.walk",
                                    label: UnitSystem(rawValue: unitSystemRaw) == .imperial
                                        ? "Best Miles"
                                        : "Best KM",
                                    value: bestDistance
                                )
                            }

                        } else if isTimeCardio {

                            if let bestTime = bestTime() {
                                highlightPill(
                                    icon: "timer",
                                    label: "Longest Time",
                                    value: bestTime
                                )
                            }

                        } else if isSports{
                            if let bestSports = bestTime(){
                                highlightPill(
                                    icon: "timer",
                                    label: "Longest Time",
                                    value: bestSports)
                            }
                        } else if isRecovery{
                            if let bestTime = bestTime(){
                                highlightPill(
                                    icon: "timer",
                                    label: "Longest Time",
                                    value: bestTime)
                            }
                        } else {

                            let (bestWeight, bestReps) = bests()

                            if let bestWeight {
                                highlightPill(
                                    icon: "scalemass.fill",
                                    label: "Best Weight",
                                    value: "\(bestWeight) \(weightUnit)"
                                )
                            }

                            if let bestReps {
                                highlightPill(
                                    icon: "number",
                                    label: "Best Reps",
                                    value: bestReps
                                )
                            }
                        }

                        highlightPill(
                            icon: "calendar",
                            label: "Sessions",
                            value: "\(totalSessions)"
                        )
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.white.opacity(0.10))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                )
            }
        }
    }
    
    // MARK: - Helpers for ImportView navigation

    private func saveEntry() {
        WorkoutApp2.saveEntry(
            for: category,
            selections: selections,
            weights: weights,
            reps: reps,
            sets: sets,
            distances: distances,
            times: times,
            notes: notes,
            workoutData: workoutData,
            onSuccess: {
                showSavedToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showSavedToast = false
                }
            },
            onError: { }
        )
    }

    private func increment(_ dict: inout [WorkoutCategory: String], for category: WorkoutCategory, by step: Int) {
        let current = Int(dict[category] ?? "0") ?? 0
        dict[category] = String(current + step)
    }

    private func decrement(_ dict: inout [WorkoutCategory: String], for category: WorkoutCategory, by step: Int) {
        let current = Int(dict[category] ?? "0") ?? 0
        let next = max(0, current - step)
        dict[category] = String(next)
    }
    
    private var graphMetricName: String {
        if isDistanceCardio {
            return UnitSystem(rawValue: unitSystemRaw) == .imperial ? "Distance (mi)" : "Distance (km)"
        } else if isTimeCardio {
            return "Time (min)"
        } else {
            return "Reps"
        }
    }

    private func graphValue(for entry: WorkoutEntry) -> Double {
        if isDistanceCardio {
            return Double(entry.weight) ?? 0
        } else if isTimeCardio {
            return Double(entry.reps) ?? 0
        } else {
            return Double(entry.reps) ?? 0
        }
    }

    private var isDistanceCardio: Bool {
        DistanceCardioWorkout.allCases
            .map(\.rawValue)
            .contains(workoutName)
    }

    private var isTimeCardio: Bool {
        TimeCardioWorkout.allCases
            .map(\.rawValue)
            .contains(workoutName)
    }
    
    private var isSports: Bool {
        SportsWorkout.allCases
            .map(\.rawValue)
            .contains(workoutName)
    }
    
    private var isRecovery: Bool {
        RecoveryWorkout.allCases
            .map(\.rawValue)
            .contains(workoutName)
    }
    
    private func bestDistance() -> String? {
        entriesForWorkout
            .compactMap { Double($0.weight) }
            .max()
            .map {
                "\(format($0)) " +
                (UnitSystem(rawValue: unitSystemRaw) == .imperial ? "mi" : "km")
            }
    }

    private func bestTime() -> String? {
        entriesForWorkout
            .compactMap { Double($0.reps) }
            .max()
            .map {
                "\(format($0)) min"
            }
    }

    private func highlightPill(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func detailLine(for entry: WorkoutEntry) -> String {

        if isDistanceCardio {

            let distance = entry.weight.isEmpty
                ? "0"
                : entry.weight

            let unit = UnitSystem(rawValue: unitSystemRaw) == .imperial
                ? "mi"
                : "km"

            let time = entry.sets.isEmpty
                ? ""
                : " • \(entry.sets) min"

            return "\(distance) \(unit)\(time)"
        }

        if isTimeCardio || isRecovery {

            let time = entry.sets.isEmpty
                ? entry.reps
                : entry.sets

            return "\(time) min"
        }
        
        if isSports {
            
            let time = entry.reps.isEmpty
            ? entry.sets
            : entry.reps
            
            return "\(time) min"
        }

        // Normal strength workouts
        if let w = Double(entry.weight),
           !entry.weight.isEmpty {

            return "\(format(w)) \(weightUnit) × \(entry.reps) reps"
        }

        if !entry.reps.isEmpty {
            return "\(entry.reps) reps"
        }

        return "No data"
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
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}

#Preview {
    let isWeighted: Bool = false
    let weightedEntries: [WorkoutEntry] = [
        WorkoutEntry(workoutType: "Bench Press", weight: "135", reps: "8", sets: "2", date: .now.addingTimeInterval(-86400 * 6), note: "Felt sore"),
        WorkoutEntry(workoutType: "Bench Press", weight: "145", reps: "8", sets: "3", date: .now.addingTimeInterval(-86400 * 4), note: "Felt sore"),
        WorkoutEntry(workoutType: "Bench Press", weight: "155", reps: "6", sets: "5", date: .now.addingTimeInterval(-86400 * 2), note: ""),
        WorkoutEntry(workoutType: "Bench Press", weight: "165", reps: "5", sets: "4", date: .now, note: ""),
        WorkoutEntry(workoutType: "Bench Press", weight: "165", reps: "5", sets: "4", date: .now, note: ""),
        WorkoutEntry(workoutType: "Bench Press", weight: "165", reps: "5", sets: "4", date: .now, note: ""),
        WorkoutEntry(workoutType: "Bench Press", weight: "165", reps: "5", sets: "4", date: .now, note: ""),
        WorkoutEntry(workoutType: "Bench Press", weight: "165", reps: "5", sets: "4", date: .now.addingTimeInterval(-86400), note: "")
    ]

    let distanceEntries: [WorkoutEntry] = [
        WorkoutEntry(workoutType: "Brisk Walking", weight: "2.5", reps: "", sets: "32", date: .now, note: "Latest Walk"),
        WorkoutEntry(workoutType: "Brisk Walking", weight: "0.8", reps: "", sets: "14", date: .now.addingTimeInterval(-86400 * 2), note: "First Walk")
    ]

    if isWeighted {
        NavigationView {
            WorkoutChartView(
                workoutName: "Bench Press",
                entries: weightedEntries,
                category: .push,
                workout: "Bench Press"
            )
            .environmentObject(GradientSettings())
            .environmentObject(WorkoutData())
        }
    } else {
        NavigationView {
            WorkoutChartView(
                workoutName: "Brisk Walking",
                entries: distanceEntries,
                category: .distanceCardio,
                workout: "Brisk Walking"
            )
            .environmentObject(GradientSettings())
            .environmentObject(WorkoutData())
        }
    }
}
