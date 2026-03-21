//
//  HomeView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI
import HealthKit

struct HomeView: View {
    @EnvironmentObject var Hmanager: HealthManager
    @EnvironmentObject var workoutData: WorkoutData
    
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userTargetWeight") private var targetWeight: String = ""
    @AppStorage("userAccountFirstSaved") private var accountFirstSaved: Date = .distantPast
    @AppStorage("userOriginalWeight") private var originalWeight: String = ""
    
    let healthStore = HKHealthStore()
    
    @State private var workoutLog: [WorkoutEntry] = {
        if let data = UserDefaults.standard.data(forKey: "workout_entries"),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            return decoded
        }
        return []
    }()
    @State private var isPresentingWeightSheet = false
    @State private var newWeightInput: String = ""
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "workoutLog"),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            print("Loaded workoutLog:")
            for entry in decoded {
                print("\(entry.workoutType) - \(entry.reps) reps - \(entry.weight) weight - \(entry.date)")
            }
        } else {
            print("No workoutLog found in UserDefaults.")
        }
    }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    GroupBox(label: Text("Current Progress")) {
                        Button { isPresentingWeightSheet = true; newWeightInput = weight } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                // Current weight prominent
                                HStack(alignment: .firstTextBaseline, spacing: 6) {
                                    Text(weight.isEmpty ? "—" : weight)
                                        .font(.system(size: 34, weight: .bold))
                                    Text(weightUnit)
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                }

                                // Target
                                HStack(spacing: 6) {
                                    Image(systemName: "target")
                                        .foregroundStyle(.secondary)
                                    Text("Target: \(targetWeight.isEmpty ? "—" : targetWeight) \(weightUnit)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                // Progress percentage from original weight
                                if let pct = progressPercentText, let color = progressColor {
                                    HStack(spacing: 6) {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .foregroundStyle(color)
                                        Text(pct)
                                            .font(.subheadline).bold()
                                            .foregroundStyle(color)
                                    }
                                } else {
                                    Text("Set target weight to see progress")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                        }
                    }
                    //Section to get steps and distance
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {

                        NavigationLink(destination: DistanceDetailView(unitSystem: unitSystem)
                                        .environmentObject(Hmanager)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Steps Today")
                                    .font(.headline)

                                Text("\(Hmanager.steps)")
                                    .font(.title2)
                                    .bold()

                                // 5-day mini bar chart
                                if !lastFiveDaysSteps.isEmpty {
                                    FiveDayStepsBarChart(data: lastFiveDaysSteps)
                                        .frame(height: 60)
                                        .padding(.top, 4)

                                    HStack {
                                        Text("5-day avg:")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("\(fiveDayAverageSteps)")
                                            .font(.caption)
                                            .bold()
                                            .foregroundStyle(.secondary)
                                    }
                                } else {
                                    Text("5-day history unavailable")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: WorkoutCalendarView(entries: workoutData.entries)) {
                            VStack(alignment: .leading) {
                                Text("Calendar")
                                    .font(.headline)
                                WorkoutHeatMapView(entries: workoutData.entries)
                                    .frame(height: 80)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    //Divider().padding(.vertical)

                    //Section for Pasted Worked Outs
                    Text("Recent Workouts")
                        .font(.title2)
                        .bold()
                        .padding(.leading)
                    //Creating the boxs for the workouts to be clicked on and carry you to more info on that workout
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {
                        ForEach(firstEntryPerWorkoutType(from: workoutData.entries)) { entry in
                            NavigationLink(
                                destination: WorkoutChartView(
                                    workoutName: entry.workoutType,
                                    entries: workoutData.entries
                                )
                            ) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.workoutType)
                                        .font(.headline)

                                    Text("\(entry.reps) reps at \(entry.weight) \(weightUnit)")
                                        .foregroundColor(.gray)

                                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.subheadline)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AccountView()) {
                        Image(systemName: "person.circle")
                            .font(.title)
                    }
                }
            }
            .sheet(isPresented: $isPresentingWeightSheet) {
                WeightUpdateSheet(
                    unitSystem: unitSystem,
                    weightUnit: weightUnit,
                    currentWeight: $weight,
                    newWeightInput: $newWeightInput,
                    entries: workoutData.entries,
                    onSave: { valueString in
                        // Update AppStorage so Account and others reflect immediately
                        weight = valueString
                        // Append a new WorkoutEntry of type "Body Weight"
                        let entry = WorkoutEntry(
                            workoutType: "Body Weight",
                            weight: valueString,
                            reps: "",
                            sets: "",
                            date: Date()
                        )
                        workoutData.add(entry: entry)
                    },
                    unitSystemRaw: unitSystemRaw
                )
            }
            .onAppear {
                Hmanager.fetchSteps()
                Hmanager.fetchDistance()
                Hmanager.fetchLastFiveDaysSteps()

                // Seed initial Body Weight entry if none exists, using the first time account info was saved
                let hasBodyWeight = workoutData.entries.contains { $0.workoutType == "Body Weight" }
                if !hasBodyWeight, let w = Double(weight), !weight.isEmpty {
                    // If we don't yet have a recorded first-saved date, set it now
                    if accountFirstSaved == .distantPast {
                        accountFirstSaved = Date()
                    }
                    let seed = WorkoutEntry(
                        workoutType: "Body Weight",
                        weight: String(w),
                        reps: "",
                        sets: "",
                        date: accountFirstSaved
                    )
                    workoutData.add(entry: seed)
                }
                // Seed original weight if not set
                if originalWeight.isEmpty, !weight.isEmpty, Double(weight) != nil {
                    originalWeight = weight
                }
            }
        }
    }

    var groupedWorkouts: [WorkoutEntry] {
        uniqueWorkoutEntries(from: workoutData.entries.sorted(by: { $0.date > $1.date }))
    }

    // MARK: - Computed properties

    var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }

    var heightUnit: String {
        unitSystem == .metric ? "cm" : "in"
    }

    var weightUnit: String {
        unitSystem == .metric ? "kg" : "lbs"
    }
    
    var weightDifference: Double? {
            guard let current = Double(weight),
                  let target = Double(targetWeight) else {
                return nil
            }
            return abs(target - current)
        }
    
    func uniqueWorkoutEntries(from all: [WorkoutEntry]) -> [WorkoutEntry] {
            var seen = Set<String>()
            var unique: [WorkoutEntry] = []

            for entry in all {
                if !seen.contains(entry.workoutType) {
                    seen.insert(entry.workoutType)
                    unique.append(entry)
                }
            }
            return unique
        }
    
    func firstEntryPerWorkoutType(from entries: [WorkoutEntry]) -> [WorkoutEntry] {
        var seen = Set<String>()

        return entries.filter { entry in
            if seen.contains(entry.workoutType) {
                return false
            } else {
                seen.insert(entry.workoutType)
                return true
            }
        }
    }
    
    // Section to formate the distance pulled from the health app.
    var formattedDistance: String {
        if unitSystem == .metric {
            let km = Hmanager.distance / 1000
            return String(format: "%.2f km", km)
        } else {
            let miles = Hmanager.distance / 1609.34
            return String(format: "%.2f mi", miles)
        }
    }
    
    private var lastFiveDaysSteps: [(date: Date, steps: Int)] {
        Hmanager.lastFiveDaysSteps
    }
    
    private var fiveDayAverageSteps: Int {
        let total = lastFiveDaysSteps.reduce(0) { $0 + $1.steps }
        return lastFiveDaysSteps.isEmpty ? 0 : total / lastFiveDaysSteps.count
    }
    
    private var currentWeightValue: Double? { Double(weight) }
    private var targetWeightValue: Double? { Double(targetWeight) }
    private var originalWeightValue: Double? { Double(originalWeight) }

    // Percentage progress from original toward target. Positive = closer, negative = farther.
    private var progressPercent: Double? {
        guard let orig = originalWeightValue,
              let curr = currentWeightValue,
              let tgt = targetWeightValue,
              orig != tgt else { return nil }
        
        let total = abs(tgt - orig)
        if total == 0 { return nil }
        
        let remaining = abs(tgt - curr)
        // ✅ Don't clamp — allow negative progress (moved away from target)
        let progressed = total - remaining
        return (progressed / total) * 100.0
    }

    private var progressPercentText: String? {
        guard let pct = progressPercent else { return nil }
        // ✅ Use the actual sign from the number itself
        if pct >= 0 {
            return String(format: "Progress: +%.0f%%", pct)
        } else {
            return String(format: "Progress: %.0f%%", pct)  // already has minus sign
        }
    }

    private var progressMovedDirectionPositive: Bool? {
        guard let pct = progressPercent else { return nil }
        return pct >= 0
    }

    private var progressColor: Color? {
        guard let positive = progressMovedDirectionPositive else { return nil }
        return positive ? .green : .red
    }

}

