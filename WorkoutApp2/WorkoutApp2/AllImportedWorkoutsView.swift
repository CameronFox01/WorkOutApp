//
//  AllImportedWorkoutsView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/22/26.
//

import SwiftUI

enum ImageNames: String, CaseIterable {
    case bodyweight
    case push
    case pull
    case leg
    case glute
    case bicep
    case tricep
    case abs
    case distanceCardio
    case timeCardio
    case sports
    case stretch

    var icon: String {
        switch self {

        case .bodyweight:
            return "figure.cross.training"

        case .push:
            return "arrow.up.forward.circle.fill"

        case .pull:
            return "arrow.down.backward.circle.fill"

        case .leg:
            return "figure.strengthtraining.functional"

        case .glute:
            return "figure.strengthtraining.traditional"

        case .bicep:
            return "dumbbell.fill"

        case .tricep:
            return "bolt.circle.fill"

        case .abs:
            return "figure.core.training"

        case .distanceCardio:
            return "figure.run"

        case .timeCardio:
            return "timer"

        case .sports:
            return "sportscourt.fill"

        case .stretch:
            return "figure.yoga"
        }
    }
}

struct AllImportedWorkoutsView: View {
    @EnvironmentObject var workoutData: WorkoutData
    
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    
    private var weightUnit: String {
        UnitSystem(rawValue: unitSystemRaw) == .imperial ? "lbs" : "kg"
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {

                if workoutData.entries.isEmpty {

                    VStack(spacing: 12) {
                        Image(systemName: "dumbbell")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)

                        Text("No Workouts Imported Yet")
                            .font(.headline)

                        Text("Your imported workouts will appear here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 80)

                } else {

                    ForEach(workoutData.entries.reversed()) { entry in
                        let iconName = workoutCategoryLookup[entry.workoutType]?.icon ?? "dumbbell.fill"
                        WorkoutEntryCard(entry: entry, iconName: iconName, weightUnit: weightUnit)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("All Workouts")
                    .font(.largeTitle).bold()
                    .foregroundStyle(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Function to search for the type of workout.
    let workoutCategoryLookup: [String: WorkoutCategory] = {

        var lookup: [String: WorkoutCategory] = [:]

        for category in WorkoutCategory.allCases {

            for workout in category.workouts {

                lookup[workout] = category
            }
        }

        return lookup
    }()
}

private struct WorkoutEntryCard: View {
    let entry: WorkoutEntry
    let iconName: String
    let weightUnit: String

    var body: some View {
        NavigationLink(destination: EditWorkoutView(entry: entry)){
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: iconName)
                        .foregroundStyle(.blue)
                    Text(entry.workoutType)
                        .font(.headline)
                        .foregroundStyle(Color.black)
                    Spacer()
                }
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    if !entry.weight.isEmpty {
                        Label("\(entry.weight) \(weightUnit)", systemImage: "scalemass")
                    }
                    if !entry.reps.isEmpty {
                        Label("\(entry.reps) Reps", systemImage: "number")
                    }
                    if !entry.sets.isEmpty {
                        Label("\(entry.sets) Sets", systemImage: "square.grid.2x2")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(Color.black)
                Divider()
                HStack {
                    Spacer()
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Color(.systemGray))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }
}


#Preview {
    NavigationStack {
        AllImportedWorkoutsView()
            .environmentObject(sampleWorkoutData)
    }
}

// MARK: - Preview Data
private var sampleWorkoutData: WorkoutData {
    let data = WorkoutData()

    data.entries = [
        WorkoutEntry(
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "4",
            date: Date()
        ),

        WorkoutEntry(
            workoutType: "Squat",
            weight: "225",
            reps: "5",
            sets: "5",
            date: Date().addingTimeInterval(-86400)
        ),

        WorkoutEntry(
            workoutType: "Running",
            weight: "3.2",
            reps: "",
            sets: "25",
            date: Date().addingTimeInterval(-172800)
        ),

        WorkoutEntry(
            workoutType: "Pull Ups",
            weight: "",
            reps: "12",
            sets: "3",
            date: Date().addingTimeInterval(-250000)
        )
    ]

    return data
}

