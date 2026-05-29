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
    
    func scheduleDailyWeighInNotification(
        hour: Int,
        minute: Int
    ) {

        let content = UNMutableNotificationContent()

        content.title = "Daily Weigh In"
        content.body = "Time to log your weight today."
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

        UNUserNotificationCenter.current()
            .add(request)
    }
    
    func scheduleWeighInReminder() {

        let notificationsEnabled =
        UserDefaults.standard.bool(
            forKey: "notificationsEnabled"
        )

        let weighInEnabled =
        UserDefaults.standard.bool(
            forKey: "weighInReminder"
        )

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
    
    func sendInstantNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // Trigger immediately (after 0.1s to allow scheduling)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
