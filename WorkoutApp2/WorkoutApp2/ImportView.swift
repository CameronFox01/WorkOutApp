//
//  ImportView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI

struct WorkoutEntry: Identifiable, Codable {
    var id = UUID()
    var workoutType: String
    var weight: String
    var reps: String
    var sets: String
    var date: Date
    var note: String = ""
}
// Enums for each workout type
enum WorkoutCategory: String, CaseIterable, Identifiable {
    case bodyweight, push, pull, leg, glute, bicep, tricep, abs, distanceCardio, timeCardio, sports, stretch

    var id: String { rawValue }

    // Title of the Sections
    var title: String {
        switch self {
        case .bodyweight: return "Body Weight"
        case .push: return "Push"
        case .pull: return "Pull"
        case .leg: return "Leg"
        case .glute: return "Glute"
        case .bicep: return "Bicep"
        case .tricep: return "Tricep"
        case .abs: return "Abs"
        case .distanceCardio: return "Distance Cardio"
        case .timeCardio: return "Time Cardio"
        case .sports: return "Sports"
        case .stretch: return "Stretch"
        }
    }

    func workouts() -> [String] {
        let builtIn: [String]

        switch self {
        case .abs:
            builtIn = AbsWorkout.allCases.map(\.rawValue)

        case .bicep:
            builtIn = BicepWorkout.allCases.map(\.rawValue)

        case .bodyweight:
            builtIn = BodyweightWorkout.allCases.map(\.rawValue)

        case .push:
            builtIn = PushWorkout.allCases.map(\.rawValue)

        case .pull:
            builtIn = PullWorkout.allCases.map(\.rawValue)

        case .leg:
            builtIn = LegWorkout.allCases.map(\.rawValue)

        case .glute:
            builtIn = GluteWorkout.allCases.map(\.rawValue)

        case .tricep:
            builtIn = TricepWorkout.allCases.map(\.rawValue)

        case .distanceCardio:
            builtIn = DistanceCardioWorkout.allCases.map(\.rawValue)

        case .timeCardio:
            builtIn = TimeCardioWorkout.allCases.map(\.rawValue)

        case .sports:
            builtIn = SportsWorkout.allCases.map(\.rawValue)

        case .stretch:
            builtIn = StretchRoutine.allCases.map(\.rawValue)
        }

        let custom = loadCustomWorkouts(for: self)

        return (builtIn + custom).sorted()
    }

    // Categories where weight is typically not entered
    var usesWeight: Bool {
        switch self {
        case .bodyweight, .abs, .stretch, .sports, .distanceCardio, .timeCardio: return false
        default: return true
        }
    }
    var icon: String {
        switch self {

        case .bodyweight:
            return "figure.cross.training"

        case .push:
            return "arrow.up.forward.circle.fill"

        case .pull:
            return "arrow.down.backward.circle.fill"

        case .leg:
            return "figure.strengthtraining.functional"

        case .glute:
            return "figure.strengthtraining.traditional"

        case .bicep:
            return "dumbbell.fill"

        case .tricep:
            return "bolt.circle.fill"

        case .abs:
            return "figure.core.training"

        case .distanceCardio:
            return "figure.run"

        case .timeCardio:
            return "timer"

        case .sports:
            return "sportscourt.fill"

        case .stretch:
            return "figure.yoga"
     
        }
    }
    
    var customKey: String {
        "custom_\(rawValue)"
    }
}

struct ImportView: View {
    @EnvironmentObject var workoutData: WorkoutData

    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue

    var weightUnit: String {
        UnitSystem(rawValue: unitSystemRaw) == .imperial ? "lbs" : "kg"
    }

    @State private var entries: [WorkoutEntry] = []
    
    //Flag for how the users will want to handle the SAVE BUTTON
    @AppStorage("saveButtonAction") private var GoToHomeScreenWhenSaved: Bool = false

    // One selection per category
    @State private var selections: [WorkoutCategory: String] = [:]
    @State private var weights: [WorkoutCategory: String] = [:]
    @State private var reps: [WorkoutCategory: String] = [:]
    @State private var setsDict: [WorkoutCategory: String] = [:]
    @State private var distances: [WorkoutCategory: String] = [:]
    @State private var times: [WorkoutCategory: String] = [:]
    
    @State private var notes: [WorkoutCategory: String] = [:]
    
    // Weight Stuff
    @AppStorage("userWeight") private var currentWeight: String = ""

    @State private var newWeightInput: String = ""

    // UI feedback
    @State private var showSavedToast = false
    
    let preselectedCategory: WorkoutCategory?
    let preselectedWorkout: String?
    
