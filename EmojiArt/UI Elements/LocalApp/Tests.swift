//
//  Tests.swift
//  EmojiArt
//
//  Created by MyBook on 19.05.2022.
//

import SwiftUI
import Combine

class CacheManager {
    static var instance = CacheManager()
    
    var imageCache: NSCache<NSString, UIImage> = {
        var cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 mb
        return cache
    }()
    
    func getImage(id: String) -> UIImage? {
        imageCache.object(forKey: id as NSString)
    }
    
    func deleteInage(id: String) {
        imageCache.removeObject(forKey: id as NSString)
    }
    
    func addImage(uiImage: UIImage, id: String) {
        imageCache.setObject(uiImage, forKey: id as NSString)
    }
}


class CacheManagerViewModel: ObservableObject {
    let manager = CacheManager.instance
    
    let name = "image2"
    @Published var uiImage: UIImage?
    
    init() {
        getImage()
    }
    
    func getImage() {
        uiImage = manager.getImage(id: name)
    }
    
    func deleteImage() {
        manager.deleteInage(id: name)
    }
    
    func addImage() {
        if let uiImage = UIImage(named: name) {
            manager.addImage(uiImage: uiImage, id: name)
        }
    }
    
}

struct Tests: View {
    
    @StateObject var vm = CacheManagerViewModel()
    
    var body: some View {
        VStack {
            if let uiImage = vm.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
            }
            Button("save") {
                vm.addImage()
            }
            .padding()
            .padding(.horizontal)
            .background(.green)
            Button("get") {
                vm.getImage()
            }
            .padding()
            .padding(.horizontal)
            .background(.yellow)
            Button("delete") {
                vm.deleteImage()
            }
            .padding()
            .padding(.horizontal)
            .background(.red)
            
        }
    }
}

struct Tests_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Tests()
                .preferredColorScheme(.light)
                .previewInterfaceOrientation(.portrait)
        }
    }
}

