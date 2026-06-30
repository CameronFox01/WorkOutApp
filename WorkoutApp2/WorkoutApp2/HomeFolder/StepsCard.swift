//
//  StepsCard.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/28/26.
//


import SwiftUI

struct StepsCard: View {
    @EnvironmentObject var Hmanager: HealthManager
    @EnvironmentObject var gradientSettings: GradientSettings
    @AppStorage("showCalendarCard") private var showCalendarCard: Bool = true

    var body: some View {
        if showCalendarCard {
            compactCard
        } else {
            expandedCard
        }
    }

    // MARK: - Compact (half-width, calendar card showing)

    private var compactCard: some View {
        NavigationLink(destination: DistanceDetailView(unitSystem: Hmanager.unitSystem)
            .environmentObject(Hmanager)
        ) {
            VStack(alignment: .center, spacing: 8) {
                Text("Steps Today")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("\(Hmanager.steps)")
                    .font(.title2).bold()

                if !Hmanager.getLastFiveDaysSteps.isEmpty {
                    FiveDayStepsBarChart(data: Hmanager.getLastFiveDaysSteps)
                        .frame(height: 60)
                        .padding(.top, 4)

                    HStack {
                        Text("5-day avg:")
                            .font(.caption)
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                        Text("\(Hmanager.fiveDayAverageSteps)")
                            .font(.caption).bold()
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                    }
                } else {
                    Text("5-day history unavailable")
                        .font(.caption)
                        .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                }
            }
        }
        .buttonStyle(.plain)
        .cardStyle()
    }

    // MARK: - Expanded (full-width, calendar card hidden)

    private var expandedCard: some View {
        NavigationLink(destination: DistanceDetailView(unitSystem: Hmanager.unitSystem)
            .environmentObject(Hmanager)
        ) {
            VStack(alignment: .leading, spacing: 18) {

                // Top row: title + today's total
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Steps")
                            .font(.title2.bold())
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                        Text("Today")
                            .font(.caption)
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.7))
                    }
                    .padding(.leading, 20)

                    Spacer()

                    Text("\(Hmanager.steps)")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                        .padding(.trailing, 10)
                }

                Divider()
                    .overlay(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.3))

                // Stat row
                HStack(spacing: 0) {
                    statBlock(
                        icon: "chart.bar.fill",
                        label: "5-day avg",
                        value: "\(Hmanager.fiveDayAverageSteps)"
                    )

                    Divider()
                        .frame(height: 36)
                        .overlay(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.3))

                    statBlock(
                        icon: "flame.fill",
                        label: "Calories Est.",
                        value: "\(Int(Double(Hmanager.steps) * 0.04))"
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
                if !Hmanager.getLastFiveDaysSteps.isEmpty {
                    FiveDayStepsBarChart(data: Hmanager.getLastFiveDaysSteps)
                        .frame(height: 110)
                        .padding(.top, 4)
                } else {
                    Text("5-day history unavailable")
                        .font(.caption)
                        .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                        .padding(.leading, 20)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .cardStyle()
    }

    private var vsAverageText: String? {
        let avg = Hmanager.fiveDayAverageSteps
        guard avg > 0 else { return nil }
        let diff = Hmanager.steps - avg
        let pct = Int((Double(diff) / Double(avg)) * 100)
        return pct == 0 ? "On par" : "\(pct > 0 ? "+" : "")\(pct)%"
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

// MARK: - StepsCard Preview

#Preview("Steps Card") {
    ZStack {
        LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

        NavigationStack {
            StepsCard()
                .environmentObject(GradientSettings())
                .environmentObject(HealthManager())
                .padding()
        }
    }
}
