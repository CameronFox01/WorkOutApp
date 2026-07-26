//
//  MeasurementEntry.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/24/26.
//


import SwiftUI

// MARK: - Model

struct MeasurementEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var chest: Double?
    var shoulders: Double?
    var waist: Double?
    var hips: Double?
    var biceps: Double?
    var thighs: Double?
    var neck: Double?
    var calves: Double?
}

// MARK: - Storage Manager

class MeasurementStore: ObservableObject {
    @Published var entries: [MeasurementEntry] = []

    private let key = "measurementHistory"

    init() { load() }

    var latest: MeasurementEntry? { entries.last }

    var previous: MeasurementEntry? {
        guard entries.count >= 2 else { return nil }
        return entries[entries.count - 2]
    }

    func save(_ entry: MeasurementEntry) {
        entries.append(entry)
        persist()
    }

    func update(_ entry: MeasurementEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            persist()
        }
    }

    func delete(id: UUID) {
        entries.removeAll { $0.id == id }
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([MeasurementEntry].self, from: data)
        else { return }
        entries = decoded
    }
}
// MARK: - Sheet View

struct MeasurementInputSheet: View {
    // MARK: - Focus
    @FocusState private var isEditing: Bool
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = MeasurementStore()
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @EnvironmentObject var gradientSettings: GradientSettings

    @State private var chest:     String = ""
    @State private var shoulders: String = ""
    @State private var waist:     String = ""
    @State private var hips:      String = ""
    @State private var biceps:    String = ""
    @State private var thighs:    String = ""
    @State private var neck:      String = ""
    @State private var calves:    String = ""

    @State private var editingEntryID: UUID?
    @State private var savedSuccessfully = false
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteID: UUID?

    private var unitSystem: UnitSystem { UnitSystem(rawValue: unitSystemRaw) ?? .metric }
    private var unitLabel: String { unitSystem == .imperial ? "in" : "cm" }

    private var measurements: [(label: String, icon: String, binding: Binding<String>)] {[
        ("Chest",     "figure.arms.open",      $chest),
        ("Shoulders", "figure.stand",           $shoulders),
        ("Waist",     "circle.dashed",          $waist),
        ("Hips",      "figure.dress.line.and.person.fill", $hips),
        ("Biceps",    "figure.strengthtraining.traditional", $biceps),
        ("Thighs",    "figure.walk",            $thighs),
        ("Neck",      "person.bust",            $neck),
        ("Calves",    "figure.run",             $calves),
    ]}

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: gradientSettings.darkGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        if editingEntryID != nil {
                            editingBanner
                        }
                        if store.latest != nil && editingEntryID == nil {
                            changesSinceLastCard
                        }
                        inputCard
                        if !store.entries.isEmpty {
                            historyCard
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Body Measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(gradientSettings.selectedPreset.topColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isEditing = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(editingEntryID == nil ? "Save" : "Update") {
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .disabled(allFieldsEmpty)
                }
            }
        }
        .overlay {
            if savedSuccessfully {
                savedToast
            }
        }
        .confirmationDialog(
            "Delete this entry?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let id = pendingDeleteID {
                    store.delete(id: id)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    // MARK: - Editing Banner

    private var editingBanner: some View {
        HStack {
            Image(systemName: "pencil.circle.fill")
                .foregroundStyle(.orange)
            Text("Editing entry")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
            Spacer()
            Button("Cancel") {
                cancelEditing()
            }
            .font(.subheadline.bold())
            .foregroundStyle(.white.opacity(0.75))
        }
        .padding(14)
        .background(.orange.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Changes Since Last Entry

    private var changesSinceLastCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Changes since last entry", systemImage: "arrow.up.arrow.down")
                .font(.headline.bold())
                .foregroundStyle(.white)

            if let last = store.latest {
                Text("Last logged \(last.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 10
                ) {
                    changeBadge(label: "Chest",     current: last.chest)
                    changeBadge(label: "Shoulders", current: last.shoulders)
                    changeBadge(label: "Waist",     current: last.waist)
                    changeBadge(label: "Hips",      current: last.hips)
                    changeBadge(label: "Biceps",    current: last.biceps)
                    changeBadge(label: "Thighs",    current: last.thighs)
                    changeBadge(label: "Neck",      current: last.neck)
                    changeBadge(label: "Calves",    current: last.calves)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.10))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        )
    }

    private func changeBadge(label: String, current: Double?) -> some View {
        let color = MeasurementAppearance.color(for: label)
        let inputValue: Double? = {
            switch label {
            case "Chest":     return Double(chest)
            case "Shoulders": return Double(shoulders)
            case "Waist":     return Double(waist)
            case "Hips":      return Double(hips)
            case "Biceps":    return Double(biceps)
            case "Thighs":    return Double(thighs)
            case "Neck":      return Double(neck)
            case "Calves":    return Double(calves)
            default:          return nil
            }
        }()

        let diff: Double? = {
            guard let i = inputValue, let c = current else { return nil }
            return i - c
        }()

        return HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))

                if let d = diff {
                    HStack(spacing: 3) {
                        Image(systemName: d > 0 ? "arrow.up" : d < 0 ? "arrow.down" : "minus")
                            .font(.caption.bold())
                        Text(String(format: "%.1f \(unitLabel)", abs(d)))
                            .font(.subheadline.bold())
                    }
                    .foregroundStyle(d == 0 ? .white.opacity(0.6) : d < 0 ? .green : .orange)
                } else if let c = current {
                    Text(String(format: "%.1f \(unitLabel)", c))
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                } else {
                    Text("--")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            Spacer()
        }
        .padding(10)
        .background(color.opacity(0.20))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Input Card

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Enter measurements", systemImage: "pencil")
                .font(.headline.bold())
                .foregroundStyle(.white)

