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
    @AppStorage("userTargetWeight") private var targetWeight: String = ""

    var body: some View {
        NavigationView {
            VStack {
                GroupBox(label: Text("Current Progress")) {
                    VStack(spacing: 10) {
                        Text("Weight: \(weight) \(weightUnit)")
                        if let difference = weightDifference {
                            Text("Difference to target: \(difference, specifier: "%.1f") \(weightUnit)")
                        } else {
                            Text("Set your target weight to see difference")
                                .foregroundColor(.gray)
                                .italic()
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AccountView()) {
                        Image(systemName: "person.circle")
                            .font(.title)
                    }
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
    
    var weightDifference: Double? {
            guard let current = Double(weight),
                  let target = Double(targetWeight) else {
                return nil
            }
            return abs(target - current)
        }
}

#Preview {
    HomeView()
}
