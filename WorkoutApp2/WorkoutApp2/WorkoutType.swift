//
//  WorkoutType.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/6/25.
//

import Foundation

func loadCustomWorkouts(for category: WorkoutCategory) -> [String] {
    UserDefaults.standard.stringArray(forKey: category.customKey) ?? []
}

func saveCustomWorkout(_ workout: String, for category: WorkoutCategory) {
    var workouts = loadCustomWorkouts(for: category)

    // Prevent duplicates
    guard !workouts.contains(workout) else { return }

    workouts.append(workout)
    workouts.sort()

    UserDefaults.standard.set(workouts, forKey: category.customKey)
}

// Bodyweight-only workouts
enum BodyweightWorkout: String, CaseIterable, Identifiable, Hashable {
    case airSquats = "Air Squats"
    case bearCrawl = "Bear Crawl"
    case bicycleCrunches = "Bicycle Crunches"
    case birdDog = "Bird Dog"
    case boxStepUps = "Box Step-ups"
    case burpees = "Burpees"
    case buttKicks = "Butt Kicks"
    case calfRaises = "Calf Raises"
    case climbers = "Climbers"
    case crabWalk = "Crab Walk"
    case curtsyLunges = "Curtsy Lunges"
    case fireHydrants = "Fire Hydrants"
    case flutterKicks = "Flutter Kicks"
    case gluteBridge = "Glute Bridge"
    case highKnees = "High Knees"
    case hipDips = "Hip Dips"
    case hollowBodyHold = "Hollow Body Hold"
    case inchworms = "Inchworms"
    case jumpingJacks = "Jumping Jacks"
    case legRaises = "Leg Raises"
    case lunges = "Lunges"
    case mountainClimbers = "Mountain Climbers"
    case mountainClimberTwists = "Mountain Climber Twists"
    case narrowPushUps = "Narrow Push-ups"
    case pikePushUps = "Pike Push-ups"
    case plankJacks = "Plank Jacks"
    case plankRocks = "Plank Rocks"
    case plankShoulderTaps = "Plank Shoulder Taps"
    case plankUps = "Plank-ups"
    case planks = "Planks"
    case pullUps = "Pull-ups"
    case pushUps = "Push-ups"
    case reverseLunges = "Reverse Lunges"
    case RussianTwists = "Russian Twists"
    case sidePlank = "Side Plank"
    case singleLegDeadlift = "Single Leg Deadlift"
    case sitUps = "Sit-ups"
    case skaterJumps = "Skater Jumps"
    case spiderManPushUps = "Spider-Man Push-ups"
    case splitSquats = "Split Squats"
    case squat = "Squat"
    case squatHold = "Squat Hold"
    case squatJumps = "Squat Jumps"
    case squatPulse = "Squat Pulse"
    case superman = "Superman"
    case toeTouches = "Toe Touches"
    case tricepDips = "Tricep Dips"
    case vUps = "V-Ups"
    case wallPushUps = "Wall Push-ups"
    case wallSit = "Wall Sit"

    var id: String { self.rawValue }
}

