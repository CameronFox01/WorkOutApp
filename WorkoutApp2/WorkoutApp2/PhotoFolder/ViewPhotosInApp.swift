//
//  ViewPhotosInApp.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/22/26.
//

import SwiftUI
import PhotosUI

struct ViewPhotosInApp: View {

    @Environment(\.dismiss) private var dismiss

    @State private var photos: [SavedPhoto] = []
    @State private var selectedImage: UIImage?
    @State private var showSaveOptions = false
    @State private var selectedURL: URL?

    var body: some View {
        NavigationView {

            ScrollView {

                let sections = PhotoOrganizer.groupedByMonth(
                    photos: photos
                )

                if photos.isEmpty {
                    EmptyPhotoView()
                } else {

                    VStack(alignment: .leading, spacing: 20) {

                        ForEach(sections) { section in

                            Text(section.title)
                                .font(.title2.bold())
                                .padding(.horizontal)

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
                                            selectedImage = uiImage
                                            showSaveOptions = true
                                            selectedURL = photo.url
                                        } label: {

                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 120)
                                                .frame(maxWidth: .infinity)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)

            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Stored in App")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }
            }
        }
        .onAppear {
            loadSavedPhotos()
        }
        .confirmationDialog(
            "What would you like to do?",
            isPresented: $showSaveOptions,
            titleVisibility: .visible
        ) {
            Button("Save to Phone Photos") {
                if let img = selectedImage {
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                }
            }

            Button("Delete Photo") {
                if let url = selectedURL {
                    deletePhoto(url)
                }
            }

            Button("Cancel", role: .cancel) { }
        }
    }

    // MARK: - Delete
    private func deletePhoto(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            photos.removeAll { $0.url == url }
        } catch {
            print("Failed to delete photo: \(error)")
        }
    }

    // MARK: - Load
    private func loadSavedPhotos() {
        photos = PhotoOrganizer.loadPhotos()
    }
}

#Preview {
    ViewPhotosInApp()
}
