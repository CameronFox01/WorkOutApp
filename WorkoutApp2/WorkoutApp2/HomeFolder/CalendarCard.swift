//
//  CalendarCard.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/28/26.
//


import SwiftUI

struct CalendarCard: View {
    @EnvironmentObject var workoutData: WorkoutData
    @EnvironmentObject var gradientSettings: GradientSettings

    var body: some View {
        NavigationLink(destination: WorkoutCalendarView(
            entries: workoutData.entries,
            comingFromWidget: false
        )) {
            VStack(alignment: .leading) {
                Text("Calendar")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .center)

                WorkoutHeatMapView(entries: workoutData.entries)
                    .frame(height: 80)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .cardStyle()
    }
}