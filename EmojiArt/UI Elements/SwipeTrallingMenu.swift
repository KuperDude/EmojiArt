//
//  SwipeTrallingMenu.swift
//  EmojiArt
//
//  Created by MyBook on 16.04.2022.
//

import SwiftUI

struct SwipeTrallingMenu<Content: View>: View {
    @Environment(\.undoManager) private var undoManager
    var width: CGFloat
    @Binding private var longPressEmoji: EmojiArtModel.Emoji?
    var content: () -> Content
    
    init(width: CGFloat = 50, longPressEmoji: Binding<EmojiArtModel.Emoji?>, content: @escaping () -> Content) {
        self.width = width
        self.content = content
        self._longPressEmoji = longPressEmoji
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                content()
                    .clipped()
                
                MenuLine()
                    .stroke(lineWidth: 3)
                    .foregroundColor(.gray)
                    .padding(.leading, 5)
                    .frame(width: 25, height: geometry.size.height / 5, alignment: .center)
                    .background(Invisible())
                    .gesture(panGesture)
                    
            }
            .cornerRadius(20, corners: [.topLeft, .bottomLeft])
        }
        .offset(panOffSet)
        .offset(CGSize(width: width * 3, height: 0))
        .frame(width: width * 4)
        .transition(swipeTransition)
        .clipped()
    }
    
    private var swipeTransition: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .offset(x: width, y: 0),
            removal: .offset(x: width * 4, y: 0)
        )
    }
    
    @State private var endOffSet: CGSize = .zero
    @GestureState private var gesOffSet: CGSize = .zero
    
    private var panOffSet: CGSize {
        var xOffSet: CGFloat = 0
        if gesOffSet.width + endOffSet.width < -width * 3 {
            xOffSet = -width * 3
        } else {
            xOffSet = gesOffSet.width + endOffSet.width
        }
        return CGSize(width: xOffSet, height: 0)
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesOffSet, body: { lastState, gesOffSet, _ in
                gesOffSet = gesOffSet + lastState.translation
                StorageLastOffSet.lastOffSet = gesOffSet
            })
            .onEnded { _ in
                endOffSet = endOffSet + StorageLastOffSet.lastOffSet
                if endOffSet.width > width / 2 {
                    longPressEmoji = nil
                }
            }
    }
}

private struct StorageLastOffSet {
    static var lastOffSet: CGSize = .zero
}

struct MenuLine: Shape {
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        return p
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
