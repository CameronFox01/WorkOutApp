//
//  TimeViewBig.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/22/26.
//

import SwiftUI

//The view for the big Screen
struct TimeViewBig: View {
    @Environment(\.dismiss) private var dismiss

    // Countdown
    @Binding var totalSeconds: Int
    @Binding var remainingSeconds: Int
    @Binding var isTimerRunning: Bool

    // Stopwatch
    @Binding var isStopWatchRunning: Bool
    @Binding var startTime: Date
    @Binding var stopWatchString: String
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let stopWatch = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    init(
        totalSeconds: Binding<Int>,
        remainingSeconds: Binding<Int>,
        isTimerRunning: Binding<Bool>,
        isStopWatchRunning: Binding<Bool>,
        startTime: Binding<Date>,
        timerString: Binding<String>
    ) {
        self._totalSeconds = totalSeconds
        self._remainingSeconds = remainingSeconds
        self._isTimerRunning = isTimerRunning
        self._isStopWatchRunning = isStopWatchRunning
        self._startTime = startTime
        self._stopWatchString = timerString
    }

    var body: some View {
        NavigationStack {

            ZStack {

                // MARK: - Background
                LinearGradient(
                    colors: gradientSettings.darkGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {

                        // MARK: - Main Timer Hero
                        VStack(spacing: 16) {

                            ZStack {

                                Circle()
                                    .stroke(
                                        Color.white.opacity(0.15),
                                        lineWidth: 18
                                    )
                                    .frame(width: 280, height: 280)

                                Circle()
                                    .trim(
                                        from: 0,
                                        to: progress
                                    )
                                    .stroke(
                                        AngularGradient(
                                            colors: [.green, .blue],
                                            center: .center
                                        ),
                                        style: StrokeStyle(
                                            lineWidth: 18,
                                            lineCap: .round
                                        )
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 280, height: 280)

                                VStack(spacing: 8) {

                                    Text(formatTime(remainingSeconds))
                                        .font(
                                            .system(
                                                size: 64,
                                                weight: .bold,
                                                design: .rounded
                                            )
                                        )
                                        .monospacedDigit()
                                        .foregroundStyle(.white)

                                    Text("Remaining")
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            }
                            .padding(.bottom, 20)
                            
                            // MARK: - Timer Controls
                            HStack(spacing: 40) {

                                controlButton(
                                    icon: "minus",
                                    color: .orange
                                ) {
                                    totalSeconds = max(0, totalSeconds - 30)
                                    remainingSeconds = max(0, remainingSeconds - 30)
                                }

                                controlButton(
                                    icon: isTimerRunning ? "pause.fill" : "play.fill",
                                    color: .green
                                ) {
                                    isTimerRunning.toggle()
                                }
                                .scaleEffect(1.2)

                                controlButton(
                                    icon: "plus",
                                    color: .blue
                                ) {
                                    totalSeconds += 30
                                    remainingSeconds += 30
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)

                        // MARK: - Stopwatch Card
                        VStack(alignment: .leading, spacing: 18) {

                            HStack {

                                Label(
                                    "Stopwatch",
                                    systemImage: "stopwatch.fill"
                                )
                                .font(.headline)

                                Spacer()

                                Circle()
                                    .fill(
                                        isStopWatchRunning
                                        ? .green
                                        : .gray.opacity(0.5)
                                    )
                                    .frame(width: 10, height: 10)
                            }
                            .foregroundStyle(.white)

                            Text(stopWatchString)
                                .font(
                                    .system(
                                        size: 42,
                                        weight: .bold,
                                        design: .rounded
                                    )
                                )
                                .monospacedDigit()
                                .foregroundStyle(.white)

                            HStack(spacing: 16) {

                                Button {

                                    if !isStopWatchRunning {
                                        startTime = Date()
                                        isStopWatchRunning = true
                                    }

                                } label: {

                                    Label("Start", systemImage: "play.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)

                                Button {

                                    if isStopWatchRunning {
                                        isStopWatchRunning = false
                                    } else {
                                        stopWatchString = "00:00"
                                    }

                                } label: {

                                    Label("Stop", systemImage: "stop.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.white.opacity(0.12))
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .principal) {
                    Text("Timer")
                        .font(.largeTitle).bold()
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
            }
            .onReceive(timer) { _ in

                guard isTimerRunning else { return }

                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    isTimerRunning = false
                }
            }
            .onReceive(stopWatch) { _ in

                guard isStopWatchRunning else { return }

                let elapsed = Date().timeIntervalSince(startTime)

                let minutes = Int(elapsed) / 60
                let seconds = Int(elapsed) % 60

                stopWatchString = String(
                    format: "%02d:%02d",
                    minutes,
                    seconds
                )
            }
        }
    }

    // MARK: - Progress Ring
    var progress: CGFloat {

        guard totalSeconds > 0 else { return 0 }

        return CGFloat(remainingSeconds)
        / CGFloat(totalSeconds)
    }

    // MARK: - Reusable Control Button
    func controlButton(
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 68, height: 68)
                .background(color.gradient)
                .clipShape(Circle())
                .shadow(radius: 8)
        }
    }

    // MARK: - Time Formatter
    func formatTime(_ seconds: Int) -> String {

        let minutes = seconds / 60
        let sec = seconds % 60

        return String(format: "%02d:%02d", minutes, sec)
    }
}

#Preview {
    TimeViewBig(
        totalSeconds: .constant(300),
        remainingSeconds: .constant(300),
        isTimerRunning: .constant(false),
        isStopWatchRunning: .constant(false),
        startTime: .constant(Date()),
        timerString: .constant("00:00")
    )
}
