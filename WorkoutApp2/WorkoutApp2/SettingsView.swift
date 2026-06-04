//
//  SettingsView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/20/26.
//
// The purpose of this View is to allow users to set their settings to make the app behave the way they would like the app to behave

import SwiftUI
import Foundation

struct SettingsView: View {
    @EnvironmentObject var workoutData: WorkoutData

    //Flags being Imported to this View
    @AppStorage("saveButtonAction") private var GoToHomeScreenWhenSaved: Bool = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = true
    @AppStorage("SaveToPhotosApp") private var saveToPhoto: Bool = true
    @AppStorage("showStopWatch") private var showStopWatch: Bool = true
    @AppStorage("numberOfWorkoutsToShow") private var numberOfWorkoutsToShow: Int = 12

    @State private var showResetConfirmation = false
    @State private var showResetAccountConfirmation = false
    
    @State private var showDeletePhotosConfirmation = false

    // Keyboard focus
    @FocusState private var workoutsFieldFocused: Bool
    
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
    
    @AppStorage("weeklyWeighInDay")
    private var weeklyWeighInDay: Int = 1
    
    // Notification Milestones Section
    @AppStorage("completedMilestonesData")
    private var completedMilestonesData: Data = Data()
    //Notification settings for milestones to be sent
    @AppStorage("milestonesReminder") private var milesstoneReminder: Bool = true

    //Notification for Goals Section
    @AppStorage("goalReminder") private var goalReminder: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack{
                LinearGradient(
                    colors: [
                        Color.blue.opacity(1.0),
                        Color.cyan.opacity(0.6),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack {
                    ScrollView {
                        VStack(spacing: 20) {

                            // DISPLAY SECTION
                            SettingsCard(title: "Home Screen") {

                                SettingsRow(
                                    icon: "rectangle.grid.2x2.fill",
                                    title: "Recent Workouts"
                                ) {
                                    TextField(
                                        "12",
                                        value: $numberOfWorkoutsToShow,
                                        format: .number
                                    )
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 50)
                                    .focused($workoutsFieldFocused)
                                }

                                Divider()

                                SettingsRow(
                                    icon: "timer",
                                    title: "Show Stopwatch"
                                ) {
                                    Toggle("", isOn: $showStopWatch)
                                        .labelsHidden()
                                }
                            }

                            // IMPORT SECTION
                            SettingsCard(title: "Import Settings") {

                                SettingsRow(
                                    icon: "square.and.arrow.down",
                                    title: "Return Home After Import"
                                ) {
                                    Toggle("", isOn: $GoToHomeScreenWhenSaved)
                                        .labelsHidden()
                                }

                                Divider()

                                SettingsRow(
                                    icon: "photo.on.rectangle",
                                    title: "Save to Photos App"
                                ) {
                                    Toggle("", isOn: $saveToPhoto)
                                        .labelsHidden()
                                }
                            }
                            
                            //Notification
                            SettingsCard(title: "Notifications") {
                                
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
                                    
                                    //Notification Section
                                    Divider()
                                    
                                    Text("Weight Settings")
                                        .font(.title2).bold()
                                        .padding(.top, 16)
                                        .padding(.bottom, 0)
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
                                                        title: "Reminder Time"
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
                                                    title: "Reminder Time"
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
                                }
                            }

                            // RESET SECTION
                            SettingsCard(title: "Danger Zone") {
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

                            // APP INFO
                            VStack(spacing: 6) {

                                Text("MyStep")
                                    .font(.headline)

                                Text("Version \(appVersion)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                        }
                        .padding()
                    }
                    .scrollIndicators(.hidden)
                    
                    .toolbar {
                        
                        ToolbarItem(placement: .principal) {
                            Text("Settings")
                                .font(.largeTitle).bold()
                                .foregroundStyle(.white)
                        }
                        
                        // Keyboard toolbar
                        ToolbarItemGroup(placement: .keyboard) {
                            
                            Spacer()
                            
                            Button("Done") {
                                workoutsFieldFocused = false
                            }
                        }
                    }
                    
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color.blue, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                }
            }
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
        .onChange(of: notificationsEnabled) { _, _ in
            updateWeighInReminder()
        }
        .onChange(of: workoutData.entries.count) { _, _ in
            checkWorkoutMilestones()
        }
        .onAppear {
            updateWeighInReminder()
            updateWeeklyWeighInReminder()
            checkWorkoutMilestones()
        }
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
        let milestones = [1, 5, 10, 25, 50, 100, 250, 500]
        var completed = getCompletedMilestones()

        for milestone in milestones {
            let key = "workout_\(milestone)"
            if workoutCount >= milestone && !completed.contains(key) {
                completed.insert(key)
                setCompletedMilestones(completed)
                NotificationHandler.shared.sendInstantNotification(
                    title: "Milestone Reached 🎉",
                    body: "You completed \(milestone) workouts!"
                )
            }
        }
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
}

