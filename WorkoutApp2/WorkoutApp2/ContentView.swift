//
//  ContentView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    @EnvironmentObject var healthManager: HealthManager  // ✅ Add
    @EnvironmentObject var workoutData: WorkoutData
    
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @State private var entries: [WorkoutEntry] = []
    @State private var selectedWorkout: String = ""

    var body: some View {
        TabView {
            HomeView()
                .environmentObject(healthManager)  
                .environmentObject(workoutData)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ImportView()
                .environmentObject(healthManager)
                .environmentObject(workoutData)
                .tabItem {
                    Label("Import", systemImage: "dumbbell")
                }
            PhotoView()
                .environmentObject(healthManager)
                .environmentObject(workoutData)
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }
            AccountView()
                .environmentObject(healthManager)
                .environmentObject(workoutData)
                .tabItem {
                    Label("Account", systemImage: "person")
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
            if selectedWorkout.isEmpty, let first = workoutsList.first {
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
    }
}
