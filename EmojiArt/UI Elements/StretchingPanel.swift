//
//  StretchingPanel.swift
//  EmojiArt
//
//  Created by MyBook on 15.05.2022.
//

import SwiftUI

struct StretchingPanel: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiFontSize) }
    
    var emoji: EmojiArtModel.Emoji
    
    var completion: (DirectionStretching, Int) -> ()
    
    @FocusState private var focusedFieldBottom: Bool
    @FocusState private var focusedFieldTop: Bool
    @FocusState private var focusedFieldRight: Bool
    @FocusState private var focusedFieldLeft: Bool
    
    init(emojiFontSize: CGFloat, emoji: EmojiArtModel.Emoji, completion: @escaping (DirectionStretching, Int) -> ()) {
        self.emojiFontSize = emojiFontSize
        self.emoji = emoji
        self.completion = completion
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 2)
                .opacity(0.3)
                .frame(width: emojiFontSize * 2 + 25, height: emojiFontSize * 2 + 25)
            VStack(spacing: 5) {
                TextFieldControl(direction: emoji.stretching.top, focusedField: $focusedFieldTop) { value in
                    completion(.top, value)
                }
                HStack(spacing: 5) {
                    TextFieldControl(direction: emoji.stretching.left, focusedField: $focusedFieldLeft) { value in
                        completion(.left, value)
                    }
                    Invisible()
                        .aspectRatio(1/1, contentMode: .fit)
                        .frame(width: emojiFontSize)
                        .onTapGesture {
                            resetFocusedFields()
                        }
                    TextFieldControl(direction: emoji.stretching.right, focusedField: $focusedFieldRight) { value in
                        completion(.right, value)
                    }
                }
                TextFieldControl(direction: emoji.stretching.bottom, focusedField: $focusedFieldBottom) { value in
                    completion(.bottom, value)
                }
            }
            .font(.system(size: emojiFontSize))
        }
        .frame(width: emojiFontSize * 3 + 25, height: emojiFontSize * 3 + 25)
        .onDisappear {
//            saveStep()
//            completion(emoji)
        }
        .background(Color(UIColor.systemGray5).onTapGesture {
            resetFocusedFields()
        })
        .cornerRadius(10)
    }
    
    func resetFocusedFields() {
        focusedFieldTop = false
        focusedFieldBottom = false
        focusedFieldRight = false
        focusedFieldLeft = false
    }
    
    private struct TextFieldControl: View {
        var emojiFontSize: CGFloat = 40
        var emojiFont: Font { .system(size: emojiFontSize) }
        
        init(direction: Int, focusedField: FocusState<Bool>.Binding, completion: @escaping (Int) -> ()) {
            self._direction = State(wrappedValue: direction)
            self.focusedField = focusedField
            self.completion = completion
        }
        
        @State var direction: Int 
        var focusedField: FocusState<Bool>.Binding
        var completion: (Int) -> ()
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.gray)
                TextField("0", value: $direction, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .focused(focusedField)
                    .font(.system(size: emojiFontSize / 2))
                    .multilineTextAlignment(.center)
                    .onChange(of: focusedField.wrappedValue) { newValue in                        
                        if !newValue {
                            completion(direction)
                        }
                    }
                
            }
            .overlay(Invisible().onTapGesture {
                focusedField.wrappedValue.toggle()
            })
            .aspectRatio(1/1, contentMode: .fit)
            .frame(width: emojiFontSize)
        }
    }
    
    enum DirectionStretching {
        case left
        case right
        case top
        case bottom
    }
}

extension Int {
    var positiveOrZero: Int {
        if self > 0 {
            return self
        } else {
            return 0
        }
    }
    
    var negatioveOrZero: Int {
        if self < 0 {
            return self
        } else {
            return 0
        }
    }
}

//struct StretchingPanel_Previews: PreviewProvider {
//    static var previews: some View {
//        StretchingPanel()
//    }
//}
