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

                if isDistanceCardio {

                    Label(
                        "\(entry.weight) \(distanceUnit)",
                        systemImage: "figure.walk"
                    )

                } else if isTimeCardio {

                    Label(
                        "\(entry.reps) min",
                        systemImage: "timer"
                    )

                } else if isSports {
                    Label(
                        "\(entry.reps) min",
                        systemImage: "timer"
                    )
                } else {

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
        if isDistanceCardio {
            return "figure.run"
        }

        if isTimeCardio {
            return "timer"
        }
        
        if isSports {
            return "sportscourt.fill"
        }
        
        if isABs {
            return "figure.core.training"
        }
        
        if isLeg {
            return "figure.strengthtraining.functional"
        }
        
        if isPull {
            return "arrow.down.backward.circle"
        }
        
        if isPush {
            return "arrow.up.forward.circle"
        }
        
        if isGlute {
            return "figure.strengthtraining.traditional"
        }
        
        if isBicep {
            return "dumbbell"
        }
        
        if isTricep {
            return "bolt.circle"
        }
        
        if isStretch {
            return "figure.yoga"
        }
        
        return "dumbbell.fill"
    }
    
    private var isPush: Bool {
        PushWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }
    
    private var isPull: Bool {
        PullWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }
    
    private var isLeg: Bool {
        LegWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }
    
    private var isGlute: Bool {
        GluteWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }
    
    private var isBicep: Bool {
        BicepWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }
    
    private var isTricep: Bool {
        TricepWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }
    
    private var isStretch: Bool {
        StretchRoutine.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }
    
    private var isABs: Bool {
        AbsWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }
    
    private var isDistanceCardio: Bool {
        DistanceCardioWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }

    private var isTimeCardio: Bool {
        TimeCardioWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }
    
    private var isSports: Bool {
        SportsWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }

    private var distanceUnit: String {
        weightUnit == "lbs" ? "mi" : "km"
    }
}
