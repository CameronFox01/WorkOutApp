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
    
    @AppStorage("dailyStepsGoal") private var dailyStepsGoal: Int = 10000
    
    private var lastFiveDaysSteps: [(date: Date, steps: Int)] { Hmanager.lastFiveDaysSteps }
    private var fiveDayAverageSteps: Int {
        let total = lastFiveDaysSteps.reduce(0) { $0 + $1.steps }
        return lastFiveDaysSteps.isEmpty ? 0 : total / lastFiveDaysSteps.count
    }
    
    var formattedDistance: String {
        if unitSystem == .metric {
            let km = Hmanager.distance / 1000
            return String(format: "%.2f km", km)
        } else {
            let miles = Hmanager.distance / 1609.34
            return String(format: "%.2f mi", miles)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GroupBox(label: Text("Today")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Steps")
                                .font(.headline)
                            Text("\(Hmanager.steps)")
                                .font(.title2).bold()
                            Text("Goal: \(dailyStepsGoal)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .center, spacing: 27){
                            Text("Flights Climbed")
                                .font(.headline)
                            Text("\(Hmanager.flightsClimbed)")
                                .font(.title2).bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 27) {
                            Text("Distance")
                                .font(.headline)
                            Text(formattedDistance)
                                .font(.title2).bold()
                        }
                    }
                    .padding()
                }

                GroupBox(label: Text("Last 5 Days")) {
                    VStack(alignment: .leading, spacing: 12) {
                        if !lastFiveDaysSteps.isEmpty {
                            FiveDayStepsBarChartWithValues(data: lastFiveDaysSteps)
                              
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .padding(.top, 4)

                            HStack {
                                Text("5-day avg:")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                Text("\(fiveDayAverageSteps)")
                                    .font(.body)
                                    .bold()
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            
                            // Move goal status below the chart and avg row
                            if let latest = lastFiveDaysSteps.last {
                                let met = latest.steps >= dailyStepsGoal
                                HStack {
                                    Label(met ? "Goal met" : "Goal not met", systemImage: met ? "checkmark.circle" : "xmark.circle")
                                        .font(.headline)
                                        .foregroundStyle(met ? .green : .red)
                                    Spacer()
                                }
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

                GroupBox(label: Text("Daily Step Goal")) {
                    HStack(spacing: 12) {
                        Stepper(value: $dailyStepsGoal, in: 1000...50000, step: 500) {
                            Text("Goal: \(dailyStepsGoal) steps")
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    Text("This goal applies per day and is shown above when comparing recent days.")
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
                Text("Steps")
                    .font(.largeTitle).bold()
                    .foregroundStyle(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Hmanager.fetchSteps()
            Hmanager.fetchDistance()
            Hmanager.fetchLastFiveDaysSteps()
            Hmanager.fetchFlightsClimbed()
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
