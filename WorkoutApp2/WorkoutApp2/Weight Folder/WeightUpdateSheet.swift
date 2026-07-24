//
//  WeightUpdateSheet.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/21/26.
//

import SwiftUI

struct WeightUpdateSheet: View {

    let unitSystem: UnitSystem
    let weightUnit: String
    let comingFromWidget: Bool
    
    @EnvironmentObject var router: AppRouter

    @Binding var currentWeight: String
    @Binding var newWeightInput: String
    
    @FocusState private var isWeightFieldFocused: Bool
    
    @AppStorage("weightGoalDirection")
    private var weightGoalDirection: String = "lose"

    var entries: [WorkoutEntry]

    let onSave: (String) -> Void
    let unitSystemRaw: String

    @Environment(\.dismiss) private var dismiss
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings
    
    //Toast Stuff
    //Toast Stuff
    @State private var showWeightToast = false
    @State private var toastMessage = ""
    @State private var toastIsPositive = true
    @AppStorage("showWeightUpdateToast") private var weightUpdateToastEnabled: Bool = true

    private let celebratoryMessages = [
        "🎉 Nice! You're getting closer to your goal.",
        "💪 Great progress toward your target!",
        "🔥 You're on the right track — keep it up!",
        "⭐️ Awesome, that's a step closer to your goal!"
    ]

    private let encouragingMessages = [
        "Every journey has ups and downs — keep going!",
        "Stay consistent, progress isn't always a straight line.",
        "You've got this — refocus and keep pushing!",
        "One entry doesn't define your journey. Keep at it!"
    ]

    private var bodyWeightEntries: [WorkoutEntry] {
        entries
            .filter { $0.workoutType == "Body Weight" }
            .sorted { $0.date < $1.date }
    }

    private var progress: CGFloat {

        guard let current = Double(currentWeight),
              let new = Double(newWeightInput.isEmpty ? currentWeight : newWeight),
              current > 0 else {
            return 0
        }

        return CGFloat(min(new / current, 1))
    }

