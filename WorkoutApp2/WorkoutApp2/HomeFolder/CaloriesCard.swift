//
//  CaloriesCard.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/28/26.
//


import SwiftUI

struct CaloriesCard: View {
    @EnvironmentObject var Hmanager: HealthManager
    @EnvironmentObject var gradientSettings: GradientSettings
    @AppStorage("energyLabel") private var energyLabel: String = "Calories"
    @AppStorage("showWeightCard") private var showWeightCard: Bool = true

    private var todayCalories: Int {
        Hmanager.activeCalories == 0
            ? Int(Double(Hmanager.steps) * 0.04)
            : Int(Hmanager.activeCalories)
    }

    private var weeklyAverage: Int {
        Hmanager.fiveDayAverageCalories
    }

    private var vsAverageText: String? {
        guard weeklyAverage > 0 else { return nil }
        let diff = todayCalories - weeklyAverage
        let pct = Int((Double(diff) / Double(weeklyAverage)) * 100)
        return pct == 0 ? "On par with average" : "\(pct > 0 ? "+" : "")\(pct)% vs average"
    }

    var body: some View {
        if showWeightCard {
            compactCard
        } else {
            expandedCard
        }
    }

    // MARK: - Compact (half-width, weight card showing)

    private var compactCard: some View {
        NavigationLink(destination: CaloriesDetailView(unitSystem: Hmanager.unitSystem)
            .environmentObject(Hmanager)
        ) {
            VStack(alignment: .center, spacing: 8) {
                Text("Calories Today")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("\(todayCalories) \(energyLabel)")
                    .font(.title2).bold()

                if !Hmanager.lastFiveDaysCalories.isEmpty {
                    FiveDayCaloriesBarChart(data: Hmanager.lastFiveDaysCalories, comingFromDetail: false)
                        .frame(height: 60)
                        .padding(.top, 4)

                    HStack {
                        Text("5-day avg:")
                            .font(.caption)
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                        Text("\(weeklyAverage)")
                            .font(.caption).bold()
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                    }
                } else {
                    Text("5-day history unavailable")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .cardStyle()
        .buttonStyle(.plain)
    }

    // MARK: - Expanded (full-width, weight card hidden)

    private var expandedCard: some View {
        NavigationLink(destination: CaloriesDetailView(unitSystem: Hmanager.unitSystem)
            .environmentObject(Hmanager)
        ) {
            VStack(alignment: .leading, spacing: 18) {

                // Top row: title + today's total
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calories")
                            .font(.title2.bold())
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                        Text("Today")
                            .font(.caption)
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.7))
                    }
                    .padding(.leading, 20)

                    Spacer()

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(todayCalories)")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                        Text(energyLabel)
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
                        icon: "chart.bar.fill",
                        label: "5-day avg",
                        value: "\(weeklyAverage)"
                    )

                    Divider()
                        .frame(height: 36)
                        .overlay(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.3))

                    statBlock(
                        icon: "figure.walk",
                        label: "Steps Today",
                        value: "\(Hmanager.steps)"
                    )

                    Divider()
                        .frame(height: 36)
                        .overlay(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.3))

                    statBlock(
                        icon: "arrow.up.arrow.down",
                        label: "vs Average",
                        value: vsAverageText ?? "—"
                    )
                }

                // Bigger chart
                if !Hmanager.lastFiveDaysCalories.isEmpty {
                    FiveDayCaloriesBarChart(data: Hmanager.lastFiveDaysCalories, comingFromDetail: false)
                        .frame(height: 110)
                        .padding(.top, 4)
                } else {
                    Text("5-day history unavailable")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 20)
                }
            }
            .padding(.vertical, 4)
        }
        .cardStyle()
        .buttonStyle(.plain)
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

// MARK: - CaloriesCard Preview

#Preview("Calories Card") {
    ZStack {
        LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

        NavigationStack {
            CaloriesCard()
                .environmentObject(GradientSettings())
                .environmentObject(HealthManager())
                .padding()
        }
    }
}
