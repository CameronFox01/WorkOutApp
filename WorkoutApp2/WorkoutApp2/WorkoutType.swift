//
//  WorkoutType.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/6/25.
//

// Bodyweight-only workouts
enum BodyweightWorkout: String, CaseIterable, Identifiable, Hashable {
    case airSquats = "Air Squats"
    case mountainClimbers = "Mountain Climbers"
    case pullUps = "Pull-ups"
    case pushUps = "Push-ups"

    var id: String { self.rawValue }
}

// Abs-focused workouts
enum AbsWorkout: String, CaseIterable, Identifiable, Hashable {
    case burpees = "Burpees"
    case planks = "Planks"
    case sitUps = "Sit-ups"
    
    var id: String {self.rawValue}
}

// Push-focused workouts
enum PushWorkout: String, CaseIterable, Identifiable, Hashable {
    case benchPress = "Bench Press"
    case chestFly = "Chest Fly"
    case dumbbellPress = "Dumbbell Press"
    case inclinePress = "Incline Press"
    case lateralRaises = "Lateral Raises"
    case shoulderPress = "Shoulder Press"
    case tricepDips = "Tricep Dips"

    var id: String { self.rawValue }
}

// Pull-focused workouts
enum PullWorkout: String, CaseIterable, Identifiable, Hashable {
    case barbellRow = "Barbell Row"
    case cableRows = "Cable Rows"
    case chinUps = "Chin-ups"
    case deadlift = "Deadlift"
    case facePulls = "Face Pulls"
    case latPulldown = "Lat Pulldown"
    case seatedRow = "Seated Row"

    var id: String { self.rawValue }
}

// Bicep workouts
enum BicepWorkout: String, CaseIterable, Identifiable, Hashable {
    case barbellCurl = "Barbell Curl"
    case bicepCurl = "Bicep Curl"
    case cableCurl = "Cable Curl"
    case concentrationCurl = "Concentration Curl"
    case hammerCurl = "Hammer Curl"
    case preacherCurl = "Preacher Curl"

    var id: String { self.rawValue }
}

// Tricep workouts
enum TricepWorkout: String, CaseIterable, Identifiable, Hashable {
    case cableKickback = "Cable Kickbacks"
    case closeGripBench = "Close-Grip Bench Press"
    case overheadExtension = "Overhead Extension"
    case skullCrushers = "Skull Crushers"
    case tricepPushdown = "Tricep Pushdown"

    var id: String { self.rawValue }
}

// Leg workouts
enum LegWorkout: String, CaseIterable, Identifiable, Hashable {
    case calfRaises = "Calf Raises"
    case legCurl = "Leg Curl"
    case legExtension = "Leg Extension"
    case legPress = "Leg Press"
    case lunges = "Lunges"
    case squat = "Squat"
    case stepUps = "Step-ups"

    var id: String { self.rawValue }
}

// Glute workouts
enum GluteWorkout: String, CaseIterable, Identifiable, Hashable {
    case bandWalks = "Band Walks"
    case bulgarianSplitSquat = "Bulgarian Split Squat"
    case cableKickbacks = "Cable Kickbacks"
    case donkeyKicks = "Donkey Kicks"
    case gluteBridge = "Glute Bridge"
    case hipThrust = "Hip Thrust"

    var id: String { self.rawValue }
}

//Cardio workouts
enum CardioWorkout: String, CaseIterable, Identifiable, Hashable {
    case cycling = "Cycling"
    case elliptical = "Elliptical"
    case rowing = "Rowing"
    case running = "Running"
    case stairClimbing = "Stair Climbing"
    case swimming = "Swimming"
    
    var id: String { self.rawValue }
}

enum SportsWorkout: String, CaseIterable, Identifiable, Hashable {
    case badminton = "Badminton"
    case baseball = "Baseball"
    case basketball = "Basketball"
    case boxing = "Boxing"
    case cricket = "Cricket"
    case dance = "Dance"
    case football = "Football"
    case golf = "Golf"
    case gymnastics = "Gymnastics"
    case hockey = "Hockey"
    case martialArts = "Martial Arts"
    case rockClimbing = "Rock Climbing"
    case rugby = "Rugby"
    case skateboarding = "Skateboarding"
    case skiing = "Skiing"
    case snowboarding = "Snowboarding"
    case soccer = "Soccer"
    case softball = "Softball"
    case surfing = "Surfing"
    case tennis = "Tennis"
    case volleyball = "Volleyball"
    case wakeboarding = "Wakeboarding"
    case wrestling = "Wrestling"
    
    var id: String { self.rawValue }
}

enum StretchRoutine: String, CaseIterable, Identifiable, Hashable {
    case catCow = "Cat-Cow"
    case childsPose = "Child's Pose"
    case cobraPose = "Cobra Pose"
    case downwardDog = "Downward-Facing Dog"
    case figureFourStretch = "Figure Four Stretch"
    case hamstringsStretch = "Hamstring Stretch"
    case hipFlexorStretch = "Hip Flexor Stretch"
    case pigeonPose = "Pigeon Pose"
    case quadricepsStretch = "Quadriceps Stretch"
    case shoulderStretch = "Shoulder Stretch"
    case tricepStretch = "Tricep Stretch"
    case warriorPose = "Warrior Pose"
    case yoga = "Yoga"
    
    var id: String { self.rawValue }
}
