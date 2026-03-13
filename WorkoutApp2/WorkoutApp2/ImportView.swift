//
//  ImportView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//
// TODO: I need to get this not to show weights on certain workouts.
import SwiftUI

struct WorkoutEntry: Identifiable, Codable {
    var id = UUID()
    var workoutType: String
    var weight: String
    var reps: String
    var date: Date
}

enum WorkoutCategory: String, CaseIterable, Identifiable {
    case bodyweight, push, pull, leg, glute, bicep, tricep, abs

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var workouts: [String] {
        switch self {
        case .bodyweight: return BodyweightWorkout.allCases.map(\.rawValue)
        case .push: return PushWorkout.allCases.map(\.rawValue)
        case .pull: return PullWorkout.allCases.map(\.rawValue)
        case .leg: return LegWorkout.allCases.map(\.rawValue)
        case .glute: return GluteWorkout.allCases.map(\.rawValue)
        case .bicep: return BicepWorkout.allCases.map(\.rawValue)
        case .tricep: return TricepWorkout.allCases.map(\.rawValue)
        case .abs: return AbsWorkout.allCases.map(\.rawValue)
        }
    }

    // Categories where weight is typically not entered
    var usesWeight: Bool {
        switch self {
        case .bodyweight, .abs: return false
        default: return true
        }
    }
}

struct ImportView: View {
    @EnvironmentObject var workoutData: WorkoutData

    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue

    var weightUnit: String {
        UnitSystem(rawValue: unitSystemRaw) == .imperial ? "lbs" : "kg"
    }

    @State private var entries: [WorkoutEntry] = []

    // One selection per category
    @State private var selections: [WorkoutCategory: String] = [:]
    @State private var weights: [WorkoutCategory: String] = [:]
    @State private var reps: [WorkoutCategory: String] = [:]

    // UI feedback
    @State private var showSavedToast = false