    private var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }
    
    init(
        preselectedCategory: WorkoutCategory? = nil,
        preselectedWorkout: String? = nil
    ) {
        self.preselectedCategory = preselectedCategory
        self.preselectedWorkout = preselectedWorkout
    }

    // The view of the list of all workouts
    var body: some View {
        NavigationView {
            ZStack{
                LinearGradient(
                    colors: [
                        Color.blue.opacity(1.0),
                        Color.cyan.opacity(0.6),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                List {
                    // All of the Types of workouts
                    Section() {
                        ForEach(WorkoutCategory.allCases) { category in
                            NavigationLink(destination: CategoryDetailView(
                                category: category,
                                unitSystemRaw: $unitSystemRaw,
                                selections: $selections,
                                weights: $weights,
                                reps: $reps,
                                sets: $setsDict,
                                distances: $distances,
                                times: $times,
                                entries: $entries,
                                notes: $notes,
                                save: { saveEntry(for: category) },
                                increment: { dict, step in self.increment(&dict, for: category, by: step) },
                                decrement: { dict, step in self.decrement(&dict, for: category, by: step) },
                                weightUnitProvider: { self.weightUnit },
                                goHomeAfterSave: GoToHomeScreenWhenSaved,
                                showSavedToast: $showSavedToast,
                                resetParent: { resetImportView() }
                            )) {
                                HStack(spacing: 12) {
                                    Image(systemName: icon(for: category))
                                        .foregroundStyle(Color.accentColor)
                                    VStack(alignment: .leading) {
                                        Text(category.title)
                                        Text("Tap to log")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            //.listRowBackground(Color.white.opacity(0.80))
                        }
                    }
                    // Seeing all workouts that have been entered
                    NavigationLink{
                        AllImportedWorkoutsView()
                    } label:{
                        HStack{
                            Image(systemName: "list.bullet")
                            Text("See all imported workouts")
                        }
                    }
                }
                .listRowSpacing(12)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .onAppear {
                resetImportView()

                  for category in WorkoutCategory.allCases {
                      if selections[category] == nil {
                          selections[category] = category.workouts().first ?? ""
                      }
                  }

                  // PRESELECT WORKOUT
                  if let category = preselectedCategory,
                     let workout = preselectedWorkout {
                      selections[category] = workout
                  }

                  loadEntries()
            }
            .onDisappear {
                resetImportView()
            }
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Import Workout")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func icon(for category: WorkoutCategory) -> String {
        switch category {
        case .bodyweight: return "figure.cross.training"
        case .push: return "arrow.up.forward.circle"
        case .pull: return "arrow.down.backward.circle"
        case .leg: return "figure.strengthtraining.functional"
        case .glute: return "figure.strengthtraining.traditional"
        case .bicep: return "dumbbell"
        case .tricep: return "bolt.circle"
        case .abs: return "figure.core.training"
        case .distanceCardio: return "figure.run"
        case .timeCardio: return "figure.dance"
        case .sports: return "sportscourt"
        case .stretch: return "figure.yoga"
        }
    }

    struct CategoryDetailView: View {
        let category: WorkoutCategory
        @Binding var unitSystemRaw: String
        @Binding var selections: [WorkoutCategory: String]
        @Binding var weights: [WorkoutCategory: String]
        @Binding var reps: [WorkoutCategory: String]
        @Binding var sets: [WorkoutCategory: String]
        @Binding var distances: [WorkoutCategory: String]
        @Binding var times: [WorkoutCategory: String]
        @Binding var entries: [WorkoutEntry]
        @Binding var notes: [WorkoutCategory: String]

        @State private var showingAddWorkout = false
        @State private var newWorkoutName = ""
        
        @Environment(\.dismiss) private var dismiss
        @Environment(\.colorScheme) private var colorScheme

        let save: () -> Void
        let increment: (inout [WorkoutCategory: String], Double) -> Void
        let decrement: (inout [WorkoutCategory: String], Double) -> Void
        let weightUnitProvider: () -> String
        let goHomeAfterSave: Bool
        @Binding var showSavedToast: Bool
        let resetParent: () -> Void

        // MARK: - Colors (match other views)
        private var cardColor: Color {
            colorScheme == .dark ? Color(.systemGray6) : .white
        }

        private var secondaryCardColor: Color {
            colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
        }

        private var textColor: Color {
            colorScheme == .dark ? .white : .primary
        }

        private var bgColor: Color {
            colorScheme == .dark ? Color.black : Color("#F3F4F6")
        }

        private var weightUnit: String { weightUnitProvider() }

        // MARK: - Bindings
        private var selectionBinding: Binding<String> {
            Binding(
                get: { selections[category] ?? category.workouts().first ?? "" },
                set: { selections[category] = $0 }
            )
        }

        private var weightBinding: Binding<String> {
            Binding(
                get: { weights[category] ?? "" },
                set: { weights[category] = $0 }
            )
        }

        private var repsBinding: Binding<String> {
            Binding(
                get: { reps[category] ?? "" },
                set: { reps[category] = $0 }
            )
        }

        private var setsBinding: Binding<String> {
            Binding(
                get: { sets[category] ?? "" },
                set: { sets[category] = $0 }
            )
        }

        private var distanceBinding: Binding<String> {
            Binding(
                get: { distances[category] ?? "" },
                set: { distances[category] = $0 }
            )
        }

        private var timeBinding: Binding<String> {
            Binding(
                get: { times[category] ?? "" },
                set: { times[category] = $0 }
            )
        }

        private var noteBinding: Binding<String> {
            Binding(
                get: { notes[category] ?? "" },
                set: { notes[category] = $0 }
            )
        }

        // MARK: - Body
        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.blue.opacity(1.0),
                        Color.cyan.opacity(0.6),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {

                        headerCard
                        workoutCard
                        statsCard
                        notesCard
                        saveButton
                        
                        Button {
                            showingAddWorkout = true
                        } label: {
                            Label("Add Custom Workout", systemImage: "plus")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                    .alert("New Workout", isPresented: $showingAddWorkout) {
                        TextField("Workout Name", text: $newWorkoutName)

                        Button("Save") {
                            let trimmed = newWorkoutName.trimmingCharacters(in: .whitespacesAndNewlines)

                            guard !trimmed.isEmpty else { return }

                            saveCustomWorkout(trimmed, for: category)

                            selections[category] = trimmed

                            newWorkoutName = ""
                        }

                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            .navigationTitle(category.title)
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .top) {
                if showSavedToast { savedToast }
            }
            .onAppear {
                resetParent()
            }
        }

        // MARK: - Cards

        private var headerCard: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(category.title)
                    .font(.title2.bold())
                    .foregroundStyle(textColor)

                Text("Log your \(category.title.lowercased()) workout")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(cardColor, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05),
                    radius: 8, x: 0, y: 4)
        }

        private var workoutCard: some View {
            VStack(alignment: .leading, spacing: 12) {

                Picker("Workout", selection: selectionBinding) {
                    ForEach(category.workouts(), id: \.self) { workout in
                        Text(workout).tag(workout)
                    }
                }
                .pickerStyle(.menu)
                .padding(12)
                .background(secondaryCardColor, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
            .background(cardColor, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05),
                    radius: 8, x: 0, y: 4)
        }

        private var statsCard: some View {
            VStack(spacing: 12) {

                if category.usesWeight && category != .distanceCardio && category != .timeCardio {
                    statRow("scalemass", "Weight (\(weightUnit))", weightBinding) {
                        increment(&weights, UnitSystem(rawValue: unitSystemRaw) == .imperial ? 5 : 2.5)
                    } dec: {
                        decrement(&weights, UnitSystem(rawValue: unitSystemRaw) == .imperial ? 5 : 2.5)
                    }
                }

                if category == .distanceCardio {

                    statRow("ruler", "Distance", distanceBinding) {
                        increment(&distances, UnitSystem(rawValue: unitSystemRaw) == .imperial ? 0.5 : 1)
                    } dec: {
                        decrement(&distances, UnitSystem(rawValue: unitSystemRaw) == .imperial ? 0.5 : 1)
                    }

                    statRow("timer", "Time (min)", timeBinding) {
                        increment(&times, 1)
                    } dec: {
                        decrement(&times, 1)
                    }
                }

                if category == .timeCardio {
                    statRow("timer", "Time (min)", timeBinding) {
                        increment(&times, 1)
                    } dec: {
                        decrement(&times, 1)
                    }
                }

                statRow("number", "Reps", repsBinding) {
                    increment(&reps, 1)
                } dec: {
                    decrement(&reps, 1)
                }

                statRow("square.grid.2x2", "Sets", setsBinding) {
                    increment(&sets, 1)
                } dec: {
                    decrement(&sets, 1)
                }
            }
            .padding(16)
            .background(cardColor, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05),
                    radius: 8, x: 0, y: 4)
        }

        private var notesCard: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Notes")
                    .font(.headline.bold())
                    .foregroundStyle(textColor)

                TextEditor(text: noteBinding)
                    .frame(minHeight: 90)
                    //.padding(10)
                    .background(secondaryCardColor, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
            .background(cardColor, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05),
                    radius: 8, x: 0, y: 4)
        }

        private var saveButton: some View {
            Button {
                save()
                if goHomeAfterSave { dismiss() }
            } label: {
                Text("Save \(category.title)")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
        }

        // MARK: - Row Builder
        private func statRow(
            _ icon: String,
            _ title: String,
            _ binding: Binding<String>,
            inc: @escaping () -> Void,
            dec: @escaping () -> Void
        ) -> some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)

                TextField(title, text: binding)
                    .keyboardType(.decimalPad)

                Spacer()

                Stepper("", onIncrement: inc, onDecrement: dec)
                    .labelsHidden()
            }
            .padding(12)
            .background(secondaryCardColor, in: RoundedRectangle(cornerRadius: 12))
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
    }
    public func resetImportView() { selections.removeAll()
        weights.removeAll()
        reps.removeAll()
        setsDict.removeAll()
        distances.removeAll()
        times.removeAll()
        notes.removeAll()
        // Re-add default workout selections
        for category in WorkoutCategory.allCases {
            selections[category] = category.workouts().first ?? ""
        }
    }
    // MARK: - Save / Storage
    func saveEntry(for category: WorkoutCategory) {
        print("🔍 Saving category: \(category)")
        // Validation adapted to categories without weight
        if category.usesWeight {
            guard let weight = weights[category], !weight.isEmpty else {
                feedbackError()
                print("⛔️ Missing values for weight")
                return
            }
        }
        
        if category == .distanceCardio {
            guard let distance = distances[category], !distance.isEmpty else {
                feedbackError()
                return
            }
            guard let time = times[category], !time.isEmpty else {
                feedbackError()
                return
            }
        }

        let rep = reps[category] ?? ""
        if category != .distanceCardio && rep.isEmpty {
            feedbackError()
            print("⛔️ Missing rep")
            return
        }

        guard let workout = selections[category], !workout.isEmpty else {
            feedbackError()
            print("⛔️ Missing values for workout")
            return
        }

        let setsVal: String = {
            if category == .distanceCardio { return times[category] ?? "" }
            else { return setsDict[category] ?? "" }
        }()

        let weightString: String = {
            if category == .distanceCardio { return distances[category] ?? "" }
            if category.usesWeight { return weights[category] ?? "" }
            else { return "" }
        }()

        let newEntry = WorkoutEntry(
            workoutType: workout,
            weight: weightString,
            reps: rep,
            sets: setsVal,
            date: Date(),
            note: notes[category] ?? ""
        )
        workoutData.add(entry: newEntry)

        entries.append(newEntry)
        saveEntriesToStorage()

        //How the button resets after being pressed.
        DispatchQueue.main.async {
            
            //This will allow the user to do multiple sets without having to redo.
            if GoToHomeScreenWhenSaved == false{
                if category.usesWeight { weights[category] = "" }
                if category == .distanceCardio { distances[category] = "" }
                if category == .distanceCardio { times[category] = "" }
                reps[category] = ""
                setsDict[category] = ""
            }else { //this will move the user out to the home screen after each save.
                resetImportView()
            }
        }

        feedbackSuccess()
    }

    func saveEntriesToStorage() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "workout_entries")
            print("✅ Workout entries saved. Count: \(entries.count)")
        } else {
            print("❌ Failed to encode entries.")
        }
    }

    func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "workout_entries"),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            entries = decoded
        }
    }

    func binding(for dict: Binding<[WorkoutCategory: String]>, key: WorkoutCategory, defaultValue: String = "") -> Binding<String> {
        return Binding<String>(
            get: { dict.wrappedValue[key] ?? defaultValue },
            set: { dict.wrappedValue[key] = $0 }
        )
    }

    // MARK: - Helpers for steppers
    private func increment(_ dict: inout [WorkoutCategory: String], for key: WorkoutCategory, by step: Double) {
        let current = Double(dict[key] ?? "") ?? 0
        let next = current + step
        dict[key] = formattedNumber(next)
    }

    private func decrement(_ dict: inout [WorkoutCategory: String], for key: WorkoutCategory, by step: Double) {
        let current = Double(dict[key] ?? "") ?? 0
        let next = max(0, current - step)
        dict[key] = formattedNumber(next)
    }

    private func formattedNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }

    // MARK: - Haptics & feedback
    private func feedbackSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            showSavedToast = true
        }
    }

    private func feedbackError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

#Preview {
    ImportView()
}

