//
//  PaletteReplace.swift
//  EmojiArt
//
//  Created by MyBook on 16.04.2022.
//

import SwiftUI
import Popovers

struct PaletteReplacer: View {
    
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiFontSize) }
    @State private var show = false
    @EnvironmentObject var store: PaletteStore
    @State var showMenu = false
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var compact: Bool { horizontalSizeClass == .compact }
    
    var completion: (String) -> ()
    
    //@SceneStorage("PaletteReplacer.choosenPaletteIndex")
    @State private var choosenPaletteIndex = UserDefaults.standard.integer(forKey: "PaletteReplacer.choosenPaletteIndex")
    
    var body: some View {
        let palette = store.palette(at: min(store.palettes.count - 1, choosenPaletteIndex))
        VStack {
            body(for: $store.palettes[palette])
            gotoMenu
        }
        .clipped()
        .frame(width: emojiFontSize * 3 + 50, height: calculateHeight(for: palette))
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
        //updating block
        .popover(present: $show) {
            EmptyView()
        }
    }
    
    var gotoMenu: some View {
        Templates.Menu(present: $showMenu) { config in
            config.popoverAnchor = .bottom
            config.width = emojiFontSize * 3 + 100
        } content: {
            VStack {
                ForEach(store.palettes) { palette in
                    Templates.MenuItem {
                        //
                    } label: { _ in
                        Text(palette.name)
                            .font(.system(size: 20))
                            .padding(5)
                            .onTapGesture {
                                if let index = store.palettes.index(matching: palette) {
                                    UserDefaults.standard.set(index, forKey: "PaletteReplacer.choosenPaletteIndex")
                                    choosenPaletteIndex = index
                                    //updating block
                                    show = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        show = false
                                    }
                                }
                            }
                    }
                }
            }
        } label: { fade in
            Label("Go To", systemImage: "text.insert")
                .font(.system(size: 20))
                .frame(width: emojiFontSize * 3 + 50)
                .padding(.bottom, 10)
        }
    }
    
    func calculateHeight(for palette: Palette) -> CGFloat {
        let elementsInColumn = palette.emojis.count % 3 == 0 ? CGFloat(palette.emojis.count / 3) : CGFloat(palette.emojis.count / 3 + 1)
        if compact && UIScreen.screenHeight - 100 < elementsInColumn * (emojiFontSize + 5) + 100 {
            return UIScreen.screenHeight - 100
        } else if !compact && UIScreen.screenWidth - 100 < elementsInColumn * (emojiFontSize + 5) + 100 {
            return UIScreen.screenWidth - 100
        }
        return elementsInColumn * (emojiFontSize + 5) + 100
    }

    func body(for palette: Binding<Palette>) -> some View {
        VStack {
            Text(palette.wrappedValue.name)
                .font(.headline)
                .lineLimit(1)
                .padding(.top, 10)
            ScrollingEmojisView(emojiFontSize: emojiFontSize, emojis: palette.emojis, completion: completion)
                .font(emojiFont)
        }
    }
}

private struct ScrollingEmojisView: View {

    var emojiFontSize: CGFloat = 40
    
    @EnvironmentObject var store: PaletteStore
    @Binding var emojis: String
    
    var completion: (String) -> ()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.fixed(emojiFontSize + 5)), GridItem(.fixed(emojiFontSize + 5)), GridItem(.fixed(emojiFontSize + 5))]) {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Button(emoji) {
                        completion(emoji)
                    }
                }
            }
        }
    }
}