    var body: some View {
        NavigationView {
            List {
                Section() {
                    ForEach(WorkoutCategory.allCases) { category in
                        NavigationLink(destination: CategoryDetailView(
                            category: category,
                            unitSystemRaw: $unitSystemRaw,
                            selections: $selections,
                            weights: $weights,
                            reps: $reps,
                            entries: $entries,
                            save: { saveEntry(for: category) },
                            increment: { dict, step in self.increment(&dict, for: category, by: step) },
                            decrement: { dict, step in self.decrement(&dict, for: category, by: step) },
                            weightUnitProvider: { self.weightUnit },
                            showSavedToast: $showSavedToast
                        )) {
                            HStack(spacing: 12) {
                                Image(systemName: icon(for: category))
                                    .foregroundStyle(Color.accentColor)
                                VStack(alignment: .leading) {
                                    Text(category.title)
                                    Text("Tap to log")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Import Workout")
            .onAppear {
                for category in WorkoutCategory.allCases {
                    if selections[category] == nil {
                        selections[category] = category.workouts.first ?? ""
                    }
                }
                loadEntries()
            }
        }
    }

    private func icon(for category: WorkoutCategory) -> String {
        switch category {
        case .bodyweight: return "figure.walk"
        case .push: return "arrow.up.forward.circle"
        case .pull: return "arrow.down.backward.circle"
        case .leg: return "figure.run"
        case .glute: return "figure.strengthtraining.traditional"
        case .bicep: return "dumbbell"
        case .tricep: return "bolt.circle"
        case .abs: return "figure.core.training"
        }
    }

    struct CategoryDetailView: View {
        let category: WorkoutCategory
        @Binding var unitSystemRaw: String
        @Binding var selections: [WorkoutCategory: String]
        @Binding var weights: [WorkoutCategory: String]
        @Binding var reps: [WorkoutCategory: String]
        @Binding var entries: [WorkoutEntry]

        let save: () -> Void
        let increment: (inout [WorkoutCategory: String], Double) -> Void
        let decrement: (inout [WorkoutCategory: String], Double) -> Void
        let weightUnitProvider: () -> String
        @Binding var showSavedToast: Bool

        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    card
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(category.title)
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .top) {
                if showSavedToast { savedToast }
            }
        }

        private var weightUnit: String { weightUnitProvider() }

        private var selectionBinding: Binding<String> {
            Binding(
                get: { selections[category] ?? category.workouts.first ?? "" },
                set: { selections[category] = $0 }
            )
        }
        private var weightBinding: Binding<String> {
            Binding(
                get: { weights[category] ?? "" },
                set: { weights[category] = $0 }
            )
        }
        private var repsBinding: Binding<String> {
            Binding(
                get: { reps[category] ?? "" },
                set: { reps[category] = $0 }
            )
        }

        @ViewBuilder private var card: some View {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Workout", selection: selectionBinding) {
                    ForEach(category.workouts, id: \.self) { workout in
                        Text(workout).tag(workout)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                if category.usesWeight {
                    HStack(spacing: 12) {
                        Image(systemName: "scalemass")
                            .foregroundStyle(.secondary)
                        TextField("Weight (\(weightUnit))", text: weightBinding)
                            .keyboardType(.decimalPad)
                        Spacer()
                        Stepper("", onIncrement: {
                            increment(&weights, UnitSystem(rawValue: unitSystemRaw) == .imperial ? 5 : 2.5)
                        }, onDecrement: {
                            decrement(&weights, UnitSystem(rawValue: unitSystemRaw) == .imperial ? 5 : 2.5)
                        })
                        .labelsHidden()
                    }
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                HStack(spacing: 12) {
                    Image(systemName: "number")
                        .foregroundStyle(.secondary)
                    TextField("Reps", text: repsBinding)
                        .keyboardType(.numberPad)
                    Spacer()
                    Stepper("", onIncrement: {
                        increment(&reps, 1)
                    }, onDecrement: {
                        decrement(&reps, 1)
                    })
                    .labelsHidden()
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Button(action: save) {
                    HStack {
                        Image(systemName: "tray.and.arrow.down.fill")
                        Text("Save \(category.title)").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }

        private var savedToast: some View {
            Text("Saved ✔︎")
                .font(.subheadline).bold()
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.spring()) { showSavedToast = false }
                    }
                }
        }
    }

    // MARK: - Save / Storage
    func saveEntry(for category: WorkoutCategory) {
        // Validation adapted to categories without weight
        if category.usesWeight {
            guard let weight = weights[category], !weight.isEmpty else {
                feedbackError()
                print("⛔️ Missing values for weight")
                return
            }
        }

        guard let rep = reps[category], !rep.isEmpty else {
            feedbackError()
            print("⛔️ Missing values for rep")
            return
        }

        guard let workout = selections[category], !workout.isEmpty else {
            feedbackError()
            print("⛔️ Missing values for workout")
            return
        }

        let weightString: String = {
            if category.usesWeight { return weights[category] ?? "" }
            else { return "" }
        }()

        let newEntry = WorkoutEntry(
            workoutType: workout,
            weight: weightString,
            reps: rep,
            date: Date()
        )
        workoutData.add(entry: newEntry)

        entries.append(newEntry)
        saveEntriesToStorage()

        // Clear inputs for quick next set
        DispatchQueue.main.async {
            if category.usesWeight { weights[category] = "" }
            reps[category] = ""
        }

        feedbackSuccess()
    }

    func saveEntriesToStorage() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "workout_entries")
            print("✅ Workout entries saved. Count: \(entries.count)")
        } else {
            print("❌ Failed to encode entries.")
        }
    }

    func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "workout_entries"),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            entries = decoded
        }
    }

    func binding(for dict: Binding<[WorkoutCategory: String]>, key: WorkoutCategory, defaultValue: String = "") -> Binding<String> {
        return Binding<String>(
            get: { dict.wrappedValue[key] ?? defaultValue },
            set: { dict.wrappedValue[key] = $0 }
        )
    }

    // MARK: - Helpers for steppers
    private func increment(_ dict: inout [WorkoutCategory: String], for key: WorkoutCategory, by step: Double) {
        let current = Double(dict[key] ?? "") ?? 0
        let next = current + step
        dict[key] = formattedNumber(next)
    }

    private func decrement(_ dict: inout [WorkoutCategory: String], for key: WorkoutCategory, by step: Double) {
        let current = Double(dict[key] ?? "") ?? 0
        let next = max(0, current - step)
        dict[key] = formattedNumber(next)
    }

    private func formattedNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }

    // MARK: - Haptics & feedback
    private func feedbackSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            showSavedToast = true
        }
    }

    private func feedbackError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

#Preview {
    ImportView()
}

