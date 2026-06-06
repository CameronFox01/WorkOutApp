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

    var body: some View {

        NavigationStack {

            ZStack {

                LinearGradient(
                    colors: [
                        Color.blue,
                        Color.cyan.opacity(0.7),
                        Color(.systemBackground)
                    ],
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
                    "\(currentStreak)",

                    label:
                    "Streak"
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

        VStack(
            spacing:12
        ){

            NavigationLink {

                GoalView()

            } label: {

                shortcutRow(
                    icon:"trophy.fill",
                    color:.yellow,
                    title:"Goals"
                )
            }

            NavigationLink {

                AchievedGoalsView(
                    achievedGoals:
                    [],
                    comingfromWidget:
                    false
                )

            } label: {

                shortcutRow(
                    icon:
                    "checkmark.seal.fill",

                    color:
                    .green,

                    title:
                    "Achievements"
                )
            }

        }
    }

    private var settingsButton: some View {

        NavigationLink {

            SettingsView()

        } label: {

            HStack {

                Image(
                    systemName:
                    "gear"
                )

                Text(
                    "Settings"
                )

                Spacer()

                Image(
                    systemName:
                    "chevron.right"
                )

            }
            .padding()
        }
        .cardStyle()
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

            Spacer()

            Text(value)
                .bold()

        }
    }

    private func progressCard(
        value:String,
        label:String
    ) -> some View {

        VStack {

            Text(value)
                .font(
                    .title.bold()
                )

            Text(label)
                .font(
                    .caption
                )

        }
        .frame(
            maxWidth:.infinity
        )
    }

    private func shortcutRow(
        icon:String,
        color:Color,
        title:String
    ) -> some View {

        HStack {

            Image(
                systemName:
                icon
            )
            .foregroundStyle(
                color
            )

            Text(title)

            Spacer()

            Image(
                systemName:
                "chevron.right"
            )

        }
        .padding()
        .cardStyle()
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

    private var currentStreak:Int {

        let calendar =
        Calendar.current

        let workoutDays =
        Set(
            workoutData.entries.map {

                calendar.startOfDay(
                    for:$0.date
                )
            }
        )

        var streak = 0

        var day =
        calendar.startOfDay(
            for: Date()
        )

        while workoutDays.contains(
            day
        ){

            streak += 1

            day =
            calendar.date(
                byAdding:.day,
                value:-1,
                to:day
            )!
        }

        return streak
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
