//
//  WorkoutCalendarView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/21/26.
//
import SwiftUI

 struct WorkoutCalendarView: View {
    let entries: [WorkoutEntry]
    @State private var currentMonthOffset: Int = 0
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    private var calendar: Calendar { Calendar.current }
     
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
        VStack(spacing: 25) {
            // This entire HStack is for the Arrows and Month/Year
            HStack {
                Button(action: { currentMonthOffset -= 1 }) { Image(systemName: "chevron.left") }
                    .font(Font.largeTitle.bold())
                Spacer()
                Text(monthTitle)
                    .font(Font.largeTitle.bold())
                Spacer()
                Button(action: { currentMonthOffset += 1 }) { Image(systemName: "chevron.right") }
                    .font(Font.largeTitle.bold())
            }
            .padding(.horizontal)

            // This is the section for the calendar and heat map itself.
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
                                    .frame(height: 38)
                                    .overlay(
                                        Text("\(calendar.component(.day, from: day))")
                                            .font(.headline)
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
                
                let workouts = UserDefaults.standard.stringArray(
                    forKey: keyItems(for: weekday(from: selectedDate))
                ) ?? []

                // This is the Hstack for the selected Date and the users body weight on that day.
                HStack {
                    Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.title.bold())
                    Spacer()
                    if let w = bodyWeightForDay ?? fallbackWeight {
                        Text("Weight: \(w)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }

                //The section for no workouts completed on that day
                if dayEntries.isEmpty {
                    ContentUnavailableView("No workouts", systemImage: "calendar", description: Text("No workouts logged for this day."))
                } else { //The section for there being workouts on that day.
                    ForEach(dayEntries) { e in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(e.workoutType)
                                .font(.headline).bold()
                            Spacer()
                            if !e.weight.isEmpty { Text(e.weight).font(.headline) }
                            if !e.reps.isEmpty { Text("\(e.reps) reps").font(.headline) }
                            if !e.sets.isEmpty { Text("\(e.sets) sets").font(.headline) }
                        }
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                    }
                }
                Spacer()
                //Section for Schedule to be accessed and displayed here.
                VStack(alignment: .leading, spacing: 8){
                    Text("Planned Workouts")
                        .font(.title.bold())
                    if workouts.isEmpty {
                        Text("No planned workouts")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(workouts, id: \.self) { workout in
                            NavigationLink {
                                ImportView.CategoryDetailView(
                                    category: categoryForWorkout(workout),
                                    unitSystemRaw: .constant(UnitSystem.metric.rawValue),
                                    selections: .constant([
                                        categoryForWorkout(workout): workout
                                    ]),
                                    weights: .constant([:]),
                                    reps: .constant([:]),
                                    sets: .constant([:]),
                                    distances: .constant([:]),
                                    times: .constant([:]),
                                    entries: .constant([]),
                                    save: {},
                                    increment: { _, _ in },
                                    decrement: { _, _ in },
                                    weightUnitProvider: { "lbs" },
                                    goHomeAfterSave: false,
                                    showSavedToast: .constant(false),
                                    resetParent: {}
                                )
                            } label: {
                                Text(workout)
                                    .font(.title3.bold())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Workout Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Workout Calendar")
                    .font(.title).bold()
                    .foregroundStyle(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: PlannedWorkoutsView()) {
                    Image(systemName: "calendar.badge.plus")
                }
            }
        }
    }
     
     private func categoryForWorkout(_ workout: String) -> WorkoutCategory {
         for category in WorkoutCategory.allCases {
             if category.workouts.contains(workout) {
                 return category
             }
         }

         return .bodyweight
     }
     
     private func keyCount(for day: Weekday) -> String { "planned_workouts_count_\(day.rawValue)" }
     private func keyItems(for day: Weekday) -> String { "planned_workouts_items_\(day.rawValue)" }
     private func keyItemCategories(for day: Weekday) -> String { "planned_workouts_categories_\(day.rawValue)" }
     
     private func weekday(from date: Date) -> Weekday {
         let weekdayNumber = calendar.component(.weekday, from: date)

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
}

#Preview {
    let sampleEntries = [
        WorkoutEntry(
            workoutType: "Bench Press",
            weight: "185",
            reps: "8",
            sets: "3",
            date: Date()
        ),
        WorkoutEntry(
            workoutType: "Squat",
            weight: "225",
            reps: "5",
            sets: "5",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        ),
        WorkoutEntry(
            workoutType: "Body Weight",
            weight: "180",
            reps: "",
            sets: "",
            date: Date()
        ),
        WorkoutEntry(
            workoutType: "Body Weight",
            weight: "190",
            reps: "",
            sets: "",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        )
    ]

    NavigationView {
        WorkoutCalendarView(entries: sampleEntries)
    }
}
