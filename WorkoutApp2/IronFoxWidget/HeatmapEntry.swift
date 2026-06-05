//
//  HeatmapEntry.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/26.
//


import WidgetKit
import SwiftUI

// Minimal model for decoding persisted workout entries in the widget target
// Keep in sync with the app's persisted schema (date + any other fields if needed).
private struct WorkoutEntry: Codable {
    let date: Date
}

struct HeatmapEntry: TimelineEntry {
    let date: Date
    let countsByDay: [Date: Int]
    let plannedTitle: String
    let plannedWorkouts: [String]
}

struct HeatmapProvider: TimelineProvider {
    func placeholder(in context: Context) -> HeatmapEntry {
        HeatmapEntry(date: Date(), countsByDay: [:], plannedTitle: "", plannedWorkouts: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (HeatmapEntry) -> Void) {
        let planned = loadPlannedWorkouts(for: Date())
        completion(HeatmapEntry(date: Date(), countsByDay: loadCounts(), plannedTitle: planned.title, plannedWorkouts: planned.workouts))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HeatmapEntry>) -> Void) {
        let planned = loadPlannedWorkouts(for: Date())
        let entry = HeatmapEntry(date: Date(), countsByDay: loadCounts(), plannedTitle: planned.title, plannedWorkouts: planned.workouts)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadCounts() -> [Date: Int] {
        let defaults = UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2")
        guard let data = defaults?.data(forKey: "workout_entries") else { return [:] }
        let decoder = JSONDecoder()
        // Ensure dates decode the same way they were encoded (default uses .deferredToDate)
        // Adjust `dateDecodingStrategy` here if your app encodes dates differently.
        if let entries = try? decoder.decode([WorkoutEntry].self, from: data) {
            let calendar = Calendar.current
            let grouped = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
            return grouped.mapValues { $0.count }
        } else {
            return [:]
        }
    }
    
    private func loadPlannedWorkouts(for date: Date) -> (title: String, workouts: [String]) {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        let rawValue: String
        switch weekdayNumber {
        case 1: rawValue = "sun"
        case 2: rawValue = "mon"
        case 3: rawValue = "tue"
        case 4: rawValue = "wed"
        case 5: rawValue = "thu"
        case 6: rawValue = "fri"
        default: rawValue = "sat"
        }

        let defaults = UserDefaults( suiteName: "group.Fox-Studios.WorkoutApp2")
        let title = defaults?.string(forKey: "planned_workouts_title_\(rawValue)") ?? ""
        let workouts = defaults?.stringArray(forKey: "planned_workouts_items_\(rawValue)") ?? []
        return (title, workouts)
    }
}

struct HeatmapWidgetView: View {
    var entry: HeatmapEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) private var colorScheme
    private let calendar = Calendar.current

    var body: some View {

        Group {
            switch family {
            case .systemSmall:
                smallView

            case .systemMedium:
                mediumView

            case .systemLarge:
                largeView

            default:
                mediumView
            }
        }
        .widgetURL(URL(string: "ironfox://workoutDetail")!)
        .containerBackground(for: .widget) {
            Rectangle().fill(
                colorScheme == .dark
                ? Color.black
                : Color.blue
            )
        }
    }

    // MARK: - Small: just the grid, no labels
    private var smallView: some View {
        VStack(spacing: 3) {
            Text(entry.date.formatted(.dateTime.month(.wide)))
                .font(.headline.bold())
                .foregroundStyle(.white.opacity(0.8))

            grid(hCellSize: 18, vCellSize: 18, hSpacing: 2, vSpacing: 2)
        }
        .padding(8)
    }

