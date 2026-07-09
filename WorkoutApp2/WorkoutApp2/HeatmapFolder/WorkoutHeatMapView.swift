//
//  WorkoutHeatMapView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/8/26.
//
import SwiftUI
import Foundation

struct WorkoutHeatMapView: View {
    let entries: [WorkoutEntry]
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings

    private var countsByDay: [Date: Int] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { e in calendar.startOfDay(for: e.date) }
        return grouped.mapValues { $0.count }
    }

    private var last7Days: [Date] {  // ✅ Changed from 30 to 7
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<7).compactMap { cal.date(byAdding: .day, value: -$0, to: today) }.reversed()
    }

    private func color(for count: Int) -> Color {
        switch count {
        case 0: return Color.gray.opacity(0.15)
        case 1: return Color.green.opacity(0.4)
        case 2...3: return Color.green.opacity(0.7)
        default: return Color.green
        }
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 4) {
            ForEach(last7Days, id: \.self) { day in
                let c = countsByDay[day] ?? 0
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color(for: c))
                        .frame(height: 30)
                    Text(day.formatted(.dateTime.weekday(.narrow)))
                        .font(.system(size: 12))
                        .foregroundColor(gradientSettings.selectedPreset.textOnDarkBackground)
                }
            }
        }
    }
}
