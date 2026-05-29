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
        checkMilestones()
        checkGoalAchieved(for: entry) 
    }

    private func checkGoalAchieved(for entry: WorkoutEntry) {
        let notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "notificationsEnabled")
        let goalReminder = UserDefaults.standard.object(forKey: "goalReminder") == nil
        ? true
        : UserDefaults.standard.bool(forKey: "goalReminder")
        
        guard notificationsEnabled && goalReminder else { return }

        let goalKey = "goal_\(entry.workoutType)"
        let completedKey = "goalReached_\(entry.workoutType)"

        // Only fire once per goal
        guard !UserDefaults.standard.bool(forKey: completedKey) else { return }

        guard let goalString = UserDefaults.standard.string(forKey: goalKey),
              let goalValue = Double(goalString),
              goalValue > 0 else { return }

        // Compare against the entry's weight (or reps for bodyweight/cardio)
        let entryValue = Double(entry.weight.isEmpty ? entry.reps : entry.weight) ?? 0

        if entryValue >= goalValue {
            UserDefaults.standard.set(true, forKey: completedKey)
            NotificationHandler.shared.sendInstantNotification(
                title: "Goal Reached!",
                body: "You hit your \(entry.workoutType) goal of \(goalString)!"
            )
            print("Goal reached for \(entry.workoutType)!")
        }
    }
    
    private func checkMilestones() {
        let notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") == nil
        ? true
        : UserDefaults.standard.bool(forKey: "notificationsEnabled")
    
    let milestonesEnabled = UserDefaults.standard.object(forKey: "milestonesReminder") == nil
        ? true
        : UserDefaults.standard.bool(forKey: "milestonesReminder")
        
        guard notificationsEnabled && milestonesEnabled else {
            return
        }

        let count = entries.count
        let milestones = [1, 5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000]

        let completedData = UserDefaults.standard.data(forKey: "completedMilestonesData") ?? Data()
        var completed = (try? JSONDecoder().decode(Set<String>.self, from: completedData)) ?? []

        for milestone in milestones {
            let key = "workout_\(milestone)"
            if count >= milestone && !completed.contains(key) {
                completed.insert(key)
                if let encoded = try? JSONEncoder().encode(completed) {
                    UserDefaults.standard.set(encoded, forKey: "completedMilestonesData")
                }
                NotificationHandler.shared.sendInstantNotification(
                    title: "Milestone Reached!",
                    body: "You've logged \(milestone) workouts!"
                )
            }
        }
    }
}
