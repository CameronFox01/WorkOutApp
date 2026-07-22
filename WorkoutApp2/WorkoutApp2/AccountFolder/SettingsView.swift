//
//  SettingsView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/20/26.
//
// The purpose of this View is to allow users to set their settings to make the app behave the way they would like the app to behave

import SwiftUI
import Foundation
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject var workoutData: WorkoutData

    //Flags being Imported to this View
    @AppStorage("saveButtonAction") private var GoToHomeScreenWhenSaved: Bool = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = true
    @AppStorage("SaveToPhotosApp") private var saveToPhoto: Bool = true
    @AppStorage("showStopWatch") private var showStopWatch: Bool = true
    @AppStorage("playSoundAtEndOfTimer") private var playSoundAtEndOfTimer: Bool = true
    @AppStorage("numberOfWorkoutsToShow") private var numberOfWorkoutsToShow: Int = 12
    @AppStorage("workoutChallengeReminder") private var workoutChallengeReminder: Bool = true
    @AppStorage("weightGoalDirection") private var weightGoalDirection: String = "lose"
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
    
    @AppStorage("showCalculatorImporting") private var showCalculatorImporting: Bool = true
    @AppStorage("showWeightUpdateToast") private var weightUpdateToastEnabled: Bool = true
    
    //Section for tutorials stuff
    
    @State private var showTutorialResetToast = false
    @AppStorage("hasSeenCategoryDetailTutorial") private var hasSeenCategoryDetailTutorial: Bool = false
    @State private var showCategoryDetailTutorial = false
    
    @AppStorage("hasSeenCalendarTutorial") private var hasSeenCalendarTutorial: Bool = false
    @State private var showCalendarTutorial = false
    
    @AppStorage("hasSeenHomeTutorial") private var hasSeenHomeTutorial: Bool = false
    @State private var showHomeTutorial = false
    
    @AppStorage("hasSeenAllImportedTutorial") private var hasSeenAllImportedTutorial: Bool = false
    @State private var showAllImportedTutorial = false
    
    @AppStorage("hasSeenEditWorkoutTutorial") private var hasSeenEditWorkoutTutorial: Bool = false
    @State private var showEditWorkoutTutorial = false
    
    @AppStorage("hasSeenPhotoTutorial") private var hasSeenPhotoTutorial: Bool = false
    @State private var showPhotoTutorial = false
    
    @AppStorage("hasSeenGoalTutorial") private var hasSeenGoalTutorial: Bool = false
    @State private var showGoalTutorial = false
    // Unit system Section
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @State private var showUnitChangeConfirmation = false
    @State private var pendingUnitSystem: String = ""
    
    //Boolean for kcal vs Calories
    @AppStorage("energyLabel")
    private var energyLabel: String = "Calories"
    
    // Widget Background Color
    @AppStorage("widgetUsesGradientBackground", store: UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2"))
    private var widgetUsesGradientBackground: Bool = false

    @State private var showResetConfirmation = false
    @State private var showResetAccountConfirmation = false
    
    @State private var showDeletePhotosConfirmation = false

    // Keyboard focus
    @FocusState private var workoutsFieldFocused: Bool
    
    // FaceID section
    @AppStorage("faceIDEnabled") private var faceIDEnabled: Bool = false
    @AppStorage("lockGracePeriodSeconds") private var lockGracePeriodSeconds: Int = 0
    
    //Notification Section
    //Settings for the entire section
    @AppStorage("notificationsEnabled")
    private var notificationsEnabled = true
    //Notification time for when the reminder to workout is.
    @AppStorage("workoutReminderTime")
    private var workoutReminderTime: Double =
    Calendar.current.date( // This is the section to set the default for when the notification comes out.
        bySettingHour: 8,
        minute: 0,
        second: 0,
        of: Date()
    )?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    
    //Notification for when to Weigh in for Daily Weigh in
    @AppStorage("weighInReminder") private var weighInReminder: Bool = true
    @AppStorage("weighInReminderTime")
    private var weighInReminderTime: Double =
    Calendar.current.date( 
        bySettingHour: 8,
        minute: 0,
        second: 0,
        of: Date()
    )?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    
    
    // Notification for when to Weigh in for Weekly Weigh In
    @AppStorage("weighInWeeklyReminder") private var weighInWeeklyReminder: Bool = false
    @AppStorage("weighInWeeklyReminderTime")
    private var weighInWeeklyReminderTime: Double =
    Calendar.current.date(
        bySettingHour: 8,
        minute: 0,
        second: 0,
        of: Date()
    )?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    
    @AppStorage("weeklyPhotoReminderDay") private var weeklyPhotoReminderDay: Int = 1   // Sunday
    @AppStorage("monthlyPhotoReminderDay") private var monthlyPhotoReminderDay: Int = 1  // 1st of month
    
    @AppStorage("weeklyWeighInDay")
    private var weeklyWeighInDay: Int = 1
    
    // Notification Milestones Section
    @AppStorage("completedMilestonesData")
    private var completedMilestonesData: Data = Data()
    //Notification settings for milestones to be sent
    @AppStorage("milestonesReminder") private var milesstoneReminder: Bool = true
    //Notification for Goals Section
    @AppStorage("goalReminder") private var goalReminder: Bool = true
    //Notification to remind you to take a weekly Progress Photo
    @AppStorage("weeklyProgressPhotoReminder") private var weeklyProgressPhotoReminder: Bool = true
    @AppStorage("weeklyPhotoReminderTime")
    private var weeklyPhotoReminderTime: Double =
    Calendar.current.date(
        bySettingHour: 8,
        minute: 0,
        second: 0,
        of: Date()
    )?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    
    @AppStorage("monthlyProgressPhotoReminder") private var monthlyProgressPhotoReminder: Bool = false
    @AppStorage("monthlyPhotoReminderTime")
    private var monthlyPhotoReminderTime: Double =
    Calendar.current.date(
        bySettingHour: 8,
        minute: 0,
        second: 0,
        of: Date()
    )?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings
    
    var body: some View {
            ZStack{
                LinearGradient(
                    colors: gradientSettings.selectedPreset.swiftUIColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 12) {
                        // MARK: Home Screen
                        CollapsibleSettingsSection(
                            title: "Home Screen",
                            icon: "house.fill",
                            iconColor: .blue
                        ) {
                            // paste your existing Home Screen SettingsCard content here
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
                                Toggle("", isOn: $playSoundAtEndOfTimer)
                                    .labelsHidden()
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
                            SettingsRow(icon: "scalemass", title: "Show Weight Card"){
                                Toggle("", isOn: $showWeightCard).labelsHidden()
                            }
                            Divider()
                            SettingsRow(icon: "flame.fill", title: "Show Calorie Card"){
                                Toggle("", isOn: $showCalorieCard).labelsHidden()
                            }
                            Divider()
                            SettingsRow(icon: "stopwatch", title: "Show Timer"){
                                Toggle("", isOn: $showTimerCard).labelsHidden()
                            }
                            Divider()
                            SettingsRow(icon: "figure.walk", title: "Show Steps"){
                                Toggle("", isOn: $showStepsCard).labelsHidden()
                            }
                            Divider()
                            SettingsRow(icon: "calendar", title: "Show Calendar"){
                                Toggle("", isOn: $showCalendarCard).labelsHidden()
                            }
                            Divider()
                            SettingsRow(icon: "dumbbell", title: "Show Recent Workouts"){
                                Toggle("", isOn: $showRecentWorkouts).labelsHidden()
                            }
                            Divider()
                            SettingsRow(icon: "list.bullet", title: "Show All Workouts"){
                                Toggle("", isOn: $showAllImported).labelsHidden()
                            }
                        }
                        
                        // MARK: Calculator Section
                        CollapsibleSettingsSection(
                            title: "Calculator",
                            icon: "plus.circle",
                            iconColor: .red
                        ){
                            SettingsRow(icon: "plus", title: "Show Calculator during import"){
                                Toggle("", isOn: $showCalculatorImporting).labelsHidden()
                            }
                        }
                        
                        // MARK: Import Settings
                        CollapsibleSettingsSection(
                            title: "Import Settings",
                            icon: "square.and.arrow.down",
                            iconColor: .green
                        ) {
                            SettingsRow(icon: "square.and.arrow.down", title: "Return Home After Import") {
                                Toggle("", isOn: $GoToHomeScreenWhenSaved).labelsHidden()
                            }
                            Divider()
                            SettingsRow(icon: "photo.on.rectangle", title: "Save to Photos App") {
                                Toggle("", isOn: $saveToPhoto).labelsHidden()
                            }
                        }
                        
                        // MARK: Units section
                        CollapsibleSettingsSection(
                            title: "Units",
                            icon: "ruler.fill",
                            iconColor: .teal
                        ) {
                            SettingsRow(icon: "scalemass", title: "Unit System") {
                                Picker("", selection: Binding(
                                    get: { unitSystemRaw },
                                    set: { newValue in
                                        pendingUnitSystem = newValue
                                        showUnitChangeConfirmation = true
                                    }
                                )) {
                                    Text("Imperial (lbs, in, mi)").tag(UnitSystem.imperial.rawValue)
                                    Text("Metric (kg, cm, km)").tag(UnitSystem.metric.rawValue)
                                }
                                .pickerStyle(.menu)
                            }

                            Text("All saved values will be automatically converted.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .confirmationDialog(
                            "Switch Unit System?",
                            isPresented: $showUnitChangeConfirmation,
                            titleVisibility: .visible
                        ) {
                            Button("Convert All Data") {
                                let newSystem = UnitSystem(rawValue: pendingUnitSystem) ?? .metric
                                convertAllDataToNewUnit(newSystem: newSystem)
                                unitSystemRaw = pendingUnitSystem
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("This will convert all your saved weights, measurements, and workout data to the new unit system.")
                        }
                        
                        CollapsibleSettingsSection(
                            title: "Weight Goal",
                            icon: "target",
                            iconColor: .orange
                        ) {
                            SettingsRow(icon: "scalemass", title: "Goal Direction") {
                                Picker("", selection: $weightGoalDirection) {
                                    Text("Lose Weight").tag("lose")
                                    Text("Gain Weight").tag("gain")
                                }
                                .pickerStyle(.menu)
                            }
                            Divider()
                                SettingsRow(icon: "bubble.left.and.bubble.right.fill", title: "Weight Update Toast") {
                                    Toggle("", isOn: $weightUpdateToastEnabled).labelsHidden()
                                }
                        }
                        
                        CollapsibleSettingsSection(
                            title: "Notifications",
                            icon: "bell.fill",
                            iconColor: .red
                        ) {
                            SettingsCard(title: "") {
                                
                                SettingsRow(
                                    icon: notificationsEnabled
                                    ? "bell.badge.fill"
                                    : "bell.slash.fill",
                                    title: "Enable Notifications"
                                ) {
                                    
                                    Toggle("", isOn: $notificationsEnabled)
                                        .labelsHidden()
                                    
                                }
                                
                                Divider()
                                
                                //Notification for Milestones achieved
                                SettingsRow(
                                    icon: notificationsEnabled
                                    ? "bell.fill"
                                    : "bell.slash.fill",
                                    title: "Enable Milestone Notifications"
                                ){
                                    Toggle("", isOn: $milesstoneReminder)
                                        .labelsHidden()
                                }
                                .opacity(notificationsEnabled ? 1 : 0.4)
                                
                                Divider()
                                
                                //Notification for Goals Achieved
                                SettingsRow(
                                    icon: notificationsEnabled
                                    ? "bell.fill"
                                    : "bell.slash.fill",
                                    title: "Enable Achieved Goal Notifications"
                                ){
                                    Toggle("", isOn: $goalReminder)
                                        .labelsHidden()
                                }
                                .opacity(notificationsEnabled ? 1 : 0.4)
                                
                                Divider()
                                
                                // Notification for Weekly Workout Challenge
                                SettingsRow(
                                    icon: notificationsEnabled
                                    ? "flame.fill"
                                    : "bell.slash.fill",
                                    title: "Weekly Workout Challenge"
                                ) {
                                    Toggle("", isOn: $workoutChallengeReminder)
                                        .labelsHidden()
                                }
                                .opacity(notificationsEnabled ? 1 : 0.4)
                                
                                if notificationsEnabled && workoutChallengeReminder {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "info.circle")
                                                .foregroundStyle(.secondary)
                                                .font(.caption)
                                            Text("Sends a mid-week check-in (Wed) and end-of-week push (Sat) if you haven't hit your weekly goal.")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.leading, 42)
                                }
                                
                                //Notification Section
                                Divider()
                                
                                Text("Weight Settings")
                                    .font(.title3).bold()
                                    .padding(.top, 16)
                                
                                //Notification for Daily weigh ins
                                SettingsCard(title: "") {
                                    
                                    VStack(spacing: 16) {
                                        
                                        // WEIGH IN REMINDER CARD
                                        VStack(spacing: 12) {
                                            
                                            SettingsRow(
                                                icon: weighInReminder ? "bell.fill" : "bell.slash.fill",
                                                title: "Daily Weigh-In Reminder"
                                            ) {
                                                Toggle("", isOn: $weighInReminder)
                                                    .labelsHidden()
                                                    .disabled(!notificationsEnabled)
                                            }
                                            .opacity(notificationsEnabled ? 1 : 0.4)
                                            
                                            if notificationsEnabled && weighInReminder {
                                                
                                                Divider()
                                                
                                                SettingsRow(
                                                    icon: "clock.fill",
                                                    title: "Time"
                                                ) {
                                                    
                                                    DatePicker(
                                                        "",
                                                        selection: Binding(
                                                            get: {
                                                                Date(
                                                                    timeIntervalSince1970:
                                                                        weighInReminderTime
                                                                )
                                                            },
                                                            set: {
                                                                weighInReminderTime =
                                                                $0.timeIntervalSince1970
                                                            }
                                                        ),
                                                        displayedComponents: .hourAndMinute
                                                    )
                                                    .labelsHidden()
                                                }
                                                
                                            } else {
                                                
                                                HStack {
                                                    
                                                    Image(systemName: "moon.zzz.fill")
                                                        .foregroundStyle(.secondary)
                                                    
                                                    Text("Reminder disabled")
                                                        .foregroundStyle(.secondary)
                                                    
                                                    Spacer()
                                                }
                                                .font(.subheadline)
                                                
                                            }
                                            
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(
                                                    notificationsEnabled && weighInReminder
                                                    ? Color.blue.opacity(0.12)
                                                    : Color.gray.opacity(0.08)
                                                )
                                        )
                                        
                                    }
                                    
                                }
                                
                                //Notification for Weekly weigh ins
                                SettingsCard(title: ""){
                                    VStack(spacing: 16) {
                                        
                                        SettingsRow(
                                            icon: weighInWeeklyReminder ? "bell.fill" : "bell.slash.fill",
                                            title: "Weekly Weigh-In Reminder"
                                        ) {
                                            Toggle("", isOn: $weighInWeeklyReminder)
                                                .labelsHidden()
                                                .disabled(!notificationsEnabled)
                                        }
                                        .opacity(notificationsEnabled ? 1 : 0.4)
                                        
                                        if notificationsEnabled && weighInWeeklyReminder {
                                            
                                            Divider()
                                            
                                            SettingsRow(
                                                icon: "clock.fill",
                                                title: "Time"
                                            ) {
                                                DatePicker(
                                                    "",
                                                    selection: Binding(
                                                        get: {
                                                            Date(
                                                                timeIntervalSince1970:
                                                                    weighInWeeklyReminderTime
                                                            )
                                                        },
                                                        set: {
                                                            weighInWeeklyReminderTime =
                                                            $0.timeIntervalSince1970
                                                        }
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
                                            
                                            HStack {
                                                
                                                Image(systemName: "moon.zzz.fill")
                                                    .foregroundStyle(.secondary)
                                                
                                                Text("Reminder disabled")
                                                    .foregroundStyle(.secondary)
                                                
                                                Spacer()
                                            }
                                            .font(.subheadline)
                                            
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(
                                                notificationsEnabled && weighInWeeklyReminder
                                                ? Color.blue.opacity(0.12)
                                                : Color.gray.opacity(0.08)
                                            )
                                    )
                                    
                                }
                                
                                Text("Photo Settings")
                                    .font(.title3).bold()
                                    .padding(.top, 10)
                                // Notification for Weekly Photos
                                SettingsCard(title: "") {
                                    VStack(spacing: 16) {
                                        
                                        // WEIGH IN REMINDER CARD
                                        VStack(spacing: 12) {
                                            
                                            SettingsRow(
                                                icon: weeklyProgressPhotoReminder ? "bell.fill" : "bell.slash.fill",
                                                title: "Weekly Photo Reminder"
                                            ) {
                                                Toggle("", isOn: $weeklyProgressPhotoReminder)
                                                    .labelsHidden()
                                                    .disabled(!notificationsEnabled)
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
                                                
                                                HStack {
                                                    
                                                    Image(systemName: "moon.zzz.fill")
                                                        .foregroundStyle(.secondary)
                                                    
                                                    Text("Reminder disabled")
                                                        .foregroundStyle(.secondary)
                                                    
                                                    Spacer()
                                                }
                                                .font(.subheadline)
                                                
                                            }
                                            
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(
                                                    notificationsEnabled && weeklyProgressPhotoReminder
                                                    ? Color.blue.opacity(0.12)
                                                    : Color.gray.opacity(0.08)
                                                )
                                        )
                                        
                                    }
                                    
                                }
                                
                                //Notification for Monthly Photos
                                SettingsCard(title: "") {
                                    VStack(spacing: 16) {
                                        
                                        SettingsRow(
                                            icon: monthlyProgressPhotoReminder ? "bell.fill" : "bell.slash.fill",
                                            title: "Monthly Photo Reminder"
                                        ) {
                                            Toggle("", isOn: $monthlyProgressPhotoReminder)
                                                .labelsHidden()
                                                .disabled(!notificationsEnabled)
                                        }
                                        .opacity(notificationsEnabled ? 1 : 0.4)
                                        
                                        if notificationsEnabled && monthlyProgressPhotoReminder {
                                            
                                            Divider()
                                            
                                            SettingsRow(
                                                icon: "clock.fill",
                                                title: "Time"
                                            ) {
                                                DatePicker(
                                                    "",
                                                    selection: Binding(
                                                        get: {
                                                            Date(timeIntervalSince1970: monthlyPhotoReminderTime)
                                                        },
                                                        set: {
                                                            monthlyPhotoReminderTime = $0.timeIntervalSince1970
                                                        }
                                                    ),
                                                    displayedComponents: .hourAndMinute
                                                )
                                                .labelsHidden()
                                            }
                                            
                                            // Monthly photo day picker — day of month, not day of week
                                            Picker("Day of Month", selection: $monthlyPhotoReminderDay) {
                                                ForEach(1...28, id: \.self) { day in
                                                    Text(dayOfMonthLabel(day)).tag(day)
                                                }
                                            }
                                            
                                        } else {
                                            
                                            HStack {
                                                Image(systemName: "moon.zzz.fill")
                                                    .foregroundStyle(.secondary)
                                                Text("Reminder disabled")
                                                    .foregroundStyle(.secondary)
                                                Spacer()
                                            }
                                            .font(.subheadline)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(
                                                notificationsEnabled && monthlyProgressPhotoReminder
                                                ? Color.blue.opacity(0.12)
                                                : Color.gray.opacity(0.08)
                                            )
                                    )
                                }
                                
                            }
                        }
                        
                        CollapsibleSettingsSection(
                            title: "Background",
                            icon: "paintpalette.fill",
                            iconColor: .purple
                        ) {
                            GradientPickerSection()
                        }
                        
                        CollapsibleSettingsSection(
                            title: "Security",
                            icon: "faceid",
                            iconColor: .blue
                        ) {
                            SettingsRow(icon: "faceid", title: "Require Face ID") {
                                Toggle("", isOn: $faceIDEnabled).labelsHidden()
                            }
                            if faceIDEnabled {
                                Divider()
                                SettingsRow(icon: "clock", title: "Lock After") {
                                    Picker("", selection: $lockGracePeriodSeconds) {
                                        ForEach(LockGracePeriod.allCases) { option in
                                            Text(option.label).tag(option.rawValue)
                                        }
                                    }
                                    .labelsHidden()
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                        }
                        
                        CollapsibleSettingsSection(
                            title: "Tutorials",
                            icon: "graduationcap.fill",
                            iconColor: .indigo
                        ) {
                            SettingsRow(icon: "house.fill", title: "Home Screen Tutorial") {
                                Button("Redo") {
                                    hasSeenHomeTutorial = false
                                    showTutorialResetToast = true
                                }
                                .font(.subheadline.bold())
                            }
                            Divider()
                            SettingsRow(icon: "calendar", title: "Workout Calendar Tutorial") {
                                Button("Redo") {
                                    hasSeenCalendarTutorial = false
                                    showTutorialResetToast = true
                                }
                                .font(.subheadline.bold())
                            }
                            Divider()
                            SettingsRow(icon: "dumbbell.fill", title: "Workout Logging Tutorial") {
                                Button("Redo") {
                                    hasSeenCategoryDetailTutorial = false
                                    showTutorialResetToast = true
                                }
                                .font(.subheadline.bold())
                            }
                            Divider()
                            SettingsRow(icon: "list.bullet", title: "All Workouts Tutorial") {
                                Button("Redo") {
                                    hasSeenAllImportedTutorial = false
                                    showTutorialResetToast = true
                                }
                                .font(.subheadline.bold())
                            }
                            Divider()
                            SettingsRow(icon: "square.and.pencil", title: "Edit Workout Tutorial") {
                                Button("Redo") {
                                    hasSeenEditWorkoutTutorial = false
                                    showTutorialResetToast = true
                                }
                                .font(.subheadline.bold())
                            }
                            Divider()
                            SettingsRow(icon: "photo.on.rectangle", title: "Compare Photos Tutorial") {
                                Button("Redo") {
                                    hasSeenPhotoTutorial = false
                                    showTutorialResetToast = true
                                }
                                .font(.subheadline.bold())
                            }
                            Divider()
                            SettingsRow(icon: "target", title: "Set Goals Tutorial") {
                                Button("Redo") {
                                    hasSeenGoalTutorial = false
                                    showTutorialResetToast = true
                                }
                                .font(.subheadline.bold())
                            }
                            
                            Divider()
                            Button {
                                hasSeenHomeTutorial = false
                                hasSeenCalendarTutorial = false
                                hasSeenCategoryDetailTutorial = false
                                hasSeenAllImportedTutorial = false
                                hasSeenEditWorkoutTutorial = false
                                hasSeenGoalTutorial = false
                                hasSeenPhotoTutorial = false
                                showTutorialResetToast = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Redo All Tutorials")
                                    Spacer()
                                }
                                .foregroundStyle(.indigo)
                            }
                        }
                        
                        CollapsibleSettingsSection(
                            title: "Data",
                            icon: "externaldrive.fill",
                            iconColor: .gray
                        ) {
                            DataExportSection()
                            
                        }
                        
                        CollapsibleSettingsSection(
                            title: "Danger Zone",
                            icon: "exclamationmark.triangle.fill",
                            iconColor: .red
                        ) {
                            Button {
                                showDeletePhotosConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "photo.on.rectangle")
                                    Text("Delete all Photos")
                                    Spacer()
                                }
                                .foregroundStyle(.orange)
                            }
                            
                            Divider()
                            
                            Button {
                                showResetAccountConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "person.crop.circle.badge.xmark")
                                    
                                    Text("Reset App Setup")
                                    
                                    Spacer()
                                }
                                .foregroundStyle(.orange)
                            }
                            
                            Divider()
                            
                            Button(role: .destructive) {
                                showResetConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    
                                    Text("Reset Entire App")
                                    
                                    Spacer()
                                }
                            }
                        }
                        .confirmationDialog(
                            "Delete All Photos?",
                            isPresented: $showDeletePhotosConfirmation,
                            titleVisibility: .visible
                        ) {
                            Button("Delete All", role: .destructive) {
                                deleteAllPhotos()
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("This will permanently delete all photos saved in the app.")
                        }
                        .confirmationDialog(
                            "Reset Entire App?",
                            isPresented: $showResetConfirmation,
                            titleVisibility: .visible
                        ) {
                            Button("Reset Everything", role: .destructive) {
                                resetEntireApp()
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("This will delete all your workout data and settings. This cannot be undone.")
                        }
                        .confirmationDialog(
                            "Reset App Setup?",
                            isPresented: $showResetAccountConfirmation,
                            titleVisibility: .visible
                        ) {
                            Button("Reset Setup", role: .destructive) {
                                hasCompletedSetup = false
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("This will take you back through the initial setup screen.")
                        }
                    }
                    .padding()
                    // APP INFO
                    VStack(spacing: 6) {

                        Text("IronFox")
                            .font(.headline)
                        
                        // Change this to the actual webpage once published.
                        Link("Visit Webpage", destination: URL(string: "http://cameronfox.me/publishedapps/ironfox")!)

                        Text("Version \(appVersion)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)

                }
            }
            .overlay(alignment: .top) {
                if showTutorialResetToast {
                    Text("Tutorial will show next time you visit that screen")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                withAnimation(.spring()) {
                                    showTutorialResetToast = false
                                }
                            }
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                }
            }
            .toolbarBackground(gradientSettings.selectedPreset.topColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        .environmentObject(gradientSettings)
        .onChange(of: widgetUsesGradientBackground) { _, _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: weighInReminder) { _, newValue in
            if newValue {
                weighInWeeklyReminder = false
            }

            updateWeighInReminder()
        }

        .onChange(of: weighInWeeklyReminder) { _, newValue in
            if newValue {
                weighInReminder = false
            }

            updateWeeklyWeighInReminder()
        }
        .onChange(of: weighInWeeklyReminderTime) { _, _ in
            updateWeeklyWeighInReminder()
        }
        .onChange(of: weighInReminderTime) { _, _ in
            updateWeighInReminder()
        }
        .onChange(of: workoutData.entries.count) { _, _ in
            checkWorkoutMilestones()
        }
        .onChange(of: weeklyProgressPhotoReminder) { _, newValue in
            if newValue {
                // Turn off monthly when weekly turns on
                monthlyProgressPhotoReminder = false
                NotificationHandler.shared.removeNotification(identifier: "monthly_photo_reminder")
            }
            updateWeeklyPhotoReminder()
        }

        .onChange(of: monthlyProgressPhotoReminder) { _, newValue in
            if newValue {
                // Turn off weekly when monthly turns on
                weeklyProgressPhotoReminder = false
                NotificationHandler.shared.removeNotification(identifier: "weekly_photo_reminder")
            }
            updateMonthlyPhotoReminder()
        }

        .onChange(of: weeklyPhotoReminderTime) { _, _ in
            updateWeeklyPhotoReminder()
        }

        .onChange(of: weeklyPhotoReminderDay) { _, _ in
            updateWeeklyPhotoReminder()
        }

        .onChange(of: monthlyPhotoReminderTime) { _, _ in
            updateMonthlyPhotoReminder()
        }

        .onChange(of: monthlyPhotoReminderDay) { _, _ in
            updateMonthlyPhotoReminder()
        }

        .onChange(of: notificationsEnabled) { _, _ in
            updateWeighInReminder()
            updateWeeklyPhotoReminder()
            updateMonthlyPhotoReminder()
        }
        .onAppear {
            updateWeighInReminder()
            updateWeeklyWeighInReminder()
            checkWorkoutMilestones()
            updateWeeklyPhotoReminder()
            updateMonthlyPhotoReminder()
        }
    }
    
    private func convertAllDataToNewUnit(newSystem: UnitSystem) {
        let isNowMetric = newSystem == .metric

        // MARK: - Weight values
        if let w = Double(UserDefaults.standard.string(forKey: "userWeight") ?? "") {
            let converted = isNowMetric ? w / 2.20462 : w * 2.20462
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userWeight")
        }

        if let tw = Double(UserDefaults.standard.string(forKey: "userTargetWeight") ?? "") {
            let converted = isNowMetric ? tw / 2.20462 : tw * 2.20462
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userTargetWeight")
        }

        if let ow = Double(UserDefaults.standard.string(forKey: "userOriginalWeight") ?? "") {
            let converted = isNowMetric ? ow / 2.20462 : ow * 2.20462
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userOriginalWeight")
        }

        if let bw = Double(UserDefaults.standard.string(forKey: "userBaselineWeightForGoal") ?? "") {
            let converted = isNowMetric ? bw / 2.20462 : bw * 2.20462
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userBaselineWeightForGoal")
        }

        // MARK: - Height
        if let h = Double(UserDefaults.standard.string(forKey: "userHeight") ?? "") {
            let converted = isNowMetric ? h * 2.54 : h / 2.54
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userHeight")
        }

        // MARK: - Body measurements
        let measurementKeys = [
            "measureChest", "measureWaist", "measureHips",
            "measureBiceps", "measureThighs", "measureNeck",
            "measureCalves", "measureShoulders"
        ]
        for key in measurementKeys {
            if let val = Double(UserDefaults.standard.string(forKey: key) ?? "") {
                let converted = isNowMetric ? val * 2.54 : val / 2.54
                UserDefaults.standard.set(String(format: "%.1f", converted), forKey: key)
            }
        }

        // MARK: - Measurement history
        let historyKey = "measurementHistory"
        if let data = UserDefaults.standard.data(forKey: historyKey),
           var entries = try? JSONDecoder().decode([MeasurementEntry].self, from: data) {
            entries = entries.map { entry in
                var e = entry
                let convert: (Double?) -> Double? = { val in
                    guard let v = val else { return nil }
                    return isNowMetric ? v * 2.54 : v / 2.54
                }
                e.chest     = convert(e.chest)
                e.shoulders = convert(e.shoulders)
                e.waist     = convert(e.waist)
                e.hips      = convert(e.hips)
                e.biceps    = convert(e.biceps)
                e.thighs    = convert(e.thighs)
                e.neck      = convert(e.neck)
                e.calves    = convert(e.calves)
                return e
            }
            if let encoded = try? JSONEncoder().encode(entries) {
                UserDefaults.standard.set(encoded, forKey: historyKey)
            }
        }

        // MARK: - Workout entries (weight field)
        if let data = UserDefaults.standard.data(forKey: "workout_entries"),
           var entries = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            entries = entries.map { entry in
                var e = entry
                // Only convert weight for strength workouts, not distance cardio
                let isDistanceCardio = DistanceCardioWorkout.allCases.map(\.rawValue).contains(e.workoutType)
                if !isDistanceCardio, let w = Double(e.weight) {
                    let converted = isNowMetric ? w / 2.20462 : w * 2.20462
                    e.weight = String(format: "%.1f", converted)
                }
                // Convert distance for cardio (miles ↔ km)
                if isDistanceCardio, let d = Double(e.weight) {
                    let converted = isNowMetric ? d * 1.60934 : d / 1.60934
                    e.weight = String(format: "%.2f", converted)
                }
                return e
            }
            if let encoded = try? JSONEncoder().encode(entries) {
                UserDefaults.standard.set(encoded, forKey: "workout_entries")
            }
            workoutData.reload()
        }
    }
    
    private func updateWeeklyPhotoReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weekly_photo_reminder"])

        guard notificationsEnabled else { return }
        guard weeklyProgressPhotoReminder else { return }

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

        guard notificationsEnabled else { return }
        guard monthlyProgressPhotoReminder else { return }

        let reminderDate = Date(timeIntervalSince1970: monthlyPhotoReminderTime)
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)

        NotificationHandler.shared.scheduleMonthlyPhotoReminder(
            hour: components.hour ?? 8,
            minute: components.minute ?? 0,
            dayOfMonth: monthlyPhotoReminderDay
        )
    }
    
    var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }
    
    private func dayOfMonthLabel(_ day: Int) -> String {
        let suffix: String
        switch day {
        case 1, 21: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default:    suffix = "th"
        }
        return "\(day)\(suffix)"
    }
    
    // Function to delete all stored photos
    private func deleteAllPhotos() {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            let photos = files.filter { $0.pathExtension.lowercased() == "jpg" }
            for url in photos {
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Failed to delete photos: \(error)")
        }

        // Clear the AppStorage references so PhotoView doesn't try to reload missing files
        UserDefaults.standard.removeObject(forKey: "leftPhotoFileName")
        UserDefaults.standard.removeObject(forKey: "rightPhotoFileName")
    }
    
    // Helpers for completedMilestones
    private func getCompletedMilestones() -> Set<String> {
        (try? JSONDecoder().decode(Set<String>.self, from: completedMilestonesData)) ?? []
    }

    private func setCompletedMilestones(_ value: Set<String>) {
        completedMilestonesData = (try? JSONEncoder().encode(value)) ?? Data()
    }

    private func checkWorkoutMilestones() {
        guard milesstoneReminder && notificationsEnabled else { return }

        let workoutCount = workoutData.entries.count
        let workoutImportedMilestones = [5, 10, 25, 50, 100, 250, 500]
        let daysWorkedOutMilestones = [7, 14, 30, 60, 90, 180, 365, 500, 1000]

        var completed = getCompletedMilestones()

        // MARK: Workout Count Milestones
        for milestone in workoutImportedMilestones {

            let key = "workout_\(milestone)"

            if workoutCount >= milestone &&
                !completed.contains(key) {

                completed.insert(key)

                NotificationHandler.shared.sendInstantNotification(
                    title: "Milestone Reached",
                    body: "You completed \(milestone) workouts!"
                )
            }
        }

        // MARK: Days Worked Out Milestones

        let uniqueWorkoutDays = Set(
            workoutData.entries.map {
                Calendar.current.startOfDay(for: $0.date)
            }
        ).count

        for milestone in daysWorkedOutMilestones {

            let key = "days_\(milestone)"

            if uniqueWorkoutDays >= milestone &&
                !completed.contains(key) {

                completed.insert(key)

                NotificationHandler.shared.sendInstantNotification(
                    title: "Consistency Milestone",
                    body: "You have worked out on \(milestone) different days!"
                )
            }
        }

        setCompletedMilestones(completed)
        workoutData.loadMilestones()
    }
    
    private func updateWeighInReminder() {

        let center = UNUserNotificationCenter.current()

        // Remove old reminder first
        center.removePendingNotificationRequests(
            withIdentifiers: ["daily_weigh_in"]
        )

        // If turned off, stop here
        guard notificationsEnabled else { return }
        guard weighInReminder else { return }

        let reminderDate =
        Date(timeIntervalSince1970: weighInReminderTime)

        let components =
        Calendar.current.dateComponents(
            [.hour, .minute],
            from: reminderDate
        )

        NotificationHandler.shared.scheduleDailyWeighInNotification(
            hour: components.hour ?? 8,
            minute: components.minute ?? 0
        )
    }
    
    private func updateWeeklyWeighInReminder() {
        let center = UNUserNotificationCenter.current()
        
        // Remove old reminder first
        center.removePendingNotificationRequests(withIdentifiers: ["weekly_weigh_in"])
        // If turned off, stop here
        guard notificationsEnabled else { return }
        guard weighInWeeklyReminder else { return }
        
        let reminderDate =
        Date(timeIntervalSince1970: weighInWeeklyReminderTime)
        
        let components =
        Calendar.current.dateComponents(
            [.hour, .minute],
            from: reminderDate
        )
        
        NotificationHandler.shared.scheduleWeeklyWeighInNotification(
            hour: components.hour ?? 8,
            minute: components.minute ?? 0,
            weekday: weeklyWeighInDay,
            identifier: "weekly_weigh_in"
        )
    }

    //This Function will reset the entire app and delete all data.
    private func resetEntireApp() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        workoutData.entries.removeAll()
        UserDefaults.standard.set(false, forKey: "hasCompletedSetup")
        hasCompletedSetup = false
    }
}

struct CollapsibleSettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @State private var isExpanded: Bool = false
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.title3)
                        .frame(width: 28)
                        .foregroundStyle(iconColor)

                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                .padding()
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 16) {
                    content
                }
                .padding([.horizontal, .bottom])
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct SettingsCard<Content: View>: View {

    let title: String
    @ViewBuilder let content: Content

    var body: some View {

        VStack(alignment: .leading, spacing: 14) {

            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 16) {
                content
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
            )
        }
    }
}

struct SettingsRow<Content: View>: View {

    let icon: String
    let title: String

    @ViewBuilder let trailing: Content

    var body: some View {

        HStack(spacing: 14) {

            Image(systemName: icon)
                .font(.title3)
                .frame(width: 28)
                .foregroundStyle(.blue)

            Text(title)
                .font(.body)

            Spacer()

            trailing
        }
    }
}

// Function to get the apps version
private var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
}

#Preview {
    SettingsView()
        .environmentObject(WorkoutData())
        .environmentObject(GradientSettings())
}

