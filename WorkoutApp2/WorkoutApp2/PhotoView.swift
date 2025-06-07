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
                HStack{
                    Button("Import Picture"){
                        print("Import Picture pressed")
                    }
                    
                    Button("Take Photo"){
                        print("Take Photo Pressed")
                    }
                }
            }
            .navigationTitle("Camera")
        }
    }
}

#Preview {
    PhotoView()
}
