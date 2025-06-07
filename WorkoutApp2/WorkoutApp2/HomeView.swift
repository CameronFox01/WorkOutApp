//
//  HomeView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutData: WorkoutData
    
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userTargetWeight") private var targetWeight: String = ""
    
    @State private var workoutLog: [WorkoutEntry] = {
        if let data = UserDefaults.standard.data(forKey: "workout_entries"),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            return decoded
        }
        return []
    }()
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "workoutLog"),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            print("Loaded workoutLog:")
            for entry in decoded {
                print("\(entry.workoutType) - \(entry.reps) reps - \(entry.weight) weight - \(entry.date)")
            }
        } else {
            print("No workoutLog found in UserDefaults.")
        }
    }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    GroupBox(label: Text("Current Progress")) {
                        VStack {
                            Text("Weight: \(weight) \(weightUnit)")
                            if let difference = weightDifference {
                                Text("Difference to target: \(difference, specifier: "%.1f") \(weightUnit)")
                            } else {
                                Text("Set your target weight to see difference")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    }

                    Divider().padding(.vertical)

                    Text("Recent Workouts")
                        .font(.title2)
                        .bold()
                        .padding(.leading)

                    ForEach(uniqueWorkoutEntries(from: workoutData.entries)) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.workoutType)
                                .font(.headline)
                            Text("\(entry.reps) reps at \(entry.weight) \(weightUnit)")
                                .foregroundColor(.gray)
                            Text("Last done on \(entry.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AccountView()) {
                        Image(systemName: "person.circle")
                            .font(.title)
                    }
                }
            }
        }
    }

    var groupedWorkouts: [WorkoutEntry] {
        uniqueWorkoutEntries(from: workoutData.entries.sorted(by: { $0.date > $1.date }))
    }

    // MARK: - Computed properties

    var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }

    var heightUnit: String {
        unitSystem == .metric ? "cm" : "in"
    }

    var weightUnit: String {
        unitSystem == .metric ? "kg" : "lbs"
    }
    
    var weightDifference: Double? {
            guard let current = Double(weight),
                  let target = Double(targetWeight) else {
                return nil
            }
            return abs(target - current)
        }
    
    func uniqueWorkoutEntries(from all: [WorkoutEntry]) -> [WorkoutEntry] {
            var seen = Set<String>()
            var unique: [WorkoutEntry] = []

            for entry in all {
                if !seen.contains(entry.workoutType) {
                    seen.insert(entry.workoutType)
                    unique.append(entry)
                }
            }
            return unique
        }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(WorkoutData())
    }
}
