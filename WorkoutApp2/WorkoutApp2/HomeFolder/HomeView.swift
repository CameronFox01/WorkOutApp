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
    
    
    @Environment(\.colorScheme) private var colorScheme
    private var weightCardColor: Color { colorScheme == .dark ? .white : .black }
    private var weightCardSecondary: Color { colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.6) }
    
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userTargetWeight") private var targetWeight: String = ""
    @AppStorage("userAccountFirstSaved") private var accountFirstSaved: Date = .distantPast
    @AppStorage("userOriginalWeight") private var originalWeight: String = ""
    @AppStorage("userTargetDaysOfWorkout") private var targetDaysOfWorkout: String = ""
    
    //Calories or kCal here
    @AppStorage("energyLabel")
    private var energyLabel: String = "Calories"
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings
    
    //Profil Image Saved here
    @AppStorage("profileImageData") private var profileImageData: Data?
    
    //Calorie
    @State private var activeCalories: Double = 0
    
    //How many Workouts to show in Recent Workouts
    @AppStorage("numberOfWorkoutsToShow") private var numberOfWorkoutsToShow: Int = 12
    
    private var profileImage: UIImage? { //This is setting what the image needs to be.
        guard let data = profileImageData else { return nil }
        return UIImage(data: data)
    }
    
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
            ZStack{
                LinearGradient(
                    colors: gradientSettings.selectedPreset.swiftUIColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                ScrollView {
                    Spacer()
                    VStack(alignment: .leading, spacing: 24) {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 16
                            
                        ){
                            // Weight Section
                            Button {
                                isPresentingWeightSheet = true; newWeightInput = weight
                            } label: {
                                VStack(alignment: .center, spacing: 8) {
                                    Text("Weight")
                                        .font(.title2.bold())
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(weightCardColor)
                                    // Current weight prominent
                                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                                        Text(weight.isEmpty ? "—" : weight)
                                            .font(.system(size: 34, weight: .bold))
                                            .foregroundStyle(weightCardColor)
                                        Text(weightUnit)
                                            .font(.headline)
                                            .foregroundStyle(weightCardColor)
                                    }
                                    
                                    // Target
                                    HStack(spacing: 6) {
                                        Image(systemName: "target")
                                            .foregroundStyle(weightCardColor)
                                        Text("Target: \(targetWeight.isEmpty ? "—" : targetWeight) \(weightUnit)")
                                            .font(.subheadline)
                                            .foregroundStyle(weightCardColor)
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
                                            .foregroundStyle(weightCardSecondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                            }
                            .cardStyle()
                            
                            // Calorie Section
                            NavigationLink(destination: CaloriesDetailView(unitSystem: Hmanager.unitSystem)
                                .environmentObject(Hmanager)) {
                                    VStack(alignment: .center, spacing: 8) {
                                        Text("Calories Today")
                                            .font(.title2.bold())
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        
                                        if Hmanager.activeCalories == 0 {
                                            Text("\(Int(Int(Double(Hmanager.steps) * 0.04))) \(energyLabel)")
                                                .font(.title2).bold()
                                        } else {
                                            Text("\(Int(Hmanager.activeCalories)) \(energyLabel)")
                                                .font(.title2).bold()
                                        }
                                        
                                        if !Hmanager.lastFiveDaysCalories.isEmpty {
                                            FiveDayCaloriesBarChart(data: Hmanager.lastFiveDaysCalories)
                                                .frame(height: 60)
                                                .padding(.top, 4)
                                            
                                            HStack {
                                                Text("5-day avg:")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                Text("\(Hmanager.fiveDayAverageCalories)")
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
                                .cardStyle()
                                .buttonStyle(.plain)
                        }
                        
                        // Timer Section
                        Group{
                            TimerView()
                                .padding(.vertical)
                        }
                        
                        //.cardStyle()
                        
                        
                        //Section to get steps and distance
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 16
                        ) {
                            NavigationLink(destination: DistanceDetailView(unitSystem: Hmanager.unitSystem)
                                .environmentObject(Hmanager)) {
                                    VStack(alignment: .center, spacing: 8) {
                                        Text("Steps Today")
                                            .font(.title2.bold())
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        
                                        
                                        Text("\(Hmanager.steps)")
                                            .font(.title2)
                                            .bold()
                                        
                                        // 5-day mini bar chart
                                        if !Hmanager.getLastFiveDaysSteps.isEmpty {
                                            FiveDayStepsBarChart(data: Hmanager.getLastFiveDaysSteps)
                                                .frame(height: 60)
                                                .padding(.top, 4)
                                            
                                            HStack {
                                                Text("5-day avg:")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                Text("\(Hmanager.fiveDayAverageSteps)")
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
                                .cardStyle()
                            
                            NavigationLink(destination: WorkoutCalendarView(entries: workoutData.entries, comingFromWidget: false)) {
                                VStack(alignment: .leading) {
                                    Text("Calendar")
                                        .font(.title2.bold())
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    WorkoutHeatMapView(entries: workoutData.entries)
                                        .frame(height: 80)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                                //.background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                            .cardStyle()
                        }
                        .padding(.horizontal)
                        
                        //Section for Weekly Recap View
                        NavigationLink(
                            destination:
                                WeeklyRecapView(
                                    recap: weeklyRecap
                                )
                        ) {

                            WeeklyRecapCard(

                                workoutsCompleted:
                                    weeklyRecap.workoutsCompleted,

                                workoutsPlanned:
                                    weeklyRecap.workoutsPlanned,

                                streak:
                                    weeklyRecap.streak
                            )
                        }
                        .padding(.horizontal)
                        .buttonStyle(.plain)
                        
                        
                        //Section for Pasted Worked Outs
                        HStack {
                            
                            VStack(alignment: .leading, spacing: 4) {
                                
                                Text("Recent Workouts")
                                    .font(.system(size: 30, weight: .bold))
                                
                                Text("Your latest progress")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundStyle(.orange)
                        }
                        .padding(.horizontal)
                        //Creating the boxs for the workouts to be clicked on and carry you to more info on that workout
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 16
                        ) {
                            ForEach(lastEntryPerWorkoutType(from: workoutData.entries)) { entry in
                                NavigationLink(
                                    destination: WorkoutChartView(
                                        workoutName: entry.workoutType,
                                        entries: workoutData.entries
                                    )
                                ) {
                                    WorkoutTypeCardView(entry: entry, weightUnit: weightUnit)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Seeing all workouts that have been entered
                    Spacer().frame(height: 50)
                    
                    NavigationLink {
                        
                        AllImportedWorkoutsView()
                        
                    } label: {
                        
                        HStack(spacing: 12) {
                            
                            Image(systemName: "list.bullet")
                            
                            Text("See all imported workouts")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(.ultraThinMaterial)
                        )
                        .foregroundStyle(gradientSettings.selectedPreset.textColor)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Home")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AccountView()) {
                        if let uiImage = profileImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 46, height: 46)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            Color.white.opacity(0.4),
                                            lineWidth: 2
                                        )
                                )
                        } else {
                            Image(systemName: "person.circle")
                                .font(.title)
                                .foregroundStyle(Color.blue)
                        }
                    }
                }
            }
            .toolbarBackground(gradientSettings.selectedPreset.topColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $isPresentingWeightSheet) {
                WeightUpdateSheet(
                    unitSystem: Hmanager.unitSystem,
                    weightUnit: weightUnit,
                    comingFromWidget: false,
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
                            date: Date(),
                            note: ""
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
                Hmanager.fetchActiveCalories()
                
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
                        date: accountFirstSaved,
                        note: ""
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
    var heightUnit: String {
        Hmanager.unitSystem == .metric ? "cm" : "in"
    }
    
    var weightUnit: String {
        Hmanager.unitSystem == .metric ? "kg" : "lbs"
    }
    
    var weightDifference: Double? {
        guard let current = Double(weight),
              let target = Double(targetWeight) else {
            return nil
        }
        return abs(target - current)
    }
    
    private var weeklyRecap: WeeklyRecapData {

        let calendar = Calendar.current
        let now = Date()

        guard let weekStart =
            calendar.date(
                from: calendar.dateComponents(
                    [.yearForWeekOfYear, .weekOfYear],
                    from: now
                )
            )
        else {

            return WeeklyRecapData(
                workoutsCompleted: 0,
                workoutsPlanned: 0,
                totalVolume: 0,
                streak: 0,
                strongestExercise: "None",
                improvementPercent: 0,
                photosAdded: 0
            )
        }

        let weekEntries =
            workoutData.entries.filter {

                $0.date >= weekStart
            }

        let workoutsCompleted =
            Set(
                weekEntries.map {
                    calendar.startOfDay(
                        for: $0.date
                    )
                }
            ).count

        let totalVolume =
            weekEntries.reduce(0.0) {

                total, entry in

                let weight =
                    Double(entry.weight) ?? 0

                let reps =
                    Double(entry.reps) ?? 0

                let sets =
                    Double(entry.sets) ?? 0

                return total + (weight * reps * sets)
            }

        let strongestExercise =
            Dictionary(
                grouping: weekEntries,
                by: { $0.workoutType }
            )
            .max {

                $0.value.count <
                $1.value.count

            }?.key ?? "None"
        
        let planned =
        max(
            Int(targetDaysOfWorkout) ?? 0,
            1
        )

        return WeeklyRecapData(

            workoutsCompleted: workoutsCompleted,

            workoutsPlanned: planned,

            totalVolume: totalVolume,

            streak: calculateStreak(),

            strongestExercise: strongestExercise,

            improvementPercent: Int(calculateImprovementPercent()),

            photosAdded: photosAddedThisWeek()
        )
    }
    
    private func calculateStreak() -> Int {

        let calendar = Calendar.current

        let workoutDays =
            Set(
                workoutData.entries.map {

                    calendar.startOfDay(
                        for: $0.date
                    )
                }
            )

        var streak = 0

        let day =
            calendar.startOfDay(
                for: Date()
            )
        var startingDate = calendar.date(
            byAdding: .day,
            value: -1,
            to: day
        )
        
        while workoutDays.contains(startingDate!) {

            streak += 1

            guard let previous =
                calendar.date(
                    byAdding: .day,
                    value: -1,
                    to: startingDate!
                )
            else { break }

            startingDate = previous
        }
        
        if workoutDays.contains(day) {
            streak += 1
        }

        return streak
    }
    
    private func calculateImprovementPercent() -> Double {
        let calendar = Calendar.current
        let now = Date()

        guard let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)
        else { return 0 }

        let thisWeekEntries = workoutData.entries.filter { $0.date >= thisWeekStart }
        let lastWeekEntries = workoutData.entries.filter { $0.date >= lastWeekStart && $0.date < thisWeekStart }

        let volumeFor: ([WorkoutEntry]) -> Double = { entries in
            entries.reduce(0.0) { total, entry in
                let weight = Double(entry.weight) ?? 0
                let reps = Double(entry.reps) ?? 0
                let sets = Double(entry.sets) ?? 0
                return total + (weight * reps * sets)
            }
        }

        let thisVolume = volumeFor(thisWeekEntries)
        let lastVolume = volumeFor(lastWeekEntries)

        // Fall back to workout count comparison if no volume data
        if lastVolume == 0 && thisVolume == 0 {
            let lastCount = Set(lastWeekEntries.map { calendar.startOfDay(for: $0.date) }).count
            let thisCount = Set(thisWeekEntries.map { calendar.startOfDay(for: $0.date) }).count
            guard lastCount > 0 else { return 0 }
            return Double(thisCount - lastCount) / Double(lastCount) * 100
        }

        guard lastVolume > 0 else { return 0 }
        return ((thisVolume - lastVolume) / lastVolume) * 100
    }
    
    private func photosAddedThisWeek() -> Int {
        let calendar = Calendar.current
        let now = Date()

        guard let weekStart = calendar.date(
            from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: now
            )
        ) else { return 0 }

        do {
            let directory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first!

            let files = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.creationDateKey]
            )

            return files.filter { url in
                guard url.pathExtension.lowercased() == "jpg",
                      let attrs = try? url.resourceValues(forKeys: [.creationDateKey]),
                      let created = attrs.creationDate
                else { return false }
                return created >= weekStart
            }.count

        } catch {
            print("Failed to count photos: \(error)")
            return 0
        }
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
    
    func lastEntryPerWorkoutType(from entries: [WorkoutEntry]) -> [WorkoutEntry] {
        let sortedEntries = entries.sorted { $0.date > $1.date }
        
        var seen = Set<String>()
        var result: [WorkoutEntry] = []
        
        for entry in sortedEntries {
            if !seen.contains(entry.workoutType) {
                seen.insert(entry.workoutType)
                result.append(entry)
            }
        }
        
        return Array(result.prefix(numberOfWorkoutsToShow))
    }
    
    private var estimatedCaloriesToday: Int { Int(Double(Hmanager.steps) * 0.04) }
    
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
    
    // Then your function works perfectly:
    private var progressColor: Color? {
        guard let positive = progressMovedDirectionPositive else { return nil }
        return positive ? Color("AdaptiveGreen") : .red
    }
}
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

struct CardStyle: ViewModifier {

    func body(content: Content) -> some View {

        content
            //.padding(18)
            .frame(
                maxWidth: .infinity,
                minHeight: 120,
                alignment: .topLeading
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
                .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        Color.white.opacity(0.12),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: .black.opacity(0.08),
                radius: 12,
                x: 0,
                y: 5
            )
    }
}

struct WorkoutTypeCardView: View {
    @EnvironmentObject var gradientSettings: GradientSettings
    
    let entry: WorkoutEntry
    let weightUnit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {

                    Text(entry.workoutType)
                        .font(.headline.bold())
                        .foregroundStyle(.white)

                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 42, height: 42)

                    Image(systemName: cardIcon)
                        .foregroundStyle(.white)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 6) {

                if isDistanceCardio {

                    Label(
                        "\(entry.weight) \(distanceUnit)",
                        systemImage: "figure.walk"
                    )

                } else if isTimeCardio {

                    Label(
                        "\(entry.reps) min",
                        systemImage: "timer"
                    )

                } else {

                    Label(
                        "\(entry.reps) reps",
                        systemImage: "figure.strengthtraining.traditional"
                    )

                    Label(
                        "\(entry.weight) \(weightUnit)",
                        systemImage: "scalemass.fill"
                    )
                }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white.opacity(0.92))
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 165, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: gradientSettings.selectedPreset.cardColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .blue.opacity(0.22), radius: 10, x: 0, y: 6)
    }
    private var cardIcon: String {
        if isDistanceCardio {
            return "figure.run"
        }

        if isTimeCardio {
            return "timer"
        }

        return "dumbbell.fill"
    }
    
    private var isDistanceCardio: Bool {
        DistanceCardioWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }

    private var isTimeCardio: Bool {
        TimeCardioWorkout.allCases
            .map(\.rawValue)
            .contains(entry.workoutType)
    }

    private var distanceUnit: String {
        weightUnit == "lbs" ? "mi" : "km"
    }
}


extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
}

extension Color {
    static let darkGreen = Color(red: 0.0, green: 0.4, blue: 0.0)
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(WorkoutData())
            .environmentObject(HealthManager())
            .environmentObject(GradientSettings())
    }
}

