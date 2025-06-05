//
//  HomeView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userHeight") private var height: String = ""

    var body: some View {
        NavigationView {
            ZStack{
                GroupBox (label: Text("Current Progress")){
                    VStack(spacing: 10) {
                        Text("Height: \(height) \(heightUnit)")
                        Text("Weight: \(weight) \(weightUnit)")
                    }
                    .padding()
                    .navigationTitle("Home")
                }
            }
        }
    }

    // MARK: - Computed properties

    var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }

    var heightUnit: String {
        unitSystem == .metric ? "cm" : "in"
    }

    var weightUnit: String {
        unitSystem == .metric ? "kg" : "lbs"
    }
}
#Preview {
    HomeView()
}
