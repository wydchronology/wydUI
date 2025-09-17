import SwiftUI

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
