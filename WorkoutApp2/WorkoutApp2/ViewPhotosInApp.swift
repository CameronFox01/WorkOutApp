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

    @State private var savedPhotoURLs: [URL] = []
    @State private var selectedImage: UIImage?
    @State private var showSaveOptions = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {

                    ForEach(savedPhotoURLs, id: \.self) { url in

                        if let uiImage = UIImage(contentsOfFile: url.path) {

                            Button {
                                selectedImage = uiImage
                                showSaveOptions = true
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
                .padding()
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

                Button("Cancel", role: .cancel) { }
            }
        }
    }

    // MARK: - Load from app storage
    private func loadSavedPhotos() {
        do {
            let directory = try documentsDirectory()

            let files = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil
            )

            savedPhotoURLs = files
                .filter { $0.pathExtension.lowercased() == "jpg" }
                .sorted { $0.lastPathComponent > $1.lastPathComponent }

        } catch {
            print("Failed to load photos: \(error)")
        }
    }

    private func documentsDirectory() throws -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let dir = urls.first else {
            throw URLError(.fileDoesNotExist)
        }
        return dir
    }
}

#Preview {
    ViewPhotosInApp()
}
