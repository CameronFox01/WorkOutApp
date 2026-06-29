//
//  DailyPlannedWorkouts.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/28/26.
//

import Foundation
import SwiftUI

struct DailyPlannedWorkouts: View {
    @EnvironmentObject var gradientSettings: GradientSettings
    @EnvironmentObject var workoutData: WorkoutData

    private var calendar: Calendar { .current }

    // Changed from computed to @State so they can refresh
    @State private var todayWorkouts: [String] = []
    @State private var dayTitle: String = ""

    private var todayWeekday: String {
        let weekdayNumber = calendar.component(.weekday, from: Date())
        switch weekdayNumber {
        case 1: return "sun"
        case 2: return "mon"
        case 3: return "tue"
        case 4: return "wed"
        case 5: return "thu"
        case 6: return "fri"
        default: return "sat"
        }
    }

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2")
    }

    // This is the function that was missing
    private func loadTodayWorkouts() {
        let key = "planned_workouts_items_\(todayWeekday)"
        let result = sharedDefaults?.stringArray(forKey: key) ?? []
        print("🗓 Loading workouts for \(todayWeekday), key: \(key), found: \(result)")
        todayWorkouts = result
        dayTitle = sharedDefaults?.string(forKey: "planned_workouts_title_\(todayWeekday)") ?? ""
    }

    private func isCompleted(_ workout: String) -> Bool {
        let today = calendar.startOfDay(for: Date())
        return workoutData.entries.contains {
            $0.workoutType == workout &&
            calendar.startOfDay(for: $0.date) == today
        }
    }

    private var completedCount: Int {
        todayWorkouts.filter { isCompleted($0) }.count
    }

    private var allDone: Bool { completedCount == todayWorkouts.count }

    var body: some View {
        Group {
            if !todayWorkouts.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - Colored Header Banner
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Today's Plan")
                                    .font(.title.bold())
                                    .foregroundStyle(.white)
                                
                                if !dayTitle.isEmpty {
                                    Text(dayTitle)
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.75))
                                }
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 2) {
                                Text("\(completedCount)/\(todayWorkouts.count)")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                Text("done")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.white.opacity(0.25))
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(.white)
                                    .frame(
                                        width: todayWorkouts.isEmpty ? 0 :
                                            geo.size.width * CGFloat(completedCount) / CGFloat(todayWorkouts.count),
                                        height: 6
                                    )
                                    .animation(.spring(response: 0.4), value: completedCount)
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: gradientSettings.selectedPreset.cardColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(UnevenRoundedRectangle(
                        topLeadingRadius: 28,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 28
                    ))
                    
                    // MARK: - Workout Rows
                    VStack(spacing: 10) {
                        ForEach(todayWorkouts, id: \.self) { workout in
                            PlannedWorkoutRow(
                                workout: workout,
                                category: categoryForWorkout(workout),
                                isCompleted: isCompleted(workout)
                            )
                        }
                    }
                    .padding(16)
                    .background(.white.opacity(0.15))
                    .clipShape(UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 28,
                        bottomTrailingRadius: 28,
                        topTrailingRadius: 0
                    ))
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.green)

                    Text("Rest Day")
                        .font(.title3.bold())

                    Text("Recovery is part of progress.\nTake today to recharge.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(.white.opacity(0.15))
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 28,
                    bottomLeadingRadius: 28,
                    bottomTrailingRadius: 28,
                    topTrailingRadius: 28
                ))
            }
        }
        .onAppear {
            loadTodayWorkouts()
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.willEnterForegroundNotification)
        ) { _ in
            loadTodayWorkouts()
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UserDefaults.didChangeNotification)
        ) { _ in
            loadTodayWorkouts()
        }
    }

    private func categoryForWorkout(_ workout: String) -> WorkoutCategory {
        for category in WorkoutCategory.allCases {
            if category.workouts().contains(workout) { return category }
        }
        return .bodyweight
    }
}

// MARK: - Individual workout row with navigation

struct PlannedWorkoutRow: View {
    let workout: String
    let category: WorkoutCategory
    let isCompleted: Bool

    @EnvironmentObject var workoutData: WorkoutData
    @EnvironmentObject var gradientSettings: GradientSettings

    @State private var selections: [WorkoutCategory: String] = [:]
    @State private var weights: [WorkoutCategory: String] = [:]
    @State private var reps: [WorkoutCategory: String] = [:]
    @State private var sets: [WorkoutCategory: String] = [:]
    @State private var distances: [WorkoutCategory: String] = [:]
    @State private var times: [WorkoutCategory: String] = [:]
    @State private var notes: [WorkoutCategory: String] = [:]
    @State private var entriesLocal: [WorkoutEntry] = []
    @State private var showSavedToast: Bool = false
    @State private var unitSystemRawLocal: String = UnitSystem.metric.rawValue
    private var GoToHomeScreenWhenSaved: Bool { false }
    private var weightUnit: String { unitSystemRawLocal }

