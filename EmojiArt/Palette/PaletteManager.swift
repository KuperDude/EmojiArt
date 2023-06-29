//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by MyBook on 16.03.2022.
//

import SwiftUI

struct PaletteManager: View {
    @EnvironmentObject var store: PaletteStore

    @Environment(\.presentationMode) var presentationMode
    
    @State private var editMode: EditMode = .inactive
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete { indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, newOffSet in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffSet)
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .dismissable { presentationMode.wrappedValue.dismiss() }
            .toolbar {
                ToolbarItem { EditButton() }
            }
            .environment(\.editMode, $editMode)
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .environmentObject(PaletteStore(named: "Preview"))
            .preferredColorScheme(.dark)
    }
}
