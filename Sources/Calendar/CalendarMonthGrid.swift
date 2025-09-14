import SwiftUI

public struct CalendarMonthGrid<DayView: View>: View {
    let month: Date
    let dayViewBuilder: (Int?, Date?) -> DayView

    let verticalSpacing: CGFloat

    init(verticalSpacing: CGFloat = 10, month: Date, @ViewBuilder dayViewBuilder: @escaping (Int?, Date?) -> DayView) {
        self.verticalSpacing = verticalSpacing
        self.month = month
        self.dayViewBuilder = dayViewBuilder
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

    public var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: verticalSpacing) {
            ForEach(0 ..< totalDaysInGrid, id: \.self) { dayIndex in
                let calendar = Calendar.current
                let startOfMonth = calendar.dateInterval(of: .month, for: month)?.start ?? month
                let firstWeekday = calendar.component(.weekday, from: startOfMonth)
                let dayOfMonth = dayIndex - firstWeekday + 2

                if dayOfMonth > 0 && dayOfMonth <= daysInMonth {
                    // Calculate the actual date for this day
                    let actualDate = calendar.date(byAdding: .day, value: dayOfMonth - 1, to: startOfMonth)
                    dayViewBuilder(dayOfMonth, actualDate)
                } else {
                    dayViewBuilder(nil, nil)
                }
            }
        }
    }
}
