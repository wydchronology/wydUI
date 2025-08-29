import SwiftUI

public protocol ParallaxPager: View {
    associatedtype Content: View
    associatedtype Backdrop: View
    
    var page: Binding<Int> { get }
    var disabled: Bool { get set }
    
    var content: () -> Content { get }
    var backdrop: () -> Backdrop { get }
}

/// A horizontally paged parallax pager view, with continuous parallax effect as you swipe.
public struct ParallaxPagerView<Content: View, Backdrop: View>: ParallaxPager {
    public var page: Binding<Int>
    public var disabled: Bool = false
    public var style: PagerStyle = .scrollView
    
    public enum PagerStyle {
        case scrollView
        case zStack
    }
    
    public let content: () -> Content
    public let backdrop: () -> Backdrop
    
    public init(
        page: Binding<Int>,
        disabled: Bool = false,
        style: PagerStyle = .scrollView,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder backdrop: @escaping () -> Backdrop = { Color.black.opacity(0.6) }
    ) {
        self.page = page
        self.disabled = disabled
        self.style = style
        self.content = content
        self.backdrop = backdrop
    }
    
    public var body: some View {
        switch style {
        case .scrollView:
            ScrollViewPager(
                page: page,
                disabled: disabled,
                content: content,
                backdrop: backdrop
            )
        case .zStack:
            ZPager(
                page: page,
                disabled: disabled,
                content: content,
                backdrop: backdrop
            )
        }
    }
}

#Preview {
    @Previewable @State var page = 1
    @Previewable @State var useScrollViewStyle = true
    
    ZStack(alignment: .topLeading) {
        ParallaxPagerView(page: $page, style: useScrollViewStyle ? .scrollView : .zStack) {
            Color.pink
                .ignoresSafeArea()
                .overlay(
                    Text("Page \(page + 1)")
                        .font(.largeTitle).foregroundStyle(.white)
                )
            
            TabView {
                Tab("Received", systemImage: "tray.and.arrow.down.fill") {
                    Text("Page \(page + 1)")
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
            .task {
                try? await Task.sleep(for: .seconds(4))
                page = 2
            }
            
            NavigationStack {
                Color.orange
                    .overlay(
                        Text("Page \(page + 1)")
                            .font(.largeTitle).foregroundStyle(.white)
                    )
                    .navigationTitle("Title")
            }
        }
        
        Toggle(isOn: $useScrollViewStyle) {
            Text("Use scroll view style")
        }
        .padding()
    }
}
