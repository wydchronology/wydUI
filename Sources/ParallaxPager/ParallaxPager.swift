import SwiftUI
import SwiftUIIntrospect

/// A horizontally paged parallax pager view, with continuous parallax effect as you swipe.
public struct ParallaxPager<Content: View, Backdrop: View>: View {
    var startAt: Int = 0
    var disabled: Bool = false
    
    let content: () -> Content
    let backdrop: () -> Backdrop
    
    @State
    private var scrollPosition: ScrollPosition = .init(idType: Int.self)
    
    public init(
        startAt: Int = 0,
        disabled: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder backdrop: @escaping () -> Backdrop = { Color.black.opacity(0.6) }
    ) {
        self.startAt = startAt
        self.disabled = disabled
        self.content = content
        self.backdrop = backdrop
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
                .onAppear {
                    scrollPosition.scrollTo(id: startAt)
                }
                .scrollPosition($scrollPosition)
                .scrollTargetBehavior(.paging)
                .scrollDisabled(disabled)
            }
        }
    }
}

#Preview {
    ParallaxPager(startAt: 1) {
        Color.pink
            .ignoresSafeArea()
            .overlay(
                Text("Hello, World!")
                    .font(.largeTitle).foregroundStyle(.white)
            )
        
        TabView {
            Tab("Received", systemImage: "tray.and.arrow.down.fill") {
                Text("received")
                    .tag(0)
            }
            .badge(2)
            
            Tab("Sent", systemImage: "tray.and.arrow.up.fill") {
                Text("sent")
                    .tag(1)
            }
            
            Tab("Account", systemImage: "person.crop.circle.fill") {
                Text("account")
                    .tag(2)
            }
            .badge("!")
        }
        
        NavigationStack {
            Color.orange
                .overlay(
                    Text("Hello, World 3!")
                        .font(.largeTitle).foregroundStyle(.white)
                )
                .navigationTitle("Title")
        }
    }
}
