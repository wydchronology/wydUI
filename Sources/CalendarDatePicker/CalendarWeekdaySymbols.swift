import SwiftUI

@MainActor
public struct CalendarWeekdaySymbolsComponents: Sendable {
    let symbol: (_ label: String, _ isHighlighted: Bool) -> AnyView

    public static let defaultSymbol: (_ label: String, _ isHighlighted: Bool) -> AnyView = { label, isHighlighted in
        AnyView(
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(isHighlighted ? .primary : .secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }

    public init(symbol: @escaping (_ label: String, _ isHighlighted: Bool) -> some View) {
        self.symbol = { label, isHighlighted in
            AnyView(symbol(label, isHighlighted))
        }
    }

    public init() {
        symbol = Self.defaultSymbol
    }
}

public struct CalendarWeekdaySymbols: View {
    let highlightedIndex: Int?
    let components: CalendarWeekdaySymbolsComponents

    public init(highlightedIndex: Int?, components: CalendarWeekdaySymbolsComponents = .init()) {
        self.highlightedIndex = highlightedIndex
        self.components = components
    }

    public var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        let weekDaySymbols = Calendar.current.shortWeekdaySymbols.map { $0.uppercased() }
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekDaySymbols.enumerated(), id: \.offset) { index, label in
                let isHighlighted = highlightedIndex != nil ? highlightedIndex == index + 1 : false
                components.symbol(label, isHighlighted)
            }
        }
    }
}
