//
//  ContentView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @State private var entries: [WorkoutEntry] = []
    @State private var selectedWorkout: String = ""

    var body: some View {
        TabView{
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ImportView()
                .tabItem{
                    Label("Import", systemImage: "dumbbell")
                }
            PhotoView()
                .tabItem{
                    Label("Camera", systemImage: "camera")
                }
            NavigationView {
                VStack(spacing: 16) {
                    if workoutsList.isEmpty {
                        ContentUnavailableView("No workouts yet", systemImage: "chart.xyaxis.line", description: Text("Log some sets to see progress here."))
                            .padding()
                    } else {
                        Picker("Workout", selection: $selectedWorkout) {
                            ForEach(workoutsList, id: \.self) { w in
                                Text(w).tag(w)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal)

                        WorkoutProgressChart(
                            workoutName: selectedWorkout,
                            entries: entries,
                            unitSystemRaw: unitSystemRaw
                        )
                    }
                }
                .navigationTitle("Progress")
                .onAppear(perform: loadEntries)
            }
            .tabItem {
                Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
            }
            AccountView()
                .tabItem{
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
    }
}
