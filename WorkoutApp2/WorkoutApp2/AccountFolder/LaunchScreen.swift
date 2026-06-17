//
//  LaunchScreen.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/31/26.
//

import SwiftUI

struct LaunchScreen: View {
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings
    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientSettings.darkGradientColors,
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Image("MyAppIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
