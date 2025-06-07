//
//  WorkoutObserver.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/7/25.
//
import SwiftUI

class WorkoutData: ObservableObject {
    @Published var entries: [WorkoutEntry] = []

    init() {
        load()
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "workout_entries"),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            entries = decoded
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "workout_entries")
        }
    }

    func add(entry: WorkoutEntry) {
        entries.append(entry)
        save()
    }
}