    var body: some View {
        NavigationLink {
            ImportView.CategoryDetailView(
                category: category,
                unitSystemRaw: $unitSystemRawLocal,
                selections: $selections,
                weights: $weights,
                reps: $reps,
                sets: $sets,
                distances: $distances,
                times: $times,
                entries: $entriesLocal,
                notes: $notes,
                save: { saveEntry() },
                increment: { dict, step in increment(&dict, for: category, by: Int(step)) },
                decrement: { dict, step in decrement(&dict, for: category, by: Int(step)) },
                weightUnitProvider: { weightUnit },
                goHomeAfterSave: GoToHomeScreenWhenSaved,
                showSavedToast: $showSavedToast,
                resetParent: { resetFields() }
            )
            .onAppear {
                selections[category] = workout
                if let saved = loadLastWorkoutValues(for: workout) {
                    if !saved["weight", default: ""].isEmpty { weights[category] = saved["weight"] }
                    if !saved["reps", default: ""].isEmpty { reps[category] = saved["reps"] }
                    if !saved["sets", default: ""].isEmpty { sets[category] = saved["sets"] }
                    if !saved["distance", default: ""].isEmpty { distances[category] = saved["distance"] }
                    if !saved["time", default: ""].isEmpty { times[category] = saved["time"] }
                }
            }
        } label: {
            HStack(spacing: 12) {
                // Completion indicator
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : Color.white.opacity(0.15))
                        .frame(width: 28, height: 28)

                    Image(systemName: isCompleted ? "checkmark" : category.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.black)
                }

                Text(workout)
                    .font(.title3.bold())
                    .foregroundStyle(
                        isCompleted
                        ? gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.5)
                        : .black
                    )
                    .strikethrough(isCompleted)

                Spacer()

                if !isCompleted {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.black)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isCompleted ? Color.green.opacity(0.15) : Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .onAppear {
            selections[category] = workout
        }
    }

    private func saveEntry() {
        WorkoutApp2.saveEntry(
            for: category,
            selections: selections,
            weights: weights,
            reps: reps,
            sets: sets,
            distances: distances,
            times: times,
            notes: notes,
            workoutData: workoutData,
            onSuccess: {
                showSavedToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showSavedToast = false
                }
            },
            onError: { }
        )
    }

    private func resetFields() {
        let current = selections[category]
        weights.removeAll(); reps.removeAll(); sets.removeAll()
        distances.removeAll(); times.removeAll(); notes.removeAll()
        selections[category] = current ?? workout
    }

    private func increment(_ dict: inout [WorkoutCategory: String], for category: WorkoutCategory, by step: Int) {
        let current = Int(dict[category] ?? "0") ?? 0
        dict[category] = String(current + step)
    }

    private func decrement(_ dict: inout [WorkoutCategory: String], for category: WorkoutCategory, by step: Int) {
        let current = Int(dict[category] ?? "0") ?? 0
        dict[category] = String(max(0, current - step))
    }
}

struct DailyPlannedWorkoutsCard: View {
    @State private var showSchedule = false

    var body: some View {
        Button {
            showSchedule = true
        } label: {
            DailyPlannedWorkouts()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSchedule) {
            PlannedWorkoutsView(comingFromCard: true)
                   .environmentObject(GradientSettings())
        }
    }
}

#Preview {
    let today: String = {
        let weekdayNumber = Calendar.current.component(.weekday, from: Date())
        switch weekdayNumber {
        case 1: return "sun"
        case 2: return "mon"
        case 3: return "tue"
        case 4: return "wed"
        case 5: return "thu"
        case 6: return "fri"
        default: return "sat"
        }
    }()

    // Seed into both suites so preview can pick it up
    UserDefaults.standard.set(
        ["Bench Press", "Arnold Press", "Brisk Walking"],
        forKey: "planned_workouts_items_\(today)"
    )
    UserDefaults.standard.set("Push Day", forKey: "planned_workouts_title_\(today)")
    UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2")?.set(
        ["Bench Press", "Arnold Press", "Brisk Walking"],
        forKey: "planned_workouts_items_\(today)"
    )
    UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2")?.set(
        "Push Day",
        forKey: "planned_workouts_title_\(today)"
    )

    return ZStack {
        LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

        DailyPlannedWorkouts()
            .padding()
    }
    .environmentObject(GradientSettings())
    .environmentObject(WorkoutData())
}
