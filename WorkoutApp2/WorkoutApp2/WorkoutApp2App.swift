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
            .onReceive(NotificationCenter.default.publisher(for: .openCalendar)) { _ in
                router.activeScreen = .workoutDetail
            }
            .onReceive(NotificationCenter.default.publisher(for: .openWeightView)) { _ in
                router.activeScreen = .weight
            }
            .onReceive(NotificationCenter.default.publisher(for: .openGoals)) { _ in
                router.activeScreen = .achievedGoals
                //router.selectedTab = .progress
            }
            .onReceive(NotificationCenter.default.publisher(for: .openMileStones)) { _ in
                router.activeScreen = .achievedMileStones
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
    
    //Section for directing users to certain screens based on the notification
    func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) {
            let id = response.notification.request.identifier

            if id.hasPrefix("planned_") {
                NotificationCenter.default.post(name: .openCalendar, object: nil)
            } else if id == "daily_weigh_in" || id == "weekly_weigh_in" {
                NotificationCenter.default.post(name: .openWeightView, object: nil)
            } else if id.hasPrefix("goalReached_") {
                NotificationCenter.default.post(name: .openGoals, object: nil)
            } else if id.hasPrefix("workout_"){
                NotificationCenter.default.post(name: .openMileStones, object: nil)
            }

            completionHandler()
        }
}

extension Notification.Name {
    static let openCalendar = Notification.Name("openCalendar")
    static let openWeightView = Notification.Name("openWeightView")
    static let openGoals = Notification.Name("openGoals")
    static let openMileStones = Notification.Name("openMileStones")
}

//Section for widgets and Notification to take you to the correct spot
enum AppRoute {
    case home
    case workout
    case goals
    case progress
    case timer
    case setup
    case weight
    case achievedGoals
    case achievedMileStones
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
        case weight
        case achievedGoals
        case achievedMileStones

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
            
        case "weight":
            activeScreen = .weight
            
        case "achievedGoals":
            activeScreen = .achievedGoals

        case "achievedMileStones":
            activeScreen = .achievedMileStones
        default:
            selectedTab = .home
        }
    }
}
