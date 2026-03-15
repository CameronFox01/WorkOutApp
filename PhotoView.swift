//
//  PhotoView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI
import PhotosUI

struct PhotoView: View {
    @State private var selectedItem: PhotosPickerItem? //Holds the selected photo item
    @State private var selectedItem2: PhotosPickerItem? //Holds the second selected photo
    @State private var selectedImage: UIImage? // holds the loaded image
    @State private var selectedImage2: UIImage? // holds second loaded image
    @State private var showingCamera =  false //controls camera sheet visiualbility

    var body: some View {
        VStack {
            HStack{
                Button(action: {
                    showingCamera = true //this will show the camera view
                }){
                    Text("Take Photo")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showingCamera){
                    CameraView(image: $selectedImage)
                }
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Select Photo")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .onChange(of: selectedItem) { oldValue, newItem in
                    Task {
                        do {
                            if let data = try await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                            } else {
                                print("Failed to load image data")
                            }
                        } catch {
                            print("Unexpected error occurred: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            //Second photo testing purpose
            PhotosPicker(
                selection: $selectedItem2,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Select Photo")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .onChange(of: selectedItem2) { oldValue, newItem in
                Task {
                    do {
                        if let data = try await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage2 = uiImage
                        } else {
                            print("Failed to load image data")
                        }
                    } catch {
                        print("Unexpected error occurred: \(error.localizedDescription)")
                    }
                }
            }
            
            HStack{
            
                // This is the section for the first Photo
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .presentationCornerRadius(40)
                } else {
                    Text("No Image Selected")
                        .foregroundStyle(.gray)
                        .padding()
                }
                
                //This is the section for the second Photo
                if let selectedImage2 = selectedImage2 {
                    Image(uiImage: selectedImage2)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .presentationCornerRadius(40)
                } else {
                    Text("No Image Selected")
                        .foregroundStyle(.gray)
                        .padding()
                }
            }
        }
        .padding()
    }
}

#Preview {
    PhotoView()
}
