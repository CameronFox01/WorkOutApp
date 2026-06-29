//
//  WeightCard.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/28/26.
//


import SwiftUI

struct WeightCard: View {
    @Environment(\.colorScheme) private var colorScheme
    private var weightCardColor: Color { colorScheme == .dark ? .white : .black }
    private var weightCardSecondary: Color { colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.6) }

    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userTargetWeight") private var targetWeight: String = ""
    @AppStorage("userBaselineWeightForGoal") private var baselineWeightForGoal: String = ""
    @AppStorage("weightGoalDirection") private var weightGoalDirection: String = "lose"
    private var gainWeight: Bool { weightGoalDirection == "gain" }

    @EnvironmentObject var gradientSettings: GradientSettings

    let weightUnit: String
    let progressPercentText: String?
    let progressIcon: String
    let progressColor: Color?
    let onTap: () -> Void

    var body: some View {
        Button { onTap() } label: {
            VStack(alignment: .center, spacing: 8) {
                Text("Weight")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(weightCardColor)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(weight.isEmpty ? "—" : weight)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(weightCardColor)
                    Text(weightUnit)
                        .font(.headline)
                        .foregroundStyle(weightCardColor)
                }

                HStack(spacing: 6) {
                    Image(systemName: "target")
                        .foregroundStyle(weightCardColor)
                    Text("Target: \(targetWeight.isEmpty ? "—" : targetWeight) \(weightUnit)")
                        .font(.subheadline)
                        .foregroundStyle(weightCardColor)
                }

                if let pct = progressPercentText, Double(targetWeight) != nil {
                    HStack(spacing: 6) {
                        Image(systemName: progressIcon)
                            .foregroundStyle(progressColor ?? weightCardSecondary)
                        Text(pct)
                            .font(.subheadline).bold()
                            .foregroundStyle(progressColor ?? weightCardSecondary)
                    }
                } else {
                    Text("Set target weight to see progress")
                        .font(.footnote)
                        .foregroundStyle(weightCardSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        .cardStyle()
    }
}