//
//  WorkoutCalendarView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/21/26.
//
import SwiftUI

struct WorkoutCalendarView: View {

    let entries: [WorkoutEntry]
    let comingFromWidget: Bool
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: AppRouter

    @State private var currentMonthOffset: Int = 0
    @State private var selectedDate: Date =
        Calendar.current.startOfDay(for: Date())
    
    @State private var showingAddWorkout = false

    @EnvironmentObject var workoutData: WorkoutData
    private var calendar: Calendar { .current }
    

    enum Weekday: String, CaseIterable, Identifiable {

        case sun, mon, tue, wed, thu, fri, sat

        var id: String { rawValue }

        var display: String {

            switch self {
            case .sun: return "Sun"
            case .mon: return "Mon"
            case .tue: return "Tue"
            case .wed: return "Wed"
            case .thu: return "Thu"
            case .fri: return "Fri"
            case .sat: return "Sat"
            }
        }
    }

    private var monthStart: Date {

        let base =
        calendar.date(
            byAdding: .month,
            value: currentMonthOffset,
            to: Date()
        ) ?? Date()

        let comps =
        calendar.dateComponents([.year, .month], from: base)

        return calendar.date(from: comps) ?? Date()
    }

    private var daysInMonth: [Date] {

        guard let range =
                calendar.range(
                    of: .day,
                    in: .month,
                    for: monthStart
                )
        else {
            return []
        }

        return range.compactMap { day -> Date? in

            var comps =
            calendar.dateComponents(
                [.year, .month],
                from: monthStart
            )

            comps.day = day

            return calendar.date(from: comps)
        }
    }

    private var countsByDay: [Date: Int] {

        let grouped = Dictionary(
            grouping: entries
        ) { e in
            calendar.startOfDay(for: e.date)
        }

        return grouped.mapValues { $0.count }
    }

    private var entriesByDay: [Date: [WorkoutEntry]] {

        Dictionary(grouping: entries) {
            calendar.startOfDay(for: $0.date)
        }
    }

    private func entries(for day: Date) -> [WorkoutEntry] {

        let key = calendar.startOfDay(for: day)

        return (entriesByDay[key] ?? [])
            .sorted { $0.date < $1.date }
    }

    private var lastStoredBodyWeightEntry: WorkoutEntry? {
        entries
            .filter {
                $0.workoutType == "Body Weight" &&
                !$0.weight.isEmpty &&
                calendar.startOfDay(for: $0.date) <= calendar.startOfDay(for: selectedDate)
            }
            .sorted { $0.date > $1.date }
            .first
    }
    private func color(for count: Int) -> Color {

        switch count {
        case 0:
            return Color.white.opacity(0.08)

        case 1:
            return Color.green.opacity(0.45)

        case 2...3:
            return Color.green.opacity(0.7)

        default:
            return .green
        }
    }

    private var monthTitle: String {

        monthStart.formatted(
            .dateTime
                .year()
                .month(.wide)
        )
    }