    private var newWeight: String {
        newWeightInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var weightToast: some View {
        HStack(spacing: 8) {
            Image(systemName: toastIsPositive ? "checkmark.circle.fill" : "heart.fill")
            Text(toastMessage)
                .font(.subheadline.bold())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            (toastIsPositive ? Color.green : Color.orange).opacity(0.95),
            in: Capsule()
        )
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.spring()) {
                    showWeightToast = false
                }
            }
        }
    }

    var body: some View {

        ZStack {

            // MARK: - Background
            LinearGradient(
                colors: gradientSettings.darkGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {

                VStack(spacing: 28) {
                    TextField(
                        "Enter weight",
                        text: $newWeightInput
                    )
                    .keyboardType(.decimalPad)
                    .font(
                        .system(
                            size: 42,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .focused($isWeightFieldFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {

                            Spacer()

                            Button("Done") {
                                isWeightFieldFocused = false
                            }
                        }
                    }
                    .onTapGesture {
                        isWeightFieldFocused = false
                    }

                    Divider()
                        .overlay(Color.white.opacity(0.2))

                    // MARK: - Chart
                    WorkoutProgressChart(
                        workoutName: "Body Weight",
                        entries: entries,
                        unitSystemRaw: unitSystemRaw
                    )
                    .frame(height: 220)
                    Spacer()
                    HStack {

                        Label(
                            "Update Weight",
                            systemImage: "scalemass.fill"
                        )
                        .font(.headline)

                        Spacer()

                        Circle()
                            .fill(.green)
                            .frame(width: 10, height: 10)
                    }
                    .foregroundStyle(.white)
                    // MARK: - Hero Weight Ring
                    VStack(spacing: 18) {

                        ZStack {

                            Circle()
                                .stroke(
                                    Color.white.opacity(0.15),
                                    lineWidth: 18
                                )
                                .frame(width: 280, height: 280)

                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    AngularGradient(
                                        colors: [.green, .blue],
                                        center: .center
                                    ),
                                    style: StrokeStyle(
                                        lineWidth: 18,
                                        lineCap: .round
                                    )
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 280, height: 280)

                            VStack(spacing: 10) {

                                TextField(
                                    "0.0",
                                    text: $newWeightInput
                                )
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .font(
                                    .system(
                                        size: 60,
                                        weight: .bold,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(.white)
                                .monospacedDigit()
                                .frame(width: 180)
                                .focused($isWeightFieldFocused)

                                Text(weightUnit)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.7))

                                Text("Current Weight")
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }

                        // MARK: - Quick Controls
                        HStack(spacing: 28) {

                            controlButton(
                                icon: "minus",
                                color: .orange
                            ) {

                                let current =
                                Double(newWeightInput)
                                ?? Double(currentWeight)
                                ?? 0

                                let step =
                                unitSystem == .imperial
                                ? 1.0
                                : 0.5

                                let next = max(0, current - step)

                                newWeightInput = formatted(next)
                            }

                            controlButton(
                                icon: "plus",
                                color: .blue
                            ) {

                                let current =
                                Double(newWeightInput)
                                ?? Double(currentWeight)
                                ?? 0

                                let step =
                                unitSystem == .imperial
                                ? 1.0
                                : 0.5

                                let next = current + step

                                newWeightInput = formatted(next)
                            }
                        }
                    }
                    .padding(.top, 20)

                    // MARK: - Input Card
                    VStack(alignment: .leading, spacing: 18) {

                        // MARK: - Save Button
                        Button {

                            let trimmed = newWeight

                           guard !trimmed.isEmpty,
                                 let newVal = Double(trimmed) else {
                               return
                           }

                           let previousValue = Double(currentWeight)

                           onSave(trimmed)
                           currentWeight = trimmed
                           hitGoal()

                           showWeightUpdateToast(previous: previousValue, new: newVal)
                        } label: {

                            Label(
                                "Save Weight",
                                systemImage: "checkmark.circle.fill"
                            )
                            .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 40)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .padding(.vertical)
                    }
                }
            }
            .onTapGesture {
                isWeightFieldFocused = false
            }
        }
        .onAppear {
            if newWeightInput.isEmpty {
                newWeightInput = currentWeight
            }
        }
        .overlay(alignment: .top) {
            if showWeightToast {
                weightToast
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if comingFromWidget {
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        router.activeScreen = nil
                    } label:{
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                }
            }

            ToolbarItem(placement: .principal) {

                Text("Update Weight")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
            }
        }
    }
    
    func hitGoal() {
        print("hitGoal Called")

        guard let goal = Double(UserDefaults.standard.string(forKey: "userTargetWeight") ?? ""),
              let current = Double(currentWeight)
        else {
            print("Invalid weights")
            return
        }

        let goalDirection = UserDefaults.standard.string(forKey: "weightGoalDirection") ?? "lose"

        let reachedGoal: Bool

        if goalDirection == "gain" {
            reachedGoal = current >= goal
        } else {
            reachedGoal = current <= goal
        }

        print("goal:", goal, "current:", current, "direction:", goalDirection)

        if reachedGoal {
            print("Reached Goal")

            let alreadyNotified =
                UserDefaults.standard.bool(forKey: "bodyWeightGoalReached")

            if !alreadyNotified {
                print("Being Scheduled")

                NotificationHandler.shared.sendInstantNotification(
                    title: "Goal Achieved!",
                    body: "You reached your target weight of \(goal) \(weightUnit)."
                )

                UserDefaults.standard.set(true, forKey: "bodyWeightGoalReached")
            } else {
                print("Already notified")
            }

        } else {
            print("Not at goal")

            UserDefaults.standard.set(false, forKey: "bodyWeightGoalReached")
        }
    }

    // MARK: - Helper Button
    func controlButton(
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 68, height: 68)
                .background(color.gradient)
                .clipShape(Circle())
                .shadow(radius: 8)
        }
    }

    // MARK: - Formatter
    func formatted(_ value: Double) -> String {

        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }

        return String(format: "%.1f", value)
    }
    
    private func showWeightUpdateToast(previous: Double?, new: Double) {

        guard weightUpdateToastEnabled else { return }

        guard let previous,
              let target = Double(UserDefaults.standard.string(forKey: "userTargetWeight") ?? "")
        else {
            toastMessage = "Weight updated!"
            toastIsPositive = true
            withAnimation(.spring()) { showWeightToast = true }
            return
        }

        let distanceBefore = abs(previous - target)
        let distanceAfter = abs(new - target)

        if distanceAfter == distanceBefore {
            toastMessage = "Weight updated — right on track!"
            toastIsPositive = true
        } else if distanceAfter < distanceBefore {
            toastMessage = celebratoryMessages.randomElement() ?? "Great progress!"
            toastIsPositive = true
        } else {
            toastMessage = encouragingMessages.randomElement() ?? "Keep going, you've got this!"
            toastIsPositive = false
        }

        withAnimation(.spring()) { showWeightToast = true }
    }
}


struct WeightUpdateSheet_Previews: PreviewProvider {
    
    struct PreviewWrapper: View {
        @State private var currentWeight = "180"
        @State private var newWeightInput = "180"

        let sampleEntries = [
            WorkoutEntry(
                workoutType: "Body Weight",
                weight: "185",
                reps: "",
                sets: "",
                date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                note: "String"
            ),
            WorkoutEntry(
                workoutType: "Body Weight",
                weight: "183",
                reps: "",
                sets: "",
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                note: "String"
            ),
            WorkoutEntry(
                workoutType: "Body Weight",
                weight: "180",
                reps: "",
                sets: "",
                date: Date(),
                note: "String"
            )
        ]

        var body: some View {
            WeightUpdateSheet(
                unitSystem: .imperial,
                weightUnit: "lbs",
                comingFromWidget: false,
                currentWeight: $currentWeight,
                newWeightInput: $newWeightInput,
                entries: sampleEntries,
                onSave: { value in
                    print(value)
                },
                unitSystemRaw: UnitSystem.imperial.rawValue
            )
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .environmentObject(GradientSettings())
    }
}
