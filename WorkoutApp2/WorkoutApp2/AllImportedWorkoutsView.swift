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
        case .bodyweight:     return "figure.cross.training"
        case .push:           return "arrow.up.forward.circle.fill"
        case .pull:           return "arrow.down.backward.circle.fill"
        case .leg:            return "figure.strengthtraining.functional"
        case .glute:          return "figure.strengthtraining.traditional"
        case .bicep:          return "dumbbell.fill"
        case .tricep:         return "bolt.circle.fill"
        case .abs:            return "figure.core.training"
        case .distanceCardio: return "figure.run"
        case .timeCardio:     return "timer"
        case .sports:         return "sportscourt.fill"
        case .stretch:        return "figure.yoga"
        }
    }
}

struct AllImportedWorkoutsView: View {
    var scrollToID: UUID?
    @EnvironmentObject var workoutData: WorkoutData

    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue

    private var weightUnit: String {
        UnitSystem(rawValue: unitSystemRaw) == .imperial ? "lbs" : "kg"
    }

    var body: some View {
        ZStack {
            // Same gradient as TimeViewBig
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.9),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {

                        if workoutData.entries.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "dumbbell")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.white.opacity(0.5))

                                Text("No Workouts Imported Yet")
                                    .font(.headline.bold())
                                    .foregroundStyle(.white)

                                Text("Your imported workouts will appear here.")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            .padding(.top, 100)

                        } else {
                            ForEach(workoutData.entries.reversed()) { entry in
                                let iconName = workoutCategoryLookup[entry.workoutType]?.icon ?? "dumbbell.fill"
                                WorkoutEntryCard(entry: entry, iconName: iconName, weightUnit: weightUnit)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .onAppear {
                    if let id = scrollToID {
                        proxy.scrollTo(id, anchor: .top)
                    }
                }
            }
        }
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

    let workoutCategoryLookup: [String: WorkoutCategory] = {
        var lookup: [String: WorkoutCategory] = [:]
        for category in WorkoutCategory.allCases {
            for workout in category.workouts() {
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
        NavigationLink(destination: EditWorkoutView(entry: entry)) {
            VStack(alignment: .leading, spacing: 12) {

                // Header
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 38, height: 38)
                        Image(systemName: iconName)
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }

                    Text(entry.workoutType)
                        .font(.headline.bold())
                        .foregroundStyle(.white)

                    Spacer()

                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                }

                // Stats row
                if !entry.weight.isEmpty || !entry.reps.isEmpty || !entry.sets.isEmpty {
                    HStack(spacing: 10) {
                        if !entry.weight.isEmpty {
                            statPill(text: "\(entry.weight) \(weightUnit)", icon: "scalemass.fill")
                        }
                        if !entry.reps.isEmpty {
                            statPill(text: "\(entry.reps) reps", icon: "number")
                        }
                        if !entry.sets.isEmpty {
                            statPill(text: "\(entry.sets) sets", icon: "square.grid.2x2.fill")
                        }
                        Spacer()
                    }
                }

                // Note
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                        .lineLimit(2)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(.white.opacity(0.10))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
            )
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }

    private func statPill(text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption.bold())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.white.opacity(0.15))
        .clipShape(Capsule())
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
            date: Date(),
            note: ""
        ),

        WorkoutEntry(
            workoutType: "Squat",
            weight: "225",
            reps: "5",
            sets: "5",
            date: Date().addingTimeInterval(-86400),
            note: "hey"
        ),

        WorkoutEntry(
            workoutType: "Running",
            weight: "3.2",
            reps: "",
            sets: "25",
            date: Date().addingTimeInterval(-172800),
            note: ""
        ),

        WorkoutEntry(
            workoutType: "Pull Ups",
            weight: "",
            reps: "12",
            sets: "3",
            date: Date().addingTimeInterval(-250000),
            note: "running"
        )
    ]

    return data
}