// Abs-focused workouts
enum AbsWorkout: String, CaseIterable, Identifiable, Hashable {
    case abdominalVacuum = "Abdominal Vacuum", abWheelRollout = "Ab Wheel Rollout"
    case barbellRollout = "Barbell Rollout", bicycleCrunches = "Bicycle Crunches", birdDog = "Bird Dog"
    case boatPose = "Boat Pose", cableCrunches = "Cable Crunches", climberKicks = "Climber Kicks"
    case coreHold = "Core Hold", crossBodyCrunch = "Cross-Body Crunch", crunches = "Crunches", deadBug = "Dead Bug"
    case declineCrunches = "Decline Crunches", dragonFlag = "Dragon Flag", elevatedPlank = "Elevated Plank"
    case flutterKickHolds = "Flutter Kick Holds", flutterKicks = "Flutter Kicks", hangingKneeRaises = "Hanging Knee Raises"
    case hangingLegRaises = "Hanging Leg Raises", heelTaps = "Heel Taps", hollowBodyHold = "Hollow Body Hold"
    case inclineSitups = "Incline Sit-ups", jackKnifeSitups = "Jack Knife Sit-ups", legCircles = "Leg Circles"
    case legRaises = "Leg Raises", mountainClimberTwists = "Mountain Climber Twists"
    case mountainClimbers = "Mountain Climbers", obliqueCrunches = "Oblique Crunches"
    case plankJacks = "Plank Jacks", plankKneeToElbow = "Plank Knee to Elbow", plankMarch = "Plank March"
    case plankReach = "Plank Reach", plankRocks = "Plank Rocks", plankShoulderTaps = "Plank Shoulder Taps"
    case planks = "Planks", reverseCrunches = "Reverse Crunches", russianTwists = "Russian Twists"
    case scissors = "Scissors", sidePlankHipDips = "Side Plank Hip Dips", sitUps = "Sit-ups"
    case spiderManPlank = "Spider-Man Plank", stabilityBallTuck = "Stability Ball Tuck"
    case standingAbTwist = "Standing Ab Twist", swissBallCrunch = "Swiss Ball Crunch"
    case toeTouches = "Toe Touches", tuckCrunches = "Tuck Crunches", vUps = "V-Ups"
    case weightedCrunches = "Weighted Crunches", weightedRussianTwist = "Weighted Russian Twist"
    case windshieldWipers = "Windshield Wipers"
    
    var id: String {self.rawValue}
}

// Push-focused workouts
enum PushWorkout: String, CaseIterable, Identifiable, Hashable {
    case ArnoldPress = "Arnold Press", bandedChestPress = "Banded Chest Press", behindNeckPress = "Behind Neck Press"
    case benchPress = "Bench Press", cableChestFly = "Cable Chest Fly", cableLateralRaise = "Cable Lateral Raise"
    case chestFly = "Chest Fly", closeGripBench = "Close-Grip Bench Press", declineBenchPress = "Decline Bench Press"
    case declinePushups = "Decline Push-ups", diamondPushUps = "Diamond Push-ups", dumbbellFly = "Dumbbell Fly"
    case dumbbellPress = "Dumbbell Press", explosivePushups = "Explosive Push-ups", facePulls = "Face Pulls"
    case floorPress = "Floor Press", frontRaises = "Front Raises", hexPress = "Hex Press"
    case highInclinePress = "High Incline Press", inclinePress = "Incline Press", isometricChestHold = "Isometric Chest Hold"
    case kneelingLandminePress = "Kneeling Landmine Press", landminePress = "Landmine Press"
    case lateralRaises = "Lateral Raises", lowInclinePress = "Low Incline Press"
    case machineChestPress = "Machine Chest Press", machineShoulderPress = "Machine Shoulder Press"
    case medicineBallChestPress = "Medicine Ball Chest Press", militaryPress = "Military Press"
    case overheadDumbbellExtension = "Overhead Dumbbell Extension", pecDeck = "Pec Deck", pikePress = "Pike Press"
    case platePress = "Plate Press", plateRaises = "Plate Raises", pushPress = "Push Press"
    case pushUps = "Push-ups", pushdown = "Pushdown", pushupToRenegadeRow = "Push-up to Renegade Row"
    case reverseFly = "Reverse Fly", seatedDumbbellPress = "Seated Dumbbell Press", shoulderPress = "Shoulder Press"
    case shoulderShrugs = "Shoulder Shrugs", shrugs = "Shrugs", singleArmDumbbellPress = "Single Arm Dumbbell Press"
    case singleArmFly = "Single Arm Fly", smithMachinePress = "Smith Machine Press", tricepDips = "Tricep Dips"
    case uprightRow = "Upright Row", weightedPushups = "Weighted Push-ups"

    var id: String { self.rawValue }
}

