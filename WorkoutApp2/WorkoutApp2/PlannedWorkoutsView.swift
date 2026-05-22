//
//  PlannedWorkoutsView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 3/19/26.
//


import SwiftUI

struct PlannedWorkoutsView: View {

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Toolbar Button Sizes
    @State private var buttonHeight: CGFloat = 10
    @State private var buttonWidth: CGFloat = 10
    @State private var buttonTextSize: CGFloat = 18

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

    // MARK: - Dynamic Colors

    private var bgColor: Color {
        colorScheme == .dark
        ? Color.black
        : Color("#F3F4F6")
    }

    private var cardColor: Color {
        colorScheme == .dark
        ? Color(.systemGray6)
        : .white
    }

    private var secondaryCardColor: Color {
        colorScheme == .dark
        ? Color(.systemGray5)
        : Color(.systemGray6)
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : .primary
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                bgColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        daySelector
                        plannedCountCard
                        plannedItemsCard
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture {
                    isEditing = false
                }
            }
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)

            .toolbar {

                // LEFT
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .font(.system(size: buttonTextSize))
                    .padding(.horizontal, buttonWidth)
                    .padding(.vertical, buttonHeight)
                    .foregroundStyle(.white)
                }

                // CENTER
                ToolbarItem(placement: .principal) {
                    Text("Schedule")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                }

                // RIGHT
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveForDay(selectedDay)
                    } label: {
                        Text("Save")
                            .fontWeight(.semibold)
                            .font(.system(size: buttonTextSize))
                            .padding(.horizontal, buttonWidth)
                            .padding(.vertical, buttonHeight)
                    }
                    .foregroundStyle(.white)
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
        HStack(spacing: 8) {
            ForEach(Weekday.allCases) { day in
                Button(action: {
                    saveForDay(selectedDay)
                    selectedDay = day
                    loadForDay(day)
                }) {
                    Text(day.display)
                        .font(.system(size: 20).bold())
                        .foregroundColor(selectedDay == day ? .white : textColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedDay == day
                            ? Color.accentColor
                            : secondaryCardColor
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Planned Count Card

    private var plannedCountCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Workouts Planned")
                .font(.headline.bold())
                .foregroundStyle(textColor)

            HStack(spacing: 12) {

                Image(systemName: "calendar.badge.plus")
                    .foregroundStyle(.tint)

                Text("Number of workouts")
                    .font(.subheadline)
                    .foregroundStyle(textColor)

                Spacer()

                pillField(
                    text: $plannedCount,
                    placeholder: "3",
                    focus: $isEditing
                )
            }
        }
        .padding(16)
        .background(
            cardColor,
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .shadow(
            color: colorScheme == .dark
            ? .clear
            : .black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    // MARK: - Planned Workouts Card

    private var plannedItemsCard: some View {

        VStack(alignment: .leading, spacing: 14) {

            Text("Specific Workouts")
                .font(.headline.bold())
                .foregroundStyle(textColor)

            ForEach(plannedItems.indices, id: \.self) { idx in

                HStack(spacing: 12) {

                    Image(systemName: "list.bullet")
                        .foregroundStyle(.secondary)

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

                        HStack {

                            let cat = (
                                idx < plannedItemCategories.count
                                ? plannedItemCategories[idx]
                                : .bodyweight
                            )

                            Text(cat.title)
                                .foregroundStyle(textColor)

                            Image(systemName: "chevron.down")
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(
                            secondaryCardColor,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                    }

                    // WORKOUT MENU
                    Menu {

                        let cat = (
                            idx < plannedItemCategories.count
                            ? plannedItemCategories[idx]
                            : .bodyweight
                        )

                        ForEach(cat.workouts, id: \.self) { name in
                            Button(name) {
                                plannedItems[idx] = name
                            }
                        }

                    } label: {

                        HStack {

                            Text(
                                plannedItems[idx].isEmpty
                                ? "Select workout"
                                : plannedItems[idx]
                            )
                            .foregroundStyle(
                                plannedItems[idx].isEmpty
                                ? .secondary
                                : textColor
                            )

                            Image(systemName: "chevron.down")
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(
                            secondaryCardColor,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                    }

                    // DELETE BUTTON
                    Button {

                        plannedItems.remove(at: idx)

                        if idx < plannedItemCategories.count {
                            plannedItemCategories.remove(at: idx)
                        }

                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
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
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
        .padding(16)
        .background(
            cardColor,
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .shadow(
            color: colorScheme == .dark
            ? .clear
            : .black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    // MARK: - Persistence

    private func keyCount(for day: Weekday) -> String {
        "planned_workouts_count_\(day.rawValue)"
    }

    private func keyItems(for day: Weekday) -> String {
        "planned_workouts_items_\(day.rawValue)"
    }

    private func keyItemCategories(for day: Weekday) -> String {
        "planned_workouts_categories_\(day.rawValue)"
    }

    private func saveForDay(_ day: Weekday) {

        UserDefaults.standard.set(
            plannedCount,
            forKey: keyCount(for: day)
        )

        UserDefaults.standard.set(
            plannedItems,
            forKey: keyItems(for: day)
        )

        let catRaw = plannedItemCategories.map { $0.rawValue }

        UserDefaults.standard.set(
            catRaw,
            forKey: keyItemCategories(for: day)
        )
    }

    private func loadForDay(_ day: Weekday) {

        plannedCount =
        UserDefaults.standard.string(
            forKey: keyCount(for: day)
        ) ?? ""

        if let arr = UserDefaults.standard.array(
            forKey: keyItems(for: day)
        ) as? [String] {

            plannedItems = arr

        } else {

            plannedItems = []
        }

        if let catArr = UserDefaults.standard.array(
            forKey: keyItemCategories(for: day)
        ) as? [String] {

            plannedItemCategories =
            catArr.compactMap {
                WorkoutCategory(rawValue: $0)
            }

        } else {

            plannedItemCategories =
            Array(repeating: .bodyweight, count: plannedItems.count)
        }

        if plannedItemCategories.count < plannedItems.count {

            plannedItemCategories +=
            Array(
                repeating: .bodyweight,
                count: plannedItems.count - plannedItemCategories.count
            )

        } else if plannedItemCategories.count > plannedItems.count {

            plannedItemCategories =
            Array(plannedItemCategories.prefix(plannedItems.count))
        }
    }
}
#Preview {
    PlannedWorkoutsView()
}
