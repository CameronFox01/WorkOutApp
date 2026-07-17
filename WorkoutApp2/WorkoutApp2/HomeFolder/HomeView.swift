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
    
    @AppStorage("hasSeenHomeTutorial") private var hasSeenHomeTutorial: Bool = false
    @State private var showHomeTutorial = false
    
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userTargetWeight") private var targetWeight: String = ""
    @AppStorage("userAccountFirstSaved") private var accountFirstSaved: Date = .distantPast
    @AppStorage("userOriginalWeight") private var originalWeight: String = ""
    @AppStorage("userBaselineWeightForGoal") private var baselineWeightForGoal: String = ""
    @AppStorage("userTargetDaysOfWorkout") private var targetDaysOfWorkout: String = ""
    @AppStorage("weightGoalDirection") private var weightGoalDirection: String = "lose"
    private var gainWeight: Bool { weightGoalDirection == "gain" }
    @AppStorage("showBMI") private var showBMI: Bool = false
    @AppStorage("showMeasurement") private var showMeasurement: Bool = false
    @AppStorage("showDailyPlanner") private var showDailyPlanner: Bool = true
    @AppStorage("showWeeklyRecap") private var showWeeklyRecap: Bool = true
    @AppStorage("showWeightCard") private var showWeightCard: Bool = true
    @AppStorage("showCalorieCard") private var showCalorieCard: Bool = true
    @AppStorage("showTimerCard") private var showTimerCard: Bool = true
    @AppStorage("showStepsCard") private var showStepsCard: Bool = true
    @AppStorage("showCalendarCard") private var showCalendarCard: Bool = true
    @AppStorage("showRecentWorkouts") private var showRecentWorkouts: Bool = true
    @AppStorage("showAllImported") private var showAllImported: Bool = true
    
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
        }
    }
    
    var body: some View {
        NavigationStack {
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
                        if showWeightCard && showCalorieCard {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                WeightCard(
                                    weightUnit: weightUnit,
                                    progressPercentText: progressPercentText,
                                    progressIcon: progressIcon,
                                    progressColor: progressColor,
                                    onTap: { isPresentingWeightSheet = true; newWeightInput = weight }
                                )
                                .environmentObject(gradientSettings)
                                .tutorialHighlight("weightCalories")

                                CaloriesCard()
                            }
                        } else if showWeightCard && !showCalorieCard {
                            WeightCard(
                                weightUnit: weightUnit,
                                progressPercentText: progressPercentText,
                                progressIcon: progressIcon,
                                progressColor: progressColor,
                                onTap: { isPresentingWeightSheet = true; newWeightInput = weight }
                            )
                            .environmentObject(gradientSettings)
                        } else if !showWeightCard && showCalorieCard {
                            CaloriesCard()
                        }
                        
                        // Timer Section
                        if showTimerCard {
                            Group{
                                TimerView()
                                    .padding(.vertical)
                            }
                            .tutorialHighlight("timer")
                        }
                        
                        // Section for Steps and Calendar
                        if showStepsCard && showCalendarCard {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                StepsCard()
                                CalendarCard()
                            }
                            .padding(.horizontal)
                            .tutorialHighlight("stepsCalendar")
                        } else if showStepsCard && !showCalendarCard {
                            StepsCard()
                                .padding(.horizontal)
                        } else if !showStepsCard && showCalendarCard {
                            CalendarCard()
                                .padding(.horizontal)
                        }
                        
                        //Section for Weekly Recap View
                        if showWeeklyRecap{
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
                        }
                        
                        // Daily Planned Workouts
                        if showDailyPlanner{
                            DailyPlannedWorkoutsCard()
                                .padding(.horizontal)
                        }
                        
                        //Can be Hiden Section before Recent Workouts
                        if showBMI {
                            BMIView()
                                .padding(.horizontal)
                        }
                        
                        if showMeasurement {
                            MeasurementRecapView()
                                .padding(.horizontal)
                        }
                        //Section for Pasted Worked Outs
                        if showRecentWorkouts {
                                HStack {
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        
                                        Text("Recent Workouts")
                                            .font(.system(size: 30, weight: .bold))
                                            .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)
                                            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                                        
                                        Text("Your latest progress")
                                            .font(.subheadline)
                                            .foregroundStyle(gradientSettings.selectedPreset.subTextOnDarkBackground)
                                            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "flame.fill")
                                        .font(.title2)
                                        .foregroundStyle(.orange)
                                }
                                .tutorialHighlight("recentWorkouts")
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
                                        let workoutName = entry.workoutType
                                        let category = categoryForWorkout(workoutName)
                                        
                                        NavigationLink(
                                            destination: WorkoutChartView(
                                                workoutName: workoutName,
                                                entries: workoutData.entries,
                                                category: category,
                                                workout: workoutName
                                            )
                                        ) {
                                            WorkoutTypeCardView(entry: entry, weightUnit: weightUnit)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                            .padding(.horizontal)
                    
                    // Seeing all workouts that have been entered
                    Spacer().frame(height: 50)
                    
                    if showAllImported {
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
                            .font(.title3)
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
            }
            .tutorialOverlay(
                isPresented: $showHomeTutorial,
                steps: homeTutorialSteps,
                onFinish: {
                    hasSeenHomeTutorial = true
                }
            )
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
                
                if !hasSeenHomeTutorial {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showHomeTutorial = true
                    }
                }
                
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
                // Seed baseline for goal progress if missing and we have a current weight
                if baselineWeightForGoal.isEmpty, let w = Double(weight), !weight.isEmpty {
                    baselineWeightForGoal = String(w)
                }
            }
            .onChange(of: targetWeight) { _, newValue in
                UserDefaults.standard.set(false, forKey: "bodyWeightGoalReached")
                // When the goal value changes, capture current weight as new baseline
                if let _ = Double(newValue), let curr = Double(weight), !weight.isEmpty {
                    baselineWeightForGoal = String(curr)
                }
                print("baseline:", baselineWeightForGoal)
                print("current:", weight)
                print("target:", targetWeight)
            }
            .onChange(of: weightGoalDirection) { _, _ in
                guard let curr = Double(weight),
                      !weight.isEmpty else { return }
                baselineWeightForGoal = String(curr)
                print("🔄 baseline reset due to direction change:", baselineWeightForGoal)
            }
            .onChange(of: weight) { _, newValue in
                print("🔥 weight changed:", newValue)
            }
        }
    }
    private func categoryForWorkout(
        _ workout: String
    ) -> WorkoutCategory {

        for category in WorkoutCategory.allCases {

            if category.workouts().contains(workout) {
                return category
            }
        }

        return .bodyweight
    }
    
    private var progressIsGood: Bool {
        guard let curr = currentWeightValue,
              let _ = targetWeightValue else {
            return false
        }

        if gainWeight {
            // gaining: closer to higher weight is good
            return curr >= (Double(baselineWeightForGoal) ?? curr)
        } else {
            // losing: lower than baseline is good
            return curr <= (Double(baselineWeightForGoal) ?? curr)
        }
    }
    
    private var progressIcon: String {
        if gainWeight {
            // gain mode flips behavior
            return progressIsGood
                ? "chart.line.uptrend.xyaxis"
                : "chart.line.downtrend.xyaxis"
        } else {
            // lose mode normal behavior
            return progressIsGood
                ? "chart.line.downtrend.xyaxis"
                : "chart.line.uptrend.xyaxis"
        }
    }
    
    private var progressPercent: Double? {
        guard let curr = currentWeightValue,
              let tgt = targetWeightValue else {
            return nil
        }

        let base = Double(baselineWeightForGoal) ?? curr

        let totalNeeded = tgt - base
        let progress = curr - base

        guard totalNeeded != 0 else { return 0 }

        return (progress / totalNeeded) * 100
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
    

    
    private var progressPercentText: String? {
        guard let pct = progressPercent else { return nil }
        return String(format: "%.0f%%", pct)
    }
    
    private var homeTutorialSteps: [TutorialStep] {
        [
            TutorialStep(id: "weightCalories", title: "Weight & Calories", description: "Track today's weight progress and calories burned at a glance."),
            TutorialStep(id: "timer", title: "Timer", description: "Built-in stopwatch and countdown timer for your workouts."),
            TutorialStep(id: "stepsCalendar", title: "Steps & Calendar", description: "See today's steps and jump into your workout history."),
            TutorialStep(id: "recentWorkouts", title: "Recent Workouts", description: "Quickly revisit exercises you've logged recently. You can personalize which cards show here anytime in Settings.")
        ]
    }
    
    // Removed progressMovedDirectionPositive as unused
    
    // Then your function works perfectly:
    private var progressColor: Color? {
        guard let curr = currentWeightValue,
              let tgt = targetWeightValue,
              let base = Double(baselineWeightForGoal) else {
            return nil
        }

        // distance from goal (smaller is better)
        let currentDistance = abs(curr - tgt)
        let baselineDistance = abs(base - tgt)

        let isImproving = currentDistance <= baselineDistance

        if isImproving {
            return gradientSettings.selectedPreset.greenTextOnDarkBackground
        } else {
            return Color.red
        }
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

