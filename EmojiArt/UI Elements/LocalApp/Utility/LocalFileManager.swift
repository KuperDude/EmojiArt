//
//  LocalFileManager.swift
//  EmojiArt
//
//  Created by MyBook on 09.06.2022.
//

import Foundation
import UIKit

class LocalFileManager {
    static var instance = LocalFileManager()
    let directoryName = "User_images"
    private init() {
        createDirectoryIfNeed()
    }
    
    func getImage(key: String) -> UIImage? {
        guard let path = pathToFile(name: key)?.path else { return nil }
        return UIImage(contentsOfFile: path)
    }
    
    func deleteInage(key: String) {
        guard let path = pathToFile(name: key) else { return }
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addImage(uiImage: UIImage, key: String) {
        guard let path = pathToFile(name: key) else { return }
        do {
            let data = uiImage.jpegData(compressionQuality: 1.0)
            try data?.write(to: path)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func pathToDirectory() -> URL? {
        if let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(directoryName) {
            return url
        }
        return nil
    }
    
    func pathToFile(name: String) -> URL? {
        if let url = pathToDirectory()?
            .appendingPathComponent(name)
            {
            return url
        }
        return nil
    }
    
    func createDirectoryIfNeed() {
        guard let url = pathToDirectory() else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            return
        } else {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                return
            }
        }
    }
}
