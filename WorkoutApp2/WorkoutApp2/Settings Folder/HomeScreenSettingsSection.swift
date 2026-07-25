//
//  HomeScreenSettingsSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/24/26.
//
import SwiftUI
import Foundation
import WidgetKit

struct HomeScreenSettingsSection: View {
    @AppStorage("numberOfWorkoutsToShow") private var numberOfWorkoutsToShow: Int = 12
    @AppStorage("showStopWatch") private var showStopWatch: Bool = true
    @AppStorage("playSoundAtEndOfTimer") private var playSoundAtEndOfTimer: Bool = true
    @AppStorage("energyLabel") private var energyLabel: String = "Calories"
    @AppStorage("showBMI") private var showBMI: Bool = false
    @AppStorage("showMeasurement") private var showMeasurement: Bool = false
    @AppStorage("showDailyPlanner") private var showDailyPlanner: Bool = true
    @AppStorage("showWeeklyRecap") private var showWeeklyRecap: Bool = true
    @AppStorage("showWeightCard") private var showWeightCard: Bool = true
    @AppStorage("showCalorieCard") private var showCalorieCard: Bool = true
    @AppStorage("showTimerCard") private var showTimerCard: Bool = true
    @AppStorage("showStepsCard") private var showStepsCard: Bool = true
    @AppStorage("showCalendarCard") private var showCalendarCard: Bool = true
    @AppStorage("showRecentWorkouts") private var showRecentWorkouts: Bool = true
    @AppStorage("showAllImported") private var showAllImported: Bool = true

    @FocusState private var workoutsFieldFocused: Bool

    var body: some View {
        CollapsibleSettingsSection(
            title: "Home Screen",
            icon: "house.fill",
            iconColor: .blue
        ) {
            SettingsRow(icon: "rectangle.grid.2x2.fill", title: "Recent Workouts") {
                TextField("12", value: $numberOfWorkoutsToShow, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 50)
                    .focused($workoutsFieldFocused)
            }
            Divider()
            SettingsRow(icon: "timer", title: "Workout Timer") {
                Picker("", selection: $showStopWatch) {
                    Text("Stopwatch").tag(true)
                    Text("Timer").tag(false)
                }
            }
            Divider()
            SettingsRow(
                icon: playSoundAtEndOfTimer ? "speaker.wave.2.fill" : "speaker.slash.fill",
                title: "Timer Sound"
            ) {
                Toggle("", isOn: $playSoundAtEndOfTimer).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "flame.fill", title: "Energy Units") {
                Picker("", selection: $energyLabel) {
                    Text("Calories").tag("Calories")
                    Text("kcal").tag("kcal")
                }
                .pickerStyle(.menu)
            }
            Divider()
            SettingsRow(icon: "scalemass", title: "Show BMI") {
                Toggle("", isOn: $showBMI).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "ruler", title: "Show Measurements") {
                Toggle("", isOn: $showMeasurement).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "calendar.badge.checkmark", title: "Show Daily Planner") {
                Toggle("", isOn: $showDailyPlanner).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "calendar", title: "Show Weekly Recap") {
                Toggle("", isOn: $showWeeklyRecap).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "scalemass", title: "Show Weight Card") {
                Toggle("", isOn: $showWeightCard).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "flame.fill", title: "Show Calorie Card") {
                Toggle("", isOn: $showCalorieCard).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "stopwatch", title: "Show Timer") {
                Toggle("", isOn: $showTimerCard).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "figure.walk", title: "Show Steps") {
                Toggle("", isOn: $showStepsCard).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "calendar", title: "Show Calendar") {
                Toggle("", isOn: $showCalendarCard).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "dumbbell", title: "Show Recent Workouts") {
                Toggle("", isOn: $showRecentWorkouts).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "list.bullet", title: "Show All Workouts") {
                Toggle("", isOn: $showAllImported).labelsHidden()
            }
        }
    }
}
