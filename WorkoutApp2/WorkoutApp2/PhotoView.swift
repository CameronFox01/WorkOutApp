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
            ZStack {
                // Consistent Gradient Background
                LinearGradient(
                    colors: [Color.blue.opacity(1.0), Color.cyan.opacity(0.6), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Comparison Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Comparison")
                                .font(.headline).bold()
                            
                            HStack(spacing: 16) {
                                imagePane(title: "Left", image: leftImage, action: { showingLeftCamera = true })
                                imagePane(title: "Right", image: rightImage, action: { showingRightCamera = true })
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)

                        // 2. Actions Card
                        VStack(spacing: 12) {
                            // LEFT PICKER
                                photoPickerButton(title: "Load Left Photo", selection: $leftSelectedItem)
                                    .onChange(of: leftSelectedItem) { _, newItem in
                                        Task {
                                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                                               let image = UIImage(data: data) {
                                                leftImage = image
                                            }
                                        }
                                    }
                                
                                // RIGHT PICKER
                                photoPickerButton(title: "Load Right Photo", selection: $rightSelectedItem)
                                    .onChange(of: rightSelectedItem) { _, newItem in
                                        Task {
                                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                                               let image = UIImage(data: data) {
                                                rightImage = image
                                            }
                                        }
                                    }
                            
                            Button { showingSavedPhotos = true } label: {
                                Label("Gallery", systemImage: "photo.on.rectangle")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                        
                        Spacer()
                        NavigationLink(destination: ViewPhotosInApp()) {
                            Label("Archive", systemImage: "photo.stack")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                }
            }
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
            .onAppear{
                loadSavedPhotos()
            }
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

    @ViewBuilder
    private func photoPickerButton(title: String, selection: Binding<PhotosPickerItem?>) -> some View {
        PhotosPicker(selection: selection, matching: .images) {
            HStack {
                Image(systemName: "photo")
                Text(title)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
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

    // SINGLE SOURCE OF TRUTH for the display pane
    @ViewBuilder
    private func imagePane(title: String, image: UIImage?, action: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemFill))
                    .frame(height: 250)
                    .overlay(Image(systemName: "plus").foregroundStyle(.secondary))
            }
            
            Button("Camera", action: action)
                .font(.caption.bold())
                .buttonStyle(.bordered)
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
