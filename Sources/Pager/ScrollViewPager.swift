import SwiftUI
import SwiftUIIntrospect

/// Implementation of ParallaxPager using a ScrollView with .paging behavior
struct ScrollViewPager<Content: View, Backdrop: View>: ParallaxPager {
    var page: Binding<Int>
    var disabled: Bool = false
    
    let content: () -> Content
    let backdrop: () -> Backdrop
    
    // Internal binding to convert Int <-> Int? for .scrollPosition(id:)
    private var selectedPage: Binding<Int?> {
        Binding<Int?>(
            get: { page.wrappedValue },
            set: { newValue in
                if let value = newValue {
                    page.wrappedValue = value
                }
            }
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width
            let containerHeight = geometry.size.height
            
            Group(subviews: content()) { views in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: .zero) {
                        ForEach(0 ..< views.count, id: \.self) { index in
                            VStack {
                                GeometryReader { geo in
                                    let minX = geo.frame(in: .scrollView).minX
                                    let translationOffset = minX * 0.15
                                    
                                    ZStack {
                                        views[index]
                                            .id(index)
                                            .clipShape(LeadingCornersContainerRelativeShape())
                                            .offset(x: translationOffset)
                                            .scrollTransition(
                                                .interactive(timingCurve: .linear),
                                                axis: .horizontal
                                            ) { content, phase in
                                                content
                                                    .offset(x: phase.value <= 0 ? -minX : 0)
                                            }
                                            .overlay(
                                                backdrop()
                                                    .scrollTransition(axis: .horizontal) { content, phase in
                                                        content
                                                            .offset(x: phase.value <= 0 ? -minX : 0)
                                                            .opacity(phase.isIdentity ? 0 : -phase.value)
                                                    }
                                                    .allowsHitTesting(false)
                                            )
                                    }
                                    .ignoresSafeArea()
                                }
                            }
                            .ignoresSafeArea()
                            .frame(width: containerWidth, height: containerHeight)
                        }
                    }
                    .scrollTargetLayout()
                }
                .introspect(.scrollView, on: .iOS(.v26)) { scrollView in
                    scrollView.bounces = false
                }
                .scrollPosition(id: selectedPage)
                .scrollTargetBehavior(.paging)
                .scrollDisabled(disabled)
            }
        }
        .animation(.default, value: page.wrappedValue)
    }
}
