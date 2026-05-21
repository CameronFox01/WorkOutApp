//
//  PlannedWorkoutsView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 3/19/26.
//


import SwiftUI

struct PlannedWorkoutsView: View {
    //Sizing of the buttons in the tool bar
    @State private var buttonHeight: CGFloat = 10
    @State private var buttonWidth: CGFloat = 10
    @State private var buttonTextSize: CGFloat = 18
    
    //Envirment section
    @Environment(\.dismiss) private var dismiss
    
    // Weekday selection
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

    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    
    @FocusState private var isEditing: Bool

    @State private var selectedDay: Weekday = .sun
    @State private var plannedCount: String = ""
    @State private var plannedItems: [String] = [] // stores workout raw values
    @State private var plannedItemCategories: [WorkoutCategory] = []

    // Colors
    private let bgColor = Color(hex: "#F3F4F6")

    var body: some View {
        NavigationView {
            ZStack {
                bgColor.ignoresSafeArea()
                
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
                // Left Side
                ToolbarItem(placement: .topBarLeading){
                    Button("Close") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .font(.system(size: CGFloat(buttonTextSize)))
                    .padding(.horizontal, buttonWidth)
                    .padding(.vertical, buttonHeight)
                }
                //Middle Part
                ToolbarItem(placement: .principal) {
                    Text("Schedule")
                        .font(.title).bold()
                        .foregroundStyle(.white)
                }
                
                //Right Side
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        saveForDay(selectedDay)
                    } label: {
                        Text("Save")
                            .fontWeight(.semibold)
                            .font(.system(size: CGFloat(buttonTextSize)))
                            .padding(.horizontal, buttonWidth)
                            .padding(.vertical, buttonHeight)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadForDay(selectedDay)
        }
    }

    private var daySelector: some View {
        HStack(spacing: 8) {
            ForEach(Weekday.allCases) { day in
                Button(action: {
                    saveForDay(selectedDay) // save current before switching
                    selectedDay = day
                    loadForDay(day)
                }) {
                    Text(day.display)
                        .font(.system(size: CGFloat(20))).bold()
                        .foregroundColor(selectedDay == day ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedDay == day ? Color.accentColor : Color(.systemGray6))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var plannedCountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workouts Planned")
                .font(.headline).bold()
                .padding(.bottom, 4)

            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.plus")
                    .foregroundStyle(.tint)
                Text("Number of workouts")
                    .font(.subheadline)
                Spacer()
                pillField(text: $plannedCount, placeholder: "3", focus: $isEditing)
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var plannedItemsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Specific Workouts")
                .font(.headline).bold()

            ForEach(plannedItems.indices, id: \.self) { idx in
                HStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .foregroundStyle(.secondary)

                    // Category menu
                    Menu {
                        ForEach(WorkoutCategory.allCases) { cat in
                            Button(cat.title) {
                                if idx < plannedItemCategories.count {
                                    plannedItemCategories[idx] = cat
                                } else {
                                    // pad categories to match
                                    while plannedItemCategories.count < plannedItems.count { plannedItemCategories.append(.bodyweight) }
                                    plannedItemCategories[idx] = cat
                                }
                                // Reset workout selection when category changes
                                plannedItems[idx] = ""
                            }
                        }
                    } label: {
                        HStack {
                            let cat = (idx < plannedItemCategories.count ? plannedItemCategories[idx] : .bodyweight)
                            Text(cat.title)
                            Image(systemName: "chevron.down").foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    }

                    // Workout menu filtered by selected category
                    Menu {
                        let cat = (idx < plannedItemCategories.count ? plannedItemCategories[idx] : .bodyweight)
                        ForEach(cat.workouts, id: \.self) { name in
                            Button(name) {
                                plannedItems[idx] = name
                            }
                        }
                    } label: {
                        HStack {
                            Text(plannedItems[idx].isEmpty ? "Select workout" : plannedItems[idx])
                                .foregroundStyle(plannedItems[idx].isEmpty ? .secondary : .primary)
                            Image(systemName: "chevron.down").foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        // Remove item and its category in sync
                        plannedItems.remove(at: idx)
                        if idx < plannedItemCategories.count { plannedItemCategories.remove(at: idx) }
                    } label: {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                plannedItems.append("")
                plannedItemCategories.append(.bodyweight)
            } label: {
                Label("Add Workout", systemImage: "plus.circle.fill")
                    .font(.subheadline).bold()
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    // MARK: - Persistence
    private func keyCount(for day: Weekday) -> String { "planned_workouts_count_\(day.rawValue)" }
    private func keyItems(for day: Weekday) -> String { "planned_workouts_items_\(day.rawValue)" }
    private func keyItemCategories(for day: Weekday) -> String { "planned_workouts_categories_\(day.rawValue)" }

    private func saveForDay(_ day: Weekday) {
        UserDefaults.standard.set(plannedCount, forKey: keyCount(for: day))
        UserDefaults.standard.set(plannedItems, forKey: keyItems(for: day))
        let catRaw = plannedItemCategories.map { $0.rawValue }
        UserDefaults.standard.set(catRaw, forKey: keyItemCategories(for: day))
    }

    private func loadForDay(_ day: Weekday) {
        plannedCount = UserDefaults.standard.string(forKey: keyCount(for: day)) ?? ""
        if let arr = UserDefaults.standard.array(forKey: keyItems(for: day)) as? [String] {
            plannedItems = arr
        } else {
            plannedItems = []
        }

        if let catArr = UserDefaults.standard.array(forKey: keyItemCategories(for: day)) as? [String] {
            plannedItemCategories = catArr.compactMap { WorkoutCategory(rawValue: $0) }
        } else {
            plannedItemCategories = Array(repeating: .bodyweight, count: plannedItems.count)
        }

        // Ensure arrays stay aligned
        if plannedItemCategories.count < plannedItems.count {
            plannedItemCategories += Array(repeating: .bodyweight, count: plannedItems.count - plannedItemCategories.count)
        } else if plannedItemCategories.count > plannedItems.count {
            plannedItemCategories = Array(plannedItemCategories.prefix(plannedItems.count))
        }
    }
}

// Color helper
fileprivate extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self = Color(red: r, green: g, blue: b)
    }
}

#Preview {
    PlannedWorkoutsView()
}
