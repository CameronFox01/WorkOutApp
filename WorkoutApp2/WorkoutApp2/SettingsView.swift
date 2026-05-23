//
//  SettingsView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/20/26.
//
// The purpose of this View is to allow users to set their settings to make the app behave the way they would like the app to behave

import SwiftUI

struct SettingsView: View {
    //Flags being Imorted to this View
    @AppStorage("saveButtonAction") private var GoToHomeScreenWhenSaved: Bool = false
    
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = true
    
    @AppStorage("SaveToPhotosApp") private var saveToPhoto: Bool = true
    
    @AppStorage("showStopWatch") private var showStopWatch: Bool = true
    
    @State private var showResetConfirmation = false
    
    @State private var showResetAccountConfirmation = false
    
    var body: some View {
        //Text("Settings View")
        NavigationView{
            VStack{
                Form {
                    //Section as to what to display in home view for the Timer
                    Section(header: Text("Setting to display either Stop Watch or Count Down")){
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
                    Section(header: Text("Where to Save Photos")){
                        Picker("How to Save New Photos", selection: $saveToPhoto) {
                            Text("Save to Photos Library and MyStep").tag(true)
                            Text("Save to just MyStep").tag(false)
                        }
                    }
                    
                    // Delete this by the end. This is great for testing
                    Button{
                        showResetAccountConfirmation = true
                    } label: {
                        Text("Reset App Setup")
                    }
                    // No confirmation because I dont want to use AI in front of a TA.
                    .confirmationDialog("Reset Account only", isPresented: $showResetAccountConfirmation, titleVisibility: .visible){
                        Button("Reset the account but save the data"){
                            hasCompletedSetup = false
                        }
                        Button("Cancel", role: .cancel){}
                    } message: {
                        Text("This will clear account information and return you to the setup form.")
                    }
                   
                    
                    //Section to reset the entire app.
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Text("Reset App")
                    }
                    .confirmationDialog("Reset the app?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                        Button("Reset and Restart Setup", role: .destructive) {
                            resetEntireApp()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("This will clear all saved settings and return you to the initial setup.")
                    }
                } //End of Form
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.blue, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Settings")
                            .font(.largeTitle).bold()
                            .foregroundStyle(.white)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .safeAreaInset(edge: .bottom) {
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
            } // End of VStack
        } // End of Navigation View
        
    }
    //This Function will reset the entire app and delete all data.
    private func resetEntireApp(){
        // TODO delete all of the data that is being stored including the photo stored for the user.
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
