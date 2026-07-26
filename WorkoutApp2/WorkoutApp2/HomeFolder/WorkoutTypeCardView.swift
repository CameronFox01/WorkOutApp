//
//  WorkoutTypeCardView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/8/26.
//
import SwiftUI
import Foundation

struct WorkoutTypeCardView: View {
    @EnvironmentObject var gradientSettings: GradientSettings
    
    let entry: WorkoutEntry
    let weightUnit: String
    let category: WorkoutCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {

                    Text(entry.workoutType)
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                    

                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 42, height: 42)

                    Image(systemName: cardIcon)
                        .foregroundStyle(.white)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 6) {

                switch category {
                  case .distanceCardio:
                      Label(
                          "\(entry.weight) \(distanceUnit)",
                          systemImage: "figure.walk"
                      )

                  case .timeCardio, .sports, .recovery:
                      Label(
                          "\(entry.reps) min",
                          systemImage: "timer"
                      )

                  default:
                      Label(
                          "\(entry.reps) reps",
                          systemImage: "figure.strengthtraining.traditional"
                      )

                      Label(
                          "\(entry.weight) \(weightUnit)",
                          systemImage: "scalemass.fill"
                      )
                  }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white.opacity(0.92))
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 165, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: gradientSettings.selectedPreset.cardColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .blue.opacity(0.22), radius: 10, x: 0, y: 6)
    }
    
    private var cardIcon: String {
        category.icon
    }

    private var distanceUnit: String {
        weightUnit == "lbs" ? "mi" : "km"
    }
}
