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

    init(entry: WorkoutEntry) {
        self._entry = State(initialValue: entry)
        self._workoutType = State(initialValue: entry.workoutType)
        self._weight = State(initialValue: entry.weight)
        self._reps = State(initialValue: entry.reps)
        self._sets = State(initialValue: entry.sets)
        self._date = State(initialValue: entry.date)
    }

    var body: some View {
        Form {
            Section(header: Text("Workout")) {
                TextField("Type", text: $workoutType)
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
            }
            Section(header: Text("Details")) {
                TextField("Weight", text: $weight)
                    .keyboardType(.decimalPad)
                TextField("Reps", text: $reps)
                    .keyboardType(.numberPad)
                TextField("Sets", text: $sets)
                    .keyboardType(.numberPad)
            }

            Section {
                Button(role: .destructive) {
                    deleteEntry()
                } label: {
                    Label("Delete Workout", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Edit Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveChanges() }
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
        EditWorkoutView(entry: WorkoutEntry(workoutType: "Bench Press", weight: "185", reps: "8", sets: "4", date: Date()))
            .environmentObject(WorkoutData())
    }
}
