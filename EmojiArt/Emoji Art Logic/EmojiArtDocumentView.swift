//
//  ContentView.swift
//  EmojiArt
//
//  Created by MyBook on 01.03.2022.
//

import SwiftUI
import AudioToolbox
import Popovers

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @EnvironmentObject var store: PaletteStore
    
    @Environment(\.undoManager) var undoManager
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var compact: Bool { horizontalSizeClass == .compact }
    
    @ScaledMetric var defaultEmojiFontSize: CGFloat = 40
    
    @State private var screenshotMaker: ScreenshotMaker?
    
    init(document: EmojiArtDocument) {
        self.document = document
        
        UITableView.appearance().backgroundColor = .clear
    }
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack(alignment: .trailing) {
                    documentBody.zIndex(1)
                    if longPressEmoji != nil {
                        SwipeTrallingMenu(longPressEmoji: $longPressEmoji) {
                            trallingMenu
                        }
                        .frame(height: compact ? 300 : geometry.size.height)
                        .zIndex(2)
                    }
                }
            }
            PaletteChooser(emojiFontSize: defaultEmojiFontSize)
        }
    }
    
    var trallingMenu: some View {
        Form {
            Group {
                
//                Menu {
//                    Button("2") {
//                        document.scaleEmoji(longPressEmoji!, by: 2, undoManager: undoManager)
//                    }
                    
    //                Button {
    //                    document.scaleEmoji(emoji, by: endZoomEmoji * 0.5, undoManager: undoManager)
    //                } label: {
    //                    TextField(String(emoji.size / 40), text: $newScale)
    //                        .textContentType(.creditCardNumber)
    //                        .onSubmit {
    //                            document.scaleEmoji(emoji, by: CGFloat(CGFloat(rawValue: newScale) ?? 1.0), undoManager: undoManager)
    //                        }
    //                }
                    
//                    Button("0.5") {
//                        document.scaleEmoji(longPressEmoji!, by: 0.5, undoManager: undoManager)
//                    }
//                } label: {
//                    Label("Scale", systemImage: "arrow.down.forward.and.arrow.up.backward").lineLimit(1)
//                }
                
                AnimatedActionButton(title: "Scale", systemImage: "arrow.down.forward.and.arrow.up.backward") {
                    selection = "Scale"
                }
                .popover(selection: $selection, tag: "Scale") { popover in
                    popover.position = .absolute(
                        originAnchor: .left,
                        popoverAnchor: .right
                    )
                    popover.presentation.transition = .none
                    popover.presentation.animation = .none
                    popover.dismissal.transition = .none
                } view: {
                    ScalePanel(emojiFontSize: defaultEmojiFontSize, emoji: longPressEmoji!) { emoji, scale in
                        document.scaleEmoji(emoji, by: scale, undoManager: undoManager)
                    }
                }
                .overlay {
                    if selection == "Scale" {
                        Invisible().onTapGesture {
                            selection = nil
                        }
                    }
                }
                
                AnimatedActionButton(title: "Offset", systemImage: "arrow.up.and.down.and.arrow.left.and.right") {
                    selection = "Offset"
                }
                .popover(selection: $selection, tag: "Offset") { popover in
                    popover.position = .absolute(
                        originAnchor: .left,
                        popoverAnchor: .right
                    )
                    popover.presentation.transition = .none
                    popover.presentation.animation = .none
                    popover.dismissal.transition = .none
                } view: {
                    ControlPanel(emojiFontSize: defaultEmojiFontSize, emoji: longPressEmoji!, offSet: $emojiOffSet) { emoji in
                        document.moveEmoji(emoji, by: emojiOffSet, undoManager: undoManager)
                        emojiOffSet = .zero
                    }
                }
                .overlay {
                    if selection == "Offset" {
                        Invisible().onTapGesture {
                            selection = nil
                        }
                    }
                }

                AnimatedActionButton(title: "Stretching", systemImage: "rectangle.dashed") {
                    selection = "Stretching"
                }
                .popover(selection: $selection, tag: "Stretching") { popover in
                    popover.position = .absolute(
                        originAnchor: .left,
                        popoverAnchor: .right
                    )
                    popover.presentation.transition = .none
                    popover.presentation.animation = .none
                    popover.dismissal.transition = .none
                } view: {
                    if let emoji = document.actualEmoji(for: longPressEmoji!) {
                        StretchingPanel(emojiFontSize: defaultEmojiFontSize, emoji: emoji) {
                            direction, value in
                            document.strechingEmoji(longPressEmoji!, to: direction, by: value, undoManager: undoManager)
                        }
                    }
                }
                .overlay {
                    if selection == "Stretching" {
                        Invisible().onTapGesture {
                            selection = nil
                        }
                    }
                }

                AnimatedActionButton(title: "Replace", systemImage: "repeat") {
                    selection = "Replace"
                }
                .popover(selection: $selection, tag: "Replace") { popover in
                    popover.position = .absolute(
                        originAnchor: .left,
                        popoverAnchor: .right
                    )
                    popover.presentation.transition = .none
                    popover.presentation.animation = .none
                    popover.dismissal.transition = .none
                } view: {
                    PaletteReplacer(emojiFontSize: defaultEmojiFontSize) { str in
                        document.replaceEmoji(longPressEmoji!, to: str, undoManager: undoManager)
                    }
                    .environmentObject(store)
                }
                .overlay {
                    if selection == "Replace" {
                        Invisible().onTapGesture {
                            selection = nil
                        }
                    }
                }
                
                Label("Alpha", systemImage: "circle.righthalf.filled")
                Label("Rotation", systemImage: "goforward")
                Label("Background", systemImage: "rectangle.inset.filled")
                Label("Clipped", systemImage: "scissors")

                Menu {
                    Button(role: .destructive) {
                        document.deleteEmoji(longPressEmoji!, undoManager: undoManager)
                    } label: {
                        Text("Delete")
                    }
                } label: {
                    Label {
                        Text("Delete")
                            .foregroundColor(.red)
                    } icon: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    //AnimatedActionButton(title: , systemImage: "trash", imageColor: .red) {}
                }
                .foregroundColor(.red)
            }
            .listRowBackground(Color(UIColor.systemGray4))
            
        }
        .background(Color(UIColor.systemGray4))
    }
    
    @State var selection: String?
    
    @State private var emojiOffSet: CGSize = .zero
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                OptionalImage(uiImage: document.backgroundImage)
                    .scaleEffect(zoomScale)
                    .position(convertFromEmojiCoordinates((0,0), in: geometry))
                    .gesture(doubleTapToZoom(in: geometry.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                        ContentView(content: emoji, longPressEmoji: $longPressEmoji, emojiOffSet: $emojiOffSet, document: _document, with: zoomScale)
                            .position(position(for: emoji, in: geometry))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
            .onChange(of: document.backgroundImageFetchStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundImageFetchFailedAlert(url)
                default: break
                }
            }
            .onReceive(document.$backgroundImage) { image in
                if autozoom {
                    zoomToFit(image, in: geometry.size)
                }
            }
            .compactableToolbar {
                toolBarContent()
            }
            .sheet(item: $backgroundImage, content: { image in
                if let image = image {
                    Share(photo: image)
                }
            })
            .sheet(item: $backgroundPicker) { pickerType in
                switch pickerType {
                case .camera: Camera(handlePickedImage: { image in handlePickedBackgroundImage(image) })
                case .library: PhotoLibrary(handlePickedImage: { image in handlePickedBackgroundImage(image) })
                }
            }
        }
        .screenshotView { screenshotMaker in
            self.screenshotMaker = screenshotMaker
        }
    }
    
    @ViewBuilder
    func toolBarContent() -> some View {
        AnimatedActionButton(title: "Share", systemImage: "square.and.arrow.up") {
            backgroundImage = screenshotMaker?.screenshot()
        }
        AnimatedActionButton(title: "Paste Background", systemImage: "doc.on.clipboard") {
            pasteBackground()
        }
        AnimatedActionButton(title: "Take Photo", systemImage: "camera") {
            if Camera.isAvailable {
                backgroundPicker = .camera
            } else {
                showCameraFailedAlert()
            }
        }
        if PhotoLibrary.isAvailable {
            AnimatedActionButton(title: "Search Photo", systemImage: "photo") {
                backgroundPicker = .library
            }
        }
        if let undoManager = undoManager {
            if undoManager.canUndo {
                AnimatedActionButton(title: undoManager.undoActionName, systemImage: "arrow.uturn.backward") {
                    undoManager.undo()
                }
            }
            if undoManager.canRedo {
                AnimatedActionButton(title: undoManager.redoActionName, systemImage: "arrow.uturn.forward") {
                    undoManager.redo()
                }
            }
        }
    }
    
    @State private var longPressEmoji: EmojiArtModel.Emoji?
    
    @State private var backgroundImage: UIImage?
    
    @State private var backgroundPicker: BackgroundPickerType?
    
    private func handlePickedBackgroundImage(_ image: UIImage?) {
        autozoom = true
        if let imageData = image?.jpegData(compressionQuality: 1.0) {
            document.setBackground(.imageData(imageData), undoManager: undoManager)
        }
        backgroundPicker = nil
    }
    
    enum BackgroundPickerType: String, Identifiable {
        case camera
        case library
        var id: String { rawValue }
    }
    
    private func pasteBackground() {
        autozoom = true
        if let imageData = UIPasteboard.general.image?.jpegData(compressionQuality: 1.0) {
            document.setBackground(.imageData(imageData), undoManager: undoManager)
        } else if let url = UIPasteboard.general.url?.imageURL {
            document.setBackground(.url(url), undoManager: undoManager)
        } else {
            alertToShow = IdentifiableAlert(
                title: "Paste Background",
                message: "There is no image currently on the pasteboard."
            )
        }
    }
    
    @State private var autozoom = false
    
    @State private var alertToShow: IdentifiableAlert?
    
    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "fetch failed: " + url.absoluteString, alert: {
            Alert(
                title: Text("Background Image Fetch"),
                message: Text("Couldn't load image from \(url)."),
                dismissButton: .default(Text("OK"))
            )
        })
    }
    
    private func showCameraFailedAlert() {
        alertToShow = IdentifiableAlert(title: "Camera isn't avalible", message: "To avalible Camera tap Allow in your Settings")
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            autozoom = true
            document.setBackground(.url(url.imageURL), undoManager: undoManager)
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    autozoom = true
                    document.setBackground(.imageData(data), undoManager: undoManager)
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: Int(defaultEmojiFontSize / zoomScale),
                        undoManager: undoManager
                    )
                }
            }
        }
        return found
    }
    
    //MARK: -Positions
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((x: emoji.x, y: emoji.y), in: geometry)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffSet.width - center.x) / zoomScale,
            y: (location.y - panOffSet.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffSet.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffSet.height
        )
    }
    
    //MARK: - Gestures
    @SceneStorage("EmojiArtDocumentView.steadyStatePanOffSet")
    private var steadyStatePanOffSet: CGSize = CGSize.zero
    @GestureState private var gesturePanOffSet: CGSize = CGSize.zero
    
    private var panOffSet: CGSize {
        (steadyStatePanOffSet + gesturePanOffSet) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffSet) { latestDragGestureValue, gesturePanOffSet, _ in
                gesturePanOffSet = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffSet = steadyStatePanOffSet + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    @SceneStorage("EmojiArtDocumentView.steadyStateZoomScale")
    private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
//        if steadyStateZoomScale * gestureZoomScale > EmojiArtDocumentView.maxZoomScale {
//            return EmojiArtDocumentView.maxZoomScale
//        } else if steadyStateZoomScale * gestureZoomScale < EmojiArtDocumentView.minZoomScale {
//            return EmojiArtDocumentView.minZoomScale
//        }
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0 , size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffSet = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
}

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    
    var emoji: EmojiArtModel.Emoji
    var zoomScale: CGFloat
    @ObservedObject var document: EmojiArtDocument
    
    init(content: EmojiArtModel.Emoji, longPressEmoji: Binding<EmojiArtModel.Emoji?>, emojiOffSet: Binding<CGSize>, document: ObservedObject<EmojiArtDocument>, with zoomScale: CGFloat) {
        self.emoji = content
        self.zoomScale = zoomScale
        self._document = document
        self._lpEmoji = longPressEmoji
        self._emojiOffSet = emojiOffSet
    }
    
    var body: some View {
        Image(uiImage: emoji.text.toImage(fontSize(for: emoji)) ?? UIImage())
            .resizable()
            .selectify(isSelect, emoji: emoji, completion: { dir, value in
                switch dir {
                case .left:   document.strechingEmoji(emoji, to: dir, by: emoji.stretching.left + value, undoManager: undoManager)
                case .right:  document.strechingEmoji(emoji, to: dir, by: emoji.stretching.right + value, undoManager: undoManager)
                case .top:    document.strechingEmoji(emoji, to: dir, by: emoji.stretching.top + value, undoManager: undoManager)
                case .bottom: document.strechingEmoji(emoji, to: dir, by: emoji.stretching.bottom + value, undoManager: undoManager)
                }
            })
            .offset(panOffSet)
            .offset(emoji == ContentView.lastlpEmoji ? emojiOffSet : .zero)
            .offset(calculateStrechingOffSet())
            .scaleEffect(zoomEmoji)
            .scaleEffect(longPress ? 0.7 : 1)
            .gesture(select)
            .gesture(isSelect ? pinchEmojiGesture(emoji).simultaneously(with: panEmojiGesture(emoji).simultaneously(with: longPressEmoji())) : nil)
            .frame(width: CGFloat(emoji.size + emoji.stretching.horizontal), height: CGFloat(emoji.size + emoji.stretching.vertical))
        //* 1.2
            .onDisappear {
                isSelect = false
            }
            
//        Text(emoji.text)
//            .font(.system(size: fontSize(for: emoji)))
            
    }
    
    func calculateStrechingOffSet() -> CGSize {
        let width = (-emoji.stretching.left + emoji.stretching.right) / 2
        let height = (-emoji.stretching.top + emoji.stretching.bottom) / 2
        return CGSize(width: width, height: height)
    }
    
    @Binding private var emojiOffSet: CGSize
    @Binding private var lpEmoji: EmojiArtModel.Emoji? {
        didSet {
            if lpEmoji != nil {
                ContentView.lastlpEmoji = lpEmoji!
            }
        }
    }
    
    @State private var isSelect = false {
        didSet {
            if isSelect == false && lpEmoji == emoji {
                withAnimation {
                    lpEmoji = nil
                }
            }
        }
    }
    
    var select: some Gesture {
        TapGesture()
            .onEnded { _ in
                isSelect.toggle()
            }
    }
    
    static private var lastlpEmoji: EmojiArtModel.Emoji?
    
    @GestureState private var longPress = false
    
    func longPressEmoji() -> some Gesture {
        return LongPressGesture(minimumDuration: 1)
            .updating($longPress) { currentState, longPress, transaction in
                AudioServicesPlaySystemSound(SystemSoundID(1519))
                longPress = currentState
                transaction.animation = Animation.easeIn(duration: 0.5)
            }
            .onEnded { _ in
                withAnimation {
                    lpEmoji = emoji
                }
            }
    }
    
    @State private var endZoomEmoji: CGFloat = 1
    @GestureState private var gestureZoomEmoji: CGFloat = 1
    
    private var zoomEmoji: CGFloat {
        endZoomEmoji * gestureZoomEmoji * zoomScale
    }
    
    func pinchEmojiGesture(_ emoji: EmojiArtModel.Emoji) -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomEmoji) { lastScale, gestureZoomEmoji, _ in
                gestureZoomEmoji = lastScale
            }
            .onEnded { gestureZoomEmoji in
                endZoomEmoji *= gestureZoomEmoji
                document.scaleEmoji(emoji, by: endZoomEmoji, undoManager: undoManager)
                endZoomEmoji = 1
            }
    }
    
    @State private var endPanEmoji: CGSize = .zero
    @GestureState private var gesturePanEmoji: CGSize = .zero
    
    var panOffSet: CGSize {
        endPanEmoji + gesturePanEmoji
    }

    func panEmojiGesture(_ emoji: EmojiArtModel.Emoji) -> some Gesture {
        DragGesture()
            .updating($gesturePanEmoji) { lastPosition, gesturePanEmoji, _ in
                gesturePanEmoji = lastPosition.translation / zoomEmoji
            }
            .onEnded { finalPanEmoji in
                endPanEmoji = endPanEmoji + (finalPanEmoji.translation / zoomEmoji)
                document.moveEmoji(emoji, by: endPanEmoji, undoManager: undoManager)
                endPanEmoji = .zero
            }
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
}











struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}

extension String {
    func toImage(_ fontSize: CGFloat) -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: fontSize) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIColor.clear.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image
    }
}

