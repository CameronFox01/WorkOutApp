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
    
    @EnvironmentObject var workoutData: WorkoutData
    @EnvironmentObject var router: AppRouter
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @State private var newWeightInput: String = ""

    @AppStorage("showCalorieCard") private var showCalorieCard: Bool = true
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userTargetWeight") private var targetWeight: String = ""
    @AppStorage("userOriginalWeight") private var originalWeight: String = ""
    @AppStorage("userBaselineWeightForGoal") private var baselineWeightForGoal: String = ""
    @AppStorage("weightGoalDirection") private var weightGoalDirection: String = "lose"
    private var gainWeight: Bool { weightGoalDirection == "gain" }

    @EnvironmentObject var gradientSettings: GradientSettings

    let weightUnit: String
    let progressPercentText: String?
    let progressIcon: String
    let progressColor: Color?
    let onTap: () -> Void

    private var totalChange: Double? {
        guard let curr = Double(weight), let start = Double(originalWeight) else { return nil }
        return curr - start
    }

    private var amountToGoal: Double? {
        guard let curr = Double(weight), let target = Double(targetWeight) else { return nil }
        return abs(target - curr)
    }

    var body: some View {
        if showCalorieCard {
            compactCard
        } else {
            expandedCard
        }
    }
    
    var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }

    // MARK: - Compact (half-width, calorie card showing)

    private var compactCard: some View {
        NavigationLink(destination: WeightUpdateSheet(
            unitSystem: unitSystem,
            weightUnit: weightUnit,
            comingFromWidget: false,
            currentWeight: $weight,
            newWeightInput: $newWeightInput,
            entries: workoutData.entries,
            onSave: { valueString in
                // Update AppStorage so Account and others reflect immediately
                weight = valueString
                // Append a new WorkoutEntry of type "Body Weight"
                let entry = WorkoutEntry(
                    workoutType: "Body Weight",
                    weight: valueString,
                    reps: "",
                    sets: "",
                    date: Date(),
                    note: ""
                )
                workoutData.add(entry: entry)
                router.activeScreen = nil
            },
            unitSystemRaw: unitSystemRaw))
        {
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
                // Take this is a life lesson that AI will make things more complicated than need to be.
                if let pct = progressPercentText,
                   Double(targetWeight) != nil{
                    HStack(spacing: 6) {
                        Image(systemName: progressIcon)
                            .foregroundStyle(progressColor ?? weightCardSecondary)
                        if pct == "-0%" {
                            Text("0%")
                                .font(.subheadline).bold()
                                .foregroundStyle(progressColor ?? weightCardSecondary)
                        } else {
                            Text(pct)
                                .font(.subheadline).bold()
                                .foregroundStyle(progressColor ?? weightCardSecondary)
                        }
                    }
                } else {
                    Text("Set target weight to see progress")
                        .font(.footnote)
                        .foregroundStyle(weightCardSecondary)
                }           }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        .cardStyle()
    }
    
    // MARK: - Expanded (full-width, calorie card hidden)

    private var expandedCard: some View {
        NavigationLink(destination: WeightUpdateSheet(
            unitSystem: unitSystem,
            weightUnit: weightUnit,
            comingFromWidget: false,
            currentWeight: $weight,
            newWeightInput: $newWeightInput,
            entries: workoutData.entries,
            onSave: { valueString in
                // Update AppStorage so Account and others reflect immediately
                weight = valueString
                // Append a new WorkoutEntry of type "Body Weight"
                let entry = WorkoutEntry(
                    workoutType: "Body Weight",
                    weight: valueString,
                    reps: "",
                    sets: "",
                    date: Date(),
                    note: ""
                )
                workoutData.add(entry: entry)
                router.activeScreen = nil
            },
            unitSystemRaw: unitSystemRaw)) {
            VStack(alignment: .leading, spacing: 18) {

                // Top row: title + current weight
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weight")
                            .font(.title2.bold())
                            .foregroundStyle(weightCardColor)
                        Text("Current")
                            .font(.caption)
                            .foregroundStyle(weightCardSecondary)
                    }
                    .padding(.leading, 20)

                    Spacer()

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(weight.isEmpty ? "—" : weight)
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(weightCardColor)
                        Text(weightUnit)
                            .font(.title3)
                            .foregroundStyle(weightCardColor)
                    }
                    .padding(.trailing, 10)
                }

                Divider()
                    .overlay(weightCardSecondary.opacity(0.3))

                // Stat row: target, change, to goal
                HStack(spacing: 0) {
                    statBlock(
                        icon: "target",
                        label: "Target",
                        value: targetWeight.isEmpty ? "—" : "\(targetWeight) \(weightUnit)"
                    )

                    Divider()
                        .frame(height: 36)
                        .overlay(weightCardSecondary.opacity(0.3))

                    statBlock(
                        icon: gainWeight ? "arrow.up.right" : "arrow.down.right",
                        label: "Total Change",
                        value: totalChange.map {
                            let rounded = (($0 * 10).rounded() / 10)
                            guard rounded != 0, !rounded.isZero else { return "0 \(weightUnit)" }
                            return String(format: "%+.1f %@", rounded, weightUnit)
                        } ?? "—"
                    )

                    Divider()
                        .frame(height: 36)
                        .overlay(weightCardSecondary.opacity(0.3))

                    statBlock(
                        icon: "flag.checkered",
                        label: "To Goal",
                        value: amountToGoal.map { String(format: "%.1f %@", $0, weightUnit) } ?? "—"
                    )
                }

                // Progress bar
                if let pct = progressPercentText, Double(targetWeight) != nil, (progressFraction ?? 0) > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: progressIcon)
                                .foregroundStyle(progressColor ?? weightCardSecondary)
                            Text("\(pct) toward goal")
                                .font(.subheadline.bold())
                                .foregroundStyle(progressColor ?? weightCardSecondary)
                            Spacer()
                        }
                        .padding(.leading, 20)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(weightCardSecondary.opacity(0.2))
                                    .frame(height: 8)

                                Capsule()
                                    .fill(progressColor ?? weightCardColor)
                                    .frame(
                                        width: progressFraction.map { geo.size.width * $0 } ?? 0,
                                        height: 8
                                    )
                                    .animation(.spring(response: 0.4), value: progressFraction)
                            }
                        }
                        .frame(height: 8)
                    }
                } else {
                    Text("Set a target weight to track your progress")
                        .font(.footnote)
                        .foregroundStyle(weightCardSecondary)
                        .padding(.leading, 20)
                }
            }
            .padding(.vertical, 4)
        }
        .cardStyle()
    }

    private func statBlock(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(weightCardSecondary)
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(weightCardColor)
            Text(label)
                .font(.caption2)
                .foregroundStyle(weightCardSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var progressFraction: Double? {
        guard let pct = progressPercentText?.replacingOccurrences(of: "%", with: ""),
              let value = Double(pct) else { return nil }
        return min(max(value / 100, 0), 1)
    }
}

// MARK: - WeightCard Preview

#Preview("Weight Card") {
    ZStack {
        LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

        WeightCard(
            weightUnit: "lbs",
            progressPercentText: "0%",
            progressIcon: "chart.line.downtrend.xyaxis",
            progressColor: .green,
            onTap: {}
        )
        .environmentObject(GradientSettings())
        .padding()
    }
}
