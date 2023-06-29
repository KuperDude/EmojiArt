//
//  ControlPanel.swift
//  EmojiArt
//
//  Created by MyBook on 16.04.2022.
//

import SwiftUI

struct ControlPanel: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiFontSize) }
    
    var emoji: EmojiArtModel.Emoji
    @Binding var offSet: CGSize
    
    @State var step: Int = UserDefaults.standard.integer(forKey: "ControlPanel.step") == 0 ? 1 : UserDefaults.standard.integer(forKey: "ControlPanel.step")
    
    var completion: (EmojiArtModel.Emoji) -> ()
    
    @FocusState private var focusedField: Bool {
        didSet {
            if focusedField {
                saveStep()
            }
        }
    }
    
    private func saveStep() {
        if let step = strStep.toFloat {
            UserDefaults.standard.set(Int(step), forKey: "ControlPanel.step")
            self.step = Int(step)
        }
    }
    //@State private var isPopoverKeyBoard = false
    
//    init(emojiFontSize: CGFloat, emoji: EmojiArtModel.Emoji, offSet: Binding<CGSize>, completion: @escaping (EmojiArtModel.Emoji) -> ()) {
//        self.emojiFontSize = emojiFontSize
//        self.emoji = emoji
//        self._offSet = offSet
//        self.completion = completion
//    }
    
    @State private var strStep = "" {
        didSet {
            if strStep.first == "0" {
                strStep = oldValue
            }
            
            if strStep.count > 3 {
                strStep = oldValue
            }
//            if strStep.contains(",") {
//                let array = strStep.split(separator: ",")
//                if array.count == 2 {
//                    if array[0].count > 2 || array[1].count > 2 {
//                        strStep = oldValue
//                    }
//                    if array[1].count == 2 {
//                        if array[1].last == "0" {
//                            strStep = oldValue
//                        }
//                    }
//                } else if array.count == 1 {
//                    if array[0].count > 2 {
//                        strStep = oldValue
//                    }
//                }
//            } else if strStep.count > 2 {
//                strStep = oldValue
//            }
        }
    }
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "arrow.up.square")
                .overlay(Invisible().onTapGesture {
                    offSet.height -= CGFloat(step)
                })
            HStack(spacing: 5) {
                Image(systemName: "arrow.left.square")
                    .overlay(Invisible().onTapGesture {
                        offSet.width -= CGFloat(step)
                    })
                //WithPopover(showPopover: $isPopoverKeyBoard, popoverSize: CGSize(width: 200, height: 330), arrowDirections: [.up]) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                        TextField("1", value: $step, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .focused($focusedField)
                            .font(.system(size: emojiFontSize / 2))
                            .multilineTextAlignment(.center)
                            .onChange(of: step) { newValue in
                                strStep = String(describing: newValue)
                            }
                        //TextField("1.0", text: $strStep)
                            
                        //Text(String(describing: step))
                            
                    }
                    .overlay(Invisible().onTapGesture {
                        focusedField.toggle()
                    })
                    .aspectRatio(1/1, contentMode: .fit)
//                } popoverContent: {
//                    PopoverKeyBoard(isPresent: $isPopoverKeyBoard, emojiFontSize: emojiFontSize, step: $step)
//                }
                Image(systemName: "arrow.right.square")
                    .overlay(Invisible().onTapGesture {
                        offSet.width += CGFloat(step)
                    })
            }
            Image(systemName: "arrow.down.square")
                .overlay(Invisible().onTapGesture {
                    offSet.height += CGFloat(step)
                })
        }
        .font(.system(size: emojiFontSize))
        .onDisappear {
            saveStep()
            completion(emoji)
        }
        .frame(width: emojiFontSize * 3 + 25, height: emojiFontSize * 3 + 25)
        .background(Color(UIColor.systemGray5).onTapGesture {
            focusedField = false
        })
        .cornerRadius(10)
    }
}

