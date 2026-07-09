//
//  PlateCalculatorView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/7/26.
//

import SwiftUI
import Foundation

struct PlateCalculatorView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gradientSettings: GradientSettings

    @FocusState private var isBarWeightFocused: Bool
    
    let weightUnit: String
    let onUseWeight: (Double) -> Void

    private var isImperial: Bool { weightUnit.lowercased() == "lbs" }

    @State private var barWeight: Double
    @State private var plateCounts: [Double: Int] = [:]

    private var availablePlates: [Double] {
        isImperial
            ? [45, 35, 25, 10, 5, 2.5]
            : [25, 20, 15, 10, 5, 2.5, 1.25]
    }

    init(weightUnit: String, onUseWeight: @escaping (Double) -> Void) {
        self.weightUnit = weightUnit
        self.onUseWeight = onUseWeight
        _barWeight = State(initialValue: weightUnit.lowercased() == "lbs" ? 45 : 20)
    }

    // Sum of (plate * count) per side, doubled for both sides of the bar
    private var plateTotal: Double {
        plateCounts.reduce(0) { $0 + ($1.key * Double($1.value)) } * 2
    }

    private var totalWeight: Double {
        barWeight + plateTotal
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: gradientSettings.darkGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // MARK: - Total
                        VStack(spacing: 6) {
                            Text(formattedNumber(totalWeight))
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                            Text(weightUnit)
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.top, 20)

                        // MARK: - Bar Weight
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Bar / Machine Start Weight")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white.opacity(0.8))

                            HStack {
                                Button {
                                    barWeight = max(0, barWeight - (isImperial ? 5 : 2.5))
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                }

                                Spacer()

                                TextField("Weight", text: barWeightTextBinding)
                                    .font(.title2.bold())
                                    .monospacedDigit()
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 90)
                                    .focused($isBarWeightFocused)

                                Spacer()

                                Button {
                                    barWeight += (isImperial ? 5 : 2.5)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                }
                            }
                            .foregroundStyle(.white)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.white.opacity(0.12))
                        )

                        // MARK: - Plates Per Side
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Plates Per Side")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white.opacity(0.8))

                            ForEach(availablePlates, id: \.self) { plate in
                                HStack {
                                    Text("\(formattedNumber(plate)) \(weightUnit)")
                                        .font(.headline)
                                        .frame(width: 90, alignment: .leading)

                                    Spacer()

                                    Button {
                                        let current = plateCounts[plate] ?? 0
                                        plateCounts[plate] = max(0, current - 1)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title3)
                                    }

                                    Text("\(plateCounts[plate] ?? 0)")
                                        .font(.title3.bold())
                                        .monospacedDigit()
                                        .frame(width: 30)

                                    Button {
                                        plateCounts[plate, default: 0] += 1
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                    }
                                }
                                .foregroundStyle(.white)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.white.opacity(0.12))
                        )

                        Button(role: .destructive) {
                            plateCounts.removeAll()
                            barWeight = isImperial ? 45 : 20
                        } label: {
                            Text("Reset")
                                .font(.subheadline.bold())
                        }
                        .padding(.top, 4)

                        Button {
                            onUseWeight(totalWeight)
                            dismiss()
                        } label: {
                            Text("Use This Weight")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)

                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Plate Calculator")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isBarWeightFocused = false
                    }
                }
            }
        }
    }
    
    private var barWeightTextBinding: Binding<String> {
        Binding(
            get: { formattedNumber(barWeight) },
            set: { newValue in
                barWeight = Double(newValue) ?? barWeight
            }
        )
    }

    private func formattedNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        } else {
            return String(format: "%.2f", value)
        }
    }
}

#Preview {
    PlateCalculatorView(weightUnit: "lbs") { total in
        print("Selected total weight: \(total)")
    }
    .environmentObject(GradientSettings())
}

#Preview("Kilograms") {
    PlateCalculatorView(weightUnit: "kg") { total in
        print("Selected total weight: \(total)")
    }
    .environmentObject(GradientSettings())
}
