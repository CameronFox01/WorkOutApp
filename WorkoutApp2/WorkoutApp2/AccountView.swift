//
//  AccountView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

// TODO: This needs to be have a design that is nice to see. This is ugly/boring.
import SwiftUI
import PhotosUI

struct AccountView: View {
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userGender") private var genderRaw: String = Gender.male.rawValue
    
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = true
    
    @AppStorage("profileImageData") private var profileImageData: Data?
    @State private var showingProfilePhotoPicker = false
    @State private var showingProfileCamera = false
    
    private var profileImage: UIImage? {
        guard let data = profileImageData else { return nil }
        return UIImage(data: data)
    }
    
    enum Gender: String, CaseIterable, Identifiable {
        case male = "Male"
        case female = "Female"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            VStack{
                Form {
                    
                    Section(header: Text("Name")) {
                        Text(name)
                    }
                    
                    Section(header: Text("Body Info")){
                        Text(displayHeight)
                        
                        Text(weight + " " + weightUnit)
                        
                    }
                    
                    Section(header: Text("Gender")) {
                        Text(genderRaw)
                    }
                    
                    Section(header: Text("Unit System")){
                        Text(unitSystemRaw)
                    }
                }
                
                PhotosPicker(selection: Binding(get: { nil }, set: { item in
                    guard let item else { return }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            profileImageData = data
                        }
                    }
                }), matching: .images, photoLibrary: .shared()) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .opacity(0.0)
                .accessibilityHidden(true)
                .onChange(of: showingProfilePhotoPicker, initial: false) { old, new in
                    // When toggled true, programmatically trigger the PhotosPicker by reassigning selection via the binding set above.
                }
                
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.blue, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Account")
                            .font(.largeTitle).bold()
                            .foregroundStyle(.white)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        NavigationLink(destination: SettingsView()){
                            Image(systemName: "gear")
                                .font(.title)
                        }
                    }
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading){
                        HStack(spacing: 0) {
                            PhotosPicker(selection: Binding(get: { nil }, set: { item in
                                guard let item else { return }
                                Task {
                                    if let data = try? await item.loadTransferable(type: Data.self) {
                                        profileImageData = data
                                    }
                                }
                            }), matching: .images, photoLibrary: .shared()) {
                                if let uiImage = profileImage {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle")
                                        .font(.title)
                                }
                            }
                            .contextMenu {
                                Button("Take Photo") { showingProfileCamera = true }
                                if profileImageData != nil {
                                    Button(role: .destructive) { profileImageData = nil } label: { Text("Remove Photo") }
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingProfileCamera) {
                    CameraView(image: Binding(get: { profileImage }, set: { newImage in
                        if let img = newImage, let data = img.jpegData(compressionQuality: 0.9) {
                            profileImageData = data
                        }
                    }))
                }
            }
        }
    }
    
    var weightUnit: String {
        unitSystemRaw == UnitSystem.metric.rawValue ? "kg" : "lbs"
    }
    
    var displayHeight: String {
        if unitSystemRaw == "metric" {
            return "\(height) cm"
        } else {
            let totalInches = Int(height) ?? 0
            let feet = totalInches / 12
            let inches = totalInches % 12
            return "\(feet)'\(inches)\""
        }
    }
}

#Preview {
    AccountView()
}
