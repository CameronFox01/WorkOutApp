//
//  PlannedWorkoutsView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 3/19/26.
//


import SwiftUI

struct PlannedWorkoutsView: View {
    // Weekday selection
    enum Weekday: String, CaseIterable, Identifiable {
        case mon, tue, wed, thu, fri, sat, sun
        var id: String { rawValue }
        var display: String {
            switch self {
            case .mon: return "Mon"
            case .tue: return "Tue"
            case .wed: return "Wed"
            case .thu: return "Thu"
            case .fri: return "Fri"
            case .sat: return "Sat"
            case .sun: return "Sun"
            }
        }
    }

    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue

    @State private var selectedDay: Weekday = .mon
    @State private var plannedCount: String = ""
    @State private var plannedItems: [String] = [] // stores workout raw values

    // Colors
    private let bgColor = Color(hex: "#F3F4F6")

    var body: some View {
        NavigationView {
            ZStack {
                bgColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        daySelector
                        plannedCountCard
                        plannedItemsCard
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Planned Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveForDay(selectedDay)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadForDay(selectedDay)
        }
    }

    @Environment(\.dismiss) private var dismiss

    private var daySelector: some View {
        HStack(spacing: 8) {
            ForEach(Weekday.allCases) { day in
                Button(action: {
                    saveForDay(selectedDay) // save current before switching
                    selectedDay = day
                    loadForDay(day)
                }) {
                    Text(day.display)
                        .font(.subheadline).bold()
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
                pillField(text: $plannedCount, placeholder: "3")
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
                    // A menu-based picker for a workout item
                    Menu {
                        // Grouped by category using your enums
                        workoutMenuSection("Bodyweight", items: BodyweightWorkout.allCases.map(\.rawValue))
                        workoutMenuSection("Push", items: PushWorkout.allCases.map(\.rawValue))
                        workoutMenuSection("Pull", items: PullWorkout.allCases.map(\.rawValue))
                        workoutMenuSection("Leg", items: LegWorkout.allCases.map(\.rawValue))
                        workoutMenuSection("Glute", items: GluteWorkout.allCases.map(\.rawValue))
                        workoutMenuSection("Bicep", items: BicepWorkout.allCases.map(\.rawValue))
                        workoutMenuSection("Tricep", items: TricepWorkout.allCases.map(\.rawValue))
                        workoutMenuSection("Abs", items: AbsWorkout.allCases.map(\.rawValue))
                        workoutMenuSection("Cardio", items: CardioWorkout.allCases.map(\.rawValue))
                        workoutMenuSection("Sports", items: SportsWorkout.allCases.map(\.rawValue))
                        workoutMenuSection("Stretch", items: StretchRoutine.allCases.map(\.rawValue))
                    } label: {
                        HStack {
                            Text(plannedItems[idx].isEmpty ? "Select workout" : plannedItems[idx])
                                .foregroundStyle(plannedItems[idx].isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        plannedItems.remove(at: idx)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                plannedItems.append("")
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

    @ViewBuilder
    private func workoutMenuSection(_ title: String, items: [String]) -> some View {
        Section(title) {
            ForEach(items, id: \.self) { name in
                Button(name) {
                    if let idx = plannedItems.firstIndex(where: { $0.isEmpty }) {
                        plannedItems[idx] = name
                    } else {
                        // Replace the last item if none empty (optional behavior)
                        if !plannedItems.isEmpty {
                            plannedItems[plannedItems.count - 1] = name
                        } else {
                            plannedItems.append(name)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Persistence
    private func keyCount(for day: Weekday) -> String { "planned_workouts_count_\(day.rawValue)" }
    private func keyItems(for day: Weekday) -> String { "planned_workouts_items_\(day.rawValue)" }

    private func saveForDay(_ day: Weekday) {
        UserDefaults.standard.set(plannedCount, forKey: keyCount(for: day))
        UserDefaults.standard.set(plannedItems, forKey: keyItems(for: day))
    }

    private func loadForDay(_ day: Weekday) {
        plannedCount = UserDefaults.standard.string(forKey: keyCount(for: day)) ?? ""
        if let arr = UserDefaults.standard.array(forKey: keyItems(for: day)) as? [String] {
            plannedItems = arr
        } else {
            plannedItems = []
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
