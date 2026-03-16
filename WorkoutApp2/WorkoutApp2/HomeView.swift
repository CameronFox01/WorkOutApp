//
//  HomeView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI
import HealthKit

struct HomeView: View {
    @EnvironmentObject var Hmanager: HealthManager
    @EnvironmentObject var workoutData: WorkoutData
    
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userTargetWeight") private var targetWeight: String = ""
    
    let healthStore = HKHealthStore()
    
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
                    //Section to get steps and distance
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {

                        VStack(alignment: .leading) {
                            Text("Steps Today")
                                .font(.headline)

                            Text("\(Hmanager.steps)")
                                .font(.title2)
                                .bold()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                        VStack(alignment: .leading) {
                            Text("Distance")
                                .font(.headline)
                            Text(formattedDistance)  // ✅ Replace Hmanager.distance with this
                                .font(.title2)
                                .bold()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    //Divider().padding(.vertical)

                    //Section for Pasted Worked Outs
                    Text("Recent Workouts")
                        .font(.title2)
                        .bold()
                        .padding(.leading)
                    //Creating the boxs for the workouts to be clicked on and carry you to more info on that workout
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {
                        ForEach(firstEntryPerWorkoutType(from: workoutData.entries)) { entry in
                            NavigationLink(
                                destination: WorkoutChartView(
                                    workoutName: entry.workoutType,
                                    entries: workoutData.entries
                                )
                            ) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.workoutType)
                                        .font(.headline)

                                    Text("\(entry.reps) reps at \(entry.weight) \(weightUnit)")
                                        .foregroundColor(.gray)

                                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.subheadline)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
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
            .onAppear(){
                Hmanager.fetchSteps()
                Hmanager.fetchDistance()
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
    
    func firstEntryPerWorkoutType(from entries: [WorkoutEntry]) -> [WorkoutEntry] {
        var seen = Set<String>()

        return entries.filter { entry in
            if seen.contains(entry.workoutType) {
                return false
            } else {
                seen.insert(entry.workoutType)
                return true
            }
        }
    }
    
    // Section to formate the distance pulled from the health app.
    var formattedDistance: String {
        if unitSystem == .metric {
            let km = Hmanager.distance / 1000
            return String(format: "%.2f km", km)
        } else {
            let miles = Hmanager.distance / 1609.34
            return String(format: "%.2f mi", miles)
        }
    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(WorkoutData())
            .environmentObject(HealthManager())
    }
}

