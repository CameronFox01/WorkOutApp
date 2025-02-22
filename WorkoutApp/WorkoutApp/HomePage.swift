//
//  ContentView.swift
//  WorkoutApp
//
//  Created by Cameron Fox on 2/20/25.
//

import SwiftUI
struct ProfileWindow: View {
    var body: some View {
        VStack {
            HStack{
                Spacer() // This spacer will push everything to the top
                
                Image(systemName: "person.circle")
                    .imageScale(.large)
                    .foregroundStyle(.black)
                    .font(.largeTitle)
                    .padding()
            }
            
            Spacer()// This pushes the HStack to the bottom
        }
        //This is the section for the pages on the bottom
        .overlay(
            VStack {
                Spacer() // This spacer ensures that the HStack stays at the bottom
                HStack {

                    Button(action: {
                        print("Trophy Page Pressed")
                    }) {
                        pageButtonCreation(label: "trophy.circle", color: .green)
                    }
                    
                    Button(action: {
                        print("WorkOut Page Pressed")
                    }) {
                        pageButtonCreation(label: "dumbbell", color: .black)
                    }

                    Button(action: {
                        print("Sport Page Pressed")
                    }) {
                        pageButtonCreation(label: "sportscourt", color: .black)
                    }
                    
                    Button(action: {
                        print("OverView of Account Pressed")
                    }) {
                        pageButtonCreation(label: "person.circle", color: .black)
                    }
                }
                .padding() // Adds padding around the HStack
                .background(Color.white) // Background color to make it like a nav bar
                .shadow(radius: 5) // Optional: Add shadow for a better look
            }
            , alignment: .bottom
        )
        .edgesIgnoringSafeArea(.bottom) // Ignore safe area to place buttons at the very bottom
    }
}


#Preview {
    ProfileWindow()
}
