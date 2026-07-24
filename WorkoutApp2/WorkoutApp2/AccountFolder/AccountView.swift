//
//  AccountView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

// TODO: This needs to be have a design that is nice to see. This is ugly/boring.
import SwiftUI
import PhotosUI

struct AccountView: View {

    @EnvironmentObject var workoutData: WorkoutData
    @AppStorage("bestStreak") private var bestStreak: Int = 0

    @AppStorage("userName")
    private var name: String = ""

    @AppStorage("userHeight")
    private var height: String = ""

    @AppStorage("userWeight")
    private var weight: String = ""

    @AppStorage("userTargetWeight")
    private var targetWeight: String = ""

    @AppStorage("userTargetDaysOfWorkout")
    private var targetDays: String = ""

    @AppStorage("unitSystem")
    private var unitSystemRaw: String =
        UnitSystem.metric.rawValue

    @AppStorage("profileImageData")
    private var profileImageData: Data?

    @State private var showingCamera = false

    private var profileImage: UIImage? {

        guard let data = profileImageData
        else { return nil }

        return UIImage(data: data)
    }
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings

    var body: some View {

        ZStack {

            LinearGradient(
                colors: gradientSettings.selectedPreset.swiftUIColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {

                VStack(
                    spacing:24
                ){

                    profileHeader

                    progressSection

                    statsSection

                    shortcutsSection

                    settingsButton

                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(gradientSettings.selectedPreset.topColor, for: .navigationBar)
        .toolbar {

            ToolbarItem(
                placement:.principal
            ){

                Text("Profile")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

            }
        }
    }
}

extension AccountView {

    private var profileHeader: some View {

        VStack(
            spacing:12
        ){

            PhotosPicker(
                selection: Binding(
                    get:{ nil },
                    set:{ item in

                        guard let item else {
                            return
                        }

                        Task {

                            if let data =
                            try? await item
                                .loadTransferable(
                                    type: Data.self
                                ){

                                profileImageData =
                                data
                            }
                        }
                    }
                ),
                matching:.images
            ){

                Group {

                    if let image =
                        profileImage {

                        Image(
                            uiImage:image
                        )
                        .resizable()
                        .scaledToFill()

                    } else {

                        Image(
                            systemName:
                            "person.circle.fill"
                        )
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                    }
                }
                .frame(
                    width:110,
                    height:110
                )
                .clipShape(
                    Circle()
                )
            }

            Text(
                name.isEmpty
                ? "Your Profile"
                : name
            )
            .font(
                .title.bold()
            )
            .foregroundStyle(
                .white
            )

        }
        .frame(
            maxWidth:.infinity
        )
    }

    private var progressSection: some View {

        VStack(
            spacing:16
        ){

            Text("Your Progress")
                .font(.title3.bold())
                .multilineTextAlignment(.center)
            HStack {

                progressCard(
                    value:
                    "\(workoutData.entries.count)",

                    label:
                    "Workouts"
                )

                progressCard(
                    value:
                    "\(bestStreakFunc)",

                    label:
                    "Best Streak"
                )

                progressCard(
                    value:
                    "\(photoCount)",

                    label:
                    "Photos"
                )

            }

        }
        .cardStyle()
    }

    private var statsSection: some View {

        VStack(
            spacing:14
        ){

            Text("Your Stats")
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            statRow(
                "Weight",
                "\(weight) \(weightUnit)"
            )

            statRow(
                "Height",
                displayHeight
            )

            statRow(
                "Goal Weight",
                "\(targetWeight) \(weightUnit)"
            )

            statRow(
                "Workout Goal",
                "\(targetDays)/week"
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .cardStyle()
    }

    private var shortcutsSection: some View {
        VStack(spacing: 12) {
            NavigationLink {
                GoalView()
            } label: {
                shortcutRow(
                    icon: "trophy.fill",
                    color: .yellow,
                    title: "Goals",
                    textColor: gradientSettings.selectedPreset.textColor
                )
            }
            .padding(.bottom, 10)

            NavigationLink {
                AchievedGoalsView(achievedGoals: workoutData.achievedGoals, comingfromWidget: false)
            } label: {
                shortcutRow(
                    icon: "checkmark.seal.fill",
                    color: .green,
                    title: "Achievements",
                    textColor: gradientSettings.selectedPreset.textColor
                )
            }
            .padding(.bottom, 10)
            
            NavigationLink {
                     MilestonesView(
                         milestones: workoutData.achievedMilestones,
                         comingfromWidget: false
                     )
                 } label: {
                     shortcutRow(
                         icon: "star.fill",
                         color: .orange,
                         title: "Milestones",
                         textColor: gradientSettings.selectedPreset.textColor
                     )
                 }
        }
    }

    private var settingsButton: some View {
        NavigationLink {
            SettingsView()
        } label: {
            HStack {
                Image(systemName: "gear")
                    .foregroundStyle(.blue)
                    .font(.title)
                Text("Settings")
                    .font(.title2)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.title2)
            }
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

extension AccountView {

    private func sectionTitle(
        _ title:String
    ) -> some View {

        HStack {

            Text(title)
                .font(
                    .headline.bold()
                )

            Spacer()

        }
    }

    private func statRow(
        _ title:String,
        _ value:String
    ) -> some View {

        HStack {

            Text(title)
                .font(.headline.bold())

            Spacer()

            Text(value)
                .font(.headline.bold())
                

        }
    }

    private func progressCard(
        value:String,
        label:String
    ) -> some View {

        VStack {

            Text(value)
                .font(
                    .largeTitle.bold()
                )

            Text(label)
                .font(.headline.bold())

        }
        .frame(maxWidth:.infinity)
    }

    private func shortcutRow(
        icon: String,
        color: Color,
        title: String,
        textColor: Color = .primary
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title)
            Text(title)
                .font(.title2)
                .foregroundStyle(textColor)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .font(.title2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 5)
    }

    private var weightUnit:String {

        unitSystemRaw ==
        UnitSystem.metric.rawValue
        ? "kg"
        : "lbs"
    }

    private var displayHeight:String {

        if unitSystemRaw ==
            UnitSystem.metric.rawValue {

            return "\(height) cm"

        }

        let inches = Int(height) ?? 0

        let feet = inches / 12
        let remaining = inches % 12

        return "\(feet)'\(remaining)\""
    }

    private var bestStreakFunc: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let workoutDays = Set(
            workoutData.entries.map {
                calendar.startOfDay(for: $0.date)
            }
        )

        var currentStreak = 0

        // If they've already worked out today, count it
        if workoutDays.contains(today) {
            currentStreak += 1
        }

        // Walk backwards from yesterday
        var day = calendar.date(byAdding: .day, value: -1, to: today)!

        while workoutDays.contains(day) {
            currentStreak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }

        // Update best streak if this one is higher
        if currentStreak > bestStreak {
            DispatchQueue.main.async {
                bestStreak = currentStreak
            }
        }

        return bestStreak
    }

    private var photoCount:Int {

        profileImageData == nil
        ? 0
        : 1
    }
}

#Preview {

    NavigationStack {

        AccountView()
            .environmentObject(GradientSettings())
            .environmentObject(
                previewWorkoutData
            )

    }

}

private var previewWorkoutData: WorkoutData {

    let data = WorkoutData()

    data.entries = [

        WorkoutEntry(
            workoutType: "Bench Press",
            weight: "135",
            reps: "8",
            sets: "3",
            date: Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: Date()
            )!,
            note: ""
        ),

        WorkoutEntry(
            workoutType: "Squat",
            weight: "185",
            reps: "5",
            sets: "3",
            date: Date(),
            note: ""
        ),

        WorkoutEntry(
            workoutType: "Hip Thrust",
            weight: "185",
            reps: "10",
            sets: "4",
            date: Date(),
            note: ""
        )

    ]
    return data
}