// Pull-focused workouts
enum PullWorkout: String, CaseIterable, Identifiable, Hashable {
    case alternatingDumbbellRow = "Alternating Dumbbell Row", assistedPullUps = "Assisted Pull-ups"
    case backExtension = "Back Extension", barbellRow = "Barbell Row", barbellShrug = "Barbell Shrug"
    case behindTheNeckPulldown = "Behind The Neck Pulldown", bentOverDumbbellRow = "Bent Over Dumbbell Row"
    case blockPull = "Block Pull", cableRearDeltFly = "Cable Rear Delt Fly", cableRows = "Cable Rows"
    case cableShrug = "Cable Shrug", chestSupportedRow = "Chest Supported Row", chinUps = "Chin-ups"
    case deadlift = "Deadlift", deadliftVariations = "Deadlift Variations", deficitDeadlift = "Deficit Deadlift"
    case dumbbellShrug = "Dumbbell Shrug", facePulls = "Face Pulls", goodMornings = "Good Mornings"
    case heavyRows = "Heavy Rows", hammerRow = "Hammer Row", invertedBarbellRow = "Inverted Barbell Row"
    case invertedRows = "Inverted Rows", krocRows = "Kroc Rows", landmineRows = "Landmine Rows"
    case latPushdown = "Lat Pushdown", latPulldown = "Lat Pulldown", machinePulldown = "Machine Pulldown"
    case meadowRows = "Meadow Rows", narrowGripPullup = "Narrow Grip Pull-up"
    case neutralGripPullup = "Neutral Grip Pull-up", pendlayRow = "Pendlay Row", pullUps = "Pull-ups"
    case pullovers = "Pullovers", rackPulls = "Rack Pulls", renegadeRows = "Renegade Rows"
    case resistanceBandRow = "Resistance Band Row", reverseGripLatPulldown = "Reverse Grip Lat Pulldown"
    case RomanianDeadlift = "Romanian Deadlift", seatedRow = "Seated Row", sealRow = "Seal Row"
    case shrugs = "Shrugs", singleArmRow = "Single Arm Row", straightArmPulldown = "Straight Arm Pulldown"
    case sumoDeadlift = "Sumo Deadlift", TBarRow = "T-Bar Row", trapBarDeadlift = "Trap Bar Deadlift"
    case uprightRow = "Upright Row", wideGripPullup = "Wide Grip Pull-up"

    var id: String { self.rawValue }
}

// Bicep workouts
enum BicepWorkout: String, CaseIterable, Identifiable, Hashable {
    case alternatingDumbbellCurl = "Alternating Dumbbell Curl", barbell21s = "Barbell 21s"
    case barbellConcentrationCurl = "Barbell Concentration Curl", barbellCurl = "Barbell Curl"
    case barbellPreacherCurl = "Barbell Preacher Curl", barbellReverseCurl = "Barbell Reverse Curl"
    case bicepCurl = "Bicep Curl", cableCurl = "Cable Curl", cableHammerCurl = "Cable Hammer Curl"
    case cableReverseCurl = "Cable Reverse Curl", concentrationCurl = "Concentration Curl"
    case concentrationHammerCurl = "Concentration Hammer Curl", crossBodyHammerCurl = "Cross-Body Hammer Curl"
    case declineDumbbellCurl = "Decline Dumbbell Curl", dragCurl = "Drag Curl", dumbbell21s = "Dumbbell 21s"
    case dumbbellReverseCurl = "Dumbbell Reverse Curl", EZBarCurl = "EZ Bar Curl"
    case hammerCurl = "Hammer Curl", heavyBarbellCurl = "Heavy Barbell Curl"
    case inclineDumbbellCurl = "Incline Dumbbell Curl", inclineHammerCurl = "Incline Hammer Curl"
    case isometricBicepHold = "Isometric Bicep Hold", lightDumbbellCurl = "Light Dumbbell Curl"
    case lyingCableCurl = "Lying Cable Curl", lyingDumbbellCurl = "Lying Dumbbell Curl"
    case machineCurl = "Machine Curl", narrowGripBarbellCurl = "Narrow Grip Barbell Curl"
    case negativeBicepCurl = "Negative Bicep Curl", plateCurl = "Plate Curl"
    case plateHammerCurl = "Plate Hammer Curl", preacherCurl = "Preacher Curl"
    case preacherHammerCurl = "Preacher Hammer Curl", proneInclineCurl = "Prone Incline Curl"
    case resistanceBandCurl = "Resistance Band Curl", reverseCurl = "Reverse Curl"
    case ropeHammerCurl = "Rope Hammer Curl", seatedDumbbellCurl = "Seated Dumbbell Curl"
    case seatedEZBarCurl = "Seated EZ Bar Curl", seatedHammerCurl = "Seated Hammer Curl"
    case singleArmCableCurl = "Single Arm Cable Curl", slowTempoCurl = "Slow Tempo Curl"
    case spiderCurl = "Spider Curl", spiderDumbbellCurl = "Spider Dumbbell Curl"
    case standingCableCurl = "Standing Cable Curl", standingDumbbellCurl = "Standing Dumbbell Curl"
    case towelCurl = "Towel Curl", wideGripBarbellCurl = "Wide Grip Barbell Curl", zottmanCurl = "Zottman Curl"

