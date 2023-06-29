//
//  LoadPhotoViewModel.swift
//  EmojiArt
//
//  Created by MyBook on 09.06.2022.
//

import Foundation
import UIKit
import Combine

class LoadPhotoViewModel: ObservableObject {
    let url: String
    let imageKey: String
    var cancellables = Set<AnyCancellable>()
    
    var cacheManager = PhotoCacheManager.instance

    @Published var uiImage: UIImage?
    
    init(stringURL url: String, key: String) {
        self.url = url
        self.imageKey = key
        getCacheImage(key: imageKey)
        if uiImage == nil {
            getImage()
        }
    }
    
    func getImage() {
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap(LoadDataManager.instance.transformToData)
            .replaceError(with: Data())
            .sink { [weak self] data in
                print("Download Image")
                guard let self = self else { return }
                self.uiImage = UIImage(data: data)
                if let uiImage = self.uiImage {
                    self.cacheManager.addImage(uiImage: uiImage, key: self.imageKey)
                }
            }
            .store(in: &cancellables)
    }
    
    func getCacheImage(key: String) {
        uiImage = cacheManager.getImage(key: key)
        if uiImage != nil {
            print("Get from File Manager")
        }
    }
}
