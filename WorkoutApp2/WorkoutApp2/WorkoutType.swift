//
//  WorkoutType.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/6/25.
//

// Bodyweight-only workouts
enum BodyweightWorkout: String, CaseIterable, Identifiable, Hashable {
    case pushUps = "Push-ups"
    case pullUps = "Pull-ups"
    case airSquats = "Air Squats"
    case mountainClimbers = "Mountain Climbers"

    var id: String { self.rawValue }
}

// Abs-focused workouts
enum AbsWorkout: String, CaseIterable, Identifiable, Hashable {
    case sitUps = "Sit-ups"
    case planks = "Planks"
    case burpees = "Burpees"
    
    var id: String {self.rawValue}
}

// Push-focused workouts
enum PushWorkout: String, CaseIterable, Identifiable, Hashable {
    case benchPress = "Bench Press"
    case shoulderPress = "Shoulder Press"
    case inclinePress = "Incline Press"
    case chestFly = "Chest Fly"
    case dumbbellPress = "Dumbbell Press"
    case tricepDips = "Tricep Dips"
    case lateralRaises = "Lateral Raises"

    var id: String { self.rawValue }
}

// Pull-focused workouts
enum PullWorkout: String, CaseIterable, Identifiable, Hashable {
    case deadlift = "Deadlift"
    case barbellRow = "Barbell Row"
    case latPulldown = "Lat Pulldown"
    case seatedRow = "Seated Row"
    case facePulls = "Face Pulls"
    case cableRows = "Cable Rows"
    case chinUps = "Chin-ups"

    var id: String { self.rawValue }
}

// Bicep workouts
enum BicepWorkout: String, CaseIterable, Identifiable, Hashable {
    case bicepCurl = "Bicep Curl"
    case hammerCurl = "Hammer Curl"
    case concentrationCurl = "Concentration Curl"
    case preacherCurl = "Preacher Curl"
    case barbellCurl = "Barbell Curl"
    case cableCurl = "Cable Curl"

    var id: String { self.rawValue }
}

// Tricep workouts
enum TricepWorkout: String, CaseIterable, Identifiable, Hashable {
    case tricepPushdown = "Tricep Pushdown"
    case overheadExtension = "Overhead Extension"
    case skullCrushers = "Skull Crushers"
    case closeGripBench = "Close-Grip Bench Press"
    case cableKickback = "Cable Kickbacks"

    var id: String { self.rawValue }
}

// Leg workouts
enum LegWorkout: String, CaseIterable, Identifiable, Hashable {
    case squat = "Squat"
    case legPress = "Leg Press"
    case lunges = "Lunges"
    case legExtension = "Leg Extension"
    case legCurl = "Leg Curl"
    case stepUps = "Step-ups"
    case calfRaises = "Calf Raises"

    var id: String { self.rawValue }
}

// Glute workouts
enum GluteWorkout: String, CaseIterable, Identifiable, Hashable {
    case hipThrust = "Hip Thrust"
    case gluteBridge = "Glute Bridge"
    case donkeyKicks = "Donkey Kicks"
    case cableKickbacks = "Cable Kickbacks"
    case bandWalks = "Band Walks"
    case bulgarianSplitSquat = "Bulgarian Split Squat"

    var id: String { self.rawValue }
}