    var id: String { self.rawValue }
}

// Tricep workouts
enum TricepWorkout: String, CaseIterable, Identifiable, Hashable {
    case bandedPushdown = "Banded Pushdown", barbellSkullCrusher = "Barbell Skull Crusher"
    case behindNeckExtension = "Behind Neck Extension", benchDips = "Bench Dips"
    case cableKickback = "Cable Kickbacks", cableOverheadExtension = "Cable Overhead Extension"
    case cableSkullCrusher = "Cable Skull Crusher", cableTricepPress = "Cable Tricep Press"
    case closeGripBench = "Close-Grip Bench Press", crossBodyExtension = "Cross-Body Extension"
    case declineSkullCrusher = "Decline Skull Crusher", diamondPushups = "Diamond Push-ups"
    case dips = "Dips", dumbbellCloseGripPress = "Dumbbell Close Grip Press"
    case dumbbellFloorPress = "Dumbbell Floor Press", dumbbellKickbacks = "Dumbbell Kickbacks"
    case dumbbellOverheadExtension = "Dumbbell Overhead Extension", dumbbellTatePress = "Dumbbell Tate Press"
    case EZBarOverheadExtension = "EZ Bar Overhead Extension", EZBarSkullCrusher = "EZ Bar Skull Crusher"
    case floorPress = "Floor Press", guillotinePress = "Guillotine Press"
    case inclineDumbbellExtension = "Incline Dumbbell Extension", inclineSkullCrusher = "Incline Skull Crusher"
    case isometricTricepHold = "Isometric Tricep Hold", JMpress = "JM Press"
    case kneelingCablePushdown = "Kneeling Cable Pushdown", lyingDumbbellTricepExtension = "Lying Dumbbell Tricep Extension"
    case narrowGripBenchPress = "Narrow Grip Bench Press", overheadExtension = "Overhead Extension"
    case plateTricepExtension = "Plate Tricep Extension", pushupNarrowGrip = "Pushup Narrow Grip"
    case resistanceBandOverheadExtension = "Resistance Band Overhead Extension"
    case reverseGripPushdown = "Reverse Grip Pushdown", ropePushdown = "Rope Pushdown"
    case seatedTricepPress = "Seated Tricep Press", singleArmCablePushdown = "Single Arm Cable Pushdown"
    case singleArmDumbbellExtension = "Single Arm Dumbbell Extension", singleArmTricepPushdown = "Single Arm Tricep Pushdown"
    case skullCrushers = "Skull Crushers", standingOverheadDumbbellExtension = "Standing Overhead Dumbbell Extension"
    case straightBarPushdown = "Straight Bar Pushdown", TatePress = "Tate Press"
    case tricepDipsOnRings = "Tricep Dips on Rings", tricepExtensionMachine = "Tricep Extension Machine"
    case tricepPressMachine = "Tricep Press Machine", tricepPushdown = "Tricep Pushdown"
    case tricepPushdownPulse = "Tricep Pushdown Pulse", weightedDips = "Weighted Dips"

