import SwiftUI

struct CalendarDatePicker<Toolbar: View, MonthYearPicker: View, WeekDayLabel: View>: View {
    @Binding var selection: Date
    @Binding var displayedDate: Date

    @State private var isMonthYearPickerPresented: Bool = false

    private let toolbar: (Binding<Date>, Binding<Bool>) -> Toolbar
    private let monthYearPicker: (Binding<Date>, _ isPresented: Binding<Bool>) -> MonthYearPicker
    private let weekDayLabel: (String, Date) -> WeekDayLabel
    private let page: (Date) -> AnyView
    private let cell: (Date, Bool) -> AnyView

    let verticalSpacing: CGFloat
    let calendar: Calendar

    init(
        verticalSpacing: CGFloat = 20,
        calendar: Calendar = Calendar.autoupdatingCurrent,
        selection: Binding<Date>,
        displayedDate: Binding<Date>,
        @ViewBuilder toolbar: @escaping (Binding<Date>, Binding<Bool>) -> Toolbar = { displayedDate, isPresented in
            CalendarDatePickerToolbar(
                selection: displayedDate,
                isMonthYearPickerPresented: isPresented
            )
        },
        @ViewBuilder monthYearPicker: @escaping (Binding<Date>, _ isPresented: Binding<Bool>) -> MonthYearPicker = { selection, isPresented in
            CalendarMonthYearPicker(
                selection: selection,
                isPresented: isPresented
            )
        },
        @ViewBuilder weekDayLabel: @escaping (String, Date) -> WeekDayLabel = { day, _ in
            Text(day)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(.secondary)
        },
        page: ((Date) -> AnyView)? = nil,
        cell: ((Date, Bool) -> AnyView)? = nil
    ) {
        self.verticalSpacing = verticalSpacing
        self.calendar = calendar

        _selection = selection
        _displayedDate = displayedDate

        self.toolbar = toolbar
        self.monthYearPicker = monthYearPicker
        self.weekDayLabel = weekDayLabel

        // Capture the binding locally to avoid capturing `self` in the escaping closure.
        let selectionBinding = selection
        self.cell = cell ?? { date, isSelected in
            AnyView(
                CalendarDateCell(date: date, isSelected: isSelected) {
                    selectionBinding.wrappedValue = date
                }
            )
        }

        // Capture the binding locally to avoid capturing `self` in the escaping closure.
        let cellContent = self.cell
        self.page = page ?? { month in
            AnyView(
                CalendarMonthGrid(month: month) { _, day in
                    if let day = day {
                        let isSelected = calendar.isDate(day, inSameDayAs: selection.wrappedValue)
                        cellContent(day, isSelected)
                    } else {
                        Color.clear
                    }
                }
            )
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: verticalSpacing) {
                toolbar($displayedDate, $isMonthYearPickerPresented)

                if isMonthYearPickerPresented {
                    monthYearPicker($displayedDate, $isMonthYearPickerPresented)
                        .frame(maxWidth: .infinity)
                        .frame(height: proxy.size.height)
                } else {
                    VStack(spacing: verticalSpacing) {
                        CalendarWeekDays(selection: selection) { day, date in
                            weekDayLabel(day, date)
                        }

                        CalendarMonthPager(selection: $displayedDate) { month in
                            page(month)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: proxy.size.height)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selection = Date()
    @Previewable @State var displayedDate = Date()

    CalendarDatePicker(
        selection: $selection,
        displayedDate: $displayedDate
    )
    .frame(height: 300)
    .padding()
    .tint(.green) // Example of tinting from outside
}
