//
//  saveEntry.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/1/26.
//

import Foundation

// MARK: - Save / Storage
import Foundation

func saveEntry(
    for category: WorkoutCategory,
    selections: [WorkoutCategory: String],
    weights: [WorkoutCategory: String],
    reps: [WorkoutCategory: String],
    sets: [WorkoutCategory: String],
    distances: [WorkoutCategory: String],
    times: [WorkoutCategory: String],
    notes: [WorkoutCategory: String],
    workoutData: WorkoutData,
    onSuccess: () -> Void,
    onError: () -> Void
) {
    if category.usesWeight {
        guard let weight = weights[category], !weight.isEmpty else { onError(); return }
    }

    if category == .distanceCardio {
        guard let distance = distances[category], !distance.isEmpty else { onError(); return }
        guard let time = times[category], !time.isEmpty else { onError(); return }
    }

    let rep = reps[category] ?? ""
    if category != .distanceCardio && rep.isEmpty { onError(); return }

    guard let workout = selections[category], !workout.isEmpty else { onError(); return }

    let setsVal: String = category == .distanceCardio ? (times[category] ?? "") : (sets[category] ?? "")
    let weightString: String = {
        if category == .distanceCardio { return distances[category] ?? "" }
        if category.usesWeight { return weights[category] ?? "" }
        return ""
    }()

    let newEntry = WorkoutEntry(
        workoutType: workout,
        weight: weightString,
        reps: rep,
        sets: setsVal,
        date: Date(),
        note: notes[category] ?? ""
    )

    workoutData.add(entry: newEntry)

    if let data = UserDefaults.standard.data(forKey: "workout_entries"),
       var existing = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
        existing.append(newEntry)
        if let encoded = try? JSONEncoder().encode(existing) {
            UserDefaults.standard.set(encoded, forKey: "workout_entries")
        }
    }

    onSuccess()
}
