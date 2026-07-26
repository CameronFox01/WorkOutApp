//
//  MeasurementRecapView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/24/26.
//

import SwiftUI
import Foundation

struct MeasurementRecapView: View {
    @EnvironmentObject var gradientSettings: GradientSettings

    @AppStorage("measureChest")     private var chest: String = ""
    @AppStorage("measureWaist")     private var waist: String = ""
    @AppStorage("measureHips")      private var hips: String = ""
    @AppStorage("measureBiceps")    private var biceps: String = ""
    @AppStorage("measureThighs")    private var thighs: String = ""
    @AppStorage("measureNeck")      private var neck: String = ""
    @AppStorage("measureCalves")    private var calves: String = ""
    @AppStorage("measureShoulders") private var shoulders: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue

    private var unitSystem: UnitSystem { UnitSystem(rawValue: unitSystemRaw) ?? .metric }
    private var unit: String { unitSystem == .imperial ? "in" : "cm" }

    private var measurements: [(label: String, value: String)] {
        [
            ("Chest",     chest),
            ("Shoulders", shoulders),
            ("Neck",      neck),
            ("Biceps",    biceps),
            ("Waist",     waist),
            ("Hips",      hips),
            ("Thighs",    thighs),
            ("Calves",    calves),
        ]
    }

    var body: some View {
        NavigationLink {
            MeasurementInputSheet()
                .environmentObject(gradientSettings)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                headerRow

                Divider()
                    .overlay(.white.opacity(0.2))

                measurementGrid
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.white.opacity(0.10))
                    .background(.ultraThinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 28)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var headerRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Measurements")
                    .font(.headline)
                    .foregroundStyle(gradientSettings.selectedPreset.bigTextOnDarkBackground)
                Text("All in \(unit == "in" ? "inches" : "centimeters")")
                    .font(.caption)
                    .foregroundStyle(gradientSettings.selectedPreset.subTextOnDarkBackground)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(gradientSettings.selectedPreset.textColor)
                    .frame(width: 44, height: 44)

                Image(systemName: "figure.stand")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
        }
    }

    private var measurementGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 14
        ) {
            ForEach(measurements, id: \.label) { item in
                measurementCell(label: item.label, value: item.value)
            }
        }
    }

    private func measurementCell(label: String, value: String) -> some View {
        let color = MeasurementAppearance.color(for: label)

        return HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(value.isEmpty ? "--" : value)
                        .font(.title3.bold())
                        .foregroundStyle(value.isEmpty ? .white.opacity(0.4) : .white)

                    if !value.isEmpty {
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.20))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue, .black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        MeasurementRecapView()
            .padding()
            .environmentObject(GradientSettings())
    }
}
