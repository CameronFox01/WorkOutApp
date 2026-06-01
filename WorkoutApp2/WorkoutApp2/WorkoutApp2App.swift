//
//  WorkoutApp2App.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI
import UserNotifications

@main
struct WorkoutApp2App: App {

    @StateObject private var workoutData = WorkoutData()
    @StateObject var healthManager = HealthManager()
    @State private var isBooting: Bool = true

    @AppStorage("hasCompletedSetup")
    private var hasCompletedSetup: Bool = false

    init() {
        
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

        NotificationHandler.shared
            .requestNotificationPermission()
        
        NotificationHandler.shared
            .scheduleWeighInReminder()

    }

    var body: some Scene {

        WindowGroup {
            Group {
                if isBooting {
                    LaunchScreen()
                        .onAppear {
                            // Simulate/allow boot tasks to finish before showing main UI
                            DispatchQueue.main.async {
                                // If you have async setup, perform it here then set isBooting = false
                                // For now, allow LaunchScreen's internal 2s animation to run, then swap root.
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    isBooting = false
                                }
                            }
                        }
                } else {
                    if hasCompletedSetup {
                        ContentView()
                            .environmentObject(workoutData)
                            .environmentObject(healthManager)
                    } else {
                        StartUpView()
                            .environmentObject(workoutData)
                            .environmentObject(healthManager)
                    }
                }
            }
        }
    }
}
