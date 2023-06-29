//
//  Photo.swift
//  EmojiArt
//
//  Created by MyBook on 09.06.2022.
//

import SwiftUI

struct PhotoView: View {
    @StateObject var photoVM = PhotoViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(photoVM.models) { model in
                    PhotoViewCell(model: model)
                }
            }
            .navigationTitle("Local App")
        }
    }
}

struct LoadAppView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView()
    }
}
