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
    @AppStorage("userAccountFirstSaved") private var accountFirstSaved: Date = .distantPast
    
    let healthStore = HKHealthStore()
    
    @State private var workoutLog: [WorkoutEntry] = {
        if let data = UserDefaults.standard.data(forKey: "workout_entries"),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            return decoded
        }
        return []
    }()
    @State private var isPresentingWeightSheet = false
    @State private var newWeightInput: String = ""
    
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
                        Button { isPresentingWeightSheet = true; newWeightInput = weight } label: {
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
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.primary)
                        }
                    }
                    //Section to get steps and distance
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {

                        NavigationLink(destination: DistanceDetailView(unitSystem: unitSystem)
                                        .environmentObject(Hmanager)) {
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
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading) {
                            Text("Calendar")
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
            .sheet(isPresented: $isPresentingWeightSheet) {
                WeightUpdateSheet(
                    unitSystem: unitSystem,
                    weightUnit: weightUnit,
                    currentWeight: $weight,
                    newWeightInput: $newWeightInput,
                    entries: workoutData.entries,
                    onSave: { valueString in
                        // Update AppStorage so Account and others reflect immediately
                        weight = valueString
                        // Append a new WorkoutEntry of type "Body Weight"
                        let entry = WorkoutEntry(
                            workoutType: "Body Weight",
                            weight: valueString,
                            reps: "",
                            sets: "",
                            date: Date()
                        )
                        workoutData.add(entry: entry)
                    },
                    unitSystemRaw: unitSystemRaw
                )
            }
            .onAppear(){
                Hmanager.fetchSteps()
                Hmanager.fetchDistance()
                // Seed initial Body Weight entry if none exists, using the first time account info was saved
                let hasBodyWeight = workoutData.entries.contains { $0.workoutType == "Body Weight" }
                if !hasBodyWeight, let w = Double(weight), !weight.isEmpty {
                    // If we don't yet have a recorded first-saved date, set it now
                    if accountFirstSaved == .distantPast {
                        accountFirstSaved = Date()
                    }
                    let seed = WorkoutEntry(
                        workoutType: "Body Weight",
                        weight: String(w),
                        reps: "",
                        sets: "",
                        date: accountFirstSaved
                    )
                    workoutData.add(entry: seed)
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

private struct WeightUpdateSheet: View {
    let unitSystem: UnitSystem
    let weightUnit: String
    @Binding var currentWeight: String
    @Binding var newWeightInput: String
    var entries: [WorkoutEntry]
    let onSave: (String) -> Void
    let unitSystemRaw: String

    @Environment(\.dismiss) private var dismiss

    private var bodyWeightEntries: [WorkoutEntry] {
        entries.filter { $0.workoutType == "Body Weight" }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Mini chart using existing WorkoutProgressChart for consistency
                WorkoutProgressChart(
                    workoutName: "Body Weight",
                    entries: entries,
                    unitSystemRaw: unitSystemRaw
                )
                .frame(height: 220)
                .padding(.horizontal)
                .padding(.top)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Enter new weight (") + Text(weightUnit).bold() + Text(")")
                    HStack(spacing: 12) {
                        TextField("e.g. 180", text: $newWeightInput)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Stepper("", onIncrement: {
                            let current = Double(newWeightInput) ?? Double(currentWeight) ?? 0
                            newWeightInput = String(format: "%.1f", current + (unitSystem == .imperial ? 1.0 : 0.5))
                        }, onDecrement: {
                            let current = Double(newWeightInput) ?? Double(currentWeight) ?? 0
                            let next = max(0, current - (unitSystem == .imperial ? 1.0 : 0.5))
                            newWeightInput = String(format: "%.1f", next)
                        })
                        .labelsHidden()
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Update Weight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = newWeightInput.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty, Double(trimmed) != nil else { return }
                        onSave(trimmed)
                        currentWeight = trimmed
                        dismiss()
                    }
                    .disabled(Double(newWeightInput) == nil)
                }
            }
        }
    }
}

private struct DistanceDetailView: View {
    @EnvironmentObject var Hmanager: HealthManager
    let unitSystem: UnitSystem

    var formattedDistance: String {
        if unitSystem == .metric {
            let km = Hmanager.distance / 1000
            return String(format: "%.2f km", km)
        } else {
            let miles = Hmanager.distance / 1609.34
            return String(format: "%.2f mi", miles)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            GroupBox(label: Text("Today")) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Steps")
                            .font(.headline)
                        Text("\(Hmanager.steps)")
                            .font(.title2).bold()
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Distance")
                            .font(.headline)
                        Text(formattedDistance)
                            .font(.title2).bold()
                    }
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Activity")
        .onAppear {
            Hmanager.fetchSteps()
            Hmanager.fetchDistance()
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

