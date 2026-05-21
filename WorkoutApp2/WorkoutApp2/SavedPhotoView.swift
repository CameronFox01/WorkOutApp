//
//  SavedPhotoView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/20/26.
//

import SwiftUI

struct SavedPhotosView: View {

    @Environment(\.dismiss) private var dismiss

    let onSelect: (UIImage) -> Void

    @State private var savedPhotoURLs: [URL] = []

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
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Saved Photos")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadSavedPhotos()
            }
        }
    }

    private func loadSavedPhotos() {

        do {

            let directory = try documentsDirectory()

            let files = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil
            )

            savedPhotoURLs = files.filter {
                $0.pathExtension.lowercased() == "jpg"
            }

        } catch {
            print("Failed to load photos: \(error)")
        }
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
