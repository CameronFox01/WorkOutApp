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
    
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup: Bool = false

    var body: some Scene {
        WindowGroup {
            if(hasCompletedSetup){
                ContentView()
                    .environmentObject(workoutData)
                    .environmentObject(healthManager)  // ✅ Add this here
            }else {
                StartUpView()
            }
        }
    }
}