    var body: some View {

        NavigationStack {

            ZStack {

                // MARK: - Background
                LinearGradient(
                    colors: gradientSettings.darkGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {

                    VStack(spacing: 28) {

                        // MARK: - Month Header
                        HStack {

                            controlButton(
                                icon: "chevron.left",
                                color: .orange
                            ) {
                                currentMonthOffset -= 1
                            }

                            Spacer()

                            VStack(spacing: 4) {

                                Text(monthTitle)
                                    .font(
                                        .system(
                                            size: 30,
                                            weight: .bold,
                                            design: .rounded
                                        )
                                    )
                                    .foregroundStyle(.white)

                                Text("Workout Activity")
                                    .foregroundStyle(
                                        .white.opacity(0.7)
                                    )
                            }

                            Spacer()

                            controlButton(
                                icon: "chevron.right",
                                color: .blue
                            ) {
                                currentMonthOffset += 1
                            }
                        }

                        // MARK: - Calendar Card
                        VStack(spacing: 20) {

                            // Weekday labels
                            LazyVGrid(
                                columns: Array(
                                    repeating: GridItem(.flexible()),
                                    count: 7
                                )
                            ) {

                                ForEach(
                                    Weekday.allCases
                                ) { day in

                                    Text(day.display)
                                        .font(.caption.bold())
                                        .foregroundStyle(
                                            .white.opacity(0.7) // this just does the inside of the Big view.
                                        )
                                }
                            }

                            let firstWeekday =
                            calendar.component(
                                .weekday,
                                from: monthStart
                            )

                            let leadingBlanks =
                            firstWeekday - 1

                            let cells: [Date?] =
                                Array(
                                    repeating: nil,
                                    count: leadingBlanks
                                ) + daysInMonth

                            LazyVGrid(
                                columns: Array(
                                    repeating: GridItem(.flexible()),
                                    count: 7
                                ),
                                spacing: 10
                            ) {

                                ForEach(
                                    cells.indices,
                                    id: \.self
                                ) { idx in

                                    if let day = cells[idx] {

                                        let key =
                                        calendar.startOfDay(
                                            for: day
                                        )

                                        let count =
                                        countsByDay[key] ?? 0

                                        let isSelected =
                                        calendar.isDate(
                                            selectedDate,
                                            inSameDayAs: day
                                        )

                                        Button {

                                            selectedDate =
                                            calendar.startOfDay(
                                                for: day
                                            )

                                        } label: {

                                            ZStack {

                                                RoundedRectangle(
                                                    cornerRadius: 12
                                                )
                                                .fill(
                                                    isSelected
                                                    ? .white
                                                    : color(for: count)
                                                )

                                                Text(
                                                    "\(calendar.component(.day, from: day))"
                                                )
                                                .font(.headline.bold())
                                                .foregroundStyle(
                                                    isSelected
                                                    ? .black
                                                    : .white
                                                )
                                            }
                                            .frame(height: 44)
                                        }
                                        .buttonStyle(.plain)

                                    } else {

                                        Color.clear
                                            .frame(height: 44)
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.white.opacity(0.12))
                        )

                        // MARK: - Selected Day Card
                        VStack(alignment: .leading, spacing: 18) {

                            HStack {
                                VStack(alignment: .leading) {
                                    Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.title.bold())
                                        .foregroundStyle(.white)
                                }

                                Spacer()

                                if let w = displayedBodyWeight {
                                    VStack(alignment: .trailing) {
                                        Text("\(w)")
                                            .font(.title3.bold())
                                        Text("Body Weight")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.white)
                                }
                            }

                            Divider()
                                .overlay(
                                    Color.white.opacity(0.15)
                                )
                            
                            // MARK: - Workouts
                            HStack {
                                Spacer()
                                Button {
                                    showingAddWorkout = true
                                } label: {
                                    Label("Add Workout", systemImage: "plus.circle.fill")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(.white.opacity(0.15), in: Capsule())
                                }
                                .buttonStyle(.plain)
                            }

                            // MARK: - Workouts
                            if selectedDayEntries.isEmpty {

                                VStack(spacing: 14) {

                                    Image(systemName: "calendar")
                                        .font(.largeTitle)

                                    Text("No Workouts")
                                        .font(.headline.bold())

                                    Text(
                                        "No workouts logged for this day."
                                    )
                                    .foregroundStyle(
                                        .white.opacity(0.7)
                                    )
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .foregroundStyle(.white)

                            } else {

                                ForEach(selectedDayEntries) { e in
                                    NavigationLink(destination: EditWorkoutView(entry: e)
                                        .environmentObject(workoutData)
                                    ) {
                                        VStack(
                                            alignment: .leading,
                                            spacing: 10
                                        ) {
                                            HStack {
                                                Text(e.workoutType)
                                                    .font(.headline.bold())

                                                Spacer()

                                                if !e.weight.isEmpty {
                                                    statCapsule(text: e.weight)
                                                }

                                                if !e.reps.isEmpty {
                                                    statCapsule(text: "\(e.reps) reps")
                                                }

                                                if !e.sets.isEmpty {
                                                    statCapsule(text: "\(e.sets) sets")
                                                }
                                            }

                                            if !e.note.isEmpty {
                                                Text(e.note)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white.opacity(0.75))
                                            }
                                        }
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(.white.opacity(0.08))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.white.opacity(0.12))
                        )

                        // MARK: - Planned Workouts
                        let currentWeekday = weekday(from: selectedDate)
                        
                        let sharedDefaults = UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2")
                        let dayTitle = sharedDefaults?.string(forKey: keyTitle(for: currentWeekday)) ?? ""
                        let workouts = sharedDefaults?.stringArray(forKey: keyItems(for: weekday(from: selectedDate))) ?? []
                        if !workouts.isEmpty { // Made it so this is hidden to look cleaner
                            VStack(alignment: .leading, spacing: 18) {
                                
                                Label(
                                    "Planned Workouts",
                                    systemImage: "calendar.badge.plus"
                                )
                                .font(.headline)
                                .foregroundStyle(.white)
                                
                                if workouts.isEmpty {
                                    
                                    Text("No planned workouts")
                                        .foregroundStyle(
                                            .white.opacity(0.7)
                                        )
                                    
                                } else {
                                    //Add a text here with the title  of the day
                                    Text(dayTitle.isEmpty ? selectedDate.formatted(date: .complete, time: .omitted) : dayTitle)
                                        .font(.headline.bold())
                                        .foregroundStyle(.white.opacity(0.8))
                                    
                                    ForEach(
                                        workouts,
                                        id: \.self
                                    ) { workout in
                                        
                                        PlannedWorkoutDetailLink(
                                            workout: workout,
                                            category:
                                                categoryForWorkout(
                                                    workout
                                                )
                                        )
                                    }
                                }
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(.white.opacity(0.12))
                            )
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutForDateView(date: selectedDate)
                    .environmentObject(workoutData)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if comingFromWidget {
                    ToolbarItem(placement: .topBarLeading) {
                        Button{
                            router.activeScreen = nil
                        } label:{
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                    }
                }

                ToolbarItem(placement: .principal) {

                    Text("Workout Calendar")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarTrailing) {

                    NavigationLink(
                        destination: PlannedWorkoutsView()
                    ) {

                        Image(
                            systemName: "calendar.badge.plus"
                        )
                        .foregroundStyle(.white)
                    }
                }
            }
        }
    }
    
    private var selectedDayEntries: [WorkoutEntry] {
        entries(for: selectedDate)
    }

    private var displayedBodyWeight: String? {
        let forDay = selectedDayEntries.first {
            $0.workoutType == "Body Weight" && !$0.weight.isEmpty
        }?.weight
        return forDay ?? lastStoredBodyWeightEntry?.weight
    }
    
    private func keyTitle(for day: WorkoutCalendarView.Weekday) -> String {
        "planned_workouts_title_\(day.rawValue)"
    }

    // MARK: - Capsule
    func statCapsule(text: String) -> some View {

        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.15))
            .clipShape(Capsule())
            .foregroundStyle(.white)
    }

    // MARK: - Control Button
    func controlButton(
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(color.gradient)
                .clipShape(Circle())
                .shadow(radius: 8)
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

    private func keyCount(for day: Weekday) -> String {
        "planned_workouts_count_\(day.rawValue)"
    }

    private func keyItems(for day: Weekday) -> String {
        "planned_workouts_items_\(day.rawValue)"
    }

    private func keyItemCategories(for day: Weekday) -> String {
        "planned_workouts_categories_\(day.rawValue)"
    }

    private func weekday(from date: Date) -> Weekday {

        let weekdayNumber =
        calendar.component(.weekday, from: date)

        switch weekdayNumber {
        case 1: return .sun
        case 2: return .mon
        case 3: return .tue
        case 4: return .wed
        case 5: return .thu
        case 6: return .fri
        default: return .sat
        }
    }

    private struct PlannedWorkoutDetailLink: View {
           

        let workout: String
        let category: WorkoutCategory
        var saveAction: (WorkoutCategory) -> Void = { _ in }
        @State private var selections: [WorkoutCategory: String] = [:]
        @State private var weights: [WorkoutCategory: String] = [:]
        @State private var reps: [WorkoutCategory: String] = [:]
        @State private var sets: [WorkoutCategory: String] = [:]
        @State private var distances: [WorkoutCategory: String] = [:]
        @State private var times: [WorkoutCategory: String] = [:]
        @State private var notes: [WorkoutCategory: String] = [:]
        @State private var entriesLocal: [WorkoutEntry] = []
        @State private var showSavedToastLocal: Bool = false
        @State private var unitSystemRawLocal: String = UnitSystem.metric.rawValue

        @EnvironmentObject private var workoutData: WorkoutData

        // Simple flags and utilities to satisfy references
        @State private var showSavedToast: Bool = false
        private var GoToHomeScreenWhenSaved: Bool { false }

        // Provide a weight unit string for ImportView
        private var weightUnit: String { unitSystemRawLocal }

        // Increment/decrement helpers for dictionaries keyed by WorkoutCategory
        private func increment(_ dict: inout [WorkoutCategory: String], for category: WorkoutCategory, by step: Int) {
            let current = Int(dict[category] ?? "0") ?? 0
            dict[category] = String(current + step)
        }

        private func decrement(_ dict: inout [WorkoutCategory: String], for category: WorkoutCategory, by step: Int) {
            let current = Int(dict[category] ?? "0") ?? 0
            let next = max(0, current - step)
            dict[category] = String(next)
        }

        // Haptic feedback helpers
        private func feedbackSuccess() {
        #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        }

        private func feedbackError() {
        #if os(iOS)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
        }

        // Reset behavior used after save when GoToHomeScreenWhenSaved is true
        private func resetImportView() {
            selections.removeAll()
            weights.removeAll()
            reps.removeAll()
            sets.removeAll()
            distances.removeAll()
            times.removeAll()
            notes.removeAll()
        }

        var body: some View {

            NavigationLink {

                ImportView.CategoryDetailView(
                    category: category,
                    unitSystemRaw: $unitSystemRawLocal,
                    selections: $selections,
                    weights: $weights,
                    reps: $reps,
                    sets: $sets,
                    distances: $distances,
                    times: $times,
                    entries: $entriesLocal,
                    notes: $notes,
                    save: { saveEntry()},
                    increment: { dict, step in self.increment(&dict, for: category, by: Int(step)) },
                    decrement: { dict, step in self.decrement(&dict, for: category, by: Int(step)) },
                    weightUnitProvider: { self.weightUnit },
                    goHomeAfterSave: GoToHomeScreenWhenSaved,
                    showSavedToast: $showSavedToast,
                    resetParent: { resetImportView() }
                )
                .onAppear{
                    if selections[category] == nil {
                                    selections[category] = workout
                                }
                }

            } label: {

                HStack {

                    Image(systemName: "dumbbell.fill")

                    Text(workout)
                        .font(.headline.bold())

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                }
                .foregroundStyle(.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.white.opacity(0.08))
                )
            }
        }
        
        private func saveEntry() {
            WorkoutApp2.saveEntry(
                for: category,
                selections: selections,
                weights: weights,
                reps: reps,
                sets: sets,
                distances: distances,
                times: times,
                notes: notes,
                workoutData: workoutData,
                onSuccess: {
                    showSavedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        showSavedToast = false
                    }
                },
                onError: { }
            )
        }
    }
}

#Preview {

    let sampleEntries = [
        
        //All comments are based on June 1 so they will be wrong on other days but needed this for screen shots
        WorkoutEntry( // Tuesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -27,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Wednesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -26,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Wednesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -26,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Wednesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -26,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Wednesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -26,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Thursday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -25,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -24,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -24,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -24,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Monday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -21,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Monday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -21,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Monday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -21,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Monday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -21,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Monday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -21,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Monday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -21,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Wednesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -19,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Thursday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -18,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Thursday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -18,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Thursday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -18,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Thursday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -18,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -17,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        
        WorkoutEntry( //Monday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -14,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Tuesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -13,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Tuesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -13,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Tuesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -13,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Tuesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -13,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Tuesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -13,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Wednesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -12,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Thursday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -11,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -10,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -10,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -10,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -10,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -10,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -10,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -10,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -10,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        
        WorkoutEntry( //Monday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -7,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Tuesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -6,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Wednesday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -5,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( // Thursday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -4,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry( //Friday
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -3,
                to: Date()
            )!,
            note: "Felt great, nice form"
        ),
        WorkoutEntry(
            workoutType: "Squat",
            weight: "225",
            reps: "5",
            sets: "5",
            date: Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: Date()
            )!,
            note: "Felt good, nice form"
        ),
        WorkoutEntry(
            workoutType: "Body Weight",
            weight: "180",
            reps: "",
            sets: "",
            date: Date(),
            note: "Felt good, nice form"
        ),
        WorkoutEntry(
            workoutType: "Body Weight",
            weight: "190",
            reps: "",
            sets: "",
            date: Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: Date()
            )!,
            note: ""
        )
    ]

    NavigationStack {
        WorkoutCalendarView(entries: sampleEntries, comingFromWidget: false)
            .environmentObject(WorkoutData())
            .environmentObject(GradientSettings())
    }
}

