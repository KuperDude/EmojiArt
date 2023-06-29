//
//  LPRectangle+Modentifier.swift
//  EmojiArt
//
//  Created by MyBook on 17.05.2022.
//

import SwiftUI

struct LDRectangleModentifier: ViewModifier {
    let isSelect: Bool
    let emoji: EmojiArtModel.Emoji
    let completion: (StretchingSquares.DirectionStretching, Int) -> ()
    @State private var refresh = false
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            if isSelect {
                ZStack {
                    Group {
                        content
                        LDRectangle(refresh: refresh)
                    }
                    .padding(min(geometry.size.width, geometry.size.height) / 10 / 2)
                    StretchingSquares(geometry: geometry, emoji: emoji, completion: completion)
                }
                .onReceive(NotificationCenter.default.publisher(for: .DocumentDidUpdateContentFrame)) { _ in
                    refresh.toggle()
                }
            } else {
                content
                    .padding(min(geometry.size.width, geometry.size.height) / 10 / 2)
            }
        }
    }
}

extension View {
    func selectify(_ isSelect: Bool, emoji: EmojiArtModel.Emoji, completion: @escaping (StretchingSquares.DirectionStretching, Int) -> ()) -> some View {
        self.modifier(LDRectangleModentifier(isSelect: isSelect, emoji: emoji, completion: completion))
    }
}

struct LDRectangle: UIViewRepresentable {
    @State var refresh = false
    
    func makeUIView(context: Context) -> UIView {
        let view = DottedView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.setNeedsDisplay()
    }
    
    class DottedView: UIView {
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
            path.move(to: rect.origin)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: rect.origin)

            let countDottedInLine: CGFloat = 10
            let dash: CGFloat = (min(rect.height, rect.width) / 2) / countDottedInLine
            let height: CGFloat = (min(rect.height, rect.width) / 2) / countDottedInLine
            let dashes: [CGFloat] = [height, dash]
            path.setLineDash(dashes, count: dashes.count, phase: 0)

            path.lineWidth = min(rect.height, rect.width) / 20
            UIColor.blue.set()
            path.stroke()
        }
    }
}

extension Notification.Name {
    static var DocumentDidUpdateContentFrame = Notification.Name(rawValue: "DocumentDidUpdateContentFrame")
}

struct StretchingSquares: View {
    typealias DirectionStretching = StretchingPanel.DirectionStretching
    
    let geometry: GeometryProxy
    @State var emoji: EmojiArtModel.Emoji
    let completion: (DirectionStretching, Int) -> ()
    var body: some View {
        VStack {
            HStack {
                Square(directions: [.left, .top], geometry: geometry, emoji: emoji, completion: completion)
                Spacer()
                Square(directions: [.top], geometry: geometry, emoji: emoji, completion: completion)
                Spacer()
                Square(directions: [.right, .top], geometry: geometry, emoji: emoji, completion: completion)
            }
            Spacer()
            HStack {
                Square(directions: [.left], geometry: geometry, emoji: emoji, completion: completion)
                Spacer()
                Square(directions: [.right], geometry: geometry, emoji: emoji, completion: completion)
            }
            Spacer()
            HStack {
                Square(directions: [.left, .bottom], geometry: geometry, emoji: emoji, completion: completion)
                Spacer()
                Square(directions: [.bottom], geometry: geometry, emoji: emoji, completion: completion)
                Spacer()
                Square(directions: [.right, .bottom], geometry: geometry, emoji: emoji, completion: completion)
            }
        }
    }
    
    struct Square: View {
        let directions: [DirectionStretching]
        let geometry: GeometryProxy
        @State var emoji: EmojiArtModel.Emoji
        let completion: (DirectionStretching, Int) -> ()
        
        var body: some View {
            Rectangle()
                .foregroundColor(Color(.blue))
                .aspectRatio(1/1, contentMode: .fit)
                .frame(width: min(geometry.size.width, geometry.size.height) / 10)
                .gesture(panGesture)
                
        }
        
        @GestureState private var gesOffSet: CGSize = .zero
        
        private var panGesture: some Gesture {
            DragGesture()
                .updating($gesOffSet, body: { lastState, gesOffSet, _ in
                    //stretchingEmoji(in: lastState.translation, for: geometry.size, content: &emoji)
                    gesOffSet = gesOffSet + lastState.translation
                })
                .onEnded { lastState in
                    for dir in directions {
                        switch dir {
                        case .left:   completion(dir, -Int(lastState.translation.width))
                        case .right:  completion(dir, Int(lastState.translation.width))
                        case .top:    completion(dir, -Int(lastState.translation.height))
                        case .bottom: completion(dir, Int(lastState.translation.height))
                        }
                    }
                }
        }
        
        private func stretchingEmoji(in size: CGSize, for contentSize: CGSize, content: inout EmojiArtModel.Emoji) {
            for dir in directions {
                switch dir {
                case .left: content.stretching.left = Int(size.width > contentSize.width ? 0 : size.width)
                case .right: content.stretching.right = Int(size.width < -contentSize.width ? 0 : size.width)
                case .top: content.stretching.top = Int(size.height > contentSize.height ? 0 : size.height)
                case .bottom: content.stretching.bottom = Int(size.height < -contentSize.height ? 0 : size.height)
                }
            }
        }
        
    }
}
