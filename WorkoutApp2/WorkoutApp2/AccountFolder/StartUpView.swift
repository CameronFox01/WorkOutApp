//
//  StartUpView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/18/26.
//

import SwiftUI

struct StartUpView: View {
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userGender") private var genderRaw: String = Gender.male.rawValue
    @AppStorage("userTargetDaysOfWorkout") private var targetDaysOfWorkout: String = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    //Stuff for import data
    @EnvironmentObject var workoutData: WorkoutData
    @StateObject private var exporter = WorkoutDataExporter()
    @State private var showingImporter = false
    @State private var showingShareSheet = false

    @State private var selectedFeet = 5
    @State private var selectedInches = 8
    @State private var selectedCentimeters = 173
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings
    
    enum Gender: String, CaseIterable, Identifiable {
        case male = "Male"
        case female = "Female"
        var id: String { self.rawValue }
    }
    
    init() {
        UISegmentedControl.appearance().setTitleTextAttributes(
            [
                .font: UIFont.preferredFont(forTextStyle: .title3)
            ],
            for: .normal
        )
    }
    
    var body: some View {
        
        NavigationStack {
            ZStack{
                LinearGradient(
                    colors: gradientSettings.selectedPreset.swiftUIColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                GeometryReader { geo in
                    //let isIPad = geo.size.width > 600
                    Form {
                        // Area for Name to be entered
                        Section {
                            TextField("Name", text: $name)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .font(.adaptiveTitle2)
                        } header: {
                            Text("Name")
                                .font(.adaptiveTitle)
                        }
                        .frame(height: .adaptiveRowHeight)
                        
                        // Area for Gender to be selected
                        Section {
                            Picker("Gender", selection: $genderRaw) {
                                ForEach(Gender.allCases) { gender in
                                    Text(gender.rawValue).tag(gender.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                        } header: {
                             Text("Gender")
                                .font(.adaptiveTitle)
                        }
                        .frame(height: .adaptiveRowHeight)
                        
                        // Area for Unit to be selected
                        Section{
                            Picker("Unit System", selection: Binding<UnitSystem>(
                                get: { UnitSystem(rawValue: unitSystemRaw) ?? .metric },
                                set: { newValue in
                                    let oldUnit = UnitSystem(rawValue: unitSystemRaw) ?? .metric
                                    if oldUnit != newValue {
                                        convertValues(from: oldUnit, to: newValue)
                                        unitSystemRaw = newValue.rawValue
                                    }
                                }
                            )) {
                                ForEach(UnitSystem.allCases, id: \.self) { unit in
                                    Text(unit.rawValue).tag(unit)
                                }
                            }
                            .pickerStyle(.segmented)
                        } header: {
                            Text("Unit System")
                                .font(.adaptiveTitle)
                        }
                        .frame(height: .adaptiveRowHeight)
                        
                        // Area for Body Info
                        Section{
                            // HEIGHT
                            if unitSystem == .imperial {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Height")
                                    HStack {
                                        Picker("Feet", selection: $selectedFeet) {
                                            ForEach(3...7, id: \.self) { foot in
                                                Text("\(foot) ft").tag(foot)
                                                    .font(.adaptiveTitle2)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: .adaptivePickerHeight)
                                        
                                        
                                        Picker("Inches", selection: $selectedInches) {
                                            ForEach(0...11, id: \.self) { inch in
                                                Text("\(inch) in").tag(inch)
                                                    .font(.adaptiveTitle2)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: .adaptivePickerHeight)
                                    }
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Height")
                                    Picker("Centimeters", selection: $selectedCentimeters) {
                                        ForEach(100...250, id: \.self) { cm in
                                            Text("\(cm) cm").tag(cm)
                                                .font(.adaptiveTitle2)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: .adaptivePickerHeight)
                                }
                            }
                            
                            // WEIGHT
                            TextField(weightLabel, text: $weight)
                                .keyboardType(.decimalPad)
                                .font(.adaptiveTitle2)
                        } header: {
                            Text("Body Info")
                                .font(.adaptiveTitle)
                        }
                        
                        
                        // Workout Goal Section
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("How many days per week?")
                                    .font(.adaptiveSubheadline)
                                    .foregroundStyle(.secondary)
                                Picker("Days", selection: $targetDaysOfWorkout) {
                                    ForEach(["1","2", "3", "4", "5", "6", "7"], id: \.self) { day in
                                        Text(day).tag(day)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        } header: {
                            Text("Weekly Workout Goal")
                                .font(.adaptiveTitle)
                        }
                        .frame(height: .adaptiveRowHeight)
                        
                        Section {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("IronFox can send you reminders to stay on track:")
                                    .font(.adaptiveSubheadline)
                                    .foregroundStyle(.secondary)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Daily weigh-in reminders", systemImage: "scalemass.fill")
                                    Label("Workout schedule reminders", systemImage: "calendar")
                                    Label("Milestone and goal achievements", systemImage: "trophy.fill")
                                }
                                .font(.adaptiveSubheadline)
                                .foregroundStyle(.secondary)
                                
                                Toggle(isOn: $notificationsEnabled) {
                                    Text("Enable Notifications")
                                        .font(.adaptiveTitle3)
                                }
                                .onChange(of: notificationsEnabled) { _, newValue in
                                    if newValue {
                                        NotificationHandler.shared.requestNotificationPermission()
                                    }
                                }
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Image(systemName: "bell.badge.fill")
                                    .foregroundStyle(.orange)
                                    .font(.adaptiveTitle)
                                Text("Notifications")
                                    .foregroundStyle(.primary)
                                    .font(.adaptiveTitle)
                            }
                            .font(.headline)
                            .textCase(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Section {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Switching from another app or device? You can import your existing workout history now.")
                                    .font(.adaptiveSubheadline)
                                    .foregroundStyle(.secondary)
                                
                                Button {
                                    showingImporter = true
                                } label: {
                                    HStack {
                                        Image(systemName: "square.and.arrow.down")
                                        Text("Import Workouts (CSV)")
                                        Spacer()
                                    }
                                    .font(.adaptiveTitle3)
                                }
                                Divider()
                                Text("Expected columns: workoutType, weight, reps, sets (optional), date, note (optional). Column order and capitalization don't matter — common synonyms like \"Type\" or \"Reps\" are also recognized.")
                                    .font(.adaptiveCaption)
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 10)
                                Divider()
                                Button {
                                    exporter.prepareTemplate()
                                    showingShareSheet = exporter.exportURL != nil
                                } label: {
                                    HStack {
                                        Image(systemName: "doc.text")
                                        Text("Download CSV Template")
                                            .font(.adaptiveTitle3)
                                        Spacer()
                                    }
                                    .foregroundStyle(.blue)
                                }
                                
                                if let summary = exporter.lastImportSummary {
                                    Label(summary, systemImage: "checkmark.circle.fill")
                                        .font(.adaptiveCaption)
                                        .foregroundStyle(.green)
                                }
                                
                                if let error = exporter.importError {
                                    Label(error, systemImage: "exclamationmark.triangle.fill")
                                        .font(.adaptiveCaption)
                                        .foregroundStyle(.orange)
                                }
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.down.on.square.fill")
                                    .foregroundStyle(.blue)
                                Text("Import Data")
                                    .foregroundStyle(.primary)
                            }
                            .font(.adaptiveTitle)
                            .textCase(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Button{
                            guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                            
                            // Always persist height from picker state right now
                            if unitSystem == .imperial {
                                let totalInches = (selectedFeet * 12) + selectedInches
                                height = "\(totalInches)"
                            } else {
                                height = "\(selectedCentimeters)"
                            }
                            let goal = Int(targetDaysOfWorkout) ?? 0
                            NotificationHandler.shared.scheduleWeeklyWorkoutChallengeNotifications(goalDays: goal)
                            hasCompletedSetup = true
                        } label: {
                            Text("Finish Setup")
                                .font(.adaptiveTitle)
                        }
                    }
                }
                .formStyle(.grouped)
                .fileImporter(
                    isPresented: $showingImporter,
                    allowedContentTypes: [.commaSeparatedText, .plainText],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        guard let url = urls.first else { return }
                        exporter.importCSV(from: url, into: workoutData)
                    case .failure(let error):
                        exporter.importError = error.localizedDescription
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(gradientSettings.selectedPreset.topColor, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Setup Account")
                            .font(.largeTitle).bold()
                            .foregroundStyle(.white)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    // Make sure unit state is consistent and pickers reflect stored value (if any)
                    initializePickersFromStoredHeight()
                    
                    // If height hasn’t been set yet, populate it from the default picker selections now
                    if height.isEmpty {
                        if unitSystem == .imperial {
                            let totalInches = (selectedFeet * 12) + selectedInches
                            height = "\(totalInches)"
                        } else {
                            height = "\(selectedCentimeters)"
                        }
                    }
                }
            }
        }
    }
    
    struct SettingsRow<Content: View>: View {

        let icon: String
        let title: String

        @ViewBuilder let trailing: Content

        var body: some View {

            HStack(spacing: 14) {

                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 28)
                    .foregroundStyle(.blue)

                Text(title)
                    .font(.body)

                Spacer()

                trailing
            }
        }
    }
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private func initializePickersFromStoredHeight() {
        // If there is an existing stored height, update the pickers to match it
        guard !height.isEmpty, let stored = Double(height) else { return }
        if unitSystem == .imperial {
            // Height is stored as total inches in your current design
            let totalInches = Int(stored.rounded())
            selectedFeet = max(3, min(7, totalInches / 12))
            selectedInches = max(0, min(11, totalInches % 12))
        } else {
            // Metric: height is stored as cm
            let cm = Int(stored.rounded())
            selectedCentimeters = max(100, min(250, cm))
        }
    }
    
    func convertValues(from oldUnit: UnitSystem, to newUnit: UnitSystem) {
        guard oldUnit != newUnit else { return }

        // Convert height and weight
        if let heightValue = Double(height), let weightValue = Double(weight) {
            switch (oldUnit, newUnit) {
            case (.metric, .imperial):
                height = String(format: "%.1f", heightValue / 2.54)
                weight = String(format: "%.1f", weightValue * 2.20462)
            case (.imperial, .metric):
                height = String(format: "%.1f", heightValue * 2.54)
                weight = String(format: "%.1f", weightValue / 2.20462)
            default:
                break
            }
        }

        // Convert saved workout goals
        let allWorkouts = BodyweightWorkout.allCases.map(\.rawValue)
            + PushWorkout.allCases.map(\.rawValue)
            + PullWorkout.allCases.map(\.rawValue)
            + LegWorkout.allCases.map(\.rawValue)
            + GluteWorkout.allCases.map(\.rawValue)
            + BicepWorkout.allCases.map(\.rawValue)
            + TricepWorkout.allCases.map(\.rawValue)
            + AbsWorkout.allCases.map(\.rawValue)
            + DistanceCardioWorkout.allCases.map(\.rawValue)

        for workout in allWorkouts {
            let key = "goal_\(workout)"
            guard let saved = UserDefaults.standard.string(forKey: key),
                  let value = Double(saved) else { continue }

            let converted: Double
            switch (oldUnit, newUnit) {
            case (.metric, .imperial): converted = value * 2.20462
            case (.imperial, .metric): converted = value / 2.20462
            default: continue
            }

            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: key)
        }

        // Convert target body weight
        if let saved = UserDefaults.standard.string(forKey: "userTargetWeight"),
           let value = Double(saved) {
            let converted: Double
            switch (oldUnit, newUnit) {
            case (.metric, .imperial): converted = value * 2.20462
            case (.imperial, .metric): converted = value / 2.20462
            default: return
            }
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userTargetWeight")
        }
    }

    // MARK: - Labels
    var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }

    var heightLabel: String {
        unitSystem == .metric ? "Height (cm)" : "Height (inches)"
    }

    var weightLabel: String {
        unitSystem == .metric ? "Weight (kg)" : "Weight (lbs)"
    }

    var heightUnit: String {
        unitSystem == .metric ? "cm" : "in"
    }

    var weightUnit: String {
        unitSystem == .metric ? "kg" : "lbs"
    }
}

#Preview {
    StartUpView()
        .environmentObject(GradientSettings())
}

