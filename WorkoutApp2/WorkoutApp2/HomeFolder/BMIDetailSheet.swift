//
//  BMIDetailSheet.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/24/26.
//

import SwiftUI

struct BMIDetailSheet: View {
    let bmi: Double
    let poundsToHealthy: Double
    let poundsToGoal: Double
    let weightUnit: String
    let category: (label: String, color: Color)

    @Environment(\.dismiss) private var dismiss
    
    //Color Gradiant
    @StateObject private var gradientSettings = GradientSettings()

    private var unit: String { weightUnit == "imperial" ? "lbs" : "kg" }

    private var monthsToGoal: Int {
        // 500 cal/day deficit ≈ 1 lb/week ≈ 4.3 lbs/month
        // For metric: 1 lb ≈ 0.453 kg
        let lossPerMonth = weightUnit == "imperial" ? 4.3 : 1.95
        guard poundsToGoal > 0 else { return 0 }
        return max(1, Int(ceil(poundsToGoal / lossPerMonth)))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    currentStatusCard
                    goalCard
                    rangeExplainerCard
                    disclaimerCard
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: gradientSettings.darkGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("BMI Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Current Status Card

    private var currentStatusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Your current BMI", systemImage: "person.fill")
                .font(.subheadline)
                .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(String(format: "%.1f", bmi))
                    .font(.system(size: 48, weight: .medium))

                Text(category.label)
                    .font(.headline)
                    .foregroundStyle(category.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(category.color.opacity(0.12))
                    .clipShape(Capsule())
            }

            if poundsToHealthy > 0 {
                Text("You are \(String(format: "%.0f", abs(poundsToHealthy))) \(unit) above the healthy range.")
                    .font(.subheadline)
                    .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)
            } else if poundsToHealthy < 0 {
                Text("You are \(String(format: "%.0f", abs(poundsToHealthy))) \(unit) below the healthy range.")
                    .font(.subheadline)
                    .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)
            } else {
                Text("You are within the healthy BMI range.")
                    .font(.subheadline)
                    .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(
                cornerRadius: 28
            )
            .fill(
                .white.opacity(0.30)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Goal Card

    @ViewBuilder
    private var goalCard: some View {
        if poundsToGoal > 0 {
            VStack(alignment: .leading, spacing: 14) {
                Label("Your weight loss goal", systemImage: "target")
                    .font(.subheadline)
                    .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)

                HStack(spacing: 16) {
                    statBox(
                        value: String(format: "%.0f \(unit)", poundsToGoal),
                        label: "To reach BMI 22"
                    )
                    statBox(
                        value: "~\(monthsToGoal) mo",
                        label: "Estimated time"
                    )
                }

                Text("Estimated at a 500  calorie per day deficit, which is roughly 1 \(weightUnit == "imperial" ? "lb" : "0.5 kg") per week. Your actual results will vary based on your activity level.")
                    .font(.caption)
                    .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(
                    cornerRadius: 28
                )
                .fill(
                    .white.opacity(0.30)
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Label("Goal reached", systemImage: "checkmark.seal.fill")
                    .font(.subheadline)
                    .foregroundStyle(.green)

                Text("You are at or below BMI 22, which is the middle of the healthy range. Keep it up!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(
                    cornerRadius: 28
                )
                .fill(
                    .white.opacity(0.30)
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Range Explainer Card

    private var rangeExplainerCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("What the ranges mean", systemImage: "info.circle")
                .font(.subheadline)
                .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)
                .padding(.bottom, 8)

            rangeRow(
                color: .blue,
                title: "Underweight  —  Below 18.5",
                description: "May indicate nutritional deficiency or other health concerns. Consider speaking with a doctor."
            )

            Divider().padding(.vertical, 8)

            rangeRow(
                color: .green,
                title: "Healthy  —  18.5 to 24.9",
                description: "Associated with the lowest risk of weight-related health issues for most adults."
            )

            Divider().padding(.vertical, 8)

            rangeRow(
                color: .orange,
                title: "Overweight  —  25 to 29.9",
                description: "May increase risk of heart disease, high blood pressure, and type 2 diabetes over time."
            )

            Divider().padding(.vertical, 8)

            rangeRow(
                color: .red,
                title: "Obese  —  30 and above",
                description: "Associated with significantly higher risk of serious health conditions. A doctor can help create a plan."
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(
                cornerRadius: 28
            )
            .fill(
                .white.opacity(0.30)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Disclaimer Card

    private var disclaimerCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.red)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("BMI has limitations")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("BMI does not account for muscle mass, bone density, age, or body composition. If you are actively building muscle through your workouts, your BMI may read higher than your actual health suggests. Use it as one data point, not the full picture.")
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.orange.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func statBox(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .medium))
            Text(label)
                .font(.caption)
                .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(
                cornerRadius: 28
            )
            .fill(
                .white.opacity(0.30)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func rangeRow(color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    BMIDetailSheet(
        bmi: 27.4,
        poundsToHealthy: 18,
        poundsToGoal: 32,
        weightUnit: "imperial",
        category: ("Overweight", .orange)
    )
}