    var id: String { self.rawValue }
}

// Leg workouts
enum LegWorkout: String, CaseIterable, Identifiable, Hashable {
    case barbellHipThrust = "Barbell Hip Thrust", boxJumps = "Box Jumps", boxSquat = "Box Squat"
    case BulgarianSplitSquat = "Bulgarian Split Squat", calfRaises = "Calf Raises"
    case cableLegExtension = "Cable Leg Extension", cablePullThrough = "Cable Pull Through"
    case curtsyLunges = "Curtsy Lunges", deadlift = "Deadlift", donkeyCalfRaise = "Donkey Calf Raise"
    case dumbbellSquat = "Dumbbell Squat", frontSquat = "Front Squat", gluteBridge = "Glute Bridge"
    case gobletSquat = "Goblet Squat", hackSquat = "Hack Squat", hipAdductorClosing = "Adductor Machine (Closing)"
    case hipAdductorOpening = "Adductor Machine (Opening)", jeffersonSquat = "Jefferson Squat"
    case jumpingLunges = "Jumping Lunges", lateralStepUps = "Lateral Step-ups", legCurl = "Leg Curl"
    case legExtension = "Leg Extension", legPress = "Leg Press", legPressCalfRaise = "Leg Press Calf Raise"
    case legPressVariations = "Leg Press Variations", lunges = "Lunges", lyingLegCurl = "Lying Leg Curl"
    case machineLegPress = "Machine Leg Press", narrowStanceSquat = "Narrow Stance Squat"
    case overheadSquat = "Overhead Squat", pistolSquats = "Pistol Squats", reverseLunges = "Reverse Lunges"
    case romanianDeadlift = "Romanian Deadlift", seatedCalfRaise = "Seated Calf Raise"
    case seatedLegCurl = "Seated Leg Curl", sideLunges = "Side Lunges", singleLegExtension = "Single Leg Extension"
    case singleLegPress = "Single Leg Press", sissySquat = "Sissy Squat", smithMachineSquat = "Smith Machine Squat"
    case splitSquats = "Split Squats", squat = "Squat", squatJumps = "Squat Jumps"
    case standingCalfRaise = "Standing Calf Raise", standingLegCurl = "Standing Leg Curl"
    case stepUps = "Step-ups", sumoSquat = "Sumo Squat", wallSit = "Wall Sit"
    case walkingLunges = "Walking Lunges", weightedStepUps = "Weighted Step-ups"
    case wideStanceSquat = "Wide Stance Squat", zercherSquat = "Zercher Squat"

    var id: String { self.rawValue }
}

// Glute workouts
enum GluteWorkout: String, CaseIterable, Identifiable, Hashable {
    case backwardLunge = "Backward Lunge", bandWalks = "Band Walks", bandedGluteBridge = "Banded Glute Bridge"
    case barbellHipThrustBridge = "Barbell Hip Thrust Bridge", benchStepUps = "Bench Step-ups"
    case boxSquat = "Box Squat", bulgarianSplitSquat = "Bulgarian Split Squat"
    case cableAbduction = "Cable Abduction", cableGluteBridge = "Cable Glute Bridge"
    case cableKickbacks = "Cable Kickbacks", cablePullThrough = "Cable Pull Through", cableSquat = "Cable Squat"
    case curtsyLunge = "Curtsy Lunge", donkeyKicks = "Donkey Kicks", fireHydrant = "Fire Hydrant"
    case frogPump = "Frog Pump", gluteBridge = "Glute Bridge", gluteBridgeMarch = "Glute Bridge March"
    case gluteBridgePulse = "Glute Bridge Pulse", gluteCableKickback = "Glute Cable Kickback"
    case gluteHamRaise = "Glute Ham Raise", gluteKickbackMachine = "Glute Kickback Machine"
    case gluteMediusKickback = "Glute Medius Kickback", gobletSquat = "Goblet Squat"
    case hipAbductionMachine = "Hip Abduction Machine", hipThrust = "Hip Thrust"
    case kettlebellDeadlift = "Kettlebell Deadlift", kettlebellSwing = "Kettlebell Swing"
    case lateralBandWalk = "Lateral Band Walk", lyingAbduction = "Lying Abduction"
    case monsterWalk = "Monster Walk", reverseHyper = "Reverse Hyper", romanianDeadlift = "Romanian Deadlift"
    case seatedHipAbduction = "Seated Hip Abduction", sideLyingLegLift = "Side Lying Leg Lift"
    case singleLegDeadlift = "Single Leg Deadlift", singleLegHipThrust = "Single Leg Hip Thrust"
    case singleLegSquat = "Single Leg Squat", sissySquat = "Sissy Squat", squat = "Squat", squatToPulse = "Squat To Pulse"
    case standingGluteKickback = "Standing Glute Kickback", stepUps = "Step-ups"
    case sumoDeadlift = "Sumo Deadlift", sumoSquat = "Sumo Squat", walkingLunges = "Walking Lunges"
    case weightedHipThrust = "Weighted Hip Thrust", weightedSideLunge = "Weighted Side Lunge"
    case weightedStepUps = "Weighted Step-ups", wideStanceLegPress = "Wide Stance Leg Press"

