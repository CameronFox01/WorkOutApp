//
//  TimerView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/22/26.
// This will include the following:
// 1. Display a timer for the user to start and stop from the home page.
// 2. Once clicked on it will open up a view that will allow the user to edit the time for the timer and in their still be able to start and stop the timer.
// 3. In the bigger view their will be one for counting up and one for counting down.
// 4. For the small view make it where there is a setting in the big screen that will allow the user to pick which one is used in the small one or not.

import SwiftUI

struct TimerView: View {
    // Storage for the Stop Watch
    @AppStorage("isStopWatchRunning")
    private var isStopWatchRunning: Bool = false

    @AppStorage("startStopWatch")
    private var startStopWatch: Double = 0

    @AppStorage("stopWatchString")
    private var stopWatchString: String = "00:00.00"
    
    @AppStorage("stopWatchLaps") private var lapsData: String = "[]"

    
    // Countdown state
    @AppStorage("totalSeconds") private var totalSeconds: Int = 60
    @AppStorage("remainingSeconds") private var remainingSeconds: Int = 60
    @AppStorage("isCountdownRunning") private var isCountdownRunning: Bool = false
    
    @AppStorage("accumulatedElapsed") private var accumulatedElapsed: Double = 0

    private let countdownTimer =
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let timer =
        Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    @State private var showBigTimer = false

    @AppStorage("showStopWatch")
    private var showStopWatch: Bool = true

    var body: some View {

        if showStopWatch {
            VStack {
                HStack(spacing: 16) {
                    
                    // Stop
                    Button {
                        if isStopWatchRunning {
                            accumulatedElapsed = Date().timeIntervalSince1970 - startStopWatch
                            isStopWatchRunning = false
                        } else {
                            stopWatchString = "00:00.00"
                            accumulatedElapsed = 0
                            clearLaps()
                        }
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    
                    Spacer()
                    
                    // Timer Display
                    VStack(spacing: 2) {
                        
                        Text(stopWatchString)
                            .font(.system(size: 25,
                                          weight: .bold,
                                          design: .rounded))
                            .monospacedDigit()
                            .onTapGesture {
                                showBigTimer = true
                            }
                        
                        Text("Tap to expand")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if !isStopWatchRunning {
                        // Start
                        Button {
                            
                            if !isStopWatchRunning {
                                
                                startStopWatch = Date().timeIntervalSince1970 - accumulatedElapsed
                                
                                isStopWatchRunning = true
                            }
                            
                        } label: {
                            Image(systemName: "play.fill")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        
                    } else {
                        Button {
                            addLap()
                        } label: {
                            Image(systemName: "stopwatch.fill")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                } // End of HStack
                if !laps.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Laps")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ForEach(Array(laps.enumerated().reversed()), id: \.offset) { index, lap in
                            HStack {
                                Text("Lap \(index + 1)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(lap)
                                    .font(.system(.subheadline, design: .rounded).bold())
                                    .monospacedDigit()
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            } // End of VStack
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(
                maxWidth: .infinity,
                alignment: .topLeading
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
                .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        Color.white.opacity(0.12),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: .black.opacity(0.08),
                radius: 12,
                x: 0,
                y: 5
            )

            // FIXED
            .onReceive(timer) { _ in
                guard isStopWatchRunning else { return }

                let start = Date(timeIntervalSince1970: startStopWatch)
                let elapsed = Date().timeIntervalSince(start)

                let minutes = Int(elapsed) / 60
                let seconds = Int(elapsed) % 60
                let milliseconds = Int((elapsed * 100).truncatingRemainder(dividingBy: 100))

                stopWatchString = String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
            }
            .fullScreenCover(isPresented: $showBigTimer) {
                TimeViewBig(
                    totalSeconds: $totalSeconds,
                    remainingSeconds: $remainingSeconds,
                    isTimerRunning: $isCountdownRunning,
                    isStopWatchRunning: $isStopWatchRunning,
                    startTime: startTimeBinding,
                    timerString: $stopWatchString,
                    lapsData: $lapsData,
                    accumulatedElapsed: $accumulatedElapsed
                )
            }
            .onAppear(){
                UIApplication.shared.isIdleTimerDisabled = false
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        } else {
            // section to show compact countdown
            HStack(spacing: 10) {
                // Decrease time
                Button{
                    guard !isCountdownRunning else { return }
                    adjustTime(by: -30)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                 //       .frame(width: 36, height: 36)
                }
                .tint(.orange)
                .buttonStyle(.bordered)
                
                // Time display (tap to expand big view)
                VStack(spacing: 2) {
                    Text(formatTime(remainingSeconds))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .onTapGesture { showBigTimer = true }
                    Text(isCountdownRunning ? "Counting down" : "Tap to expand")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(minWidth: 100)
                
                // Increase time
                Button {
                    guard !isCountdownRunning else { return }
                    adjustTime(by: 30)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                      //  .frame(width: 36, height: 36)
                }
                .tint(.blue)
                .buttonStyle(.bordered)
                
                Spacer(minLength: 0)
                
                // Stop Button
                Button{
                    if isCountdownRunning {
                        isCountdownRunning = false
                    } else {
                        totalSeconds = 60
                        remainingSeconds = 60
                    }
                    
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.red)
                
                // Start Button
                Button{
                    isCountdownRunning = true
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(
                maxWidth: .infinity,
                alignment: .topLeading
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
                .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        Color.white.opacity(0.12),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: .black.opacity(0.08),
                radius: 12,
                x: 0,
                y: 5
            )
            .onReceive(countdownTimer) { _ in
                guard isCountdownRunning else { return }
                if remainingSeconds > 0 { remainingSeconds -= 1 }
                else { isCountdownRunning = false
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }
            .fullScreenCover(isPresented: $showBigTimer) {
                TimeViewBig( totalSeconds: $totalSeconds,
                             remainingSeconds: $remainingSeconds,
                             isTimerRunning: $isCountdownRunning,
                             isStopWatchRunning: $isStopWatchRunning,
                             startTime: startTimeBinding,
                             timerString: $stopWatchString,
                             lapsData: $lapsData,
                             accumulatedElapsed: $accumulatedElapsed
                )
            }
            .onAppear(){
                UIApplication.shared.isIdleTimerDisabled = false
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }

    // MARK: - Helpers
    
    private var laps: [String] {
        get { (try? JSONDecoder().decode([String].self, from: Data(lapsData.utf8))) ?? [] }
    }

    private func addLap() {
        var current = laps
        current.append(stopWatchString)
        if let data = try? JSONEncoder().encode(current),
           let str = String(data: data, encoding: .utf8) {
            lapsData = str
        }
    }

    private func clearLaps() {
        lapsData = "[]"
    }

    private func adjustTime(by delta: Int) {
        totalSeconds = max(0, totalSeconds + delta)
        remainingSeconds = max(0, remainingSeconds + delta)
    }

    private func toggleCountdown() {
        if isCountdownRunning {
            isCountdownRunning = false
        } else {

            if remainingSeconds == 0 {
                remainingSeconds = max(0, totalSeconds)
            }

            isCountdownRunning = remainingSeconds > 0
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Date Conversion

    private var startTimeBinding: Binding<Date> {
        Binding<Date>(
            get: {
                Date(timeIntervalSince1970: startStopWatch)
            },
            set: { newValue in
                startStopWatch = newValue.timeIntervalSince1970
            }
        )
    }
}

#Preview {
    TimerView()
}
