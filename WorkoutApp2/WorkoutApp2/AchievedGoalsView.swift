//
//  AchievedGoalsView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/30/26.
//

import SwiftUI

struct AchievedGoal: Identifiable {
    let id = UUID()
    let workout: String
    let target: String
    let dateReached: Date? // optional, if you later decide to store it
}

struct AchievedGoalsView: View {
    let achievedGoals: [AchievedGoal]

    // Optional: you can also recompute here if you want live refresh,
    // but using the passed-in array keeps it simple.
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(1.0),
                    Color.cyan.opacity(0.6),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("Goals Achieved")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)

                    if achievedGoals.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No goals reached yet — keep going!")
                                .foregroundStyle(.secondary)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 240)
                        .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(achievedGoals) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.workout)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text("Target: \(item.target)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                                .padding(14)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
                .padding(.top, 12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Goals Achieved")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
        }
    }
}
