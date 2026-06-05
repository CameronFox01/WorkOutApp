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

    @State private var entries: [WorkoutEntry] = []
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
                   
                   case .weight: // This loads it but two issues. 1. Doesn't have any info, (expected) 2. Cant exit the view
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
    
    var weightUnit: String {
        unitSystem == .metric ? "kg" : "lbs"
    }
    
    var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }

    private var workoutsList: [String] {
        Array(Set(entries.map { $0.workoutType })).sorted()
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
            .environmentObject(HealthManager())  // ✅ Add this
            .environmentObject(AppRouter())
    }
}
