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
    @StateObject private var gradientSettings = GradientSettings()
    
    @State private var isBooting: Bool = true

    @AppStorage("hasCompletedSetup")
    private var hasCompletedSetup: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isBooting {
                    LaunchScreen()
                        .environmentObject(gradientSettings)
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
                            .environmentObject(gradientSettings)
                    } else {
                        StartUpView()
                            .environmentObject(workoutData)
                            .environmentObject(healthManager)
                            .environmentObject(router)
                            .environmentObject(gradientSettings)
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
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .openPhotoReminder
                )
            ) { _ in
                router.selectedTab = .settings
                router.activeScreen = nil
            }
        }
    }
}

func migrateUserDefaultsToShared() {
    let standard = UserDefaults.standard
    guard let shared = UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2") else {
        print("FAILED TO GET SHARED DEFAULTS")
        return
    }

    // Decode both stores
    let standardEntries: [WorkoutEntry] = {
        guard let data = standard.data(forKey: "workout_entries"),
              let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data)
        else { return [] }
        return decoded
    }()

    let sharedEntries: [WorkoutEntry] = {
        guard let data = shared.data(forKey: "workout_entries"),
              let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data)
        else { return [] }
        return decoded
    }()

    print("Standard entries: \(standardEntries.count)")
    print("Shared entries: \(sharedEntries.count)")

    // Merge by combining both and deduplicating by ID
    var merged = sharedEntries
    let existingIDs = Set(sharedEntries.map { $0.id })
    for entry in standardEntries {
        if !existingIDs.contains(entry.id) {
            merged.append(entry)
        }
    }

    // Sort by date
    merged.sort { $0.date < $1.date }

    print("Merged entries: \(merged.count)")

    if let encoded = try? JSONEncoder().encode(merged) {
        shared.set(encoded, forKey: "workout_entries")
        standard.set(encoded, forKey: "workout_entries")  // keep standard in sync too
    }
}

func debugStorage() {

    let standard =
    UserDefaults.standard

    guard let shared =
    UserDefaults(
        suiteName:
        "group.Fox-Studios.WorkoutApp2"
    ) else {
        return
    }

    print("========== STANDARD ==========")

    if let data =
        standard.data(
            forKey:"workout_entries"
        ) {

        print(
            "Workout bytes:",
            data.count
        )

        if let workouts =
            try? JSONDecoder().decode(
                [WorkoutEntry].self,
                from:data
            ) {

            print(
                "Workout count:",
                workouts.count
            )

            print(
                "First workout:",
                workouts.first?.date ?? Date()
            )

            print(
                "Last workout:",
                workouts.last?.date ?? Date()
            )
        }

    } else {

        print(
            "No workout entries"
        )
    }

    print(
        "Weight:",
        standard.string(
            forKey:"userWeight"
        ) ?? "nil"
    )

    print(
        "Target Days:",
        standard.string(
            forKey:"userTargetDaysOfWorkout"
        ) ?? "nil"
    )

    print(
        "Unit:",
        standard.string(
            forKey:"unitSystem"
        ) ?? "nil"
    )



    print("========== SHARED ==========")

    if let data =
        shared.data(
            forKey:"workout_entries"
        ) {

        print(
            "Workout bytes:",
            data.count
        )

        if let workouts =
            try? JSONDecoder().decode(
                [WorkoutEntry].self,
                from:data
            ) {

            print(
                "Workout count:",
                workouts.count
            )

            print(
                "First workout:",
                workouts.first?.date ?? Date()
            )

            print(
                "Last workout:",
                workouts.last?.date ?? Date()
            )
        }

    } else {

        print(
            "No workout entries"
        )
    }

    print(
        "Weight:",
        shared.string(
            forKey:"userWeight"
        ) ?? "nil"
    )

    print(
        "Target Days:",
        shared.string(
            forKey:"userTargetDaysOfWorkout"
        ) ?? "nil"
    )

    print(
        "Unit:",
        shared.string(
            forKey:"unitSystem"
        ) ?? "nil"
    )

}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        migrateUserDefaultsToShared()

        // Set this class as notification delegate
        UNUserNotificationCenter.current().delegate = self

        UserDefaults.standard.register(defaults: [
            "notificationsEnabled": true,
            "weighInReminder": true,
            "milestonesReminder": true,
            "goalReminder": true
        ])

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
            } else if id == "weekly_photo_reminder" ||
                        id == "monthly_photo_reminder" {

                  NotificationCenter.default.post(
                      name: .openPhotoReminder,
                      object: nil
                  )
              }

            completionHandler()
        }
}

extension Notification.Name {
    static let openCalendar = Notification.Name("openCalendar")
    static let openWeightView = Notification.Name("openWeightView")
    static let openGoals = Notification.Name("openGoals")
    static let openMileStones = Notification.Name("openMileStones")
    static let openPhotoReminder = Notification.Name("openPhotoReminder")
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
    @Published var activeScreen: Screen? = nil 

    enum Tab {
        case home
        case workout
        case progress
        case settings
        case photo
    }

    enum Screen: Identifiable {
        case timer
        case workoutDetail
        case goalEdit
        case weight
        case achievedGoals
        case achievedMileStones
        case photoReminder

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
        
        case "photoReminder":
            selectedTab = .photo
            
            
        default:
            selectedTab = .home
        }
    }
}
