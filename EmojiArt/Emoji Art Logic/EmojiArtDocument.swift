//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by MyBook on 01.03.2022.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

extension UTType {
    static let emojiart = UTType(exportedAs: "emojiart.test")
}

class EmojiArtDocument: ReferenceFileDocument {
    
    static var readableContentTypes = [UTType.emojiart]
    static var writeableContentTypes = [UTType.emojiart]
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArtModel(json: data)
            fetchBackgroundImageDataIfNecessary()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }

    init() {
        emojiArt = EmojiArtModel()
    }
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    
    private var backgroundImageFetchCancellable: AnyCancellable?
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            backgroundImageFetchCancellable?.cancel()
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map { (data, urlSession) in UIImage(data: data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
            
            backgroundImageFetchCancellable = publisher
                .sink { [weak self] image in
                    self?.backgroundImage = image
                    self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
                }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    func actualEmoji(for emoji: EmojiArtModel.Emoji) -> EmojiArtModel.Emoji? {
        if let index = emojiArt.emojis.index(matching: emoji) {
            return emojiArt.emojis[index]
        }
        return nil
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background, undoManager: UndoManager?) {
        undoablyPerform(operation: "Set Background", with: undoManager) {
            emojiArt.background = background
        }
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: Int, undoManager: UndoManager?) {
        undoablyPerform(operation: "Add \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: location, size: size)
        }
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize, undoManager: UndoManager?) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Move \(emoji.text)", with: undoManager) {
                emojiArt.emojis[index].x += Int(offset.width)
                emojiArt.emojis[index].y += Int(offset.height)
            }
        }
    }
    
    func strechingEmoji(_ emoji: EmojiArtModel.Emoji, to direction: StretchingPanel.DirectionStretching, by value: Int, undoManager: UndoManager?) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Streching \(emoji.text)", with: undoManager) {
                switch direction {
                case .left:   emojiArt.emojis[index].stretching.left   = value
                case .right:  emojiArt.emojis[index].stretching.right  = value
                case .bottom: emojiArt.emojis[index].stretching.bottom = value
                case .top:    emojiArt.emojis[index].stretching.top    = value
                }
                NotificationCenter.default.post(name: .DocumentDidUpdateContentFrame, object: nil)
            }
        }
    }

    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat, undoManager: UndoManager?) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Scale \(emoji.text)", with: undoManager) {
                emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero)) > 1024 ? 1024 :    Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
                NotificationCenter.default.post(name: .DocumentDidUpdateContentFrame, object: nil)
            }
        }
    }
    
    func deleteEmoji(_ emoji: EmojiArtModel.Emoji, undoManager: UndoManager?) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Delete \(emoji.text)", with: undoManager) {
                emojiArt.emojis.remove(at: index)
            }
        }
    }
    
    func replaceEmoji(_ emoji: EmojiArtModel.Emoji, to text: String, undoManager: UndoManager?) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Replace \(emoji.text)", with: undoManager) {
                emojiArt.emojis[index].text = text
            }
        }
    }
    
    // MARK: -Undo
    private func undoablyPerform(operation: String, with undoManager: UndoManager? = nil, doit: ()->Void) {
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(operation: operation, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(operation)
    }
}
