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

    var body: some View {
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
}