//
//  DistanceDetailView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/21/26.
//
import SwiftUI

struct DistanceDetailView: View {

    @EnvironmentObject var Hmanager: HealthManager
    let unitSystem: UnitSystem

    @AppStorage("dailyStepsGoal")
    private var dailyStepsGoal: Int = 10000

    private var progress: CGFloat {

        guard dailyStepsGoal > 0 else { return 0 }

        return min(
            CGFloat(Hmanager.steps)
            / CGFloat(dailyStepsGoal),
            1
        )
    }

    var body: some View {

        NavigationStack {

            ZStack {

                // MARK: - Background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.9),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {

                    VStack(spacing: 28) {

                        // MARK: - Header
                        HStack {

                            Label(
                                "Daily Activity",
                                systemImage: "figure.walk"
                            )
                            .font(.headline)

                            Spacer()

                            Circle()
                                .fill(
                                    Hmanager.steps >= dailyStepsGoal
                                    ? .green
                                    : .orange
                                )
                                .frame(width: 10, height: 10)
                        }
                        .foregroundStyle(.white)

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
                                            colors: [.green, .blue],
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

                                    Text("\(Hmanager.steps)")
                                        .font(
                                            .system(
                                                size: 52,
                                                weight: .bold,
                                                design: .rounded
                                            )
                                        )
                                        .foregroundStyle(.white)
                                        .monospacedDigit()

                                    Text("Steps")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.white.opacity(0.7))

                                    Text("Goal: \(dailyStepsGoal)")
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }

                            // MARK: - Quick Goal Controls
                            HStack(spacing: 28) {

                                controlButton(
                                    icon: "minus",
                                    color: .orange
                                ) {

                                    dailyStepsGoal = max(
                                        1000,
                                        dailyStepsGoal - 500
                                    )
                                }

                                controlButton(
                                    icon: "plus",
                                    color: .blue
                                ) {

                                    dailyStepsGoal += 500
                                }
                            }
                        }

                        // MARK: - Stats Card
                        VStack(spacing: 18) {

                            HStack(spacing: 20) {

                                VStack(spacing: 10) {

                                    Image(systemName: "figure.stairs")
                                        .font(.title2)

                                    Text("\(Hmanager.flightsClimbed)")
                                        .font(.title.bold())

                                    Text("Flights")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)

                                Divider()
                                    .overlay(Color.white.opacity(0.2))

                                VStack(spacing: 10) {

                                    Image(systemName: "location.fill")
                                        .font(.title2)

                                    Text(Hmanager.formattedDistance)
                                        .font(.title.bold())

                                    Text("Distance")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .foregroundStyle(.white)

                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.white.opacity(0.12))
                                .background(.ultraThinMaterial)
                        )

                        // MARK: - Chart Card
                        VStack(alignment: .leading, spacing: 18) {

                            HStack {

                                Label(
                                    "Last 5 Days",
                                    systemImage: "chart.bar.fill"
                                )
                                .font(.headline)

                                Spacer()

                                Text("Avg \(Hmanager.fiveDayAverageSteps)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .foregroundStyle(.white)

                            if !Hmanager.getLastFiveDaysSteps.isEmpty {

                                FiveDayStepsBarChartWithValues(
                                    data: Hmanager.getLastFiveDaysSteps
                                )
                                .frame(height: 220)

                                let met =
                                Hmanager.steps >= dailyStepsGoal

                                HStack {

                                    Label(
                                        met
                                        ? "Goal Met"
                                        : "Goal Not Met",
                                        systemImage:
                                            met
                                            ? "checkmark.circle.fill"
                                            : "xmark.circle.fill"
                                    )
                                    .foregroundStyle(
                                        met
                                        ? .green
                                        : .red
                                    )

                                    Spacer()
                                }
                                .font(.headline)

                            } else {

                                Text("5-day history unavailable")
                                    .foregroundStyle(
                                        .white.opacity(0.7)
                                    )
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.white.opacity(0.12))
                                .background(.ultraThinMaterial)
                        )

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .principal) {

                    Text("Steps")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }
            }
            .onAppear {

                Hmanager.fetchSteps()
                Hmanager.fetchDistance()
                Hmanager.fetchLastFiveDaysSteps()
                Hmanager.fetchFlightsClimbed()
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
    struct PreviewWrapper: View {
        @StateObject private var manager = HealthManager()

        init() {
            manager.steps = 8432
            manager.distance = 6200
            manager.lastFiveDaysSteps = [
                (Calendar.current.date(byAdding: .day, value: -4, to: Date())!, 5000),
                (Calendar.current.date(byAdding: .day, value: -3, to: Date())!, 7200),
                (Calendar.current.date(byAdding: .day, value: -2, to: Date())!, 9100),
                (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 6800),
                (Date(), 8432)
            ]
        }

        var body: some View {
            NavigationView {
                DistanceDetailView(unitSystem: .imperial)
                    .environmentObject(manager)
            }
        }
    }

    return PreviewWrapper()
}
