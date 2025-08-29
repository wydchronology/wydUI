import SwiftUI

/// Implementation of ParallaxPager using a ZStack with a custom gesture recognizer
struct ZPager<Content: View, Backdrop: View>: ParallaxPager {
    @Environment(\.scenePhase) private var scenePhase
    
    var page: Binding<Int>
    
    var disabled: Bool = true
    
    var overlapMultiplier: CGFloat = 5
    
    @ViewBuilder
    let content: () -> Content
    
    @ViewBuilder
    let backdrop: () -> Backdrop
    
    @State
    private var translation: CGFloat = 0
    
    @State
    private var gestureDirection: Int = 0
    
    public var body: some View {
        Group(subviews: content()) { views in
            GeometryReader { geometry in
                ZStack {
                    ForEach(0 ..< views.count, id: \.self) { index in
                        let dragActivation: some Gesture = LongPressGesture(minimumDuration: 0)
                        
                        let dragGesture: some Gesture = DragGesture(minimumDistance: 20)
                            .onChanged { value in
                                // dont respond to vertical swipes
                                let verticalSwipeDistance = abs(
                                    value.location.y - value.startLocation.y
                                )
                                let horizontalSwipeDistance = abs(
                                    value.location.x - value.startLocation.x
                                )
                                if verticalSwipeDistance > horizontalSwipeDistance {
                                    return
                                }
                                
                                translation = getNextState(
                                    value,
                                    index: index,
                                    count: views.count
                                )
                            }
                            .onEnded { value in
                                translation = 0
                                
                                if index == page.wrappedValue {
                                    page.wrappedValue = getNextIndex(
                                        value,
                                        count: views.count,
                                        frameSize: geometry.size
                                    )
                                }
                            }
                        
                        views[index]
                            .clipShape(
                                LeadingCornersContainerRelativeShape()
                            )
                            .animation(.smooth(duration: 0.25), value: page.wrappedValue)
                            .offset(x: getOffsetForView(at: index, using: geometry.size))
                            .offset(x: getTranslationOffset(at: index, using: geometry.size))
                            .animation(.interactiveSpring(), value: translation)
                            .overlay(
                                backdrop()
                                    .opacity(
                                        getOverlayOpacity(
                                            at: index,
                                            using: geometry.size,
                                            minOpacity: 0.5
                                        )
                                    )
                            )
                            .animation(
                                .snappy(duration: 0.25),
                                value: getOverlayOpacity(
                                    at: index,
                                    using: geometry.size,
                                    minOpacity: 0.5
                                )
                            )
                            .gesture(
                                dragGesture.sequenced(before: dragActivation),
                                name: "pagerGesture",
                                isEnabled: !disabled
                            )
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .task(id: scenePhase) {
                    if scenePhase != .active {
                        translation = 0
                        gestureDirection = 0
                    }
                }
            }
        }
    }
    
    func getNextState(
        _ value: DragGesture.Value,
        index: Int,
        count: Int
    ) -> CGFloat {
        gestureDirection = Int(
            value.location.x - value.startLocation.x
        )
        
        if index == 0, gestureDirection > 0 {
            /// block attempts to swipe right from first page
            return value.translation.width / .infinity
        } else if index == count - 1, gestureDirection < 0 {
            /// block attempts to swipe right from last page
            return value.translation.width / .infinity
        } else {
            return value.translation.width
        }
    }
    
    func getNextIndex(
        _ value: DragGesture.Value,
        count: Int,
        frameSize: CGSize
    ) -> Int {
        let offset = value.translation.width / frameSize.width
        let newIndex = Int((CGFloat(page.wrappedValue) - offset).rounded())
        return min(max(newIndex, 0), count - 1)
    }
    
    func getOffsetForView(at index: Int, using size: CGSize) -> CGFloat {
        let page = page.wrappedValue
        if index > page {
            return -CGFloat(page - index) * size.width
        } else {
            return -CGFloat(page - index) * size.width / overlapMultiplier
        }
    }
    
    func isSwipingRight(index: Int) -> Bool {
        gestureDirection > 0 && index < page.wrappedValue
    }
    
    func isSwipingLeft(index: Int) -> Bool {
        gestureDirection < 0 && index == page.wrappedValue
    }
    
    func translationRatio(using size: CGSize) -> CGFloat {
        translation / size.width
    }
    
    func overlapRatio(using size: CGSize) -> CGFloat {
        size.width / overlapMultiplier
    }
    
    func getTranslationOffset(at index: Int, using size: CGSize) -> CGFloat {
        if isSwipingRight(index: index) || isSwipingLeft(index: index) {
            translationRatio(using: size) * overlapRatio(using: size)
        } else {
            translation
        }
    }
    
    func getViewOpacity(
        at index: Int,
        using size: CGSize,
        minOpacity: CGFloat?
    ) -> CGFloat {
        let offset =
            getOffsetForView(at: index, using: size)
                + getTranslationOffset(at: index, using: size)
        let transparentOpacityOffset: CGFloat = -size.width / overlapMultiplier
        let opaqueOpacityOffset: CGFloat = 0
        let transparentOpacity: CGFloat = minOpacity ?? 0
        let opaqueOpacity: CGFloat = 1
        let opacity =
            opaqueOpacity + (offset - opaqueOpacityOffset)
                * ((transparentOpacity - opaqueOpacity)
                    / (transparentOpacityOffset - opaqueOpacityOffset))
        return max(transparentOpacity, min(1, opacity))
    }
    
    func getOverlayOpacity(
        at index: Int,
        using size: CGSize,
        minOpacity: CGFloat?
    ) -> CGFloat {
        1 - getViewOpacity(at: index, using: size, minOpacity: minOpacity)
    }
}
