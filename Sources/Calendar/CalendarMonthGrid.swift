import SwiftUI

public struct CalendarMonthGrid<Cell: View>: View {
    let month: Date
    let cell: (Int?, Date?) -> Cell

    let verticalSpacing: CGFloat

    init(
        verticalSpacing: CGFloat = 14,
        month: Date,
        @ViewBuilder cell: @escaping (Int?, Date?) -> Cell
    ) {
        self.verticalSpacing = verticalSpacing
        self.month = month
        self.cell = cell
    }

    private var daysInMonth: Int {
        let calendar = Calendar.current
        return calendar.range(of: .day, in: .month, for: month)?.count ?? 30
    }

    private var totalDaysInGrid: Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: month)?.start ?? month
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = self.daysInMonth

        // Calculate how many weeks we need to display
        let totalCells = firstWeekday - 1 + daysInMonth
        let weeksNeeded = (totalCells + 6) / 7 // Round up to nearest week
        return weeksNeeded * 7
    }

    private var numberOfRows: Int {
        return totalDaysInGrid / 7
    }

    public var body: some View {
        GeometryReader { geometry in
            let finalSpacing = numberOfRows > 5 ? 0 : verticalSpacing
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: finalSpacing) {
                ForEach(0 ..< totalDaysInGrid, id: \.self) { dayIndex in
                    let calendar = Calendar.current
                    let startOfMonth = calendar.dateInterval(of: .month, for: month)?.start ?? month
                    let firstWeekday = calendar.component(.weekday, from: startOfMonth)
                    let dayOfMonth = dayIndex - firstWeekday + 2

                    if dayOfMonth > 0 && dayOfMonth <= daysInMonth {
                        // Calculate the actual date for this day
                        let actualDate = calendar.date(byAdding: .day, value: dayOfMonth - 1, to: startOfMonth)
                        cell(dayOfMonth, actualDate)
                    } else {
                        cell(nil, nil)
                    }
                }
            }
        }
    }
}
