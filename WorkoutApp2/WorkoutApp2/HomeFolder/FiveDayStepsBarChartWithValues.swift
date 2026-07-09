//
//  FiveDayStepsBarChartWithValues.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/8/26.
//
import SwiftUI
import Foundation

struct FiveDayStepsBarChartWithValues: View {
    let data: [(date: Date, steps: Int)]

    private var maxSteps: Double {
        max(Double(data.map { $0.steps }.max() ?? 1), 1)
    }

    private var weekdayFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "E"
        return df
    }
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings
    
    
    public var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 8
            let totalSpacing = spacing * CGFloat(data.count - 1)
            let barWidth = (geo.size.width - totalSpacing) / CGFloat(data.count)
            let chartHeight = geo.size.height - 40  // room for label + step count

            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                    let heightRatio = CGFloat(Double(item.steps) / maxSteps)
                    let barHeight = max(4, chartHeight * heightRatio)

                    VStack(spacing: 2) {
                        // ✅ Step count sits just above the bar
                        Text("\(item.steps)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: barWidth)

                        ZStack(alignment: .bottom) {
                            // Background track
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: barWidth, height: chartHeight)

                            // Filled bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(gradientSettings.selectedPreset.stepsAccentColor)
                                .frame(width: barWidth, height: barHeight)
                        }

                        // ✅ Day label sits below the bar
                        Text(weekdayFormatter.string(from: item.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: barWidth)
                    }
                }
            }
            .frame(width: geo.size.width)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}
