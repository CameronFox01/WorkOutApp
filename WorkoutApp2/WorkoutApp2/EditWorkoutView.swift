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

    @State var entry: WorkoutEntry

    @State private var workoutType: String = ""
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var sets: String = ""
    @State private var date: Date = Date()
    @State private var notes: String = ""

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case weight, reps, sets, notes
    }

    @State private var selectedCategory: WorkoutCategory = .push
    @State private var showDeleteConfirm = false

    private let workoutCategoryLookup: [String: WorkoutCategory] = {
        var lookup: [String: WorkoutCategory] = [:]
        for category in WorkoutCategory.allCases {
            for workout in category.workouts() {
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
        if let cat = workoutCategoryLookup[entry.workoutType] {
            self._selectedCategory = State(initialValue: cat)
        } else {
            self._selectedCategory = State(initialValue: .push)
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.9), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {

                    // MARK: - Workout Card
                    sectionCard {
                        VStack(alignment: .leading, spacing: 14) {
                            sectionLabel("Workout", icon: "dumbbell.fill")

                            // Category picker
                            frostedNavigationPicker(
                                label: "Category",
                                icon: "square.grid.2x2.fill",
                                value: selectedCategory.title
                            ) {
                                List {
                                    ForEach(WorkoutCategory.allCases) { category in
                                        Button {
                                            selectedCategory = category
                                        } label: {
                                            HStack(spacing: 12) {
                                                Image(systemName: category.icon)
                                                    .foregroundStyle(.blue)
                                                Text(category.title)
                                                if selectedCategory == category {
                                                    Spacer()
                                                    Image(systemName: "checkmark")
                                                        .foregroundStyle(.blue)
                                                }
                                            }
                                        }
                                        .foregroundStyle(.primary)
                                    }
                                }
                                .navigationTitle("Category")
                            }

                            // Workout picker
                            frostedNavigationPicker(
                                label: "Workout",
                                icon: "figure.strengthtraining.traditional",
                                value: workoutType.isEmpty ? "Select" : workoutType
                            ) {

                                let workouts = selectedCategory.workouts()

                                List {
                                    ForEach(workouts, id: \.self) { workout in
                                        Button {
                                            workoutType = workout
                                        } label: {
                                            HStack {
                                                Text(workout)

                                                if workoutType == workout {
                                                    Spacer()

                                                    Image(systemName: "checkmark")
                                                        .foregroundStyle(.blue)
                                                }
                                            }
                                        }
                                        .foregroundStyle(.primary)
                                    }
                                }
                                .navigationTitle("Workout")
                            }

                            // Date picker
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .foregroundStyle(.white.opacity(0.7))
                                    Text("Date")
                                        .foregroundStyle(.white.opacity(0.7))
                                        .font(.subheadline)
                                }
                                DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .colorScheme(.dark)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // MARK: - Details Card
                    sectionCard {
                        VStack(alignment: .leading, spacing: 14) {
                            sectionLabel("Details", icon: "list.number")

                            frostedField(label: "Weight", placeholder: "0", text: $weight, keyboard: .decimalPad, field: .weight, next: .reps)
                            frostedField(label: "Reps", placeholder: "0", text: $reps, keyboard: .numberPad, field: .reps, next: .sets)
                            frostedField(label: "Sets", placeholder: "0", text: $sets, keyboard: .numberPad, field: .sets, next: nil)
                        }
                    }

                    // MARK: - Notes Card
                    sectionCard {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionLabel("Notes", icon: "note.text")

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $notes)
                                    .frame(minHeight: 100)
                                    .focused($focusedField, equals: .notes)
                                    .scrollContentBackground(.hidden)
                                    .foregroundStyle(.white)
                                    .padding(4)

                                if notes.isEmpty {
                                    Text("Add a note...")
                                        .foregroundStyle(.white.opacity(0.35))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 12)
                                        .allowsHitTesting(false)
                                }
                            }
                            .background(.white.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // MARK: - Delete Button
                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete Workout", systemImage: "trash")
                            .font(.subheadline.bold())
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.red.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Edit Workout")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveChanges() }
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
                    .foregroundStyle(.blue)
            }
        }
        .onChange(of: selectedCategory) { _, newCategory in
            if !newCategory.workouts().contains(workoutType) {
                workoutType = newCategory.workouts().first ?? workoutType
            }
        }
        .confirmationDialog(
            "Delete this workout?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { deleteEntry() }
            Button("Cancel", role: .cancel) { }
        }
    }

    // MARK: - Reusable Components

    @ViewBuilder
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white.opacity(0.10))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            )
    }

    private func sectionLabel(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline.bold())
            .foregroundStyle(.white)
    }

    private func frostedField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType,
        field: Field,
        next: Field?
    ) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.white.opacity(0.75))
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .focused($focusedField, equals: field)
                .submitLabel(next == nil ? .done : .next)
                .onSubmit { focusedField = next }
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(12)
        .background(.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func frostedNavigationPicker<Destination: View>(
        label: String,
        icon: String,
        value: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 20)
                Text(label)
                    .foregroundStyle(.white.opacity(0.75))
                    .font(.subheadline)
                Spacer()
                Text(value)
                    .foregroundStyle(.white)
                    .font(.subheadline.bold())
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.4))
                    .font(.caption)
            }
            .padding(12)
            .background(.white.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

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

    private func deleteEntry() {
        if let index = workoutData.entries.firstIndex(where: { $0.id == entry.id }) {
            workoutData.entries.remove(at: index)
        }
        saveEntriesToStorage()
        dismiss()
    }

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