//struct PopoverKeyBoard: View {
//    var emojiFontSize: CGFloat = 40
//    var emojiFont: Font { .system(size: emojiFontSize) }
//    @State private var commaAlreadyExist: Bool = true
//
//    @Binding var isPresent: Bool
//
//    @Binding var step: Float
//
//    @State private var strStep = "" {
//        didSet {
//            if strStep.first == "0" {
//                strStep = oldValue
//            }
//            if strStep.contains(",") {
//                let array = strStep.split(separator: ",")
//                if array.count == 2 {
//                    if array[0].count > 2 || array[1].count > 2 {
//                        strStep = oldValue
//                    }
//                    if array[1].count == 2 {
//                        if array[1].last == "0" {
//                            strStep = oldValue
//                        }
//                    }
//                } else if array.count == 1 {
//                    if array[0].count > 2 {
//                        strStep = oldValue
//                    }
//                }
//            } else if strStep.count > 2 {
//                strStep = oldValue
//            }
//
//            if let step = strStep.toFloat {
//                self.step = step
//                UserDefaults.standard.set(step, forKey: "ControlPanel.stepHeight")
//            }
//        }
//    }
//
//    init(isPresent: Binding<Bool>, emojiFontSize: CGFloat, step: Binding<Float>) {
//        self.emojiFontSize = emojiFontSize
//        self._step = step
//        self._isPresent = isPresent
//        self._strStep = State(initialValue: String(describing: step.wrappedValue).replacingOccurrences(of: ".", with: ","))
//    }
//
//    func roundDown(_ value: Float, toNearest: Float) -> Float {
//        return floor(value / toNearest) * toNearest
//    }
//
//    var body: some View {
//        VStack(spacing: 3) {
//            HStack(spacing: 4.5) {
//                Text(strStep)
//                    .keyItem(2/1, color: .blue)
//                Image(systemName: "delete.left.fill")
//                    .keyItem(color: .red) {
//                        if !strStep.isEmpty {
//                            let ch = strStep.removeLast()
//                            if ch == "," {
//                                commaAlreadyExist = false
//                            }
//                        }
//                    }
//            }
//            HStack(spacing: 3) {
//                Text("1")
//                    .keyItem {
//                        strStep += "1"
//                    }
//                Text("2")
//                    .keyItem {
//                        strStep += "2"
//                    }
//                Text("3")
//                    .keyItem {
//                        strStep += "3"
//                    }
//            }
//            HStack(spacing: 3) {
//                Text("4")
//                    .keyItem {
//                        strStep += "4"
//                    }
//                Text("5")
//                    .keyItem {
//                        strStep += "5"
//                    }
//                Text("6")
//                    .keyItem {
//                        strStep += "6"
//                    }
//            }
//            HStack(spacing: 3) {
//                Text("7")
//                    .keyItem {
//                        strStep += "7"
//                    }
//                Text("8")
//                    .keyItem {
//                        strStep += "8"
//                    }
//                Text("9")
//                    .keyItem {
//                        strStep += "9"
//                    }
//            }
//            HStack(spacing: 3) {
//                Text(",")
//                    .keyItem {
//                        if !commaAlreadyExist {
//                            if !commaAlreadyExist {
//                                strStep += ","
//                                commaAlreadyExist = true
//                            }
//                        }
//                    }
//                Text("0")
//                    .keyItem {
//                        strStep += "0"
//                    }
//                Image(systemName: "checkmark")
//                    .keyItem(color: .green) {
//                        isPresent = false
//                    }
//            }
//        }
//        .font(emojiFont)
//    }
//}
//
//struct KeyItem: ViewModifier {
//    var aspect: CGFloat
//    var color: Color
//    var action: (()->())?
//    func body(content: Content) -> some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 10)
//                .shadow(color: .black, radius: 10, x: 0, y: 1)
//                .foregroundColor(color)
//                .aspectRatio(aspect, contentMode: .fit)
//                .frame(height: 60)
//            content
//        }
//        .onTapGesture {
//            if action != nil {
//                action!()
//            }
//        }
//    }
//}
//
//extension View {
//    func keyItem(_ aspect: CGFloat = 1/1, color: Color = .gray, _ action: (()->())? = nil) -> some View {
//        self.modifier(KeyItem(aspect: aspect, color: color, action: action))
//    }
//}

//struct ControlPanel_Previews: PreviewProvider {
//    static var previews: some View {
//        ControlPanel()
//    }
//}
