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
    @AppStorage("leftPhotoFileName") private var leftPhotoFileName: String = ""
    @AppStorage("rightPhotoFileName") private var rightPhotoFileName: String = ""
    
    
    @State private var showImageSheet = false
    
    //Color Gradiant
    @EnvironmentObject var gradientSettings: GradientSettings

    var body: some View {
        NavigationStack {
            ZStack {
                // Consistent Gradient Background
                LinearGradient(
                    colors: gradientSettings.selectedPreset.swiftUIColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Comparison Card
                        VStack(alignment: .leading, spacing: 12) {
                          
                            HStack(spacing: 16) {
                                VStack{
                                    Text("Before")
                                        .font(.headline).bold()
                                    imagePane(title: "Left", image: leftImage, action: { showingLeftCamera = true }) {
                                           if !leftPhotoFileName.isEmpty {
                                               let url = documentsDirectory().appendingPathComponent(leftPhotoFileName)
                                               try? FileManager.default.removeItem(at: url)
                                           }
                                           leftImage = nil
                                           leftPhotoFileName = ""
                                           UserDefaults.standard.removeObject(forKey: "leftPhotoFileName")
                                       }
                                }
                                VStack{
                                    Text("After")
                                        .font(.headline).bold()
                                    imagePane(title: "Right", image: rightImage, action: { showingRightCamera = true }) {
                                          if !rightPhotoFileName.isEmpty {
                                              let url = documentsDirectory().appendingPathComponent(rightPhotoFileName)
                                              try? FileManager.default.removeItem(at: url)
                                          }
                                          rightImage = nil
                                          rightPhotoFileName = ""
                                          UserDefaults.standard.removeObject(forKey: "rightPhotoFileName")
                                      }
                                }
                            }
                        }
                        .padding()
                        .cardStyle()
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)

                        // 2. Actions Card
                        VStack(spacing: 12) {
                            // LEFT PICKER
                                photoPickerButton(title: "Choose Before Photo", selection: $leftSelectedItem)
                                    .onChange(of: leftSelectedItem) { _, newItem in
                                        Task {
                                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                                               let image = UIImage(data: data) {
                                                leftImage = image
                                                saveToAppStorage(image: image, side: "left")
                                            }
                                        }
                                    }
                                
                                // RIGHT PICKER
                                photoPickerButton(title: "Choose After Photo", selection: $rightSelectedItem)
                                    .onChange(of: rightSelectedItem) { _, newItem in
                                        Task {
                                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                                               let image = UIImage(data: data) {
                                                rightImage = image
                                                saveToAppStorage(image: image, side: "right")
                                            }
                                        }
                                    }
                            
                            Button { showingSavedPhotos = true } label: {
                                Label("Choose from Saved Photos", systemImage: "photo.on.rectangle")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(gradientSettings.selectedPreset.textColor)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                        .padding()
                        .cardStyle()
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                        
                        Spacer()
                        NavigationLink(destination: ViewPhotosInApp()) {
                            Label("Saved Photos", systemImage: "photo.stack")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(gradientSettings.selectedPreset.textColor)
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showingLeftCamera) {
                CameraView(image: Binding(
                    get: { leftImage },
                    set: { newValue in
                        leftImage = newValue
                        if let img = newValue {
                            saveToAppStorage(image: img, side: "left")
                           // saveGalleryPhoto(image: img)
                        }
                    }
                ))
            }
            .sheet(isPresented: $showingRightCamera) {
                CameraView(image: Binding(
                    get: { rightImage },
                    set: { newValue in
                        rightImage = newValue
                        if let img = newValue {
                            saveToAppStorage(image: img, side: "right")
                          //  saveGalleryPhoto(image: img)
                        }
                    }
                ))
            }
            .sheet(isPresented: $showingSavedPhotos) {
                SavedPhotosView(
                    onSelect: { image in
                            selectedGalleryImage = image
                            showingSidePicker = true
                        },
                        leftImage: leftImage,
                        rightImage: rightImage,
                    leftPhotoFileName: leftPhotoFileName,  
                    rightPhotoFileName: rightPhotoFileName
                )
            }
            .confirmationDialog(
                "Use Photo",
                isPresented: $showingSidePicker,
                titleVisibility: .visible
            ) {
                Button("Use as Before Photo") {
                    if let img = selectedGalleryImage {
                        leftImage = img
                        saveToAppStorage(image: img, side: "left")
                    }
                }

                Button("Use as After Photo") {
                    if let img = selectedGalleryImage {
                        rightImage = img
                        saveToAppStorage(image: img, side: "right")
                    }
                }

                Button("Cancel", role: .cancel) { }
            }
            .onAppear{
                loadSavedPhotos()
                loadPersistentImages()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(gradientSettings.selectedPreset.topColor, for: .navigationBar)
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

    
    private func photoPickerButton(title: String, selection: Binding<PhotosPickerItem?>) -> some View {
        let textColor = gradientSettings.selectedPreset.textColor

        return PhotosPicker(selection: selection, matching: .images) {
            Label(title, systemImage: "photo")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(textColor)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
    
    private func loadPersistentImages() {
        if !leftPhotoFileName.isEmpty {
            let url = documentsDirectory().appendingPathComponent(leftPhotoFileName)
            leftImage = UIImage(contentsOfFile: url.path)
        }

        if !rightPhotoFileName.isEmpty {
            let url = documentsDirectory().appendingPathComponent(rightPhotoFileName)
            rightImage = UIImage(contentsOfFile: url.path)
        }
    }
    
    private func loadSavedPhotos() {
        do {
            let directory = documentsDirectory()

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
    
    private func saveGalleryPhoto(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }

        let filename = "\(UUID().uuidString).jpg"
        let url = documentsDirectory().appendingPathComponent(filename)

        do {
            try data.write(to: url)
        } catch {
            print(error)
        }
    }

    // SINGLE SOURCE OF TRUTH for the display pane
    @ViewBuilder
    private func imagePane(title: String, image: UIImage?, action: @escaping () -> Void, onClear: @escaping () -> Void) -> some View {
        let minWidth: CGFloat = 150
        let maxWidth: CGFloat = AdaptiveFont.isIPad ? 500 : 200
        let imageHeight: CGFloat = AdaptiveFont.isIPad ? 550 : 250
        VStack(spacing: 8) {
            if let uiImage = image {
                ZStack(alignment: .topTrailing) {
                     Image(uiImage: uiImage)
                         .resizable()
                         .scaledToFill()
                         .frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: imageHeight, maxHeight: imageHeight)
                         .clipShape(RoundedRectangle(cornerRadius: 12))

                     // Clear button
                     Button {
                         saveToAppStorage(image: uiImage, side: "")
                         onClear()
                     } label: {
                         Image(systemName: "xmark.circle.fill")
                             .font(.title3)
                             .foregroundStyle(.white)
                             .shadow(radius: 3)
                     }
                     .padding(6)
                 }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemFill))
                    .frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: imageHeight, maxHeight: imageHeight)
                    .overlay(Image(systemName: "plus").foregroundStyle(.secondary))
            }
            
            Button("Camera", action: action)
                .font(.caption.bold())
                .buttonStyle(.bordered)
        }
    }

    // Saves to App Storage and Photo's App on iPhone
    private func saveToAppStorage(image: UIImage, side: String) {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }

        // Generate a unique timestamped filename for the new photo
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "\(side)_photo_\(timestamp).jpg"
        let url = documentsDirectory().appendingPathComponent(filename)

        do {
            try data.write(to: url)

            if side == "left" {
                leftPhotoFileName = filename
            } else {
                rightPhotoFileName = filename
            }
        } catch {
            print("Failed to save image: \(error)")
        }

        if saveToPhoto {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }

        loadSavedPhotos()
    }
    
    private func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
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
        .environmentObject(GradientSettings())
}
