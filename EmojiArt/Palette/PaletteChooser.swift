//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by MyBook on 16.03.2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct PaletteChooser: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiFontSize) }
    
    @EnvironmentObject var store: PaletteStore
    
    @SceneStorage("PaletteChooser.choosenPaletteIndex")
    private var choosenPaletteIndex = 0
    
    var body: some View {
        let palette = store.palette(at: choosenPaletteIndex)
        HStack {
            paletteControlButton
            body(for: $store.palettes[palette])
        }
        .clipped()
        .background(Color(UIColor.systemGray4))
    }
    
    var paletteControlButton: some View {
        Button {
            withAnimation {
                choosenPaletteIndex = (choosenPaletteIndex + 1) % store.palettes.count
            }
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu { contextMenu }
    }

    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
            paletteToEdit = store.palette(at: choosenPaletteIndex)
        }
        AnimatedActionButton(title: "New", systemImage: "plus") {
            store.insertPalette(named: "New", emojis: "", at: choosenPaletteIndex)
            paletteToEdit = store.palette(at: choosenPaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            choosenPaletteIndex = store.removePalette(at: choosenPaletteIndex)
        }
        AnimatedActionButton(title: "Manager", systemImage: "slider.vertical.3") {
            managing = true
        }
        gotoMenu
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach(store.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.palettes.index(matching: palette) {
                        choosenPaletteIndex = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }
    }

    func body(for palette: Binding<Palette>) -> some View {
        HStack {
            Text(palette.wrappedValue.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(rollTransition)
        .popover(item: $paletteToEdit) { palette in
            PaletteEditor(palette: $store.palettes[palette])
                .wrappedInNavigationViewToMakeDismissable { paletteToEdit = nil }
        }
        .sheet(isPresented: $managing) {
            PaletteManager()
        }
    }
    
    @State private var managing = false
    @State private var paletteToEdit: Palette?
    
    var rollTransition: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .offset(x: 0, y: emojiFontSize),
            removal: .offset(x: 0, y: -emojiFontSize)
        )
    }
}

private struct ScrollingEmojisView: View {
    @EnvironmentObject var store: PaletteStore
    
    @Binding var emojis: String

    @State var draggedItem : String?
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        //.onDrag { NSItemProvider(object: emoji as NSString) }
                        .onDrag({
                            self.draggedItem = emoji
                            return NSItemProvider(object: emoji as NSString)
                        })
                        .onDrop(of: [UTType.text], delegate: MyDropDelegate(item: emoji, items: $emojis.toArray, draggedItem: $draggedItem))
                }
            }
        }
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
    }
}
