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
    
    // Everything needed for counting down
    @Binding var totalSeconds: Int
    @Binding var remainingSeconds: Int
    @Binding var isTimerRunning: Bool
    
    // Everything Needed for counting up
    @Binding var isStopWatchRunning: Bool
    @Binding var startTime: Date
    @Binding var stopWatchString: String
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let stopWatch = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    init(totalSeconds: Binding<Int>, remainingSeconds: Binding<Int>, isTimerRunning: Binding<Bool>, isStopWatchRunning: Binding<Bool>, startTime: Binding<Date>, timerString: Binding<String>) {
        self._totalSeconds = totalSeconds
        self._remainingSeconds = remainingSeconds
        self._isTimerRunning = isTimerRunning
        self._isStopWatchRunning = isStopWatchRunning
        self._startTime = startTime
        self._stopWatchString = timerString
    }

    var body: some View {
        NavigationStack {

            VStack(spacing: 32) {

                // Optional mini timer view (kept as-is)
                HStack(spacing: 16) {

                    // MARK: - Stop
                    Button {
                        if isStopWatchRunning {
                            isStopWatchRunning = false
                        } else {
                            stopWatchString = "00:00"
                        }
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
                        Text(stopWatchString)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .monospacedDigit()
                    }

                    Spacer()

                    // MARK: - Start / Reset
                    Button {
                        if !isStopWatchRunning {
                            stopWatchString = "00:00"
                            startTime = Date()
                            isStopWatchRunning = true
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
                .onReceive(stopWatch) { _ in
                    guard isStopWatchRunning else { return }

                    let elapsed = Date().timeIntervalSince(startTime)

                    let minutes = Int(elapsed) / 60
                    let seconds = Int(elapsed) % 60

                    stopWatchString = String(format: "%02d:%02d", minutes, seconds)
                }

                // MARK: - Timer Display Card
                VStack(spacing: 12) {

                    Text(formatTime(remainingSeconds))
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .padding(.vertical, 10)

                    Text("Remaining Time")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)

                // MARK: - Time Controls (+ / -)
                HStack(spacing: 40) {

                    Button {
                        totalSeconds = max(0, totalSeconds - 30)
                        remainingSeconds = max(0, remainingSeconds - 30)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                    }

                    VStack(spacing: 4) {
                        Text("Adjust Time")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("+ / - 30 sec")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        totalSeconds += 30
                        remainingSeconds += 30
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.green)
                    }
                }

                // MARK: - Start / Stop Controls
                HStack(spacing: 16) {

                    Button {
                        if isTimerRunning {
                            isTimerRunning = false
                        } else {
                            totalSeconds = 60
                            remainingSeconds = 60
                        }
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                    Button {
                        isTimerRunning = true
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding(.horizontal)
            }
            .padding(.top, 20)
            .onReceive(timer) { _ in
                guard isTimerRunning else { return }

                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    isTimerRunning = false
                }
            }

            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Timer")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }
            }
        }
    }

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
