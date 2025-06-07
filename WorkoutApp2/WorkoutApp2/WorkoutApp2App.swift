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

        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(workoutData)  // inject shared data
            }
        }
}
