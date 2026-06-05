//
//  PlannedWorkoutsView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 3/19/26.
//

import SwiftUI
import WidgetKit

struct PlannedWorkoutsView: View {
    private let sharedDefaults = UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2")!

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - Toolbar Button Sizes
    @State private var buttonHeight: CGFloat = 10
    @State private var buttonWidth: CGFloat = 10
    @State private var buttonTextSize: CGFloat = 18
    @State private var dayTitle: String = ""
    @State private var showSavedToast = false

    // MARK: - Weekdays
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

    // MARK: - Storage
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue

    // MARK: - Focus
    @FocusState private var isEditing: Bool

    // MARK: - State
    @State private var selectedDay: Weekday = .sun
    @State private var plannedCount: String = ""
    @State private var plannedItems: [String] = []
    @State private var plannedItemCategories: [WorkoutCategory] = []
    @State private var plannedReminderEnabled: Bool = true
    @State private var plannedTime: Date = {
        // default to 8:00 AM today
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 8
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }()

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {

                // Same gradient as TimeViewBig
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.9),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        daySelector
                        titleCard
                        plannedCountCard
                        plannedItemsCard
                        dayReminderCard
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture {
                    isEditing = false
                }
                .onChange(of: plannedReminderEnabled) { _, _ in
                    sharedDefaults.set(plannedReminderEnabled, forKey: keyEnabled(for: selectedDay))
                    scheduleReminderForDay(selectedDay)
                }
                .onChange(of: plannedTime) { _, _ in
                    sharedDefaults.set(plannedTime.timeIntervalSince1970, forKey: keyTime(for: selectedDay))
                    scheduleReminderForDay(selectedDay)
                }
            }
            .overlay(alignment: .top) {
                if showSavedToast {
                    savedToast
                }
            }
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Schedule")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveForDay(selectedDay)
                        withAnimation(.spring()) {
                           showSavedToast = true
                       }
                    } label: {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadForDay(selectedDay)
        }
    }

    // MARK: - Day Selector

    private var daySelector: some View {
        HStack(spacing: 6) {
            ForEach(Weekday.allCases) { day in
                Button(action: {
                    saveForDay(selectedDay)
                    selectedDay = day
                    loadForDay(day)
                }) {
                    Text(day.display)
                        .font(.system(size: 13).bold())
                        .foregroundStyle(selectedDay == day ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedDay == day
                                ? Color.blue
                                : Color.white.opacity(0.12)
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Title Card

    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            Label("Schedule Title", systemImage: "tag.fill")
                .font(.headline.bold())
                .foregroundStyle(.white)

            TextField("e.g. Leg Day", text: $dayTitle)
                .padding(12)
                .background(.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
                .font(.headline)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.white.opacity(0.10))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28))
        )
    }

    private var dayReminderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Planned Reminder", systemImage: "bell.fill")
                .font(.headline.bold())
                .foregroundStyle(.white)

            HStack {
                Image(systemName: plannedReminderEnabled ? "bell.fill" : "bell.slash.fill")
                    .foregroundStyle(.white.opacity(0.85))
                Text("Enable Reminder")
                    .foregroundStyle(.white)
                Spacer()
                Toggle("", isOn: $plannedReminderEnabled)
                    .labelsHidden()
            }
            .padding(12)
            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

            if plannedReminderEnabled {
                Divider().background(Color.white.opacity(0.2))

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(.white.opacity(0.85))
                        Text("Reminder Time")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                    }

                    DatePicker(
                        "",
                        selection: $plannedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .colorScheme(.dark)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "moon.zzz.fill")
                        .foregroundStyle(.secondary)
                    Text("Reminder disabled")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.white.opacity(0.10))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28))
        )
    }

    // MARK: - Planned Count Card

    private var plannedCountCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            Label("Number of Workouts Planned", systemImage: "calendar.badge.plus")
                .font(.headline.bold())
                .foregroundStyle(.white)

            HStack {
                Spacer()
                TextField("3", text: $plannedCount)
                    .keyboardType(.numberPad)
                    .focused($isEditing)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
                    .font(.headline.bold())
                Spacer()
           }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.white.opacity(0.10))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28))
        )
    }

    // MARK: - Planned Workouts Card

    private var plannedItemsCard: some View {
        VStack(alignment: .leading, spacing: 16) {

            Label("Specific Workouts", systemImage: "list.bullet.clipboard.fill")
                .font(.headline.bold())
                .foregroundStyle(.white)

            ForEach(plannedItems.indices, id: \.self) { idx in
                HStack(spacing: 10) {

                    // CATEGORY MENU
                    Menu {
                        ForEach(WorkoutCategory.allCases) { cat in
                            Button(cat.title) {
                                if idx < plannedItemCategories.count {
                                    plannedItemCategories[idx] = cat
                                } else {
                                    while plannedItemCategories.count < plannedItems.count {
                                        plannedItemCategories.append(.bodyweight)
                                    }
                                    plannedItemCategories[idx] = cat
                                }
                                plannedItems[idx] = ""
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            let cat = idx < plannedItemCategories.count
                                ? plannedItemCategories[idx]
                                : .bodyweight
                            Text(cat.title)
                                .foregroundStyle(.white)
                                .font(.subheadline)
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.white.opacity(0.6))
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // WORKOUT MENU
                    Menu {
                        let cat = idx < plannedItemCategories.count
                            ? plannedItemCategories[idx]
                            : .bodyweight
                        ForEach(cat.workouts(), id: \.self) { name in
                            Button(name) { plannedItems[idx] = name }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(plannedItems[idx].isEmpty ? "Select" : plannedItems[idx])
                                .foregroundStyle(plannedItems[idx].isEmpty ? .white.opacity(0.45) : .white)
                                .font(.subheadline)
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.white.opacity(0.6))
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Spacer()

                    // DELETE
                    Button {
                        plannedItems.remove(at: idx)
                        if idx < plannedItemCategories.count {
                            plannedItemCategories.remove(at: idx)
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                }
            }

            // ADD BUTTON
            Button {
                plannedItems.append("")
                plannedItemCategories.append(.bodyweight)
            } label: {
                Label("Add Workout", systemImage: "plus.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.white.opacity(0.10))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28))
        )
    }

    // MARK: - Persistence

    private func keyCount(for day: Weekday) -> String { "planned_workouts_count_\(day.rawValue)" }
    private func keyItems(for day: Weekday) -> String { "planned_workouts_items_\(day.rawValue)" }
    private func keyItemCategories(for day: Weekday) -> String { "planned_workouts_categories_\(day.rawValue)" }
    private func keyTitle(for day: Weekday) -> String { "planned_workouts_title_\(day.rawValue)" }
    private func keyTime(for day: Weekday) -> String { "planned_workout_time_\(day.rawValue)" }
    private func keyEnabled(for day: Weekday) -> String { "planned_workout_enabled_\(day.rawValue)" }

    private func saveForDay(_ day: Weekday) {
        sharedDefaults.set(plannedCount, forKey: keyCount(for: day))
        sharedDefaults.set(plannedItems, forKey: keyItems(for: day))
        sharedDefaults.set(plannedItemCategories.map { $0.rawValue }, forKey: keyItemCategories(for: day))
        sharedDefaults.set(dayTitle, forKey: keyTitle(for: day))
        sharedDefaults.set(plannedReminderEnabled, forKey: keyEnabled(for: day))
        sharedDefaults.set(plannedTime.timeIntervalSince1970, forKey: keyTime(for: day))
        scheduleReminderForDay(day)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Toast
    private var savedToast: some View {
        Text("Saved ✔︎")
            .font(.subheadline.bold())
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.spring()) {
                        showSavedToast = false
                    }
                }
            }
    }
    
    private func scheduleReminderForDay(_ day: Weekday) {

        let notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "notificationsEnabled")

        let enabledForDay = UserDefaults.standard.object(forKey: keyEnabled(for: day)) == nil
            ? true
            : UserDefaults.standard.bool(forKey: keyEnabled(for: day))

        guard notificationsEnabled else {
            NotificationHandler.shared.removeNotification(identifier: "planned_\(day.rawValue)")
            return
        }

        guard enabledForDay else {
            NotificationHandler.shared.removeNotification(identifier: "planned_\(day.rawValue)")
            return
        }

        guard !dayTitle.isEmpty else {
            NotificationHandler.shared.removeNotification(identifier: "planned_\(day.rawValue)")
            return
        }

        let ts = sharedDefaults.double(forKey: keyTime(for: day))
        let dateForTime = ts > 0 ? Date(timeIntervalSince1970: ts) : plannedTime
        let components = Calendar.current.dateComponents([.hour, .minute], from: dateForTime)

        let weekdayMap: [Weekday: Int] = [
            .sun: 1, .mon: 2, .tue: 3, .wed: 4, .thu: 5, .fri: 6, .sat: 7
        ]

        let weekdayInt = weekdayMap[day] ?? 1

        NotificationHandler.shared.scheduleWorkoutNotification(
            title: "Workout Reminder",
            body: "Today's workout: \(dayTitle)",
            weekday: weekdayInt,
            hour: components.hour ?? 8,
            minute: components.minute ?? 0,
            identifier: "planned_\(day.rawValue)"
        )

        // Verify it was actually registered
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let match = requests.filter { $0.identifier == "planned_\(day.rawValue)" }
            for r in match {
                print("   → \(r.identifier): \(r.trigger.debugDescription)")
            }
        }
    }

    private func loadForDay(_ day: Weekday) {
        plannedCount = sharedDefaults.string(forKey: keyCount(for: day)) ?? ""

        if let arr = sharedDefaults.array(forKey: keyItems(for: day)) as? [String] {
            plannedItems = arr
        } else {
            plannedItems = []
        }

        if let catArr = sharedDefaults.array(forKey: keyItemCategories(for: day)) as? [String] {
            plannedItemCategories = catArr.compactMap { WorkoutCategory(rawValue: $0) }
        } else {
            plannedItemCategories = Array(repeating: .bodyweight, count: plannedItems.count)
        }

        if plannedItemCategories.count < plannedItems.count {
            plannedItemCategories += Array(repeating: .bodyweight, count: plannedItems.count - plannedItemCategories.count)
        } else if plannedItemCategories.count > plannedItems.count {
            plannedItemCategories = Array(plannedItemCategories.prefix(plannedItems.count))
        }

        dayTitle = sharedDefaults.string(forKey: keyTitle(for: day)) ?? ""

        if sharedDefaults.object(forKey: keyEnabled(for: day)) == nil {
            plannedReminderEnabled = true
        } else {
            plannedReminderEnabled = sharedDefaults.bool(forKey: keyEnabled(for: day))
        }

        let ts = sharedDefaults.double(forKey: keyTime(for: day))
        if ts > 0 {
            plannedTime = Date(timeIntervalSince1970: ts)
        } else {
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            comps.hour = 8
            comps.minute = 0
            plannedTime = Calendar.current.date(from: comps) ?? Date()
        }
    }
}

#Preview {
    PlannedWorkoutsView()
}
