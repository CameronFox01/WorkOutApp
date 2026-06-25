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

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
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
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = MeasurementStore()
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    //Color Gradiant
    @StateObject private var gradientSettings = GradientSettings()

    // Input fields
    @State private var chest:     String = ""
    @State private var shoulders: String = ""
    @State private var waist:     String = ""
    @State private var hips:      String = ""
    @State private var biceps:    String = ""
    @State private var thighs:    String = ""
    @State private var neck:      String = ""
    @State private var calves:    String = ""

    @State private var savedSuccessfully = false

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
            ScrollView {
                VStack(spacing: 20) {
                    if store.latest != nil {
                        changesSinceLastCard
                    }
                    inputCard
                    if !store.entries.isEmpty {
                        historyCard
                    }
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: gradientSettings.darkGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Body Measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveEntry() }
                        .fontWeight(.semibold)
                        .disabled(allFieldsEmpty)
                }
            }
        }
        .overlay {
            if savedSuccessfully {
                savedToast
            }
        }
    }

    // MARK: - Changes Since Last Entry

    private var changesSinceLastCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Changes since last entry", systemImage: "arrow.up.arrow.down")
                .font(.title2)
                .foregroundStyle(.black)

            if let last = store.latest {
                let date = last.date.formatted(date: .abbreviated, time: .omitted)
                Text("Last logged \(date)")
                    .font(.headline)
                    .foregroundStyle(.black)

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
            RoundedRectangle(cornerRadius: 28)
                .fill(.white.opacity(0.30))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
//            RoundedRectangle(cornerRadius: 3)
//                .fill(color.opacity(0.5))
//                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.title3)
                    .foregroundStyle(.white)

                if let d = diff {
                    HStack(spacing: 3) {
                        Image(systemName: d > 0 ? "arrow.up" : d < 0 ? "arrow.down" : "minus")
                            .font(.headline)
                        Text(String(format: "%.1f \(unitLabel)", abs(d)))
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                    }
                    .foregroundStyle(d == 0 ? .secondary : d < 0 ? .green : Color.orange)
                } else if let c = current {
                    Text(String(format: "%.1f \(unitLabel)", c))
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                } else {
                    Text("--")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
            }

            Spacer()
        }
        .padding(10)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Input Card

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Enter measurements", systemImage: "pencil")
                .font(.title2)
                .foregroundStyle(.black)

            ForEach(measurements, id: \.label) { item in
                let color = MeasurementAppearance.color(for: item.label)

                HStack {
                    Label(item.label, systemImage: item.icon)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .frame(width: 130, alignment: .leading)

                    Spacer()

                    HStack(spacing: 4) {
                        TextField("",
                                  text: item.binding,
                                  prompt: Text("0.0").foregroundStyle(.white.opacity(0.6))
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                        .foregroundStyle(.white)
                        .font(.title3)

                        Text(unitLabel)
                            .font(.subheadline)
                            .frame(width: 24, alignment: .leading)
                            .foregroundStyle(.white.opacity(0.8))
                            .font(.title3)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(color.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.white.opacity(0.30))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - History Card

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Previous entries", systemImage: "clock")
                .font(.title)
                .foregroundStyle(.black)

            ForEach(store.entries.reversed()) { entry in
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)
                        .foregroundStyle(.black)

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
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.white.opacity(0.30))
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.white.opacity(0.30))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func historyCell(label: String, value: Double?) -> some View {
        HStack {
            Text(label)
                .font(.title2)
                .foregroundStyle(MeasurementAppearance.color(for: label))
            Spacer()
            Text(value.map { String(format: "%.1f \(unitLabel)", $0) } ?? "--")
                .font(.title2.bold())
                .foregroundStyle(MeasurementAppearance.color(for: label))
        }
    }

    // MARK: - Toast

    private var savedToast: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Measurements saved")
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

    private func saveEntry() {
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

        // Also update AppStorage so MeasurementRecapView stays in sync
        UserDefaults.standard.set(chest,     forKey: "measureChest")
        UserDefaults.standard.set(shoulders, forKey: "measureShoulders")
        UserDefaults.standard.set(waist,     forKey: "measureWaist")
        UserDefaults.standard.set(hips,      forKey: "measureHips")
        UserDefaults.standard.set(biceps,    forKey: "measureBiceps")
        UserDefaults.standard.set(thighs,    forKey: "measureThighs")
        UserDefaults.standard.set(neck,      forKey: "measureNeck")
        UserDefaults.standard.set(calves,    forKey: "measureCalves")

        withAnimation(.spring()) { savedSuccessfully = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { savedSuccessfully = false }
        }

        chest = ""; shoulders = ""; waist = ""
        hips = ""; biceps = ""; thighs = ""
        neck = ""; calves = ""
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
