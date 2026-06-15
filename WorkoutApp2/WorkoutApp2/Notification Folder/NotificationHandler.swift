//
//  NotificationHandler.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/27/26.
//

import Foundation
import UserNotifications

class NotificationHandler {

    static let shared = NotificationHandler()

    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .badge, .sound]
            ) { success, error in

                if let error {
                    print(error)
                }

                print(success ? "Permission Granted" : "Permission Denied")
            }
    }

    func removeNotification(
        identifier: String
    ) {

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )

    }
    
    func scheduleWeeklyWeighInNotification(
    hour: Int,
    minute: Int,
    weekday: Int,
    identifier: String
    ){
        //Remove the old one
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )
        
        let content = UNMutableNotificationContent()
        
        content.title = "Weekly Weigh In"
        content.body = "Don't forget to log this weeks weight."
        content.sound = .default
        
        var components = DateComponents()
        
        components.hour = hour
        components.minute = minute
        components.weekday = weekday
        
        let trigger =
        UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        
        let request =
        UNNotificationRequest(
            identifier: "weekly_weigh_in",
            content: content,
            trigger: trigger
            )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed weekly reminder: \(error)")
            } else {
                print("Weekly reminder scheduled")
            }
        }
    }
    
    func scheduleDailyWeighInNotification(
        hour: Int,
        minute: Int
    ) {

        let content = UNMutableNotificationContent()

        content.title = "Daily Weigh In"
        content.body = "Don't forget to log today's weight."
        content.sound = .default

        var components = DateComponents()

        components.hour = hour
        components.minute = minute

        let trigger =
        UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request =
        UNNotificationRequest(
            identifier: "daily_weigh_in",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule daily weigh-in: \(error)")
            } else {
                print("Scheduled daily weigh-in at \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    func ensureAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion(true)
            case .denied:
                completion(false)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                    completion(granted)
                }
            @unknown default:
                completion(false)
            }
        }
    }
    
    func scheduleWeighInReminder() {

        let notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "notificationsEnabled")

        let weighInEnabled = UserDefaults.standard.object(forKey: "weighInReminder") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "weighInReminder")

        let identifier = "daily_weigh_in"

        // Remove old notification first
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )

        guard notificationsEnabled,
              weighInEnabled else {

            return
        }

        let savedTime =
        Date(
            timeIntervalSince1970:
            UserDefaults.standard.double(
                forKey: "weighInReminderTime")
        )

        let components =
        Calendar.current.dateComponents(
            [.hour,.minute],
            from: savedTime
        )

        var dateComponents = DateComponents()

        dateComponents.hour =
        components.hour

        dateComponents.minute =
        components.minute

        let trigger =
        UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let content =
        UNMutableNotificationContent()

        content.title =
        "Daily Weigh In"

        content.body =
        "Don't forget to log today's weight."

        content.sound = .default

        let request =
        UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current()
            .add(request)

    }
    
    func scheduleWorkoutNotification(
        title: String,
        body: String,
        weekday: Int,
        hour: Int,
        minute: Int,
        identifier: String
    ) {

        // remove old version
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )

        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()

        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current()
            .add(request)
    }
    
    func sendInstantNotification(title: String, body: String, identifier: String = UUID().uuidString) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("Failed to schedule: \(error)") }
        }
    }
    
    func scheduleWeeklyWorkoutChallengeNotifications(goalDays: Int) {
        let center = UNUserNotificationCenter.current()
        
        // Remove old ones first
        center.removePendingNotificationRequests(withIdentifiers: [
            "workout_challenge_midweek",
            "workout_challenge_endweek"
        ])
        
        guard goalDays > 0 else { return }
        
        // Mid-week check-in — Wednesday at 6pm
        let midweekContent = UNMutableNotificationContent()
        midweekContent.title = "Halfway There!"
        midweekContent.body = "You're aiming for \(goalDays) workouts this week. Keep building that momentum!"
        midweekContent.sound = .default
        
        var midweekComponents = DateComponents()
        midweekComponents.weekday = 4  // Wednesday
        midweekComponents.hour = 18
        midweekComponents.minute = 0
        
        let midweekTrigger = UNCalendarNotificationTrigger(
            dateMatching: midweekComponents,
            repeats: true
        )
        
        center.add(UNNotificationRequest(
            identifier: "workout_challenge_midweek",
            content: midweekContent,
            trigger: midweekTrigger
        ))
        
        // End of week push — Saturday at 10am
        let endweekContent = UNMutableNotificationContent()
        endweekContent.title = "One More Opportunity"
        endweekContent.body = "A workout today can still move things forward."
        endweekContent.sound = .default
        
        var endweekComponents = DateComponents()
        endweekComponents.weekday = 7  // Saturday
        endweekComponents.hour = 10
        endweekComponents.minute = 0
        
        let endweekTrigger = UNCalendarNotificationTrigger(
            dateMatching: endweekComponents,
            repeats: true
        )
        
        center.add(UNNotificationRequest(
            identifier: "workout_challenge_endweek",
            content: endweekContent,
            trigger: endweekTrigger
        ))
    }
}
