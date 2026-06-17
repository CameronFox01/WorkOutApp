//
//  WeeklyRecapCard.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/5/26.
//


import SwiftUI

struct WeeklyRecapCard: View {

    let workoutsCompleted: Int
    let workoutsPlanned: Int
    let streak: Int

    private var consistency: Int {
        guard workoutsPlanned > 0 else { return 0 }

        return Int(
            (Double(workoutsCompleted) /
             Double(workoutsPlanned)) * 100
        )
    }

    private var message: String {

        if consistency >= 100 {
            return "Excellent week"

        } else if consistency >= 75 {
            return "Strong progress"

        } else if consistency >= 50 {
            return "Building momentum"

        } else {
            return "Every workout counts"
        }
    }

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("This Week")
                        .font(.headline)

                    Text(message)
                        .font(.title3.bold())
                }

                Spacer()

                ZStack {

                    Circle()
                        .stroke(
                            .white.opacity(0.15),
                            lineWidth: 8
                        )

                    Circle()
                        .trim(
                            from: 0,
                            to: Double(consistency)/100
                        )
                        .stroke(
                            .green,
                            style: StrokeStyle(
                                lineWidth: 8,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(
                            .degrees(-90)
                        )

                    Text("\(consistency)%")
                        .font(.headline.bold())
                     //   .foregroundStyle(.white)

                }
                .frame(
                    width: 60,
                    height: 60
                )
            }

            HStack(spacing: 50) {

                stat(
                    icon: "dumbbell.fill",
                    value: "\(workoutsCompleted)",
                    label: "Workouts"
                )

                stat(
                    icon: "flame.fill",
                    value: "\(streak)",
                    label: "Streak"
                )

                Spacer()
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(
                cornerRadius: 28
            )
            .fill(
                .white.opacity(0.30)
            )
        )
    }

    private func stat(
        icon: String,
        value: String,
        label: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            Image(systemName: icon)
                .foregroundStyle(.orange)

            Text(value)
                .font(.headline.bold())
              //  .foregroundStyle(.white)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                    
              
        }
    }
}

#Preview {

    ZStack {

        LinearGradient(
            colors: [.blue,.black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        WeeklyRecapCard(
            workoutsCompleted: 4,
            workoutsPlanned: 5,
            streak: 12
        )
        .environmentObject(GradientSettings())
        .padding()
    }
}
