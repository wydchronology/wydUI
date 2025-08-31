import SwiftUI

public struct QuickSelect<Data: Hashable, Label: View, Trigger: View, Sheet: View>: View {
    let items: [Data]
    let action: (Data) -> Void
    let label: (Data) -> Label

    let isExpanded: Binding<Bool>
    let trigger: () -> Trigger
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
        @ViewBuilder trigger: @escaping () -> Trigger = {
            Image(systemName: "plus")
                .imageScale(.large)
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
            HStack(spacing: config.spacing) {
                ForEach(items, id: \.self) { item in
                    Button(action: {
                        action(item)
                    }) {
                        label(item)
                    }
                    .tint(config.tint)
                    .buttonStyle(.glassProminent)
                }

                Button(action: {
                    isExpanded.wrappedValue = true
                }) {
                    trigger()
                        .matchedTransitionSource(id: transitionSourceID, in: namespace)
                }
                .tint(config.tint)
                .buttonStyle(.glassProminent)
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
        .defaultScrollAnchor(.center)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    @Previewable @State var selectedEmoji: String? = nil
    @Previewable @State var isSheetPresented = false

    VStack(spacing: 20) {
        QuickSelect(
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
                    .font(.body)
                    .padding(4)
            },
            isExpanded: $isSheetPresented,
            trigger: {
                Text("➕")
                    .font(.body)
                    .padding(4)
            },
            sheet: {
                Text("I'm a sheet")
                    .presentationDetents([.medium, .large])
            },
            config: .init(
                tint: Color.pink.opacity(0.2),
                containerPadding: 10,
                spacing: 1,
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
