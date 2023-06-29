//
//  LoadPhotoView.swift
//  EmojiArt
//
//  Created by MyBook on 09.06.2022.
//

import SwiftUI

struct LoadPhotoView: View {
    @StateObject var vm: LoadPhotoViewModel
    
    init(url: String, key: String) {
        _vm = StateObject(wrappedValue: LoadPhotoViewModel(stringURL: url, key: key))
    }
    var body: some View {
        if vm.uiImage == nil {
            ProgressView()
        } else if let uiImage = vm.uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        }
    }
}

struct LoadPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        LoadPhotoView(url: "https://via.placeholder.com/600/92c952", key: "1")
    }
}
