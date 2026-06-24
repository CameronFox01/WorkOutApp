//
//  BMIView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/24/26.
//

import Foundation
import SwiftUI

struct BMIView: View {
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("heightUnit") private var heightUnit: String = "imperial"
    @AppStorage("weightUnit") private var weightUnit: String = "imperial"
    
    //Color Gradiant
    @StateObject private var gradientSettings = GradientSettings()
    
    @State private var showSheet = false

    var body: some View {
        Button{
            showSheet = true
        } label:{
            VStack(alignment: .leading, spacing: 16) {
                topRow
                scaleBar
            }
            .padding(24)
            .background(
                RoundedRectangle(
                    cornerRadius: 28
                )
                .fill(
                    .white.opacity(0.30)
                )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSheet) {
            BMIDetailSheet(
                bmi: calculateBMI(),
                poundsToHealthy: poundsToHealthy,
                poundsToGoal: poundsToGoal,
                weightUnit: weightUnit,
                category: bmiCategory
            )
        }
    }
    

    // MARK: - Top Row

    private var topRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Your BMI")
                    .font(.title3)
                    .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)

                Text(String(format: "%.1f", calculateBMI()))
                    .font(.title.bold())
                    .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)

                categoryBadge
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(healthyRangeTitle)
                    .font(.title3)
                    .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)

                Text(poundsToHealthyRangeText)
                    .font(.title.bold())
                    .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)

                Text(healthyRangeSubtitle)
                    .font(.headline)
                    .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
            }        }
    }

    // MARK: - Category Badge

    private var categoryBadge: some View {
        Text(bmiCategory.label)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(.white.opacity(0.22))
            .clipShape(Capsule())
    }
    
    // MARK: - Area for sentences for healthy range.
    var healthyRangeTitle: String {
        let bmi = calculateBMI()
        switch bmi {
        case ..<18.5: return "To reach healthy range"
        case 18.5..<25: return ""
        case 25..<30: return "To reach healthy range"
        default: return "To reach healthy range"
        }
    }

    var healthyRangeSubtitle: String {
        let bmi = calculateBMI()
        switch bmi {
        case ..<18.5: return "Need to gain weight"
        case 18.5..<25: return "Currently in healthy range"
        case 25..<30: return "Need to lose weight"
        default: return "Need to lose weight"
        }
    }

    // MARK: - Scale Bar

    private var scaleBar: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Gradient track
                    LinearGradient(
                        colors: [
                            Color.cyan,
                            Color.green,
                            Color.yellow,
                            Color(red: 0.976, green: 0.486, blue: 0.42),
                            Color(red: 0.851, green: 0.251, blue: 0.251)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 10)
                    .clipShape(Capsule())

                    // Marker dot
                    Circle()
                        .fill(.white)
                        .overlay(Circle().stroke(Color.black.opacity(0.25), lineWidth: 3))
                        .frame(width: 18, height: 18)
                        .offset(x: markerOffset(in: geo.size.width) - 9)
                        .animation(.spring(response: 0.4), value: calculateBMI())
                }
                .frame(height: 18)
            }
            .frame(height: 18)

            // Labels
            HStack {
                Text("Underweight\n<18.5")
                    .multilineTextAlignment(.leading)

                Spacer()

                Text("Healthy\n18.5–24.9")
                    .multilineTextAlignment(.center)

                Spacer()

                Text("Overweight\n25–29.9")
                    .multilineTextAlignment(.center)

                Spacer()

                Text("Obese\n30+")
                    .multilineTextAlignment(.trailing)
            }
            .font(.subheadline)
            .foregroundStyle(gradientSettings.selectedPreset.textOnDarkBackground)
        }
    }

    // MARK: - Calculations

    func calculateBMI() -> Double {
        let h = currentHeightInMeters
        let w = currentWeightInKg
        guard h > 0 else { return 0 }
        return w / pow(h, 2)
    }

    var currentHeightInMeters: Double {
        if heightUnit == "metric" {
            return (Double(height) ?? 0) / 100
        } else {
            return parseImperialHeight(height) * 0.0254
        }
    }

    var currentWeightInKg: Double {
        if weightUnit == "metric" {
            return Double(weight) ?? 0
        } else {
            return (Double(weight) ?? 0) / 2.20462
        }
    }

    func parseImperialHeight(_ raw: String) -> Double {
        if raw.contains("'") {
            let parts = raw.split(separator: "'")
            let feet = Double(parts.first ?? "0") ?? 0
            let inches = Double(parts.last ?? "0") ?? 0
            return (feet * 12) + inches
        }
        return Double(raw) ?? 0
    }

    func healthyWeightUpperBound() -> Double {
        return 24.9 * pow(currentHeightInMeters, 2)
    }

    func healthyWeightLowerBound() -> Double {
        return 18.5 * pow(currentHeightInMeters, 2)
    }

    var poundsToHealthy: Double {
        let bmi = calculateBMI()
        if bmi > 24.9 {
            return (currentWeightInKg - healthyWeightUpperBound()) * (weightUnit == "imperial" ? 2.20462 : 1)
        } else if bmi < 18.5 {
            return (currentWeightInKg - healthyWeightLowerBound()) * (weightUnit == "imperial" ? 2.20462 : 1)
        }
        return 0
    }

    var poundsToHealthyRangeText: String {
        let val = abs(poundsToHealthy)
        let unit = weightUnit == "imperial" ? "lbs" : "kg"
        
        if val == 0 {
            return "You're there!"
        }
        
        let sign = poundsToHealthy > 0 ? "-" : "+"
        return String(format: "\(sign)%.0f \(unit)", val)
    }

    var bmiCategory: (label: String, color: Color) {
        let bmi = calculateBMI()
        switch bmi {
        case ..<18.5: return ("Underweight", .blue)
        case 18.5..<25: return ("✓ Healthy weight", .green)
        case 25..<30: return ("Overweight", .orange)
        default: return ("Obese", .red)
        }
    }

    // MARK: - Scale marker position

    func markerOffset(in width: Double) -> Double {
        // Map BMI 15–40 across the bar width
        let minBMI = 15.0
        let maxBMI = 40.0
        let clamped = min(max(calculateBMI(), minBMI), maxBMI)
        return (clamped - minBMI) / (maxBMI - minBMI) * width
    }
    
    var poundsToGoal: Double {
        // Targets BMI of 22 (middle of healthy range)
        let targetWeightKg = 22.0 * pow(currentHeightInMeters, 2)
        let diff = (currentWeightInKg - targetWeightKg) * (weightUnit == "imperial" ? 2.20462 : 1)
        return diff
    }        
}


#Preview {
    ZStack{
        LinearGradient(
            colors: [.blue,.black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        BMIView()
    }
}
