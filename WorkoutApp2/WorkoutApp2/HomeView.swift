//
//  HomeView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI
import HealthKit

struct HomeView: View {
    @EnvironmentObject var workoutData: WorkoutData
    
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userTargetWeight") private var targetWeight: String = ""
    
    let healthStore = HKHealthStore()
    @State private var steps: Double = 0
    @State private var distanceMeters: Double = 0
    
    var distanceMiles: Double {
        distanceMeters / 1609.34
    }
    
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

                            Text("\(Int(steps))")
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

                            Text("\(distanceMiles, specifier: "%.2f") mi")
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
           // .onAppear {
               // Task{
                 //   await loadHealthData()
                //}
            //}
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
    
    //Functions to get Health Data from iPhone
    func requestHealthAccess() {
        let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

        let readTypes: Set = [steps, distance]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if success {
                print("Health access granted")
            }
        }
    }
    //Function to get Step Count for the Day
    func fetchStepsToday(completion: @escaping (Double) -> Void) {

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in

            guard let sum = result?.sumQuantity() else {
                completion(0)
                return
            }

            let steps = sum.doubleValue(for: HKUnit.count())
            completion(steps)
        }

        healthStore.execute(query)
    }
    
    //Function to get Walking Distance from iPhone
    func fetchDistanceToday(completion: @escaping (Double) -> Void) {

        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

        let startOfDay = Calendar.current.startOfDay(for: Date())

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: distanceType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in

            guard let sum = result?.sumQuantity() else {
                completion(0)
                return
            }

            let meters = sum.doubleValue(for: HKUnit.meter())
            completion(meters)
        }

        healthStore.execute(query)
    }
    
    func loadHealthData() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

        let readTypes: Set = [stepType, distanceType]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if success {
                fetchStepsToday { value in
                    DispatchQueue.main.async {
                        steps = value
                    }
                }

                fetchDistanceToday { value in
                    DispatchQueue.main.async {
                        distanceMeters = value
                    }
                }
            } else if let error = error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            }
        }
    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(WorkoutData())
    }
}
