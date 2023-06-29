//
//  PhotoCacheManager.swift
//  EmojiArt
//
//  Created by MyBook on 09.06.2022.
//

import SwiftUI

class PhotoCacheManager {
    static var instance = PhotoCacheManager()
    
    var imageCache: NSCache<NSString, UIImage> = {
        var cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200
        cache.totalCostLimit = 1024 * 1024 * 200 // 200 mb
        return cache
    }()
    
    func getImage(key: String) -> UIImage? {
        imageCache.object(forKey: key as NSString)
    }
    
    func deleteInage(key: String) {
        imageCache.removeObject(forKey: key as NSString)
    }
    
    func addImage(uiImage: UIImage, key: String) {
        imageCache.setObject(uiImage, forKey: key as NSString)
    }

}
