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
    }
    
    private func checkMilestones() {
        let notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") == nil
        ? true
        : UserDefaults.standard.bool(forKey: "notificationsEnabled")
    
    let milestonesEnabled = UserDefaults.standard.object(forKey: "milestonesReminder") == nil
        ? true
        : UserDefaults.standard.bool(forKey: "milestonesReminder")
        
        print("🔔 checkMilestones called — count: \(entries.count), notif: \(notificationsEnabled), milestones: \(milestonesEnabled)")
        
        guard notificationsEnabled && milestonesEnabled else {
            print("⛔️ Guard failed — notificationsEnabled: \(notificationsEnabled), milestonesEnabled: \(milestonesEnabled)")
            return
        }

        let count = entries.count
        let milestones = [1, 5, 10, 25, 50, 100, 250, 500]

        let completedData = UserDefaults.standard.data(forKey: "completedMilestonesData") ?? Data()
        var completed = (try? JSONDecoder().decode(Set<String>.self, from: completedData)) ?? []
        
        print("✅ Already completed milestones: \(completed)")

        for milestone in milestones {
            let key = "workout_\(milestone)"
            print("🔍 Checking milestone \(milestone) — count: \(count), already done: \(completed.contains(key))")
            if count >= milestone && !completed.contains(key) {
                completed.insert(key)
                if let encoded = try? JSONEncoder().encode(completed) {
                    UserDefaults.standard.set(encoded, forKey: "completedMilestonesData")
                }
                NotificationHandler.shared.sendInstantNotification(
                    title: "Milestone Reached!",
                    body: "You've logged \(milestone) workouts!"
                )
                print("🎉 Milestone \(milestone) reached. Sending notification.")
            }
        }
    }
}
