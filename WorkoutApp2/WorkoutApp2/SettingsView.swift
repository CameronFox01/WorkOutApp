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
    
    @State private var showResetConfirmation = false
    
    var body: some View {
        //Text("Settings View")
        NavigationView{
            VStack{
                Form {
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
                .navigationTitle("Settings")
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

#Preview {
    SettingsView()
}
