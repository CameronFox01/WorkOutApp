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
    @StateObject private var router = AppRouter()
    
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
                            .environmentObject(router)
                    } else {
                        StartUpView()
                            .environmentObject(workoutData)
                            .environmentObject(healthManager)
                            .environmentObject(router)
                    }
                }
            }
            .onOpenURL { url in
                  router.handle(url: url)
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

//Section for widgets and Notification to take you to the correct spot
enum AppRoute {
    case home
    case workout
    case goals
    case progress
    case timer
    case setup
}

class AppRouter: ObservableObject {

    @Published var selectedTab: Tab = .home
    @Published var activeScreen: Screen? = nil   // 👈 NEW

    enum Tab {
        case home
        case workout
        case progress
        case settings
    }

    enum Screen: Identifiable {
        case timer
        case workoutDetail
        case goalEdit

        var id: String { "\(self)" }
    }

    func handle(url: URL) {
        guard let host = url.host else { return }

        switch host {

        case "home":
            selectedTab = .home

        case "workout":
            selectedTab = .workout

        case "progress":
            selectedTab = .progress

        case "goals":
            selectedTab = .progress

        case "timer":
            activeScreen = .timer   // 🔥 NOT a tab
            
        case "workoutDetail":
            activeScreen = .workoutDetail

        default:
            selectedTab = .home
        }
    }
}
