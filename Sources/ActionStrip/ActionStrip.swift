import SwiftUI

public struct ActionStrip<Data: Hashable, Label: View, Trigger: View, Sheet: View>: View {
    let items: [Data]
    let action: (Data) -> Void
    let label: (Data) -> Label

    let isExpanded: Binding<Bool>
    let trigger: (String, Namespace.ID) -> Trigger
    let sheet: () -> Sheet

    let config: StyleConfig

    public struct StyleConfig {
        let tint: Color
        let containerPadding: CGFloat
        let spacing: CGFloat

        public init(tint: Color, containerPadding: CGFloat, spacing: CGFloat) {
            self.tint = tint
            self.containerPadding = containerPadding
            self.spacing = spacing
        }
    }

    public init(
        items: [Data],
        action: @escaping (Data) -> Void,
        @ViewBuilder label: @escaping (Data) -> Label,
        isExpanded: Binding<Bool>,
        @ViewBuilder trigger: @escaping (String, Namespace.ID) -> Trigger = { transitionSourceID, namespace in
            Image(systemName: "plus")
                .imageScale(.large)
                .matchedTransitionSource(id: transitionSourceID, in: namespace)
                .frame(width: 30, height: 30)
        },
        @ViewBuilder sheet: @escaping () -> Sheet = {
            EmptyView()
        },
        config: StyleConfig = .init(
            tint: .clear,
            containerPadding: 5,
            spacing: 10,
        ),
    ) {
        self.items = items

        self.action = action
        self.label = label

        self.isExpanded = isExpanded
        self.trigger = trigger
        self.sheet = sheet

        self.config = config
    }

    @Namespace
    private var namespace

    private var transitionSourceID = "expandTrigger"

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GlassEffectContainer {
                HStack(spacing: config.spacing) {
                    ForEach(items, id: \.self) { item in
                        Button(action: {
                            action(item)
                        }) {
                            label(item)
                        }
                        .tint(config.tint)
                        .buttonStyle(.plain)
                    }
                    
                    Button(action: {
                        isExpanded.wrappedValue = true
                    }) {
                        trigger(transitionSourceID, namespace)
                    }
                    .tint(config.tint)
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(config.containerPadding)
                .sheet(isPresented: isExpanded) {
                    sheet()
                        .navigationTransition(
                            .zoom(sourceID: transitionSourceID, in: namespace)
                        )
                }
            }
        }
        .defaultScrollAnchor(.center)
        .scrollContentBackground(.hidden)
        .scrollClipDisabled()
    }
}

#Preview {
    @Previewable @State var selectedEmoji: String? = nil
    @Previewable @State var isSheetPresented = false
    
    ZStack {
        Color.cyan.opacity(0.2)
            .edgesIgnoringSafeArea(.all)
        
        VStack(spacing: 20) {
            ActionStrip(
                items: [
                    "🚶",
                    "🍽️",
                    "🎨",
                    "🚗",
                    "🎤",
                    "🤸",
                ],
                action: { emoji in
                    selectedEmoji = emoji
                },
                label: { emoji in
                    Text(emoji)
                        .padding(10)
                        .clipShape(Circle())
                        .glassEffect(.clear.interactive(), in: .circle)
                },
                isExpanded: $isSheetPresented,
                trigger: { transitionSourceID, namespace in
                    Text("➕")
                        .padding(10)
                        .matchedTransitionSource(id: transitionSourceID, in: namespace)
                        .clipShape(Circle())
                        .glassEffect(.clear.tint(Color.blue).interactive(), in: .circle)
                },
                sheet: {
                    Text("I'm a sheet")
                        .presentationDetents([.medium, .large])
                },
                config: .init(
                    tint: Color.pink.opacity(0.2),
                    containerPadding: 10,
                    spacing: 5,
                )
            )
            
            Text("Choose an Emoji")
                .font(.largeTitle)
            
            if let emoji = selectedEmoji {
                VStack(spacing: 10) {
                    Text("You chose \(emoji)")
                    
                    Button(action: {
                        selectedEmoji = nil
                    }) {
                        Text("Clear")
                    }
                }
            }
        }
    }
}
