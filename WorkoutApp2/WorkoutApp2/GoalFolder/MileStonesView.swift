//
//  MileStonesView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/3/26.
//
import SwiftUI

struct MilestonesView: View {
    let milestones: [Milestone]
    let comingfromWidget: Bool
    
    @EnvironmentObject var router: AppRouter
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings

    private var workoutMilestones: [Milestone] {
        milestones.filter { !$0.title.hasSuffix("Workout Days") }
    }

    private var dayMilestones: [Milestone] {
        milestones.filter { $0.title.hasSuffix("Workout Days") }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientSettings.selectedPreset.swiftUIColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("Milestones")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)

                    if milestones.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No milestones reached yet — keep going!")
                                .foregroundStyle(.secondary)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 240)
                        .padding()
                    } else {

                        // MARK: - Workouts Section
                        if !workoutMilestones.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "dumbbell.fill")
                                        .foregroundStyle(.orange)
                                    Text("Workouts Logged")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                }
                                .padding(.horizontal)

                                VStack(spacing: 12) {
                                    ForEach(workoutMilestones) { milestone in
                                        MilestoneRow(
                                            milestone: milestone,
                                            iconColor: .orange,
                                            accentColor: .orange
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // MARK: - Days Section
                        if !dayMilestones.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                        .foregroundStyle(.cyan)
                                    Text("Days Worked Out")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                }
                                .padding(.horizontal)

                                VStack(spacing: 12) {
                                    ForEach(dayMilestones) { milestone in
                                        MilestoneRow(
                                            milestone: milestone,
                                            iconColor: .cyan,
                                            accentColor: .cyan
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(gradientSettings.selectedPreset.topColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            if comingfromWidget {
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        router.activeScreen = nil
                    } label:{
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Milestones")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Reusable Row
private struct MilestoneRow: View {
    let milestone: Milestone
    let iconColor: Color
    let accentColor: Color

    var body: some View {
        HStack {
            Image(systemName: milestone.icon)
                .font(.title2)
                .foregroundStyle(iconColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(milestone.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
