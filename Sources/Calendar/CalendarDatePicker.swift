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
                .foregroundColor(Color(UIColor.tertiaryLabel))
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
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        },
    ) where Cell == CalendarDateCell<EmptyView, CalendarDateCellLabel>, Page == CalendarMonthGrid<CalendarCell<CalendarDateCell<EmptyView, CalendarDateCellLabel>>> {
        let cellContent: (
            Date,
            CalendarDatePickerContext
        ) -> CalendarDateCell<EmptyView, CalendarDateCellLabel> = { date, context in
            CalendarDateCell(
                date: date,
                selection: context.selection
            ) {
                selection.wrappedValue = date
            }
        }

        let pageContent: (CalendarDatePickerContext) -> CalendarMonthGrid<CalendarCell<CalendarDateCell<EmptyView, CalendarDateCellLabel>>> = { context in
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

    public var body: some View {
        VStack(spacing: verticalSpacing) {
            toolbar($displayedDate, $isMonthYearPickerPresented)

            if isMonthYearPickerPresented {
                monthYearPicker($displayedDate, $isMonthYearPickerPresented)
                    .frame(minHeight: 380, alignment: .top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
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
                            .padding(.top, verticalSpacing / 2)
                    }
                    .frame(minHeight: 380, alignment: .top)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview("Default Page and Cell") {
    @Previewable @State var selection = Date()
    @Previewable @State var displayedDate = Date()

    ZStack {
        LinearGradient(
            colors: [.purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)

        ScrollView {
            CalendarDatePicker(
                selection: $selection,
                displayedDate: $displayedDate
            )
            .padding()
            .tint(Color(UIColor.purple)) // Example of tinting from outside
        }
    }
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
                label: { dayString, isSelected, isToday, size in
                    Text(dayString)
                        .frame(width: size, height: size)
                        .font(.system(.body, design: .rounded, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? (isToday ? Color(UIColor.white) : Color.accentColor) : (isToday ? Color.accentColor : Color(UIColor.label)))
                        .background(isSelected ? (isToday ? Color.accentColor : Color.accentColor.opacity(0.1)) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                },
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
            .buttonStyle(
                ClippedShapeButtonStyle(shape: RoundedRectangle(cornerRadius: 5))
            )
        }
    )
    .frame(height: 450)
    .padding()
    .tint(Color(UIColor.magenta)) // Example of tinting from outside
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
