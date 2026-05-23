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
    @State var isTimerRunning: Bool = false
    @State private var startTime = Date()
    @State private var timerString: String = "00:00"
    // Countdown state
    @State private var totalSeconds: Int = 60
    @State private var remainingSeconds: Int = 60
    @State private var isCountdownRunning: Bool = false
    private let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State private var showBigTimer = false

    @AppStorage("showStopWatch") private var showStopWatch: Bool = true
    
    var body: some View {
        
        if showStopWatch { //Section for stopwatch to be shown.
            
            HStack(spacing: 16) {
                
                // MARK: - Stop
                Button {
                    isTimerRunning = false
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                
                Spacer()
                
                // MARK: - Timer Display (tap to expand)
                VStack(spacing: 2) {
                    Text(timerString)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .onTapGesture {
                            showBigTimer = true
                        }
                    
                    Text("Tap to expand")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // MARK: - Start / Reset
                Button {
                    if !isTimerRunning {
                        timerString = "00:00"
                        startTime = Date()
                        isTimerRunning = true
                    }
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .onReceive(timer) { _ in
                guard isTimerRunning else { return }
                
                let elapsed = Date().timeIntervalSince(startTime)
                
                let minutes = Int(elapsed) / 60
                let seconds = Int(elapsed) % 60
                
                timerString = String(format: "%02d:%02d", minutes, seconds)
            }
            .sheet(isPresented: $showBigTimer) {
                TimeViewBig()
            }
        } else { // section to show compact countdown
            HStack(spacing: 12) {
                // Decrease time
                Button {
                    guard !isCountdownRunning else { return }
                    adjustTime(by: -30)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: 36, height: 36)
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
                        .frame(width: 36, height: 36)
                }
                .tint(.blue)
                .buttonStyle(.bordered)

                Spacer(minLength: 0)

                // Start/Stop toggle (single button)
                Button {
                    toggleCountdown()
                } label: {
                    Image(systemName: isCountdownRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(isCountdownRunning ? .gray : .green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .onReceive(countdownTimer) { _ in
                guard isCountdownRunning else { return }
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    isCountdownRunning = false
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }
            .sheet(isPresented: $showBigTimer) {
                TimeViewBig()
            }
        }
    }
    
    private func adjustTime(by delta: Int) {
        totalSeconds = max(0, totalSeconds + delta)
        remainingSeconds = max(0, remainingSeconds + delta)
    }

    private func toggleCountdown() {
        if isCountdownRunning {
            isCountdownRunning = false
        } else {
            // If remaining is zero, reset from total
            if remainingSeconds == 0 { remainingSeconds = max(0, totalSeconds) }
            isCountdownRunning = remainingSeconds > 0
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    TimerView()
}
