import SwiftUI

public struct CalendarDatePickerContext {
    let selection: Date
    let displayedDate: Date
}

public struct CalendarCell<CellContent: View>: View {
    let day: Date?
    let context: CalendarDatePickerContext
    let label: (Date, CalendarDatePickerContext) -> CellContent

    public var body: some View {
        if let day = day {
            label(day, context)
        } else {
            Color.clear
        }
    }
}

public struct CalendarDatePicker<Toolbar: View, MonthYearPicker: View, WeekDayLabel: View, Page: View, Cell: View>: View {
    @Binding var selection: Date
    @Binding var displayedDate: Date

    private let toolbar: (Binding<Date>, Binding<Bool>) -> Toolbar
    private let monthYearPicker: (Binding<Date>, _ isPresented: Binding<Bool>) -> MonthYearPicker
    private let dayOfWeekLabel: (String, CalendarDatePickerContext) -> WeekDayLabel
    private let page: (CalendarDatePickerContext) -> Page
    private let cell: (Date, CalendarDatePickerContext) -> Cell

    let verticalSpacing: CGFloat
    let calendar: Calendar

    @State
    private var isMonthYearPickerPresented: Bool = false

    public init(
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
        @ViewBuilder dayOfWeekLabel: @escaping (String, CalendarDatePickerContext) -> WeekDayLabel = { day, _ in
            Text(day)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        },
        @ViewBuilder page: @escaping (CalendarDatePickerContext) -> Page,
        @ViewBuilder cell: @escaping (Date, CalendarDatePickerContext) -> Cell
    ) {
        self.verticalSpacing = verticalSpacing
        self.calendar = calendar

        _selection = selection
        _displayedDate = displayedDate

        self.toolbar = toolbar
        self.monthYearPicker = monthYearPicker
        self.dayOfWeekLabel = dayOfWeekLabel
        self.cell = cell
        self.page = page
    }

    // Convenience initializer with default page and cell getter
    public init(
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
        @ViewBuilder dayOfWeekLabel: @escaping (String, CalendarDatePickerContext) -> WeekDayLabel = { day, _ in
            Text(day)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        },
    ) where Cell == CalendarDateCell<EmptyView>, Page == CalendarMonthGrid<CalendarCell<CalendarDateCell<EmptyView>>> {
        let cellContent: (Date, CalendarDatePickerContext) -> CalendarDateCell<EmptyView> = { date, context in
            CalendarDateCell(
                date: date,
                selection: context.selection
            ) {
                selection.wrappedValue = date
            }
        }

        let pageContent: (CalendarDatePickerContext) -> CalendarMonthGrid<CalendarCell<CalendarDateCell<EmptyView>>> = { context in
            CalendarMonthGrid(month: context.displayedDate) { _, day in
                CalendarCell(
                    day: day,
                    context: context
                ) { date, context in
                    cellContent(date, context)
                }
            }
        }

        self.init(
            verticalSpacing: verticalSpacing,
            calendar: calendar,
            selection: selection,
            displayedDate: displayedDate,
            toolbar: toolbar,
            monthYearPicker: monthYearPicker,
            dayOfWeekLabel: dayOfWeekLabel,
            page: pageContent,
            cell: cellContent
        )
    }

    // Convenience initializer with default page and cell getter
    public init(
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
        @ViewBuilder dayOfWeekLabel: @escaping (String, CalendarDatePickerContext) -> WeekDayLabel = { day, _ in
            Text(day)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        },
        @ViewBuilder cell: @escaping (Date, CalendarDatePickerContext) -> Cell
    ) where Page == CalendarMonthGrid<CalendarCell<Cell>> {
        let pageContent: (CalendarDatePickerContext) -> CalendarMonthGrid<CalendarCell<Cell>> = { context in
            CalendarMonthGrid(month: context.displayedDate) { _, day in
                CalendarCell(
                    day: day,
                    context: context
                ) { date, context in
                    cell(date, context)
                }
            }
        }

        self.init(
            verticalSpacing: verticalSpacing,
            calendar: calendar,
            selection: selection,
            displayedDate: displayedDate,
            toolbar: toolbar,
            monthYearPicker: monthYearPicker,
            dayOfWeekLabel: dayOfWeekLabel,
            page: pageContent,
            cell: cell
        )
    }

    public var body: some View {
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
                        )

                        CalendarWeekDays(selection: selection) { day, _ in
                            dayOfWeekLabel(day, context)
                        }

                        CalendarMonthPager(selection: $displayedDate) { activelyDisplayedDate in
                            let context = CalendarDatePickerContext(
                                selection: selection,
                                displayedDate: activelyDisplayedDate,
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

#Preview("Default Page and Cell") {
    @Previewable @State var selection = Date()
    @Previewable @State var displayedDate = Date()

    CalendarDatePicker(
        selection: $selection,
        displayedDate: $displayedDate
    )
    .frame(height: 450)
    .padding()
    .tint(Color(UIColor.purple)) // Example of tinting from outside
}

#Preview("Custom Cell") {
    @Previewable @State var selection = Date()
    @Previewable @State var displayedDate = Date()

    CalendarDatePicker(
        selection: $selection,
        displayedDate: $displayedDate,
        cell: { date, _ in
            CalendarDateCell(
                date: date,
                selection: selection,
                indicator: { _ in
                    if Bool.random() {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 5, height: 5)
                    }
                }
            ) {
                selection = date
            }
        }
    )
    .frame(height: 450)
    .padding()
    .tint(Color(UIColor.brown)) // Example of tinting from outside
}

#Preview("Custom Page and Cell") {
    @Previewable @State var selection = Date()
    @Previewable @State var displayedDate = Date()

    CalendarDatePicker(
        selection: $selection,
        displayedDate: $displayedDate,
        page: { context in
            CalendarMonthGrid(month: context.displayedDate) { _, day in
                CalendarCell(
                    day: day,
                    context: context
                ) { date, context in
                    CalendarDateCell(
                        date: date,
                        selection: context.selection,
                        indicator: { _ in
                            Circle()
                                .fill(Color.red)
                                .frame(width: 3, height: 3)
                        }
                    ) {
                        selection = date
                    }
                }
            }
        },
        cell: { date, _ in
            CalendarDateCell(
                date: date,
                selection: selection
            ) {
                selection = date
            }
        }
    )
    .frame(height: 450)
    .padding()
    .tint(Color(UIColor.purple)) // Example of tinting from outside
}

#Preview("Frame Modifier Test") {
    @Previewable @State var selection = Date()
    @Previewable @State var displayedDate = Date()

    CalendarDatePicker(
        selection: $selection,
        displayedDate: $displayedDate,
        page: { context in
            CalendarMonthGrid(month: context.displayedDate) { _, day in
                CalendarCell(
                    day: day,
                    context: context
                ) { date, context in
                    CalendarDateCell(
                        date: date,
                        selection: context.selection
                    ) {
                        selection = date
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top) // This now works!
        },
        cell: { date, _ in
            CalendarDateCell(
                date: date,
                selection: selection
            ) {
                selection = date
            }
        }
    )
    .frame(height: 450)
    .padding()
    .tint(Color(UIColor.purple))
}