private struct FiveDayStepsBarChart: View {
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
                ForEach(Array(data.enumerated()), id: \.offset) { idx, item in
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

private struct FiveDayStepsBarChartWithValues: View {
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
                            .foregroundStyle(.secondary)
                            .frame(width: barWidth)

                        ZStack(alignment: .bottom) {
                            // Background track
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: barWidth, height: chartHeight)

                            // Filled bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor.opacity(0.7))
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

private struct WeightUpdateSheet: View {
    let unitSystem: UnitSystem
    let weightUnit: String
    @Binding var currentWeight: String
    @Binding var newWeightInput: String
    var entries: [WorkoutEntry]
    let onSave: (String) -> Void
    let unitSystemRaw: String

    @Environment(\.dismiss) private var dismiss

    private var bodyWeightEntries: [WorkoutEntry] {
        entries.filter { $0.workoutType == "Body Weight" }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Mini chart using existing WorkoutProgressChart for consistency
                WorkoutProgressChart(
                    workoutName: "Body Weight",
                    entries: entries,
                    unitSystemRaw: unitSystemRaw
                )
                .frame(height: 220)
                .padding(.horizontal)
                .padding(.top)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Enter new weight (") + Text(weightUnit).bold() + Text(")")
                    HStack(spacing: 12) {
                        TextField("e.g. 180", text: $newWeightInput)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Stepper("", onIncrement: {
                            let current = Double(newWeightInput) ?? Double(currentWeight) ?? 0
                            newWeightInput = String(format: "%.1f", current + (unitSystem == .imperial ? 1.0 : 0.5))
                        }, onDecrement: {
                            let current = Double(newWeightInput) ?? Double(currentWeight) ?? 0
                            let next = max(0, current - (unitSystem == .imperial ? 1.0 : 0.5))
                            newWeightInput = String(format: "%.1f", next)
                        })
                        .labelsHidden()
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Update Weight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = newWeightInput.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty, Double(trimmed) != nil else { return }
                        onSave(trimmed)
                        currentWeight = trimmed
                        dismiss()
                    }
                    .disabled(Double(newWeightInput) == nil)
                }
            }
        }
    }
}

