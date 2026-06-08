//
//  ContentView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var workoutData: WorkoutData
    @EnvironmentObject var router: AppRouter

    //Section for weight Screen from notification
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userWeight") private var weight: String = ""
    @State private var newWeightInput: String = ""


    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    
    private let sharedDefaults = UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2")!

    @State private var entries: [WorkoutEntry] = []
    @State private var achievedGoals: [AchievedGoal] = []
    @State private var achievedMilestones: [Milestone] = []
    @State private var selectedWorkout: String = ""

    var body: some View {
        ZStack{
            
            if !hasCompletedSetup {
                StartUpView()
            } else {
                TabView(selection: $router.selectedTab) {

                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(AppRouter.Tab.home)
                    
                    ImportView()
                        .tabItem {
                            Label("Import", systemImage: "dumbbell")
                        }
                        .tag(AppRouter.Tab.workout)
                    
                    PhotoView()
                        .tabItem {
                            Label("Camera", systemImage: "camera")
                        }
                        .tag(AppRouter.Tab.settings)
                    
                    NavigationStack {
                        GoalView()
                    }
                    .tabItem {
                        Label("Goal", systemImage: "trophy")
                    }
                    .tag(AppRouter.Tab.progress)
                }
                if let screen = router.activeScreen {
                   switch screen {
                   case .timer:
                       TimerView()

                   case .workoutDetail:
                       WorkoutCalendarView(entries: entries, comingFromWidget: true)
                           .onAppear {
                               entries = workoutData.entries
                           }
                           .onChange(of: workoutData.entries.count) { _, _ in
                                  entries = workoutData.entries 
                              }
                   
                   case .weight: // This comes from one of the notifications
                       WeightUpdateSheet(
                           unitSystem: unitSystem,
                           weightUnit: weightUnit,
                           comingFromWidget: true,
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
                                   date: Date(),
                                   note: ""
                               )
                               workoutData.add(entry: entry)
                               router.activeScreen = nil
                           },
                           unitSystemRaw: unitSystemRaw
                       )
                       .onAppear {
                           newWeightInput = weight
                       }
                   
                   case .achievedGoals:
                       NavigationStack {
                           AchievedGoalsView(
                            achievedGoals: loadAchievedGoalsForOverlay(),
                            comingfromWidget: true
                           )
                       }
                       .environmentObject(workoutData)
                       
                   case .achievedMileStones:
                        NavigationStack {
                           MilestonesView(
                            milestones: achievedMilestones,
                            comingfromWidget: true
                           )
                       }
                       .environmentObject(workoutData)
                       .onAppear {
                           loadAchievedMilestones()  // ✅ load when the view appears
                       }
                       
                   case .goalEdit:
                       GoalView()
                   }
                    
               }
            }
        }
        .onOpenURL { url in  // ✅ add here
            if url.absoluteString == "workoutapp://calendar" {
                router.activeScreen = .workoutDetail
            }
        }
    }
    
    private func loadAchievedGoalsForOverlay() -> [AchievedGoal] {
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

        return allWorkouts.compactMap { workout in
            guard let goal = UserDefaults.standard.string(forKey: "goal_\(workout)"), !goal.isEmpty,
                  UserDefaults.standard.bool(forKey: "goalReached_\(workout)") else { return nil }
            return AchievedGoal(workout: workout, target: goal, dateReached: nil)
        }.sorted { $0.workout.localizedCaseInsensitiveCompare($1.workout) == .orderedAscending }
    }
    
    var weightUnit: String {
        unitSystem == .metric ? "kg" : "lbs"
    }
    
    var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }

    private var workoutsList: [String] {
        Array(Set(entries.map { $0.workoutType })).sorted()
    }
    
    private func loadAchievedMilestones() {
        let completedData = UserDefaults.standard.data(forKey: "completedMilestonesData") ?? Data()
        let completed = (try? JSONDecoder().decode(Set<String>.self, from: completedData)) ?? []

        var results: [Milestone] = []

        for key in completed {
            if key.hasPrefix("workout_") {
                let number = key.replacingOccurrences(of: "workout_", with: "")
                results.append(
                    Milestone(
                        title: "\(number) Workouts",
                        description: "Completed \(number) workouts",
                        icon: "dumbbell.fill",
                        dateReached: nil
                    )
                )
            } else if key.hasPrefix("days_") {
                let number = key.replacingOccurrences(of: "days_", with: "")
                results.append(
                    Milestone(
                        title: "\(number) Workout Days",
                        description: "Worked out on \(number) different days",
                        icon: "calendar",
                        dateReached: nil
                    )
                )
            }
        }

        achievedMilestones = results.sorted { $0.title < $1.title }
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "workout_entries"),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {

            entries = decoded

            if selectedWorkout.isEmpty,
               let first = workoutsList.first {

                selectedWorkout = first

            } else if !workoutsList.contains(selectedWorkout) {

                selectedWorkout = workoutsList.first ?? ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WorkoutData())
            .environmentObject(HealthManager())
            .environmentObject(AppRouter())
    }
}
