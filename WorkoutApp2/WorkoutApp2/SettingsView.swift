//
//  SettingsView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/20/26.
//
// The purpose of this View is to allow users to set their settings to make the app behave the way they would like the app to behave

import SwiftUI

struct SettingsView: View {

    //Flags being Imported to this View
    @AppStorage("saveButtonAction") private var GoToHomeScreenWhenSaved: Bool = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = true
    @AppStorage("SaveToPhotosApp") private var saveToPhoto: Bool = true
    @AppStorage("showStopWatch") private var showStopWatch: Bool = true
    @AppStorage("numberOfWorkoutsToShow") private var numberOfWorkoutsToShow: Int = 12

    @State private var showResetConfirmation = false
    @State private var showResetAccountConfirmation = false

    // Keyboard focus
    @FocusState private var workoutsFieldFocused: Bool

    var body: some View {

        NavigationView {
            VStack {
                Form {

                    //How many workouts to show in the Home tab
                    Section(header: Text("How many workouts to show in Recent Workouts")) {

                        TextField(
                            "12",
                            value: $numberOfWorkoutsToShow,
                            format: .number
                        )
                        .keyboardType(.numberPad)
                        .focused($workoutsFieldFocused)
                    }

                    //Section as to what to display in home view for the Timer
                    Section(header: Text("Setting to display either Stop Watch or Count Down")) {
                        Picker("Display Stop Watch or Count Down", selection: $showStopWatch) {
                            Text("Show Stop Watch").tag(true)
                            Text("Show Count Down").tag(false)
                        }
                    }

                    //Section to decide how to react when Save Import Button is pressed.
                    Section(header: Text("Settings How to Save when Importing")) {
                        Picker("How to Save when Importing", selection: $GoToHomeScreenWhenSaved) {
                            Text("Go to Home Screen after Import").tag(true)
                            Text("Keep in Current screen after Import").tag(false)
                        }
                    }

                    //Section to decide where the photos taken in app should be saved.
                    Section(header: Text("Where to Save Photos")) {
                        Picker("How to Save New Photos", selection: $saveToPhoto) {
                            Text("Save to Photos Library and MyStep").tag(true)
                            Text("Save to just MyStep").tag(false)
                        }
                    }

                    Button {
                        showResetAccountConfirmation = true
                    } label: {
                        Text("Reset App Setup")
                    }
                    .confirmationDialog(
                        "Reset Account only",
                        isPresented: $showResetAccountConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Reset the account but save the data") {
                            hasCompletedSetup = false
                        }

                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This will clear account information and return you to the setup form.")
                    }

                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Text("Reset App")
                    }
                    .confirmationDialog(
                        "Reset the app?",
                        isPresented: $showResetConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Reset and Restart Setup", role: .destructive) {
                            resetEntireApp()
                        }

                        Button("Cancel", role: .cancel) { }

                    } message: {
                        Text("This will clear all saved settings and return you to the initial setup.")
                    }
                    
                    Section(){
                        VStack(spacing: 4) {

                            Text("MyStep")
                                .font(.headline)

                            Text("Version \(appVersion)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGroupedBackground))
                    }
                    .listRowBackground(Color(.systemGroupedBackground))
                }

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

    //This Function will reset the entire app and delete all data.
    private func resetEntireApp() {

        if let bundleID = Bundle.main.bundleIdentifier {

            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }

        UserDefaults.standard.set(false, forKey: "hasCompletedSetup")
        hasCompletedSetup = false
    }
}

// Function to get the apps version
private var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
}
#Preview {
    SettingsView()
}
