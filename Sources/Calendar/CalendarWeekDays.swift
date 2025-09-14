import SwiftUI

struct CalendarWeekDays<Label: View>: View {
    private let weekDaySymbols: [String]
    private let selection: Date
    private let label: (String, Date) -> Label

    init(selection: Date, @ViewBuilder label: @escaping (String, Date) -> Label) {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        weekDaySymbols = formatter.shortWeekdaySymbols.map { $0.uppercased() }
        self.label = label
        self.selection = selection
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekDaySymbols, id: \.self) { day in
                label(day, selection)
            }
        }
    }
}