private struct DistanceDetailView: View {
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
                        VStack(alignment: .trailing, spacing: 8) {
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
        .navigationTitle("Activity")
        .onAppear {
            Hmanager.fetchSteps()
            Hmanager.fetchDistance()
            Hmanager.fetchLastFiveDaysSteps()
        }
    }
}

private struct WorkoutHeatMapView: View {
    let entries: [WorkoutEntry]

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
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

private struct WorkoutCalendarView: View {
    let entries: [WorkoutEntry]
    @State private var currentMonthOffset: Int = 0
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    private var calendar: Calendar { Calendar.current }

    private var monthStart: Date {
        let base = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
        let comps = calendar.dateComponents([.year, .month], from: base)
        return calendar.date(from: comps) ?? Date()
    }

    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        return range.compactMap { day -> Date? in
            var comps = calendar.dateComponents([.year, .month], from: monthStart)
            comps.day = day
            return calendar.date(from: comps)
        }
    }

    private var countsByDay: [Date: Int] {
        let grouped = Dictionary(grouping: entries) { e in calendar.startOfDay(for: e.date) }
        return grouped.mapValues { $0.count }
    }
    
    private var entriesByDay: [Date: [WorkoutEntry]] {
        Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
    }

    private func entries(for day: Date) -> [WorkoutEntry] {
        let key = calendar.startOfDay(for: day)
        return (entriesByDay[key] ?? []).sorted { $0.date < $1.date }
    }

    private var lastStoredBodyWeightEntry: WorkoutEntry? {
        entries
            .filter { $0.workoutType == "Body Weight" }
            .sorted { $0.date > $1.date }
            .first
    }

    private func color(for count: Int) -> Color {
        switch count {
        case 0: return Color.gray.opacity(0.15)
        case 1: return Color.green.opacity(0.4)
        case 2...3: return Color.green.opacity(0.7)
        default: return Color.green
        }
    }

    private var monthTitle: String {
        monthStart.formatted(.dateTime.year().month(.wide))
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { currentMonthOffset -= 1 }) { Image(systemName: "chevron.left") }
                Spacer()
                Text(monthTitle).font(.headline)
                Spacer()
                Button(action: { currentMonthOffset += 1 }) { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal)

            let firstWeekday = calendar.component(.weekday, from: monthStart)
            let leadingBlanks = (firstWeekday + 5) % 7 // make Monday=1 alignment

            let cells: [Date?] = Array(repeating: nil, count: leadingBlanks) + daysInMonth

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(cells.indices, id: \.self) { idx in
                    if let day = cells[idx] {
                        let key = calendar.startOfDay(for: day)
                        let count = countsByDay[key] ?? 0
                        VStack {
                            Button {
                                selectedDate = calendar.startOfDay(for: day)
                            } label: {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(color(for: count))
                                    .frame(height: 32)
                                    .overlay(
                                        Text("\(calendar.component(.day, from: day))")
                                            .font(.caption2)
                                            .foregroundColor(.primary)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        Color.clear.frame(height: 32)
                    }
                }
            }
            .padding(.horizontal)
            
            // Details for selected day
            VStack(alignment: .leading, spacing: 8) {
                let dayEntries = entries(for: selectedDate)
                let bodyWeightForDay = dayEntries.first(where: { $0.workoutType == "Body Weight" && !$0.weight.isEmpty })?.weight
                let fallbackWeight = lastStoredBodyWeightEntry?.weight

                HStack {
                    Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)
                    Spacer()
                    if let w = bodyWeightForDay ?? fallbackWeight {
                        Text("Weight: \(w)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                if dayEntries.isEmpty {
                    ContentUnavailableView("No workouts", systemImage: "calendar", description: Text("No workouts logged for this day."))
                } else {
                    ForEach(dayEntries) { e in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(e.workoutType)
                                .font(.subheadline).bold()
                            Spacer()
                            if !e.weight.isEmpty { Text(e.weight) }
                            if !e.reps.isEmpty { Text("\(e.reps) reps") }
                            if !e.sets.isEmpty { Text("\(e.sets) sets") }
                        }
                        .foregroundColor(.primary)
                        .padding(.vertical, 2)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Workout Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: PlannedWorkoutsView()) {
                    Image(systemName: "calendar.badge.plus")
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(WorkoutData())
            .environmentObject(HealthManager())
    }
}

