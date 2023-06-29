//
//  Camera.swift
//  EmojiArt
//
//  Created by MyBook on 04.04.2022.
//

import SwiftUI
import AVFoundation

struct Camera: UIViewControllerRepresentable {
    var handlePickedImage: (UIImage?) -> Void
    
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera) && (AVCaptureDevice.authorizationStatus(for: .video) == .authorized)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(handlePickedImage: handlePickedImage)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // nothing to do
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var handlePickedImage: (UIImage?) -> Void
        
        init(handlePickedImage: @escaping (UIImage?) -> Void) {
            self.handlePickedImage = handlePickedImage
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            handlePickedImage(nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            handlePickedImage((info[.editedImage] ?? info[.originalImage]) as? UIImage)
        }
    }
}
