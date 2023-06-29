//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by MyBook on 01.03.2022.
//

import Foundation

struct EmojiArtModel: Codable {
    var background = Background.blank
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Hashable, Codable {
        var text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
        var size: Int
        var stretching: Stretching
        var id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
            self.stretching = Stretching()
        }
        
        static func == (_ first: Emoji, _ second: Emoji) -> Bool {
            first.id == second.id
        }
        
        struct Stretching: Hashable, Codable {
            var left = 0
            var right = 0
            var top = 0
            var bottom = 0
            
            var horizontal: Int {
                left + right
            }
            var vertical: Int {
                top + bottom
            }
        }
    }
    
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try EmojiArtModel(json: data)
    }
    
    init() {}
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
}
