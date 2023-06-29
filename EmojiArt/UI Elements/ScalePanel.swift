//
//  ScalePanel.swift
//  EmojiArt
//
//  Created by MyBook on 21.04.2022.
//

import SwiftUI

struct ScalePanel: View {
    
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiFontSize) }
    
    var emoji: EmojiArtModel.Emoji
    
    @State var scale: Float = UserDefaults.standard.float(forKey: "ScalePanel.scale") == 0 ? 1 : UserDefaults.standard.float(forKey: "ScalePanel.scale") {
        didSet {
            if scale <= 0 {
                scale = oldValue
            }
//            if (scale * 100) > Float(Int(scale * 100)) {
//                print(scale * 100)
//                print(Float(Int(scale * 100)))
//                scale = String(format: "%.2f", scale).toFloat ?? oldValue
//            }
        }
    }
    
    var completion: (EmojiArtModel.Emoji, CGFloat) -> ()
    
    @FocusState private var focusedField: Bool {
        didSet {
            if focusedField {
                saveScale()
            }
        }
    }
    
    private func saveScale() {
        UserDefaults.standard.set(scale, forKey: "ScalePanel.scale")
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                Image(systemName: "arrow.down.square")
                    .overlay(Invisible().onTapGesture {
                        scale -= 0.1
                    })
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                        TextField("1", value: $scale, format: .number)
                            .keyboardType(.decimalPad)
                            .focused($focusedField)
                            .font(.system(size: emojiFontSize / 2))
                            .multilineTextAlignment(.center)
                            .onChange(of: scale) { newValue in
                                if String(format: "%.2f", newValue).toFloat ?? scale == 0.00 {
                                    scale = 0.1
                                } else {
                                    scale = String(format: "%.2f", newValue).toFloat ?? scale
                                }
                            }
                    }
                    .overlay(Invisible().onTapGesture {
                        focusedField.toggle()
                    })
                    .aspectRatio(1/1, contentMode: .fit)
                Image(systemName: "arrow.up.square")
                    .overlay(Invisible().onTapGesture {
                        scale += 0.1
                    })
            }
//            Button {
//                completion(emoji, CGFloat(scale))
//            } label: {
            Label("Use", systemImage: "dot.circle.and.hand.point.up.left.fill").onTapGesture {
                completion(emoji, CGFloat(scale))
            }
            .font(.system(size: 20))
//            }
//            .font(.system(size: 20))

//            Label("Use", systemImage: "arrow.up.square")
//            Button("Use") {
//                completion(emoji, CGFloat(scale))
//            }
//            .buttonStyle(.automatic)
//            .font(.system(size: 20))
//            .foregroundColor(.white)
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(lineWidth: 3)
//                    .frame(width: emojiFontSize * 2, height: emojiFontSize - 10)
//                Text("Use")
//                    .font(.system(size: 20))
//
//            }
        }
        .font(.system(size: emojiFontSize))
        .onDisappear {
            saveScale()
        }
        .frame(width: emojiFontSize * 3 + 25, height: emojiFontSize * 2 + 25)
        .background(Color(UIColor.systemGray5).onTapGesture {
            focusedField = false
        })
        .cornerRadius(10)
        .overlay {
            if focusedField {
                Invisible().onTapGesture {
                    focusedField = false
                }
            }
        }
    }
}


//struct ScalePanel_Previews: PreviewProvider {
//    static var previews: some View {
//        ScalePanel()
//    }
//}
