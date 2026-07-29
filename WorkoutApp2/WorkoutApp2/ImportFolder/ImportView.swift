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
    case bodyweight, push, pull, leg, glute, bicep, tricep, abs, distanceCardio, timeCardio, sports, stretch, recovery

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
        case .recovery: return "Recovery"
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
            
        case .recovery:
            builtIn = RecoveryWorkout.allCases.map(\.rawValue)
        }

        let custom = loadCustomWorkouts(for: self)

        return (builtIn + custom).sorted()
    }

    // Categories where weight is typically not entered
    var usesWeight: Bool {
        switch self {
        case .bodyweight, .abs, .stretch, .sports, .distanceCardio, .timeCardio, .recovery: return false
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
        
        case .recovery:
            return "figure.mind.and.body"
     
        }
    }
    
    var customKey: String {
        "custom_\(rawValue)"
    }
}

struct ImportView: View {
    @EnvironmentObject var workoutData: WorkoutData
    
    // MARK: - Focus
    @FocusState private var isEditing: Bool

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
    
    @State private var showingAddFromSearch = false
    @State private var newSearchWorkoutName = ""
    @State private var newSearchWorkoutCategory: WorkoutCategory = .push
    @State private var navigateToNewSearchWorkout = false
    
    @State private var searchText: String = ""

    private var allWorkoutsFlattened: [(workout: String, category: WorkoutCategory)] {
        WorkoutCategory.allCases.flatMap { category in
            category.workouts().map { (workout: $0, category: category) }
        }
    }

