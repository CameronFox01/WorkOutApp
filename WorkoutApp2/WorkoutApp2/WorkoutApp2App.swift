//
//  WorkoutApp2App.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI

@main
struct WorkoutApp2App: App {
    @StateObject private var workoutData = WorkoutData()
    @StateObject var healthManager = HealthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutData)
                .environmentObject(healthManager)  // ✅ Add this here
        }
    }
}
