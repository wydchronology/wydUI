import SwiftUI

struct CalendarDatePickerContext {
    let selection: Date
    let displayedDate: Date
    let cellSize: CGFloat
}

struct CalendarDatePicker<Toolbar: View, MonthYearPicker: View, WeekDayLabel: View>: View {
    @Binding var selection: Date
    @Binding var displayedDate: Date

    private let toolbar: (Binding<Date>, Binding<Bool>) -> Toolbar
    private let monthYearPicker: (Binding<Date>, _ isPresented: Binding<Bool>) -> MonthYearPicker
    private let dayOfWeekLabel: (String, CalendarDatePickerContext) -> WeekDayLabel
    private let page: (CalendarDatePickerContext) -> AnyView
    private let cell: (Date, CalendarDatePickerContext) -> AnyView

    let verticalSpacing: CGFloat
    let cellSize: CGFloat
    let calendar: Calendar

    @State
    private var isMonthYearPickerPresented: Bool = false

    init(
        verticalSpacing: CGFloat = 20,
        cellSize: CGFloat = 40,
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
        @ViewBuilder dayOfWeekLabel: @escaping (String, CalendarDatePickerContext) -> WeekDayLabel = { day, _ in
            Text(day)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        },
        page: ((CalendarDatePickerContext) -> AnyView)? = nil,
        cell: ((Date, CalendarDatePickerContext) -> AnyView)? = nil
    ) {
        self.verticalSpacing = verticalSpacing
        self.cellSize = cellSize
        self.calendar = calendar

        _selection = selection
        _displayedDate = displayedDate

        self.toolbar = toolbar
        self.monthYearPicker = monthYearPicker
        self.dayOfWeekLabel = dayOfWeekLabel

        // Capture the binding locally to avoid capturing `self` in the escaping closure.
        let selectionBinding = selection
        self.cell = cell ?? { date, context in
            AnyView(
                CalendarDateCell(
                    calendar: calendar,
                    date: date,
                    selection: context.selection
                ) {
                    selectionBinding.wrappedValue = date
                }
            )
        }

        // Capture the binding locally to avoid capturing `self` in the escaping closure.
        let cellContent = self.cell
        self.page = page ?? { context in
            AnyView(
                CalendarMonthGrid(month: context.displayedDate) { _, day in
                    if let day = day {
                        cellContent(day, context)
                            .frame(width: context.cellSize, height: context.cellSize)
                    } else {
                        Color.clear
                            .frame(width: context.cellSize, height: context.cellSize)
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
                        .frame(width: proxy.size.width, height: proxy.size.height)
                } else {
                    VStack(spacing: verticalSpacing) {
                        let context = CalendarDatePickerContext(
                            selection: selection,
                            displayedDate: displayedDate,
                            cellSize: cellSize
                        )

                        CalendarWeekDays(selection: selection) { day, _ in
                            dayOfWeekLabel(day, context)
                        }

                        CalendarMonthPager(selection: $displayedDate) { activelyDisplayedDate in
                            let context = CalendarDatePickerContext(
                                selection: selection,
                                displayedDate: activelyDisplayedDate,
                                cellSize: cellSize
                            )
                            page(context)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
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
    .tint(Color(UIColor.brown)) // Example of tinting from outside
}
