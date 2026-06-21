//
//  ContentView.swift
//  WorkoutApp2
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI
import Charts
import LocalAuthentication
struct ContentView: View {
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var workoutData: WorkoutData
    @EnvironmentObject var router: AppRouter

    //Section for weight Screen from notification
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userWeight") private var weight: String = ""
    @State private var newWeightInput: String = ""
    
    // Section for FaceID
    @State private var isUnlocked = false
    @State private var authFailed = false
    @AppStorage("faceIDEnabled") private var faceIDEnabled: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var backgroundedAt: Date?
    @AppStorage("lockGracePeriodSeconds") private var lockGracePeriodSeconds: Int = 0

    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    
    private let sharedDefaults = UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2")!

    @State private var entries: [WorkoutEntry] = []
    @State private var achievedGoals: [AchievedGoal] = []
    @State private var achievedMilestones: [Milestone] = []
    @State private var selectedWorkout: String = ""

    var body: some View {
        ZStack{
            if isUnlocked{
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
            } else if authFailed {
                VStack(spacing: 20) {
                                Image(systemName: "faceid")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.secondary)

                                Text("Authentication Failed")
                                    .font(.title2.bold())

                                Text("Please try again to access your workouts.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)

                                Button("Try Again") {
                                    authFailed = false
                                    authenticator()
                                }
                                .buttonStyle(.borderedProminent)
                            }
            }
        }
        .onAppear(perform: authenticator)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                // Only record background time if Face ID is actually enabled
                if faceIDEnabled {
                    backgroundedAt = Date()
                }

            } else if newPhase == .active {
                guard faceIDEnabled else {
                    // Face ID off — always stay unlocked
                    isUnlocked = true
                    return
                }

                if let backgroundedAt {
                    let elapsed = Date().timeIntervalSince(backgroundedAt)
                    if elapsed > Double(lockGracePeriodSeconds) {
                        isUnlocked = false
                    }
                }

                if !isUnlocked {
                    authenticator()
                }
            }
        }
//        .onChange(of: scenePhase) { _, newPhase in
//            if newPhase == .background {
//                backgroundedAt = Date()
//            } else if newPhase == .active {
//                if let backgroundedAt {
//                    let elapsed = Date().timeIntervalSince(backgroundedAt)
//                    if elapsed > Double(lockGracePeriodSeconds) {
//                        isUnlocked = false
//                    }
//                }
//                if faceIDEnabled && !isUnlocked {
//                    authenticator()
//                }
//            }
//        }
        .onOpenURL { url in  // ✅ add here
            if url.absoluteString == "workoutapp://calendar" {
                router.activeScreen = .workoutDetail
            }
        }
    }
    
    private func authenticator() {
        guard faceIDEnabled else {
                // Setting is off — skip authentication entirely, app opens normally.
                isUnlocked = true
                return
            }
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authenticate to access your workouts"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        authFailed = false
                        self.backgroundedAt = nil
                    } else {
                        authFailed = true
                    }
                }
            }
        } else {
            // No biometrics available/enrolled on this device — decide what should happen here.
            // Currently this silently does nothing too, which has the same "stuck" problem.
            authFailed = true
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

        guard let shared =
        UserDefaults(
            suiteName:
            "group.Fox-Studios.WorkoutApp2"
        ) else {
            return
        }

        if let data =
        shared.data(
            forKey:"workout_entries"
        ),

        let decoded =
        try? JSONDecoder().decode(
            [WorkoutEntry].self,
            from:data
        ) {

            entries = decoded

            if selectedWorkout.isEmpty,
               let first = workoutsList.first {

                selectedWorkout = first

            } else if !workoutsList.contains(selectedWorkout) {

                selectedWorkout =
                workoutsList.first ?? ""
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
            .environmentObject(GradientSettings())
    }
}

enum LockGracePeriod: Int, CaseIterable, Identifiable {
    case immediately = 0
    case thirtySeconds = 30
    case oneMinute = 60
    case fiveMinutes = 300

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .immediately: return "Immediately"
        case .thirtySeconds: return "30 Seconds"
        case .oneMinute: return "1 Minute"
        case .fiveMinutes: return "5 Minutes"
        }
    }
}