            ForEach(measurements, id: \.label) { item in
                let color = MeasurementAppearance.color(for: item.label)

                HStack {
                    Label(item.label, systemImage: item.icon)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(width: 130, alignment: .leading)

                    Spacer()

                    HStack(spacing: 4) {
                        TextField("",
                                  text: item.binding,
                                  prompt: Text("0.0").foregroundStyle(.white.opacity(0.4))
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                        .foregroundStyle(.white)
                        .font(.subheadline.bold())
                        .focused($isEditing)

                        Text(unitLabel)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(color.opacity(0.20))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.10))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        )
    }

    // MARK: - History Card

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Previous entries", systemImage: "clock")
                .font(.headline.bold())
                .foregroundStyle(.white)

            Text("Tap to edit \u{00B7} Swipe to delete")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))

            ForEach(store.entries.reversed()) { entry in
                Button {
                    startEditing(entry)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                            Spacer()
                            if editingEntryID == entry.id {
                                Text("Editing")
                                    .font(.caption.bold())
                                    .foregroundStyle(.orange)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }

                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 6
                        ) {
                            historyCell(label: "Chest",     value: entry.chest)
                            historyCell(label: "Shoulders", value: entry.shoulders)
                            historyCell(label: "Waist",     value: entry.waist)
                            historyCell(label: "Hips",      value: entry.hips)
                            historyCell(label: "Biceps",    value: entry.biceps)
                            historyCell(label: "Thighs",    value: entry.thighs)
                            historyCell(label: "Neck",      value: entry.neck)
                            historyCell(label: "Calves",    value: entry.calves)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(editingEntryID == entry.id ? .orange.opacity(0.15) : .white.opacity(0.08))
                    )
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        pendingDeleteID = entry.id
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.10))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        )
    }

    private func historyCell(label: String, value: Double?) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(MeasurementAppearance.color(for: label))
            Spacer()
            Text(value.map { String(format: "%.1f \(unitLabel)", $0) } ?? "--")
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
    }

    // MARK: - Toast

    private var savedToast: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(editingEntryID == nil ? "Measurements saved" : "Entry updated")
                    .font(.subheadline.bold())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .shadow(radius: 8)
            .padding(.bottom, 32)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Actions

    private var allFieldsEmpty: Bool {
        [chest, shoulders, waist, hips, biceps, thighs, neck, calves]
            .allSatisfy { $0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    private func startEditing(_ entry: MeasurementEntry) {
        editingEntryID = entry.id
        chest     = entry.chest.map { format($0) } ?? ""
        shoulders = entry.shoulders.map { format($0) } ?? ""
        waist     = entry.waist.map { format($0) } ?? ""
        hips      = entry.hips.map { format($0) } ?? ""
        biceps    = entry.biceps.map { format($0) } ?? ""
        thighs    = entry.thighs.map { format($0) } ?? ""
        neck      = entry.neck.map { format($0) } ?? ""
        calves    = entry.calves.map { format($0) } ?? ""
    }

    private func cancelEditing() {
        editingEntryID = nil
        clearFields()
    }

    private func format(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }

    private func clearFields() {
        chest = ""; shoulders = ""; waist = ""
        hips = ""; biceps = ""; thighs = ""
        neck = ""; calves = ""
    }

    private func saveEntry() {
        if let editingID = editingEntryID,
           let original = store.entries.first(where: { $0.id == editingID }) {

            let updated = MeasurementEntry(
                id: original.id,
                date: original.date,
                chest:     Double(chest),
                shoulders: Double(shoulders),
                waist:     Double(waist),
                hips:      Double(hips),
                biceps:    Double(biceps),
                thighs:    Double(thighs),
                neck:      Double(neck),
                calves:    Double(calves)
            )
            store.update(updated)
            editingEntryID = nil

        } else {
            let entry = MeasurementEntry(
                date:      Date(),
                chest:     Double(chest),
                shoulders: Double(shoulders),
                waist:     Double(waist),
                hips:      Double(hips),
                biceps:    Double(biceps),
                thighs:    Double(thighs),
                neck:      Double(neck),
                calves:    Double(calves)
            )
            store.save(entry)
        }

        // Sync AppStorage so MeasurementRecapView reflects the latest values
        if let last = store.entries.last {
            UserDefaults.standard.set(last.chest.map { format($0) } ?? "",     forKey: "measureChest")
            UserDefaults.standard.set(last.shoulders.map { format($0) } ?? "", forKey: "measureShoulders")
            UserDefaults.standard.set(last.waist.map { format($0) } ?? "",     forKey: "measureWaist")
            UserDefaults.standard.set(last.hips.map { format($0) } ?? "",      forKey: "measureHips")
            UserDefaults.standard.set(last.biceps.map { format($0) } ?? "",    forKey: "measureBiceps")
            UserDefaults.standard.set(last.thighs.map { format($0) } ?? "",    forKey: "measureThighs")
            UserDefaults.standard.set(last.neck.map { format($0) } ?? "",      forKey: "measureNeck")
            UserDefaults.standard.set(last.calves.map { format($0) } ?? "",    forKey: "measureCalves")
        }

        withAnimation(.spring()) { savedSuccessfully = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { savedSuccessfully = false }
        }

        clearFields()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue, .black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        MeasurementInputSheet()
            .environmentObject(GradientSettings())
            .onAppear {
                // Seed a previous entry so all three cards show
                let store = MeasurementStore()
                let previous = MeasurementEntry(
                    date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                    chest: 38.5,
                    shoulders: 44.0,
                    waist: 32.0,
                    hips: 38.0,
                    biceps: 13.5,
                    thighs: 22.0,
                    neck: 15.0,
                    calves: 14.5
                )
                store.save(previous)
            }
    }
}