    private var filteredWorkouts: [(workout: String, category: WorkoutCategory)] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        return allWorkoutsFlattened.filter {
            $0.workout.localizedCaseInsensitiveContains(searchText)
        }
        .sorted { $0.workout < $1.workout }
    }
    
    @AppStorage("hasSeenKeyboardDismissTutorial") private var hasSeenKeyboardDismissTutorial: Bool = false
    @State private var showKeyboardDismissTutorial = false

    private var keyboardDismissTutorialSteps: [TutorialStep] {
        [
            TutorialStep(
                id: "keyboard",
                title: "Dismiss the Keyboard",
                description: "Tap here anytime to close the keyboard and see the rest of the screen."
            )
        ]
    }
    
    //Date Being passed in
    let selectedDate: Date?
    
    //Coming from Previous day
    let comingFromCalendar: Bool
    @Environment(\.dismiss) private var dismiss
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings
    
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
    
    // Wherever you need an actual Date to save with:
    private var effectiveDate: Date {
        selectedDate ?? Date()
    }
    
    init(
        preselectedCategory: WorkoutCategory? = nil,
        preselectedWorkout: String? = nil,
        selectedDate: Date? = nil,
        comingFromCalendar: Bool = false
    ) {
        self.preselectedCategory = preselectedCategory
        self.preselectedWorkout = preselectedWorkout
        self.selectedDate = selectedDate
        self.comingFromCalendar = comingFromCalendar
    }

    // The view of the list of all workouts
    var body: some View {
        NavigationStack {
            ZStack{
                LinearGradient(
                    colors: gradientSettings.selectedPreset.swiftUIColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: - Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(gradientSettings.selectedPreset.textColor)

                        TextField("Search all workouts...", text: $searchText)
                            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .focused($isEditing)

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                            }
                        }
                    }
                    .padding(12)
                    .background(.white.opacity(0.67), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.top, 8)

                    if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {

                        // MARK: - Search Results
                        List {
                            if filteredWorkouts.isEmpty {
                                VStack(spacing: 14) {
                                       Text("No workouts found for \"\(searchText)\"")
                                        .foregroundStyle(gradientSettings.selectedPreset.subTextOnDarkBackground)
                                           .multilineTextAlignment(.center)

                                       Button {
                                           newSearchWorkoutName = searchText.trimmingCharacters(in: .whitespaces)
                                           showingAddFromSearch = true
                                       } label: {
                                           Label("Add \"\(searchText)\" as a new workout", systemImage: "plus.circle.fill")
                                               .font(.headline.bold())
                                               .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
                                       }
                                       .buttonStyle(.borderedProminent)
                                       .tint(.white)
                                   }
                                   .frame(maxWidth: .infinity)
                                   .padding(.vertical, 30)
                                   .listRowBackground(Color.clear)
                            } else {
                                ForEach(filteredWorkouts, id: \.workout) { item in
                                    NavigationLink(destination: CategoryDetailView(
                                        category: item.category,
                                        date: effectiveDate,
                                        unitSystemRaw: $unitSystemRaw,
                                        selections: $selections,
                                        weights: $weights,
                                        reps: $reps,
                                        sets: $setsDict,
                                        distances: $distances,
                                        times: $times,
                                        entries: $entries,
                                        notes: $notes,
                                        save: { saveEntry(for: item.category) },
                                        increment: { dict, step in self.increment(&dict, for: item.category, by: step) },
                                        decrement: { dict, step in self.decrement(&dict, for: item.category, by: step) },
                                        weightUnitProvider: { self.weightUnit },
                                        goHomeAfterSave: GoToHomeScreenWhenSaved,
                                        showSavedToast: $showSavedToast,
                                        resetParent: { resetImportView() }
                                    )
                                    .onAppear {
                                        // Pre-select the tapped workout for this category
                                        selections[item.category] = item.workout
                                    }
                                    ) {
                                        HStack(spacing: 12) {
                                            Image(systemName: item.category.icon)
                                                .foregroundStyle(gradientSettings.selectedPreset.textColor)
                                            VStack(alignment: .leading) {
                                                Text(item.workout)
                                                Text(item.category.title)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .listRowSpacing(12)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)

                    } else {

                        // MARK: - Category List (existing content, unchanged)
                        List {
                            Section() {
                                ForEach(WorkoutCategory.allCases) { category in
                                    NavigationLink(destination: CategoryDetailView(
                                        category: category,
                                        date: effectiveDate,
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
                                                .foregroundStyle(gradientSettings.selectedPreset.textColor)
                                            VStack(alignment: .leading) {
                                                Text(category.title)
                                                Text("Tap to log")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
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
                }
            }
            .sheet(isPresented: $showingAddFromSearch) {
                NavigationStack {
                    ZStack {
                        // MARK: - Background
                        LinearGradient(
                            colors: gradientSettings.darkGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        Form {
                            Section("Workout Name") {
                                TextField("Workout name", text: $newSearchWorkoutName)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                                    .foregroundStyle(.black)
                                    .focused($isEditing)
                                    
                            }
                            .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)
                            
                            Section("Category") {
                                Picker("Category", selection: $newSearchWorkoutCategory) {
                                    ForEach(WorkoutCategory.allCases) { category in
                                        Label {
                                            Text(category.title)
                                                .foregroundStyle(
                                                    .black
                                                )
                                        } icon: {
                                            Image(systemName: category.icon)
                                                .foregroundStyle(
                                                    gradientSettings.selectedPreset.textColor
                                                )
                                        }
                                        .tag(category)
                                    }
                                }
                                .pickerStyle(.inline)
                                .labelsHidden()
                            }
                            .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)
                        }// End of Form
                        .scrollContentBackground(.hidden)
                    }
                    .navigationTitle("Add Workout")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isEditing = false
                            }
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                showingAddFromSearch = false
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add") {
                                let trimmed = newSearchWorkoutName.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else { return }

                                saveCustomWorkout(trimmed, for: newSearchWorkoutCategory)
                                selections[newSearchWorkoutCategory] = trimmed

                                showingAddFromSearch = false
                                searchText = ""
                                navigateToNewSearchWorkout = true
                            }
                            .fontWeight(.semibold)
                          //  .disabled(newSearchWorkoutName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
            }
            .tutorialOverlay(
                isPresented: $showKeyboardDismissTutorial,
                steps: keyboardDismissTutorialSteps,
                onFinish: {
                    hasSeenKeyboardDismissTutorial = true
                }
            )
            .onChange(of: isEditing) { _, newValue in
                if newValue && !hasSeenKeyboardDismissTutorial {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showKeyboardDismissTutorial = true
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToNewSearchWorkout) {
                CategoryDetailView(
                    category: newSearchWorkoutCategory,
                    date: effectiveDate,
                    unitSystemRaw: $unitSystemRaw,
                    selections: $selections,
                    weights: $weights,
                    reps: $reps,
                    sets: $setsDict,
                    distances: $distances,
                    times: $times,
                    entries: $entries,
                    notes: $notes,
                    save: { saveEntry(for: newSearchWorkoutCategory) },
                    increment: { dict, step in self.increment(&dict, for: newSearchWorkoutCategory, by: step) },
                    decrement: { dict, step in self.decrement(&dict, for: newSearchWorkoutCategory, by: step) },
                    weightUnitProvider: { self.weightUnit },
                    goHomeAfterSave: GoToHomeScreenWhenSaved,
                    showSavedToast: $showSavedToast,
                    resetParent: { resetImportView() }
                )
            }
            .onAppear {
                  for category in WorkoutCategory.allCases {
                      if selections[category] == nil {
                          selections[category] = category.workouts().first ?? ""
                      }
                  }
                  if let category = preselectedCategory,
                     let workout = preselectedWorkout {
                      selections[category] = workout
                  }
                  loadEntries()
            }
            .toolbarBackground(gradientSettings.selectedPreset.topColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                if isEditing {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isEditing = false
                        } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                        .transition(.scale.combined(with: .opacity))
                        .tutorialHighlight("keyboard")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Import Workout")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                }
                if comingFromCalendar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(.white)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isEditing)
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
        case .recovery: return "figure.mind.and.body"
        }
    }

    struct CategoryDetailView: View {
        let category: WorkoutCategory
        let date: Date
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
        @State private var showingPlateCalculator = false
        @State private var hasLoadedInitialValues = false
        
        @AppStorage("showCalculatorImporting") private var showCalculatorImporting: Bool = true
        
        // MARK: - Focus
        @FocusState private var isEditing: Bool
        
        //Color Gradiant
        @EnvironmentObject var gradientSettings: GradientSettings
        
        @Environment(\.dismiss) private var dismiss
        @Environment(\.colorScheme) private var colorScheme
        
        @AppStorage("hasSeenCategoryDetailTutorial") private var hasSeenCategoryDetailTutorial: Bool = false
        @State private var showCategoryDetailTutorial = false

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
                    colors: gradientSettings.selectedPreset.swiftUIColors,
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
                                .foregroundStyle(gradientSettings.selectedPreset.textColor)
                        }
                        .tutorialHighlight("addCustomWorkout")
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
            //.navigationTitle(category.title)
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .top) {
                if showSavedToast { savedToast }
            }
            .navigationDestination(isPresented: $showingPlateCalculator) {
                PlateCalculatorView(weightUnit: weightUnit) { total in
                    weights[category] = formattedNumber(total)
                }
                .environmentObject(gradientSettings)
            }
            .tutorialOverlay(
                isPresented: $showCategoryDetailTutorial,
                steps: categoryDetailTutorialSteps,
                onFinish: {
                    hasSeenCategoryDetailTutorial = true
                }
            )
            .onAppear {
                guard !hasLoadedInitialValues else { return }
                hasLoadedInitialValues = true

                let currentWorkout = selections[category] ?? category.workouts().first ?? ""
                if let saved = loadLastWorkoutValues(for: currentWorkout) {
                    if !saved["weight", default: ""].isEmpty { weights[category] = saved["weight"] }
                    if !saved["reps", default: ""].isEmpty { reps[category] = saved["reps"] }
                    if !saved["sets", default: ""].isEmpty { sets[category] = saved["sets"] }
                    if !saved["distance", default: ""].isEmpty { distances[category] = saved["distance"] }
                    if !saved["time", default: ""].isEmpty { times[category] = saved["time"] }
                }

                if !hasSeenCategoryDetailTutorial {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showCategoryDetailTutorial = true
                    }
                }
            }
            .onChange(of: selectionBinding.wrappedValue) { _, newWorkout in
                if let saved = loadLastWorkoutValues(for: newWorkout) {
                    if !saved["weight", default: ""].isEmpty { weights[category] = saved["weight"] }
                    if !saved["reps", default: ""].isEmpty { reps[category] = saved["reps"] }
                    if !saved["sets", default: ""].isEmpty { sets[category] = saved["sets"] }
                    if !saved["distance", default: ""].isEmpty { distances[category] = saved["distance"] }
                    if !saved["time", default: ""].isEmpty { times[category] = saved["time"] }
                } else {
                    // First time — clear fields so they start fresh
                    weights[category] = ""
                    reps[category] = ""
                    sets[category] = ""
                    distances[category] = ""
                    times[category] = ""
                }
            }
            .toolbar{
                if !showingAddWorkout{
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isEditing = false
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(category.title)
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                }
            }
        }
        
        private func formattedNumber(_ value: Double) -> String {
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                return String(Int(value))
            } else {
                return String(format: "%.1f", value)
            }
        }

        // MARK: - Cards

        private var headerCard: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(category.title)
                    .font(.title2.bold())
                    .foregroundStyle(textColor)
                    

                Text("Log your \(category.title.lowercased()) workout \(date.formatted(date: .long, time: .omitted))")
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
                .tint(gradientSettings.selectedPreset.textColor)
            }
            .padding(16)
            .background(cardColor, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05),
                    radius: 8, x: 0, y: 4)
            .tutorialHighlight("workoutPicker")
        }

        private var statsCard: some View {
            VStack(spacing: 12) {
                if showCalculatorImporting {
                    if category.usesWeight && category != .distanceCardio && category != .timeCardio && category != .recovery {
                        statRow("scalemass", "Weight (\(weightUnit))", weightBinding, calculatorAction: {
                            showingPlateCalculator = true
                        }) {
                            increment(&weights, UnitSystem(rawValue: unitSystemRaw) == .imperial ? 5 : 2.5)
                        } dec: {
                            decrement(&weights, UnitSystem(rawValue: unitSystemRaw) == .imperial ? 5 : 2.5)
                        }
                    }
                } else {
                    if category.usesWeight && category != .distanceCardio && category != .timeCardio && category != .recovery {
                        statRow("scalemass", "Weight (\(weightUnit))", weightBinding) {
                            increment(&weights, UnitSystem(rawValue: unitSystemRaw) == .imperial ? 5 : 2.5)
                        } dec: {
                            decrement(&weights, UnitSystem(rawValue: unitSystemRaw) == .imperial ? 5 : 2.5)
                        }
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

                if category == .timeCardio || category == .sports  || category == .recovery{
                    statRow("timer", "Time (min)", timeBinding) {
                        increment(&times, 1)
                    } dec: {
                        decrement(&times, 1)
                    }
                }

                // Only show reps and sets for non-sports, non-cardio categories
                 if category != .distanceCardio && category != .timeCardio && category != .sports && category != .recovery {
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
                 } else {
                     
                 }
            }
            .padding(16)
            .background(cardColor, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05),
                    radius: 8, x: 0, y: 4)
            .tutorialHighlight("statsCard")
        }

        private var notesCard: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Notes")
                    .font(.headline.bold())
                    .foregroundStyle(textColor)

                TextEditor(text: noteBinding)
                    .frame(minHeight: 90)
                    .focused($isEditing)
                    .background(secondaryCardColor, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
            .background(cardColor, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05),
                    radius: 8, x: 0, y: 4)
            .tutorialHighlight("notesCard")
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
            //.tint(.accentColor)
            .tint(gradientSettings.selectedPreset.textColor)
            .tutorialHighlight("saveButton")
        }

        // MARK: - Row Builder
        private func statRow(
            _ icon: String,
            _ title: String,
            _ binding: Binding<String>,
            calculatorAction: (() -> Void)? = nil,
            inc: @escaping () -> Void,
            dec: @escaping () -> Void
        ) -> some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)

                TextField(title, text: binding)
                    .keyboardType(.decimalPad)
                    .focused($isEditing)

                Spacer()

                if let calculatorAction {
                    Button(action: calculatorAction) {
                        Image(systemName: "plusminus.circle")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }

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
        
        private var categoryDetailTutorialSteps: [TutorialStep] {
            [
                TutorialStep(
                    id: "workoutPicker",
                    title: "Choose Your Workout",
                    description: "Pick the specific exercise you're logging within this category."
                ),
                TutorialStep(
                    id: "statsCard",
                    title: "Log Your Stats",
                    description: "Enter weight, reps, sets, distance, or time depending on the workout. Tap the plate icon next to Weight to use the plate calculator."
                ),
                TutorialStep(
                    id: "notesCard",
                    title: "Add Notes",
                    description: "Jot down how it felt, form cues, or anything worth remembering next time."
                ),
                TutorialStep(
                    id: "saveButton",
                    title: "Save",
                    description: "Save this entry to your workout history."
                ),
                TutorialStep(
                    id: "addCustomWorkout",
                    title: "Add Custom Workout",
                    description: "Don't see your exercise? Add your own custom workout to this category."
                )
            ]
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
        WorkoutApp2.saveEntry(
            for: category,
            selections: selections,
            weights: weights,
            reps: reps,
            sets: setsDict,
            distances: distances,
            times: times,
            notes: notes,
            date: effectiveDate,
            workoutData: workoutData,
            onSuccess: { feedbackSuccess() },
            onError: { feedbackError() }
        )
    }
    
    func saveEntriesToStorage() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "workout_entries")
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
    ImportView(selectedDate: Date(), comingFromCalendar: false)
        .environmentObject(GradientSettings())
}

