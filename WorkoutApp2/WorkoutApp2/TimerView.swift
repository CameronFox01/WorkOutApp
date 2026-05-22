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
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Button("Stop Timer"){
                if isTimerRunning{
                    isTimerRunning = false
                }
            }
            .font(.headline.bold())
            .buttonStyle(.borderedProminent)
            .tint(Color.red)
           
            Spacer()
            
            Text(self.timerString)
                .font(.title)
                .bold()
            Spacer()
            
            Button("Start Timer") {
                if !isTimerRunning{
                    // Resetting and setting up the timer
                    timerString = "00:00"
                    startTime = Date()
                    // Starting the timer
                    isTimerRunning = true
                }
            }
            .font(.headline.bold())
            .buttonStyle(.borderedProminent)
            .tint(Color.green)
        
        }
        .onReceive(timer) { _ in
            guard isTimerRunning else { return }
            
            let elapsed = Date().timeIntervalSince(startTime)
            
            let minutes = Int(elapsed) / 60
            let seconds = Int(elapsed) % 60
            
            timerString = String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    TimerView()
}
