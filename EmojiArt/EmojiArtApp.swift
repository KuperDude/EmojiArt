//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by MyBook on 01.03.2022.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var paletteStore = PaletteStore(named: "Default")
    
    var body: some Scene {
//        WindowGroup {
//            PhotoView()
//        }
        DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
            EmojiArtDocumentView(document: config.document).environmentObject(paletteStore)
        }
    }
}
