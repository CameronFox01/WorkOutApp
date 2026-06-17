//
//  GradientPickerSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/16/26.
//
import SwiftUI

struct GradientPickerSection: View {
    @EnvironmentObject var gradientSettings: GradientSettings

    @State private var customColor1: Color = .blue
    @State private var customColor2: Color = .cyan
    @State private var customColor3: Color = Color(.systemBackground)
    @State private var showingCustomEditor = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Preset swatches
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(GradientPreset.presets) { preset in
                        PresetSwatch(
                            preset: preset,
                            isSelected: preset.name == gradientSettings.selectedPreset.name
                        ) {
                            gradientSettings.select(preset)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Divider()

            // Custom gradient toggle
            Button {
                showingCustomEditor.toggle()
            } label: {
                HStack {
                    Image(systemName: "paintpalette.fill")
                        .frame(width: 28)
                    Text("Custom Colors")
                    Spacer()
                    Image(systemName: showingCustomEditor ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .foregroundStyle(.primary)

            if showingCustomEditor {
                VStack(spacing: 12) {
                    ColorPicker("Top Color", selection: $customColor1, supportsOpacity: false)
                    ColorPicker("Middle Color", selection: $customColor2, supportsOpacity: false)
                    ColorPicker("Bottom Color", selection: $customColor3, supportsOpacity: false)

                    LinearGradient(
                        colors: [customColor1, customColor2, customColor3],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button("Apply Custom Gradient") {
                        gradientSettings.setCustomColors([customColor1, customColor2, customColor3])
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.15))
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 4)
            }
        }
    }
}

private struct PresetSwatch: View {
    let preset: GradientPreset
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                LinearGradient(
                    colors: preset.swiftUIColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )

                Text(preset.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