    var id: String { self.rawValue }
}

//Cardio workouts that require distance
enum DistanceCardioWorkout: String, CaseIterable, Identifiable, Hashable {
    case briskWalking = "Brisk Walking", casualWalking = "Casual Walking"
    case crossCountrySkiing = "Cross-Country Skiing"
    case cycleSprint = "Cycle Sprint", cycling = "Cycling"
    case elliptical = "Elliptical", ellipticalIntervals = "Elliptical Intervals"
    case hiking = "Hiking"
    case iceSkating = "Ice Skating"
    case kayaking = "Kayaking"
    case mountainBiking = "Mountain Biking"
    case outdoorCycling = "Outdoor Cycling", paddleboarding = "Paddleboarding", rollerblading = "Rollerblading"
    case rowing = "Rowing", rowingMachine = "Rowing Machine", rowingSprints = "Rowing Sprints"
    case running = "Running", skaterJumps = "Skater Jumps"
    case speedWalking = "Speed Walking"
    case stationaryBike = "Stationary Bike", swimming = "Swimming"
    case swimmingLaps = "Swimming Laps", treadmill = "Treadmill", treadmillInclineWalk = "Treadmill Incline Walk"
    case treadmillJogging = "Treadmill Jogging", treadmillSprint = "Treadmill Sprint"
    
    var id: String { self.rawValue }
}

//Cardio Workouts that are time based
enum TimeCardioWorkout: String, CaseIterable, Identifiable, Hashable {
    case battleRopes = "Battle Ropes"
    case burpees = "Burpees", burpeesWithPlank = "Burpees with Plank", burpeesWithPushUps = "Burpees with Push-Ups"
    case burpeesWithTricepDips = "Burpees with Tricep Dips", burpeesWithWallSits = "Burpees with Wall Sits"
    case circuitTraining = "Circuit Training", crossTrainer = "Cross Trainer",danceCardio = "Dance Cardio"
    case fitnessBoxing = "Fitness Boxing", HIIT = "HIIT", highKnees = "High Knees"
    case intervalTraining = "Interval Training", jumpRope = "Jump Rope"
    case jumpSquats = "Jump Squats", jumpingJacks = "Jumping Jacks"
    case kickboxing = "Kickboxing",  mountainClimbers = "Mountain Climbers"
    case shadowBoxing = "Shadow Boxing", spinClass = "Spin Class", stairClimbing = "Stair Climbing"
    case stairClimbingIntervals = "Stair Climbing Intervals", stairMaster = "Stair Master"
    case stepAerobics = "Step Aerobics"
    case waterAerobics = "Water Aerobics", zumba = "Zumba"
    
    var id: String{self.rawValue}
}

