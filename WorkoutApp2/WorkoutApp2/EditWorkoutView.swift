//
//  EditWorkoutView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/23/26.
//

import SwiftUI

struct EditWorkoutView: View {
    @EnvironmentObject var workoutData: WorkoutData
    @Environment(\.dismiss) private var dismiss

    // The entry being edited
    @State var entry: WorkoutEntry

    // Local editable fields
    @State private var workoutType: String = ""
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var sets: String = ""
    @State private var date: Date = Date()
    @State private var notes: String = ""
    
    // Focus handling for keyboard dismissal
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case weight
        case reps
        case sets
        case notes
    }
    
    // Picker selections
    @State private var selectedCategory: WorkoutCategory = .push

    // Lookup from workout name to category to initialize the picker
    private let workoutCategoryLookup: [String: WorkoutCategory] = {
        var lookup: [String: WorkoutCategory] = [:]
        for category in WorkoutCategory.allCases {
            for workout in category.workouts {
                lookup[workout] = category
            }
        }
        return lookup
    }()
    
    init(entry: WorkoutEntry) {
        self._entry = State(initialValue: entry)
        self._workoutType = State(initialValue: entry.workoutType)
        self._weight = State(initialValue: entry.weight)
        self._reps = State(initialValue: entry.reps)
        self._sets = State(initialValue: entry.sets)
        self._date = State(initialValue: entry.date)
        self._notes = State(initialValue: entry.note)
        // Initialize selected category from the current workout type if possible
        if let cat = workoutCategoryLookup[entry.workoutType] {
            self._selectedCategory = State(initialValue: cat)
        } else {
            self._selectedCategory = State(initialValue: .push)
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Workout")) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(WorkoutCategory.allCases) { category in
                        HStack(spacing: 10) {

                            Image(systemName: category.icon)
                                .foregroundStyle(Color.blue)

                            Text(category.title)
                                .foregroundStyle(Color.black)
                                .font(.headline.bold())
                        }
                        .tag(category)
                    }
                }
                .pickerStyle(.navigationLink)
                Picker("Workout", selection: $workoutType) {
                    ForEach(selectedCategory.workouts, id: \.self) { workout in
                        Text(workout).tag(workout)
                            .foregroundStyle(Color.black)
                            .font(.headline.bold())
                    }
                }
                .pickerStyle(.navigationLink)
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
            }
            Section(header: Text("Details")) {
                //Section for Weight
                HStack{
                    Text("Weight:")
                    
                    TextField("Weight", text: $weight)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .weight)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .reps }
                }
                //Section for Reps
                HStack{
                    Text("Reps:")
                    
                    TextField("Reps", text: $reps)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .reps)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .sets }
                }
                //Section for Sets
                HStack{
                    Text("Sets:")
                    TextField("Sets", text: $sets)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .sets)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                }
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
                    .focused($focusedField, equals: .notes)
            }

            Section {
                Button(role: .destructive) {
                    deleteEntry()
                } label: {
                    Label("Delete Workout", systemImage: "trash")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveChanges() }
            }
            ToolbarItem(placement: .principal){
                Text("Edit Workout")
                    .font(.largeTitle).bold()
                    .foregroundStyle(.white)
            }
        }
        .onChange(of: selectedCategory) { _, newCategory in
            // When category changes, if current workout type is not in the new category, reset to the first option.
            if !newCategory.workouts.contains(workoutType) {
                workoutType = newCategory.workouts.first ?? workoutType
            }
        }
        .toolbar { // keyboard toolbar
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
    }

    //Saves the entry to Memory
    private func saveChanges() {

        if let index = workoutData.entries.firstIndex(where: { $0.id == entry.id }) {

            workoutData.entries[index].workoutType = workoutType
            workoutData.entries[index].weight = weight
            workoutData.entries[index].reps = reps
            workoutData.entries[index].sets = sets
            workoutData.entries[index].date = date
            workoutData.entries[index].note = notes
        }

        saveEntriesToStorage()

        dismiss()
    }

    //Deletes the entry from Memory
    private func deleteEntry() {

        if let index = workoutData.entries.firstIndex(where: { $0.id == entry.id }) {

            workoutData.entries.remove(at: index)
        }

        saveEntriesToStorage()

        dismiss()
    }
    
    //Saves it to storage
    private func saveEntriesToStorage() {
        if let encoded = try? JSONEncoder().encode(workoutData.entries) {
            UserDefaults.standard.set(encoded, forKey: "workout_entries")
        }
    }
}

#Preview {
    NavigationStack {
        EditWorkoutView(entry: WorkoutEntry(workoutType: "Bench Press", weight: "185", reps: "8", sets: "4", date: Date(), note: "That was hard"))
            .environmentObject(WorkoutData())
    }
}
