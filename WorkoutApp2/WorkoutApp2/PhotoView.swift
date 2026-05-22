//
//  PhotoView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct PhotoView: View {
    // Two independent slots for side-by-side comparison
    @State private var leftSelectedItem: PhotosPickerItem?
    @State private var rightSelectedItem: PhotosPickerItem?

    @State private var leftImage: UIImage?
    @State private var rightImage: UIImage?

    @State private var showingLeftCamera: Bool = false
    @State private var showingRightCamera: Bool = false
    
    //Array for saved photos
    @State private var savedPhotoURLs: [URL] = []
    @State private var showingSavedPhotos = false
    @State private var selectedGalleryImage: UIImage?
    @State private var showingSidePicker = false
    
    @AppStorage("SaveToPhotosApp") private var saveToPhoto: Bool = true
    
    @State private var showImageSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Side-by-side image comparison
                HStack(spacing: 12) {
                    imagePane(title: "Left", image: leftImage, takeAction: { showingLeftCamera = true }, pickAction: { /* handled by PhotosPicker below */ })
                        .onChange(of: leftSelectedItem) { _, newItem in
                              guard let newItem else { return }
                              Task {
                                  if let data = try? await newItem.loadTransferable(type: Data.self),
                                     let image = UIImage(data: data) {
                                      leftImage = image
                                  }
                              }
                          }
                    imagePane(title: "Right", image: rightImage, takeAction: { showingRightCamera = true }, pickAction: { /* handled by PhotosPicker below */ })
                        .onChange(of: rightSelectedItem) { _, newItem in
                                guard let newItem else { return }
                                Task {
                                    if let data = try? await newItem.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        rightImage = image
                                    }
                                }
                            }
                }
                .frame(maxHeight: .infinity)
                
                // Pickers row
                VStack(spacing: 12) {
                    photoPicker(title: "Pick Left Photo From Device", selection: $leftSelectedItem)
                    photoPicker(title: "Pick Right Photo From Device", selection: $rightSelectedItem)
                    
                    Button {
                        showingSavedPhotos = true
                    } label: {
                        HStack {
                            Image(systemName: "photo.stack")

                            Text("View Photos Stored on App")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }

                // Camera sheets for each side
                .sheet(isPresented: $showingLeftCamera) {
                    CameraView(image: Binding(get: { leftImage }, set: { newValue in
                        leftImage = newValue
                        if let img = newValue { saveToAppStorage(image: img) }
                    }))
                }
                .sheet(isPresented: $showingRightCamera) {
                    CameraView(image: Binding(get: { rightImage }, set: { newValue in
                        rightImage = newValue
                        if let img = newValue { saveToAppStorage(image: img) }
                    }))
                }
                .sheet(isPresented: $showingSavedPhotos) {
                    SavedPhotosView { image in
                        selectedGalleryImage = image
                        showingSidePicker = true
                    }
                }
                .confirmationDialog(
                    "Use Photo",
                    isPresented: $showingSidePicker,
                    titleVisibility: .visible
                ) {
                    Button("Use for Left") {
                        leftImage = selectedGalleryImage
                    }

                    Button("Use for Right") {
                        rightImage = selectedGalleryImage
                    }

                    Button("Cancel", role: .cancel) { }
                }
            }
            .onAppear{
                loadSavedPhotos()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Compare Photos")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
            .sorted(by: {
                $0.lastPathComponent > $1.lastPathComponent
            })

        } catch {
            print("Failed to load saved photos: \(error)")
        }
    }

    // MARK: - UI Helpers
    @ViewBuilder
    private func imagePane(title: String, image: UIImage?, takeAction: @escaping () -> Void, pickAction: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                    VStack(spacing: 6) {
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                        Text("No Image")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(3/4, contentMode: .fit)
            }

            HStack(spacing: 8) {
                Button(action: takeAction) {
                    Label("Take", systemImage: "camera")
                        .font(.footnote.weight(.semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Capsule())
                }
                // The pick action is handled by the PhotosPicker row below; this button is a convenience to guide users
                // It can be wired to scroll/focus if desired; for now it's disabled visually
                .buttonStyle(.plain)

                // Spacer for symmetry or add more actions here
            }
        }
    }

    // Saves to App Storage and Photo's App on iPhone
    private func saveToAppStorage(image: UIImage) {
        //This saves it but I need to create a way to access those saced photo's.
        // Save JPEG to app's documents directory. This does NOT write to the Photos app.
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        let filename = UUID().uuidString + ".jpg"
        do {
            let url = try documentsDirectory().appendingPathComponent(filename)
            try data.write(to: url)
            // You could store URLs in a model for later reuse if needed
            // print("Saved image to: \(url)")
        } catch {
            // print("Failed to save image: \(error)")
        }
        
        //Saving to Photo's on iPhone
        if saveToPhoto == true {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        
        loadSavedPhotos()
    }

    private func documentsDirectory() throws -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let dir = urls.first else { throw URLError(.fileDoesNotExist) }
        return dir
    }
    
    @ViewBuilder
    func photoPicker(title: String, selection: Binding<PhotosPickerItem?>) -> some View {
        PhotosPicker(selection: selection, matching: .images) {
            Label(title, systemImage: "photo.on.rectangle")
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PhotoView()
}
