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
