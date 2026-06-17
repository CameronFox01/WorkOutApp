//
//  FiveDayCaloriesBarChart.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/21/26.
//
import SwiftUI
//This is just the bar chart for the Calories
struct FiveDayCaloriesBarChart: View {
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings
    let data: [(date: Date, calories: Int)]

    private var maxCalories: Double {
        max(Double(data.map { $0.calories }.max() ?? 1), 1)
    }

    private var weekdayFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "E"
        return df
    }

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 8
            let dataCount = max(data.count, 1)

            let totalSpacing = spacing * CGFloat(max(dataCount - 1, 0))
            let barWidth = (geo.size.width - totalSpacing) / CGFloat(dataCount)
            let chartHeight = geo.size.height - 20

            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(data.indices, id: \.self) { i in
                    let item = data[i]

                    VStack(spacing: 4) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: barWidth, height: chartHeight)

                            let heightRatio = CGFloat(Double(item.calories) / maxCalories)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(gradientSettings.selectedPreset.caloriesAccentColor)
                                .frame(width: barWidth,
                                       height: max(4, chartHeight * heightRatio))
                        }

                        Text(weekdayFormatter.string(from: item.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: barWidth)
                    }
                }
            }
            .frame(width: geo.size.width)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let sampleData: [(date: Date, calories: Int)] = [
        (Calendar.current.date(byAdding: .day, value: -6, to: Date())!, 320),
        (Calendar.current.date(byAdding: .day, value: -5, to: Date())!, 450),
        (Calendar.current.date(byAdding: .day, value: -4, to: Date())!, 610),
        (Calendar.current.date(byAdding: .day, value: -3, to: Date())!, 280),
        (Calendar.current.date(byAdding: .day, value: -2, to: Date())!, 720),
        (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 510),
        (Date(), 840)
    ]

    VStack {
        FiveDayCaloriesBarChart(data: sampleData)
            .frame(height: 120)
            .padding()
            .environmentObject(GradientSettings())
    }
}
