//
//  NotificationsSettingsSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/24/26.
//
import SwiftUI
import Foundation
import WidgetKit

struct NotificationsSettingsSection: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("milestonesReminder") private var milesstoneReminder: Bool = true
    @AppStorage("goalReminder") private var goalReminder: Bool = true
    @AppStorage("workoutChallengeReminder") private var workoutChallengeReminder: Bool = true

    @AppStorage("weighInReminder") private var weighInReminder: Bool = true
    @AppStorage("weighInReminderTime") private var weighInReminderTime: Double =
        Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())?.timeIntervalSince1970 ?? Date().timeIntervalSince1970

    @AppStorage("weighInWeeklyReminder") private var weighInWeeklyReminder: Bool = false
    @AppStorage("weighInWeeklyReminderTime") private var weighInWeeklyReminderTime: Double =
        Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    @AppStorage("weeklyWeighInDay") private var weeklyWeighInDay: Int = 1

    @AppStorage("weeklyProgressPhotoReminder") private var weeklyProgressPhotoReminder: Bool = true
    @AppStorage("weeklyPhotoReminderTime") private var weeklyPhotoReminderTime: Double =
        Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    @AppStorage("weeklyPhotoReminderDay") private var weeklyPhotoReminderDay: Int = 1

    @AppStorage("monthlyProgressPhotoReminder") private var monthlyProgressPhotoReminder: Bool = false
    @AppStorage("monthlyPhotoReminderTime") private var monthlyPhotoReminderTime: Double =
        Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    @AppStorage("monthlyPhotoReminderDay") private var monthlyPhotoReminderDay: Int = 1

    var body: some View {
        CollapsibleSettingsSection(
            title: "Notifications",
            icon: "bell.fill",
            iconColor: .red
        ) {
            SettingsCard(title: "") {
                SettingsRow(
                    icon: notificationsEnabled ? "bell.badge.fill" : "bell.slash.fill",
                    title: "Enable Notifications"
                ) {
                    Toggle("", isOn: $notificationsEnabled).labelsHidden()
                }

                Divider()

                SettingsRow(
                    icon: notificationsEnabled ? "bell.fill" : "bell.slash.fill",
                    title: "Enable Milestone Notifications"
                ) {
                    Toggle("", isOn: $milesstoneReminder).labelsHidden()
                }
                .opacity(notificationsEnabled ? 1 : 0.4)

                Divider()

                SettingsRow(
                    icon: notificationsEnabled ? "bell.fill" : "bell.slash.fill",
                    title: "Enable Achieved Goal Notifications"
                ) {
                    Toggle("", isOn: $goalReminder).labelsHidden()
                }
                .opacity(notificationsEnabled ? 1 : 0.4)

                Divider()

                SettingsRow(
                    icon: notificationsEnabled ? "flame.fill" : "bell.slash.fill",
                    title: "Weekly Workout Challenge"
                ) {
                    Toggle("", isOn: $workoutChallengeReminder).labelsHidden()
                }
                .opacity(notificationsEnabled ? 1 : 0.4)

                if notificationsEnabled && workoutChallengeReminder {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        Text("Sends a mid-week check-in (Wed) and end-of-week push (Sat) if you haven't hit your weekly goal.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 42)
                }

                Divider()
                Text("Weight Settings").font(.title3).bold().padding(.top, 16)

                reminderCard(
                    isEnabled: notificationsEnabled && weighInReminder,
                    toggleRow: {
                        SettingsRow(icon: weighInReminder ? "bell.fill" : "bell.slash.fill", title: "Daily Weigh-In Reminder") {
                            Toggle("", isOn: $weighInReminder).labelsHidden().disabled(!notificationsEnabled)
                        }
                    },
                    isReminderOn: notificationsEnabled && weighInReminder
                ) {
                    SettingsRow(icon: "clock.fill", title: "Time") {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { Date(timeIntervalSince1970: weighInReminderTime) },
                                set: { weighInReminderTime = $0.timeIntervalSince1970 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                    }
                }

                SettingsCard(title: "") {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            SettingsRow(
                                icon: weighInWeeklyReminder ? "bell.fill" : "bell.slash.fill",
                                title: "Weekly Weigh-In Reminder"
                            ) {
                                Toggle("", isOn: $weighInWeeklyReminder).labelsHidden().disabled(!notificationsEnabled)
                            }
                            .opacity(notificationsEnabled ? 1 : 0.4)

                            if notificationsEnabled && weighInWeeklyReminder {
                                Divider()
                                SettingsRow(icon: "clock.fill", title: "Time") {
                                    DatePicker(
                                        "",
                                        selection: Binding(
                                            get: { Date(timeIntervalSince1970: weighInWeeklyReminderTime) },
                                            set: { weighInWeeklyReminderTime = $0.timeIntervalSince1970 }
                                        ),
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                }
                                Picker("Day", selection: $weeklyWeighInDay) {
                                    Text("Sunday").tag(1)
                                    Text("Monday").tag(2)
                                    Text("Tuesday").tag(3)
                                    Text("Wednesday").tag(4)
                                    Text("Thursday").tag(5)
                                    Text("Friday").tag(6)
                                    Text("Saturday").tag(7)
                                }
                            } else {
                                disabledRow
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(notificationsEnabled && weighInWeeklyReminder ? Color.blue.opacity(0.12) : Color.gray.opacity(0.08))
                        )
                    }
                }

                Text("Photo Settings").font(.title3).bold().padding(.top, 10)

                SettingsCard(title: "") {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            SettingsRow(
                                icon: weeklyProgressPhotoReminder ? "bell.fill" : "bell.slash.fill",
                                title: "Weekly Photo Reminder"
                            ) {
                                Toggle("", isOn: $weeklyProgressPhotoReminder).labelsHidden().disabled(!notificationsEnabled)
                            }
                            .opacity(notificationsEnabled ? 1 : 0.4)

                            if notificationsEnabled && weeklyProgressPhotoReminder {
                                Divider()
                                SettingsRow(icon: "clock.fill", title: "Time") {
                                    DatePicker(
                                        "",
                                        selection: Binding(
                                            get: { Date(timeIntervalSince1970: weeklyPhotoReminderTime) },
                                            set: { weeklyPhotoReminderTime = $0.timeIntervalSince1970 }
                                        ),
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                }
                                Picker("Day", selection: $weeklyPhotoReminderDay) {
                                    Text("Sunday").tag(1)
                                    Text("Monday").tag(2)
                                    Text("Tuesday").tag(3)
                                    Text("Wednesday").tag(4)
                                    Text("Thursday").tag(5)
                                    Text("Friday").tag(6)
                                    Text("Saturday").tag(7)
                                }
                            } else {
                                disabledRow
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(notificationsEnabled && weeklyProgressPhotoReminder ? Color.blue.opacity(0.12) : Color.gray.opacity(0.08))
                        )
                    }
                }

                SettingsCard(title: "") {
                    VStack(spacing: 16) {
                        SettingsRow(
                            icon: monthlyProgressPhotoReminder ? "bell.fill" : "bell.slash.fill",
                            title: "Monthly Photo Reminder"
                        ) {
                            Toggle("", isOn: $monthlyProgressPhotoReminder).labelsHidden().disabled(!notificationsEnabled)
                        }
                        .opacity(notificationsEnabled ? 1 : 0.4)

                        if notificationsEnabled && monthlyProgressPhotoReminder {
                            Divider()
                            SettingsRow(icon: "clock.fill", title: "Time") {
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { Date(timeIntervalSince1970: monthlyPhotoReminderTime) },
                                        set: { monthlyPhotoReminderTime = $0.timeIntervalSince1970 }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                            }
                            Picker("Day of Month", selection: $monthlyPhotoReminderDay) {
                                ForEach(1...28, id: \.self) { day in
                                    Text(dayOfMonthLabel(day)).tag(day)
                                }
                            }
                        } else {
                            disabledRow
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(notificationsEnabled && monthlyProgressPhotoReminder ? Color.blue.opacity(0.12) : Color.gray.opacity(0.08))
                    )
                }
            }
        }
        .onChange(of: weighInReminder) { _, newValue in
            if newValue { weighInWeeklyReminder = false }
            updateWeighInReminder()
        }
        .onChange(of: weighInWeeklyReminder) { _, newValue in
            if newValue { weighInReminder = false }
            updateWeeklyWeighInReminder()
        }
        .onChange(of: weighInWeeklyReminderTime) { _, _ in updateWeeklyWeighInReminder() }
        .onChange(of: weighInReminderTime) { _, _ in updateWeighInReminder() }
        .onChange(of: weeklyProgressPhotoReminder) { _, newValue in
            if newValue {
                monthlyProgressPhotoReminder = false
                NotificationHandler.shared.removeNotification(identifier: "monthly_photo_reminder")
            }
            updateWeeklyPhotoReminder()
        }
        .onChange(of: monthlyProgressPhotoReminder) { _, newValue in
            if newValue {
                weeklyProgressPhotoReminder = false
                NotificationHandler.shared.removeNotification(identifier: "weekly_photo_reminder")
            }
            updateMonthlyPhotoReminder()
        }
        .onChange(of: weeklyPhotoReminderTime) { _, _ in updateWeeklyPhotoReminder() }
        .onChange(of: weeklyPhotoReminderDay) { _, _ in updateWeeklyPhotoReminder() }
        .onChange(of: monthlyPhotoReminderTime) { _, _ in updateMonthlyPhotoReminder() }
        .onChange(of: monthlyPhotoReminderDay) { _, _ in updateMonthlyPhotoReminder() }
        .onChange(of: notificationsEnabled) { _, _ in
            updateWeighInReminder()
            updateWeeklyPhotoReminder()
            updateMonthlyPhotoReminder()
        }
        .onAppear {
            updateWeighInReminder()
            updateWeeklyWeighInReminder()
            updateWeeklyPhotoReminder()
            updateMonthlyPhotoReminder()
        }
    }

    // MARK: - Small helpers

    private var disabledRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "moon.zzz.fill").foregroundStyle(.secondary)
            Text("Reminder disabled").foregroundStyle(.secondary)
            Spacer()
        }
        .font(.subheadline)
    }

    @ViewBuilder
    private func reminderCard<ToggleRow: View, Content: View>(
        isEnabled: Bool,
        @ViewBuilder toggleRow: () -> ToggleRow,
        isReminderOn: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        SettingsCard(title: "") {
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    toggleRow().opacity(notificationsEnabled ? 1 : 0.4)
                    if isReminderOn {
                        Divider()
                        content()
                    } else {
                        disabledRow
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(isReminderOn ? Color.blue.opacity(0.12) : Color.gray.opacity(0.08))
                )
            }
        }
    }

    private func dayOfMonthLabel(_ day: Int) -> String {
        let suffix: String
        switch day {
        case 1, 21: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }
        return "\(day)\(suffix)"
    }

    private func updateWeighInReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily_weigh_in"])
        guard notificationsEnabled, weighInReminder else { return }
        let reminderDate = Date(timeIntervalSince1970: weighInReminderTime)
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        NotificationHandler.shared.scheduleDailyWeighInNotification(
            hour: components.hour ?? 8,
            minute: components.minute ?? 0
        )
    }

    private func updateWeeklyWeighInReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weekly_weigh_in"])
        guard notificationsEnabled, weighInWeeklyReminder else { return }
        let reminderDate = Date(timeIntervalSince1970: weighInWeeklyReminderTime)
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        NotificationHandler.shared.scheduleWeeklyWeighInNotification(
            hour: components.hour ?? 8,
            minute: components.minute ?? 0,
            weekday: weeklyWeighInDay,
            identifier: "weekly_weigh_in"
        )
    }

    private func updateWeeklyPhotoReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weekly_photo_reminder"])
        guard notificationsEnabled, weeklyProgressPhotoReminder else { return }
        let reminderDate = Date(timeIntervalSince1970: weeklyPhotoReminderTime)
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        NotificationHandler.shared.scheduleWeeklyPhotoReminder(
            hour: components.hour ?? 8,
            minute: components.minute ?? 0,
            weekday: weeklyPhotoReminderDay
        )
    }

    private func updateMonthlyPhotoReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["monthly_photo_reminder"])
        guard notificationsEnabled, monthlyProgressPhotoReminder else { return }
        let reminderDate = Date(timeIntervalSince1970: monthlyPhotoReminderTime)
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        NotificationHandler.shared.scheduleMonthlyPhotoReminder(
            hour: components.hour ?? 8,
            minute: components.minute ?? 0,
            dayOfMonth: monthlyPhotoReminderDay
        )
    }
}
