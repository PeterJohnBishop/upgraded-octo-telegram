//
//  accessMediaView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/14/25.
//

import Foundation
import SwiftUI
import PhotosUI

struct accessMediaView: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Binding var sourceType: SourceType // Changed to Binding
    @Environment(\.presentationMode) var isPresented
    
    func makeUIViewController(context: Context) -> UIViewController {
        switch sourceType {
        case .camera:
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = context.coordinator
            return imagePicker
            
        case .photoLibrary:
            var config = PHPickerConfiguration()
            config.filter = .images
            config.selectionLimit = 1
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

// Enum to specify source type
enum SourceType {
    case camera
    case photoLibrary
}

// Coordinator to handle image selection
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
    var picker: accessMediaView
    
    init(picker: accessMediaView) {
        self.picker = picker
    }
    
    // Handle image selection from UIImagePickerController (Camera)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            self.picker.selectedImages.append(selectedImage)
        }
        self.picker.isPresented.wrappedValue.dismiss()
    }
    
    // Handle cancellation for UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.picker.isPresented.wrappedValue.dismiss()
    }
    
    // Handle image selection from PHPickerViewController
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        self.picker.isPresented.wrappedValue.dismiss()
        
        guard let result = results.first else { return }
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                if let uiImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self?.picker.selectedImages.append(uiImage)
                    }
                }
            }
        }
    }
}
