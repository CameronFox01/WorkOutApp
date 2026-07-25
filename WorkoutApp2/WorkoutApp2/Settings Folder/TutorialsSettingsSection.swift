//
//  TutorialsSettingsSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/24/26.
//
import SwiftUI
import Foundation
import WidgetKit

struct TutorialsSettingsSection: View {
    @Binding var showTutorialResetToast: Bool

    @AppStorage("hasSeenHomeTutorial") private var hasSeenHomeTutorial: Bool = false
    @AppStorage("hasSeenCalendarTutorial") private var hasSeenCalendarTutorial: Bool = false
    @AppStorage("hasSeenCategoryDetailTutorial") private var hasSeenCategoryDetailTutorial: Bool = false
    @AppStorage("hasSeenAllImportedTutorial") private var hasSeenAllImportedTutorial: Bool = false
    @AppStorage("hasSeenEditWorkoutTutorial") private var hasSeenEditWorkoutTutorial: Bool = false
    @AppStorage("hasSeenPhotoTutorial") private var hasSeenPhotoTutorial: Bool = false
    @AppStorage("hasSeenGoalTutorial") private var hasSeenGoalTutorial: Bool = false

    var body: some View {
        CollapsibleSettingsSection(
            title: "Tutorials",
            icon: "graduationcap.fill",
            iconColor: .indigo
        ) {
            row(icon: "house.fill", title: "Home Screen Tutorial") { hasSeenHomeTutorial = false }
            Divider()
            row(icon: "calendar", title: "Workout Calendar Tutorial") { hasSeenCalendarTutorial = false }
            Divider()
            row(icon: "dumbbell.fill", title: "Workout Logging Tutorial") { hasSeenCategoryDetailTutorial = false }
            Divider()
            row(icon: "list.bullet", title: "All Workouts Tutorial") { hasSeenAllImportedTutorial = false }
            Divider()
            row(icon: "square.and.pencil", title: "Edit Workout Tutorial") { hasSeenEditWorkoutTutorial = false }
            Divider()
            row(icon: "photo.on.rectangle", title: "Compare Photos Tutorial") { hasSeenPhotoTutorial = false }
            Divider()
            row(icon: "target", title: "Set Goals Tutorial") { hasSeenGoalTutorial = false }

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
    }

    private func row(icon: String, title: String, reset: @escaping () -> Void) -> some View {
        SettingsRow(icon: icon, title: title) {
            Button("Redo") {
                reset()
                showTutorialResetToast = true
            }
            .font(.subheadline.bold())
        }
    }
}
