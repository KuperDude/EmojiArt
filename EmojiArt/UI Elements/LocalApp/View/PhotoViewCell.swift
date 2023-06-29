//
//  PhotoViewCell.swift
//  EmojiArt
//
//  Created by MyBook on 09.06.2022.
//

import SwiftUI

struct PhotoViewCell: View {
    
    var model: PhotoModel
    
    var body: some View {
        HStack {
            LoadPhotoView(url: model.url, key: "\(model.id)")
                .frame(width: 75, height: 75)
            Spacer()
            VStack {
                Text(model.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(model.url)
                    .font(.body)
                    .italic()
            }
        }
        .padding()
    }
}

struct PhotoViewCell_Previews: PreviewProvider {
    static var previews: some View {
        PhotoViewCell(model: PhotoModel(albumId: 2, id: 3, title: "Title", url: "https://via.placeholder.com/600/92c952", thumbnailUrl: "xmzm"))
            .previewLayout(.sizeThatFits)
    }
}
