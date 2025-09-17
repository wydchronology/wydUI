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
