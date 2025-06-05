//
//  PhotoView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI

struct PhotoView: View {
    var body: some View {
        NavigationView{
            ZStack{
                Color.yellow
                Text("Photo")
            }
            .navigationTitle("Camera")
        }
    }
}

#Preview {
    PhotoView()
}
