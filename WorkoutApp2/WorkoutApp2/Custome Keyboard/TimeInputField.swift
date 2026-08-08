//
//  TimeInputField.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 8/4/26.
//
import SwiftUI

struct TimeInputField: View {
    let timeKeyboard: Bool
    let title: String
    @Binding var text: String
    let field: Field

    @State private var showingKeyboard = false
    @EnvironmentObject var gradientSettings: GradientSettings
    
    // Access the scroll proxy via a preference key or pass a closure if needed,
    // OR simplify by letting onChange trigger a global scroll coordinate space.
    // Alternatively, use a matched geometry effect or GeometryReader.
    
    var body: some View {
        Button {
            showingKeyboard = true
        } label: {
            HStack {
                Text(text.isEmpty ? title : text)
                    .foregroundStyle(text.isEmpty ? .gray.opacity(0.75) : gradientSettings.selectedPreset.bigTextOnDarkBackground)

                Spacer()
            }
            .padding(8)
            .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingKeyboard) {
            CustomDigitKeyboard(
                timeKeyboard: timeKeyboard,
                text: $text,
                isPresented: $showingKeyboard
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
    }
}

struct CustomDigitKeyboard: View {
    let timeKeyboard: Bool
    @Binding var text: String
    @Binding var isPresented: Bool
    @EnvironmentObject var gradientSettings: GradientSettings

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 3
    )

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientSettings.darkGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {

                LazyVGrid(columns: columns, spacing: 8) {
                    keyboardButton("1")
                    keyboardButton("2")
                    keyboardButton("3")

                    keyboardButton("4")
                    keyboardButton("5")
                    keyboardButton("6")

                    keyboardButton("7")
                    keyboardButton("8")
                    keyboardButton("9")

                    if timeKeyboard {
                        keyboardButton(":")
                    } else {
                        keyboardButton(".")
                    }
                    keyboardButton("0")

                    Button {
                        deleteLastCharacter()
                    } label: {
                        Image(systemName: "delete.left")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                    }
                }

                Button("Done") {
                    isPresented = false
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(gradientSettings.selectedPreset.textColor, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
           // .padding(.bottom, 8)
        }
    }

    private func keyboardButton(_ value: String) -> some View {
        Button {
            insert(value)
        } label: {
            Text(value)
                .font(.title3.weight(.medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func insert(_ value: String) {
        let separator = timeKeyboard ? ":" : "."

        if value == separator {
            guard !text.contains(separator) else { return }
            guard !text.isEmpty else { return }
            text.append(separator)
            return
        }

        let newText = text + value
        guard isValid(newText) else { return }
        text = newText
    }


    private func deleteLastCharacter() {
        guard !text.isEmpty else { return }
        text.removeLast()
    }

    private func isValid(_ value: String) -> Bool {
        timeKeyboard ? isValidTime(value) : isValidDecimal(value)
    }
    
    private func isValidTime(_ value: String) -> Bool {
        let parts = value.split(separator: ":", omittingEmptySubsequences: false)

        if parts.count == 1 {
            return parts[0].count <= 3
        }

        guard parts.count == 2 else {
            return false
        }

        guard parts[1].count <= 2 else {
            return false
        }

        if let seconds = Int(parts[1]), seconds > 59 {
            return false
        }

        return true
    }
    
    private func isValidDecimal(_ value: String) -> Bool {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)

        if parts.count == 1 {
            // Whole-number part — cap at 4 digits (e.g. up to 9999)
            return parts[0].count <= 4
        }

        guard parts.count == 2 else {
            return false
        }

        // Only 2 digits allowed after the decimal point
        return parts[1].count <= 2
    }
}



#Preview("Time Input Field") {
    struct PreviewWrapper: View {
        @State private var time = ""
        @State private var focusedField: Field?

        var body: some View {
            ZStack {
                LinearGradient(
                    colors: GradientSettings().darkGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    TimeInputField(
                        timeKeyboard: true,
                        title: "Enter time",
                        text: $time,
                        field: .time
                    )
                        .padding(.horizontal)

                    Text("Current value: \(time.isEmpty ? "—" : time)")
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
    }

    return PreviewWrapper()
        .environmentObject(GradientSettings())
}

#Preview("Time Keyboard") {
    struct PreviewWrapper: View {
        @State private var time = "12:3"

        var body: some View {
            CustomDigitKeyboard(
                timeKeyboard: true,
                text: $time,
                isPresented: .constant(true)
            )
        }
    }

    return PreviewWrapper()
        .environmentObject(GradientSettings())
}
