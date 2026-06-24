//
//  MeasurementRecapView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/24/26.
//

import SwiftUI
import Foundation

struct MeasurementRecapView: View {
    @StateObject private var gradientSettings = GradientSettings()
    @State private var showSheet = false

    // AppStorage for each measurement
    @AppStorage("measureChest")     private var chest: String = ""
    @AppStorage("measureWaist")     private var waist: String = ""
    @AppStorage("measureHips")      private var hips: String = ""
    @AppStorage("measureBiceps")    private var biceps: String = ""
    @AppStorage("measureThighs")    private var thighs: String = ""
    @AppStorage("measureNeck")      private var neck: String = ""
    @AppStorage("measureCalves")    private var calves: String = ""
    @AppStorage("measureShoulders") private var shoulders: String = ""
    @AppStorage("measurementUnit")  private var unit: String = "in"

    private var measurements: [(label: String, value: String)] {
        [
            ("Chest",     chest),
            ("Shoulders", shoulders),
            ("Waist",     waist),
            ("Hips",      hips),
            ("Biceps",    biceps),
            ("Thighs",    thighs),
            ("Neck",      neck),
            ("Calves",    calves),
        ]
    }

    var body: some View {
        Button {
            showSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                headerRow
                Divider()
                    .overlay(gradientSettings.selectedPreset.textOnDarkBackground.opacity(0.3))
                measurementGrid
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.white.opacity(0.30))
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSheet) {
            MeasurementInputSheet()
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Measurements")
                    .font(.headline)
                    .foregroundStyle(.black)
                Text("All in \(unit == "in" ? "inches" : "centimeters")")
                    .font(.caption)
                    .foregroundStyle(.black)
            }
            Spacer()
            Image(systemName: "ruler")
                .font(.title2)
                .foregroundStyle(.black)
        }
    }

    // MARK: - Grid

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

    // MARK: - Cell

    private func measurementCell(label: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.black)

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(value.isEmpty ? "--" : value)
                        .font(.title3.bold())
                        .foregroundStyle(.black)

                    if !value.isEmpty {
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.black)
                    }
                }
            }
            Spacer()
        }
        .padding(12)
        .background(.white.opacity(0.12))
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
    }
}
