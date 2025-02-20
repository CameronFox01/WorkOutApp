//
//  ContentView.swift
//  WorkoutApp
//
//  Created by Cameron Fox on 2/20/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "dumbbell")
                .imageScale(.large)
                .foregroundStyle(.black)
                .font(.largeTitle)
            Text("Let's WorkOut!!")
            
        }
        HStack{
            Button(action: {
                print("OverView of Account Pressed")
            }){
                pageButtonCreation(label: "person.circle")
            }
            
            Button(action: {
                print("WorkOut Page Pressed")
            }){
                pageButtonCreation(label: "dumbbell")
            }
            
            Button(action: {
                print("Sport Page Pressed")
            }){
                pageButtonCreation(label: "sportscourt")
            }
            
            Button(action: {
                print("Trophy Page Pressed")
            }){
                pageButtonCreation(label: "trophy.circle")
            }
        }
        .padding()
    }
    private func pageButtonCreation(label: String) -> some View {
        Image(systemName: label)
            .imageScale(.large)
            .foregroundStyle(.black)
    }
}

#Preview {
    ContentView()
}
