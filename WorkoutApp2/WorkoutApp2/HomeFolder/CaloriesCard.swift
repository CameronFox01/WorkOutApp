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

    var body: some View {
        NavigationLink(destination: CaloriesDetailView(unitSystem: Hmanager.unitSystem)
            .environmentObject(Hmanager)
        ) {
            VStack(alignment: .center, spacing: 8) {
                Text("Calories Today")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .center)

                if Hmanager.activeCalories == 0 {
                    Text("\(Int(Double(Hmanager.steps) * 0.04)) \(energyLabel)")
                        .font(.title2).bold()
                } else {
                    Text("\(Int(Hmanager.activeCalories)) \(energyLabel)")
                        .font(.title2).bold()
                }

                if !Hmanager.lastFiveDaysCalories.isEmpty {
                    FiveDayCaloriesBarChart(data: Hmanager.lastFiveDaysCalories, comingFromDetail: false)
                        .frame(height: 60)
                        .padding(.top, 4)

                    HStack {
                        Text("5-day avg:")
                            .font(.caption)
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                        Text("\(Hmanager.fiveDayAverageCalories)")
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
}