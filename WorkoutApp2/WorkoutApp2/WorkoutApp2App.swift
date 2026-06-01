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

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var workoutData = WorkoutData()
    @StateObject var healthManager = HealthManager()
    @State private var isBooting: Bool = true

    @AppStorage("hasCompletedSetup")
    private var hasCompletedSetup: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isBooting {
                    LaunchScreen()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                isBooting = false
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

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        // Set this class as the notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Register defaults so UserDefaults never returns false unexpectedly
        UserDefaults.standard.register(defaults: [
            "notificationsEnabled": true,
            "weighInReminder": true,
            "milestonesReminder": true,
            "goalReminder": true
        ])

        // Request permission and schedule reminders
        NotificationHandler.shared.requestNotificationPermission()
        NotificationHandler.shared.scheduleWeighInReminder()

        return true
    }

    // Shows notifications even when the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
