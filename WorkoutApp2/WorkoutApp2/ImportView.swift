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

    var body: some View {
        NavigationView {
            Form {
                ForEach(WorkoutCategory.allCases) { category in
                    Section(header: Text(category.rawValue.capitalized + " Workouts")) {
                        Picker("Workout", selection: binding(for: $selections, key: category, defaultValue: category.workouts.first ?? "")) {
                            ForEach(category.workouts, id: \.self) { workout in
                                Text(workout).tag(workout)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 100)

                        TextField("Weight (\(weightUnit))", text: binding(for: $weights, key: category))
                        TextField("Reps", text: binding(for: $reps, key: category))

                        Button("Save Entry") {
                            saveEntry(for: category)
                        }
                    }
                }

                if !entries.isEmpty {
                    Section(header: Text("Previous Entries")) {
                        ForEach(entries) { entry in
                            VStack(alignment: .leading) {
                                Text("\(entry.workoutType): \(entry.weight) \(weightUnit) x \(entry.reps)")
                                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Import Workout")
            .onAppear {
                // Pre-fill selections with first workout for each category if not set
                for category in WorkoutCategory.allCases {
                    if selections[category] == nil {
                        selections[category] = category.workouts.first ?? ""
                    }
                }
                loadEntries()
            }
        }
    }

    func saveEntry(for category: WorkoutCategory) {
        guard let weight = weights[category], !weight.isEmpty else {
            print("⛔️ Missing values for weight")
            return
        }

        guard let rep = reps[category], !rep.isEmpty else {
            print("⛔️ Missing values for rep")
            return
        }
        
        guard let workout = selections[category], !workout.isEmpty else {
            print("⛔️ Missing values for workout")
            return
        }


        let newEntry = WorkoutEntry(
            workoutType: workout,
            weight: weight,
            reps: rep,
            date: Date()
        )
        workoutData.add(entry: newEntry)

        entries.append(newEntry)
        saveEntriesToStorage()

        DispatchQueue.main.async {
            weights[category] = ""
            reps[category] = ""
        }
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

}

#Preview {
    ImportView()
}
