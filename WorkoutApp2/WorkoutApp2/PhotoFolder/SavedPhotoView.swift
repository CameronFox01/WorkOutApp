//
//  SavedPhotoView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/20/26.
//

import SwiftUI

struct SavedPhotosView: View {

    @Environment(\.dismiss) private var dismiss
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings

    let onSelect: (UIImage) -> Void

    @State private var photos: [SavedPhoto] = []
    
    let leftImage: UIImage?
    let rightImage: UIImage?
    
    let leftPhotoFileName: String
    let rightPhotoFileName: String
    
    var body: some View {
        NavigationView {
            ZStack {
                // Consistent Gradient Background
                LinearGradient(
                    colors: gradientSettings.selectedPreset.darkVariant(),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    
                    VStack(alignment: .leading) {
                        
                        // 👇 EMPTY STATE FIRST
                        if photos.isEmpty {
                            
                            EmptyPhotoView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                        } else {
                            
                            // 👇 your existing UI
                            
                            if leftImage != nil || rightImage != nil {
                                
                                Text("Current Comparison")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                    .foregroundStyle(.white)
                                
                                HStack {
                                    
                                    if let leftImage {
                                        Image(uiImage: leftImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    
                                    if let rightImage {
                                        Image(uiImage: rightImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            let sections = PhotoOrganizer.groupedByMonth(photos: photos)
                            
                            ForEach(sections) { section in
                                
                                Text(section.title)
                                    .font(.title2.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .foregroundStyle(.white)
                                
                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ],
                                    spacing: 12
                                ) {
                                    
                                    ForEach(section.photos) { photo in
                                        
                                        if let uiImage = UIImage(contentsOfFile: photo.url.path) {
                                            
                                            Button {
                                                onSelect(uiImage)
                                                dismiss()
                                            } label: {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(height: 120)
                                                    .frame(maxWidth: .infinity)
                                                    .clipped()
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .navigationTitle("Saved Photos")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    loadSavedPhotos()
                }
            }
        }
    }
    
    private func filteredPhotos() -> [SavedPhoto] {
        let excluded = Set([leftPhotoFileName, rightPhotoFileName].filter { !$0.isEmpty })
        return PhotoOrganizer.loadPhotos().filter { photo in
            !excluded.contains(photo.url.lastPathComponent)
        }
    }

    private func loadSavedPhotos() {
        photos = filteredPhotos()
    }

    private func documentsDirectory() throws -> URL {
        let urls = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )

        guard let dir = urls.first else {
            throw URLError(.fileDoesNotExist)
        }

        return dir
    }
}
