import EmojiKit
import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

public struct EmojiListView<HeaderContent: View, RowContent: View>: View {
    let header: (String) -> HeaderContent
    let row: (String, [String]) -> RowContent
    let groupSize: Int

    @usableFromInline
    init(
        @ViewBuilder header: @escaping (String) -> HeaderContent,
        @ViewBuilder row: @escaping (String, [String]) -> RowContent,
        groupSize: Int = 8
    ) {
        self.groupSize = groupSize
        self.header = header
        self.row = row
    }

    public var body: some View {
        List {
            ForEach(EmojiManager.getAvailableEmojis(), id: \.name) { category in
                Section(header: header(category.name.rawValue)) {
                    let emojiGroups = category.values.chunked(into: groupSize)
                    ForEach(Array(emojiGroups.enumerated()), id: \.offset) { _, group in
                        row(category.name.rawValue, group)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

public struct EmojiQuickSelect<Label: View, Trigger: View, Sheet: View>: View {
    let defaults: [String]
    let tint: Color
    let containerPadding: CGFloat
    let spacing: CGFloat
    let action: (String) -> Void
    let label: (String) -> Label
    let trigger: () -> Trigger
    let sheet: () -> Sheet
    let isSheetPresented: Binding<Bool>

    public init(
        defaults: [String] = [
            "🚶",
            "🍽️",
            "🎨",
            "🚗",
            "🎤",
            "🤸",
        ],
        tint: Color = .clear,
        containerPadding: CGFloat = 5,
        spacing: CGFloat = 10,
        action: @escaping (String) -> Void,
        @ViewBuilder label: @escaping (String) -> Label = { emoji in
            Text(emoji)
                .frame(width: 30, height: 30)
        },
        isSheetPresented: Binding<Bool>,
        @ViewBuilder trigger: @escaping () -> Trigger = {
            Image(systemName: "plus")
                .imageScale(.large)
                .frame(width: 30, height: 30)
        },
        @ViewBuilder sheet: @escaping () -> Sheet
    ) {
        self.defaults = defaults
        self.tint = tint
        self.containerPadding = containerPadding
        self.spacing = spacing
        self.action = action
        self.label = label
        self.isSheetPresented = isSheetPresented
        self.trigger = trigger
        self.sheet = sheet
    }

    @Namespace
    private var namespace

    private var navigationTransitionSourceID = "expandTrigger"

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(defaults, id: \.self) { emoji in
                    Button(action: {
                        action(emoji)
                    }) {
                        label(emoji)
                    }
                    .tint(tint)
                    .buttonStyle(.glassProminent)
                }

                Button(action: {
                    isSheetPresented.wrappedValue = true
                }) {
                    trigger()
                        .matchedTransitionSource(id: navigationTransitionSourceID, in: namespace)
                }
                .tint(tint)
                .buttonStyle(.glassProminent)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(containerPadding)
            .sheet(isPresented: isSheetPresented) {
                sheet()
                    .navigationTransition(
                        .zoom(sourceID: navigationTransitionSourceID, in: namespace)
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
        EmojiQuickSelect(
            tint: Color.pink.opacity(0.2),
            containerPadding: 10,
            spacing: 1,
            action: { emoji in
                selectedEmoji = emoji
            },
            label: { emoji in
                Text(emoji)
                    .font(.body)
                    .padding(4)
            },
            isSheetPresented: $isSheetPresented,
            trigger: {
                Text("➕")
                    .font(.body)
                    .padding(4)
            },
            sheet: {
                EmojiListView(header: { category in
                    Text(category)
                }) { _, group in
                    HStack(spacing: 8) {
                        ForEach(group, id: \.self) { emoji in
                            Text(emoji)
                                .frame(maxHeight: .infinity, alignment: .center)
                                .font(.title2)
                                .glassEffect()
                                .onTapGesture {
                                    selectedEmoji = emoji
                                    isSheetPresented = false
                                }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                }
                .presentationDetents([.medium, .large])
            }
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
