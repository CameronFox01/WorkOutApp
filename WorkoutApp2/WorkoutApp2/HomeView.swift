//
//  HomeView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView{
            ZStack {
                Color.pink
                Text("HomeView")
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
