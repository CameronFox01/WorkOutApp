//
//  DangerZoneSettingsSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/24/26.
//
import SwiftUI
import Foundation
import WidgetKit

struct DangerZoneSettingsSection: View {
    @EnvironmentObject var workoutData: WorkoutData
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = true

    @State private var showDeletePhotosConfirmation = false
    @State private var showResetConfirmation = false
    @State private var showResetAccountConfirmation = false

    var body: some View {
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
            Button("Delete All", role: .destructive) { deleteAllPhotos() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all photos saved in the app.")
        }
        .confirmationDialog(
            "Reset Entire App?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Everything", role: .destructive) { resetEntireApp() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will delete all your workout data and settings. This cannot be undone.")
        }
        .confirmationDialog(
            "Reset App Setup?",
            isPresented: $showResetAccountConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Setup", role: .destructive) { hasCompletedSetup = false }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will take you back through the initial setup screen.")
        }
    }

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
        UserDefaults.standard.removeObject(forKey: "leftPhotoFileName")
        UserDefaults.standard.removeObject(forKey: "rightPhotoFileName")
    }

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