// Sports Workouts
enum SportsWorkout: String, CaseIterable, Identifiable, Hashable {
    case archery = "Archery", badminton = "Badminton", baseball = "Baseball", basketball = "Basketball"
    case billiards = "Billiards", bobsledding = "Bobsledding", bowling = "Bowling", boxing = "Boxing"
    case cricket = "Cricket", dance = "Dance", dodgeball = "Dodgeball", fencing = "Fencing"
    case fieldHockey = "Field Hockey", figureSkating = "Figure Skating", football = "Football"
    case gymnastics = "Gymnastics", handball = "Handball", hockey = "Hockey", horsebackRiding = "Horseback Riding"
    case iceSkating = "Ice Skating", judo = "Judo", karate = "Karate", kickball = "Kickball"
    case lacrosse = "Lacrosse", martialArts = "Martial Arts", racquetball = "Racquetball"
    case rockClimbing = "Rock Climbing", rowing = "Rowing", rugby = "Rugby", sailing = "Sailing"
    case skiJumping = "Ski Jumping", skiing = "Skiing", skateboarding = "Skateboarding"
    case snowboarding = "Snowboarding", soccer = "Soccer", softball = "Softball"
    case squash = "Squash", surfing = "Surfing", surfingCompetitive = "Surfing Competitive"
    case surfingLessons = "Surfing Lessons", tableTennis = "Table Tennis", taekwondo = "Taekwondo"
    case tennis = "Tennis", ultimateFrisbee = "Ultimate Frisbee", volleyball = "Volleyball"
    case wakeboarding = "Wakeboarding", waterPolo = "Water Polo", wrestling = "Wrestling"
    
    var id: String { self.rawValue }
}

enum StretchRoutine: String, CaseIterable, Identifiable, Hashable {
    case ankleCircles = "Ankle Circles", boatPoseStretch = "Boat Pose Stretch", bridgePose = "Bridge Pose"
    case butterflyStretch = "Butterfly Stretch", calfStretch = "Calf Stretch", catCow = "Cat-Cow"
    case chestStretch = "Chest Stretch", childsPose = "Child's Pose", cobraPose = "Cobra Pose"
    case cobraStretch = "Cobra Stretch", corpsePose = "Corpse Pose", cowFacePose = "Cow Face Pose"
    case crossBodyShoulderStretch = "Cross-Body Shoulder Stretch", dancerPose = "Dancer Pose"
    case downwardDog = "Downward-Facing Dog", eaglePose = "Eagle Pose", figureFourStretch = "Figure Four Stretch"
    case forearmStretch = "Forearm Stretch", forwardFold = "Forward Fold", gluteStretch = "Glute Stretch"
    case groinStretch = "Groin Stretch", hamstringsStretch = "Hamstring Stretch", happyBaby = "Happy Baby"
    case heroPose = "Hero Pose", hipFlexorStretch = "Hip Flexor Stretch", kneeToChest = "Knee to Chest"
    case lizardPose = "Lizard Pose", mountainPose = "Mountain Pose", neckStretch = "Neck Stretch"
    case overheadTricepStretch = "Overhead Tricep Stretch", pigeonPose = "Pigeon Pose"
    case puppyPose = "Puppy Pose", quadStretchStanding = "Quad Stretch Standing"
    case quadricepsStretch = "Quadriceps Stretch", recliningHandToBigToe = "Reclining Hand To Big Toe"
    case seatedForwardFold = "Seated Forward Fold", shoulderStretch = "Shoulder Stretch"
    case sideStretch = "Side Stretch", sphinxPose = "Sphinx Pose", spineTwist = "Spine Twist"
    case supineTwist = "Supine Twist", threadTheNeedle = "Thread The Needle", thunderboltPose = "Thunderbolt Pose"
    case treePose = "Tree Pose", tricepStretch = "Tricep Stretch", warriorPose = "Warrior Pose"
    case wideLegForwardFold = "Wide Leg Forward Fold", wristStretch = "Wrist Stretch", yoga = "Yoga"
    
    var id: String { self.rawValue }
}
