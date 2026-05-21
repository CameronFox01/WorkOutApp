//
//  CaloriesDetailView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/21/26.
//
import SwiftUI

struct CaloriesDetailView: View {
    @EnvironmentObject var Hmanager: HealthManager
    let unitSystem: UnitSystem

    @AppStorage("dailyCaloriesGoal") private var dailyCaloriesGoal: Int = 2000

    private var lastFiveDaysSteps: [(date: Date, steps: Int)] { Hmanager.lastFiveDaysSteps }

    private var lastFiveDaysCalories: [(date: Date, calories: Int)] {
        lastFiveDaysSteps.map { ($0.date, Int(Double($0.steps) * 0.04)) }
    }

    private var fiveDayAverageCalories: Int {
        let total = lastFiveDaysCalories.reduce(0) { $0 + $1.calories }
        return lastFiveDaysCalories.isEmpty ? 0 : total / lastFiveDaysCalories.count
    }

    private var estimatedCaloriesToday: Int { Int(Double(Hmanager.steps) * 0.04) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GroupBox(label: Text("Today")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calories")
                                .font(.headline)
                            Text("\(Int(Hmanager.activeCalories)) kcal")
                                .font(.title2).bold()
                            Text("Goal: \(dailyCaloriesGoal) kcal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                }

                GroupBox(label: Text("Last 5 Days")) {
                    VStack(alignment: .leading, spacing: 12) {
                        if !lastFiveDaysCalories.isEmpty {
                            FiveDayCaloriesBarChart(data: lastFiveDaysCalories)
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .padding(.top, 4)

                            HStack {
                                Text("5-day avg:")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                Text("\(fiveDayAverageCalories)")
                                    .font(.body)
                                    .bold()
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }

                            let met = estimatedCaloriesToday >= dailyCaloriesGoal
                            HStack {
                                Label(met ? "Goal met" : "Goal not met", systemImage: met ? "checkmark.circle" : "xmark.circle")
                                    .font(.headline)
                                    .foregroundStyle(met ? .green : .red)
                                Spacer()
                            }
                        } else {
                            Text("5-day history unavailable")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }

                GroupBox(label: Text("Daily Calories Goal")) {
                    HStack(spacing: 12) {
                        Stepper(value: $dailyCaloriesGoal, in: 500...10000, step: 50) {
                            Text("Goal: \(dailyCaloriesGoal) kcal")
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    Text("This is your target active calories burned per day.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Calories")
                    .font(.largeTitle).bold()
                    .foregroundStyle(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Hmanager.fetchSteps()
            Hmanager.fetchLastFiveDaysSteps()
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var current = "180"
        @State var input = "180"

        var body: some View {
            WeightUpdateSheet(
                unitSystem: .metric,
                weightUnit: "kg",
                currentWeight: $current,
                newWeightInput: $input,
                entries: [],
                onSave: { _ in },
                unitSystemRaw: UnitSystem.metric.rawValue
            )
        }
    }

    return PreviewWrapper()
}
