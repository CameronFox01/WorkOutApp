//
//  FiveDayStepsBarChart.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/21/26.
//

import SwiftUI
// This is straight up just the bar chart for the Steps
struct FiveDayStepsBarChart: View {
    let data: [(date: Date, steps: Int)]

    private var maxSteps: Double {
        max(Double(data.map { $0.steps }.max() ?? 1), 1)
    }

    private var weekdayFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "E"
        return df
    }

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 8
            let totalSpacing = spacing * CGFloat(data.count - 1)
            let barWidth = (geo.size.width - totalSpacing) / CGFloat(data.count)  // ✅ Uses full geo width
            let chartHeight = geo.size.height - 20  // leave room for labels

            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(data.indices, id: \.self) { i in
                    let item = data[i]
                    VStack(spacing: 4) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: barWidth, height: chartHeight)

                            let heightRatio = CGFloat(Double(item.steps) / maxSteps)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor.opacity(0.7))
                                .frame(width: barWidth, height: max(4, chartHeight * heightRatio))
                        }

                        Text(weekdayFormatter.string(from: item.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: barWidth)
                    }
                }
            }
            .frame(width: geo.size.width)  // ✅ Force HStack to use full GeometryReader width
        }
        .frame(maxWidth: .infinity)  // ✅ Tell GeometryReader to take full width
    }
}


#Preview {
    let sampleData: [(date: Date, steps: Int)] = [
        (Calendar.current.date(byAdding: .day, value: -6, to: Date())!, 4200),
        (Calendar.current.date(byAdding: .day, value: -5, to: Date())!, 7100),
        (Calendar.current.date(byAdding: .day, value: -4, to: Date())!, 9800),
        (Calendar.current.date(byAdding: .day, value: -3, to: Date())!, 5300),
        (Calendar.current.date(byAdding: .day, value: -2, to: Date())!, 12000),
        (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 8600),
        (Date(), 15000)
    ]

    VStack {
        FiveDayStepsBarChart(data: sampleData)
            .frame(height: 120)
            .padding()
    }
}
