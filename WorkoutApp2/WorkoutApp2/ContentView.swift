//
//  ContentView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ImportView()
                .tabItem{
                    Label("Import", systemImage: "dumbbell")
                }
            PhotoView()
                .tabItem{
                    Label("Camera", systemImage: "camera")
                }
            NavigationView {
                           AccountView()
            }
                .tabItem {
                    Label("Account", systemImage: "person")
                }
        }
    }
}


#Preview {
    ContentView()
}
