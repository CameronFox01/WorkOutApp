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
    @EnvironmentObject var gradientSettings: GradientSettings

    @AppStorage("widgetUsesGradientBackground", store: UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2"))
    private var widgetUsesGradientBackground: Bool = false

    @AppStorage("milestonesReminder") private var milesstoneReminder: Bool = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("completedMilestonesData") private var completedMilestonesData: Data = Data()

    @State private var showTutorialResetToast = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientSettings.selectedPreset.swiftUIColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    HomeScreenSettingsSection()
                    CalculatorSettingsSection()
                    ImportSettingsSection()
                    UnitsSettingsSection()
                    WeightGoalSettingsSection()
                    NotificationsSettingsSection()
                    BackgroundSettingsSection()
                    SecuritySettingsSection()
                    TutorialsSettingsSection(showTutorialResetToast: $showTutorialResetToast)
                    DataSettingsSection()
                    DangerZoneSettingsSection()
                }
                .padding()

                VStack(spacing: 6) {
                    Text("IronFox").font(.headline)
                    Link("Visit Webpage", destination: URL(string: "http://cameronfox.me/publishedapps/ironfox")!)
                    Text("Version \(appVersion)")
                        .font(.footnote)
                        .foregroundStyle(.primary)
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
        .toolbar {
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
        .onChange(of: workoutData.entries.count) { _, _ in
            checkWorkoutMilestones()
        }
        .onAppear {
            checkWorkoutMilestones()
        }
    }

    private func getCompletedMilestones() -> Set<String> {
        (try? JSONDecoder().decode(Set<String>.self, from: completedMilestonesData)) ?? []
    }

    private func setCompletedMilestones(_ value: Set<String>) {
        completedMilestonesData = (try? JSONEncoder().encode(value)) ?? Data()
    }

    private func checkWorkoutMilestones() {
        guard milesstoneReminder && notificationsEnabled else { return }

        let workoutCount = workoutData.entries.count
        let workoutImportedMilestones = [5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 25000, 50000]
        let daysWorkedOutMilestones = [7, 14, 30, 60, 90, 180, 365, 500, 1000, 1500, 2000, 2500]

        var completed = getCompletedMilestones()

        for milestone in workoutImportedMilestones {
            let key = "workout_\(milestone)"
            if workoutCount >= milestone && !completed.contains(key) {
                completed.insert(key)
                NotificationHandler.shared.sendInstantNotification(
                    title: "Milestone Reached",
                    body: "You completed \(milestone) workouts!"
                )
            }
        }

        let uniqueWorkoutDays = Set(
            workoutData.entries.map { Calendar.current.startOfDay(for: $0.date) }
        ).count

        for milestone in daysWorkedOutMilestones {
            let key = "days_\(milestone)"
            if uniqueWorkoutDays >= milestone && !completed.contains(key) {
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
}

private var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
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

#Preview {
    SettingsView()
        .environmentObject(WorkoutData())
        .environmentObject(GradientSettings())
}

