//
//  WorkoutObserver.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/7/25.
//
import SwiftUI
import WidgetKit

struct Milestone: Identifiable {
    let id = UUID()

    let title: String
    let description: String

    let icon: String

    let dateReached: Date?
}

class WorkoutData: ObservableObject {
    @Published var entries: [WorkoutEntry] = []
    @Published var achievedMilestones: [Milestone] = []
    
    private let sharedDefaults = UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2") // For thr Widget

    init() {
        load()
    }

    func load() {
        if let data = sharedDefaults?.data(forKey: "workout_entries"),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            entries = decoded
        }
        loadMilestones()
        loadAchievedGoals()
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(entries) {
            sharedDefaults?.set(encoded, forKey: "workout_entries")
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    func loadMilestones() {
        let completed =
        (try? JSONDecoder().decode(
            Set<String>.self,
            from: UserDefaults.standard.data(
                forKey: "completedMilestonesData"
            ) ?? Data()
        )) ?? []

        var results: [Milestone] = []

        for item in completed {

            if item.starts(with: "workout_") {
                let number = item.replacingOccurrences(of: "workout_", with: "")
                results.append(
                    Milestone(
                        title: "\(number) Workouts",
                        description: "Completed \(number) workouts",
                        icon: "dumbbell.fill",          // ✅ added missing icon
                        dateReached: nil     // ✅ fixed label (was achievedDate:)
                    )
                )
            }

            if item.starts(with: "days_") {
                let number = item.replacingOccurrences(of: "days_", with: "")
                results.append(
                    Milestone(
                        title: "\(number) Workout Days",
                        description: "Worked out on \(number) different days",
                        icon: "calendar",          // ✅ added missing icon
                        dateReached: nil     // ✅ fixed label (was achievedDate:)
                    )
                )
            }
        }

        achievedMilestones = results.sorted { a, b in
            // Group by type first (workout_ before days_)
            let aIsWorkout = a.title.contains("Workouts") && !a.title.contains("Days")
            let bIsWorkout = b.title.contains("Workouts") && !b.title.contains("Days")

            if aIsWorkout != bIsWorkout {
                return aIsWorkout // workout milestones first
            }

            // Then sort numerically within each group
            let numA = Int(a.title.components(separatedBy: " ").first ?? "") ?? 0
            let numB = Int(b.title.components(separatedBy: " ").first ?? "") ?? 0
            return numA < numB
        }
    }
    
    func orderMilestones(_ milestones: [Milestone]) -> [Milestone] {
        return milestones.sorted { a, b in
            let aIsWorkout = a.title.contains("Workouts") && !a.title.contains("Days")
            let bIsWorkout = b.title.contains("Workouts") && !b.title.contains("Days")

            if aIsWorkout != bIsWorkout {
                return aIsWorkout
            }

            let numA = Int(a.title.components(separatedBy: " ").first ?? "") ?? 0
            let numB = Int(b.title.components(separatedBy: " ").first ?? "") ?? 0
            return numA < numB
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

        guard !UserDefaults.standard.bool(forKey: completedKey) else { return }

        guard let goalString = UserDefaults.standard.string(forKey: goalKey),
              let goalValue = Double(goalString),
              goalValue > 0 else { return }

        let entryValue = Double(entry.weight.isEmpty ? entry.reps : entry.weight) ?? 0

        if entryValue >= goalValue {
            UserDefaults.standard.set(true, forKey: completedKey)
            NotificationHandler.shared.sendInstantNotification(
                title: "Goal Reached!",
                body: "You hit your \(entry.workoutType) goal of \(goalString)!",
                identifier: "goalReached_\(entry.workoutType)"
            )
            loadAchievedGoals() 
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

        guard notificationsEnabled && milestonesEnabled else { return }

        let count = entries.count
        let workoutMilestones = [1, 5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000]
        let dayMilestones = [7, 14, 30, 60, 90, 180, 365, 500, 1000]

        let completedData = UserDefaults.standard.data(forKey: "completedMilestonesData") ?? Data()
        var completed = (try? JSONDecoder().decode(Set<String>.self, from: completedData)) ?? []

        // Workout count milestones
        for milestone in workoutMilestones {
            let key = "workout_\(milestone)"
            if count >= milestone && !completed.contains(key) {
                completed.insert(key)
                NotificationHandler.shared.sendInstantNotification(
                    title: "Milestone Reached!",
                    body: "You've logged \(milestone) workouts!",
                    identifier: key
                )
            }
        }

        // Unique days worked out milestones
        let uniqueDays = Set(entries.map {
            Calendar.current.startOfDay(for: $0.date)
        }).count

        for milestone in dayMilestones {
            let key = "days_\(milestone)"
            if uniqueDays >= milestone && !completed.contains(key) {
                completed.insert(key)
                NotificationHandler.shared.sendInstantNotification(
                    title: "Consistency Milestone!",
                    body: "You've worked out on \(milestone) different days!",
                    identifier: key
                )
            }
        }

        if let encoded = try? JSONEncoder().encode(completed) {
            UserDefaults.standard.set(encoded, forKey: "completedMilestonesData")
        }

        loadMilestones()
    }
    
    @Published var achievedGoals: [AchievedGoal] = []

    func loadAchievedGoals() {
        let allWorkouts = BodyweightWorkout.allCases.map(\.rawValue)
            + PushWorkout.allCases.map(\.rawValue)
            + PullWorkout.allCases.map(\.rawValue)
            + LegWorkout.allCases.map(\.rawValue)
            + GluteWorkout.allCases.map(\.rawValue)
            + BicepWorkout.allCases.map(\.rawValue)
            + TricepWorkout.allCases.map(\.rawValue)
            + AbsWorkout.allCases.map(\.rawValue)
            + DistanceCardioWorkout.allCases.map(\.rawValue)
            + TimeCardioWorkout.allCases.map(\.rawValue)
            + SportsWorkout.allCases.map(\.rawValue)
            + StretchRoutine.allCases.map(\.rawValue)

        var results: [AchievedGoal] = []

        for workout in allWorkouts {
            let goalKey = "goal_\(workout)"
            let completedKey = "goalReached_\(workout)"

            guard let goalValue = UserDefaults.standard.string(forKey: goalKey),
                  !goalValue.isEmpty else { continue }

            if UserDefaults.standard.bool(forKey: completedKey) {
                results.append(AchievedGoal(workout: workout, target: goalValue, dateReached: nil))
            }
        }

        achievedGoals = results.sorted {
            $0.workout.localizedCaseInsensitiveCompare($1.workout) == .orderedAscending
        }
    }
}
