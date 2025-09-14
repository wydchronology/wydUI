import SwiftUI

struct CalendarWeekDays<Label: View>: View {
    private let weekDaySymbols: [String]
    private let selection: Date
    private let label: (String, Date) -> Label
    private let spacing: CGFloat
    private let size: CGFloat

    init(spacing: CGFloat = 10, size: CGFloat = 40, selection: Date, @ViewBuilder label: @escaping (String, Date) -> Label) {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        weekDaySymbols = formatter.shortWeekdaySymbols.map { $0.uppercased() }
        self.label = label
        self.selection = selection

        self.spacing = spacing
        self.size = size
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.adaptive(minimum: size)), count: 7)
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(weekDaySymbols, id: \.self) { day in
                label(day, selection)
            }
        }
    }
}
