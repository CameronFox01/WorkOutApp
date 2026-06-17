//
//  CaloriesDetailView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/21/26.
//
import SwiftUI

struct CaloriesDetailView: View {

    @EnvironmentObject var Hmanager: HealthManager
    @Environment(\.dismiss) private var dismiss
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings

    let unitSystem: UnitSystem

    @AppStorage("dailyCaloriesGoal")
    private var dailyCaloriesGoal: Int = 500

    private var lastFiveDaysSteps: [(date: Date, steps: Int)] {
        Hmanager.lastFiveDaysSteps
    }

    var lastFiveDaysActiveCalories: [Date: Double] = [:]
    
    private var estimatedCaloriesToday: Int {
        Int(Double(Hmanager.steps) * 0.04)
    }

    private var progress: CGFloat {

        guard dailyCaloriesGoal > 0 else {
            return 0
        }

        return min(
            CGFloat(estimatedCaloriesToday)
            / CGFloat(dailyCaloriesGoal),
            1
        )
    }

    var body: some View {

        NavigationStack {

            ZStack {

                // MARK: - Background
                LinearGradient(
                    colors: gradientSettings.darkGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {

                    VStack(spacing: 28) {

                        // MARK: - Hero Ring
                        VStack(spacing: 18) {

                            ZStack {

                                Circle()
                                    .stroke(
                                        Color.white.opacity(0.15),
                                        lineWidth: 18
                                    )
                                    .frame(width: 280, height: 280)

                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(
                                        AngularGradient(
                                            colors: [.orange, .red],
                                            center: .center
                                        ),
                                        style: StrokeStyle(
                                            lineWidth: 18,
                                            lineCap: .round
                                        )
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 280, height: 280)

                                VStack(spacing: 10) {
                                    if Hmanager.activeCalories == 0 {
                                        Text("\(Int(Int(Double(Hmanager.steps) * 0.04)))")
                                            .font(
                                                .system(
                                                    size: 60,
                                                    weight: .bold,
                                                    design: .rounded
                                                )
                                            )
                                            .foregroundStyle(.white)
                                            .monospacedDigit()
                                    } else {
                                        Text("\(Int(Hmanager.activeCalories))")
                                            .font(
                                                .system(
                                                    size: 60,
                                                    weight: .bold,
                                                    design: .rounded
                                                )
                                            )
                                            .foregroundStyle(.white)
                                            .monospacedDigit()
                                    }

                                    Text("kcal")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(
                                            .white.opacity(0.7)
                                        )

                                    Text("Calories Burned")
                                        .foregroundStyle(
                                            .white.opacity(0.6)
                                        )
                                }
                            }

                            // MARK: - Goal Controls
                            HStack(spacing: 28) {

                                controlButton(
                                    icon: "minus",
                                    color: .orange
                                ) {

                                    dailyCaloriesGoal = max(
                                        100,
                                        dailyCaloriesGoal - 50
                                    )
                                }

                                VStack(spacing: 4) {

                                    Text("Goal")

                                    Text("\(dailyCaloriesGoal)")

                                }
                                .font(.headline.bold())
                                .foregroundStyle(.white)

                                controlButton(
                                    icon: "plus",
                                    color: .blue
                                ) {

                                    dailyCaloriesGoal += 50
                                }
                            }
                        }
                        .padding(.top, 20)

                        // MARK: - Analytics Card
                        VStack(alignment: .leading, spacing: 18) {

                            HStack {

                                Label(
                                    "Calories Analytics",
                                    systemImage: "flame.fill"
                                )
                                .font(.headline)

                                Spacer()

                                Circle()
                                    .fill(
                                        estimatedCaloriesToday
                                        >= dailyCaloriesGoal
                                        ? .green
                                        : .orange
                                    )
                                    .frame(width: 10, height: 10)
                            }
                            .foregroundStyle(.white)

                            VStack(alignment: .leading, spacing: 10) {

                                HStack {

                                    Text("Today's Calories")
                                        .foregroundStyle(
                                            .white.opacity(0.7)
                                        )

                                    Spacer()

                                    Text("\(Int(Hmanager.activeCalories)) kcal")
                                        .bold()
                                }

                                HStack {

                                    Text("5-Day Average")
                                        .foregroundStyle(
                                            .white.opacity(0.7)
                                        )

                                    Spacer()

                                    Text("\(Hmanager.fiveDayAverageCalories)")
                                        .bold()
                                }

                                HStack {

                                    Text("Goal Status")
                                        .foregroundStyle(
                                            .white.opacity(0.7)
                                        )

                                    Spacer()

                                    Label(
                                        estimatedCaloriesToday
                                        >= dailyCaloriesGoal
                                        ? "Met"
                                        : "In Progress",
                                        systemImage:
                                            estimatedCaloriesToday
                                            >= dailyCaloriesGoal
                                            ? "checkmark.circle.fill"
                                            : "clock.fill"
                                    )
                                    .foregroundStyle(
                                        estimatedCaloriesToday
                                        >= dailyCaloriesGoal
                                        ? .green
                                        : .orange
                                    )
                                }
                            }
                            .foregroundStyle(.white)

                            Divider()
                                .overlay(
                                    Color.white.opacity(0.15)
                                )

                            // MARK: - Chart
                            if !Hmanager.lastFiveDaysCalories.isEmpty {

                                FiveDayCaloriesBarChart(
                                    data: Hmanager.lastFiveDaysCalories
                                )
                                .frame(height: 220)
                            } else {

                                VStack(spacing: 12) {

                                    Image(systemName: "chart.bar.xaxis")
                                        .font(.largeTitle)

                                    Text("No calorie history available")
                                        .foregroundStyle(
                                            .white.opacity(0.7)
                                        )
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.white.opacity(0.12))
                                .background(.ultraThinMaterial)
                        )
                        .padding(.horizontal)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .principal) {

                    Text("Calories")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }
            }
            .onAppear {
                Hmanager.fetchSteps()
                Hmanager.fetchLastFiveDaysSteps()
                Hmanager.fetchActiveCalories()
                Hmanager.fetchLastFiveDaysActiveCalories()
            }
        }
    }

    // MARK: - Control Button
    func controlButton(
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 68, height: 68)
                .background(color.gradient)
                .clipShape(Circle())
                .shadow(radius: 8)
        }
    }
}

#Preview {
    // 1. Create a NavigationStack (needed for the toolbar to show correctly)
    NavigationStack {
        CaloriesDetailView(unitSystem: .metric)
            .environmentObject(HealthManager()) // 2. Inject your manager here
    }
}
