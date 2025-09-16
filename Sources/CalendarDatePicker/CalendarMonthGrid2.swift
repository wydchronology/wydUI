import SwiftUI
import Time

public struct CalendarMonthGridConfiguration: Sendable {
    let region: Region
    let verticalSpacing: CGFloat

    public init(
        region: Region = .autoupdatingCurrent,
        verticalSpacing: CGFloat = 10
    ) {
        self.region = region
        self.verticalSpacing = verticalSpacing
    }
}

@MainActor
public struct CalendarMonthGridComponents: Sendable {
    let cell: (Fixed<Day>?) -> AnyView

    public init(
        @ViewBuilder cell: @escaping (Fixed<Day>?) -> some View
    ) {
        self.cell = { day in
            AnyView(cell(day))
        }
    }
}

public struct CalendarMonthGrid2: View {
    let month: Fixed<Month>
    let components: CalendarMonthGridComponents
    let config: CalendarMonthGridConfiguration

    public init(
        month: Fixed<Month>,
        components: CalendarMonthGridComponents,
        config: CalendarMonthGridConfiguration = .init()
    ) {
        self.month = month
        self.components = components
        self.config = config
    }

    private var calendar: Calendar {
        return config.region.calendar
    }

    private var daysInMonth: Int {
        var count = 0
        for _ in month.days {
            count += 1
        }
        return count
    }

    private var totalDaysInGrid: Int {
        let monthStart = month.firstInstant.date
        let startOfMonth = calendar.dateInterval(of: .month, for: monthStart)?.start ?? monthStart
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = self.daysInMonth

        // Calculate how many weeks we need to display
        let totalCells = firstWeekday - 1 + daysInMonth
        let weeksNeeded = (totalCells + 6) / 7 // Round up to nearest week
        return weeksNeeded * 7
    }

    @ViewBuilder
    private func content(index: Int) -> some View {
        // Start counting from the day of the week the first day of the month falls on
        let offset = month.firstDay.dayOfWeek
        let dayOfMonth = month.firstDay.day + index - offset

        let date = calendar.date(
            byAdding: .day,
            value: dayOfMonth - 1,
            to: month.firstInstant.date
        )

        if let date = date {
            let day = Fixed<Day>(region: config.region, date: date)
            day.isDuring(month) ? components.cell(day) : components.cell(nil)
        } else {
            components.cell(nil)
        }
    }

    public var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        LazyVGrid(columns: columns, spacing: config.verticalSpacing) {
            ForEach(1 ... 42, id: \.self) { index in
                content(index: index)
            }
        }
    }
}