    // MARK: - Medium: grid + weekday headers
    private var mediumView: some View {
        VStack(){
            Text(entry.date.formatted(.dateTime.month(.wide).day()))
                .font(.headline.bold())
                .foregroundStyle(.white)
            
            HStack() {
                
                // Left: stats for today
                VStack(alignment: .center, spacing: 10) {
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                            .font(.title)
                        
                        Text("\(currentStreak)")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        Text("Day Streak")
                            .font(.headline).bold()
                            .foregroundStyle(.white)
                    }
                    
                    HStack(spacing: 4) {
                        Text("\(todayCount)")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        Text("Today")
                            .font(.subheadline).bold()
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .overlay(Color.white.opacity(0.2))
                
                // Right: heatmap
                VStack(spacing: 1) {
                    weekdayHeaders(fontSize: 12, spacing: 2)
                    grid(hCellSize: 18, vCellSize: 18, hSpacing: 3, vSpacing: 3)
                }
            }
            .padding(1)
        }
    }

    // MARK: - Large: grid + headers + workout count summary
    private var largeView: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.date.formatted(.dateTime.month(.wide).day(.twoDigits)))
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    Text(entry.date.formatted(.dateTime.year()))
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                HStack(spacing: 5) {
                    summaryItem(icon: "flame.fill", value: "\(totalWorkouts)", label: "Total")
                    summaryItem(icon: "calendar", value: "\(activeDays)", label: "Active Days")
                    summaryItem(icon: "chart.bar.fill", value: "\(bestDay)", label: "Best Day")
                }
            }

            // Heatmap
            VStack(spacing: 2) {
                weekdayHeaders(fontSize: 12, spacing: 0)  // ✅ spacing matches grid
                grid(hCellSize: 26, vCellSize: 22 ,hSpacing: 10, vSpacing: 4)
            }
            .frame(maxWidth: 250)

            Divider()

            // Planned workouts
            if entry.plannedWorkouts.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(.white.opacity(0.4))
                    Text("No workouts planned today")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.4))
                }
            } else {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.plannedTitle.isEmpty ? "Today's Plan" : entry.plannedTitle)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text("Tap to open app")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("\(entry.plannedWorkouts.count)")
                            .font(.title.bold())
                            .foregroundStyle(.green)
                        Text(entry.plannedWorkouts.count == 1 ? "workout" : "workouts")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(10)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(10)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(14)
    }

    // MARK: - Shared grid
    private func grid(hCellSize: CGFloat,vCellSize: CGFloat, hSpacing: CGFloat, vSpacing: CGFloat) -> some View {
        let cells: [Date?] = Array(repeating: nil, count: leadingBlanks) + daysInMonth

        return LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(hCellSize), spacing: hSpacing), count: 7),
            spacing: vSpacing  // ✅ this controls row spacing
        ) {
            ForEach(cells.indices, id: \.self) { i in
                if let day = cells[i] {
                    RoundedRectangle(cornerRadius: vCellSize * 0.2)
                        .fill(color(for: day))
                        .frame(width: hCellSize, height: vCellSize)
                } else {
                    Color.clear
                        .frame(width: hCellSize, height: vCellSize)
                }
            }
        }
    }

    // MARK: - Weekday headers
    private func weekdayHeaders(fontSize: CGFloat, spacing: CGFloat) -> some View {
        let days = ["S","M","T","W","T","F","S"]
        return HStack(spacing: spacing) {
            ForEach(days.indices, id: \.self) { i in
                Text(days[i])
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Summary item (large only)
    private func summaryItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
  //Was bring used for the Large Widget just couldn't get it. Saving incase I revist this.
//    private func workoutPill(_ name: String) -> some View {
//        HStack(spacing: 4) {
//            Circle()
//                .fill(.green.opacity(0.7))
//                .frame(width: 6, height: 6)
//            Text(name)
//                .font(.caption.bold())
//                .foregroundStyle(.white.opacity(0.85))
//                .lineLimit(1)
//                .minimumScaleFactor(0.6)  // ✅ shrinks text before truncating
//        }
//        .padding(.horizontal, 8)
//        .padding(.vertical, 4)
//        .frame(maxWidth: .infinity)  // ✅ each pill takes equal width
//        .background(.white.opacity(0.12), in: Capsule())
//    }
    
    private var todayCount: Int {
        entry.countsByDay[calendar.startOfDay(for: entry.date)] ?? 0
    }

    private var currentStreak: Int {
        var streak = 0
        var day = calendar.startOfDay(for: entry.date)
        while let count = entry.countsByDay[day], count > 0 {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }

    // MARK: - Helpers
    private var daysInMonth: [Date] {
        let comps = calendar.dateComponents([.year, .month], from: entry.date)
        let monthStart = calendar.date(from: comps)!
        let range = calendar.range(of: .day, in: .month, for: monthStart)!
        return range.compactMap { day -> Date? in
            var c = comps; c.day = day
            return calendar.date(from: c)
        }
    }

    private var leadingBlanks: Int {
        let comps = calendar.dateComponents([.year, .month], from: entry.date)
        let monthStart = calendar.date(from: comps)!
        return calendar.component(.weekday, from: monthStart) - 1
    }

    private func color(for date: Date) -> Color {
        color(count: entry.countsByDay[calendar.startOfDay(for: date)] ?? 0)
    }

    private func color(count: Int) -> Color {
        switch count {
        case 0:     return Color.white.opacity(0.28)
        case 1:     return Color.green.opacity(0.45)
        case 2...3: return Color.green.opacity(0.7)
        default:    return .green
        }
    }

    private var totalWorkouts: Int { entry.countsByDay.values.reduce(0, +) }
    private var activeDays: Int { entry.countsByDay.values.filter { $0 > 0 }.count }
    private var bestDay: Int { entry.countsByDay.values.max() ?? 0 }
}

struct IronFoxHeatmapWidget: Widget {
    let kind = "IronFoxHeatmapWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HeatmapProvider()) { entry in
            HeatmapWidgetView(entry: entry)
        }
        .configurationDisplayName("Workout Heatmap")
        .description("See your workout activity this month.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }

}

#Preview("Small", as: .systemSmall) {
    IronFoxHeatmapWidget()
} timeline: {
    HeatmapEntry(date: .now, countsByDay: sampleCounts, plannedTitle: "", plannedWorkouts: [])
}

#Preview("Medium", as: .systemMedium) {
    IronFoxHeatmapWidget()
} timeline: {
    HeatmapEntry(date: .now, countsByDay: sampleCounts, plannedTitle: "Leg Day", plannedWorkouts: ["Squats", "Lunges", "Leg Press"])
}

#Preview("Large", as: .systemLarge) {
    IronFoxHeatmapWidget()
} timeline: {
    HeatmapEntry(date: .now, countsByDay: sampleCounts, plannedTitle: "Leg Day", plannedWorkouts: ["Squats", "Lunges", "Leg Press", "Calf Raises","Squats", "Lunges", "Leg Press", "Calf Raises"])
}

private let sampleCounts: [Date: Int] = {
    let today = Calendar.current.startOfDay(for: .now)
    return [
        today: 2,
        Calendar.current.date(byAdding: .day, value: -1, to: today)!: 1,
        Calendar.current.date(byAdding: .day, value: -2, to: today)!: 3,
        Calendar.current.date(byAdding: .day, value: -4, to: today)!: 1,
        Calendar.current.date(byAdding: .day, value: -5, to: today)!: 2,
    ]
}()
