//
//  CameraView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 3/20/26.
//

import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var image : UIImage? //bind to the parent view state
    @Environment (\.presentationMode) var presentationMode //Dismiss the view when done
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController() //Create the Camera Picker
        picker.delegate = context.coordinator //Set the coordinator as delayed
        picker.sourceType = .camera //Set the source for the camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        //No Updates needed under here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image //Pass the select image to the parent
            }
            parent.presentationMode.wrappedValue.dismiss() //dismiss the picker
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss() //dismiss on cancel
        }
    }
}
