//
//  Share.swift
//  EmojiArt
//
//  Created by MyBook on 10.04.2022.
//

import SwiftUI

struct Share: UIViewControllerRepresentable {
    let photo: UIImage
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityItems: [Any] = [photo]
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
    
}
