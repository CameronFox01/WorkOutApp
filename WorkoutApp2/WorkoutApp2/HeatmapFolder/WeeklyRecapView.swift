//
//  WeeklyRecapView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/5/26.
//

import SwiftUI

struct WeeklyRecapData {
    let workoutsCompleted: Int
    let workoutsPlanned: Int
    let totalVolume: Double
    let streak: Int
    let strongestExercise: String
    let improvementPercent: Int
    let photosAdded: Int
}

struct WeeklyRecapView: View {

    let recap: WeeklyRecapData

    var consistency: Double {
        guard recap.workoutsPlanned > 0 else { return 0 }
        return Double(recap.workoutsCompleted) /
        Double(recap.workoutsPlanned)
    }

    //Color Gradiant
    @StateObject private var gradientSettings = GradientSettings()
    
    var body: some View {

        ZStack {

            LinearGradient(
                colors: gradientSettings.darkGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {

                VStack(spacing: 22) {

                    header

                    consistencyCard

                    statsGrid

                    highlightCard

                    motivationCard

                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
    }

    private var header: some View {

        VStack(spacing: 8) {

            Text("Weekly Recap")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("See how this week went")
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.top)
    }

    private var consistencyCard: some View {

        VStack(spacing: 16) {

            Text("Consistency")
                .font(.headline)
                .foregroundStyle(.white)

            ZStack {

                Circle()
                    .stroke(
                        Color.white.opacity(0.15),
                        lineWidth: 14
                    )

                Circle()
                    .trim(from: 0, to: consistency)
                    .stroke(
                        Color.green,
                        style: StrokeStyle(
                            lineWidth: 14,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                VStack {

                    Text("\(Int(consistency * 100))%")
                        .font(.largeTitle.bold())

                    Text(
                        "\(recap.workoutsCompleted)/\(recap.workoutsPlanned)"
                    )
                    .font(.caption)
                }
                .foregroundStyle(.white)
            }
            .frame(width: 150, height: 150)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(cardBackground)
    }

    private var statsGrid: some View {

        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 16
        ) {

            statCard(
                icon: "flame.fill",
                title: "Streak",
                value: "\(recap.streak) days"
            )

            statCard(
                icon: "dumbbell.fill",
                title: "Volume",
                value: "\(Int(recap.totalVolume))"
            )

            statCard(
                icon: "photo",
                title: "Photos",
                value: "\(recap.photosAdded)"
            )

            statCard(
                icon: "arrow.up.circle.fill",
                title: "Improvement",
                value: "\(recap.improvementPercent)%"
            )
        }
    }

    private var highlightCard: some View {

        VStack(alignment: .leading, spacing: 12) {

            Label(
                "Highlight",
                systemImage: "star.fill"
            )
            .foregroundStyle(.yellow)

            Text("Most Improved Exercise")
                .foregroundStyle(.white)

            Text(recap.strongestExercise)
                .font(.title2.bold())
                .foregroundStyle(.white)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(cardBackground)
    }

    private var motivationCard: some View {

        VStack(spacing: 10) {

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(
                "Progress comes from consistency."
            )
            .foregroundStyle(.white.opacity(0.7))
        }
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(cardBackground)
    }

    private func statCard(
        icon: String,
        title: String,
        value: String
    ) -> some View {

        VStack(spacing: 10) {

            Image(systemName: icon)
                .font(.title2)

            Text(value)
                .font(.headline.bold())

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(cardBackground)
    }

    private var cardBackground: some View {

        RoundedRectangle(
            cornerRadius: 24
        )
        .fill(.white.opacity(0.12))
    }

    private var message: String {

        if consistency >= 1 {
            return "Excellent week 🎉"

        } else if consistency >= 0.75 {
            return "Strong consistency this week"

        } else if consistency >= 0.5 {
            return "Solid progress this week"

        } else {
            return "Every workout counts"
        }
    }
}

#Preview {

    WeeklyRecapView(
        recap: WeeklyRecapData(
            workoutsCompleted: 4,
            workoutsPlanned: 5,
            totalVolume: 18500,
            streak: 12,
            strongestExercise: "Bench Press",
            improvementPercent: 14,
            photosAdded: 2
        )
    )
    .environmentObject(GradientSettings())
}
