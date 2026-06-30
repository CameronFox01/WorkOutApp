//
//  CalendarCard.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/28/26.
//


import SwiftUI

struct CalendarCard: View {
    @EnvironmentObject var workoutData: WorkoutData
    @EnvironmentObject var gradientSettings: GradientSettings
    @AppStorage("showStepsCard") private var showStepsCard: Bool = true

    private var calendar: Calendar { .current }

    private var workoutsThisWeek: Int {
        guard let weekStart = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        ) else { return 0 }

        return Set(
            workoutData.entries
                .filter { $0.date >= weekStart }
                .map { calendar.startOfDay(for: $0.date) }
        ).count
    }

    private var currentStreak: Int {
        let workoutDays = Set(workoutData.entries.map { calendar.startOfDay(for: $0.date) })
        let today = calendar.startOfDay(for: Date())

        var streak = 0
        if workoutDays.contains(today) { streak += 1 }

        var day = calendar.date(byAdding: .day, value: -1, to: today)!
        while workoutDays.contains(day) {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }

    private var lastWorkoutDate: String {
        guard let last = workoutData.entries.sorted(by: { $0.date > $1.date }).first else {
            return "—"
        }
        return last.date.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        if showStepsCard {
            compactCard
        } else {
            expandedCard
        }
    }

    // MARK: - Compact (half-width, steps card showing)

    private var compactCard: some View {
        NavigationLink(destination: WorkoutCalendarView(
            entries: workoutData.entries,
            comingFromWidget: false
        )) {
            VStack(alignment: .leading) {
                Text("Calendar")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .center)

                WorkoutHeatMapView(entries: workoutData.entries)
                    .frame(height: 80)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .cardStyle()
    }

    // MARK: - Expanded (full-width, steps card hidden)

    private var expandedCard: some View {
        NavigationLink(destination: WorkoutCalendarView(
            entries: workoutData.entries,
            comingFromWidget: false
        )) {
            VStack(alignment: .leading, spacing: 18) {

                // Top row
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calendar")
                            .font(.title2.bold())
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                        Text("Activity")
                            .font(.caption)
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.7))
                    }
                    .padding(.leading, 20)

                    Spacer()

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(currentStreak)")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                        Text("day streak")
                            .font(.title3)
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                    }
                    .padding(.trailing, 10)
                }

                Divider()
                    .overlay(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.3))

                // Stat row
                HStack(spacing: 0) {
                    statBlock(
                        icon: "calendar.badge.checkmark",
                        label: "This Week",
                        value: "\(workoutsThisWeek)"
                    )

                    Divider()
                        .frame(height: 36)
                        .overlay(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.3))

                    statBlock(
                        icon: "dumbbell.fill",
                        label: "Total Logged",
                        value: "\(workoutData.entries.count)"
                    )

                    Divider()
                        .frame(height: 36)
                        .overlay(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.3))

                    statBlock(
                        icon: "clock.arrow.circlepath",
                        label: "Last Workout",
                        value: lastWorkoutDate
                    )
                }

                // Bigger heat map
                WorkoutHeatMapView(entries: workoutData.entries)
                    .frame(height: 130)
                    .padding(.top, 4)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .cardStyle()
    }

    private func statBlock(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.7))
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
            Text(label)
                .font(.caption2)
                .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - CalendarCard Preview

#Preview("Calendar Card") {
    let _: [WorkoutEntry] = [
        WorkoutEntry(workoutType: "Bench Press", weight: "135", reps: "8", sets: "3", date: .now, note: ""),
        WorkoutEntry(workoutType: "Squat", weight: "185", reps: "5", sets: "5", date: .now.addingTimeInterval(-86400), note: "")
    ]

    return ZStack {
        LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

        NavigationStack {
            CalendarCard()
                .environmentObject(GradientSettings())
                .environmentObject(WorkoutData())
                .padding()
        }
    }
}
